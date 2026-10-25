package net.admin.admin;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import net.admin.admin.module.system.employee.dao.EmployeeDao;
import net.admin.admin.module.system.employee.domain.entity.EmployeeEntity;
import net.admin.base.config.DataSourceConfig;
import net.admin.base.config.MybatisPlusConfig;
import org.apache.ibatis.session.SqlSession;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.SingleConnectionDataSource;
import org.springframework.test.util.ReflectionTestUtils;

import javax.sql.DataSource;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

@EnabledIfEnvironmentVariable(named = "POSTGRES_TEST_URL", matches = ".+")
class PostgresDatabaseTest {

    @Test
    void initializesAndRunsTheRealMappersOnPostgres() throws Exception {
        try (Connection connection = DriverManager.getConnection(System.getenv("POSTGRES_TEST_URL"),
                System.getenv().getOrDefault("POSTGRES_USER", "postgres"), System.getenv("POSTGRES_PASSWORD"))) {
            connection.setAutoCommit(false);
            try {
                String schema = "admin_check_" + UUID.randomUUID().toString().replace("-", "");
                execute(connection, "CREATE SCHEMA " + schema + "; SET LOCAL search_path TO " + schema);
                String initialization = new ClassPathResource("postgresql.sql").getContentAsString(StandardCharsets.UTF_8)
                        .replaceAll("(?m)^(?:BEGIN|START TRANSACTION|COMMIT);\\s*$", "");
                assertDoesNotThrow(() -> execute(connection, initialization));
                assertEquals(22, scalar(connection,
                        "SELECT count(*) FROM information_schema.tables WHERE table_schema = current_schema()"));
                assertEquals(52, scalar(connection, "SELECT count(*) FROM t_menu"));
                assertEquals(52, scalar(connection, "SELECT count(*) FROM t_role_menu"));

                DataSource source = new SingleConnectionDataSource(connection, true);
                DataSourceConfig config = new DataSourceConfig() {
                    @Override
                    public DataSource druidDataSource() {
                        return source;
                    }
                };
                ReflectionTestUtils.setField(config, "paginationInterceptor", new MybatisPlusConfig().paginationInterceptor());
                try (SqlSession session = config.sqlSessionFactory().openSession()) {
                    EmployeeDao employees = session.getMapper(EmployeeDao.class);
                    EmployeeEntity admin = employees.getByLoginName("ADMIN", false);
                    assertNotNull(admin);
                    assertTrue(admin.getAdministratorFlag());
                    assertFalse(admin.getDisabledFlag());

                    EmployeeEntity employee = new EmployeeEntity();
                    employee.setEmployeeUid(UUID.randomUUID().toString());
                    employee.setLoginName("postgres_check");
                    employee.setLoginPwd("test_digest");
                    employee.setActualName("Admin_% Café\\check");
                    employee.setDepartmentId(1L);
                    employee.setGender(0);
                    employee.setAdministratorFlag(false);
                    employee.setDisabledFlag(false);
                    employee.setDeletedFlag(false);
                    assertEquals(1, employees.insert(employee));
                    assertEquals(2L, employee.getEmployeeId());
                    assertEquals(1, query(session, EmployeeDao.class.getName() + ".queryEmployee", "queryForm",
                            Map.of("keyword", "admin_% cafe\\check", "disabledFlag", false, "deletedFlag", false)).size());
                    Page<EmployeeEntity> page = new Page<>(1, 1);
                    List<EmployeeEntity> records = session.selectList(EmployeeDao.class.getName() + ".queryEmployee",
                            Map.of("queryForm", Map.of("deletedFlag", false), "page", page));
                    assertEquals(1, records.size());
                    assertEquals(2, page.getTotal());

                    execute(connection, """
                            INSERT INTO t_config (config_name, config_key, config_value) VALUES ('search', 'Config_% Café', '{}');
                            INSERT INTO t_dict (dict_name, dict_code, disabled_flag) VALUES ('Dict_% Café', 'PG_CHECK', false);
                            INSERT INTO t_dict_data (dict_id, data_value, data_label, sort_order, disabled_flag)
                            SELECT dict_id, 'one', 'One', 1, false FROM t_dict WHERE dict_code = 'PG_CHECK';
                            INSERT INTO t_role_employee (role_id, employee_id) VALUES (1, 2);
                            INSERT INTO t_change_log (update_version, type, publish_author, public_date, content, create_time)
                            VALUES ('Version_% Café', 1, 'check', DATE '2024-02-29', 'check', TIMESTAMP '2024-02-29 23:59:59');
                            INSERT INTO t_feedback (feedback_content, user_id, user_type, user_name, create_time)
                            VALUES ('Feedback_% Café', 1, 1, 'check', TIMESTAMP '2024-02-29 23:59:59'),
                                   ('Feedback_% Café', 1, 1, 'check', TIMESTAMP '2024-03-01 00:00:00');
                            INSERT INTO t_file (folder_type, file_name, file_key, file_type, create_time)
                            VALUES (1, 'File_% Café', 'pg_check', 'txt', TIMESTAMP '2024-02-29 23:59:59');
                            INSERT INTO t_help_doc (help_doc_catalog_id, title, content_text, content_html, create_time)
                            VALUES (1, 'Doc_% Café', 'check', 'check', TIMESTAMP '2024-02-29 23:59:59');
                            INSERT INTO t_login_fail (user_id, user_type, login_name, lock_flag, login_lock_begin_time)
                            VALUES (1, 1, 'Fail_% Café', true, TIMESTAMP '2024-02-29 23:59:59');
                            INSERT INTO t_login_log (user_id, user_type, user_name, login_result, create_time)
                            VALUES (1, 1, 'Login_% Café', 0, TIMESTAMP '2024-02-29 23:59:59'),
                                   (1, 1, 'Login_% Café', 0, TIMESTAMP '2024-03-01 00:00:00');
                            INSERT INTO t_operate_log (operate_user_id, operate_user_type, operate_user_name, success_flag, create_time)
                            VALUES (1, 1, 'Operate_% Café', true, TIMESTAMP '2024-02-29 23:59:59');
                            """);
                    LocalDate day = LocalDate.of(2024, 2, 29);
                    String base = "net.admin.base.module.support.";
                    assertEquals(1, query(session, base + "config.ConfigDao.queryByPage", "query", Map.of("configKey", "config_% cafe")).size());
                    assertEquals(1, query(session, base + "dict.dao.DictDao.queryPage", "queryForm", Map.of("keywords", "dict_% cafe", "disabledFlag", false)).size());
                    assertEquals(1, query(session, base + "changelog.dao.ChangeLogDao.queryPage", "queryForm", Map.of("keyword", "version_% cafe", "publicDateBegin", day, "publicDateEnd", day, "createTime", day)).size());
                    assertEquals(1, query(session, base + "feedback.dao.FeedbackDao.queryPage", "query", Map.of("searchWord", "feedback_% cafe", "startDate", day, "endDate", day)).size());
                    assertEquals(1, query(session, base + "file.dao.FileDao.queryPage", "queryForm", Map.of("fileName", "file_% cafe", "createTimeBegin", day, "createTimeEnd", day)).size());
                    assertEquals(1, query(session, base + "helpdoc.dao.HelpDocDao.query", "query", Map.of("keywords", "doc_% cafe", "createTimeBegin", day, "createTimeEnd", day)).size());
                    var locked = query(session, base + "securityprotect.dao.LoginFailDao.queryPage", "queryForm", Map.of("loginName", "fail_% cafe", "lockFlag", true, "loginLockBeginTimeBegin", day, "loginLockBeginTimeEnd", day));
                    assertEquals(1, locked.size());
                    assertEquals(1, ((net.admin.base.module.support.securityprotect.domain.LoginFailVO) locked.get(0)).getLockFlag());
                    assertEquals(1, query(session, base + "loginlog.LoginLogDao.queryByPage", "query", Map.of("userName", "login_% cafe", "startDate", day.toString(), "endDate", day.toString())).size());
                    assertEquals(1, query(session, base + "operatelog.OperateLogDao.queryByPage", "query", Map.of("userName", "operate_% cafe", "successFlag", true, "startDate", day.toString(), "endDate", day.toString())).size());
                    assertEquals(1, query(session, "net.admin.admin.module.system.role.dao.RoleEmployeeDao.selectRoleEmployeeByName", "queryForm", Map.of("keywords", "admin_% cafe")).size());
                    session.update("net.admin.admin.module.system.menu.dao.MenuDao.deleteByMenuIdList",
                            Map.of("menuIdList", List.of(252L, 253L), "updateUserId", 1L, "deletedFlag", true));
                    assertEquals(2, scalar(connection, "SELECT count(*) FROM t_menu WHERE menu_id IN (252, 253) AND deleted_flag"));

                    execute(connection, "UPDATE t_role SET update_time = TIMESTAMP '2000-01-01' WHERE role_id = 1; UPDATE t_role SET remark = 'updated' WHERE role_id = 1");
                    assertEquals(1, scalar(connection, "SELECT count(*) FROM t_role WHERE role_id = 1 AND update_time > TIMESTAMP '2000-01-01'"));
                    execute(connection, "UPDATE t_role SET update_time = TIMESTAMP '2000-01-01' WHERE role_id = 1; UPDATE t_role SET role_code = 'ADMIN' WHERE role_id = 1");
                    assertEquals(1, scalar(connection, "SELECT count(*) FROM t_role WHERE role_id = 1 AND update_time > TIMESTAMP '2000-01-01'"));
                    var savepoint = connection.setSavepoint();
                    assertThrows(SQLException.class, () -> execute(connection, "INSERT INTO t_role (role_name, role_code) VALUES ('duplicate', 'ADMIN')"));
                    connection.rollback(savepoint);
                }
            } finally {
                connection.rollback();
            }
        }
    }

    private static List<Object> query(SqlSession session, String statement, String parameter, Map<String, Object> values) {
        return session.selectList(statement, Map.of(parameter, values));
    }

    private static void execute(Connection connection, String sql) throws SQLException {
        try (Statement statement = connection.createStatement()) {
            statement.execute(sql);
        }
    }

    private static long scalar(Connection connection, String sql) throws SQLException {
        try (Statement statement = connection.createStatement(); var result = statement.executeQuery(sql)) {
            assertTrue(result.next());
            return result.getLong(1);
        }
    }
}
