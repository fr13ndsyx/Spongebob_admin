<template>
  <a-card class="welcome-card" :bordered="false">
    <div class="welcome-header">
      <div class="welcome-info">
        <h1>{{ actualName ? actualName + '，欢迎回来' : '欢迎使用管理后台' }}</h1>
        <p class="day-info">{{ dayInfo }}<span v-if="userStore.departmentName"> · {{ userStore.departmentName }}</span></p>
        <p v-if="loginRegion" class="login-info"><EnvironmentOutlined /> 地区：{{ loginRegion }}</p>
        <p class="heart-sentence"><SmileOutlined /> {{ heartSentence }}</p>
      </div>
      <a-button class="feedback-button" type="link" @click="feedbackModal?.show()"><MessageOutlined /> 意见反馈</a-button>
    </div>
  </a-card>
  <FeedbackModal ref="feedbackModal" />
  <HomeHelpDoc />
  <a-card v-if="loadFailed || changeLogs.length" class="change-log-card" title="更新日志" :bordered="false">
    <template #extra>
      <a-button type="link" :loading="loading" @click="queryChangeLogs">刷新</a-button>
    </template>
    <a-alert v-if="loadFailed" type="error" show-icon message="更新日志加载失败，请点击刷新重试。" />
    <a-list v-else :data-source="changeLogs" :loading="loading" :locale="{ emptyText: '暂无更新日志' }">
      <template #renderItem="{ item }">
        <a-list-item>
          <a-list-item-meta>
            <template #title>
              <a-button class="version-button" type="link" @click="showChangeLog(item)">{{ item.updateVersion }}</a-button>
              <span class="publish-date">{{ item.publicDate }}</span>
            </template>
            <template #description>
              <div class="change-log-preview">{{ item.content }}</div>
            </template>
          </a-list-item-meta>
        </a-list-item>
      </template>
    </a-list>
  </a-card>
  <ChangeLogModal ref="changeLogModal" />
</template>
<script setup lang="ts">
  import { computed, onActivated, onMounted, ref } from 'vue';
  import { useUserStore } from '/@/store/modules/system/user';
  import { changeLogApi } from '/@/api/support/change-log-api';
  import { sentry } from '/@/lib/sentry';
  import HomeHelpDoc from '/@/layout/components/side-help-doc/index.vue';
  import FeedbackModal from '/@/layout/components/side-help-doc/components/feedback-modal.vue';
  import heartSentences from './heart-sentence';
  import ChangeLogModal from '../../support/change-log/change-log-modal.vue';

  interface ChangeLog {
    changeLogId: number;
    updateVersion: string;
    publicDate: string;
    content: string;
    link?: string;
  }

  const HOME_CHANGE_LOG_LIMIT = 5;
  const IP_REGION_LOCATION_FIELDS = 4;
  const userStore = useUserStore();
  const actualName = computed(() => userStore.actualName);
  const loginRegion = computed(() => [...new Set((userStore.lastLoginIpRegion || '').split('|').slice(0, IP_REGION_LOCATION_FIELDS).map(region => region.trim()).filter(region => region && !['0', '内网IP', '未知'].includes(region)))].join(' · '));
  const dayInfo = new Date().toLocaleDateString('zh-CN', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' });
  const heartSentence = heartSentences[Math.floor(Math.random() * heartSentences.length)];
  const changeLogs = ref<ChangeLog[]>([]);
  const changeLogModal = ref<InstanceType<typeof ChangeLogModal>>();
  const feedbackModal = ref<InstanceType<typeof FeedbackModal>>();
  const loading = ref(false);
  const loadFailed = ref(false);

  async function queryChangeLogs(): Promise<void> {
    if (loading.value) return;
    loading.value = true;
    loadFailed.value = false;
    try {
      const response = await changeLogApi.queryPage({
        pageNum: 1,
        pageSize: HOME_CHANGE_LOG_LIMIT,
        searchCount: false,
        sortItemList: [
          { column: 'public_date', isAsc: false },
          { column: 'change_log_id', isAsc: false },
        ],
      });
      changeLogs.value = response.data.list;
    } catch (error) {
      loadFailed.value = true;
      sentry.captureError(error);
    } finally {
      loading.value = false;
    }
  }

  function showChangeLog(changeLog: ChangeLog): void {
    changeLogModal.value?.show(changeLog);
  }

  onMounted(queryChangeLogs);
  onActivated(queryChangeLogs);
</script>
<style scoped>
  .welcome-card, .change-log-card { margin-top: 10px; }
  .welcome-header { display: flex; justify-content: space-between; align-items: center; gap: 24px; }
  .welcome-info { min-width: 0; flex: 1; }
  h1 { margin: 0 0 12px; font-size: 24px; font-weight: 600; }
  p { margin: 0; color: #666; }
  .login-info { margin-top: 8px; font-size: 13px; overflow-wrap: anywhere; }
  .heart-sentence { margin-top: 14px; line-height: 1.8; }
  .feedback-button { display: block; flex-shrink: 0; align-self: flex-end; height: auto; margin-left: auto; padding: 0; border: 0; line-height: 1.8; }
  .version-button { height: auto; padding: 0; font-weight: 600; }
  .publish-date { margin-left: 16px; color: #999; font-size: 13px; }
  .change-log-preview {
    display: -webkit-box;
    overflow: hidden;
    white-space: pre-line;
    -webkit-box-orient: vertical;
    -webkit-line-clamp: 2;
  }
</style>
