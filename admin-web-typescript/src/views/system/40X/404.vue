<template>
  <div class="not-found">
    <img class="illustration" :src="illustration" alt="" />
    <div class="code">404</div>
    <p class="message">这个页面不存在，可能是链接输错了。</p>
    <a-button type="primary" size="large" @click="goHome">返回首页</a-button>
  </div>
</template>

<script setup lang="ts">
  import { useRouter } from 'vue-router';
  import { HOME_PAGE_NAME } from '/@/constants/system/home-const';
  import illustration from '/@/assets/images/404-illustration.png';

  const router = useRouter();

  function goHome() {
    router.push({ name: HOME_PAGE_NAME });
  }
</script>

<style lang="less" scoped>
  .not-found {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    min-height: calc(100vh - 140px);
    padding: 24px;
    text-align: center;
  }

  .illustration {
    width: 236px;
    max-width: 60vw;
    height: auto;
  }

  .code {
    margin: 4px 0 0;
    font-size: 52px;
    font-weight: 600;
    letter-spacing: 6px;
    color: #1f2937;
    line-height: 1.1;
  }

  .message {
    margin: 10px 0 26px;
    font-size: 14px;
    color: #757980;
  }
</style>
