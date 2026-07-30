<script setup lang="ts">
defineOptions({
  name: '{{pageComponentName}}'
})

import { ref } from 'vue'

import { usePagination } from '@/hooks'
import { useBreadcrumbStore } from '@/stores'
import PageView from '@/views/layout/PageView.vue'

import {{formModalComponentName}} from './components/{{formModalComponentName}}.vue'
import {{settingComponentName}} from './components/{{settingComponentName}}.vue'
import {{tableComponentName}} from './components/{{tableComponentName}}.vue'

const { pagination } = usePagination()
pagination.changer = true

const breadcrumbStore = useBreadcrumbStore()
breadcrumbStore.breadcrumbs = [
  {
    name: '{{menuGroupName}}'
  },
  {
    name: '{{pageTitle}}'
  }
]

const visible = ref(false)
const loading = ref(false)
const dataSource = ref<{{listItemTypeName}}[]>([])
const currentRecord = ref<{{formItemTypeName}} | null>(null)
const searchForm = ref<{{listParamsTypeName}}>({
  page: 1,
  per_page: pagination.size
})

/**
 * 获取列表数据
 * @description 根据当前分页和筛选条件请求页面列表
 */
const reqGetList = async () => {
  loading.value = true
  try {
    // @MODULE-PLACEHOLDER: 接入 {{serviceMethodListName}}
  } finally {
    loading.value = false
  }
}

/**
 * 查询列表
 */
const handleSearch = () => {
  pagination.current = 1
  searchForm.value.page = 1
  searchForm.value.per_page = pagination.size
  reqGetList()
}

/**
 * 重置筛选条件
 */
const handleReset = () => {
  searchForm.value = {
    page: 1,
    per_page: pagination.size
  } as {{listParamsTypeName}}
  handleSearch()
}

/**
 * 打开新增弹窗
 */
const handleCreate = () => {
  currentRecord.value = null
  visible.value = true
}

/**
 * 打开编辑弹窗
 * @param record 当前行数据
 */
const handleEdit = (record: {{listItemTypeName}}) => {
  currentRecord.value = {
    ...record
  }
  visible.value = true
}

/**
 * 分页变更回调
 */
const handleChangePagination = () => {
  searchForm.value.page = pagination.current
  searchForm.value.per_page = pagination.size
  reqGetList()
}

/**
 * 保存成功回调
 */
const handleSuccess = async () => {
  visible.value = false
  await reqGetList()
}

reqGetList()
</script>

<template>
  <PageView
    v-model="pagination.current"
    v-model:pageSize="pagination.size"
    :pagination="pagination"
    title="管理"
    @change-pagination="handleChangePagination"
  >
    <template #title>
      <{{settingComponentName}}
        mode="title"
        :title="'{{pageTitle}}'"
        @create="handleCreate"
      />
    </template>
    <template #search>
      <{{settingComponentName}}
        v-model="searchForm"
        mode="search"
        @reset="handleReset"
        @search="handleSearch"
      />
    </template>
    <template #content>
      <{{tableComponentName}}
        :data-source="dataSource"
        :loading="loading"
        @edit="handleEdit"
      />
    </template>
  </PageView>
  <{{formModalComponentName}}
    v-if="visible"
    v-model:open="visible"
    :record="currentRecord"
    @success="handleSuccess"
  />
</template>

<style lang="scss" scoped></style>