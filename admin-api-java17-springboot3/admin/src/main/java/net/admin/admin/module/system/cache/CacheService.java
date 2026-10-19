package net.admin.admin.module.system.cache;

import lombok.RequiredArgsConstructor;
import net.admin.admin.constant.AdminCacheConst;
import net.admin.base.common.domain.ResponseDTO;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CacheService {

    private static final List<CacheVO> CLEARABLE_CACHES = List.of(
            new CacheVO(AdminCacheConst.Dict.DICT_DATA, "字典数据"),
            new CacheVO(AdminCacheConst.Department.DEPARTMENT_LIST_CACHE, "部门列表"),
            new CacheVO(AdminCacheConst.Department.DEPARTMENT_TREE_CACHE, "部门树"),
            new CacheVO(AdminCacheConst.Department.DEPARTMENT_SELF_CHILDREN_CACHE, "部门及下级 ID"),
            new CacheVO(AdminCacheConst.Department.DEPARTMENT_PATH_CACHE, "部门路径")
    );

    private final CacheManager cacheManager;

    public List<CacheVO> list() {
        return CLEARABLE_CACHES;
    }

    public ResponseDTO<String> clear(String cacheName) {
        if (CLEARABLE_CACHES.stream().noneMatch(cache -> cache.cacheName().equals(cacheName))) {
            return ResponseDTO.userErrorParam("该缓存未登记为可清理的业务缓存");
        }
        clearCache(cacheName);
        return ResponseDTO.ok();
    }

    public ResponseDTO<String> clearAll() {
        for (CacheVO cache : CLEARABLE_CACHES) {
            clearCache(cache.cacheName());
        }
        return ResponseDTO.ok();
    }

    private void clearCache(String cacheName) {
        Cache cache = cacheManager.getCache(cacheName);
        if (cache == null) {
            throw new IllegalStateException("缓存管理器未提供缓存：" + cacheName);
        }
        cache.clear();
    }
}
