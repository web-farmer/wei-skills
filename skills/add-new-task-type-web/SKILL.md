---
name: add-new-task-type
description: Add a new AI task type (drawing model / video generation model) to the draw-web platform. This skill guides the full integration across enums, APIs, stores, routing, menus, task center logic, gallery filters, and one-click quick actions.
---

# Skill: add-new-task-type

## Description

Add a new AI task type (drawing model / video generation model) to the draw-web platform. This skill guides the full integration across enums, APIs, stores, routing, menus, task center logic, gallery filters, and one-click quick actions.

## Trigger

Use this skill when the user asks to add a new task type, new AI model integration, new drawing type, or new video generation type to the project.

## Prerequisites

Before starting, gather from the user:

- **Task name** (English identifier, e.g., `drawFlux`)
- **Task label** (Chinese display name, e.g., `Flux绘画`)
- **Category**: drawing (`gDraw`) or video (`gVideo`)
- **Enum numeric ID** (the next integer in `TaskTypeEnum`, e.g., `14`)
- **API base path** (e.g., `/front/api/schedule/v1/flux/`)
- **Flow list** (workflow definitions with IDs, names, descriptions, and posters)
- **Filter options** (sub-type filter items for the gallery, with IDs and names)
- **Socket main type ID** (the next integer in `SocketTaskMainTypeEnum`, e.g., `9`)
- **Socket note type** (optional, if the task has its own progress notification enum)

## Marker

All integration points are marked with `// @AI-MARKER: ADD_NEW_TASK_TYPE`. Search globally to locate them.

---

## Steps

### Step 1: Define Enums

#### 1.1 `src/enums/task.ts`

- **`TaskMainTypeEnum`**: Add `'<TaskMainTypeEnum>' = <ID>` (e.g., `'drawFlux' = 14`)
- **`TaskMainTypeLabelEnum`**: Add `'<TaskMainTypeLabelEnum>' = <ID>` (e.g., `'Flux绘画' = 14`)
- **`TaskTypeEnum`**: Add `'<TaskTypeEnum>' = <ID>` (e.g., `'drawFlux' = 14`)
- **`TaskTypeLabelEnum`**: Add `'<TaskTypeLabelEnum>' = <ID>` (e.g., `'Flux绘画' = 14`)

Pattern:

```ts

export enum TaskMainTypeEnum {
  // ... existing
  'drawFlux' = 14
  // @AI-MARKER: ADD_NEW_TASK_TYPE
}

export enum TaskMainTypeLabelEnum {
  // ... existing
  'Flux绘画' = 14
  // @AI-MARKER: ADD_NEW_TASK_TYPE
}

export enum TaskTypeEnum {
  // ... existing
  'drawFlux' = 14
  // @AI-MARKER: ADD_NEW_TASK_TYPE
}

export enum TaskTypeLabelEnum {
  // ... existing
  'Flux绘画' = 14
  // @AI-MARKER: ADD_NEW_TASK_TYPE
}

```

#### 1.2 `src/enums/socket.ts`

- **`SocketTaskTypeEnum`**: Add entry matching `TaskTypeEnum` value (`'drawFlux' = 14`)
- **`SocketTaskMainTypeEnum`**: Add broad category entry (e.g., `'drawFlux' = 9`)
- **`SocketNoteTypeEnum`** (optional): Add if the task has its own progress notification type

---

### Step 2: Flow Enum File

Create `src/components/ApiTask/enums/<category>-<name>.ts` (e.g., `image-flux.ts`).

Follow the pattern from `src/components/ApiTask/enums/image-gemini.ts`:

```ts
// Flow IDs
export enum EDrawFluxFlowId {
  FlowA = 0,
  FlowB = 1
}

// Payload keys (maps flow ID to API payload key)
export enum EDrawFluxPayloadKey {
  flow_a = EDrawFluxFlowId.FlowA,
  flow_b = EDrawFluxFlowId.FlowB
}

// Flow list with metadata
export const drawFluxFlowList = [
  {
    id: EDrawFluxFlowId.FlowA,
    name: 'Flow A',
    desc: '描述',
    poster: '/static/flux/flow-a.png',
    note: 'by: model-name'
  }
]

// Label lookup enum
export const drawFluxFlowLabelEnum = drawFluxFlowList.reduce((acc: any, item: any) => {
  return { ...acc, [item.id]: item.name, [item.name]: item.id }
}, {})
```

---

### Step 3: API Service

In `src/services/api-task.ts`, add three API functions following the pattern:

```ts
// Cancel
export const postDrawFluxTaskCancel = (data?: any): ApiPromise => {
  return request.post({ url: '/front/api/schedule/v1/flux/task/cancel', data })
}

// Generate
export const postDrawFluxGenerate = (data?: IApiTaskGenerateParam): ApiPromise => {
  return request.post({ url: '/front/api/schedule/v1/flux/photo/add', data })
}

// Flow detail (uses assetsRequest, no auth)
export const getDrawFluxFlowDetail = (data: any) => {
  return assetsRequest.get({ url: '/front/api/schedule/v2/flux/photo/desc', data })
}
```

Import the flow ID type if needed.

---

### Step 4: Flow Store

Create `src/stores/useDrawFluxFlowStore.ts` following the pattern from `src/stores/useDrawGeminiFlowStore.ts`:

```ts
import { ref } from 'vue'
import { defineStore } from 'pinia'
import {
  drawFluxFlowList as fluxList,
  EDrawFluxFlowId
} from '@/components/ApiTask/enums/image-flux'
import { type IApiFlowItem } from '@/components/ApiTask/types/types'
import { parseApiDescToFormSchema } from '@/components/ApiTask/utils'
import { getDrawFluxFlowDetail } from '@/services/api-task'

export const useDrawFluxFlowStore = defineStore('drawFluxFlow', () => {
  const drawFluxFlowList = ref<IApiFlowItem[]>([...fluxList])
  const drawFluxFlowDetailMap = ref<Record<any, any>>({})

  const getDrawFluxFlowList = () => drawFluxFlowList.value

  const getDrawFluxFlowDetailApi = async (id: EDrawFluxFlowId) => {
    try {
      if (drawFluxFlowDetailMap.value[id]) {
        return Promise.resolve(drawFluxFlowDetailMap.value[id])
      }
      const schemaDesc = await getDrawFluxFlowDetail({
        action: id,
        showMessage: false
      })
      const formSchema = parseApiDescToFormSchema(schemaDesc)
      const flowInfo = fluxList.find((item) => item.id === id)
      const flowDetail = { version: formSchema.version, schema: formSchema, id, ...flowInfo }
      drawFluxFlowDetailMap.value[id] = { ...flowDetail }
      return Promise.resolve({ ...flowDetail })
    } catch (error) {
      console.warn('getDrawFluxFlowDetailApi error', error)
      return Promise.reject(error)
    }
  }

  return { drawFluxFlowList, drawFluxFlowDetailMap, getDrawFluxFlowList, getDrawFluxFlowDetailApi }
})
```

Then export in `src/stores/index.ts`:

```ts
export * from './useDrawFluxFlowStore'
```

---

### Step 5: Router & Menu

#### 5.1 Route (`src/router/index.ts`)

Add a child route under the `/task` parent:

```ts
{
  path: '/drawFlux',
  name: 'drawFlux',
  meta: { title: 'Flux绘画', keepAlive: true, activeGroup: 'gDraw', active: 'task' },
  component: () => import('@/views/drawFlux/IndexView.vue')
}
```

#### 5.2 Menu (`src/stores/useMenuStore.ts`)

Add to `gDraw.children` (for drawing) or `gVideo.children` (for video):

```ts
{
  key: 'drawFlux',
  label: 'Flux绘画',
  activeMenu: 'gDraw',
  new: true
}
```

#### 5.3 Task Switch Modal (`src/views/task/components/TaskSwitchModal.vue`)

Add to the appropriate `items` array (drawing or video group):

```ts
{
  id: '<nextId>',
  title: 'Flux绘画',
  desc: '描述文案',
  icon: '/static/task/task-avatar-drawFlux.png',
  routeName: 'drawFlux',
  isNew: true
}
```

---

### Step 6: ApiTask Core Logic

#### 6.1 `src/components/ApiTask/hooks/useApiTaskPage.ts`

Add the new task type to **5 maps** inside this file (search for each marker):

1. **`taskGenerateApiMap`** — map generation API:
   ```ts
   [TaskTypeEnum.drawFlux]: postDrawFluxGenerate
   ```
2. **`taskTipsMap`** (2 occurrences) — map running tips type:
   ```ts
   [TaskTypeEnum.drawFlux]: 'drawFlux'
   ```
3. **`taskPayloadEnumMap`** — map payload key enum:
   ```ts
   [TaskTypeEnum.drawFlux]: EDrawFluxPayloadKey
   ```
4. **`targetRouteNameMap`** — map task type to route name:
   ```ts
   [TaskTypeEnum.drawFlux]: 'drawFlux'
   ```
5. **`taskCancelApiMap`** — map cancel API:
   ```ts
   [TaskTypeEnum.drawFlux]: postDrawFluxTaskCancel
   ```
6. **`supportedMainTypes`** array — add `SocketTaskMainTypeEnum.drawFlux`

Import the new API functions and payload key enum at the top of the file.

#### 6.2 `src/components/ApiTask/utils.ts`

Add to **4 maps/functions**:

1. **`getActionName`** — add flow label mapping:
   ```ts
   if (taskType === TaskTypeEnum.drawFlux) {
     return drawFluxFlowLabelEnum[action]
   }
   ```
2. **`taskTipsMap`** (in `handleRefactorApiTaskItem`) — add tips type:
   ```ts
   [TaskTypeEnum.drawFlux]: 'drawFlux'
   ```
3. **`parseApiTaskImageParams`** — add flow store for param parsing:
   ```ts
   else if (task_type === TaskTypeEnum.drawFlux) {
     flowDetail = await useDrawFluxFlowStore().getDrawFluxFlowDetailApi(flowId)
   }
   ```
4. **`routeNameToTaskTypeMap`** (in `getRouteNameToTaskTypeEnum`) — add route mapping:
   ```ts
   drawFlux: TaskTypeEnum.drawFlux
   ```

Import the flow label enum, flow ID type, and flow store at the top.

#### 6.3 `src/components/ApiTask/ApiTaskItem.vue`

Add the new task type to the local **`TaskTypeLabelEnum`** object (used for task item title display):

```ts
const TaskTypeLabelEnum = {
  // ... existing
  16: 'Flux绘画'
  // @AI-MARKER: ADD_NEW_TASK_TYPE map route name to task type enum here
}
```

Key is the `TaskTypeEnum` numeric ID, value is the Chinese display name.

---

### Step 7: Gallery & History

#### 7.1 Gallery Config (`src/views/gallery/config.ts`)

- Add to `taskFilterTypeEnum`: `DrawFlux = 'DrawFlux'`
- Add to `taskFilterTypeLabelEnum`: `DrawFlux = 'Flux绘画'`
- Define filter options:
  ```ts
  export const drawFluxTaskFilterOptions: any[] = [
    { name: '全部', id: 0, checked: false },
    { id: 601, name: 'Flow A', checked: false }
  ]
  export const drawFluxTaskFilterLabelEnum = drawFluxTaskFilterOptions.reduce((prev, cur) => {
    prev[cur.id] = cur.name
    return prev
  }, {} as Record<number, string>)
  ```

#### 7.2 Gallery Views (3 files)

In each of these files, add the new type to the `task_type` mapping object:

- `src/views/gallery/GalleryCollected.vue`
- `src/views/gallery/GalleryHistory.vue`
- `src/views/gallery/GalleryShare.vue`

```ts
DrawFlux: TaskTypeEnum.drawFlux,
// @AI-MARKER: ADD_NEW_TASK_TYPE
```

#### 7.3 Filter Popover (`src/views/gallery/components/GalleryTypeFilterPopover.vue`)

- **Template**: Add a new filter section block (copy the pattern from existing sections like draw-gemini)
- **Script**: Add reactive refs for the filter options and label enum:
  ```ts
  const drawFluxFilterOptions = ref<any[]>(deepClone(drawFluxTaskFilterOptions))
  const drawFluxFilterLabelEnum = ref<any>(deepClone(drawFluxTaskFilterLabelEnum))
  ```
- **`handleClear`**: Add reset logic for the new filter
- **`handleTaskCheck`**: Add checked-state toggle logic for the new filter

#### 7.4 History Expand (`src/components/DrawHistory/DrawHistoryExpand.vue`)

Add to the slogan icon mapping:

```ts
[TaskTypeEnum.drawFlux]: 'AI',
```

---

### Step 8: One-Click Quick Action (Optional)

If the task supports "一键同款" (one-click replicate):

#### 8.1 `src/views/composition/IndexView.vue`

- Add `item.task_type === TaskTypeEnum.drawFlux` to `v-show` conditions
- Add `sendQuickDrawFlux(item)` dispatch in the quick action handler
- Define the `sendQuickDrawFlux` function (route push + emit task payload)

#### 8.2 `src/components/PhotoDetail/index.vue`

- **Quick action trigger**: Add `sendQuickDrawFlux()` case in dispatch
- **Param parsing**: Add `task_type === TaskTypeEnum.drawFlux` branch in `parseApiTaskImageParams` call
- **Hide prompt translation**: Add `_detail.task_type !== TaskTypeEnum.drawFlux` to the v-if condition
- **Show reference images**: Add `_detail?.task_type === TaskTypeEnum.drawFlux` to the v-if condition
- **One-click action display**: Add `_detail.task_type === TaskTypeEnum.drawFlux` to the v-show condition

#### 8.3 `src/components/PhotoDetail/sendImgTargets.ts`（仅发送图片至）

若新任务支持「仅发送图片」入口，在 `SEND_IMG_TARGETS` 追加一项即可（菜单与跳转自动生效）：

```ts
{ key: 'drawFlux', label: 'Flux绘画' }
// @AI-MARKER: ADD_NEW_TASK_TYPE add send image only target here
```

- `key` 通常等于路由名；若 key 与路由名不一致才配置 `routeName`
- API 类任务无需配置 `isSd` / `module`（默认走 `sendTaskImageToInput`）
- SD 类特殊逻辑才需要：`isSd: true`、`routeName: 'draw'`、`module: 'img2img'`

---

### Step 9: Page View Component

Create the page view at the path specified in the route (e.g., `src/views/drawFlux/IndexView.vue`).

Follow the pattern from existing task views like `src/views/drawGemini/IndexView.vue`. The component should:

- Use `useApiTaskPage` hook with the task type identifier
- Include `ApiTaskInput`, `ApiTaskItem`, `ApiTaskSkeleton`, `ApiTaskHistory` components
- Set up Split.js for the input/preview layout
- Handle the `sendQuickTaskEvent` for receiving quick task payloads

---

### Step 10: Static Assets

- Add task avatar image: `/public/static/task/task-avatar-<identifier>.png`
- Add flow poster images: `/public/static/<name>/` directory

---

### Step 11: Verification

1. Search `// @AI-MARKER: ADD_NEW_TASK_TYPE` globally to confirm all 20 files are updated
2. Run `pnpm type-check` to verify TypeScript compiles
3. Run `pnpm lint` to fix formatting
4. Test the new route in the browser

### Complete File Checklist

| #   | File                                                        | What to add                                                                       |
| --- | ----------------------------------------------------------- | --------------------------------------------------------------------------------- |
| 1   | `src/enums/task.ts`                                         | `TaskTypeLabelEnum` + `TaskTypeEnum`                                              |
| 2   | `src/enums/socket.ts`                                       | `SocketTaskTypeEnum` + `SocketTaskMainTypeEnum` (+ optional `SocketNoteTypeEnum`) |
| 3   | `src/components/ApiTask/enums/<name>.ts`                    | Flow ID enum, payload key enum, flow list, label enum                             |
| 4   | `src/services/api-task.ts`                                  | Cancel, generate, flow detail API functions                                       |
| 5   | `src/stores/use<Name>FlowStore.ts`                          | Pinia store for flow list + detail                                                |
| 6   | `src/stores/index.ts`                                       | Re-export the new store                                                           |
| 7   | `src/router/index.ts`                                       | Task child route                                                                  |
| 8   | `src/stores/useMenuStore.ts`                                | Menu item in `gDraw` or `gVideo` children                                         |
| 9   | `src/views/task/components/TaskSwitchModal.vue`             | Switch modal item                                                                 |
| 10  | `src/components/ApiTask/hooks/useApiTaskPage.ts`            | 5 maps + supportedMainTypes                                                       |
| 11  | `src/components/ApiTask/utils.ts`                           | 4 maps/functions                                                                  |
| 12  | `src/components/ApiTask/ApiTaskItem.vue`                    | Local `TaskTypeLabelEnum` object — add task type ID → Chinese label               |
| 13  | `src/views/gallery/config.ts`                               | Filter enums + options + labels                                                   |
| 14  | `src/views/gallery/GalleryCollected.vue`                    | task_type mapping                                                                 |
| 15  | `src/views/gallery/GalleryHistory.vue`                      | task_type mapping                                                                 |
| 16  | `src/views/gallery/GalleryShare.vue`                        | task_type mapping                                                                 |
| 17  | `src/views/gallery/components/GalleryTypeFilterPopover.vue` | Template + script filter logic                                                    |
| 18  | `src/components/DrawHistory/DrawHistoryExpand.vue`          | Slogan icon mapping                                                               |
| 19  | `src/components/PhotoDetail/index.vue`                      | Quick action + param parsing + v-if conditions (4 markers)                        |
| 20  | `src/components/PhotoDetail/sendImgTargets.ts`              | 仅发送图片至目标配置（追加一项即可）                                              |
| 21  | `src/views/composition/IndexView.vue`                       | v-show + quick action handler (2 markers)                                         |
| 22  | `src/views/<name>/IndexView.vue`                            | **New** page view component                                                       |
| 23  | Static assets                                               | Avatar + flow posters                                                             |
