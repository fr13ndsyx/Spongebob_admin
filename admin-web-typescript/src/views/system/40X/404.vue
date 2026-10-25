<template>
  <main class="not-found" aria-labelledby="not-found-title">
    <div class="not-found-content">
      <div class="ocean-scene" aria-hidden="true">
        <svg class="ocean-backdrop" viewBox="0 0 500 440" fill="none" focusable="false">
          <path d="M73 138 C92 66 187 47 268 65 C353 29 446 81 451 166 C491 246 434 345 354 365 C256 408 142 382 82 318 C29 266 32 191 73 138Z" fill="#e8f0f2" />
          <path d="M75 275 C126 239 145 313 193 282 C234 254 247 296 279 284" stroke="#bcd4dc" stroke-width="2" stroke-linecap="round" stroke-dasharray="4 9" />
          <g stroke="#c6dde3" stroke-width="2.5" stroke-linejoin="round">
            <path d="M0 -14 C-39 -62 -62 -23 -15 -1 C-69 15 -32 55 -5 15 C8 70 43 37 13 6 C68 10 46 -40 9 -12 C40 -64 -10 -67 0 -14Z" transform="translate(120 114) rotate(-12)" />
            <path d="M0 -14 C-39 -62 -62 -23 -15 -1 C-69 15 -32 55 -5 15 C8 70 43 37 13 6 C68 10 46 -40 9 -12 C40 -64 -10 -67 0 -14Z" transform="translate(411 294) rotate(20) scale(.65)" />
          </g>
          <g stroke="#b4d1da" stroke-width="1.7">
            <circle cx="351" cy="57" r="6" />
            <circle cx="368" cy="34" r="3" />
            <circle cx="65" cy="213" r="6" />
            <circle cx="431" cy="219" r="4" />
          </g>
          <g class="lost-jelly">
            <g transform="translate(418 112) rotate(12)">
              <path d="M-16 1 C-23 20 -8 24 -17 43 M0 4 C10 20 -8 29 0 49 M16 1 C9 20 25 28 16 42" stroke="#d6a2c1" stroke-width="2.7" stroke-linecap="round" />
              <path d="M-28 0 C-28 -38 28 -38 28 0 Q23 8 16 3 Q8 11 0 5 Q-9 11 -17 3 Q-28 8 -28 0Z" fill="#f2c9df" stroke="#c890b0" stroke-width="1.6" />
              <path d="M-18 -12 Q-14 -21 -4 -22" stroke="#fff4fa" stroke-width="3.5" stroke-linecap="round" />
              <ellipse cx="12" cy="-16" rx="3.5" ry="2.5" fill="#dca3c4" />
              <circle cx="-4" cy="-10" r="2.3" fill="#dca3c4" />
            </g>
          </g>
          <g class="lost-jelly lost-jelly-small">
            <g transform="translate(81 333) rotate(-14) scale(.62)">
              <path d="M-16 1 C-23 20 -8 24 -17 43 M0 4 C10 20 -8 29 0 49 M16 1 C9 20 25 28 16 42" stroke="#d6a2c1" stroke-width="2.7" stroke-linecap="round" />
              <path d="M-28 0 C-28 -38 28 -38 28 0 Q23 8 16 3 Q8 11 0 5 Q-9 11 -17 3 Q-28 8 -28 0Z" fill="#f2c9df" stroke="#c890b0" stroke-width="1.6" />
              <path d="M-18 -12 Q-14 -21 -4 -22" stroke="#fff4fa" stroke-width="3.5" stroke-linecap="round" />
            </g>
          </g>
          <ellipse cx="262" cy="376" rx="115" ry="12" fill="#cbdde3" opacity=".65" />
        </svg>
        <img class="illustration" :src="illustration" alt="" />
      </div>

      <div class="not-found-copy">
        <p class="code" aria-label="错误代码 404">404</p>
        <h1 id="not-found-title" class="message"><span>页面不存在，</span><span>是不是抓水母迷路了？</span></h1>
        <a-button class="home-button" type="primary" size="large" @click="goHome">
          <template #icon><HomeOutlined /></template>
          返回首页
        </a-button>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
  import { HomeOutlined } from '@ant-design/icons-vue';
  import { useRouter } from 'vue-router';
  import { HOME_PAGE_NAME } from '/@/constants/system/home-const';
  import illustration from '/@/assets/images/404-illustration.png';

  const router = useRouter();

  function goHome(): void {
    router.push({ name: HOME_PAGE_NAME });
  }
</script>

<style lang="less" scoped>
  :global(#app:has(.not-found)) {
    min-width: 0;
  }

  .not-found {
    display: grid;
    place-items: center;
    min-height: 100vh;
    min-height: 100dvh;
    padding: 48px 32px;
    background: #f6f7f9;
    color: #293f4a;
    font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
  }

  .not-found-content {
    display: grid;
    grid-template-columns: minmax(0, 1.15fr) minmax(0, 1fr);
    align-items: center;
    gap: 64px;
    width: min(100%, 1020px);
  }

  .ocean-scene {
    position: relative;
    width: 100%;
    aspect-ratio: 500 / 440;
  }

  .ocean-backdrop {
    display: block;
    width: 100%;
    height: 100%;
  }

  .illustration {
    position: absolute;
    bottom: 9%;
    left: 50%;
    width: 73%;
    height: auto;
    transform: translateX(-50%);
  }

  .code {
    margin: 0 0 20px;
    color: #527986;
    font-family: 'Arial Rounded MT Bold', 'Trebuchet MS', sans-serif;
    font-size: clamp(84px, 8vw, 112px);
    font-weight: 800;
    letter-spacing: 4px;
    line-height: 1;
  }

  .message {
    margin: 0;
    color: #293f4a;
    font-size: clamp(23px, 2.2vw, 28px);
    font-weight: 600;
    line-height: 1.6;
    letter-spacing: .2px;
  }

  .message span {
    display: block;
  }

  .home-button {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    min-width: 148px;
    height: 46px;
    margin-top: 32px;
    padding-inline: 24px;
    border: 0;
    border-radius: 10px;
    background: #5c33e3;
    color: #fff;
    font-size: 15px;
    font-weight: 500;
    box-shadow: 0 5px 12px rgba(92, 51, 227, .12);
    transition: background-color .2s, box-shadow .2s;
  }

  .home-button:hover {
    background: #7048ed;
    color: #fff;
  }

  .home-button:focus-visible {
    background: #7048ed;
    box-shadow: 0 0 0 4px #f6f7f9, 0 0 0 7px #8a6bec;
  }

  .lost-jelly {
    animation: jelly-drift 5s ease-in-out infinite;
  }

  .lost-jelly-small {
    animation-duration: 6s;
    animation-delay: -2s;
  }

  @keyframes jelly-drift {
    0%, 100% {
      transform: translateY(0);
    }
    50% {
      transform: translateY(-9px);
    }
  }

  @media (max-width: 760px) {
    .not-found {
      padding: 32px 24px 48px;
    }

    .not-found-content {
      grid-template-columns: minmax(0, 1fr);
      justify-items: center;
      gap: 8px;
      max-width: 440px;
      text-align: center;
    }

    .ocean-scene {
      width: min(100%, 360px);
    }

    .code {
      margin-bottom: 12px;
      font-size: 72px;
    }

    .message {
      font-size: clamp(20px, 5.4vw, 24px);
    }

    .home-button {
      margin-top: 24px;
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .lost-jelly {
      animation: none;
    }

    .home-button {
      transition: none;
    }
  }
</style>
