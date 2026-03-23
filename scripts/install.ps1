# Claude Code Optimizer — PowerShell Installer (Windows)
# By Huzefa Nalkheda Wala | github.com/huzaifa525
#
# Usage:
#   irm https://raw.githubusercontent.com/huzaifa525/claude-code-optimizer/main/scripts/install.ps1 | iex

$Version = "1.0.0"
$Repo = "huzaifa525/claude-code-optimizer"
$Branch = "main"
$BaseUrl = "https://raw.githubusercontent.com/$Repo/$Branch"
$ClaudeHome = Join-Path $env:USERPROFILE ".claude"

Write-Host ""
Write-Host "  Claude Code Optimizer v$Version" -ForegroundColor White
Write-Host "  by Huzefa Nalkheda Wala" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Installing globally to " -NoNewline
Write-Host "~/.claude/" -ForegroundColor Cyan
Write-Host ""

function Download-File {
    param([string]$Url, [string]$Dest, [string]$Label)

    $Dir = Split-Path -Parent $Dest
    if (-not (Test-Path $Dir)) {
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
    }

    if (Test-Path $Dest) {
        Write-Host "  ~ $Label (already exists, skipping)" -ForegroundColor Yellow
        return
    }

    try {
        Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing -ErrorAction Stop
        Write-Host "  + $Label" -ForegroundColor Green
    }
    catch {
        Write-Host "  ! Failed: $Label" -ForegroundColor Red
    }
}

# Skills
Write-Host "  Skills:"
$Skills = @("explore-area", "gen-context", "smart-edit", "token-check", "planning", "commit", "review", "create-pr", "fix-issue", "tdd", "debug-error", "refactor", "document", "security-scan", "perf-check", "dep-check", "changelog", "migrate", "onboard", "plan", "optimize-tokens")
foreach ($Skill in $Skills) {
    Download-File `
        -Url "$BaseUrl/templates/.claude/skills/$Skill/SKILL.md" `
        -Dest (Join-Path $ClaudeHome "skills/$Skill/SKILL.md") `
        -Label "Skill: $Skill"
}

Write-Host ""

# Rules
Write-Host "  Rules:"
$Rules = @("frontend.md", "backend.md", "database.md", "testing.md", "token-optimization.md")
foreach ($Rule in $Rules) {
    Download-File `
        -Url "$BaseUrl/templates/.claude/rules/$Rule" `
        -Dest (Join-Path $ClaudeHome "rules/$Rule") `
        -Label "Rule: $Rule"
}

Write-Host ""

# Hooks
Write-Host "  Hooks:"
$Hooks = @("generate-context.sh", "protect-files.sh", "filter-test-output.sh", "block-dangerous.sh", "auto-format.sh", "commit-reminder.sh", "resume-plan.sh")
foreach ($Hook in $Hooks) {
    Download-File `
        -Url "$BaseUrl/templates/.claude/hooks/$Hook" `
        -Dest (Join-Path $ClaudeHome "hooks/$Hook") `
        -Label "Hook: $Hook"
}

Write-Host ""

# Templates
Write-Host "  Templates:"
Download-File `
    -Url "$BaseUrl/templates/CLAUDE.md" `
    -Dest (Join-Path $ClaudeHome "CLAUDE.md.template") `
    -Label "CLAUDE.md.template"
Download-File `
    -Url "$BaseUrl/templates/.claudeignore" `
    -Dest (Join-Path $ClaudeHome "claudeignore.template") `
    -Label "claudeignore.template"

Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Installed to ~/.claude/:"
Write-Host "    skills/   " -ForegroundColor Cyan -NoNewline
Write-Host "21 skills (explore-area, commit, review, create-pr, fix-issue, etc.)"
Write-Host "    rules/    " -ForegroundColor Cyan -NoNewline
Write-Host "frontend, backend, database, testing"
Write-Host "    hooks/    " -ForegroundColor Cyan -NoNewline
Write-Host "generate-context, protect-files, filter-test-output"
Write-Host ""
Write-Host "  Next steps:"
Write-Host "    1. Copy template to your project:"
Write-Host "       cp ~/.claude/CLAUDE.md.template ./CLAUDE.md" -ForegroundColor DarkGray
Write-Host "       cp ~/.claude/claudeignore.template ./.claudeignore" -ForegroundColor DarkGray
Write-Host "    2. Edit CLAUDE.md with your project details"
Write-Host "    3. Edit rules in ~/.claude/rules/ for your stack"
Write-Host "    4. Start Claude Code and try: " -NoNewline
Write-Host "/explore-area src/" -ForegroundColor Cyan
Write-Host ""
