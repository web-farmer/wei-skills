<script setup lang="ts">
defineOptions({
  name: '{{tableComponentName}}'
})

import { computed } from 'vue'

interface IProps {
  dataSource: {{listItemTypeName}}[]
  loading: boolean
}

const props = defineProps<IProps>()

const emits = defineEmits<{
  edit: [record: {{listItemTypeName}}]
  remove: [record: {{listItemTypeName}}]
}>()

const columns = computed(() => {
  return [
    // @MODULE-PLACEHOLDER: 根据接口文档补充列定义
    {
      title: 'ID',
      dataIndex: 'id',
      align: 'center'
    },
    {
      title: '操作',
      key: 'action',
      align: 'center'
    }
  ]
})

/**
 * 编辑当前行
 * @param record 当前行数据
 */
const handleEdit = (record: {{listItemTypeName}}) => {
  emits('edit', record)
}

/**
 * 删除当前行
 * @param record 当前行数据
 */
const handleRemove = (record: {{listItemTypeName}}) => {
  emits('remove', record)
}
</script>

<template>
  <a-table :columns="columns" :data-source="props.dataSource" :loading="props.loading" :pagination="false"
  :sticky="true"
  >
    <template #bodyCell="{ column, record }">
      <template v-if="column.key === 'action'">
        <div class="button-group">
          <a-button type="primary" size="small" ghost @click="handleEdit(record)">
            编辑
          </a-button>
          <a-button size="small" danger @click="handleRemove(record)">删除</a-button>
        </div>
      </template>
    </template>
  </a-table>
</template>

<style lang="scss" scoped>
.button-group {
  display: flex;
  gap: 8px;
  justify-content: center;
}
</style>