<template>
  <svg ref="scene" class="characters" viewBox="0 0 520 450" aria-hidden="true" focusable="false" :data-mode="hiding ? 'hiding' : leaning ? 'leaning' : 'tracking'">
    <defs>
      <linearGradient :id="`${artId}-sponge`" x1="0" y1="0" x2=".85" y2="1"><stop stop-color="#fff07d"/><stop offset="1" stop-color="#ffd34c"/></linearGradient>
      <linearGradient :id="`${artId}-star`" x1="0" y1="0" x2=".9" y2="1"><stop stop-color="#ffbaa9"/><stop offset="1" stop-color="#f58d91"/></linearGradient>
      <linearGradient :id="`${artId}-shorts`" x2="0" y2="1"><stop stop-color="#c6e989"/><stop offset="1" stop-color="#9ed068"/></linearGradient>
      <path :id="`${artId}-patrick-arm`" d="M8 -7 C-18 -17 -54 -15 -78 -5 C-88 0 -87 9 -77 14 C-52 22 -18 20 8 7" :fill="`url(#${artId}-star)`"/>
      <g :id="`${artId}-sponge-arm`" fill="#ffe16b">
        <path d="M0 0 C-10 -28 28 -34 51 -54" fill="none" stroke="#745033" stroke-width="7" vector-effect="non-scaling-stroke"/>
        <path d="M0 0 C-10 -28 28 -34 51 -54" fill="none" stroke="#ffe16b" stroke-width="4" vector-effect="non-scaling-stroke"/>
      </g>
      <g :id="`${artId}-sponge-hand`" fill="#ffe16b">
        <path d="M46 -52 L42 -60 Q39 -65 42 -70 L43 -75 Q45 -80 50 -76 Q52 -82 57 -77 Q60 -81 64 -76 Q69 -78 70 -72 L72 -63 Q70 -55 62 -52 L55 -49Z"/>
        <path d="M50 -74 L50 -66 M57 -75 L57 -66 M64 -74 L64 -66 M44 -61 Q50 -57 56 -62" fill="none" stroke="#b58a35" stroke-width="1.8"/>
      </g>
      <clipPath :id="`${artId}-net-mesh`"><path d="M15 67 Q53 35 86 69 Q93 112 58 140 Q20 132 15 67Z"/></clipPath>
    </defs>
    <ellipse class="ground" cx="271" cy="420" rx="177" ry="14" opacity=".6"/>
    <g class="character-float patrick-float">
      <g class="pose patrick-pose" stroke="#794950" stroke-width="3" stroke-linejoin="round" stroke-linecap="round">
        <path d="M281 346 Q281 384 289 408 Q295 422 309 413 L334 382 L352 382 Q368 415 384 412 Q398 408 392 384 L384 340Z" :fill="`url(#${artId}-star)`"/>
        <path class="patrick-body" d="M278 213 C295 180 306 132 320 102 Q330 80 341 102 C353 126 360 170 376 210 C389 238 414 303 408 337 Q401 365 346 370 Q286 372 270 342 Q259 315 270 268Z" :fill="`url(#${artId}-star)`"/>
        <path d="M328 111 Q337 107 342 131" fill="none" stroke="#ffd5c3" stroke-width="5"/>
        <path d="M272 315 Q340 336 409 314 L410 344 Q405 363 380 372 L352 366 Q337 375 316 374 L285 362 Q274 350 272 315Z" :fill="`url(#${artId}-shorts)`"/>
        <g fill="#aa7db7" stroke="none">
          <path d="M291 325 C281 311 274 324 284 331 C267 330 269 346 285 343 C280 356 294 361 298 348 C310 357 319 345 305 338 C318 329 309 320 299 330Z"/>
          <path d="M373 334 C361 321 353 334 366 341 C350 341 352 354 367 352 C361 366 376 369 379 356 C390 367 402 355 388 349 C404 342 393 328 384 339Z"/>
        </g>
        <path d="M327 282 Q333 288 338 282 M332 289 L332 292" fill="none" stroke="#bf7477" stroke-width="2.5"/>
        <g class="blink patrick-eyes" fill="#fffef7">
          <ellipse cx="320" cy="190" rx="18" ry="26" transform="rotate(9 320 190)"/><ellipse cx="349" cy="188" rx="18" ry="26" transform="rotate(-7 349 188)"/>
          <g class="pupil" :transform="pupilTransform(PATRICK_PUPIL_TRAVEL)" fill="#493b42" stroke="none"><ellipse cx="325" cy="193" rx="5" ry="7"/><ellipse cx="345" cy="191" rx="5" ry="7"/><circle cx="326" cy="190" r="1.6" fill="#fff"/><circle cx="346" cy="188" r="1.6" fill="#fff"/></g>
        </g>
        <path class="closed-eyes" d="M306 190 Q320 201 334 190 M336 188 Q349 199 362 188" fill="none"/>
        <path d="M306 158 L319 155 M347 153 L359 157" fill="none" stroke-width="4"/>
        <ellipse cx="298" cy="222" rx="12" ry="7" fill="#ef7f8c" opacity=".6" stroke="none"/><ellipse cx="372" cy="219" rx="12" ry="7" fill="#ef7f8c" opacity=".6" stroke="none"/>
        <path d="M310 226 Q334 241 363 224 Q352 253 335 250 Q319 248 310 226Z" fill="#7f4653"/>
        <path d="M325 245 Q336 235 350 243 Q337 253 325 245Z" fill="#f797a2" stroke="none"/>
        <g transform="translate(293 246)">
          <g class="arm patrick-arm"><use :href="`#${artId}-patrick-arm`"/></g>
        </g>
        <g transform="translate(374 246) scale(-1 1)">
          <g class="arm patrick-arm"><use :href="`#${artId}-patrick-arm`"/></g>
        </g>
      </g>
    </g>
    <g class="character-float sponge-float">
      <g class="pose sponge-pose" stroke="#745033" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
        <g class="fishing-net">
          <path d="M15 67 Q53 35 86 69 Q93 112 58 140 Q20 132 15 67Z" fill="#e4f3ee" fill-opacity=".6" stroke="#94b9b1" stroke-width="2"/>
          <g :clip-path="`url(#${artId}-net-mesh)`" fill="none" stroke="#94b9b1" stroke-width="1.2" opacity=".85">
            <path d="M-5 65 L86 148 M-5 45 L106 148 M15 45 L106 128 M35 45 L106 108 M55 45 L106 88 M-5 85 L66 148 M-5 105 L46 148"/>
            <path d="M105 65 L14 148 M105 45 L-6 148 M85 45 L-6 128 M65 45 L-6 108 M45 45 L-6 88 M105 85 L34 148 M105 105 L54 148"/>
          </g>
          <path d="M86 87 L99 100 H288" fill="none" stroke="#745033" stroke-width="9"/>
          <path d="M86 87 L99 100 H288" fill="none" stroke="#cfaa70" stroke-width="5"/>
          <ellipse cx="51" cy="70" rx="40" ry="24" transform="rotate(25 51 70)" fill="#edf5f2" fill-opacity=".35" stroke="#6c8e89" stroke-width="6"/>
          <ellipse cx="51" cy="70" rx="40" ry="24" transform="rotate(25 51 70)" fill="none" stroke="#bad6ce" stroke-width="2"/>
          <path d="M102 97 V103 M108 97 V103 M114 97 V103" stroke="#a48153" stroke-width="1.5"/>
        </g>
        <g fill="#ffe272">
          <path d="M155 353 L152 391 L166 393 L170 353Z"/><path d="M219 354 L225 393 L239 391 L235 353Z"/>
          <path d="M153 379 L151 401 L166 402 L167 380Z" fill="#fffef8"/><path d="M223 379 L226 402 L241 399 L237 378Z" fill="#fffef8"/>
          <path d="M153 385 L166 386 M225 385 L238 384" stroke="#e5736b" stroke-width="2"/><path d="M153 390 L165 391 M226 390 L239 389" stroke="#5c9fb7" stroke-width="2"/>
        </g>
        <path d="M151 399 Q140 392 130 401 Q117 410 130 416 L164 417 Q174 415 170 403 L165 398Z" fill="#494044"/><path d="M227 400 Q238 394 247 400 Q260 397 265 407 Q270 417 254 418 L229 416 Q219 414 222 404Z" fill="#494044"/>
        <path d="M132 412 L163 412 M232 412 L257 412" stroke="#756267" stroke-width="2"/>
        <path d="M112 248 Q94 244 92 261 L109 274 L123 259Z M273 246 Q290 243 295 257 L281 270 L266 258Z" fill="#fffdf5"/>
        <path d="M114 289 L277 289 L272 352 Q236 362 196 357 Q151 361 116 350Z" fill="#aa7551"/>
        <path d="M124 340 Q196 350 264 342" fill="none" stroke="#c58d62" stroke-width="5"/>
        <path d="M112 283 L279 283 L278 310 L113 307Z" fill="#fffdf5"/>
        <path d="M163 291 L185 306 L197 290 L210 307 L232 291" fill="#fffdf5"/>
        <path d="M190 300 L203 300 L206 309 L198 318 L188 310Z M198 317 L186 338 L200 349 L212 335Z" fill="#ed6e56"/>
        <path d="M128 319 L148 320 M164 320 L178 320 M220 321 L234 320 M249 320 L265 319" stroke="#654c3c" stroke-width="5"/>
        <path d="M113 139 Q124 130 137 136 Q151 128 164 135 Q179 128 193 135 Q210 128 224 135 Q239 128 252 135 Q266 130 276 140 Q283 153 277 167 Q285 179 279 193 Q285 207 279 221 Q286 235 279 248 Q284 267 276 283 Q262 292 248 286 Q234 294 220 287 Q205 294 191 288 Q175 295 161 288 Q146 294 134 287 Q119 291 109 281 Q103 269 109 254 Q101 240 108 225 Q101 211 107 197 Q101 183 108 169 Q102 152 113 139Z" :fill="`url(#${artId}-sponge)`"/>
        <path d="M120 146 Q133 140 145 145 M167 143 Q180 138 190 143 M221 144 Q236 139 247 144" fill="none" stroke="#fff4af" stroke-width="5"/>
        <g fill="#dfb743" stroke="#c9a03a" stroke-width="1.3" opacity=".8">
          <ellipse cx="120" cy="162" rx="6" ry="9" transform="rotate(25 120 162)"/><ellipse cx="263" cy="154" rx="7" ry="5"/><ellipse cx="118" cy="212" rx="4" ry="6"/><ellipse cx="267" cy="222" rx="4" ry="6"/><ellipse cx="125" cy="269" rx="9" ry="6" transform="rotate(20 125 269)"/><ellipse cx="259" cy="272" rx="7" ry="9" transform="rotate(-20 259 272)"/><ellipse cx="148" cy="280" rx="3" ry="2"/><ellipse cx="242" cy="149" rx="3" ry="2"/>
        </g>
        <path class="sponge-lashes" d="M149 163 L145 154 M161 159 L162 148 M173 163 L178 154 M218 162 L214 152 M231 158 L232 147 M243 162 L249 153" stroke="#594532" stroke-width="4"/>
        <g class="blink sponge-eyes" fill="#fffefa">
          <ellipse cx="163" cy="190" rx="30" ry="33"/><ellipse cx="230" cy="189" rx="30" ry="33"/>
          <g class="pupil" :transform="pupilTransform(SPONGE_PUPIL_TRAVEL)">
            <ellipse cx="169" cy="193" rx="13" ry="16" fill="#75c9e7" stroke="#4e777e" stroke-width="2"/><ellipse cx="224" cy="192" rx="13" ry="16" fill="#75c9e7" stroke="#4e777e" stroke-width="2"/>
            <ellipse cx="170" cy="194" rx="6.5" ry="10" fill="#39464d" stroke="none"/><ellipse cx="223" cy="193" rx="6.5" ry="10" fill="#39464d" stroke="none"/>
            <circle cx="173" cy="188" r="3.5" fill="#fff" stroke="none"/><circle cx="226" cy="187" r="3.5" fill="#fff" stroke="none"/>
          </g>
        </g>
        <path class="closed-eyes" d="M143 190 Q163 203 184 190 M210 189 Q230 202 250 189" fill="none"/>
        <ellipse cx="137" cy="229" rx="17" ry="10" fill="#f49a77" opacity=".6" stroke="none"/><ellipse cx="254" cy="228" rx="16" ry="10" fill="#f49a77" opacity=".6" stroke="none"/>
        <g fill="#ce7955" stroke="none"><circle cx="131" cy="226" r="2"/><circle cx="140" cy="224" r="2"/><circle cx="136" cy="232" r="2"/><circle cx="250" cy="224" r="2"/><circle cx="258" cy="226" r="2"/><circle cx="253" cy="232" r="2"/></g>
        <path d="M146 237 Q193 260 246 235 Q233 275 196 275 Q163 275 146 237Z" fill="#96543d"/>
        <path d="M179 271 Q193 255 216 270 Q197 279 179 271Z" fill="#e98d75" stroke="none"/>
        <path d="M179 248 L179 261 Q187 265 194 262 L194 251 M200 251 L201 263 Q210 266 217 261 L216 248" fill="#fffef7" stroke-width="2"/>
        <path d="M139 235 Q144 231 150 234 M241 233 Q248 229 253 234" fill="none" stroke-width="2.5"/>
        <path d="M191 216 C185 194 202 192 205 206 L207 222 Q201 231 191 224" fill="#ffe479"/>
        <g transform="translate(106 259)">
          <g class="arm sponge-arm"><use :href="`#${artId}-sponge-arm`"/><use class="sponge-palm" :href="`#${artId}-sponge-hand`"/></g>
        </g>
        <g transform="translate(284 259) scale(-1 1)">
          <g class="arm sponge-arm"><use :href="`#${artId}-sponge-arm`"/><use class="sponge-palm" :href="`#${artId}-sponge-hand`"/></g>
        </g>
      </g>
    </g>
  </svg>
</template>

<script setup lang="ts">
  import { computed, onMounted, onUnmounted, ref, useId } from 'vue';

  const props = defineProps<{ isTyping: boolean; hasSecret: boolean; secretVisible: boolean }>();
  const PATRICK_PUPIL_TRAVEL = 5;
  const SPONGE_PUPIL_TRAVEL = 6;
  const artId = useId();
  const scene = ref<SVGSVGElement | null>(null);
  const gaze = ref({ x: 0, y: 0 });
  const reducedMotion = ref(false);
  const hiding = computed(() => props.hasSecret && props.secretVisible);
  const leaning = computed(() => props.isTyping || (props.hasSecret && !props.secretVisible));
  let motionQuery: MediaQueryList | undefined;

  function resetGaze(): void {
    gaze.value = { x: 0, y: 0 };
  }

  function updateMotionPreference(): void {
    reducedMotion.value = motionQuery?.matches ?? false;
    resetGaze();
  }

  function trackMouse(event: MouseEvent): void {
    if (reducedMotion.value || hiding.value) return;
    const bounds = scene.value?.getBoundingClientRect();
    if (!bounds?.width || !bounds.height) {
      resetGaze();
      return;
    }
    gaze.value = {
      x: Math.max(-1, Math.min(1, (event.clientX - bounds.left - bounds.width / 2) / (bounds.width / 2))),
      y: Math.max(-1, Math.min(1, (event.clientY - bounds.top - bounds.height / 2) / (bounds.height / 2))),
    };
  }

  function pupilTransform(travel: number): string {
    const offset = reducedMotion.value || hiding.value ? { x: 0, y: 0 } : gaze.value;
    return `translate(${offset.x * travel} ${offset.y * travel})`;
  }

  onMounted(() => {
    motionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    updateMotionPreference();
    motionQuery.addEventListener('change', updateMotionPreference);
    window.addEventListener('mousemove', trackMouse, { passive: true });
    window.addEventListener('blur', resetGaze);
  });

  onUnmounted(() => {
    motionQuery?.removeEventListener('change', updateMotionPreference);
    window.removeEventListener('mousemove', trackMouse);
    window.removeEventListener('blur', resetGaze);
  });
</script>

<style scoped>
  .characters {
    display: block;
    width: min(100%, 520px);
    height: auto;
    margin-inline: auto;
    overflow: visible;
  }

  .ground {
    fill: #cad4db;
  }

  .character-float,
  .pose,
  .blink {
    transform-box: fill-box;
    transform-origin: center bottom;
  }

  .character-float {
    animation: character-breathe 5s ease-in-out infinite;
  }

  .patrick-float {
    animation-delay: -2.1s;
  }

  .pose {
    transition: transform .5s cubic-bezier(.2, .75, .25, 1);
  }

  .characters[data-mode='leaning'] .sponge-pose {
    transform: rotate(3deg) translateX(3px);
  }

  .characters[data-mode='leaning'] .patrick-pose {
    transform: rotate(-3deg) translateY(-4px);
  }

  .blink {
    transform-origin: center;
    animation: character-blink 6.5s infinite;
  }

  .patrick-eyes {
    animation-delay: 1.6s;
  }

  .arm {
    transform-box: view-box;
    transform-origin: 0 0;
    transition: transform .55s cubic-bezier(.4, 0, .2, 1);
  }

  .patrick-arm {
    transform: rotate(-70deg) scale(.72);
  }

  .sponge-arm {
    transform: rotate(-40deg) scale(2);
  }

  .sponge-palm {
    transform-box: view-box;
    transform-origin: 51px -54px;
    transform: rotate(40deg) scale(.5);
    transition: transform .55s cubic-bezier(.4, 0, .2, 1);
  }

  .fishing-net {
    transform-box: view-box;
    transform-origin: 80px 100px;
    transition: transform .55s cubic-bezier(.4, 0, .2, 1);
  }

  .characters[data-mode='hiding'] .fishing-net {
    transform: translate(-50px, 115px) rotate(80deg);
  }

  .closed-eyes {
    opacity: 0;
    transition: opacity .12s .35s;
  }

  .blink,
  .sponge-lashes {
    transition: opacity .12s .35s;
  }

  .characters[data-mode='hiding'] .blink,
  .characters[data-mode='hiding'] .sponge-lashes {
    opacity: 0;
    transition-delay: 0s;
  }

  .characters[data-mode='hiding'] .closed-eyes {
    opacity: 1;
    transition-delay: 0s;
  }

  .characters[data-mode='hiding'] .patrick-arm {
    transform: rotate(124deg) scale(1);
  }

  .characters[data-mode='hiding'] .sponge-arm {
    transform: rotate(0deg) scale(1);
  }

  .characters[data-mode='hiding'] .sponge-palm {
    transform: rotate(0deg) scale(1);
  }

  @keyframes character-breathe {
    0%, 100% {
      transform: translateY(0) rotate(-.5deg);
    }
    50% {
      transform: translateY(-4px) rotate(.5deg);
    }
  }

  @keyframes character-blink {
    0%, 43%, 46%, 100% {
      transform: scaleY(1);
    }
    44.5% {
      transform: scaleY(.06);
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .character-float,
    .blink {
      animation: none;
    }

    .pose,
    .arm,
    .sponge-palm,
    .fishing-net,
    .blink,
    .sponge-lashes,
    .closed-eyes {
      transition: none;
    }

    .characters[data-mode='leaning'] .pose {
      transform: none;
    }
  }
</style>
