#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");

const VERSION = "1.0.0";
const CLAUDE_HOME = path.join(os.homedir(), ".claude");
const TEMPLATES_DIR = path.join(__dirname, "..", "templates");

const BOLD = "\x1b[1m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const CYAN = "\x1b[36m";
const DIM = "\x1b[2m";
const RESET = "\x1b[0m";

function log(msg) {
  console.log(msg);
}

function success(msg) {
  console.log(`${GREEN}  + ${RESET}${msg}`);
}

function skip(msg) {
  console.log(`${YELLOW}  ~ ${RESET}${msg}`);
}

function info(msg) {
  console.log(`${CYAN}  i ${RESET}${msg}`);
}

function copyDirRecursive(src, dest) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }

  const entries = fs.readdirSync(src, { withFileTypes: true });
  let copied = 0;

  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      copied += copyDirRecursive(srcPath, destPath);
    } else {
      if (!fs.existsSync(destPath)) {
        fs.copyFileSync(srcPath, destPath);
        copied++;
      }
    }
  }

  return copied;
}

function copyFileIfNotExists(src, dest, label) {
  if (fs.existsSync(dest)) {
    skip(`${label} already exists, skipping`);
    return false;
  }
  const dir = path.dirname(dest);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.copyFileSync(src, dest);
  success(label);
  return true;
}

function installGlobal() {
  log("");
  log(`${BOLD}  Claude Code Optimizer v${VERSION}${RESET}`);
  log(`${DIM}  by Huzefa Nalkheda Wala${RESET}`);
  log("");
  log(`  Installing globally to ${CYAN}~/.claude/${RESET}`);
  log("");

  // Ensure ~/.claude exists
  if (!fs.existsSync(CLAUDE_HOME)) {
    fs.mkdirSync(CLAUDE_HOME, { recursive: true });
  }

  // Install skills
  const skillsSrc = path.join(TEMPLATES_DIR, ".claude", "skills");
  const skillsDest = path.join(CLAUDE_HOME, "skills");

  if (fs.existsSync(skillsSrc)) {
    const skills = fs.readdirSync(skillsSrc, { withFileTypes: true }).filter((e) => e.isDirectory());
    let skillCount = 0;

    for (const skill of skills) {
      const srcSkill = path.join(skillsSrc, skill.name);
      const destSkill = path.join(skillsDest, skill.name);
      const destSkillFile = path.join(destSkill, "SKILL.md");

      if (fs.existsSync(destSkillFile)) {
        skip(`Skill: ${skill.name} (already exists)`);
      } else {
        copyDirRecursive(srcSkill, destSkill);
        success(`Skill: ${skill.name}`);
        skillCount++;
      }
    }

    if (skillCount === 0) {
      info("All skills already installed");
    }
  }

  log("");

  // Install rules
  const rulesSrc = path.join(TEMPLATES_DIR, ".claude", "rules");
  const rulesDest = path.join(CLAUDE_HOME, "rules");

  if (fs.existsSync(rulesSrc)) {
    const rules = fs.readdirSync(rulesSrc).filter((f) => f.endsWith(".md"));
    let ruleCount = 0;

    for (const rule of rules) {
      const srcRule = path.join(rulesSrc, rule);
      const destRule = path.join(rulesDest, rule);

      if (fs.existsSync(destRule)) {
        skip(`Rule: ${rule} (already exists)`);
      } else {
        if (!fs.existsSync(rulesDest)) {
          fs.mkdirSync(rulesDest, { recursive: true });
        }
        fs.copyFileSync(srcRule, destRule);
        success(`Rule: ${rule}`);
        ruleCount++;
      }
    }

    if (ruleCount === 0) {
      info("All rules already installed");
    }
  }

  log("");

  // Install hooks
  const hooksSrc = path.join(TEMPLATES_DIR, ".claude", "hooks");
  const hooksDest = path.join(CLAUDE_HOME, "hooks");

  if (fs.existsSync(hooksSrc)) {
    const hooks = fs.readdirSync(hooksSrc).filter((f) => f.endsWith(".sh"));
    let hookCount = 0;

    for (const hook of hooks) {
      const srcHook = path.join(hooksSrc, hook);
      const destHook = path.join(hooksDest, hook);

      if (fs.existsSync(destHook)) {
        skip(`Hook: ${hook} (already exists)`);
      } else {
        if (!fs.existsSync(hooksDest)) {
          fs.mkdirSync(hooksDest, { recursive: true });
        }
        fs.copyFileSync(srcHook, destHook);
        // Make executable on Unix
        try {
          fs.chmodSync(destHook, 0o755);
        } catch (_) {}
        success(`Hook: ${hook}`);
        hookCount++;
      }
    }

    if (hookCount === 0) {
      info("All hooks already installed");
    }
  }

  log("");

  // Install CLAUDE.md template to ~/.claude/ (as a reference, not active)
  const claudeMdSrc = path.join(TEMPLATES_DIR, "CLAUDE.md");
  const claudeMdDest = path.join(CLAUDE_HOME, "CLAUDE.md.template");
  copyFileIfNotExists(claudeMdSrc, claudeMdDest, "CLAUDE.md.template (copy to your project root as CLAUDE.md)");

  // Install .claudeignore template
  const ignoreSrc = path.join(TEMPLATES_DIR, ".claudeignore");
  const ignoreDest = path.join(CLAUDE_HOME, "claudeignore.template");
  copyFileIfNotExists(ignoreSrc, ignoreDest, "claudeignore.template (copy to your project root as .claudeignore)");

  log("");
  log(`${BOLD}${GREEN}  Installation complete!${RESET}`);
  log("");
  log("  What was installed:");
  log(`    ${CYAN}~/.claude/skills/${RESET}     21 skills (explore-area, gen-context, smart-edit, token-check,`);
  log(`                          planning, commit, review, create-pr, fix-issue, tdd,`);
  log(`                          debug-error, refactor, document, security-scan, perf-check,`);
  log(`                          dep-check, changelog, migrate, onboard, plan, optimize-tokens)`);
  log(`    ${CYAN}~/.claude/rules/${RESET}      4 rules (frontend, backend, database, testing)`);
  log(`    ${CYAN}~/.claude/hooks/${RESET}      3 hooks (generate-context, protect-files, filter-test-output)`);
  log(`    ${CYAN}~/.claude/${RESET}            CLAUDE.md.template + claudeignore.template`);
  log("");
  log("  Next steps:");
  log(`    1. Copy templates to your project:`);
  log(`       ${DIM}cp ~/.claude/CLAUDE.md.template ./CLAUDE.md${RESET}`);
  log(`       ${DIM}cp ~/.claude/claudeignore.template ./.claudeignore${RESET}`);
  log(`    2. Edit CLAUDE.md with your project details`);
  log(`    3. Edit rules in ~/.claude/rules/ for your stack`);
  log(`    4. Start Claude Code and try: ${CYAN}/explore-area src/${RESET}`);
  log("");
}

function installProject() {
  const projectDir = process.cwd();

  log("");
  log(`${BOLD}  Claude Code Optimizer v${VERSION}${RESET}`);
  log(`${DIM}  by Huzefa Nalkheda Wala${RESET}`);
  log("");
  log(`  Installing to project: ${CYAN}${projectDir}${RESET}`);
  log("");

  // CLAUDE.md
  copyFileIfNotExists(
    path.join(TEMPLATES_DIR, "CLAUDE.md"),
    path.join(projectDir, "CLAUDE.md"),
    "CLAUDE.md"
  );

  // .claudeignore
  copyFileIfNotExists(
    path.join(TEMPLATES_DIR, ".claudeignore"),
    path.join(projectDir, ".claudeignore"),
    ".claudeignore"
  );

  log("");

  // .claude directory
  const claudeDir = path.join(projectDir, ".claude");

  // Skills
  const skillsSrc = path.join(TEMPLATES_DIR, ".claude", "skills");
  const skills = fs.readdirSync(skillsSrc, { withFileTypes: true }).filter((e) => e.isDirectory());
  for (const skill of skills) {
    const dest = path.join(claudeDir, "skills", skill.name);
    if (fs.existsSync(path.join(dest, "SKILL.md"))) {
      skip(`Skill: ${skill.name} (exists)`);
    } else {
      copyDirRecursive(path.join(skillsSrc, skill.name), dest);
      success(`Skill: ${skill.name}`);
    }
  }

  log("");

  // Rules
  const rulesSrc = path.join(TEMPLATES_DIR, ".claude", "rules");
  const rules = fs.readdirSync(rulesSrc).filter((f) => f.endsWith(".md"));
  for (const rule of rules) {
    const dest = path.join(claudeDir, "rules", rule);
    if (fs.existsSync(dest)) {
      skip(`Rule: ${rule} (exists)`);
    } else {
      if (!fs.existsSync(path.join(claudeDir, "rules"))) {
        fs.mkdirSync(path.join(claudeDir, "rules"), { recursive: true });
      }
      fs.copyFileSync(path.join(rulesSrc, rule), dest);
      success(`Rule: ${rule}`);
    }
  }

  log("");

  // Hooks
  const hooksSrc = path.join(TEMPLATES_DIR, ".claude", "hooks");
  const hooks = fs.readdirSync(hooksSrc).filter((f) => f.endsWith(".sh"));
  for (const hook of hooks) {
    const dest = path.join(claudeDir, "hooks", hook);
    if (fs.existsSync(dest)) {
      skip(`Hook: ${hook} (exists)`);
    } else {
      if (!fs.existsSync(path.join(claudeDir, "hooks"))) {
        fs.mkdirSync(path.join(claudeDir, "hooks"), { recursive: true });
      }
      fs.copyFileSync(path.join(hooksSrc, hook), dest);
      try { fs.chmodSync(dest, 0o755); } catch (_) {}
      success(`Hook: ${hook}`);
    }
  }

  log("");

  // Settings
  const settingsSrc = path.join(TEMPLATES_DIR, ".claude", "settings.json");
  const settingsDest = path.join(claudeDir, "settings.json");
  copyFileIfNotExists(settingsSrc, settingsDest, "settings.json (hook config)");

  log("");
  log(`${BOLD}${GREEN}  Installation complete!${RESET}`);
  log("");
  log("  Next steps:");
  log("    1. Edit CLAUDE.md with your project details");
  log("    2. Edit .claude/rules/ for your stack");
  log(`    3. Start Claude Code and try: ${CYAN}/explore-area src/${RESET}`);
  log("");
}

function uninstall() {
  log("");
  log(`${BOLD}  Claude Code Optimizer — Uninstall${RESET}`);
  log("");

  const skillNames = [
    "explore-area", "gen-context", "smart-edit", "token-check",
    "planning", "commit", "review", "create-pr", "fix-issue", "tdd",
    "debug-error", "refactor", "document", "security-scan", "perf-check",
    "dep-check", "changelog", "migrate", "onboard", "plan", "optimize-tokens"
  ];

  const items = [
    ...skillNames.map((s) => ({ path: path.join(CLAUDE_HOME, "skills", s), label: `Skill: ${s}` })),
    { path: path.join(CLAUDE_HOME, "rules", "frontend.md"), label: "Rule: frontend.md" },
    { path: path.join(CLAUDE_HOME, "rules", "backend.md"), label: "Rule: backend.md" },
    { path: path.join(CLAUDE_HOME, "rules", "database.md"), label: "Rule: database.md" },
    { path: path.join(CLAUDE_HOME, "rules", "testing.md"), label: "Rule: testing.md" },
    { path: path.join(CLAUDE_HOME, "hooks", "generate-context.sh"), label: "Hook: generate-context.sh" },
    { path: path.join(CLAUDE_HOME, "hooks", "protect-files.sh"), label: "Hook: protect-files.sh" },
    { path: path.join(CLAUDE_HOME, "hooks", "filter-test-output.sh"), label: "Hook: filter-test-output.sh" },
    { path: path.join(CLAUDE_HOME, "CLAUDE.md.template"), label: "CLAUDE.md.template" },
    { path: path.join(CLAUDE_HOME, "claudeignore.template"), label: "claudeignore.template" },
  ];

  let removed = 0;
  for (const item of items) {
    if (fs.existsSync(item.path)) {
      fs.rmSync(item.path, { recursive: true, force: true });
      success(`Removed: ${item.label}`);
      removed++;
    }
  }

  if (removed === 0) {
    info("Nothing to remove — not installed globally");
  } else {
    log("");
    log(`${GREEN}  Removed ${removed} items.${RESET}`);
  }
  log("");
}

function showHelp() {
  log("");
  log(`${BOLD}  Claude Code Optimizer v${VERSION}${RESET}`);
  log(`${DIM}  by Huzefa Nalkheda Wala${RESET}`);
  log("");
  log("  Usage:");
  log(`    ${CYAN}npx claude-code-optimizer${RESET}            Install globally to ~/.claude/`);
  log(`    ${CYAN}npx claude-code-optimizer --project${RESET}  Install to current project`);
  log(`    ${CYAN}npx claude-code-optimizer --uninstall${RESET} Remove global installation`);
  log(`    ${CYAN}npx claude-code-optimizer --help${RESET}     Show this help`);
  log("");
  log("  Aliases:");
  log(`    ${CYAN}npx cco${RESET}                              Same as claude-code-optimizer`);
  log("");
  log(`  Docs: ${DIM}https://github.com/huzaifa525/claude-code-optimizer${RESET}`);
  log("");
}

// Parse args
const args = process.argv.slice(2);
const flag = args[0] || "";

if (flag === "--help" || flag === "-h") {
  showHelp();
} else if (flag === "--project" || flag === "-p") {
  installProject();
} else if (flag === "--uninstall" || flag === "-u") {
  uninstall();
} else {
  installGlobal();
}
