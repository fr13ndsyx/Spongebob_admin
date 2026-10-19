package net.admin.admin.module.system.cache;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "可清理的业务缓存")
public record CacheVO(String cacheName, String displayName) {
}
