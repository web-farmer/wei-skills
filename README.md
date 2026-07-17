# wei-skills

统一管理 **Agent Skills** 与 **MCP servers** 的 monorepo。

目标：

- 规范目录与命名，方便协作
- 一键安装 skills（symlink 到 Claude Code 可发现路径）
- 提供可运行的最简 skill 案例；MCP 预留标准目录与约定

---

## 快速开始

```bash
git clone <repo-url> wei-skills
cd wei-skills
./scripts/install.sh
```

安装后，skills 会出现在 `~/.claude/skills/<name>`（软链到本仓库）。

只装某一个 skill：

```bash
./scripts/install.sh hello-world
```

项目级安装（写入业务项目 `.claude/skills`）：

```bash
./scripts/install.sh --project /path/to/app
```

卸载（仅删除本仓库创建的软链）：

```bash
./scripts/uninstall.sh
./scripts/uninstall.sh hello-world
```

查看状态：

```bash
./scripts/list.sh
```

也可使用 npm scripts：

```bash
npm run install:skills
npm run list:skills
npm run uninstall:skills
```

---

## 目录说明

```text
wei-skills/
├── skills/           # 全部 Agent Skills（每个子目录一个 skill）
├── mcps/             # 全部 MCP servers（首期仅约定文档）
├── scripts/          # install / uninstall / list
├── templates/        # 新建 skill 的拷贝模板
└── docs/             # 命名、目录、发布规范
```

| 路径 | 说明 |
|------|------|
| `skills/<name>/SKILL.md` | skill 本体；目录名必须等于 frontmatter `name` |
| `mcps/` | MCP 源码与说明，安装链路与 skill 分离 |
| `scripts/install.sh` | 软链 skills 到 `~/.claude/skills` 或项目 `.claude/skills` |
| `templates/skill/` | 新建 skill 时复制此模板 |

---

## 如何新增 Skill

1. 复制模板：

   ```bash
   cp -R templates/skill skills/my-skill
   ```

2. 编辑 `skills/my-skill/SKILL.md`：
   - frontmatter `name` 与目录名一致（kebab-case）
   - `description` 写清用途与触发词

3. 安装并验证：

   ```bash
   ./scripts/install.sh my-skill
   ./scripts/list.sh
   ```

4. 新开 Claude Code 会话，用 description 中的触发词验证是否被加载。

详细约定见 [docs/conventions.md](docs/conventions.md)。

---

## MCP 规划

首期 **不强制实现** MCP 服务，仅保留目录与约定。

开发与注册方式见 [mcps/README.md](mcps/README.md)。

典型流程（二期）：

```bash
cd mcps/<name>
npm install && npm run build
claude mcp add <name> -- node "$(pwd)/dist/index.js"
# 或写入业务项目 .mcp.json 供团队共享
```

---

## 验证方式

1. `./scripts/install.sh` 无报错
2. `ls -la ~/.claude/skills/hello-world` 为指向本仓的 symlink
3. `./scripts/list.sh` 显示 `hello-world` 为 `installed`
4. `./scripts/uninstall.sh hello-world` 后软链消失；再 install 可恢复
5. 新会话中说「hello skill」/「测试 skill」可触发 `hello-world`

---

## 给协作者

```bash
git clone <repo-url> wei-skills
cd wei-skills
./scripts/install.sh
./scripts/list.sh
```

- 安装脚本使用相对路径与 `$HOME`，clone 后即可执行
- 不会覆盖已存在且非本仓库的 skill（跳过并告警）
- 不会修改全局 `~/.claude.json`

---

## 规范

见 [docs/conventions.md](docs/conventions.md)。

## License

MIT
