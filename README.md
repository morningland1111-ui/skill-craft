# skill-craft

> [中文](#中文) · [English](#english)

---

## 中文

Claude Code skill：写新 Skill 时的**架构审查 orchestrator**。

补的是官方 skill-creator 没做的「**写之前的判断**」——资格审查、AI 判断 vs 脚本边界、SKILL.md 起草与结构 lint，四段交互式流程。完成后主动交棒给官方 skill-creator 跑 eval。

### 安装

```bash
git clone https://github.com/morningland1111-ui/skill-craft.git ~/.claude/skills/skill-craft
```

Claude Code 下次启动会自动加载。

### 触发

中文召唤："写 skill / 做 skill / 帮我做个 skill / 我要写一个 skill / 把 X 流程做成 skill"

### 4 段流程

| 段 | 任务 | 等用户确认什么 |
|---|---|---|
| **1 审查** | 该不该写？规模多大？ | "写 / 不写 / 改其他方式；如写，单文件 or 文件夹" |
| **2 拆解** | AI 判断 vs 脚本边界、输入输出契约、触发词 | "分工对吗？触发词覆盖你常说的吗？" |
| **3 起草+lint** | 写 SKILL.md 草稿 + 跑结构 lint | "草稿和 lint 报告 OK 吗？" |
| **4 交棒** | 草稿落盘 → 提示调用官方 skill-creator | — |

### 与官方 skill-creator 的分工

| | skill-craft（本仓） | skill-creator（官方） |
|---|---|---|
| 触发 | 中文「写 skill」 | 英文「create skill / improve skill / run evals」 |
| 负责 | 设计阶段：审查、拆解、起草、lint | 评测阶段：trigger eval、with/without 对照、description 优化 |

中文起手 → skill-craft 走完 4 段 → 主动交棒给 skill-creator 跑 eval。

### 系统要求

- Claude Code
- **PowerShell**（`scripts/lint-skill.ps1` 是 PowerShell 写的；Windows 原生支持，macOS / Linux 需装 `pwsh`）

### License

MIT

---

## English

A Claude Code skill: an **architecture-review orchestrator** for designing new skills.

Fills the gap the official `skill-creator` skips — the **"should-we-build-this" judgment phase**: qualification review, AI-judgment vs script-boundary decomposition, SKILL.md drafting, and structural lint. A four-stage interactive flow that hands off to `skill-creator` for evaluation once the draft is ready.

### Install

```bash
git clone https://github.com/morningland1111-ui/skill-craft.git ~/.claude/skills/skill-craft
```

Claude Code will auto-load on next launch.

### Trigger

Chinese-only trigger phrases: "写 skill / 做 skill / 帮我做个 skill / 我要写一个 skill / 把 X 流程做成 skill" (literally "write a skill / make a skill / help me build a skill / I want to write a skill / turn workflow X into a skill").

### 4-stage flow

| Stage | Task | User confirms |
|---|---|---|
| **1 Qualify** | Should you build this? How big? | "Build / don't build / use another approach; if build, single file or folder" |
| **2 Decompose** | AI-judgment vs script boundary, I/O contract, trigger words | "Is the split right? Do the triggers cover what you actually say?" |
| **3 Draft + lint** | Write SKILL.md draft, run structural lint | "Draft and lint report OK?" |
| **4 Hand off** | Write draft to disk → prompt user to invoke official `skill-creator` | — |

### Division of labor with official `skill-creator`

| | skill-craft (this repo) | skill-creator (official) |
|---|---|---|
| Trigger | Chinese "写 skill" phrases | English "create skill / improve skill / run evals" |
| Owns | Design phase: qualify, decompose, draft, lint | Eval phase: trigger eval, with/without ablation, description tuning |

Chinese trigger → skill-craft runs 4 stages → hands off to skill-creator for eval.

### Requirements

- Claude Code
- **PowerShell** (`scripts/lint-skill.ps1` is PowerShell; native on Windows, requires `pwsh` on macOS / Linux)

### License

MIT
