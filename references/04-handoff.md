# 段 4：分流（按 skill 类型决定交棒 or 停在草稿）

**目的**：不再"一律交棒给官方 skill-creator"。先判断 skill 类型——artifact 型走交棒跑 eval，对话引擎型停在草稿、靠用户自跑 N 次后回看验证。

---

## 步骤 A：类型判断（先做这步，不要默认走交棒）

回看段 2 的拆解卡，看两个信号：

| 信号 | artifact 型 | 对话引擎型 |
|---|---|---|
| **输出契约** | 文件 / 数据 / 可枚举决策 / 结构化产物 | 对话流 + 实时判断点，不留产物 |
| **脚本数** | ≥ 1（解析/IO/计算/API 调用） | 0（纯 AI 判断） |

**判定**：
- 两个信号至少有一个属于 artifact 型 → **artifact 型**，走步骤 B-D（交棒）
- 两个信号都是对话引擎型 → **对话引擎型**，走步骤 E（停在草稿）

**对话引擎型的本质特征**：产出是 AI 引导的对话流，每轮内含判断点暴露给用户，对错在用户体验里（能不能叫停 / 能不能纠偏 / 跑完状态有没有改善），没法用结构化输入输出对量化 eval。典型场景：对话式追问、情绪/思考梳理、协作纪律约束、自助式咨询引擎。

---

## artifact 型分支（步骤 B-D）

### 步骤 B：确认官方 skill-creator 已安装

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

### 步骤 C：草稿落盘

依据段 1 的复杂度体检结果：

- **单文件 skill** → 落到 `~/.claude/skills/<name>/SKILL.md`
- **文件夹 skill** → 落到 `~/.claude/skills/<name>/`，包含：
  - `SKILL.md`
  - `references/`（如果段 2 拆解里有外挂材料）
  - `scripts/`（如果段 2 标识了脚本化动作）
  - `assets/`（如果段 2 标识了模板/schema）

确认目录创建 + 文件写入成功后，**告知用户具体路径**。

### 步骤 D：交棒措辞

向用户输出明确转交话术：

```
## 段 4 交棒（artifact 型）

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
5. 最后用 trigger eval 优化 description

提醒：本草稿 description 用了**短版**（X 词）。如果官方 skill-creator 跑完 trigger eval 显示触发率偏低，建议加 pushy 触发短语。

需要我现在就替你触发吗？（"是" / "我自己来" / "先停在草稿这里"）
```

---

## 对话引擎型分支（步骤 E）

### 步骤 E：落盘 + 明确"停在这里"

草稿已经在段 3 写入磁盘（路径在段 3 已告知）。本段**不交棒**，只做一件事：让用户明确知道**为什么停在这里 + 验证路径是什么**。

输出措辞：

```
## 段 4 分流：对话引擎型 → 停在草稿

判断依据（段 2 拆解卡）：
- 输出契约：对话流 + 实时判断点，无 artifact
- 脚本数：0

**官方 skill-creator 的 eval 跑不了这类 skill**——它假设有结构化输入输出对，trigger eval 看召唤率、output eval 看产物质量，但对话引擎的"对错"在用户体验里（能不能叫停 / 能不能纠偏 / 跑完状态有没有改善），只有你能判。

**验证路径**：
1. 把草稿当 v0.1 用，跑 3 次真实场景
2. 每次跑完记下：哪些 Red Flags 触发了？哪些规则没用上？哪些"未命中"出现了？
3. 跑完 3 次回看草稿——删掉从未用上的部分，补上重复出现的新模式

**不要**给这类 skill 加 tests / eval scaffolding——会鼓励 AI 为了通过测试而结构化对话，破坏空间感，违背设计本意。

草稿路径：`~/.claude/skills/<name>/`

要继续在这条会话里讨论，还是收工？
```

---

## 共同的不要做

- ❌ **不要自己跑 eval**——artifact 型有官方工具链；对话引擎型本来就不该跑 eval。
- ❌ **不要假装自己能跑 trigger optimization**——这需要 `claude -p` subprocess + 真实模型评分。
- ❌ **不要在草稿落盘前问用户"要不要存"**——段 3 lint 已经过了，段 4 默认草稿已落盘。
- ❌ **不要英文化触发词**——保持中文（官方走英文，分工天然）。
- ❌ **不要把对话引擎型硬塞进交棒流程**——用户撞墙后回来骂的就是这个坑。

## Red Flags

- 🚩 段 2 拆解卡明明写"0 脚本 + 对话流输出"，段 4 还想交棒 → **强行交棒会让 eval 失败 + 用户挫败**。停下走分支 E。
- 🚩 用户说"算了不交棒，先用着"（artifact 型）→ 提醒"没有 eval 的 artifact 型 skill 在长期使用中会漂移，至少跑一次基础 eval 再用"。如用户坚持，尊重决定，但**明确告知风险**。
- 🚩 用户说"官方 skill-creator 太麻烦，你直接帮我跑测试" → 拒绝。说："官方那套是为这个设计的，我用 prompt 模拟不出量化对比，你真要测我帮你叫 skill-creator"。
- 🚩 对话引擎型用户问"那怎么知道做得好不好" → 回答："跑 3 次真实场景。看 v0.1 草稿哪些触发了、哪些没用上、哪些'未命中'反复出现。这是宪法 §8 + 版本声明里写明的验证路径"。不要被推回去搞 eval。
