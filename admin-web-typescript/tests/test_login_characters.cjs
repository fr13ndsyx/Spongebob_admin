const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { parse, compileScript } = require('@vue/compiler-sfc');
const ts = require('typescript');
const vue = require('vue');

const componentDir = path.resolve(__dirname, '../src/views/system/login3');
const modules = new Map();
const listeners = new Map();
const mediaListeners = new Map();
const media = {
  matches: false,
  addEventListener: (name, callback) => mediaListeners.set(name, callback),
  removeEventListener: (name) => mediaListeners.delete(name),
};
const clock = {
  matchMedia: () => media,
  addEventListener: (name, callback) => listeners.set(name, callback),
  removeEventListener: (name) => listeners.delete(name),
};

function loadComponent(filename) {
  if (modules.has(filename)) return modules.get(filename);
  const source = fs.readFileSync(filename, 'utf8');
  const parsed = parse(source, { filename });
  assert.equal(parsed.errors.length, 0);
  const compiled = compileScript(parsed.descriptor, {
    id: path.basename(filename),
    inlineTemplate: true,
    templateOptions: { compilerOptions: { hoistStatic: false } },
  });
  const code = ts.transpileModule(compiled.content, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
  }).outputText;
  const module = { exports: {} };
  vm.runInNewContext(code, {
    module,
    exports: module.exports,
    require: (name) => name.endsWith('.vue') ? loadComponent(path.resolve(path.dirname(filename), name)) : require(name),
    window: clock,
  }, { filename });
  modules.set(filename, module.exports);
  return module.exports;
}

function element(type) {
  return {
    type, props: {}, style: {}, children: [], parent: null,
    getBoundingClientRect: () => ({ left: 0, top: 0, width: 520, height: 450 }),
  };
}

const renderer = vue.createRenderer({
  createElement: element,
  createText: (text) => ({ ...element('text'), text }),
  createComment: (text) => ({ ...element('comment'), text }),
  setText: (node, text) => { node.text = text; },
  setElementText: (node, text) => { node.text = text; },
  parentNode: (node) => node.parent,
  nextSibling: (node) => node.parent?.children[node.parent.children.indexOf(node) + 1] ?? null,
  patchProp: (node, key, previous, value) => {
    node.props[key] = value;
    if (key === 'style') Object.assign(node.style, value);
  },
  insert: (node, parent, anchor) => {
    if (node.parent) node.parent.children.splice(node.parent.children.indexOf(node), 1);
    node.parent = parent;
    const index = parent.children.indexOf(anchor);
    parent.children.splice(index < 0 ? parent.children.length : index, 0, node);
  },
  remove: (node) => {
    node.parent.children.splice(node.parent.children.indexOf(node), 1);
    node.parent = null;
  },
});

function nodes(root, className) {
  const matches = (root.props.class ?? '').split(' ').includes(className) ? [root] : [];
  return matches.concat(root.children.flatMap((child) => nodes(child, className)));
}

async function check() {
  const props = vue.reactive({ isTyping: false, hasSecret: false, secretVisible: false });
  const root = element('root');
  const component = loadComponent(path.join(componentDir, 'AnimatedCharacters.vue')).default;
  const app = renderer.createApp({ setup: () => () => vue.h(component, props) });
  app.mount(root);
  await vue.nextTick();
  const scene = nodes(root, 'characters')[0];
  assert.equal(scene.type, 'svg', 'Characters must render as the approved SVG artwork');
  const pupils = nodes(root, 'pupil');
  assert.equal(pupils.length, 2);
  const arms = nodes(root, 'arm');
  assert.equal(arms.length, 4, 'Each character must have only two persistent arms');
  for (const name of ['patrick-pose', 'sponge-pose']) assert.equal(nodes(nodes(root, name)[0], 'arm').length, 2);
  assert.equal(scene.props['data-mode'], 'tracking');
  listeners.get('mousemove')({ clientX: 260, clientY: 225 });
  await vue.nextTick();
  for (const pupil of pupils) assert.equal(pupil.props.transform, 'translate(0 0)');
  listeners.get('mousemove')({ clientX: 10000, clientY: -10000 });
  await vue.nextTick();
  assert.equal(pupils[0].props.transform, 'translate(5 -5)');
  assert.equal(pupils[1].props.transform, 'translate(6 -6)');
  props.isTyping = true;
  await vue.nextTick();
  assert.equal(scene.props['data-mode'], 'leaning');
  props.isTyping = false;
  props.hasSecret = true;
  await vue.nextTick();
  assert.equal(scene.props['data-mode'], 'leaning');
  props.secretVisible = true;
  await vue.nextTick();
  assert.equal(scene.props['data-mode'], 'hiding');
  nodes(root, 'arm').forEach((arm, index) => assert.equal(arm, arms[index], 'Hiding must move the existing arms'));
  for (const pupil of pupils) assert.equal(pupil.props.transform, 'translate(0 0)');
  props.hasSecret = false;
  await vue.nextTick();
  assert.equal(scene.props['data-mode'], 'tracking');
  media.matches = true;
  mediaListeners.get('change')();
  listeners.get('mousemove')({ clientX: 10000, clientY: 10000 });
  await vue.nextTick();
  for (const pupil of pupils) assert.equal(pupil.props.transform, 'translate(0 0)');
  props.hasSecret = true;
  await vue.nextTick();
  assert.equal(scene.props['data-mode'], 'hiding');
  props.hasSecret = false;
  await vue.nextTick();
  media.matches = false;
  mediaListeners.get('change')();
  listeners.get('mousemove')({ clientX: 0, clientY: 450 });
  await vue.nextTick();
  assert.equal(pupils[0].props.transform, 'translate(-5 5)');
  listeners.get('blur')();
  await vue.nextTick();
  for (const pupil of pupils) assert.equal(pupil.props.transform, 'translate(0 0)');
  scene.getBoundingClientRect = () => ({ left: 0, top: 0, width: 0, height: 0 });
  listeners.get('mousemove')({ clientX: 100, clientY: 100 });
  await vue.nextTick();
  for (const pupil of pupils) assert.equal(pupil.props.transform, 'translate(0 0)');
  app.unmount();
  assert.equal(listeners.size, 0);
  assert.equal(mediaListeners.size, 0);
  media.matches = true;
  const reducedRoot = element('root');
  const reducedApp = renderer.createApp(component, { isTyping: false, hasSecret: false, secretVisible: false });
  reducedApp.mount(reducedRoot);
  listeners.get('mousemove')({ clientX: 10000, clientY: -10000 });
  await vue.nextTick();
  for (const pupil of nodes(reducedRoot, 'pupil')) assert.equal(pupil.props.transform, 'translate(0 0)');
  reducedApp.unmount();
  assert.equal(listeners.size, 0);
  assert.equal(mediaListeners.size, 0);
  process.stdout.write('Login character animation checks passed.\n');
}

check().catch((error) => { process.stderr.write(`${error.stack}\n`); process.exitCode = 1; });
