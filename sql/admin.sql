SET NAMES utf8mb4;

CREATE TABLE `t_change_log`  (
  `change_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '更新日志id',
  `update_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '版本',
  `type` int NOT NULL COMMENT '更新类型:[1:特大版本功能更新;2:功能更新;3:bug修复]',
  `publish_author` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '发布人',
  `public_date` date NOT NULL COMMENT '发布日期',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '更新内容',
  `link` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '跳转链接',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`change_log_id`) USING BTREE,
  UNIQUE INDEX `version_unique`(`update_version`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统更新日志' ROW_FORMAT = Dynamic;

CREATE TABLE `t_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `config_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '参数名字',
  `config_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '参数key',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '上次修改时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '系统配置' ROW_FORMAT = Dynamic;

CREATE TABLE `t_department`  (
  `department_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门主键id',
  `department_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '部门名称',
  `manager_id` bigint NULL DEFAULT NULL COMMENT '部门负责人id',
  `parent_id` bigint NOT NULL DEFAULT 0 COMMENT '部门的父级id',
  `sort` int NOT NULL COMMENT '部门排序',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`department_id`) USING BTREE,
  INDEX `parent_id`(`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门' ROW_FORMAT = Dynamic;

CREATE TABLE `t_dict` (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典id',
  `dict_name` varchar(500) NOT NULL COMMENT '字典名字',
  `dict_code` varchar(500) NOT NULL COMMENT '字典编码',
  `remark` varchar(1000) DEFAULT NULL COMMENT '字典备注',
  `disabled_flag` tinyint NOT NULL DEFAULT '0' COMMENT '禁用状态',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`dict_id`),
  UNIQUE KEY `unique_code` (`dict_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='字典表';

CREATE TABLE `t_dict_data` (
  `dict_data_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典数据id',
  `dict_id` bigint NOT NULL COMMENT '字典id',
  `data_value` varchar(500) NOT NULL COMMENT '字典项值',
  `data_label` varchar(500) NOT NULL COMMENT '字典项显示名称',
  `data_style` varchar(500) NULL COMMENT '字典项样式',
  `remark` varchar(1000) DEFAULT NULL COMMENT '备注',
  `sort_order` int NOT NULL COMMENT '排序（越大越靠前）',
  `disabled_flag` tinyint NOT NULL DEFAULT '0' COMMENT '禁用状态',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`dict_data_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='字典数据表';

CREATE TABLE `t_employee`  (
  `employee_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `employee_uid` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '员工uuid',
  `login_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录帐号',
  `login_pwd` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录密码',
  `actual_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '员工名称',
  `avatar` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `gender` tinyint(1) NOT NULL DEFAULT 0 COMMENT '性别',
  `phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号码',
  `department_id` bigint NOT NULL COMMENT '部门id',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `disabled_flag` tinyint unsigned NOT NULL COMMENT '是否被禁用 0否1是',
  `deleted_flag` tinyint unsigned NOT NULL COMMENT '是否删除0否 1是',
  `administrator_flag` tinyint NOT NULL DEFAULT 0 COMMENT '是否为超级管理员: 0 不是，1是',
  `remark` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`employee_id`) USING BTREE,
  UNIQUE INDEX `employee_uid_index`(`employee_uid`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '员工表' ROW_FORMAT = Dynamic;

CREATE TABLE `t_feedback`  (
  `feedback_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `feedback_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '反馈内容',
  `feedback_attachment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '反馈图片',
  `user_id` bigint NOT NULL COMMENT '创建人id',
  `user_type` int NOT NULL COMMENT '创建人用户类型',
  `user_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '创建人姓名',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`feedback_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '意见反馈' ROW_FORMAT = Dynamic;

CREATE TABLE `t_file`  (
  `file_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `folder_type` tinyint unsigned NOT NULL COMMENT '文件夹类型',
  `file_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '文件名称',
  `file_size` int NULL DEFAULT NULL COMMENT '文件大小',
  `file_key` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '文件key，用于文件下载',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '文件类型',
  `creator_id` bigint NULL DEFAULT NULL COMMENT '创建人，即上传人',
  `creator_user_type` int NULL DEFAULT NULL COMMENT '创建人用户类型',
  `creator_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '创建人姓名',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上次更新时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`file_id`) USING BTREE,
  UNIQUE INDEX `uk_file_key`(`file_key`) USING BTREE,
  INDEX `module_id_module_type`(`folder_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '文件' ROW_FORMAT = Dynamic;

CREATE TABLE `t_help_doc`  (
  `help_doc_id` bigint NOT NULL AUTO_INCREMENT,
  `help_doc_catalog_id` bigint NOT NULL COMMENT '类型1公告 2动态',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标题',
  `content_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '文本内容',
  `content_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'html内容',
  `attachment` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '附件',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序',
  `page_view_count` int NOT NULL DEFAULT 0 COMMENT '页面浏览量，传说中的pv',
  `user_view_count` int NOT NULL DEFAULT 0 COMMENT '用户浏览量，传说中的uv',
  `author` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '作者',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`help_doc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '帮助文档' ROW_FORMAT = Dynamic;

CREATE TABLE `t_help_doc_catalog`  (
  `help_doc_catalog_id` bigint NOT NULL AUTO_INCREMENT COMMENT '帮助文档目录',
  `name` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '名称',
  `sort` int NOT NULL DEFAULT 0 COMMENT '排序字段',
  `parent_id` bigint NOT NULL COMMENT '父级id',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`help_doc_catalog_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '帮助文档-目录' ROW_FORMAT = Dynamic;

CREATE TABLE `t_help_doc_relation`  (
  `relation_id` bigint NOT NULL COMMENT '关联id',
  `relation_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '关联名称',
  `help_doc_id` bigint NOT NULL COMMENT '文档id',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`relation_id`, `help_doc_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '帮助文档-关联表' ROW_FORMAT = Dynamic;

CREATE TABLE `t_help_doc_view_record`  (
  `help_doc_id` bigint NOT NULL COMMENT '通知公告id',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '用户名称',
  `page_view_count` int NULL DEFAULT 0 COMMENT '查看次数',
  `first_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '首次ip',
  `first_user_agent` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '首次用户设备等标识',
  `last_ip` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '最后一次ip',
  `last_user_agent` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '最后一次用户设备等标识',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`help_doc_id`, `user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '帮助文档-查看记录' ROW_FORMAT = Dynamic;

CREATE TABLE `t_login_fail`  (
  `login_fail_id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `user_type` int NOT NULL COMMENT '用户类型',
  `login_name` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '登录名',
  `login_fail_count` int NULL DEFAULT NULL COMMENT '连续登录失败次数',
  `lock_flag` tinyint NULL DEFAULT 0 COMMENT '锁定状态:1锁定，0未锁定',
  `login_lock_begin_time` datetime(0) NULL DEFAULT NULL COMMENT '连续登录失败锁定开始时间',
  `create_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`login_fail_id`) USING BTREE,
  UNIQUE INDEX `uid_and_utype`(`user_id`, `user_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '登录失败次数记录表' ROW_FORMAT = Dynamic;

CREATE TABLE `t_login_log` (
  `login_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` int NOT NULL COMMENT '用户id',
  `user_type` int NOT NULL COMMENT '用户类型',
  `user_name` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名',
  `login_ip` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户ip',
  `login_ip_region` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '用户ip地区',
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT 'user-agent信息',
  `login_device` varchar(1000) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '登录设备',
  `login_result` int NOT NULL COMMENT '登录结果：0成功 1失败 2 退出',
  `remark` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '备注',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`login_log_id`) USING BTREE,
  KEY `customer_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='用户登录日志';

CREATE TABLE `t_mail_template`  (
  `template_code` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `template_subject` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '模板名称',
  `template_content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '模板内容',
  `template_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '解析类型 string，freemarker',
  `disable_flag` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否禁用',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`template_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

CREATE TABLE `t_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
  `menu_type` int NOT NULL COMMENT '类型',
  `parent_id` bigint NOT NULL COMMENT '父菜单ID',
  `sort` int NULL DEFAULT NULL COMMENT '显示顺序',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '路由地址',
  `component` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '组件路径',
  `perms_type` int NULL DEFAULT NULL COMMENT '权限类型',
  `api_perms` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '后端权限字符串',
  `web_perms` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '前端权限字符串',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单图标',
  `context_menu_id` bigint NULL DEFAULT NULL COMMENT '功能点关联菜单ID',
  `frame_flag` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否为外链',
  `frame_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '外链地址',
  `cache_flag` tinyint(1) NOT NULL DEFAULT 0 COMMENT '是否缓存',
  `visible_flag` tinyint(1) NOT NULL DEFAULT 1 COMMENT '显示状态',
  `disabled_flag` tinyint(1) NOT NULL DEFAULT 0 COMMENT '禁用状态',
  `deleted_flag` tinyint(1) NOT NULL DEFAULT 0 COMMENT '删除状态',
  `create_user_id` bigint NOT NULL COMMENT '创建人',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_user_id` bigint NULL DEFAULT NULL COMMENT '更新人',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单表' ROW_FORMAT = Dynamic;

CREATE TABLE `t_operate_log` (
  `operate_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `operate_user_id` bigint NOT NULL COMMENT '用户id',
  `operate_user_type` int NOT NULL COMMENT '用户类型',
  `operate_user_name` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '用户名称',
  `module` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '操作模块',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '操作内容',
  `url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '请求路径',
  `method` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '请求方法',
  `param` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '请求参数',
  `response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '返回值',
  `ip` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '请求ip',
  `ip_region` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT '请求ip地区',
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '请求user-agent',
  `success_flag` tinyint DEFAULT NULL COMMENT '请求结果 0失败 1成功',
  `fail_reason` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci COMMENT '失败原因',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`operate_log_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC COMMENT='操作记录';

CREATE TABLE `t_password_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `user_type` tinyint NOT NULL COMMENT '用户类型',
  `old_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '旧密码',
  `new_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '新密码',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_and_type_index`(`user_id`, `user_type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '密码修改记录' ROW_FORMAT = Dynamic;

CREATE TABLE `t_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `role_name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '角色名称',
  `role_code` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色编码',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色描述',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`role_id`) USING BTREE,
  UNIQUE INDEX `role_code_uni`(`role_code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

CREATE TABLE `t_role_employee`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL COMMENT '角色id',
  `employee_id` bigint NOT NULL COMMENT '员工id',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_role_employee`(`role_id`, `employee_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色员工功能表' ROW_FORMAT = Dynamic;

CREATE TABLE `t_role_menu`  (
  `role_menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键id',
  `role_id` bigint NOT NULL COMMENT '角色id',
  `menu_id` bigint NOT NULL COMMENT '菜单id',
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`role_menu_id`) USING BTREE,
  INDEX `idx_role_id`(`role_id`) USING BTREE,
  INDEX `idx_menu_id`(`menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色-菜单\n' ROW_FORMAT = Dynamic;

CREATE TABLE `t_table_column`  (
  `table_column_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户id',
  `user_type` int NOT NULL COMMENT '用户类型',
  `table_id` int NOT NULL COMMENT '表格id',
  `columns` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '具体的表格列，存入的json',
  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`table_column_id`) USING BTREE,
  UNIQUE INDEX `uni_employee_table`(`user_id`, `table_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '表格的自定义列存储' ROW_FORMAT = Dynamic;

START TRANSACTION;

INSERT INTO t_config (config_id, config_name, config_key, config_value, remark)
VALUES (1, '三级等保', 'level3_protect_config', '{"fileDetectFlag":true,"loginActiveTimeoutMinutes":30,"loginFailLockMinutes":30,"loginFailMaxTimes":3,"maxUploadFileSizeMb":30,"passwordComplexityEnabled":true,"regularChangePasswordMonths":3,"regularChangePasswordNotAllowRepeatTimes":3,"twoFactorLoginEnabled":false}', '默认安全配置');

INSERT INTO t_department (department_id, department_name, manager_id, parent_id, sort)
VALUES (1, '比奇堡', 1, 0, 1);

INSERT INTO t_employee (employee_id, employee_uid, login_name, login_pwd, actual_name, avatar, gender, phone, department_id, email, disabled_flag, deleted_flag, administrator_flag, remark)
VALUES (1, 'cf1e361fd46741f5b2a09335cef50db8', 'admin', '$argon2id$v=19$m=16384,t=2,p=1$d9yQEAhck+haKxP2ZtXocg$NEnw3D2Ly8UbYpy2odATLA4ZflZ1FKJjWCuOGrVE4PM', '海绵宝宝', NULL, 0, NULL, 1, NULL, 0, 0, 1, NULL);

INSERT INTO t_mail_template (template_code, template_subject, template_content, template_type, disable_flag)
VALUES ('login_verification_code', '登录验证码', '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>登录验证码</title></head><body><h1>登录验证码</h1><p>请在验证页面输入此验证码：</p><p><b>${code}</b></p><p>验证码将在5分钟后过期。</p><p>如果你未曾提出此请求，可以忽略这封邮件。</p></body></html>', 'freemarker', 0);

INSERT INTO t_menu (menu_id, menu_name, menu_type, parent_id, sort, path, component, perms_type, api_perms, web_perms, icon, context_menu_id, frame_flag, frame_url, cache_flag, visible_flag, disabled_flag, deleted_flag, create_user_id, create_time, update_user_id, update_time) VALUES
(26, '菜单管理', 2, 50, 1, '/menu/list', '/system/menu/menu-list.vue', NULL, NULL, NULL, 'CopyOutlined', NULL, 0, NULL, 1, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(40, '删除', 3, 26, NULL, NULL, NULL, 1, 'system:menu:batchDelete', 'system:menu:batchDelete', NULL, 26, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(45, '组织架构', 1, 0, 3, '/organization', NULL, NULL, NULL, NULL, 'UserSwitchOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(46, '员工管理', 2, 45, 3, '/organization/employee', '/system/employee/index.vue', NULL, NULL, NULL, 'AuditOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(50, '系统设置', 1, 0, 6, '/setting', NULL, NULL, NULL, NULL, 'SettingOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(76, '角色管理', 2, 45, 4, '/organization/role', '/system/role/index.vue', NULL, NULL, NULL, 'SlidersOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(81, '用户操作记录', 2, 213, 6, '/support/operate-log/operate-log-list', '/support/operate-log/operate-log-list.vue', NULL, NULL, NULL, 'VideoCameraOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(86, '添加部门', 3, 46, 1, NULL, NULL, 1, 'system:department:add', 'system:department:add', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(87, '修改部门', 3, 46, 2, NULL, NULL, 1, 'system:department:update', 'system:department:update', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(88, '删除部门', 3, 46, 3, NULL, NULL, 1, 'system:department:delete', 'system:department:delete', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(91, '添加员工', 3, 46, NULL, NULL, NULL, 1, 'system:employee:add', 'system:employee:add', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(92, '编辑员工', 3, 46, NULL, NULL, NULL, 1, 'system:employee:update', 'system:employee:update', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(93, '禁用启用员工', 3, 46, NULL, NULL, NULL, 1, 'system:employee:disabled', 'system:employee:disabled', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(94, '调整员工部门', 3, 46, NULL, NULL, NULL, 1, 'system:employee:department:update', 'system:employee:department:update', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(95, '重置密码', 3, 46, NULL, NULL, NULL, 1, 'system:employee:password:reset', 'system:employee:password:reset', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(96, '删除员工', 3, 46, NULL, NULL, NULL, 1, 'system:employee:delete', 'system:employee:delete', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(97, '添加角色', 3, 76, NULL, NULL, NULL, 1, 'system:role:add', 'system:role:add', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(98, '删除角色', 3, 76, NULL, NULL, NULL, 1, 'system:role:delete', 'system:role:delete', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(99, '编辑角色', 3, 76, NULL, NULL, NULL, 1, 'system:role:update', 'system:role:update', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(101, '批量移除员工', 3, 76, NULL, NULL, NULL, 1, 'system:role:employee:batch:delete', 'system:role:employee:batch:delete', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(102, '移除员工', 3, 76, NULL, NULL, NULL, 1, 'system:role:employee:delete', 'system:role:employee:delete', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(103, '添加员工', 3, 76, NULL, NULL, NULL, 1, 'system:role:employee:add', 'system:role:employee:add', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(104, '修改权限', 3, 76, NULL, NULL, NULL, 1, 'system:role:menu:update', 'system:role:menu:update', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(105, '添加', 3, 26, NULL, NULL, NULL, 1, 'system:menu:add', 'system:menu:add', NULL, 26, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(106, '编辑', 3, 26, NULL, NULL, NULL, 1, 'system:menu:update', 'system:menu:update', NULL, 26, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(143, '登录登出记录', 2, 213, 5, '/support/login-log/login-log-list', '/support/login-log/login-log-list.vue', NULL, NULL, NULL, 'LoginOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(147, '帮助文档', 2, 218, 1, '/help-doc/help-doc-manage-list', '/support/help-doc/management/help-doc-manage-list.vue', NULL, NULL, NULL, 'FolderViewOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(148, '意见反馈', 2, 218, 2, '/feedback/feedback-list', '/support/feedback/feedback-list.vue', NULL, NULL, NULL, 'CoffeeOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(152, '更新日志', 2, 218, 3, '/support/change-log/change-log-list', '/support/change-log/change-log-list.vue', NULL, NULL, NULL, 'HeartOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(168, '查询', 3, 147, 11, NULL, NULL, 1, 'support:helpDoc:query', 'support:helpDoc:query', NULL, 147, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(169, '新建', 3, 147, 12, NULL, NULL, 1, 'support:helpDoc:add', 'support:helpDoc:add', NULL, 147, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(170, '新建目录', 3, 147, 1, NULL, NULL, 1, 'support:helpDocCatalog:addCategory', 'support:helpDocCatalog:addCategory', NULL, 147, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(171, '修改目录', 3, 147, 2, NULL, NULL, 1, 'support:helpDocCatalog:update', 'support:helpDocCatalog:update', NULL, 147, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(190, '查询', 3, 152, NULL, NULL, NULL, 1, '', 'support:changeLog:query', NULL, 152, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(191, '新建', 3, 152, NULL, NULL, NULL, 1, 'support:changeLog:add', 'support:changeLog:add', NULL, 152, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(192, '批量删除', 3, 152, NULL, NULL, NULL, 1, 'support:changeLog:batchDelete', 'support:changeLog:batchDelete', NULL, 152, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(198, '删除', 3, 152, NULL, NULL, NULL, 1, 'support:changeLog:delete', 'support:changeLog:delete', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(201, '删除', 3, 147, 14, NULL, NULL, 1, 'support:helpDoc:delete', 'support:helpDoc:delete', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(202, '更新', 3, 147, 13, NULL, NULL, 1, 'support:helpDoc:update', 'support:helpDoc:update', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(203, '查询', 3, 143, NULL, NULL, NULL, 1, 'support:loginLog:query', 'support:loginLog:query', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(204, '查询', 3, 81, NULL, NULL, NULL, 1, 'support:operateLog:query', 'support:operateLog:query', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(205, '详情', 3, 81, NULL, NULL, NULL, 1, 'support:operateLog:detail', 'support:operateLog:detail', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(207, '更新', 3, 152, NULL, NULL, NULL, 1, 'support:changeLog:update', 'support:changeLog:update', NULL, NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(213, '网络安全', 1, 0, 5, '/security', NULL, 1, NULL, NULL, 'SafetyCertificateOutlined', NULL, 0, NULL, 1, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(214, '登录失败锁定', 2, 213, 4, '/support/login-fail', '/support/login-fail/login-fail-list.vue', 1, NULL, NULL, 'LockOutlined', NULL, 0, NULL, 1, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(218, '文档中心', 1, 0, 4, '/document', NULL, 1, NULL, NULL, 'FileSearchOutlined', NULL, 0, NULL, 1, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(219, '部门管理', 2, 45, 1, '/organization/department', '/system/department/department-list.vue', 1, NULL, NULL, 'ApartmentOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(234, 'swagger文档', 2, 218, 5, '/swagger', 'http://localhost:1024/swagger-ui/index.html', 1, NULL, NULL, 'ApiOutlined', NULL, 1, 'http://localhost:1024/swagger-ui/index.html', 1, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(250, '三级等保设置', 2, 213, 1, '/support/level3protect/level3-protect-config-index', '/support/level3protect/level3-protect-config-index.vue', 1, NULL, NULL, 'SafetyOutlined', NULL, 0, NULL, 1, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(251, '缓存管理', 2, 50, 2, '/support/cache', '/support/cache/cache-list.vue', NULL, NULL, NULL, 'DatabaseOutlined', NULL, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(252, '查询', 3, 251, 1, NULL, NULL, 1, 'support:cache:query', 'support:cache:query', NULL, 251, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP),
(253, '清理', 3, 251, 2, NULL, NULL, 1, 'support:cache:clear', 'support:cache:clear', NULL, 251, 0, NULL, 0, 1, 0, 0, 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP);

INSERT INTO t_role (role_id, role_name, role_code, remark)
VALUES (1, '管理员', 'admin', '系统管理员');

INSERT INTO t_role_employee (role_id, employee_id) VALUES (1, 1);

INSERT INTO t_role_menu (role_id, menu_id)
SELECT 1, menu_id FROM t_menu WHERE disabled_flag = 0 AND deleted_flag = 0 ORDER BY menu_id;

COMMIT;

SELECT DATABASE() AS database_name, 'admin' AS initial_login_name, '初始化成功，请使用当前 admin 密码登录' AS result;
