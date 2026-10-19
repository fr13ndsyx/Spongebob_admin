const assert = require('node:assert/strict');
const fs = require('node:fs');
const http = require('node:http');
const path = require('node:path');
const vm = require('node:vm');
const { test } = require('node:test');
const ts = require('typescript');
const axios = require('axios');

const root = path.resolve(__dirname, '..');
const apiUrl = 'http://127.0.0.1:1024';

function loadModule(filename, imports, env = {}) {
  const source = fs.readFileSync(path.join(root, filename), 'utf8').replaceAll('import.meta', 'importMeta');
  const code = ts.transpileModule(source, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true },
  }).outputText;
  const module = { exports: {} };
  vm.runInNewContext(code, {
    module,
    exports: module.exports,
    importMeta: { env, glob: () => ({}) },
    Blob,
    require: name => Object.hasOwn(imports, name) ? imports[name] : require(name),
  }, { filename });
  return module.exports;
}

function loadHttpClient(isDev) {
  return loadModule('src/lib/axios.ts', {
    'ant-design-vue': { message: { destroy() {}, error() {} }, Modal: { error() {} } },
    '/@/utils/local-util': { localRead: () => 'test-token' },
    '/@/store/modules/system/user': { useUserStore: () => ({ logout() {} }) },
    '/@/constants/local-storage-key-const': { default: { USER_TOKEN: 'token' }, __esModule: true },
  }, { DEV: isDev, VITE_APP_API_URL: apiUrl });
}

test('开发请求使用同源代理，构建后的请求使用配置的后端地址', async () => {
  for (const [isDev, expectedUrl] of [[true, '/api/login/getEncryptPublicKey'], [false, apiUrl + '/login/getEncryptPublicKey']]) {
    const client = loadHttpClient(isDev);
    const result = await client.request({
      url: '/login/getEncryptPublicKey',
      adapter: async config => ({
        data: { code: 0, ok: true, msg: '操作成功', data: { url: axios.getUri(config), token: config.headers.Authorization } },
        headers: { 'content-type': 'application/json' },
        status: 200,
        statusText: 'OK',
        config,
      }),
    });
    assert.equal(result.data.url, expectedUrl);
    assert.equal(result.data.token, 'Bearer test-token');
  }
});

test('只有数字成功码零通过，错误和不完整响应必须拒绝', async () => {
  const client = loadHttpClient(true);
  for (const data of [{ code: 0 }, { code: 1 }, { code: 40001 }, {}, { code: null }, { code: false }, { code: '' }, { code: '0' }]) {
    const response = { data, headers: { 'content-type': 'application/json' }, status: 200, statusText: 'OK' };
    const pending = client.request({ url: '/example', adapter: async () => response });
    if (data.code === 0) {
      assert.equal(await pending, data);
    } else {
      await assert.rejects(pending, error => error === response);
    }
  }
  const binary = { data: new Blob(['file']), headers: { 'content-type': 'application/octet-stream' }, status: 200, statusText: 'OK' };
  assert.equal(await client.request({ url: '/download', adapter: async () => binary }), binary);
});

test('首页需要登录并提前放行，普通页面继续执行标签页处理', async () => {
  let guard;
  let token = 'test-token';
  let tagUpdates = 0;
  let logouts = 0;
  const user = { setTagNav: () => tagUpdates++, logout: () => logouts++ };
  loadModule('src/router/index.ts', {
    'nprogress': { start() {}, done() {} },
    'nprogress/nprogress.css': {},
    'vue-router': { createWebHashHistory: () => ({}), createRouter: () => ({ beforeEach: value => { guard = value; }, afterEach() {} }) },
    './routers': { routerArray: [] },
    '/@/constants/common-const': { PAGE_PATH_404: '/404', PAGE_PATH_LOGIN: '/login', HOME_PAGE_PATH: '/home' },
    '/@/constants/system/home-const': { HOME_PAGE_NAME: 'Home' },
    '../layout/index.vue': {},
    '/@/store/modules/system/user': { useUserStore: () => user },
    '/@/utils/local-util': { localRead: () => token },
    '/@/constants/local-storage-key-const': { default: { USER_TOKEN: 'token' }, __esModule: true },
  });
  const destinations = [];
  const next = destination => destinations.push(destination);
  await guard({ path: '/home', name: 'Home', meta: {} }, {}, next);
  assert.equal(destinations.length, 1);
  assert.equal(destinations[0], undefined);
  assert.equal(tagUpdates, 0);
  await guard({ path: '/employee', name: 'Employee', meta: {} }, {}, next);
  assert.equal(tagUpdates, 1);
  token = undefined;
  await guard({ path: '/home', name: 'Home', meta: {} }, {}, next);
  assert.equal(destinations[2].path, '/login');
  assert.equal(logouts, 1);
});

test('Vite 将 API 转发到后端并保留页面与静态资源', async () => {
  const { createServer } = await import('vite');
  const backend = http.createServer(async (request, response) => {
    let body = '';
    for await (const chunk of request) body += chunk;
    response.setHeader('content-type', 'application/json');
    response.end(JSON.stringify({ path: request.url, host: request.headers.host, token: request.headers.authorization, body }));
  });
  await new Promise(resolve => backend.listen(0, '127.0.0.1', resolve));
  const previousApiUrl = process.env.VITE_APP_API_URL;
  process.env.VITE_APP_API_URL = `http://127.0.0.1:${backend.address().port}`;
  let server;
  try {
    server = await createServer({
      root,
      mode: 'localhost',
      server: { host: '127.0.0.1', port: 0, preTransformRequests: false },
      optimizeDeps: { noDiscovery: true, include: [] },
    });
    await server.listen();
    const origin = `http://127.0.0.1:${server.httpServer.address().port}`;
    const response = await fetch(origin + '/api/login/test?keyword=a%20b', {
      method: 'POST',
      headers: { Authorization: 'Bearer proxy-test', 'Content-Type': 'application/json' },
      body: '{"value":1}',
    });
    assert.equal(response.status, 200);
    assert.deepEqual(await response.json(), {
      path: '/login/test?keyword=a%20b',
      host: `127.0.0.1:${backend.address().port}`,
      token: 'Bearer proxy-test',
      body: '{"value":1}',
    });
    const page = await fetch(origin + '/');
    assert.equal(page.status, 200);
    assert.match(await page.text(), /<div id="app">/);
    const asset = await fetch(origin + '/src/main.ts');
    assert.equal(asset.status, 200);
    assert.match(asset.headers.get('content-type'), /javascript/);
  } finally {
    await server?.close();
    await new Promise(resolve => backend.close(resolve));
    if (previousApiUrl === undefined) delete process.env.VITE_APP_API_URL;
    else process.env.VITE_APP_API_URL = previousApiUrl;
  }
});
