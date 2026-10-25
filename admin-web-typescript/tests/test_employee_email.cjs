const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const ts = require('typescript');
const { parse } = require('@vue/compiler-sfc');
const Schema = require('async-validator').default;
const root = path.resolve(__dirname, '..');

async function checkEmailRules() {
  for (const filename of [
    'src/views/system/employee/components/employee-form-modal/index.vue',
    'src/views/system/account/components/center/index.vue',
  ]) {
    const source = parse(fs.readFileSync(path.join(root, filename), 'utf8')).descriptor.scriptSetup.content;
    const ast = ts.createSourceFile(filename + '.ts', source, ts.ScriptTarget.Latest, true);
    const declaration = ast.statements
      .filter(ts.isVariableStatement)
      .flatMap((statement) => [...statement.declarationList.declarations])
      .find((item) => item.name.getText(ast) === 'rules');
    const email = declaration.initializer.properties.find((item) => item.name.getText(ast) === 'email');
    const rules = vm.runInNewContext('(' + email.initializer.getText(ast) + ')');
    const validator = new Schema({ email: rules });
    for (const value of [undefined, null, '', 'employee@example.com']) {
      await assert.doesNotReject(() => validator.validate({ email: value }), filename + ': ' + value);
    }
    for (const value of ['invalid', 'employee@', '@example.com', 'employee@example']) {
      await assert.rejects(() => validator.validate({ email: value }), filename + ': ' + value);
    }
  }
}

checkEmailRules().then(() => {
  process.stdout.write('Optional employee email validation checks passed.\n');
}).catch((error) => {
  process.stderr.write(error.stack + '\n');
  process.exitCode = 1;
});
