package net.admin.admin.module.system.cache;

import cn.dev33.satoken.annotation.SaCheckPermission;
import org.junit.jupiter.api.Test;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class CacheServiceTest {

    @Test
    void clearsOnlyRegisteredBusinessCaches() {
        ConcurrentMapCacheManager manager = new ConcurrentMapCacheManager();
        CacheService service = new CacheService(manager);
        List<String> businessNames = List.of("dict_data_cache", "department_list_cache", "department_tree_cache",
                "department_self_children_cache", "department_path_cache");
        List<String> protectedNames = List.of("login_request_employee", "login_user_permission", "Authorization:login:session",
                "captcha", "login:verification-code", "repeat-submit", "future_module_state");
        for (String name : businessNames) {
            manager.getCache(name).put("entry", "business");
        }
        for (String name : protectedNames) {
            manager.getCache(name).put("entry", "protected");
        }

        assertEquals(businessNames, service.list().stream().map(CacheVO::cacheName).toList());
        assertTrue(service.clearAll().getOk());

        for (String name : businessNames) {
            assertNull(manager.getCache(name).get("entry"), name);
        }
        for (String name : protectedNames) {
            assertEquals("protected", manager.getCache(name).get("entry", String.class), name);
        }
    }

    @Test
    void rejectsProtectedUnknownAndPatternNamesBeforeAccessingCacheManager() {
        ConcurrentMapCacheManager manager = new ConcurrentMapCacheManager();
        CacheService service = new CacheService(manager);
        for (String name : new String[]{null, "", "*", "cache:*", "login_request_employee", "login_user_permission",
                "Authorization:login:session", "department_list_cache#-1", "department_list_cache:*", "unknown"}) {
            assertFalse(service.clear(name).getOk(), name);
        }
        assertTrue(manager.getCacheNames().isEmpty());
    }

    @Test
    void clearingOneCacheKeepsOtherBusinessCaches() {
        ConcurrentMapCacheManager manager = new ConcurrentMapCacheManager();
        CacheService service = new CacheService(manager);
        manager.getCache("dict_data_cache").put("entry", "dict");
        manager.getCache("department_list_cache").put("entry", "department");

        assertTrue(service.clear("dict_data_cache").getOk());

        assertNull(manager.getCache("dict_data_cache").get("entry"));
        assertEquals("department", manager.getCache("department_list_cache").get("entry", String.class));
    }

    @Test
    void endpointsRequirePermissionsAndUsePostForClearing() throws Exception {
        assertArrayEquals(new String[]{"support:cache:query"}, CacheController.class.getMethod("list")
                .getAnnotation(SaCheckPermission.class).value());
        for (String methodName : List.of("clear", "clearAll")) {
            var method = methodName.equals("clear") ? CacheController.class.getMethod(methodName, String.class)
                    : CacheController.class.getMethod(methodName);
            assertArrayEquals(new String[]{"support:cache:clear"}, method.getAnnotation(SaCheckPermission.class).value());
            assertNotNull(method.getAnnotation(PostMapping.class));
        }
    }
}
