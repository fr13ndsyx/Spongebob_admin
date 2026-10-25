<template>
  <main class="login-page">
    <div class="login-shell">
      <section class="character-panel" aria-label="欢迎登录">
        <div class="character-scene">
          <AnimatedCharacters :is-typing="isTyping" :has-secret="loginForm.password.length > 0" :secret-visible="showPassword" />
        </div>
        <div class="character-caption">
          <h2>嗨，海绵宝宝，我们去抓水母吧。</h2>
          <p>对不起，今天不行，我要上班。</p>
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
  import { onMounted, onUnmounted, reactive, ref } from 'vue';
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
    display: flex;
    flex-direction: column;
    min-width: 0;
    padding: 36px 36px 44px;
    background: #edf0f4;
  }

  .character-scene {
    display: flex;
    align-items: flex-end;
    flex: 1;
    min-height: 430px;
    padding-bottom: 20px;
  }

  .character-caption {
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
