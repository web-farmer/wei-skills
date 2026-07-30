# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**wei-skills** is a monorepo for managing Agent Skills and MCP servers. It unifies skills (Skills that extend Claude Code capabilities) and pre-configured MCP servers (Model Context Protocol servers) under a standardized directory structure and installation system.

Key goals:
- Enforce consistent naming and organization for collaboration
- Provide one-click installation via symlinks
- Include minimal runnable skill examples
- Support both global installation (`~/.claude/skills`) and project-level installation

## Core Structure

```
wei-skills/
├── skills/                 # Agent skills; each subdir is one skill (name = kebab-case)
├── mcps/                   # MCP servers (documentation-only at launch)
├── scripts/                # Installation & management tools
│   ├── install.sh          # Symlink skills to ~/.claude/skills or project .claude/skills
│   ├── uninstall.sh
│   └── list.sh
├── templates/              # Reusable templates for new skills
└── docs/                   # Conventions and setup guides
    └── conventions.md
```

**skills/*/** contains skills that implement tool call logic, human-in-the-loop prompting, or MCP server implementations. Each skill has an `SKILL.md` with frontmatter and usage instructions.

**mcps/*/** is for MCP servers (later implementations will live here). Currently limited to documentation.

## File Naming & Organization Rules

- **Directory names** must be **kebab-case** (`hello-world`, `figma-export`)
- **SKILL.md** frontmatter:
  ```yaml
  ---
  name: hello-world
  description: >
    开发者友好的技能示例。当用户说「hello skill」「测试 skill」时触发。
  ---
  ```
- Each skill must be self-contained: no external dependencies on other skills' paths
- Optional directories: `references/` (long docs), `assets/`, `scripts/`

## Development Flow

1. **Create new skill**:
   ```
   cp -R templates/skill skills/new-skill
   edit skills/new-skill/SKILL.md (update name, description, body)
   ./scripts/install.sh new-skill
   ./scripts/list.sh
   ```

2. **Run install scripts**:
   ```
   npm run install:skills   # or ./scripts/install.sh
   npm run list:skills
   ```

3. **Validate**:
   - Install creates/ refreshes symlinks pointing into the repo
   - Verify via `ls ~/.claude/skills/<skill>` or project `.claude/skills/`
   - Test trigger via Claude session ("hello skill")

## Skill Structure & Content Requirements

**SKILL.md** must include:
- Frontmatter (`name` = directory name, description with trigger words)
- Clear trigger description (what user says to activate)
- Steps for Claude to use it (function calls, tools, etc.)
- Usage notes in imperative language (agent-facing)

Example triggers: 「hello skill」, 「测试 skill」, 「code review」, 「提交代码」

For any skill:
- Use the exact description text provided in the `SKILL.md` frontmatter
- When user uses the trigger, invoke the skill's implementation steps

This file is auto-generated from the monorepo structure and conventions for future Claude Code instances.