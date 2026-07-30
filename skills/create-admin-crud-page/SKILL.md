---
name: create-admin-crud-page
description: 快速创建 draw-admin 管理后台的列表页和编辑页。Use when asked to add a new admin page such as /{module}, scaffold list/edit views, add router and menu entries, create page/components/service/types from API docs, or follow the model module pattern.
user_invocable: true
metadata:
  author: draw-admin team
  version: "1.0.0"
---

# Create Admin CRUD Page

用于在 draw-admin 中快速创建一个新的管理后台列表页和编辑页。

适用场景：
- 用户要求新增一个管理页面，如 /{module}、/notice-config、/vip-rule。
- 用户要求按模型模块页面模式快速搭建列表页、筛选区、表格和编辑弹窗。
- 用户提供了接口文档，希望同时完成 service、TS 类型和页面字段对接。

## 开始前先读取的仓库文件

执行前必须先读取以下文件，再开始生成：

1. `src/views/model/ModelList.vue`
2. `src/views/model/ModelEdit.vue`
3. `src/views/model/config.ts`
4. `src/services/model.ts`

目的：
- 对齐现有 `PageView` 用法
- 对齐 breadcrumb 写法
- 对齐模型模块的列表页和编辑页拆分方式
- 对齐 service 与页面字段映射方式

## 必须先确认的信息

如果用户没有完整提供，先追问，不能跳过：

1. 页面路径
2. 页面中文名称
3. 菜单归属
4. 接口文档或接口定义
5. 列表筛选字段
6. 列表表格字段
7. 表单字段

如果用户只说“新增一个页面”但没有给路径，必须提示用户输入页面名称或路径，例如 /{module}。

如果用户只给了接口地址，没有直接提供接口文档内容，则必须优先通过 mcp 的 `dobest-api-docs` 获取接口内容，再继续页面生成。

## 输入解析规则

以页面路径 /{module} 为例，统一派生命名：

| 类型 | 规则 | 示例 |
|------|------|------|
| 目录名 | 取路径最后一段 | {module} |
| 主页面组件名 | 目录名 + View | {module}View |
| 表格组件名 | 主页面组件名 + Table | {module}ViewTable |
| 设置组件名 | 主页面组件名 + Setting | {module}ViewSetting |
| 表单弹窗组件名 | 主页面组件名 + FormModal | {module}ViewFormModal |
| 服务文件 | src/services/<目录名>.ts | src/services/{module}.ts |
| 视图目录 | src/views/<目录名>/ | src/views/{module}/ |
| 组件目录 | src/views/<目录名>/components/ | src/views/{module}/components/ |
| 路由 path | 使用新增模块名 | {module} |
| 路由 name | 使用新增模块名 | {module} |

命名要求：
- 组件前缀必须使用主页面组件名。
- 组件后缀必须体现功能和交互方式，例如 Table、Setting、FormModal。
- 函数名、变量名、类型名必须语义清晰，不允许无含义缩写。

## 代码结构要求

### 1. 主页面必须保持轻量

主页面只负责：
- `PageView` 布局
- 页面级状态编排
- 主组件导入
- 组件间事件联动

主页面不要直接堆积大量表格列、表单项和接口细节。参考模型模块页面拆分方式，但只保留 `PageView` 和主组件导入的组织方式。

推荐结构：

- `src/views/{module}/{module}View.vue`
- `src/views/{module}/components/{module}ViewSetting.vue`
- `src/views/{module}/components/{module}ViewTable.vue`
- `src/views/{module}/components/{module}ViewFormModal.vue`
- `src/services/{module}.ts`

### 2. 页面职责拆分

#### {module}View.vue
- 挂载 `PageView`
- 维护分页、查询条件、当前编辑记录、弹窗显隐
- 调用列表请求
- 向子组件传递数据和回调

#### {module}ViewSetting.vue
- 渲染页面标题、筛选项、查询按钮、重置按钮、新增按钮
- 通过事件把筛选动作和新增动作通知父组件

#### {module}ViewTable.vue
- 只负责表格展示
- 接收 columns、dataSource、loading
- 对编辑、删除等行操作通过事件抛出

#### {module}ViewFormModal.vue
- 只负责新增和编辑表单
- 支持详情回填
- 根据是否有 id 自动区分新增和编辑

## 实施步骤

### 步骤 1：新增路由

修改 `src/router/index.ts`。

根据菜单归属选择接入方式：

- 如果挂到已有一级菜单下，则直接在对应 `children` 中新增页面路由。
- 不要为 `{module}` 额外再套一层子路由。
- 路由 `path` 和 `name` 统一使用新增的模块名 `{module}`。

默认路由模板：

```ts
{
  path: '{module}',
  name: '{module}',
  meta: { menu: '/{menuGroup}/{module}' },
  component: () => import('@/views/{module}/{module}View.vue')
}
```

如果该模块挂在顶级路径下，则对应写成 `path: '/{module}'`。核心原则是不再为 `{module}` 创建额外的空 `children` 包装层。

### 步骤 2：新增菜单

修改 `src/views/layout/MainView.vue` 中的静态 `menus` 数组。

规则：
- 已有一级菜单下新增子菜单时，只追加子项。
- 新建一级菜单时，同时补 icon 和默认子菜单项。
- `key` 必须与 `meta.menu` 保持一致。

### 步骤 3：创建视图目录和组件目录

创建：

- `src/views/{module}/`
- `src/views/{module}/components/`

### 步骤 4：创建主页面

主页面文件名按路径派生，例如：

- `src/views/{module}/{module}View.vue`

要求：
- 使用 `<script setup lang="ts">`
- 使用 Composition API
- 设置 `defineOptions({ name: '{module}View' })`
- 使用 `PageView`
- 只导入主组件，例如 `{module}ViewSetting`、`{module}ViewTable`、`{module}ViewFormModal`
- 必须保留分页、弹窗、查询参数这些页面级状态

### 步骤 5：创建组件文件

至少包含：

- `{module}ViewSetting.vue`
- `{module}ViewTable.vue`
- `{module}ViewFormModal.vue`

如果页面需要额外信息区、统计区、详情抽屉，可继续沿用此前缀：

- `{module}ViewStatisticCard.vue`
- `{module}ViewDetailDrawer.vue`

### 步骤 6：根据接口文档完成接口对接

必须先读懂接口文档，再写代码。

如果用户提供的是接口地址而不是接口文档正文：

- 优先通过 mcp 的 `dobest-api-docs` 拉取接口内容。
- 拿到接口内容后，再整理请求参数、返回结构、字段含义和可选枚举。
- 如果 mcp 无法获取接口内容，再向用户补充确认缺失字段，不能直接猜测接口结构。

页面中涉及loading的地方，优先使用 v-loading 指令。

至少识别以下接口：

1. 列表接口
2. 详情接口
3. 新增接口
4. 编辑接口
5. 删除接口
6. 选项枚举接口（如果有）

必须完成：
- 请求方法和路径对接
- 请求参数类型定义
- 列表项类型定义
- 表单类型定义
- 枚举类型或选项列表定义
- 页面字段和表单字段映射
- 接口返回数据转换

建议的 service 结构：

```ts
export interface I{Module}ListParams {}
export interface I{Module}ListItem {}
export interface I{Module}FormItem {}

export const get{Module}List = (data: I{Module}ListParams) => {}
export const get{Module}Detail = (data: { id: number }) => {}
export const post{Module}Add = (data: I{Module}FormItem) => {}
export const post{Module}Edit = (data: I{Module}FormItem) => {}
export const post{Module}Delete = (data: { id: number }) => {}
```

### 步骤 7：严格补齐类型和注释

要求：
- 所有接口参数和页面核心状态必须有 TS 类型。
- 函数必须补充必要的 JSDoc 注释。
- 注释统一使用中文。
- 对复杂字段映射和状态切换补简洁注释。
- 不要写无意义注释。

JSDoc 示例：

```ts
/**
 * 获取{模块名称}列表
 * @description 根据筛选条件和分页参数获取{模块名称}列表数据
 */
const reqGetList = async () => {}
```

## 页面生成顺序

实际执行时，按以下顺序完成：

1. 确认页面路径、菜单归属和接口文档
2. 新增路由和菜单
3. 创建视图目录和组件目录
4. 创建 service 和类型
5. 创建主页面和子组件
6. 接入列表、详情、新增、编辑、删除逻辑
7. 补充 JSDoc 和必要注释
8. 做局部校验

## 与模型模块对齐的实现原则

参考模型模块实现时，保留这些能力：
- 分页
- 查询和重置
- 新增和编辑弹窗
- 删除确认
- 页面 breadcrumb
- `PageView` 插槽结构

但要做这些改进：
- 视图组件更薄，不把所有逻辑都堆在一个文件里
- 表格和筛选区拆到组件中
- 接口类型更完整
- 函数职责更单一
- 注释和命名更规范

## 必须检查的仓库约定

- Vue 页面使用 `<script setup lang="ts">`
- 使用 Composition API
- 路径别名使用 `@`
- 注释使用中文
- 风格遵循仓库 Prettier 和 ESLint 规则

## 模板占位标记约定

- 模板中禁止使用 `TODO` 作为占位注释。
- 统一使用 `@MODULE-PLACEHOLDER:` 作为待实现标记。
- 该标记只用于提示后续需要根据接口文档补充的逻辑、字段、表单项和列定义。
- 实际生成业务代码时，应优先替换或删除这些占位标记，不要直接保留到最终提交代码中。

## 生成时的执行约束

1. 若页面路径缺失，先提示用户输入，不要自行猜测。
2. 若接口文档缺失，只允许先生成页面骨架，不要伪造接口字段。
3. 若菜单归属不明确，先询问是挂到现有菜单还是创建新一级菜单。
4. 若接口字段与 UI 字段不一致，先建立字段映射，再编码。
5. 路由、菜单、视图、组件、服务、类型必须同步生成，避免半成品。
6. 若用户给定接口地址，先通过 mcp 的 `dobest-api-docs` 获取接口内容，再开始接口对接。

## 建议产物清单

以 /{module} 为例，默认应生成：

- `src/views/{module}/{module}View.vue`
- `src/views/{module}/components/{module}ViewSetting.vue`
- `src/views/{module}/components/{module}ViewTable.vue`
- `src/views/{module}/components/{module}ViewFormModal.vue`
- `src/services/{module}.ts`

按需补充：
- `src/views/{module}/constants.ts`
- `src/views/{module}/types.ts`

## 校验要求

完成后至少执行：

1. 对新增和修改文件做局部错误检查
2. 确认路由 import 路径正确
3. 确认菜单 key 与 `meta.menu` 一致
4. 确认弹窗新增和编辑逻辑分支正确
5. 确认接口参数类型与表单字段一致

如果全局 `pnpm type-check` 存在与本次改动无关的历史错误，应优先使用局部错误检查说明结果，再单独说明历史问题。

## 代码规范：BEM 与禁止缩写

### CSS 命名规则

- 样式统一使用 BEM 命名规范，block、element、modifier 三级语义清晰。
- className 禁止缩写，必须使用完整语义化命名，例如 `.credit-config-table__cell-input`，而不是 `&__cell-input` 或 `.table-input`。
- 修饰类（modifier）使用 `is--{状态}` 或 `{block}--{修饰}` 形式，例如 `is--rmb`、`credit-config-table--active`。
- 单个组件内 scope 样式必须以该组件的 block 名作为根，如 `.credit-config-table`、`.credit-config-setting`、`.credit-config`。

### SCSS 书写要求

- 禁止使用 `&` 嵌套缩写拼接 className。每个选择器都写完整语义化类名，例如：

  ```scss
  // 正确
  .credit-config__quota-panel {
    padding: 24px;
  }

  .credit-config__quota-input {
    width: 220px;
  }

  // 错误（禁止）
  .credit-config {
    &__quota-panel {
      padding: 24px;
    }

    &__quota-input {
      width: 220px;
    }
  }
  ```

- block 与 element 之间的 `__`、modifier 的 `--` 不能省略。
- 媒体查询、状态修饰等仍以完整 className 书写，例如 `.credit-config-table__currency.is--rmb`。
- 组件根 block 名应和组件文件名语义一致（如 `CreditConfigTable.vue` 对应 `.credit-config-table`）。

## 模板资产

本 skill 附带以下模板，可直接参考：

- `templates/page-view.template.vue`
- `templates/setting.template.vue`
- `templates/table.template.vue`
- `templates/form-modal.template.vue`
- `templates/service.template.ts`

生成代码时优先基于这些模板替换占位符，而不是从零随意发挥。


TODO: 代码规范

BEM & 禁止缩写