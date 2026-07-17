# MCP Servers

本目录存放全部 **MCP（Model Context Protocol）** server 源码。

首期仅提供目录约定与注册说明；完整示例服务（如 `hello-mcp`）预留二期实现。

---

## 目录约定

```text
mcps/
├── README.md           # 本文件
└── <name>/             # 每个 MCP 一个子目录
    ├── package.json
    ├── src/
    │   └── index.ts
    ├── dist/           # 构建产物（gitignore）
    └── README.md       # 可选：该服务专属说明
```

命名：`{service}-mcp`，kebab-case，与注册名一致。

---

## 技术约定

| 项 | 约定 |
|----|------|
| 传输 | stdio（默认） |
| 日志 | stderr；stdout 仅用于 MCP 协议 |
| 工具名 | snake_case |
| 运行时 | Node.js >= 18 推荐 |
| SDK | `@modelcontextprotocol/sdk`（或等价实现） |

---

## 本地开发与注册

```bash
cd mcps/<name>
npm install
npm run build

# 注册到当前用户 Claude Code
claude mcp add <name> -- node "$(pwd)/dist/index.js"

# 查看
claude mcp list
```

### 团队共享（业务项目）

在业务仓库根目录写入 `.mcp.json`（示例）：

```json
{
  "mcpServers": {
    "hello-mcp": {
      "command": "node",
      "args": ["/absolute/path/to/wei-skills/mcps/hello-mcp/dist/index.js"]
    }
  }
}
```

也可使用相对路径或包装脚本，按团队环境约定即可。

> 注意：本 monorepo 的 `scripts/install.sh` **只安装 skills**，不注册 MCP。MCP 与 skill 安装链路分离。

---

## 与 Skill 的关系

| | Skill | MCP |
|--|-------|-----|
| 位置 | `skills/` | `mcps/` |
| 发现 | `~/.claude/skills` 或项目 `.claude/skills` | `claude mcp add` / `.mcp.json` / `~/.claude.json` |
| 形态 | `SKILL.md` 指令与可选脚本 | 可执行 server + tools |
| 本仓安装脚本 | `scripts/install.sh` | 暂无（二期可加 `install-mcp.sh`） |

---

## 二期预留

- `mcps/hello-mcp`：TypeScript + stdio echo tool
- `scripts/install-mcp.sh` / `create-mcp.sh`
- 可选 Plugin 包装层

新增 MCP 时请同步更新本 README 的列表（服务名、一句话说明、注册命令）。
