# 段 4：交棒给官方 skill-creator

**目的**：把 lint 通过的草稿落盘到目标位置，然后明确把控制权交给官方 skill-creator 进入 eval 阶段。本段不需要用户确认（自动转交），但要明确告知。

---

## 步骤 A：确认官方 skill-creator 已安装

检查路径：
```powershell
Test-Path "$env:USERPROFILE\.claude\plugins\marketplaces\claude-plugins-official\plugins\skill-creator\skills\skill-creator\SKILL.md"
```

如返回 `False`：**停下**，告诉用户：

> 官方 skill-creator 未安装，无法进入 eval 阶段。请在 Claude Code 输入框依次执行：
> ```
> /plugin marketplace add anthropics/claude-plugins-official
> /plugin install skill-creator@claude-plugins-official
> /reload-plugins
> ```
> 装完再继续。或者你可以选择"停在草稿"——草稿已经落盘到 [path]，以后想跑 eval 再来。

## 步骤 B：草稿落盘

依据段 1 的复杂度体检结果：

- **单文件 skill** → 落到 `~/.claude/skills/<name>/SKILL.md`
- **文件夹 skill** → 落到 `~/.claude/skills/<name>/`，包含：
  - `SKILL.md`
  - `references/`（如果段 2 拆解里有外挂材料）
  - `scripts/`（如果段 2 标识了脚本化动作）
  - `assets/`（如果段 2 标识了模板/schema）

确认目录创建 + 文件写入成功后，**告知用户具体路径**。

## 步骤 C：交棒措辞（关键）

向用户输出一段**明确转交话术**，让主 Agent 在下一轮自然路由到官方 skill-creator：

```
## 段 4 交棒

草稿已落盘：`~/.claude/skills/<name>/`

**接下来交给官方 skill-creator 跑 eval 阶段**。请告诉我或在新一轮说：

> "用 skill-creator 给 ~/.claude/skills/<name>/ 跑 eval"

或英文（更容易触发官方）：

> "Run evals for the skill at ~/.claude/skills/<name>/"

官方 skill-creator 接手后会：
1. 帮你出 2-3 个测试 prompt
2. 用 subagent 跑 with-skill 和 baseline 对比
3. 开浏览器评审界面
4. 根据你的反馈迭代
5. 最后用 trigger eval 优化 description（这里能用数据化解我们之前讨论的"description 长 vs 短"张力）

需要我现在就替你触发吗？（"是" / "我自己来" / "先停在草稿这里"）
```

## 步骤 D：description 长短决策辅助（化解张力）

在交棒话术里**主动提一句**：

> 提醒：本草稿 description 用了**短版**（X 词）。如果官方 skill-creator 跑完 trigger eval 显示触发率偏低，建议加 pushy 触发短语（参考精华 vs 官方的张力，让数据决定）。

让用户在交棒前对这个张力点有心理预期，避免后续 eval 失败时困惑。

---

## 不要做什么

- ❌ **不要自己跑 eval**——官方有完整工具链（aggregate_benchmark.py, eval-viewer, run_loop.py），重写一遍是蠢。
- ❌ **不要假装自己能跑 trigger optimization**——这需要 `claude -p` subprocess + 真实模型评分，不是 prompt 能模拟的。
- ❌ **不要在草稿落盘前问用户"要不要存"**——段 3 lint 已经过了，段 4 默认落盘是契约。
- ❌ **不要英文化触发词**——保持中文（官方走英文，分工天然）。

## Red Flags

- 🚩 用户说"算了不交棒，先用着" → 提醒"没有 eval 的 skill 在长期使用中会漂移，至少跑一次基础 eval 再用"。如用户坚持，尊重决定，但**明确告知风险**。
- 🚩 用户说"官方 skill-creator 太麻烦，你直接帮我跑测试" → 拒绝。说："官方那套是为这个设计的，我用 prompt 模拟不出量化对比，你真要测我帮你叫 skill-creator"。
