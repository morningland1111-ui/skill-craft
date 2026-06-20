# 段 3：起草 SKILL.md + 结构 lint

**目的**：把段 2 的拆解卡变成可用的 SKILL.md 草稿（必要时含 references/scripts/assets 骨架），然后跑结构 lint 确保过最低门槛。

**输出契约**：本段结束输出 (a) SKILL.md 草稿全文 + (b) lint 报告（全 pass 才能进段 4）。

---

## 步骤 A：用模板起草

从 `assets/SKILL.md.template` 复制骨架，依次填：

1. **YAML frontmatter**：
   - `name`：短，全小写，连字符分隔
   - `description`：基于段 2 触发词候选。**先写短版**，包含"触发场景 + 一句话功能 + 边界声明"。例：
     ```
     设计与起草新 Skill 的架构审查。触发："写 skill / 做 skill / 帮我做个 skill"。
     评测请用 skill-creator。
     ```

2. **正文结构**（按段 1 体检结果定）：
   - **单文件 skill**：SKILL.md 一个文件 ≤100 行，所有规则内联
   - **文件夹 skill**：SKILL.md ≤100 行薄壳 + references/scripts/assets

3. **正文必含 6 个模块**（缺一会被 lint 标 fail）：
   - 简短"why"段（为什么需要这个 skill，1-3 句）
   - 路由表 / 流程步骤（表格优先，AI 长会话压缩后更容易保留表格）
   - 执行规则（祈使句，每条后跟"检验：..."）
   - **Red Flags 区**（停止区——把 AI 真实会说的借口提前拦截）
   - 边界声明（不做什么 / 推给谁）
   - 失败模式诊断（症状 → 通常哪步出问题）

## 步骤 B：写作规则（lint 会查）

### 规则 1：祈使句 + 解释 why
- ❌ "应该谨慎写入" → 太软
- ✓ "执行写入前问用户确认。**Why**：上次自动写入覆盖了用户未保存的内容。"

### 规则 2：原则 + 检验句（不是原则 + 解释）
- ❌ "默认 dry-run，因为安全很重要" → 没有可操作的检验
- ✓ "默认 dry-run。**检验**：执行写入前问自己'用户是否已明确确认？'"

### 规则 3：好坏对比，不是抽象禁止
- ❌ "不要在 description 里写抽象描述" → AI 不知道替代方案
- ✓ "不写'强大的多功能信息处理'，要写'当用户需要读取 RSS 源并按格式输出时使用'"

### 规则 4：参数说明必须声明值的来源
- ❌ "user_id：用户 ID"
- ✓ "user_id：**取自上游 GET /api/me 的 id 字段，不能从自然语言推断**。无值时先调 GET /api/me。"

### 规则 5：示例 ≥ 2 个不同方向
- ❌ 只给 1 个示例 → AI 当默认值（首选项效应）
- ✓ 给 2-3 个明显不同的示例，并显式说"这些只是示例，根据实际情况调整"

### 规则 6：返回值/输出先事实后动作
- ❌ "下一步：请确认是否发送" → AI 还没意识到上一步成了
- ✓ "已生成草稿 weekly.md（348 字，4 项任务）。下一步：可选择发送或修改。"

## 步骤 C：写 Red Flags 区

把"AI 真实会找的借口"提前抄进 SKILL.md。常见借口模板：

- 🚩 "用户已经说要做了，跳过审查吧"
- 🚩 "这次特殊，先跳过 dry-run"
- 🚩 "用户没明说，按上下文猜测大概是 X"
- 🚩 "下一步省事，直接 [破坏性动作]"
- 🚩 "外显确认太啰嗦，这次直接做"

针对你的 skill 至少写 3-5 条 Red Flags。**不要写抽象的（"小心使用"）**，写 AI 真的会说的具体话。

## 步骤 D：跑 lint 脚本

```powershell
powershell -ExecutionPolicy Bypass -File ~/.claude/skills/skill-craft/scripts/lint-skill.ps1 -SkillPath <draft-path>
```

输出格式：
```
[PASS] description 长度 32 词（≤50 词）
[PASS] 含 Red Flags 区
[FAIL] 缺少"检验"句——找到 8 条规则但 0 条配检验句
[WARN] 参数说明里 3 处缺"取自/来自/源于"等来源声明
[FAIL] 示例数 = 1（要求 ≥ 2）
```

**任何 FAIL 必须修了再走**。WARN 让用户判断（有时候真的不需要）。

---

## 本段输出模板（给用户）

```
## 段 3 草稿 + lint

**SKILL.md 草稿**（70 行）：
[完整内容]

**lint 报告**：
[PASS] description 32 词
[PASS] 6 个必含模块齐全
[PASS] Red Flags 区 4 条
[PASS] 检验句 11/13 条规则
[WARN] 示例数 = 2，建议加到 3
[PASS] 参数来源声明完整

**结论**：lint 全 pass，1 处建议增强。
**询问**：要按建议加第 3 个示例吗？OK 后进段 4 交棒给官方 skill-creator。
```

或带 FAIL：

```
[FAIL] 缺 Red Flags 区
[FAIL] description 67 词超长

**结论**：2 处 FAIL 必修。我现在改：
- 加 Red Flags 区（草稿如下...）
- description 砍到 38 词（前后对比...）

确认这些修改后再进段 4。
```
