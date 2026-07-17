# 开发约定（conventions）

本文档定义 `wei-skills` monorepo 中 Skill / MCP 的命名、目录、注释与新增流程。

---

## 1. 命名

| 对象 | 规则 | 示例 |
|------|------|------|
| 目录名 | kebab-case | `hello-world`、`figma-export` |
| Skill `name` | 与目录名 **完全一致** | `name: hello-world` |
| MCP 目录 / 服务名 | `{service}-mcp` | `jira-mcp`、`hello-mcp` |
| MCP 工具名 | snake_case | `echo_message`、`list_issues` |

禁止：空格、下划线目录名、与 `name` 不一致的目录。

---

## 2. Skill 规范

### 最小结构

```text
skills/<name>/
└── SKILL.md          # 必填
```

可选：

```text
skills/<name>/
├── SKILL.md
├── scripts/          # 可被 skill 引用的辅助脚本
├── references/       # 大段参考文档（按需加载）
└── assets/           # 静态资源
```

### SKILL.md frontmatter（必填）

```yaml
---
name: my-skill
description: >
  一句话说明用途。包含触发词：当用户说「…」、想做「…」时使用。
---
```

要求：

- `name` = 目录名
- `description` 必须可被模型用来判断 **是否触发**；写清场景与触发词
- body 使用 **祈使句 / 步骤指令**，面向 Agent，不是面向最终用户的营销文案
- 大段 API 说明、长表格放入 `references/`，在 body 中按需引用，避免 SKILL.md 过长

### 自包含

每个 skill 应可独立安装与理解，不依赖兄弟 skill 的相对路径。

---

## 3. MCP 约定（首期文档级）

- 源码放在 `mcps/<name>/`
- 优先 **stdio** 传输
- 日志、调试信息走 **stderr**（stdout 留给协议）
- 工具名 `snake_case`，参数 schema 明确
- 构建产物 `dist/`，由根 / 本地 `.gitignore` 忽略
- 注册方式：
  - 个人：`claude mcp add <name> -- <command>`
  - 团队：业务项目 `.mcp.json`

详见 [mcps/README.md](../mcps/README.md)。

---

## 4. 注释与代码风格

| 类型 | 要求 |
|------|------|
| Shell 脚本 | 文件头说明用途、用法、参数；函数名语义化 |
| TypeScript | 仅在非显而易见处注释；优先类型表达意图 |
| Markdown | UTF-8；列表与标题层级清晰 |

编辑器统一：见根目录 `.editorconfig`（UTF-8、LF、2 空格）。

---

## 5. 新增 Skill 流程

1. 从模板复制：

   ```bash
   cp -R templates/skill skills/<name>
   ```

2. 修改 `SKILL.md` 的 `name` / `description` / body
3. 安装验证：

   ```bash
   ./scripts/install.sh <name>
   ./scripts/list.sh
   ```

4. 新开 Claude Code 会话，用触发词验证
5. 提交代码（若仓库已初始化 git）

---

## 6. 新增 MCP 流程（二期）

1. 在 `mcps/<name>/` 初始化包（Node + `@modelcontextprotocol/sdk` 等）
2. 实现 stdio server 与至少一个 tool
3. `npm run build`，本地 `claude mcp add` 验证
4. 在 `mcps/README.md` 或子目录 README 记录注册命令

---

## 7. 安装脚本行为摘要

| 脚本 | 行为 |
|------|------|
| `install.sh` | `skills/*` → `~/.claude/skills/<name>` 软链；已存在非本仓路径则跳过 |
| `uninstall.sh` | 只删除指向本仓库 `skills/` 的软链 |
| `list.sh` | 列出仓库 skill 与安装状态 |

项目级：`--project /path/to/app` → `/path/to/app/.claude/skills`。

---

## 8. 不做事项（与首期对齐）

- 不强制 Claude Plugin / marketplace 发布
- 不修改用户全局 `~/.claude.json`
- 安装以 symlink 为主，保持与本机 `~/.claude/skills` 习惯一致
