---
allowed-tools: Bash(git:*), Bash(grep:*), Bash(ls:*)
description: '生成规范的 git commit message 并提交代码'
---

## 任务

根据当前暂存区（staged）的代码变更，生成规范的中文 git commit message 并在用户确认后提交

## 输入参数

- 任务 ID（可选）：`$ARGUMENTS`

## 执行步骤

### 1. 确定任务 ID

- 如果用户传入了任务 ID（即 `$ARGUMENTS` 不为空），则使用该 ID 作为 scope，格式为 `AIH-<任务ID>`
- 如果用户未传入任务 ID（即 `$ARGUMENTS` 为空），则通过 `git log --oneline -1` 获取上一条 commit message，从中提取 `AIH-XXXX` 格式的任务 ID
- **无论如何，最终 commit message 中必须包含任务 ID**，如果两种方式都无法获取到任务 ID，则提示用户手动输入

### 2. 分析代码变更

- 执行 `git diff --cached --stat` 和 `git diff --cached` 查看暂存区的变更内容
- 如果暂存区为空，则执行 `git diff --stat` 和 `git status` 查看工作区变更，并提示用户先执行 `git add`
- 分析变更的文件和内容，理解本次修改的目的和范围

### 3. 生成 commit message

根据分析结果生成符合 Conventional Commits 规范的 commit message，格式为：

```
type(AIH-XXXX): subject

- 详细变更点 1
- 详细变更点 2
```

**规则：**

- **type** 从以下类型中选择最合适的：`feat`、`fix`、`docs`、`style`、`refactor`、`test`、`chore`
- **scope** 固定为任务 ID，格式 `AIH-XXXX`（如 `AIH-1000`）
- **subject** 用简洁的中文描述本次变更的核心内容，概括性说明本次改了什么，不要过于笼统
- **详细变更点**：在 subject 下方空一行后，用 `- ` 开头逐条列出每个文件的具体修改内容
  - 每条描述对应一个变更文件的具体改动，格式为：`- <动词> <修改文件名> 中的<具体改动内容>`
  - 动词使用中文，如：新增、优化、修复、移除、重构、调整、更新
  - 修改文件名，如 `WidgetRadioButton.vue`
  - 描述要具体且精简，说明改了哪个文件、改了什么，避免模糊描述
  - 按变更文件的重要性排序，核心变更在前
  - 总体长度控制在100个字符

### 4. 确认并提交

- 将生成的 commit message 展示给用户，格式如下：

```
📝 生成的 Commit Message：

  <commit message>

📁 变更文件：
  <变更文件列表>
```

- 询问用户是否确认提交，或者需要修改 message
- 用户确认后执行 `git commit -m "<commit message>"`
- 如果用户要求修改，根据反馈重新生成并再次确认