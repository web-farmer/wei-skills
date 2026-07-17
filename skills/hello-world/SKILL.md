---
name: hello-world
description: >
  演示 Skill 结构与触发方式。当用户说「hello skill」「测试 skill」、
  「skill 示例」或想验证 wei-skills 是否安装成功时使用。
---

# Hello World

确认本 skill 已从 `wei-skills` 仓库正确加载，并输出约定摘要。

## 指令

1. 明确告知用户：`hello-world` skill 已加载，安装路径约定为 `~/.claude/skills/hello-world`（或项目级 `.claude/skills/hello-world`）软链到 monorepo 的 `skills/hello-world`。
2. 用简短列表说明仓库约定：
   - 新增 skill：从 `templates/skill` 复制到 `skills/<name>`，保证目录名 = frontmatter `name`
   - 安装：在仓库根目录执行 `./scripts/install.sh` 或 `./scripts/install.sh <name>`
   - 查看状态：`./scripts/list.sh`
   - 卸载：`./scripts/uninstall.sh`（仅删除本仓库创建的软链）
   - 规范文档：`docs/conventions.md`
3. 询问用户是否需要新建 skill 或查看 MCP 目录约定（`mcps/README.md`）。

## 约束

- 不要修改用户全局配置（如 `~/.claude.json`）。
- 不要执行破坏性命令；本 skill 仅用于演示与说明。
- 保持回复简短、可操作。
