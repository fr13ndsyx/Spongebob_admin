const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
const web = path.join(root, 'admin-web-typescript');
const api = path.join(root, 'admin-api-java17-springboot3');
const skippedDirectories = new Set(['.git', 'node_modules', 'target', 'dist', 'runtime', 'memory', '.idea', '.claude']);
const textExtensions = new Set(['.java', '.xml', '.yaml', '.factories', '.vm', '.ts', '.vue', '.less', '.cjs', '.json', '.md']);
const files = [];
function collectFiles(directory) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const filename = path.join(directory, entry.name);
    if (entry.isDirectory() && !skippedDirectories.has(entry.name)) collectFiles(filename);
    if (entry.isFile()) files.push(filename);
  }
}
collectFiles(root);
const legacyIdentity = /lab\d+|\d+lab__|[s]mart[\w-]*|\bsa-(?:admin|base|parent)\b|classpath\*:sa-\*\.yaml/i;
const removedPrefix = /[dD]og/;
const licenseAttributionFile = path.join(root, 'README.md');
for (const filename of files) {
  const relativeName = path.relative(root, filename);
  assert.doesNotMatch(relativeName, legacyIdentity, filename);
  assert.doesNotMatch(relativeName, removedPrefix, filename);
  if (!textExtensions.has(path.extname(filename)) && !path.basename(filename).startsWith('.env.')) continue;
  const text = fs.readFileSync(filename, 'utf8');
  assert.doesNotMatch(text, removedPrefix, filename);
  if (filename !== licenseAttributionFile) {
    assert.doesNotMatch(text, legacyIdentity, filename);
  }
}
const packageJson = JSON.parse(fs.readFileSync(path.join(web, 'package.json'), 'utf8'));
const lockJson = JSON.parse(fs.readFileSync(path.join(web, 'package-lock.json'), 'utf8'));
assert.equal(packageJson.name, 'admin');
assert.equal(lockJson.name, packageJson.name);
assert.equal(lockJson.packages[''].name, packageJson.name);
assert.deepEqual(lockJson.packages[''].dependencies, packageJson.dependencies);
assert.deepEqual(lockJson.packages[''].devDependencies, packageJson.devDependencies);
const javaFiles = files.filter(filename => filename.endsWith('.java'));
const classes = new Map();
for (const filename of javaFiles) {
  const text = fs.readFileSync(filename, 'utf8');
  const packageName = text.match(/^package\s+([\w.]+);/m)?.[1];
  assert.ok(packageName?.startsWith('net.admin.'), filename);
  const sourceRoot = filename.match(/^(.*[\\/]src[\\/](?:main|test)[\\/]java)[\\/]/)?.[1];
  assert.ok(sourceRoot, filename);
  const expectedPath = packageName.split('.').join(path.sep) + path.sep + path.basename(filename);
  assert.equal(path.relative(sourceRoot, filename), expectedPath);
  classes.set(packageName + '.' + path.basename(filename, '.java'), filename);
}
for (const filename of javaFiles) {
  const text = fs.readFileSync(filename, 'utf8');
  for (const match of text.matchAll(/^import\s+(?:static\s+)?(net\.admin\.[\w.*]+);/gm)) {
    const importedName = match[1];
    if (importedName.endsWith('.*')) {
      const prefix = importedName.slice(0, -1);
      assert.ok([...classes.keys()].some(name => name.startsWith(prefix) || prefix.startsWith(name + '.')), importedName);
    } else {
      assert.ok([...classes.keys()].some(name => importedName === name || importedName.startsWith(name + '.')), importedName);
    }
  }
}
const parentPom = fs.readFileSync(path.join(api, 'pom.xml'), 'utf8');
assert.match(parentPom, /<groupId>net\.admin<\/groupId>/);
assert.match(parentPom, /<artifactId>admin-parent<\/artifactId>/);
for (const moduleName of ['admin', 'base']) {
  assert.ok(parentPom.includes('<module>' + moduleName + '</module>'));
  const modulePom = fs.readFileSync(path.join(api, moduleName, 'pom.xml'), 'utf8');
  assert.ok(modulePom.includes('<artifactId>' + moduleName + '</artifactId>'));
  assert.match(modulePom, /<artifactId>admin-parent<\/artifactId>/);
}
assert.match(fs.readFileSync(path.join(api, 'admin/pom.xml'), 'utf8'), /<mainClass>net\.admin\.admin\.AdminApplication<\/mainClass>/);
const yamlProcessor = fs.readFileSync(path.join(api, 'base/src/main/java/net/admin/base/config/YamlProcessor.java'), 'utf8');
assert.ok(yamlProcessor.includes('classpath*:base.yaml'));
const factories = fs.readFileSync(path.join(api, 'base/src/main/resources/META-INF/spring.factories'), 'utf8');
assert.ok(factories.includes('net.admin.base.config.YamlProcessor'));
for (const environment of ['dev', 'test', 'pre', 'prod']) {
  const baseConfig = fs.readFileSync(path.join(api, 'base/src/main/resources', environment, 'base.yaml'), 'utf8');
  const applicationConfig = fs.readFileSync(path.join(api, 'admin/src/main/resources', environment, 'application.yaml'), 'utf8');
  assert.ok(baseConfig.includes('${POSTGRES_DATABASE:admin}'));
  assert.ok(baseConfig.includes('sm2-private-key: ${API_ENCRYPT_PRIVATE_KEY}'), environment + ' SM2 private key must come from environment');
  assert.match(applicationConfig, /name: admin/);
}
for (const filename of files.filter(filename => filename.endsWith('.xml'))) {
  const text = fs.readFileSync(filename, 'utf8');
  for (const match of text.matchAll(/(?:namespace|type|resultType|parameterType|class)="(net\.admin\.[\w.]+)"/g)) {
    assert.ok(classes.has(match[1]), match[1]);
  }
}
assert.ok(fs.existsSync(path.join(web, 'src/theme/admin.less')));
assert.ok(fs.readFileSync(path.join(web, 'src/theme/index.less'), 'utf8').includes("'./admin.less'"));
assert.ok(fs.readFileSync(path.join(web, 'src/config/app-config.ts'), 'utf8').includes("websiteName: 'admin'"));
assert.equal(fs.readFileSync(path.join(root, 'sql/postgresql.sql'), 'utf8').match(/^CREATE TABLE /gm).length, 22);
assert.ok(fs.statSync(path.join(api, 'base/src/main/resources/ip2region.xdb')).size > 0);
process.stdout.write('admin identity, Java packages, mapper references and configuration checks passed.\n');
const vm = require('node:vm');
const ts = require('typescript');
const { sm2 } = require('sm-crypto');
const SM2_CIPHER_MODE_C1C3C2 = 1;
const PUBLIC_KEY_URL = '/login/getEncryptPublicKey';
const apiEncryptDirectory = path.join(api, 'base/src/main/java/net/admin/base/module/support/apiencrypt/service');
const encryptSource = fs.readFileSync(path.join(web, 'src/lib/encrypt.ts'), 'utf8');
assert.deepEqual(fs.readdirSync(apiEncryptDirectory).sort(), ['ApiEncryptService.java', 'ApiEncryptServiceSmImpl.java']);
for (const source of [encryptSource, fs.readFileSync(path.join(apiEncryptDirectory, 'ApiEncryptServiceSmImpl.java'), 'utf8')]) {
  assert.doesNotMatch(source, /adminadmin|_KEY = ['"]/, 'encryption keys must not be hardcoded');
}
const keyPair = sm2.generateKeyPairHex();
const requestedUrls = [];
const axiosStub = {
  getRequest: async (url) => {
    requestedUrls.push(url);
    return { data: keyPair.publicKey };
  },
  request: async (config) => config,
};
const encryptModule = { exports: {} };
const encryptCode = ts.transpileModule(encryptSource, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022, esModuleInterop: true },
}).outputText;
vm.runInNewContext(encryptCode, {
  module: encryptModule,
  exports: encryptModule.exports,
  require: (name) => (name === '/@/lib/axios' ? axiosStub : require(name)),
});
const { encryptData, postEncryptRequest } = encryptModule.exports;
const decryptFrontendCipher = (cipher) => {
  assert.ok(cipher.startsWith('04'), 'SM2 ciphertext must carry the uncompressed point prefix');
  return sm2.doDecrypt(cipher.slice(2), keyPair.privateKey, SM2_CIPHER_MODE_C1C3C2);
};
(async () => {
  for (const value of ['admin login', '中文密码验证', { loginName: 'admin', data: '地区与权限' }]) {
    const plain = typeof value === 'object' ? JSON.stringify(value) : value;
    assert.equal(decryptFrontendCipher(await encryptData(value)), plain);
  }
  assert.equal(await encryptData(''), null);
  const posted = await postEncryptRequest('/employee/update/password', { oldPassword: '旧密码', newPassword: 'new' });
  assert.equal(decryptFrontendCipher(posted.data.encryptData), JSON.stringify({ oldPassword: '旧密码', newPassword: 'new' }));
  assert.ok(requestedUrls.length > 0 && requestedUrls.every((url) => url === PUBLIC_KEY_URL));
  process.stdout.write('SM2 public key encryption, Unicode round trips and no hardcoded key checks passed.\n');
})();
