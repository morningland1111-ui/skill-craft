---
name: skill-craft
description: 设计与起草新 Skill 的架构审查 orchestrator。包含资格审查、AI 判断 vs 脚本边界拆解、SKILL.md 起草与结构 lint 四个交互式阶段。触发场景："写 skill / 做 skill / 帮我做个 skill / 我要写一个 skill / 把 X 流程做成 skill"。本 Skill 只负责设计阶段，完成草稿后会主动交棒给官方 skill-creator 进行 eval 与描述优化——评测、跑测试、优化已有 skill 描述请直接调 skill-creator，不要选本 Skill。
---

# skill-craft

设计阶段的 orchestrator。负责把"想写一个 skill"的模糊念头，变成"经过审查、拆解清晰、lint 通过的 SKILL.md 草稿"，然后交棒给官方 skill-creator 跑 eval。

## 为什么需要这个 skill

官方 skill-creator 默认你**已经决定要写**，直接进入 Capture Intent。本 skill 补的是**"写之前的架构判断"**——综合中文社区实战经验，覆盖资格审查、AI/脚本分工、结构 lint、三层注意力权重等官方没讲的设计陷阱。

## 4 段路由表（强制按序执行 + 每段外显确认）

| 段 | 任务 | 读哪个 reference | 等用户确认什么 |
|---|---|---|---|
| **1 审查** | 该不该写？规模多大？ | `references/01-qualify.md` | "结论：写 / 不写 / 改其他方式；如写，单文件 or 文件夹" |
| **2 拆解** | AI 判断 vs 脚本边界、输入输出契约、触发词 | `references/02-decompose.md` | "分工对吗？触发词覆盖你常说的吗？" |
| **3 起草+lint** | 写 SKILL.md 草稿 + 跑结构 lint | `references/03-draft-and-lint.md` + `scripts/lint-skill.ps1` | "草稿和 lint 报告 OK 吗？" |
| **4 交棒** | 调用官方 skill-creator 进入 eval | `references/04-handoff.md` | （自动转交，无需确认） |

## 执行规则（核心约束）

1. **必须按 1→2→3→4 顺序**。跳段会丢上下文（如直接到 3 不知道是单文件还是文件夹）。
2. **每段完成后必须先输出结果，等用户明确说"OK / 继续"才能进下一段**。检验：进入下一段之前问自己"用户是否已经确认了上一段的输出？"
3. **每段开头先读对应的 reference 文件**，不要凭记忆做。检验：开始执行前确认"我已经 Read 了 references/0X-*.md"。
4. **段 3 起草后必须跑 lint 脚本**。检验："scripts/lint-skill.ps1 输出我已经贴给用户？"
5. **段 4 交棒之前必须确认官方 skill-creator 已安装**。如未安装，停下来告知用户。

## Red Flags（停止区——出现立刻停手不要绕过）

- 🚩 用户说"快速搞一个" / "随便弄个 skill" → **不要跳过段 1 审查**，最容易做废。说："我先做 30 秒资格审查，免得做白工"。
- 🚩 段 1 审查结论是"不该写" → **不要因为用户已经说要写就硬往下做**。重申理由，给替代方案（CLAUDE.md / 一次性 prompt / 现有 skill）。
- 🚩 段 3 lint 有红色 fail（缺 Red Flags、缺检验句、参数无源声明）→ **不要带着 fail 进段 4**。修了再走。
- 🚩 用户中途说"直接给我草稿" → 短回应解释为什么前两段不能省（30 秒成本，避免后续返工），让用户在知情下决定。
- 🚩 自己想"这次特殊，跳过外显确认吧" → **没有这次特殊**。每段必须等用户点头。

## 边界声明（不做什么）

- **不跑 eval、不做量化测试、不优化已有 skill 的描述** —— 这些是官方 skill-creator 的活，段 4 交棒。
- **不修改已经发布的 skill** —— 改用户已有 skill 用官方的 improve 模式。
- **不接管纯英文请求** —— "create a skill" 类英文请求直接路由到官方 skill-creator。

## 失败模式诊断

| 症状 | 通常是哪段出问题 |
|---|---|
| 写完发现根本不该写 / 用一次就废 | 段 1 审查跳过或敷衍 |
| AI 写出的 skill 关键步骤总是不稳定 | 段 2 没把"应该脚本化的判断"识别出来 |
| description 没人触发 / 老是误触发 | 段 2 触发词没收集真实用户表达 |
| skill 跑长会话就跑偏 | 段 3 缺 Red Flags / 检验句 / 入口路由表 |
| 交棒后官方 eval 失败 | 段 3 lint 没过就硬交棒 |
