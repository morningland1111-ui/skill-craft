#Requires -Version 5.1
<#
SKILL.md 结构 lint。
用法： powershell -ExecutionPolicy Bypass -File lint-skill.ps1 -SkillPath <SKILL.md>
退出码： 0=全部 pass 或仅 WARN；1=有 FAIL
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SkillPath
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $SkillPath)) {
    Write-Host "[FAIL] 文件不存在: $SkillPath" -ForegroundColor Red
    exit 1
}

$raw = Get-Content -Path $SkillPath -Raw -Encoding UTF8
$failCount = 0
$warnCount = 0

function Emit-Pass($msg) { Write-Host "[PASS] $msg" -ForegroundColor Green }
function Emit-Warn($msg) {
    Write-Host "[WARN] $msg" -ForegroundColor Yellow
    $script:warnCount++
}
function Emit-Fail($msg) {
    Write-Host "[FAIL] $msg" -ForegroundColor Red
    $script:failCount++
}

# --- 1. 解析 frontmatter ---
$fmMatch = [regex]::Match($raw, '(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$')
if (-not $fmMatch.Success) {
    Emit-Fail "缺少 YAML frontmatter（--- 包围的 name/description 块）"
    exit 1
}
$frontmatter = $fmMatch.Groups[1].Value
$body = $fmMatch.Groups[2].Value

# --- 2. name ---
if ($frontmatter -match '(?m)^\s*name:\s*(.+)$') {
    $name = $matches[1].Trim()
    if ($name -match '^[a-z][a-z0-9-]*$') {
        Emit-Pass "name 合法: $name"
    } else {
        Emit-Warn "name '$name' 不符合 lowercase-with-hyphens 惯例"
    }
} else {
    Emit-Fail "frontmatter 缺 name 字段"
}

# --- 3. description ---
if ($frontmatter -match '(?ms)^\s*description:\s*(.+?)(?=\r?\n\s*\w+:|$)') {
    $desc = $matches[1].Trim() -replace '\s+', ' '
    $wordCount = ($desc -split '\s+' | Where-Object { $_ }).Count
    if ($wordCount -le 60) {
        Emit-Pass "description 长度 $wordCount 词（≤60）"
    } elseif ($wordCount -le 100) {
        Emit-Warn "description 长度 $wordCount 词，偏长（精华派建议 <60；如官方 trigger eval 显示 undertrigger 再加长）"
    } else {
        Emit-Fail "description 长度 $wordCount 词，远超 100。会污染所有对话上下文"
    }

    # 触发场景 / 触发词
    if ($desc -match '触发|Use when|use when|trigger|场景|when users') {
        Emit-Pass "description 含触发场景描述"
    } else {
        Emit-Fail "description 没有'何时使用'的触发场景——AI 不知道什么时候召唤"
    }
} else {
    Emit-Fail "frontmatter 缺 description 字段"
}

# --- 4. 正文必含 6 模块 ---
$required = @{
    'Red Flags 区'   = '(?im)^#{1,3}\s*(red\s*flags?|🚩|停止区)'
    '执行规则段'      = '(?im)^#{1,3}\s*(执行规则|core\s*rules|rules|规则)'
    '边界声明'        = '(?im)^#{1,3}\s*(边界|boundar|不做|不接管|out\s*of\s*scope)'
}
foreach ($k in $required.Keys) {
    if ([regex]::IsMatch($body, $required[$k])) {
        Emit-Pass "含 $k"
    } else {
        Emit-Fail "缺少 $k"
    }
}

# --- 5. 检验句 ---
$ruleMarkers  = [regex]::Matches($body, '(?m)^\s*[\d\-*]+\.?\s+').Count
$checkMarkers = [regex]::Matches($body, '检验[:：]|\bcheck:|\bcheckpoint:').Count
if ($ruleMarkers -ge 3) {
    if ($checkMarkers -ge [math]::Max(2, [int]($ruleMarkers * 0.3))) {
        Emit-Pass "检验句 $checkMarkers 条（规则约 $ruleMarkers 条）"
    } else {
        Emit-Warn "检验句仅 $checkMarkers 条，对应 $ruleMarkers 条规则，比例偏低（建议 ≥30%）"
    }
}

# --- 6. Red Flags 区条数 ---
$redFlagItems = [regex]::Matches($body, '(?m)^\s*(?:[-*]\s+)?🚩').Count
if ($redFlagItems -ge 3) {
    Emit-Pass "Red Flags 条数 $redFlagItems（≥3）"
} elseif ($redFlagItems -ge 1) {
    Emit-Warn "Red Flags 仅 $redFlagItems 条，建议 ≥3 覆盖常见借口"
} else {
    Emit-Fail "Red Flags 区为空（或没用 🚩 标记）。AI 找借口时无可拦截"
}

# --- 7. 参数源声明 ---
$paramBlocks  = [regex]::Matches($body, '(?im)(参数|param|argument).{0,40}[:：]').Count
$sourceMarkers = [regex]::Matches($body, '取自|来自|源于|from\s+(the\s+)?(upstream|api|tool|previous)|不能.*推断').Count
if ($paramBlocks -ge 2) {
    if ($sourceMarkers -lt 1) {
        Emit-Warn "发现 $paramBlocks 处参数提及，但 0 处声明值来源（'取自/来自/源于/不能推断'）——可能导致 AI 编造参数值"
    } else {
        Emit-Pass "参数源声明 $sourceMarkers 处"
    }
}

# --- 8. 示例多样性 ---
$exampleHeaders = [regex]::Matches($body, '(?im)example\s*\d+|示例\s*\d+|例\s*\d+|\*\*示例\*\*|\*\*example\*\*').Count
if ($exampleHeaders -ge 2) {
    Emit-Pass "示例数 $exampleHeaders（≥2，对抗首选项效应）"
} elseif ($exampleHeaders -eq 1) {
    Emit-Warn "示例数 = 1。单个示例会被模型当默认值（首选项效应），建议 ≥2 不同方向"
}

# --- 9. SKILL.md 行数 ---
$lineCount = ($raw -split "`n").Count
if ($lineCount -le 100) {
    Emit-Pass "SKILL.md 行数 $lineCount（≤100，符合薄壳原则）"
} elseif ($lineCount -le 200) {
    Emit-Warn "SKILL.md 行数 $lineCount，建议拆 references/ 减薄"
} else {
    Emit-Fail "SKILL.md 行数 $lineCount，严重过厚。复杂内容必须外挂到 references/"
}

# --- summary ---
Write-Host ""
Write-Host "==== 总结 ====" -ForegroundColor Cyan
Write-Host "FAIL: $failCount    WARN: $warnCount"
if ($failCount -gt 0) {
    Write-Host "结论: 不能进段 4 交棒。必须先修 FAIL。" -ForegroundColor Red
    exit 1
} elseif ($warnCount -gt 0) {
    Write-Host "结论: 可进段 4，但建议先评估 WARN 项。" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "结论: 全 pass，可交棒。" -ForegroundColor Green
    exit 0
}
