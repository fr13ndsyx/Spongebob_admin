<template>
  <a-card size="small" :bordered="false">
    <a-row class="table-btn-block">
      <div class="table-operate-block">
        <a-button
          danger
          :loading="clearing"
          :disabled="tableLoading || tableData.length === 0"
          v-privilege="'support:cache:clear'"
          @click="confirmClear()"
        >
          清理全部业务缓存
        </a-button>
      </div>
      <a-button :disabled="clearing" :loading="tableLoading" v-privilege="'support:cache:query'" @click="queryData">刷新列表</a-button>
    </a-row>
    <a-table
      size="small"
      rowKey="cacheName"
      :columns="columns"
      :dataSource="tableData"
      :loading="tableLoading"
      :pagination="false"
      :scroll="{ x: 600 }"
      bordered
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.dataIndex === 'action'">
          <a-button type="link" danger :disabled="clearing" v-privilege="'support:cache:clear'" @click="confirmClear(record)">清理</a-button>
        </template>
      </template>
    </a-table>
  </a-card>
</template>
<script setup lang="ts">
  import { onMounted, ref } from 'vue';
  import { message, Modal } from 'ant-design-vue';
  import type { TableColumnsType } from 'ant-design-vue';
  import { cacheApi } from '/@/api/support/cache-api';
  import type { CacheItem } from '/@/api/support/cache-api';
  import { sentry } from '/@/lib/sentry';

  const tableData = ref<CacheItem[]>([]);
  const tableLoading = ref(false);
  const clearing = ref(false);
  const columns: TableColumnsType<CacheItem> = [
    { title: '缓存名称', dataIndex: 'displayName', width: 180 },
    { title: '缓存标识', dataIndex: 'cacheName' },
    { title: '操作', dataIndex: 'action', width: 90 },
  ];

  async function queryData(): Promise<void> {
    tableLoading.value = true;
    try {
      const result = await cacheApi.list();
      tableData.value = result.data;
    } catch (error) {
      sentry.captureError(error);
    } finally {
      tableLoading.value = false;
    }
  }

  function confirmClear(cache?: CacheItem): void {
    Modal.confirm({
      title: cache ? `清理${cache.displayName}？` : '清理全部业务缓存？',
      content: '缓存会在后续访问时重新生成，登录状态会保留。',
      okText: '清理',
      okType: 'danger',
      cancelText: '取消',
      onOk: async (): Promise<void> => {
        clearing.value = true;
        try {
          if (cache) {
            await cacheApi.clear(cache.cacheName);
          } else {
            await cacheApi.clearAll();
          }
          message.success('缓存已清理，请刷新相关页面');
        } catch (error) {
          sentry.captureError(error);
          throw error;
        } finally {
          clearing.value = false;
        }
      },
    });
  }

  onMounted(queryData);
</script>
