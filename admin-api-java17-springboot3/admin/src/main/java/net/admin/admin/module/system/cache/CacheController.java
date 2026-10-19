package net.admin.admin.module.system.cache;

import cn.dev33.satoken.annotation.SaCheckPermission;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import net.admin.base.common.domain.ResponseDTO;
import net.admin.base.module.support.operatelog.annotation.OperateLog;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/support/cache")
@Tag(name = "业务支撑-缓存管理")
@RequiredArgsConstructor
public class CacheController {

    private final CacheService cacheService;

    @GetMapping("/list")
    @Operation(summary = "查询可清理的业务缓存")
    @SaCheckPermission("support:cache:query")
    public ResponseDTO<List<CacheVO>> list() {
        return ResponseDTO.ok(cacheService.list());
    }

    @PostMapping("/clear/{cacheName}")
    @Operation(summary = "清理单项业务缓存")
    @SaCheckPermission("support:cache:clear")
    @OperateLog
    public ResponseDTO<String> clear(@PathVariable String cacheName) {
        return cacheService.clear(cacheName);
    }

    @PostMapping("/clearAll")
    @Operation(summary = "清理全部已登记业务缓存")
    @SaCheckPermission("support:cache:clear")
    @OperateLog
    public ResponseDTO<String> clearAll() {
        return cacheService.clearAll();
    }
}
