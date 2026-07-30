---
name: changelog-writer
description: 根据用户提供的版本变更梗概，对比当前分支与 master 的提交/文件差异，完善 changelog 并写入项目 changelog 文件。调用时必须提供版本梗概；未提供时提示用户输入。
---

# Skill: changelog-writer

## Description

根据用户给出的**版本记录梗概**，结合当前分支相对基线分支的 git 提交与代码 diff，补全详细 changelog（组件名、文件名、关键逻辑），并写入项目根目录的 changelog 文件。

## Trigger

在以下场景使用本 skill：

- 用户要求「完善 changelog」「写版本记录」「生成 change log」
- 用户提供版本号 + 功能梗概，要求补充具体改动
- 用户说「根据当前版本和 master 的修改完善 changelog」

## 必填输入（Args）

调用时用户必须提供**版本记录梗概**。梗概通常包含：

1. **版本号**（如 `3.7.0`）
2. **端/模块分类**（创作端 / 后台 / 模型端 / comfyui 等，按项目既有分类）
3. **功能/优化条目列表**（可简略，一行一个点）

### 未提供梗概时

若用户仅触发 skill、未给出梗概（无版本号、无功能列表），**立即停止后续分析**，并提示用户补充，例如：

```text
请提供版本记录梗概后再继续，格式示例：

# 3.7.0

## 创作端

### 功能

- 创作端：动态表单上传音视频增加总时长校验
- 创作端：动态表单支持图片上传自动裁剪参数
- 创作端：场景聚合节点解析及展示
...
```

不要猜测版本号，不要在没有梗概的情况下直接写 changelog。

可选补充信息（有则用，无则自行推断）：

- 对比基线分支（默认 `origin/master`，本地无 `master` 时用 `origin/master`）
- 是否覆盖已有同版本章节（默认：同版本已存在则**替换**该版本整块，不重复插入）
- 详略程度（默认：含组件/文件/关键符号；用户要求「对外简版」则去掉实现细节）

---

## Steps

### Step 0: 校验输入

1. 从用户消息 / skill args 中解析：
   - 版本号 `X.Y.Z`
   - 梗概条目列表
2. 若缺少版本号或条目列表 → 提示用户输入，结束本轮。
3. 确认项目根目录 changelog 路径：
   - 优先 `changelog.md`
   - 其次 `CHANGELOG.md`
   - 若两者均为硬链接/同一文件，只写一次
   - **若均不存在 → 创建 `changelog.md`**，首行可用项目名（如 `ai 绘画`）或保持空标题后直接写版本块

### Step 1: 确定对比基线

```bash
# 远程基线（优先）
git fetch origin master 2>/dev/null || true
git rev-parse origin/master HEAD
git merge-base origin/master HEAD
```

- 默认基线：`origin/master`
- 若用户指定 `develop` / 某 tag，改用用户指定
- 记录：`git log <base>..HEAD --oneline --no-merges` 与 `git diff <base>...HEAD --stat` / `--name-status`

### Step 2: 按梗概对齐提交与文件

1. 列出基线到 HEAD 的非 merge 提交：
   ```bash
   git log origin/master..HEAD --oneline --no-merges
   ```
2. 按 commit message 中的工单号（如 `AIH-xxxx`）与类型（feat/fix/refactor）分组。
3. 将**用户梗概中的每一条**映射到：
   - 相关 commit 列表
   - 相关文件路径（`git show <hash> --stat` 或 name-status）
4. 对梗概未覆盖、但 diff 中明确的**用户可见改动**（如下架入口、删路由、UI 小优化），归入「优化 / 其他」或对应端分类；**不要**把纯 docs/settings/chore 堆进功能列表，文档可单独一小节。
5. 若某条梗概在 diff 中找不到对应改动，在最终输出中标注「未在代码 diff 中定位到实现，保留梗概原文」，不要编造文件名。

### Step 3: 深挖实现细节（按条进行）

对每条功能，读取关键 diff / 源码，提取：

| 维度 | 提取内容 |
| --- | --- |
| 新增/修改文件 | 组件、store、service、utils、enum、路由等路径 |
| 关键符号 | 组件名、函数名、enum 成员、schema 字段、socket 类型 |
| 行为变化 | 校验规则、默认值、拦截逻辑、展示文案 |
| 资源 | 静态图、配置 id 等 |

常用切入点：

- `git show <commit> -p -- <paths>` 看单次改动
- `rg` 搜新增 export / 组件引用
- 用户提供的 `docs/vX.Y.Z/` 设计文档（若有）仅作辅助，**以代码为准**

控制范围：只服务 changelog，不重构代码，不顺手改业务。

### Step 4: 按项目风格撰写

#### 结构模板

与仓库既有 changelog 保持一致，推荐结构：

```markdown
# <版本号>

## <端/模块>          # 如：创作端、后台、模型端、comfyui

### 功能

- <端前缀>：<梗概标题>（`<工单号>`）
  - <组件/文件>：<具体改动>
  - ...

### 优化 / 其他

- <简要条目>

## 文档            # 可选

- 新增 `docs/...`
```

#### 写作规范

1. **中文**描述；代码标识用反引号：`` `ComponentName` ``、`` `path/file.ts` ``。
2. **保留用户梗概标题**作为一级 bullet，细节作为缩进子 bullet。
3. 尽量带工单号：``（`AIH-xxxx`）``（从 commit message 提取）。
4. 细节层级：
   - 默认（详细）：组件名、关键文件、配置字段、枚举值、接入位置
   - 简版（用户要求时）：仅保留「端：功能说明」一行
5. 同一能力的 fix/refactor 合并进对应功能条，不单独刷屏，除非是独立用户可见修复。
6. 不写耗时估计、不写「AI 生成」字样、不堆无意义 process 日志。

#### 参考示例（详细条目）

```markdown
- 创作端：动态表单上传音视频增加总时长校验（`AIH-1498`）
  - `WidgetAudioUpload` / `WidgetVideoUpload` 新增 `maxTotalDuration` 属性
  - `DynamicFormField` 透传 schema 字段 `max_total_duration`
  - 超出限制时提示：`「字段名」总时长不能大于 N 秒`
```

### Step 5: 写入 changelog 文件

1. 定位文件：`changelog.md` 或 `CHANGELOG.md`；都不存在则 **创建** `changelog.md`。
2. 文件头若有项目标题行（如 `ai 绘画`），**保留**。
3. 版本块插入规则：
   - 在标题行之后、**最新版本之前**插入新版本（新版本置顶）
   - 若已存在同版本 `# X.Y.Z` 章节：用完善后的内容**整体替换**该版本块（从该 `# X.Y.Z` 到下一 `#` 版本标题之前）
   - 不要删除其他历史版本
4. 保持 Markdown 空行风格与文件其余部分一致（版本标题下空一行、章节间空行）。
5. 若 `changelog.md` 与 `CHANGELOG.md` 是同一 inode（硬链接），只编辑其中一个即可。

### Step 6: 交付确认

完成后向用户简要说明：

1. 对比基线（如 `origin/master`）与提交数量
2. 写入的文件路径
3. 完善后的版本摘要（可按梗概条目列出）
4. 若有梗概未在 diff 中定位到的条目，单独列出

---

## 注意事项

- **禁止**在无梗概时凭空生成版本功能列表。
- **禁止**把 `node_modules`、无关 lockfile 噪音写进 changelog。
- **禁止**捏造未出现在 diff 中的文件名/API。
- 本地无 `master` 分支时一律使用 `origin/master`（或先 `git fetch`）。
- 纯 merge commit 忽略；以 `--no-merges` 的功能提交为准。
- 本 skill 只维护 changelog 文档，不自动 commit；用户要求提交时再走 commit 流程。

## 示例调用

**正确（含梗概）：**

```text
/changelog-writer

# 3.7.0
## 创作端
### 功能
- 创作端：动态表单上传音视频增加总时长校验
- 创作端：增加用户积分展示、积分更新、任务拦截
```

**错误（无梗概，应提示）：**

```text
/changelog-writer
```

→ 回复要求用户粘贴版本梗概后再执行。
