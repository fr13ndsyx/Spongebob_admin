<template>
  <main class="login-page">
    <div class="login-shell">
      <section class="character-panel" aria-label="欢迎登录">
        <div class="jellies" aria-hidden="true">
          <div v-for="index in 6" :key="index" class="jelly" :class="'jelly-' + index">
            <svg class="jelly-shape" viewBox="0 0 120 168" fill="none" focusable="false">
              <defs>
                <radialGradient :id="jellyId + '-cap-' + index" cx=".32" cy=".22" r=".85">
                  <stop stop-color="#fff3fa" stop-opacity=".96" />
                  <stop offset=".5" stop-color="#f6c4e0" stop-opacity=".88" />
                  <stop offset="1" stop-color="#df91bd" stop-opacity=".92" />
                </radialGradient>
                <linearGradient :id="jellyId + '-ribbon-' + index" x1="0" y1="0" x2="0" y2="1">
                  <stop stop-color="#d98bb8" />
                  <stop offset="1" stop-color="#e9b7d5" stop-opacity=".45" />
                </linearGradient>
              </defs>
              <g class="jelly-tentacles" stroke-linecap="round">
                <g stroke="#ce8bb4" stroke-width="2" opacity=".7">
                  <path class="jelly-tendril" d="M29 64 C21 84 37 94 26 112 S22 140 27 145" />
                  <path class="jelly-tendril jelly-tendril-late" d="M91 64 C100 85 83 98 94 116 S99 137 93 144" />
                </g>
                <g :stroke="'url(#' + jellyId + '-ribbon-' + index + ')'" stroke-width="5">
                  <path class="jelly-tendril" d="M42 66 C30 88 53 97 39 121 S43 147 37 154" />
                  <path class="jelly-tendril jelly-tendril-late" d="M60 68 C73 91 48 105 61 127 S67 150 60 158" />
                  <path class="jelly-tendril" d="M79 66 C91 87 68 100 81 120 S77 143 83 150" />
                </g>
              </g>
              <g class="jelly-bell">
                <path d="M20 60 C25 48 95 48 100 60 L102 69 C98 77 90 72 86 74 C81 82 74 76 69 77 C63 84 56 79 51 77 C44 81 38 76 34 74 C26 78 18 72 18 67Z" fill="#e9acd0" stroke="#bb7c9e" stroke-width="1.6" />
                <ellipse cx="60" cy="64" rx="37" ry="8" fill="#c983af" opacity=".35" />
                <path d="M18 61 C18 34 35 15 58 14 C82 12 102 32 102 60 C102 67 94 68 88 65 C82 73 73 68 68 67 C62 74 54 70 49 67 C41 72 33 68 29 64 C23 67 18 66 18 61Z" :fill="'url(#' + jellyId + '-cap-' + index + ')'" stroke="#bb7c9e" stroke-width="1.8" stroke-linejoin="round" />
                <path d="M28 42 C31 30 41 23 52 22" stroke="#fff9fd" stroke-width="4.5" stroke-linecap="round" opacity=".85" />
                <ellipse cx="66" cy="23" rx="5" ry="3" fill="#fff9fd" opacity=".7" transform="rotate(12 66 23)" />
                <g fill="#c67ba8" opacity=".52">
                  <ellipse cx="46" cy="34" rx="4.5" ry="3" transform="rotate(-20 46 34)" />
                  <ellipse cx="77" cy="32" rx="5" ry="3.5" transform="rotate(25 77 32)" />
                  <circle cx="87" cy="43" r="2.5" />
                  <circle cx="58" cy="28" r="2" />
                </g>
                <g fill="#885b78">
                  <ellipse cx="46" cy="51" rx="2.4" ry="3.5" />
                  <ellipse cx="74" cy="51" rx="2.4" ry="3.5" />
                </g>
                <g fill="#fff7fc">
                  <circle cx="45.3" cy="49.8" r=".8" />
                  <circle cx="73.3" cy="49.8" r=".8" />
                </g>
                <g fill="#df8eb7" opacity=".55">
                  <ellipse cx="37" cy="57" rx="5" ry="2.5" />
                  <ellipse cx="83" cy="57" rx="5" ry="2.5" />
                </g>
                <path d="M55 57 Q60 62 65 57" stroke="#a5658b" stroke-width="1.6" stroke-linecap="round" />
              </g>
            </svg>
          </div>
        </div>
        <div class="character-scene">
          <AnimatedCharacters :is-typing="isTyping" :has-secret="loginForm.password.length > 0" :secret-visible="showPassword" />
        </div>
        <div class="character-caption">
          <h2>嗨，海绵宝宝，我们去抓水母吧。</h2>
          <p>派大星，今天不行，我要上班。</p>
        </div>
      </section>

      <section class="form-panel" aria-labelledby="login-title">
        <div class="form-content">
          <h1 id="login-title">欢迎回来</h1>
          <a-form
            ref="formRef"
            class="login-form"
            layout="vertical"
            :model="loginForm"
            :rules="rules"
            @focusin="onInputFocus"
            @focusout="onInputBlur"
            @finish="onLogin"
          >
            <a-form-item label="账号" name="loginName">
              <a-input v-model:value.trim="loginForm.loginName" placeholder="请输入用户名" autocomplete="username" />
            </a-form-item>
            <a-form-item label="密码" name="password">
              <a-input v-model:value="loginForm.password" :type="showPassword ? 'text' : 'password'" placeholder="请输入密码" autocomplete="current-password">
                <template #suffix>
                  <button
                    type="button"
                    class="password-toggle"
                    tabindex="-1"
                    :aria-label="showPassword ? '隐藏密码' : '显示密码'"
                    :aria-pressed="showPassword"
                    @mousedown.prevent
                    @click="togglePassword"
                  >
                    <EyeOutlined v-if="showPassword" />
                    <EyeInvisibleOutlined v-else />
                  </button>
                </template>
              </a-input>
            </a-form-item>
            <a-form-item v-if="emailCodeShowFlag" label="邮箱验证码" name="emailCode">
              <div class="verification-row">
                <a-input v-model:value.trim="loginForm.emailCode" autocomplete="one-time-code" placeholder="请输入邮箱验证码" />
                <a-button class="email-code-button" :disabled="emailCodeButtonDisabled" @click="sendSmsCode">{{ emailCodeTips }}</a-button>
              </div>
            </a-form-item>
            <a-form-item label="图形验证码" name="captchaCode">
              <div class="verification-row">
                <a-input v-model:value.trim="loginForm.captchaCode" placeholder="请输入验证码" autocomplete="off" />
                <button class="captcha-button" type="button" aria-label="刷新图形验证码" @click="getCaptcha">
                  <img v-if="captchaBase64Image" :src="captchaBase64Image" alt="图形验证码" />
                  <span v-else>刷新验证码</span>
                </button>
              </div>
            </a-form-item>
            <a-button class="login-button" type="primary" html-type="submit" :loading="isSubmitting">登录</a-button>
          </a-form>
        </div>
      </section>
    </div>
  </main>
</template>

<script setup lang="ts">
  import { message } from 'ant-design-vue';
  import type { FormInstance } from 'ant-design-vue';
  import { EyeInvisibleOutlined, EyeOutlined } from '@ant-design/icons-vue';
  import { onMounted, onUnmounted, reactive, ref, useId } from 'vue';
  import { useRouter } from 'vue-router';
  import AnimatedCharacters from './AnimatedCharacters.vue';
  import { loginApi } from '/@/api/system/login-api';
  import { Loading } from '/@/components/framework/loading';
  import { LOGIN_DEVICE_ENUM } from '/@/constants/system/login-device-const';
  import { useUserStore } from '/@/store/modules/system/user';
  import { buildRoutes } from '/@/router/index';
  import { sentry } from '/@/lib/sentry';
  import { encryptData } from '/@/lib/encrypt';
  import { localSave } from '/@/utils/local-util';
  import LocalStorageKeyConst from '/@/constants/local-storage-key-const';
  import { useDictStore } from '/@/store/modules/system/dict';
  import { dictApi } from '/@/api/support/dict-api';
  const jellyId = useId();

  const SECOND_MS = 1000;
  const CAPTCHA_REFRESH_BUFFER_SECONDS = 5;
  const EMAIL_CODE_WAIT_SECONDS = 60;
  const loginForm = reactive({
    loginName: 'admin',
    password: '',
    emailCode: '',
    captchaCode: '',
    captchaUuid: '',
    loginDevice: LOGIN_DEVICE_ENUM.PC.value,
  });
  const rules = {
    loginName: [{ required: true, message: '请输入用户名' }],
    password: [{ required: true, message: '请输入密码' }],
    emailCode: [{ required: true, message: '请输入邮箱验证码' }],
    captchaCode: [{ required: true, message: '请输入图形验证码' }],
  };
  const router = useRouter();
  const formRef = ref<FormInstance>();
  const isTyping = ref(false);
  const showPassword = ref(false);
  const isSubmitting = ref(false);
  const captchaBase64Image = ref('');
  const emailCodeShowFlag = ref(false);
  const emailCodeTips = ref('获取验证码');
  const emailCodeButtonDisabled = ref(false);
  let refreshCaptchaTimer: number | undefined;
  let countDownTimer: number | undefined;
  let active = true;

  function onInputFocus(event: FocusEvent): void {
    isTyping.value = event.target instanceof HTMLInputElement;
  }

  function onInputBlur(event: FocusEvent): void {
    const next = event.relatedTarget;
    isTyping.value = next instanceof HTMLInputElement && event.currentTarget instanceof HTMLElement && event.currentTarget.contains(next);
  }

  function togglePassword(): void {
    showPassword.value = !showPassword.value;
  }

  async function onLogin(): Promise<void> {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    try {
      Loading.show();
      const encryptedForm = { ...loginForm, password: await encryptData(loginForm.password) };
      const res = await loginApi.login(encryptedForm);
      stopRefreshCaptchaTimer();
      localSave(LocalStorageKeyConst.USER_TOKEN, res.data.token || '');
      message.success('登录成功');
      useUserStore().setUserLoginInfo(res.data);
      const dictRes = await dictApi.getAllDictData();
      useDictStore().initData(dictRes.data);
      buildRoutes(useUserStore().getMenuRouterList);
      await router.push('/home');
    } catch (error) {
      loginForm.captchaCode = '';
      await getCaptcha();
      sentry.captureError(error);
    } finally {
      isSubmitting.value = false;
      Loading.hide();
    }
  }

  function stopRefreshCaptchaTimer(): void {
    window.clearTimeout(refreshCaptchaTimer);
    refreshCaptchaTimer = undefined;
  }

  async function getCaptcha(): Promise<void> {
    try {
      const result = await loginApi.getCaptcha();
      if (!active) return;
      captchaBase64Image.value = result.data.captchaBase64Image;
      loginForm.captchaUuid = result.data.captchaUuid;
      stopRefreshCaptchaTimer();
      const delay = Math.max(1, result.data.expireSeconds - CAPTCHA_REFRESH_BUFFER_SECONDS) * SECOND_MS;
      refreshCaptchaTimer = window.setTimeout(() => { void getCaptcha(); }, delay);
    } catch (error) {
      sentry.captureError(error);
    }
  }

  function runCountDown(): void {
    window.clearInterval(countDownTimer);
    emailCodeButtonDisabled.value = true;
    let remaining = EMAIL_CODE_WAIT_SECONDS;
    emailCodeTips.value = `${remaining}秒后重试`;
    countDownTimer = window.setInterval(() => {
      remaining--;
      if (remaining > 0) {
        emailCodeTips.value = `${remaining}秒后重试`;
      } else {
        window.clearInterval(countDownTimer);
        countDownTimer = undefined;
        emailCodeButtonDisabled.value = false;
        emailCodeTips.value = '获取验证码';
      }
    }, SECOND_MS);
  }

  async function getTwoFactorLoginFlag(): Promise<void> {
    try {
      const result = await loginApi.getTwoFactorLoginFlag();
      if (active) emailCodeShowFlag.value = result.data;
    } catch (error) {
      sentry.captureError(error);
    }
  }

  async function sendSmsCode(): Promise<void> {
    if (emailCodeButtonDisabled.value) return;
    try {
      await formRef.value?.validateFields(['loginName']);
    } catch {
      return;
    }
    try {
      Loading.show();
      await loginApi.sendLoginEmailCode(loginForm.loginName);
      if (!active) return;
      message.success('验证码已发送，请查看邮箱');
      runCountDown();
    } catch (error) {
      sentry.captureError(error);
    } finally {
      Loading.hide();
    }
  }

  onMounted(() => {
    void getCaptcha();
    void getTwoFactorLoginFlag();
  });

  onUnmounted(() => {
    active = false;
    stopRefreshCaptchaTimer();
    window.clearInterval(countDownTimer);
  });
</script>

<style scoped>
  .login-page {
    display: grid;
    place-items: center;
    min-height: 100vh;
    min-height: 100dvh;
    padding: 40px 24px;
    background: #f6f7f9;
    color: #252525;
    font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
  }

  .login-shell {
    display: grid;
    grid-template-columns: 1.2fr 1fr;
    width: min(100%, 1080px);
    min-height: 690px;
    background: white;
    border-radius: 24px;
    overflow: hidden;
    box-shadow: 0 24px 80px rgba(28, 32, 44, .08);
  }

  .character-panel {
    position: relative;
    display: flex;
    flex-direction: column;
    min-width: 0;
    padding: 36px 36px 44px;
    background: #edf0f4;
    overflow: hidden;
  }

  .jellies {
    position: absolute;
    inset: 0 0 136px;
    z-index: 0;
    overflow: hidden;
    pointer-events: none;
    mask-image: linear-gradient(transparent, #000 10%, #000 85%, transparent);
  }

  .jelly {
    --jelly-opacity: .8;
    --jelly-sway-duration: 4s;
    position: absolute;
    top: 100%;
    opacity: 0;
    animation: jelly-swim 24s linear infinite;
  }

  .jelly-shape {
    display: block;
    width: 100%;
    height: auto;
    overflow: visible;
    animation: jelly-sway var(--jelly-sway-duration) ease-in-out infinite;
  }

  .jelly-bell {
    transform-origin: 60px 66px;
    animation: jelly-pulse var(--jelly-sway-duration) ease-in-out infinite;
  }

  .jelly-tendril {
    transform-origin: 60px 66px;
    animation: jelly-tendril 3.6s ease-in-out infinite;
  }

  .jelly-tendril-late {
    animation-delay: -1.8s;
    animation-duration: 4.2s;
  }

  .jelly-1 {
    width: 112px;
    left: 78%;
    animation-duration: 24s;
    animation-delay: -8s;
  }

  .jelly-2 {
    --jelly-sway-duration: 4.6s;
    width: 84px;
    left: 3%;
    animation-duration: 28s;
    animation-delay: -16s;
  }

  .jelly-3 {
    --jelly-opacity: .55;
    width: 60px;
    left: 65%;
    animation-duration: 32s;
    animation-delay: -26s;
  }

  .jelly-4 {
    --jelly-sway-duration: 3.8s;
    width: 76px;
    left: 12%;
    animation-duration: 26s;
    animation-delay: -4s;
  }

  .jelly-5 {
    --jelly-opacity: .5;
    width: 52px;
    left: 45%;
    animation-duration: 30s;
    animation-delay: -21s;
  }

  .jelly-6 {
    --jelly-opacity: .65;
    --jelly-sway-duration: 4.8s;
    width: 66px;
    left: 31%;
    animation-duration: 34s;
    animation-delay: -14s;
  }

  .jelly-3 .jelly-shape,
  .jelly-6 .jelly-shape {
    filter: hue-rotate(16deg);
  }

  @keyframes jelly-swim {
    0% {
      transform: translate(0, 0);
      opacity: 0;
    }
    12%, 78% {
      opacity: var(--jelly-opacity);
    }
    100% {
      transform: translate(-14px, -720px);
      opacity: 0;
    }
  }

  @keyframes jelly-sway {
    0%, 100% {
      transform: translateX(-5px) rotate(-5deg);
    }
    50% {
      transform: translateX(5px) rotate(5deg);
    }
  }

  @keyframes jelly-pulse {
    0%, 100% {
      transform: scale(1, 1);
    }
    45% {
      transform: scale(1.035, .94);
    }
  }

  @keyframes jelly-tendril {
    0%, 100% {
      transform: skewX(-5deg);
    }
    50% {
      transform: skewX(6deg);
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .jelly {
      top: 24%;
      opacity: var(--jelly-opacity);
      animation: none;
    }

    .jelly-shape,
    .jelly-bell,
    .jelly-tendril {
      animation: none;
    }

    .jelly-2 {
      top: 8%;
    }

    .jelly-3,
    .jelly-4,
    .jelly-5,
    .jelly-6 {
      display: none;
    }
  }

  .character-scene {
    position: relative;
    z-index: 1;
    display: flex;
    align-items: flex-end;
    flex: 1;
    min-height: 430px;
    padding-bottom: 20px;
  }

  .character-caption {
    position: relative;
    z-index: 1;
    margin-top: 28px;
  }

  .character-caption h2 {
    margin: 0 0 10px;
    font-size: 25px;
    font-weight: 600;
    letter-spacing: -.5px;
  }

  .character-caption p,
  .form-description {
    margin: 0;
    color: #757980;
    font-size: 14px;
    line-height: 1.7;
  }

  .form-panel {
    display: grid;
    align-items: center;
    padding: 56px 48px;
  }

  .form-content {
    width: 100%;
    max-width: 360px;
    margin-inline: auto;
  }

  h1 {
    margin: 0 0 10px;
    font-size: 32px;
    font-weight: 650;
    letter-spacing: -1px;
  }

  .login-form {
    margin-top: 36px;
  }

  .login-form :deep(.ant-form-item) {
    margin-bottom: 22px;
  }

  .login-form :deep(.ant-form-item-label > label) {
    color: #42454b;
    font-size: 13px;
    font-weight: 500;
  }

  .login-form :deep(.ant-input),
  .login-form :deep(.ant-input-affix-wrapper) {
    min-height: 48px;
    border-color: #dde0e6;
    border-radius: 9px;
    background: white;
    color: #252525;
    font-size: 14px;
  }

  .login-form :deep(.ant-input-affix-wrapper .ant-input) {
    min-height: 0;
  }

  .login-form :deep(.ant-input:hover),
  .login-form :deep(.ant-input-affix-wrapper:hover),
  .login-form :deep(.ant-input:focus),
  .login-form :deep(.ant-input-affix-wrapper-focused) {
    border-color: #7a54ff;
  }

  .login-form :deep(input:autofill),
  .login-form :deep(input:-webkit-autofill) {
    box-shadow: 0 0 0 1000px #fff inset !important;
    -webkit-text-fill-color: #252525;
    caret-color: #252525;
  }

  .password-toggle {
    display: grid;
    place-items: center;
    width: 28px;
    height: 28px;
    padding: 0;
    border: 0;
    border-radius: 4px;
    background: transparent;
    color: #858991;
    font-size: 18px;
    cursor: pointer;
  }

  .verification-row {
    display: flex;
    gap: 12px;
  }

  .verification-row :deep(.ant-input) {
    flex: 1;
    min-width: 0;
  }

  .captcha-button,
  .email-code-button {
    display: grid;
    place-items: center;
    flex: none;
    width: 126px;
    height: 48px;
    padding: 0;
    border: 1px solid #dde0e6;
    border-radius: 9px;
    background: #f7f8fa;
    color: #575b63;
    font-size: 12px;
    cursor: pointer;
    overflow: hidden;
  }

  .captcha-button img {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }

  .login-button {
    width: 100%;
    height: 48px;
    margin-top: 8px;
    border: 0;
    border-radius: 9px;
    background: #5c33e3;
    color: white;
    font-size: 15px;
    font-weight: 600;
    box-shadow: none;
  }

  .login-button:hover,
  .login-button:focus {
    background: #7048ed;
    color: white;
  }

  .password-toggle:focus-visible,
  .captcha-button:focus-visible,
  .login-button:focus-visible {
    outline: 2px solid #7a54ff;
    outline-offset: 4px;
  }

  .form-footer {
    margin: 28px 0 0;
    color: #858991;
    text-align: center;
    font-size: 12px;
  }

</style>
