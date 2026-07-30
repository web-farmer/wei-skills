<script setup lang="ts">
defineOptions({
  name: '{{formModalComponentName}}'
})

import { computed, ref, watch } from 'vue'
import { message } from 'ant-design-vue'

interface IProps {
  open?: boolean
  record?: {{formItemTypeName}} | null
}

const props = withDefaults(defineProps<IProps>(), {
  open: false,
  record: null
})

const visible = defineModel<boolean>('open', {
  default: false
})

const emits = defineEmits<{
  success: []
}>()

const formRef = ref()
const loading = ref(false)

const formState = ref<{{formItemTypeName}}>({
  // @MODULE-PLACEHOLDER: 根据接口文档补充初始值
} as {{formItemTypeName}})

const modalTitle = computed(() => {
  return props.record?.id ? '编辑{{pageTitle}}' : '新增{{pageTitle}}'
})

watch(
  () => props.record,
  async newRecord => {
    if (!newRecord) {
      formState.value = {} as {{formItemTypeName}}
      return
    }

    formState.value = {
      ...newRecord
    }

    // @MODULE-PLACEHOLDER: 如有详情接口，在此补充详情回填
  },
  {
    immediate: true,
    deep: true
  }
)

/**
 * 提交表单
 */
const handleConfirm = async () => {
  await formRef.value?.validate()
  loading.value = true

  try {
    // @MODULE-PLACEHOLDER: 根据是否存在 id 调用新增或编辑接口
    message.success('保存成功')
    emits('success')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <a-modal
    v-model:open="visible"
    :confirm-loading="loading"
    :title="modalTitle"
    centered
    wrap-class-name="crud-form-modal-wrap"
    @ok="handleConfirm"
  >
    <div class="crud-form-modal-body">
      <a-form ref="formRef" :model="formState" :label-col="{ span: 6 }" size="large">
        <!-- @MODULE-PLACEHOLDER: 根据接口文档补充表单项 -->
        <a-form-item label="名称" name="name" required>
          <a-input v-model:value="formState.name" allow-clear placeholder="请输入" />
        </a-form-item>
      </a-form>
    </div>
  </a-modal>
</template>

<style lang="scss" scoped>
.crud-form-modal-wrap :deep(.ant-modal) {
  padding-bottom: 0;
}

.crud-form-modal-body {
  width: 480px;
  max-height: 60vh;
  overflow-y: auto;
  scrollbar-width: none;
}

.crud-form-modal-body::-webkit-scrollbar {
  display: none;
}
</style>