# 海绵宝宝管理后台

基于 Vue 3 与 Spring Boot 3 的前后端分离管理后台，保留账号、组织、角色权限和必要支撑功能，适合在此基础上开发自己的业务系统。


## 1. 当前功能

| 模块 | 功能 |
| --- | --- |
| 登录与安全 | 登录、验证码、登录失败锁定、密码复杂度和定期改密配置 |
| 首页 | 欢迎信息、日期、有效登录地区、语录、意见反馈、帮助文档和更新日志 |
| 组织管理 | 员工、部门、一级部门和下级部门 |
| 权限管理 | 角色、角色员工关联、菜单，以及按钮和后端接口权限 |
| 个人中心 | 个人资料、修改密码、头像 |
| 文档中心 | 帮助文档目录与内容管理、文档查阅、意见反馈、更新日志、Swagger |
| 基础支撑 | 文件上传、字典底层、表格列配置、邮件模板、业务缓存管理 |
| 安全审计 | 登录与退出日志、操作日志、三级等保设置 |

标签页支持右键关闭其他或关闭所有。登录地区没有有效地理信息时不显示。

初始化不带业务示例、历史文档和测试人员。字典、文件和配置等保留底层能力，不代表都有独立管理页面。

## 2. 技术栈与环境

| 部分 | 技术或要求 |
| --- | --- |
| 前端 | Vue 3.5.43、TypeScript 5.6.3、Vite 5.2.12、Ant Design Vue 4.2.5、Pinia |
| 前端工具 | Node.js >= 18，建议使用仍受维护的 LTS 版本；npm |
| 后端 | Java 17、Spring Boot 3.5.4、MyBatis-Plus 3.5.12、Sa-Token 1.44.0 |
| 后端工具 | JDK 17 或兼容版本，建议 Maven 3.9.x；可使用 IntelliJ IDEA |
| 数据库 | PostgreSQL 18，需包含 ICU 排序规则支持 |
| 缓存和会话 | Redis；建议使用独立实例或独立逻辑数据库 |

首次安装需要访问 npm 和 Maven 仓库。前端按 `package-lock.json` 安装依赖，后端按父工程 `pom.xml` 管理依赖。

## 3. 源码与压缩包

本文描述改名后的当前源码。名称调整没有重新生成之前的压缩包；转交最新版本时，应从当前源码重新打包。

当前源码目录与压缩包目录对应如下：

| 内容 | 原源码目录 | 解压后目录 |
| --- | --- | --- |
| 前端 | `admin-web-typescript/` | `web/` |
| 后端父工程 | `admin-api-java17-springboot3/` | `api/` |
| 初始化 SQL | `sql/postgresql.sql` | `sql/postgresql.sql`（与 `api/` 同级） |

解压两个包后，主要结构为：

```text
web/
├── public/
├── src/
├── tests/
├── .env.localhost
├── package.json
├── package-lock.json
└── vite.config.ts

api/
├── admin/
│   ├── src/main/java/
│   ├── src/main/resources/
│   └── pom.xml
├── base/
│   ├── src/main/java/
│   ├── src/main/resources/
│   └── pom.xml
└── pom.xml

sql/
└── postgresql.sql
```

`admin` 是启动模块，`base` 是它依赖的公共模块。打开后端时导入父工程 `api/pom.xml`。

两个压缩包是源码包，不包含 `node_modules/`、`dist/`、`target/`、运行日志、上传运行数据、IDE 配置和本机私有连接信息。本 README 单独提供，不放入压缩包。

## 4. 初始化数据库

1. 启动 PostgreSQL 18，使用数据库管理工具新建 UTF-8 编码的空数据库，建议名称为 `admin`。
2. 选中这个新库，执行 `sql/postgresql.sql`；压缩包路径为 `sql/postgresql.sql`（与 `api/` 同级）。
3. 核对导入结果，再配置后端连接这个数据库。应用启动不会自动执行该脚本。转交项目时需同时携带根目录的 `sql/postgresql.sql`；Maven 仅将它作为测试资源加载。

创建数据库也可以使用：

```sql
CREATE DATABASE admin ENCODING 'UTF8';
ALTER DATABASE admin SET timezone TO 'Asia/Shanghai';
```

脚本在当前选中的数据库执行，使用事务创建全部表和初始数据，不删除已有库表。它用于全新安装，不是旧库升级脚本；执行失败应回滚事务，不要在已有数据的库上重复导入。`sql/admin.sql` 只保留为原 MySQL 脚本，当前后端使用 PostgreSQL。

初始化结果：

- 22 张表。
- 1 个管理员账号、1 个默认部门、1 个管理员角色及员工角色关联。
- 52 项菜单和功能点，以及对应的 52 条管理员菜单授权。
- 1 项必要安全配置、1 份登录验证码邮件模板。
- 其余 14 张表为空，登录和操作后会正常产生新的日志。

登录账号为 `admin`，初始密码为 `123456`。管理员 UID 与密码摘要是配对数据，不能只修改其中一个字段来重置密码。

状态字段使用 PostgreSQL `boolean`，自增主键使用 `IDENTITY` 并在初始化后校准序列。原有自动更新时间通过触发器保留；时间列沿用与 Java `LocalDateTime` 对应的 `timestamp(0)`。字符串使用 ICU `admin_ci` 排序规则，保留大小写、重音不敏感比较；搜索使用 PostgreSQL 18 对该排序规则的 `LIKE` 支持，并将 `%`、`_` 和反斜杠按普通搜索字符处理。

## 5. 配置并启动后端

### 5.1 环境配置

压缩包中的 `dev`、`test`、`pre`、`prod` 配置使用环境变量提供连接信息。默认 Maven profile 为 `dev`。

主要配置文件：

- `api/admin/src/main/resources/dev/application.yaml`：应用端口、环境、日志目录。
- `api/base/src/main/resources/dev/base.yaml`：数据库、Redis、邮件、文件存储和安全支撑配置。

四套后端配置均通过环境变量连接 PostgreSQL 和 Redis，不在源码中填写本机密码。

| 环境变量 | 默认值 | 用途 |
| --- | --- | --- |
| `POSTGRES_HOST` | `127.0.0.1` | PostgreSQL 地址 |
| `POSTGRES_PORT` | `5432` | PostgreSQL 端口 |
| `POSTGRES_DATABASE` | `admin` | 导入 SQL 的数据库名称 |
| `POSTGRES_USER` | `postgres` | PostgreSQL 账号 |
| `POSTGRES_PASSWORD` | 无，必须设置 | PostgreSQL 密码，与 admin 登录密码是两回事 |
| `REDIS_HOST` | `127.0.0.1` | Redis 地址 |
| `REDIS_PORT` | `6379` | Redis 端口 |
| `REDIS_DATABASE` | `2` | Redis 逻辑数据库，与旧 MySQL 版本使用的 1 隔离 |
| `REDIS_PASSWORD` | 空 | Redis 有密码时设置 |
| `API_ENCRYPT_PRIVATE_KEY` | 无，必须设置 | 登录与改密传输加密用的 SM2 私钥，64 位十六进制；只放后端，不要提交进 git |

`API_ENCRYPT_PRIVATE_KEY` 的生成方式：双击 `api/tools/generate-sm2-private-key.bat`（原源码为 `admin-api-java17-springboot3/tools/`），把窗口中输出的私钥填入该环境变量。每个环境各生成一把，不要共用；前端不需要任何配置，登录时会向后端获取对应的公钥。更换私钥后重启后端即可，已打开的登录页刷新一次。

在 IDEA 的 `AdminApplication` 运行配置中设置这些环境变量，并让该进程能连接 PostgreSQL 和 Redis。使用终端启动时，环境变量必须在该终端进程中生效。

### 5.2 IDEA 启动

1. 打开 `api/pom.xml`，作为 Maven 父工程导入。
2. 将项目与 Maven 使用的 JDK 设置为 17 或兼容版本。
3. 重新加载 Maven 工程，等待依赖下载完成；默认选择 `dev` profile。
4. 设置运行环境变量，工作目录建议选择 `api/`。
5. 运行启动类 `net.admin.admin.AdminApplication`。

启动类文件位于 `api/admin/src/main/java/net/admin/admin/AdminApplication.java`。Maven 会按选择的 profile 处理 YAML 资源；切换 profile 后重新处理资源，不能仅修改 Spring 的运行参数代替 Maven profile 切换。

后端默认地址为 `http://127.0.0.1:1024`，Swagger 地址为 `http://127.0.0.1:1024/swagger-ui/index.html`。

### 5.3 命令行启动（可选）

在 `api/` 目录中执行以下命令，环境变量仍需提前设置：

```shell
mvn -Pdev -DskipTests clean package
java -jar admin/target/admin-dev-3.0.0.jar
```

这组命令会下载依赖并编译后端。开发阶段优先使用 IDE；本 README 的编写没有执行这些命令。

### 5.4 按需配置

- 邮件验证码：设置 `MAIL_HOST`、`MAIL_PORT`、`MAIL_USERNAME`、`MAIL_PASSWORD`，并验证邮件投递后再开启双因子登录。初始化配置关闭邮件双因子，首次登录不需要 SMTP。
- 文件存储：默认使用本地存储，上传目录由 `UPLOAD_DIRECTORY` 控制，默认 `./runtime/upload/`；文件访问前缀通过 `FILE_URL_PREFIX` 配置。
- 日志：通过 `LOG_DIRECTORY` 配置日志根目录，默认 `./runtime/logs`。
- 云存储：切换存储模式后配置 `CLOUD_REGION`、`CLOUD_ENDPOINT`、`CLOUD_BUCKET`、`CLOUD_ACCESS_KEY`、`CLOUD_SECRET_KEY` 等变量。

## 6. 安装并启动前端

在 `web/` 目录打开终端：

```shell
npm ci
npm run localhost
```

默认访问地址为 `http://127.0.0.1:8081`。端口被占用时，以 Vite 终端输出的实际地址为准。

本地接口地址在 `web/.env.localhost` 中配置：

```dotenv
NODE_ENV=development
VITE_APP_TITLE='admin'
VITE_APP_API_URL='http://127.0.0.1:1024'
```

后端地址或端口变化时同步修改 `VITE_APP_API_URL`，然后重启 Vite。开发环境的接口请求走同源 `/api`，由 Vite 转发到该地址并移除 `/api` 前缀；构建后的接口请求仍使用该变量配置的地址。此变量不能放入服务密码或密钥。

已有的前端脚本：

| 命令 | 作用 |
| --- | --- |
| `npm run localhost` | 使用 `.env.localhost` 启动开发服务 |
| `npm run dev` | 使用 development 模式启动开发服务 |
| `npm run build:test` | 测试构建，资源基础路径为 `/admin/` |
| `npm run build:pre` | 预发布构建 |
| `npm run build:prod` | 生产构建 |

构建输出在 `dist/`；需要构建时先确认对应环境的接口地址。

## 7. 首次运行检查

1. 确认 PostgreSQL、Redis 和后端已启动，再启动前端。
2. 使用 `admin` 和交付方提供的密码登录。
3. 首页应显示语录和意见反馈入口；有内容时显示帮助文档和更新日志卡片。
4. 员工、部门和角色列表应各有一条基础数据；菜单管理应有 52 项菜单和功能点。
5. 标签页右键应能关闭其他或关闭所有。
6. 再次登录和进行管理操作后，可到登录日志、操作日志页面检查新记录。
7. 新增业务和普通角色后，分别核对页面、按钮与后端接口权限；前端按钮隐藏不能代替后端鉴权。

## 8. 常见问题

| 现象 | 检查方向 |
| --- | --- |
| 启动提示无法解析 `POSTGRES_PASSWORD` | 在 IDEA 的运行 → 编辑配置 → AdminApplication → 环境变量中设置；从 Windows 用户环境变量读取时需完全重启 IDEA |
| `ClassNotFoundException: org.postgresql.Driver` | 在 IDEA 的 Maven 面板重新加载全部 Maven 项目；确认后端父 `pom.xml` 已作为 Maven 工程导入、运行配置使用 `admin` 模块，外部库中存在 `org.postgresql:postgresql` 后再启动 |
| 启动提示无法解析 `API_ENCRYPT_PRIVATE_KEY` 或「不是有效的 SM2 私钥」 | 按 5.1 节用生成工具重新生成私钥，并确认运行进程设置了该环境变量 |
| 数据库连接失败或找不到表 | 检查 PostgreSQL 连接参数、数据库名及 SQL 是否导入到同一个库 |
| Redis 连接失败 | 检查地址、端口、密码和逻辑数据库配置 |
| 前端打不开或接口请求失败 | 查看 Vite 实际端口，核对 `.env.localhost` 中的接口地址和后端是否启动 |
| 登录提示密码错误 | 全新初始化库使用本节说明的初始账号密码；修改密码后使用新密码 |
| 新库出现旧部门或旧会话 | 检查是否复用了其他项目的 Redis 数据库，改用独立实例或数据库 |
| 首页文档、更新日志为空 | 初始化不带历史内容，可到文档中心创建 |

## 9. 验证范围

PostgreSQL 迁移检查位于 `admin-api-java17-springboot3/admin/src/test/java/net/admin/admin/PostgresDatabaseTest.java`，在真实 PostgreSQL 的独立临时 schema 中验证初始化、基础数据、自增主键、大小写与特殊字符搜索、分页、状态字段、日期筛选、菜单更新和自动更新时间，结束后回滚；不会修改已有业务表。

在后端父工程目录设置 `POSTGRES_TEST_URL=jdbc:postgresql://127.0.0.1:5432/postgres`、`POSTGRES_USER` 和 `POSTGRES_PASSWORD` 后执行 `mvn -Pdev test`，即可连库运行该检查；未设置测试 URL 时只跳过这项连库检查。测试账号需有创建 schema 的权限。后端重新编译并重启由使用者执行，按第 7 节继续核对页面与接口；邮件投递、云存储和公网部署需按实际配置验证。

现有源码仍有尚未整理的严格 TypeScript 类型检查问题。`build:*` 使用 Vite 构建，不等于全仓类型检查已经通过。

## IP 地区数据

后端公共模块的 `base/src/main/resources/ip2region.xdb` 是离线 IP 地区查询数据，由启动监听器加载到内存，供登录和操作日志记录地区使用。它不是数据库初始化脚本，项目改名不修改该文件。

当前源码采用 `net.admin` 包名前缀，Maven 模块为 `admin` 和 `base`；公共配置文件为 `base.yaml`，默认数据库名为 `admin`。使用其他 PostgreSQL 数据库名时，通过 `POSTGRES_DATABASE` 指定。切换新库时使用独立 Redis 逻辑数据库；本配置默认使用 2，旧版本的 1 不会被清理，浏览器需要重新登录。

可运行的源码检查位于 `admin-web-typescript/tests/`，安装前端依赖后在前端目录执行 `node tests/test_project_identity.cjs`（其余检查脚本同理），覆盖 Java 包路径、Mapper 引用、配置加载、品牌与旧缓存、首页、头像、登录动画和传输加密。

## 代码命名与传输加密

项目自定义的工具类、组件、文件名、导出符号和 CSS 类名不带项目前缀，例如 `BeanUtil.java`、`sentry.ts`、`loading/`、`.margin-left10`。与第三方同名时改用描述性名称，例如实现 springdoc `OperationCustomizer` 接口的类叫 `SwaggerOperationCustomizer`；同一文件需要同名第三方类时写全路径。浏览器本地缓存键名前缀为 `admin_`，从旧版升级后需要重新登录一次。

登录密码和修改密码请求使用国密 SM2 非对称加密：私钥只存在后端环境变量 `API_ENCRYPT_PRIVATE_KEY`，后端由私钥推算公钥，前端通过 `GET /login/getEncryptPublicKey` 获取公钥后加密，代码中不再写死任何密钥。原 AES 与 SM4 对称加密实现已移除；响应加密注解 `@ApiEncrypt` 在 SM2 下前端无法解密，目前没有接口使用。数据库中的管理员密码摘要和初始化SQL没有修改。前后端必须使用同一版代码，旧后端配合新前端会导致登录失败。

传输加密不能代替 HTTPS，线上部署仍需启用 HTTPS。

## 版权与许可

本项目（admin 管理后台底座）基于 **SmartAdmin** 二次开发。

| 项 | 说明 |
| --- | --- |
| 原项目 | SmartAdmin |
| 原项目仓库 | https://github.com/1024-lab/smart-admin |
| 原项目官网 | https://smartadmin.vip |
| 版权归属 | 1024 创新实验室（中国·洛阳） |
| 开源协议 | MIT License |
| 原版权声明 | `Copyright (c) 2020 1024-lab` |

SmartAdmin 采用 MIT License 发布，允许免费任意商用。本项目沿用同一协议，完整许可文本见仓库根目录的 `LICENSE` 文件。按照 MIT License 的要求，原项目的版权声明与许可声明已完整保留，未作删改。

本项目对代码的名称调整、结构调整和功能裁剪均属二次开发，不影响原作者对原作品的版权归属。名称调整只涉及本项目自身的标识（包名、Maven 模块名、组件与工具类前缀等），不改变第三方依赖的名称，也不代表原项目立场，不构成原作者对本项目的认可或背书。

`LICENSE` 文件中的版权声明指向原作品作者。若需在对外发布时同时声明二次开发部分的版权，应在 `LICENSE` 中原版权行下方另起一行追加，不要替换或删除原有版权行。


## 业务缓存管理

“系统设置 → 缓存管理”支持按项清理和清理全部已登记业务缓存，当前包含字典数据与部门列表、树、下级 ID、路径。后端只接受明确登记的缓存名称，保留登录会话、用户身份与权限缓存、验证码、安全限制及其他 Redis 数据；不会清除浏览器的登录令牌。清理后请刷新相关页面。

PostgreSQL 新库初始化已包含缓存管理菜单和管理员授权，其他角色在角色管理中按需授权。不要为增加菜单重新导入初始化脚本。更新代码后重新编译、重启后端，再刷新前端；普通账号新增授权后需要重新登录以更新现有权限缓存。

新模块复用 Spring Cache，并在 `admin-api-java17-springboot3/admin/src/main/java/net/admin/admin/module/system/cache/CacheService.java` 的 `CLEARABLE_CACHES` 中登记缓存常量和显示名称，即可纳入管理。只有可从原始数据重新生成的业务缓存才能登记，禁止登记会话、权限和安全状态。未登记的缓存默认不能清理。
