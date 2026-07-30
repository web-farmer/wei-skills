<script setup lang="ts">
defineOptions({
  name: '{{settingComponentName}}'
})

interface IProps {
  mode: 'title' | 'search'
  title?: string
}

const props = withDefaults(defineProps<IProps>(), {
  title: ''
})

const formModel = defineModel<{{listParamsTypeName}}>({
  default: () => ({}) as {{listParamsTypeName}}
})

const emits = defineEmits<{
  create: []
  reset: []
  search: []
}>()

/**
 * 触发新增
 */
const handleCreate = () => {
  emits('create')
}

/**
 * 触发查询
 */
const handleSearch = () => {
  emits('search')
}

/**
 * 触发重置
 */
const handleReset = () => {
  emits('reset')
}
</script>

<template>
  <div v-if="props.mode === 'title'" class="header-title">
    <span class="header-title__text">{{ props.title }}</span>
    <a-button type="primary" size="large" @click="handleCreate">新增</a-button>
  </div>
  <div v-else class="header-search">
    <!-- @MODULE-PLACEHOLDER: 根据接口文档补充筛选项 -->
    <a-input
      v-model:value="formModel.search_key"
      allow-clear
      placeholder="请输入关键词"
      size="large"
      style="width: 240px"
      @pressEnter="handleSearch"
    />
    <a-button type="primary" size="large" @click="handleSearch">查询</a-button>
    <a-button size="large" @click="handleReset">重置</a-button>
  </div>
</template>

<style lang="scss" scoped>
.header-title {
  display: flex;
  align-items: center;
  justify-content: space-between;

  &__text {
    font-size: 18px;
    font-weight: 600;
  }
}

.header-search {
  display: flex;
  gap: 16px;
  align-items: center;
}
</style>