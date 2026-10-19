package net.admin.base.config;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.Cursor;
import org.springframework.data.redis.core.ScanOptions;
import org.springframework.test.util.ReflectionTestUtils;

import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class CacheConfigTest {

    @Test
    void clearsOnlyTheSelectedCachePrefixUsingScan() {
        RedisConnectionFactory factory = mock(RedisConnectionFactory.class);
        RedisConnection connection = mock(RedisConnection.class);
        Cursor<byte[]> cursor = mock(Cursor.class);
        byte[] businessKey = "cache:dict_data_cache:status_1".getBytes(StandardCharsets.UTF_8);
        var keys = List.of(businessKey).iterator();
        when(cursor.hasNext()).thenAnswer(invocation -> keys.hasNext());
        when(cursor.next()).thenAnswer(invocation -> keys.next());
        when(factory.getConnection()).thenReturn(connection);
        when(connection.scan(any(ScanOptions.class))).thenReturn(cursor);
        CacheConfig config = new CacheConfig();
        ReflectionTestUtils.setField(config, "redisConnectionFactory", factory);
        RedisCacheManager manager = (RedisCacheManager) config.cacheManager();
        manager.afterPropertiesSet();

        manager.getCache("dict_data_cache").clear();

        ArgumentCaptor<ScanOptions> options = ArgumentCaptor.forClass(ScanOptions.class);
        verify(connection).scan(options.capture());
        assertEquals("cache:dict_data_cache:*", options.getValue().getPattern());
        assertTrue(options.getValue().getCount() > 0);
        verify(connection).del(businessKey);
        verify(connection, never()).keys(any(byte[].class));
        verify(connection, never()).flushDb();
        verify(connection, never()).flushAll();
    }
}
