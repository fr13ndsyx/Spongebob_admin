const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require('typescript');
const vue = require('vue');
const { parse, compileScript, compileTemplate, compileStyle } = require('@vue/compiler-sfc');

const root = path.resolve(__dirname, '..');
function loadComponent(filename, imports) {
  const { descriptor, errors } = parse(fs.readFileSync(path.join(root, filename), 'utf8'), { filename });
  assert.equal(errors.length, 0);
  const script = compileScript(descriptor, { id: filename });
  const template = compileTemplate({ source: descriptor.template.content, filename, id: filename, compilerOptions: { bindingMetadata: script.bindings } });
  assert.equal(template.errors.length, 0, filename);
  const module = { exports: {} };
  const code = ts.transpileModule(script.content, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 } }).outputText;
  const mounted = [];
  const activated = [];
  vm.runInNewContext(code, {
    module,
    exports: module.exports,
    document: { getElementsByClassName: () => [] },
    require: name => {
      if (name === 'vue') return { ...vue, onMounted: fn => mounted.push(fn), onActivated: fn => activated.push(fn) };
      assert.ok(Object.hasOwn(imports, name), name);
      return imports[name];
    },
  });
  const emitted = [];
  return { setup: module.exports.default.setup({}, { expose: () => {}, emit: (...args) => emitted.push(args) }), descriptor, mounted, activated, emitted };
}
async function main() {
  let departments = [
    { departmentId: 1, parentId: 0, departmentName: '总部' },
    { departmentId: 2, parentId: 0, departmentName: '分部' },
    { departmentId: 3, parentId: 2, departmentName: '产品部' },
  ];
  let shown;
  const memberRequests = new Map();
  const sentryErrors = [];
  const support = {
    '/@/lib/sentry': { sentry: { captureError: error => sentryErrors.push(error) } },
    '/@/components/framework/loading': { Loading: { show: () => {}, hide: () => {} } },
    '/@/api/system/department-api': { departmentApi: { queryAllDepartment: async () => ({ data: departments }) } },
  };
  const list = loadComponent('src/views/system/department/department-list.vue', {
    ...support,
    'lodash': { default: require('lodash') },
    'ant-design-vue': { Modal: {} },
    '@ant-design/icons-vue': { ExclamationCircleOutlined: {} },
    './components/department-form-modal.vue': {},
    './components/pearl-visuals/OrgCanvas.vue': {},
    '/@/api/system/employee-api': { employeeApi: {
      queryAll: async () => ({ data: [] }),
      queryEmployeeByDeptId: departmentId => new Promise(resolve => memberRequests.set(departmentId, resolve)),
    } },
  });
  const department = list.setup;
  department.departmentFormModal.value = { showModal: data => { shown = data; } };
  department.addDepartment();
  assert.equal(shown.parentId, 0);
  department.addDepartment(departments[1]);
  assert.equal(shown.parentId, 2);
  await department.queryDepartmentTree();
  assert.deepEqual(Array.from(department.departmentTreeData.value, item => item.departmentId), [1, 2]);
  assert.equal(department.departmentTreeData.value[1].children[0].departmentId, 3);
  assert.equal(department.departmentTreeData.value[0].children, undefined);
  assert.deepEqual(Array.from(department.defaultExpandedRowList.value), [1, 2]);
  department.memberCountByDepartmentId.value = { 3: 2 };
  const orgRoots = department.orgTree.value;
  assert.deepEqual(Array.from(orgRoots, node => node.id), [1, 2]);
  assert.equal(orgRoots[0].memberCount, 0);
  assert.equal(orgRoots[1].children[0].name, '产品部');
  assert.equal(orgRoots[1].children[0].memberCount, 2);
  const staleSelection = department.selectOrgNode(orgRoots[0]);
  const latestSelection = department.selectOrgNode(orgRoots[1]);
  memberRequests.get(2)({ data: [{ employeeId: 5, actualName: '成员甲', disabledFlag: false }] });
  await latestSelection;
  memberRequests.get(1)({ data: [{ employeeId: 6, actualName: '成员乙', disabledFlag: false }] });
  await staleSelection;
  assert.equal(department.selectedOrgNode.value.id, 2);
  assert.deepEqual(Array.from(department.selectedMembers.value, member => member.employeeId), [5]);
  assert.equal(department.membersLoading.value, false);
  department.keywords.value = '产品';
  department.onSearch();
  assert.equal(department.departmentTreeData.value.length, 1);
  assert.equal(department.departmentTreeData.value[0].departmentId, 2);
  departments = [];
  await department.queryDepartmentTree();
  assert.equal(department.idInfoMap.value.size, 0);
  assert.equal(department.defaultExpandedRowList.value.length, 0);
  assert.equal(department.departmentTreeData.value.length, 0);

  const submitted = [];
  const form = loadComponent('src/views/system/department/components/department-form-modal.vue', {
    ...support,
    'ant-design-vue/lib/message': { default: { error: message => { throw Error(message); }, warning: () => {} } },
    '/@/components/system/department-tree-select/index.vue': {},
    '/@/components/system/employee-select/index.vue': {},
    '/@/api/system/department-api': { departmentApi: {
      addDepartment: async data => submitted.push({ ...data }),
      updateDepartment: async () => { throw Error('New department must not update an old row'); },
    } },
  }).setup;
  form.formRef.value = { validate: async () => {} };
  form.showModal({ departmentId: 42, parentId: 0, departmentName: '既有部门' });
  form.closeModal();
  form.showModal({ parentId: 0, departmentName: '新一级部门' });
  assert.equal(form.formState.departmentId, undefined);
  await form.addDepartment();
  assert.equal(submitted[0].parentId, 0);
  assert.equal(submitted[0].departmentName, '新一级部门');

  const requests = [];
  let finish;
  let failure = false;
  const homeUser = vue.reactive({ actualName: '管理员', lastLoginIpRegion: '0|0|0|内网IP|内网IP' });
  const home = loadComponent('src/views/system/home/index.vue', {
    '/@/store/modules/system/user': { useUserStore: () => homeUser },
    '/@/api/support/change-log-api': { changeLogApi: { queryPage: params => {
      requests.push(params);
      return failure ? Promise.reject(Error('network')) : new Promise(resolve => { finish = resolve; });
    } } },
    '/@/lib/sentry': support['/@/lib/sentry'],
    '../../support/change-log/change-log-modal.vue': {},
    '/@/layout/components/side-help-doc/index.vue': {},
    '/@/layout/components/side-help-doc/components/feedback-modal.vue': {},
    './heart-sentence': { default: ['原来的语录'] },
  });
  const initial = home.mounted[0]();
  await home.activated[0]();
  assert.equal(requests.length, 1);
  assert.equal(requests[0].pageSize, 5);
  assert.deepEqual(Array.from(requests[0].sortItemList, item => [item.column, item.isAsc]), [['public_date', false], ['change_log_id', false]]);
  const release = { changeLogId: 9, updateVersion: 'v0.0.1', publicDate: '2026-10-06', content: '发布内容' };
  finish({ data: { list: [release] } });
  await initial;
  assert.equal(home.setup.changeLogs.value[0].changeLogId, 9);
  let details;
  home.setup.changeLogModal.value = { show: value => { details = value; } };
  home.setup.showChangeLog(home.setup.changeLogs.value[0]);
  assert.equal(details.content, release.content);
  const refresh = home.activated[0]();
  finish({ data: { list: [] } });
  await refresh;
  assert.equal(home.setup.changeLogs.value.length, 0);
  failure = true;
  await home.setup.queryChangeLogs();
  assert.equal(home.setup.loadFailed.value, true);
  assert.equal(home.setup.loading.value, false);
  failure = false;
  const retry = home.setup.queryChangeLogs();
  finish({ data: { list: [release] } });
  await retry;
  assert.equal(home.setup.loadFailed.value, false);
  assert.equal(home.setup.changeLogs.value.length, 1);
  assert.equal(sentryErrors.length, 1);

  assert.equal(home.setup.loginRegion.value, '');
  homeUser.lastLoginIpRegion = '中国|0|湖南省|长沙市|电信';
  assert.equal(home.setup.loginRegion.value, '中国 · 湖南省 · 长沙市');
  homeUser.lastLoginIpRegion = '0|0|0';
  assert.equal(home.setup.loginRegion.value, '');
  homeUser.lastLoginIpRegion = '';
  assert.equal(home.setup.loginRegion.value, '');
  assert.equal(home.setup.heartSentence, '原来的语录');
  homeUser.lastLoginIpRegion = '未知|0|0|0|未知';
  assert.equal(home.setup.loginRegion.value, '');
  assert.match(home.descriptor.template.content, /v-if="loginRegion"/);
  assert.match(home.descriptor.template.content, /<HomeHelpDoc/);
  assert.match(home.descriptor.template.content, /feedbackModal\?\.show\(\)/);
  assert.match(home.descriptor.template.content, /v-if="loadFailed \|\| changeLogs\.length"/);

  let documentRequests = 0;
  let finishDocuments;
  let documentFailure = false;
  const documents = loadComponent('src/layout/components/side-help-doc/index.vue', {
    '/@/api/support/help-doc-api': { helpDocApi: { getAllHelpDocList: () => {
      documentRequests++;
      return documentFailure ? Promise.reject(Error('documents network')) : new Promise(resolve => { finishDocuments = resolve; });
    } } },
    '/@/lib/sentry': support['/@/lib/sentry'],
  });
  const initialDocuments = documents.mounted[0]();
  await documents.activated[0]();
  assert.equal(documentRequests, 1);
  finishDocuments({ data: [{ helpDocId: 7, title: '使用说明' }] });
  await initialDocuments;
  assert.equal(documents.setup.helpDocs.value[0].helpDocId, 7);
  const reloadDocuments = documents.activated[0]();
  finishDocuments({ data: [] });
  await reloadDocuments;
  assert.equal(documents.setup.helpDocs.value.length, 0);
  documentFailure = true;
  await documents.setup.queryHelpDocs();
  assert.equal(documents.setup.loadFailed.value, true);
  assert.equal(documents.setup.loading.value, false);
  documentFailure = false;
  const retryDocuments = documents.setup.queryHelpDocs();
  finishDocuments({ data: [{ helpDocId: 8, title: '新说明' }] });
  await retryDocuments;
  assert.equal(documents.setup.loadFailed.value, false);
  assert.equal(documents.setup.helpDocs.value[0].helpDocId, 8);
  assert.equal(sentryErrors.length, 2);
  assert.match(documents.descriptor.template.content, /helpDocId: item.helpDocId/);
  assert.doesNotMatch(documents.descriptor.template.content, /feedbackModal/);
  assert.match(documents.descriptor.template.content, /v-if="loadFailed \|\| helpDocs\.length"/);
  assert.doesNotMatch(fs.readFileSync(path.join(root, 'src/layout/side-layout.vue'), 'utf8'), /SideHelpDoc|help-doc-sider|helpDocExpandFlag/);
  assert.doesNotMatch(fs.readFileSync(path.join(root, 'src/layout/components/header-user-space/index.vue'), 'utf8'), /showHelpDoc|helpDocExpandFlag/);
  const loginFile = 'src/views/system/login3/login.vue';
  const login = parse(fs.readFileSync(path.join(root, loginFile), 'utf8')).descriptor;
  const style = compileStyle({ source: login.styles[0].content, filename: loginFile, id: 'data-v-login', scoped: true });
  assert.equal(style.errors.length, 0);
  assert.match(style.code, /input:-webkit-autofill/);
  assert.match(style.code, /input:autofill/);
  assert.match(login.template.content, /autocomplete="current-password"/);
  for (const file of [
    'src/views/system/employee/components/employee-form-modal/index.vue',
    'src/views/system/employee/components/employee-list/index.vue',
    'src/views/system/account/components/center/index.vue',
  ]) assert.doesNotMatch(fs.readFileSync(path.join(root, file), 'utf8'), /PositionSelect|positionId|positionName/);
  const closedTabs = [];
  const tabRoutes = [];
  const tabs = loadComponent('src/layout/components/page-tag/components/chrome-tab.vue', {
    'vue-router': { useRoute: () => ({ name: '26' }), useRouter: () => ({ push: route => tabRoutes.push(route) }) },
    '/@/constants/system/home-const': { HOME_PAGE_NAME: 'Home' },
    '/@/store/modules/system/app-config': { useAppConfigStore: () => ({ $state: { pageTagFlag: true } }) },
    '/@/store/modules/system/user': { useUserStore: () => ({
      getTagNav: [{ menuName: 'Home' }, { menuName: '26' }, { menuName: '35' }],
      closeTagNav: (...args) => closedTabs.push(args),
    }) },
    'ant-design-vue': { theme: { useToken: () => ({ token: {} }) } },
  });
  tabs.setup.closeByMenu(false);
  assert.deepEqual(closedTabs[0], ['26', true]);
  assert.equal(tabRoutes.length, 0);
  tabs.setup.closeByMenu(true);
  assert.deepEqual(closedTabs[1], [null, true]);
  assert.equal(tabRoutes[0].name, 'Home');
  assert.match(tabs.descriptor.template.content, /contextmenu/);
  assert.equal((tabs.descriptor.template.content.match(/<a-dropdown/g) || []).length, 1);
  assert.doesNotMatch(tabs.descriptor.template.content, /AppstoreOutlined|page-tag-operate/);
  for (const descriptor of [home.descriptor, documents.descriptor, login]) {
    assert.doesNotMatch(descriptor.styles.map(style => style.content).join('\n'), /@media[^{]*(?:min|max)-width/);
  }
  const characters = parse(fs.readFileSync(path.join(root, 'src/views/system/login3/AnimatedCharacters.vue'), 'utf8')).descriptor;
  assert.doesNotMatch(characters.styles[0].content, /@media[^{]*(?:min|max)-width/);
  assert.match(characters.styles[0].content, /prefers-reduced-motion/);
  assert.match(fs.readFileSync(path.join(root, 'src/theme/index.less'), 'utf8'), /#app\s*\{\s*min-width: 1200px/);
  process.stdout.write('Desktop layout, right-click tabs, geographic region and existing admin checks passed.\n');
}
main().catch(error => { process.stderr.write(error.stack + '\n'); process.exitCode = 1; });
