---
name: add-new-task-type
description: Step-by-step guide for integrating a new AI drawing/generation task type into the draw-admin dashboard. Covers enums, services, views, utils, and queue management. Use this skill when asked to add a new task type (e.g., a new AI model provider).
user_invocable: true
metadata:
  author: draw-admin team
  version: "1.0.0"
---

# Add New Task Type

> Complete checklist for integrating a new task type into the draw-admin codebase.
> The codebase uses `@AI-MARKER: ADD_NEW_TASK_TYPE` comments (numbered 1–25) to mark every insertion point.

## Prerequisites

Before starting, gather the following from the backend/product team:

| Item | Example (drawGemini) | Description |
|------|----------------------|-------------|
| **Task key name** | `drawGemini` | camelCase identifier used in code |
| **Display label** | `Gemini绘画` | Chinese label shown in UI |
| **Backend task type ID** | `13` | Integer from the backend `task_type` field |
| **DrawType index** | `7` | Next sequential value in `DrawTypeEnum` |
| **DrawTypeFilter value** | `8` | Next 1-based value in `DrawTypeFilterOptions` |
| **ApiKeyType value** | `4` | Next value in `ApiKeyTypeEnum` (if API-key managed) |
| **Workflow API endpoint** | `/ops/api/schedule/v2/gemini/photo/desc` | Backend desc API |
| **Secondary tasks (flows)** | `NanoBanana2=0, NanoBananaPro=1` | Sub-task enum values |
| **Secondary filter list** | `[{value:501,label:'NanoBanana2'}, ...]` | Used in task/picture list dropdowns |
| **Badge color** | `#4285f4` | Hex color for the picture list badge |
| **Notification tag** | `drawGemini` | Radio value in NoticeLoading |

## Step-by-Step Checklist

Follow the numbered markers in the code. Each step corresponds to a `@AI-MARKER: ADD_NEW_TASK_TYPE - N` comment.

---

### Phase 1: Core Type Definitions

**File: `src/views/system/types.ts`**

| Step | Marker | What to add |
|------|--------|-------------|
| 1 | `#1` | Add entry to `DrawTypeEnum` (e.g., `'newType' = 8`) |
| 2 | `#2` | Add entry to `DrawTypeLabelEnum` (e.g., `'新类型绘画' = 8`) |
| 3 | `#3` | Add entry to `DrawTypeOptions` array (e.g., `{ label: '新类型绘画', value: DrawTypeEnum.newType }`) |
| 4 | `#4` | Add entry to `DrawTypeFilterOptions` array (value is **1-based cumulative**, e.g., `{ label: '新类型绘画', value: 9 }`) |
| 5 | `#5` | Add entry to `TaskTypeLabelEnum` (e.g., `'新类型绘画' = 14`) |
| 6 | `#6` | Add entry to `TaskTypeEnum` (e.g., `'newType' = 14`) |
| 7 | `#7` | Add entry to `TaskTypeOptions` array (e.g., `{ label: '新类型绘画', value: 14 }`) |
| 8 | `#8` | If the task type has secondary tasks: create `NewTypeTaskTypeFilterList` and `NewTypeTaskTypeFilterLabel` (copy the pattern from `DrawGeminiTaskTypeFilterList`) |

> `DrawQueueTypeEnum` at the bottom of the file is a spread of `DrawTypeEnum`, so it auto-inherits.

---

### Phase 2: Enum File (Secondary Tasks / Flows)

**New file: `src/enum/<new-type>.ts`**

Create a new enum file following the pattern in `src/enum/draw-gemini.ts`:

```typescript
/**
 * <new-type> 二级任务类型
 */
export enum ENewTypeFlowId {
  FlowA = 0,
  FlowB = 1
}

export const newTypeFlowList = [
  { id: ENewTypeFlowId.FlowA, name: 'FlowA' },
  { id: ENewTypeFlowId.FlowB, name: 'FlowB' }
]

/**
 * <new-type> 工作流label【二级任务 label】
 */
export const newTypeFlowLabelEnum = newTypeFlowList.reduce((acc: any, item: any) => {
  return {
    ...acc,
    [item.id]: item.name,
    [item.name]: item.id
  }
}, {})
```

> This file does NOT need to be re-exported from `src/enum/index.ts`; it is imported directly where needed.

---

### Phase 3: Service Layer

**File: `src/services/api-task.ts`** (unnumbered marker)

Add a new workflow detail API function:

```typescript
export const getApiNewTypeWorkflowDetail = (data: any): AxiosPromise => {
  return assetsRequest.get({
    url: '/ops/api/schedule/v2/<new-type>/desc',
    data
  })
}
```

**File: `src/services/api-manage.ts`**

| Step | Marker | What to add |
|------|--------|-------------|
| 9 | `#9` | Add to `ApiKeyTypeEnum` (e.g., `newType = 5`) |
| 10 | `#10` | Add to `ApiKeyTypeOptions` (e.g., `{ label: '新类型绘画', value: ApiKeyTypeEnum.newType }`) |

---

### Phase 4: Dispatch Module (Task List)

**File: `src/views/dispatch/config.ts`**

| Step | Marker | What to add |
|------|--------|-------------|
| 11 | `#11` | In the `columns` 任务类型 `customRender`: add `if (record.task_type === TaskTypeEnum.newType) { return TaskTypeLabelEnum[record.task_type] }` |
| 12 | `#12` | In the `columns` 二级任务 `customRender`: add `if (record.task_type === TaskTypeEnum.newType) { return NewTypeTaskTypeFilterLabel[record.mj_type] \|\| '-' }` |

> Import `NewTypeTaskTypeFilterLabel` from `../system/types` at the top of the file.

**File: `src/views/dispatch/TaskList.vue`**

| Step | Marker | What to add |
|------|--------|-------------|
| 13 | `#13` | Add to `drawTypeFilterOptions` map: `[DrawTypeEnum.newType]: [...NewTypeTaskTypeFilterList]` |
| 14 | `#14` | Add to `reqGetTaskList()`: `if (drawType.value === DrawTypeEnum.newType) { params.mj_types = taskTypeIds; params.task_type = TaskTypeEnum.newType }` |

> Import `NewTypeTaskTypeFilterList` from `../system/types`.

---

### Phase 5: Picture Module

**File: `src/views/picture/PictureData.vue`**

| Step | Marker | What to add |
|------|--------|-------------|
| 15 | `#15` | Add to `drawTypeFilterOptions` map: `[DrawTypeEnum.newType]: [...NewTypeTaskTypeFilterList]` |
| 16 | `#16` | Add to `TaskTypeColor`: `[TaskTypeEnum.newType]: '#HEXCOLOR'` |
| 17 | `#17` | Add to `reqGetImagesList()`: `if (drawType.value === DrawTypeEnum.newType) { params.mj_types = taskTypeIds }` |
| 18 | `#18` | Add to SD badge exclusion condition: `picture.task_type !== TaskTypeEnum.newType &&` |

---

### Phase 6: Detail Components

**File: `src/views/dispatch/components/TaskDetailModal.vue`**

| Step | Marker | What to add |
|------|--------|-------------|
| 19 | `#19` | Add `\|\| props.taskType === TaskTypeEnum.newType` to the `if` condition that triggers `parseApiTaskImageParams` |
| 20 | `#20` | Add `\|\| props.taskType === TaskTypeEnum.newType` to the `v-else-if` condition that shows the API task form section |

**File: `src/views/picture/components/PictureDetail.vue`**

| Step | Marker | What to add |
|------|--------|-------------|
| 21 | `#21` | Add `\|\| data.task_type === TaskTypeEnum.newType` to the `if` condition that triggers `parseApiTaskImageParams` |
| 22 | `#22` | Add `\|\| detail?.task_type === TaskTypeEnum.newType` to the `v-else-if` condition that shows API task detail form |

---

### Phase 7: Queue Management

**File: `src/views/dispatch/components/EditQueueModal.vue`**

| Step | Marker | What to add |
|------|--------|-------------|
| 23 | `#23` | Add `else if (taskType === DrawQueueTypeEnum.newType) { type = ApiKeyTypeEnum.newType }` in `fetchApiOptions()` |

**Additionally** in the same file, add `DrawQueueTypeEnum.newType` to **all 6 conditional blocks** that distinguish API-type queues from device-type queues:

| Lines (approx) | Purpose | Pattern |
|-----------------|---------|---------|
| ~74-79 | Skip `getDeviceOptions` for API types | Add `\|\| ... === DrawQueueTypeEnum.newType` |
| ~173-178 | Fetch API key/entity in `getDetail` | Add `\|\| ... === DrawQueueTypeEnum.newType` |
| ~274-279 | Hide "dynamic queue" switch | Add `&& ... !== DrawQueueTypeEnum.newType` |
| ~313-319 | Hide "add devices" button | Add `&& ... !== DrawQueueTypeEnum.newType` |
| ~357-363 | Show "API KEY" select | Add `\|\| ... === DrawQueueTypeEnum.newType` |
| ~376-382 | Show "API entity" select | Add `\|\| ... === DrawQueueTypeEnum.newType` |

---

### Phase 8: Utils (Parameter Parsing)

**File: `src/utils/api-task.ts`**

| Step | Marker | What to add |
|------|--------|-------------|
| 24 | `#24` | Add `if (taskType === TaskTypeEnum.newType) { taskPayloadJson.actionName = newTypeFlowLabelEnum[taskPayloadJson.action] \|\| '-' }` |
| 25 | `#25` | Add `else if (taskType === TaskTypeEnum.newType) { flowDetail = await getApiNewTypeWorkflowDetail({ action: taskPayloadJson.action }) }` |

> Import `newTypeFlowLabelEnum` from `@/enum/<new-type>` and `getApiNewTypeWorkflowDetail` from `@/services/api-task`.

---

### Phase 9: Notification (Optional)

**File: `src/views/system/NoticeLoading.vue`**

Add a new `<a-radio>` for the notification tag filter (around line 218):

```html
<a-radio value="newType">newType</a-radio>
```

---

## Auto-propagating Files (No Direct Changes Needed)

These files import from the types/options above and update automatically:

- `src/views/system/Dashboard.vue` — uses `DrawTypeFilterOptions`, `TaskTypeOptions`, `TaskTypeLabelEnum`
- `src/views/openapi/Tmpl/EditModal.vue` — uses `TaskTypeOptions`
- `src/views/dispatch/ConsumeList.vue` — uses `DrawTypeFilterOptions`
- `src/router/index.ts` — no task-type-specific routes
- `src/stores/` — task-type agnostic

---

## Files Summary

| Category | Files to modify |
|----------|-----------------|
| **New file** | `src/enum/<new-type>.ts` |
| **Core types** | `src/views/system/types.ts` |
| **Services** | `src/services/api-task.ts`, `src/services/api-manage.ts` |
| **Dispatch views** | `src/views/dispatch/config.ts`, `src/views/dispatch/TaskList.vue` |
| **Dispatch components** | `src/views/dispatch/components/TaskDetailModal.vue`, `src/views/dispatch/components/EditQueueModal.vue` |
| **Picture views** | `src/views/picture/PictureData.vue` |
| **Picture components** | `src/views/picture/components/PictureDetail.vue` |
| **Utils** | `src/utils/api-task.ts` |
| **System** | `src/views/system/NoticeLoading.vue` |

**Total: 1 new file + 10 modified files, 25+ insertion points.**

---

## Verification

After making all changes:

1. Run `pnpm type-check` — ensure no TypeScript errors
2. Run `pnpm lint` — ensure no lint errors
3. Manual verification:
   - Dashboard page: new type appears in filter dropdowns and charts
   - Task list page: can filter by new type, primary/secondary labels render
   - Picture list page: badge color, filter, detail modal all work
   - Queue management: can create/edit queue for new type with API key/entity
   - Notification page: new radio option appears
