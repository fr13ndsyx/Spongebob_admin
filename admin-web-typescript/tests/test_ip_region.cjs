const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require('typescript');
const vue = require('vue');
const { parse, compileScript, compileTemplate } = require('@vue/compiler-sfc');
const root = path.resolve(__dirname, '..');

function loadScript(source, imports) {
  const module = { exports: {} };
  const code = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
  }).outputText;
  vm.runInNewContext(code, { module, exports: module.exports, require: name => imports[name] });
  return module.exports;
}

function regionExpression(node) {
  if (node.type === 5 && /\bdetail\.ipRegion\b/.test(node.content.content)) return node.loc.source;
  for (const child of node.children ?? []) {
    const expression = regionExpression(child);
    if (expression) return expression;
  }
}

const filename = 'src/views/support/operate-log/operate-log-detail-modal.vue';
const parsed = parse(fs.readFileSync(path.join(root, filename), 'utf8'), { filename });
assert.equal(parsed.errors.length, 0);
const script = compileScript(parsed.descriptor, { id: filename });
const expression = regionExpression(parsed.descriptor.template.ast);
assert.ok(expression);
const template = compileTemplate({
  source: expression, filename, id: filename,
  compilerOptions: { bindingMetadata: script.bindings },
});
assert.equal(template.errors.length, 0);
const { render } = loadScript(template.code, { vue });
const imports = {};
if (script.bindings.formatIpRegion) {
  Object.assign(imports, loadScript(fs.readFileSync(path.join(root, 'src/lib/ip-region.ts'), 'utf8'), {}));
}
for (const [input, expected] of [
  ['中国|0|湖南省|长沙市|电信', '中国|湖南省|长沙市|电信'],
  ['0|中国|0|湖南省|0|长沙市|电信|0', '中国|湖南省|长沙市|电信'],
  ['中国||湖南省|长沙市|', '中国|湖南省|长沙市'],
  [' 中国 | 0 | 湖南省 | 长沙市 | 电信 ', '中国|湖南省|长沙市|电信'],
  ['0|0|0|内网IP|内网IP', '内网IP|内网IP'],
  ['区域10|运营商0', '区域10|运营商0'],
  ['中国|北京|北京|联通', '中国|北京|北京|联通'],
  ['0|0|0', ''],
  [null, ''],
  [undefined, ''],
  ['', ''],
]) {
  const output = render({}, [], {}, { ...imports, detail: { ipRegion: input } });
  assert.equal(typeof output === 'string' ? output : output.children, expected);
}
process.stdout.write('IP region display checks passed.\n');
