<template>
  <iframe :id="name" :src="url" class="iframe-page" scrolling="yes"></iframe>
</template>
<script setup lang="ts">
  let props = defineProps({
    name: String,
    url: String,
  });
</script>
<style scoped>
  .iframe-page {
    display: block;
    width: 100%;
    height: 100%;
    border: 0;
  }
</style>
