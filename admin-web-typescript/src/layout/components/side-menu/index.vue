<template>
  <!--左侧菜单分为两部分：1、顶部logo区域，包含 logo和名称;2、下方菜单区域-->

  <!-- 1、顶部logo区域 -->
  <div class="logo" @click="onGoHome" :style="sideMenuWidth" v-if="!collapsed">
    <img class="logo-avatar" :src="defaultAvatar" alt="" />
    <div class="title logo title-light" v-if="sideMenuTheme === 'light'">{{ websiteName }}</div>
    <div class="title logo title-dark" v-if="sideMenuTheme === 'dark'">{{ websiteName }}</div>
  </div>
  <div class="min-logo" @click="onGoHome" v-if="collapsed">
    <img class="logo-avatar" :src="defaultAvatar" alt="首页" />
  </div>

  <!-- 2、下方菜单区域： 这里使用一个递归菜单解决 -->
  <div class="menu">
    <RecursionMenu :collapsed="collapsed" ref="menuRef" />
  </div>
</template>

<script setup lang="ts">
  import { computed, nextTick, ref, watch } from 'vue';
  import { useRouter } from 'vue-router';
  import RecursionMenu from './recursion-menu.vue';
  import { HOME_PAGE_NAME } from '/@/constants/system/home-const';
  import { useAppConfigStore } from '/@/store/modules/system/app-config';
  import { defaultAvatar } from '/@/lib/avatar';

  const websiteName = computed(() => useAppConfigStore().websiteName);
  const sideMenuWidth = computed(() => 'width:' + useAppConfigStore().sideMenuWidth + 'px');
  const sideMenuTheme = computed(() => useAppConfigStore().sideMenuTheme);

  const props = defineProps({
    collapsed: {
      type: Boolean,
      required: false,
      default: false,
    },
  });

  const menuRef = ref();

  watch(
    () => props.collapsed,
    (newValue, oldValue) => {
      // 如果是展开菜单的话，重新获取更新菜单的展开项: openkeys和selectKeys
      if (!newValue) {
        nextTick(() => menuRef.value.updateOpenKeysAndSelectKeys());
      }
    }
  );

  const router = useRouter();
  function onGoHome() {
    router.push({ name: HOME_PAGE_NAME });
  }

  const color = computed(() => {
    let isLight = useAppConfigStore().$state.sideMenuTheme === 'light';
    return {
      background: isLight ? '#FFFFFF' : '#001529',
    };
  });
</script>

<style lang="less" scoped>
  .home-icon {
    font-size: 24px;
  }

  .logo-avatar {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    margin-right: 10px;
    flex: none;
    object-fit: cover;
  }

  .min-logo .logo-avatar {
    margin-right: 0;
  }

  .shadow {
    box-shadow: 2px 0 6px rgba(0, 21, 41, 0.35);
  }
  .side-menu {
    min-height: 100vh;
    overflow-y: auto;
    z-index: 10;

    .min-logo {
      height: @header-user-height;
      line-height: @header-user-height;
      padding: 0px 15px 0px 15px;
      background-color: v-bind('color.background');
      position: fixed;
      width: 80px;
      z-index: 21;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .logo {
      height: @header-user-height;
      line-height: @header-user-height;
      background-color: v-bind('color.background');
      padding: 0px 15px 0px 15px;
      position: fixed;
      z-index: 21;
      display: flex;
      cursor: pointer;
      justify-content: center;
      align-items: center;


      .title {
        font-size: 16px;
        font-weight: 600;
      }
      .title-light {
        color: #001529;
      }
      .title-dark {
        color: #ffffff;
      }
    }
  }
  .menu {
    margin-top: @header-user-height;
  }
</style>
