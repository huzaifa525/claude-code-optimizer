#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const os = require("os");

// Skip in CI/Docker/non-interactive environments (for postinstall safety)
if (process.env.CI || process.env.DOCKER || process.env.GITHUB_ACTIONS || process.env.NETLIFY || process.env.VERCEL) {
  process.exit(0);
}

const VERSION = require("../package.json").version;
const CLAUDE_HOME = path.join(os.homedir(), ".claude");
const TEMPLATES_DIR = path.join(__dirname, "..", "templates");
const VERSION_FILE = path.join(CLAUDE_HOME, ".cco-version");

const BOLD = "\x1b[1m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const CYAN = "\x1b[36m";
const MAGENTA = "\x1b[35m";
const DIM = "\x1b[2m";
const RESET = "\x1b[0m";

function log(msg) {
  console.log(msg);
}

function success(msg) {
  console.log(`${GREEN}  + ${RESET}${msg}`);
}

function updated(msg) {
  console.log(`${MAGENTA}  ↑ ${RESET}${msg}`);
}

function skip(msg) {
  console.log(`${YELLOW}  ~ ${RESET}${msg}`);
}

function info(msg) {
  console.log(`${CYAN}  i ${RESET}${msg}`);
}

// Version tracking for auto-upgrade
function getInstalledVersion() {
  try {
    return fs.readFileSync(VERSION_FILE, "utf-8").trim();
  } catch (_) {
    return null;
  }
}

function saveInstalledVersion() {
  fs.writeFileSync(VERSION_FILE, VERSION);
}

function compareSemver(a, b) {
  const pa = a.split(".").map(Number);
  const pb = b.split(".").map(Number);
  for (let i = 0; i < 3; i++) {
    if ((pa[i] || 0) > (pb[i] || 0)) return 1;
    if ((pa[i] || 0) < (pb[i] || 0)) return -1;
  }
  return 0;
}

function copyDirRecursive(src, dest, force) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }

  const entries = fs.readdirSync(src, { withFileTypes: true });
  let copied = 0;

  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);

    if (entry.isDirectory()) {
      copied += copyDirRecursive(srcPath, destPath, force);
    } else {
      if (force || !fs.existsSync(destPath)) {
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

// Dynamically count items in templates
function countSkills() {
  const skillsSrc = path.join(TEMPLATES_DIR, ".claude", "skills");
  if (!fs.existsSync(skillsSrc)) return 0;
  return fs.readdirSync(skillsSrc, { withFileTypes: true }).filter((e) => e.isDirectory()).length;
}

function countRules() {
  const rulesSrc = path.join(TEMPLATES_DIR, ".claude", "rules");
  if (!fs.existsSync(rulesSrc)) return 0;
  return fs.readdirSync(rulesSrc).filter((f) => f.endsWith(".md")).length;
}

function countHooks() {
  const hooksSrc = path.join(TEMPLATES_DIR, ".claude", "hooks");
  if (!fs.existsSync(hooksSrc)) return 0;
  return fs.readdirSync(hooksSrc).filter((f) => f.endsWith(".sh")).length;
}

function installGlobal() {
  log("");
  log(`${BOLD}  Claude Code Optimizer v${VERSION}${RESET}`);
  log(`${DIM}  by Huzefa Nalkheda Wala${RESET}`);
  log("");

  // Ensure ~/.claude exists
  if (!fs.existsSync(CLAUDE_HOME)) {
    fs.mkdirSync(CLAUDE_HOME, { recursive: true });
  }

  // Detect upgrade vs fresh install vs same version
  const installedVersion = getInstalledVersion();
  const isUpgrade = installedVersion && compareSemver(VERSION, installedVersion) > 0;
  const isSameVersion = installedVersion === VERSION;
  const isFreshInstall = !installedVersion;
  // Pre-v4 installs won't have .cco-version — detect by checking if skills dir exists
  const isLegacyUpgrade = !installedVersion && fs.existsSync(path.join(CLAUDE_HOME, "skills"));
  const force = isUpgrade || isLegacyUpgrade;

  if (isUpgrade) {
    log(`  ${MAGENTA}Upgrading${RESET} v${installedVersion} → v${VERSION} in ${CYAN}~/.claude/${RESET}`);
  } else if (isLegacyUpgrade) {
    log(`  ${MAGENTA}Upgrading${RESET} (pre-v4) → v${VERSION} in ${CYAN}~/.claude/${RESET}`);
  } else if (isSameVersion) {
    log(`  v${VERSION} already installed in ${CYAN}~/.claude/${RESET} — checking for missing files`);
  } else {
    log(`  Installing globally to ${CYAN}~/.claude/${RESET}`);
  }
  log("");

  // Install skills
  const skillsSrc = path.join(TEMPLATES_DIR, ".claude", "skills");
  const skillsDest = path.join(CLAUDE_HOME, "skills");

  if (fs.existsSync(skillsSrc)) {
    const skills = fs.readdirSync(skillsSrc, { withFileTypes: true }).filter((e) => e.isDirectory());
    let newCount = 0;
    let updatedCount = 0;

    for (const skill of skills) {
      const srcSkill = path.join(skillsSrc, skill.name);
      const destSkill = path.join(skillsDest, skill.name);
      const destSkillFile = path.join(destSkill, "SKILL.md");
      const exists = fs.existsSync(destSkillFile);

      if (exists && !force) {
        skip(`Skill: ${skill.name}`);
      } else if (exists && force) {
        copyDirRecursive(srcSkill, destSkill, true);
        updated(`Skill: ${skill.name}`);
        updatedCount++;
      } else {
        copyDirRecursive(srcSkill, destSkill, false);
        success(`Skill: ${skill.name}`);
        newCount++;
      }
    }

    if (newCount === 0 && updatedCount === 0) {
      info("All skills up to date");
    } else if (updatedCount > 0) {
      info(`${updatedCount} skills updated, ${newCount} new`);
    }
  }

  log("");

  // Install rules
  const rulesSrc = path.join(TEMPLATES_DIR, ".claude", "rules");
  const rulesDest = path.join(CLAUDE_HOME, "rules");

  if (fs.existsSync(rulesSrc)) {
    if (!fs.existsSync(rulesDest)) {
      fs.mkdirSync(rulesDest, { recursive: true });
    }
    const rules = fs.readdirSync(rulesSrc).filter((f) => f.endsWith(".md"));
    let newCount = 0;
    let updatedCount = 0;

    for (const rule of rules) {
      const srcRule = path.join(rulesSrc, rule);
      const destRule = path.join(rulesDest, rule);
      const exists = fs.existsSync(destRule);

      if (exists && !force) {
        skip(`Rule: ${rule}`);
      } else if (exists && force) {
        fs.copyFileSync(srcRule, destRule);
        updated(`Rule: ${rule}`);
        updatedCount++;
      } else {
        fs.copyFileSync(srcRule, destRule);
        success(`Rule: ${rule}`);
        newCount++;
      }
    }

    if (newCount === 0 && updatedCount === 0) {
      info("All rules up to date");
    } else if (updatedCount > 0) {
      info(`${updatedCount} rules updated, ${newCount} new`);
    }
  }

  log("");

  // Install hooks
  const hooksSrc = path.join(TEMPLATES_DIR, ".claude", "hooks");
  const hooksDest = path.join(CLAUDE_HOME, "hooks");

  if (fs.existsSync(hooksSrc)) {
    if (!fs.existsSync(hooksDest)) {
      fs.mkdirSync(hooksDest, { recursive: true });
    }
    const hooks = fs.readdirSync(hooksSrc).filter((f) => f.endsWith(".sh"));
    let newCount = 0;
    let updatedCount = 0;

    for (const hook of hooks) {
      const srcHook = path.join(hooksSrc, hook);
      const destHook = path.join(hooksDest, hook);
      const exists = fs.existsSync(destHook);

      if (exists && !force) {
        skip(`Hook: ${hook}`);
      } else if (exists && force) {
        fs.copyFileSync(srcHook, destHook);
        try { fs.chmodSync(destHook, 0o755); } catch (_) {}
        updated(`Hook: ${hook}`);
        updatedCount++;
      } else {
        fs.copyFileSync(srcHook, destHook);
        try { fs.chmodSync(destHook, 0o755); } catch (_) {}
        success(`Hook: ${hook}`);
        newCount++;
      }
    }

    if (newCount === 0 && updatedCount === 0) {
      info("All hooks up to date");
    } else if (updatedCount > 0) {
      info(`${updatedCount} hooks updated, ${newCount} new`);
    }
  }

  log("");

  // Install settings.json globally (always overwrite on upgrade — new hooks need wiring)
  const settingsSrc = path.join(TEMPLATES_DIR, ".claude", "settings.json");
  const settingsDest = path.join(CLAUDE_HOME, "settings.json");
  if (fs.existsSync(settingsDest) && !force) {
    skip("settings.json (already exists — hooks may need manual merge)");
  } else if (fs.existsSync(settingsDest) && force) {
    fs.copyFileSync(settingsSrc, settingsDest);
    updated("settings.json (hooks rewired for v" + VERSION + ")");
  } else {
    fs.copyFileSync(settingsSrc, settingsDest);
    success("settings.json (hooks wired + MAX_THINKING_TOKENS=10000)");
  }

  log("");

  // Install templates (never overwrite — user may have customized)
  const claudeMdSrc = path.join(TEMPLATES_DIR, "CLAUDE.md");
  const claudeMdDest = path.join(CLAUDE_HOME, "CLAUDE.md.template");
  copyFileIfNotExists(claudeMdSrc, claudeMdDest, "CLAUDE.md.template");

  const ignoreSrc = path.join(TEMPLATES_DIR, ".claudeignore");
  const ignoreDest = path.join(CLAUDE_HOME, "claudeignore.template");
  copyFileIfNotExists(ignoreSrc, ignoreDest, "claudeignore.template");

  log("");

  // Create sessions directory for persistent memory
  const sessionsDir = path.join(CLAUDE_HOME, "sessions");
  if (!fs.existsSync(sessionsDir)) {
    fs.mkdirSync(sessionsDir, { recursive: true });
    success("Created sessions/ directory (persistent memory)");
  }

  // Save version for future upgrade detection
  saveInstalledVersion();

  log("");
  if (isUpgrade || isLegacyUpgrade) {
    log(`${BOLD}${GREEN}  Upgrade complete!${RESET}`);
  } else {
    log(`${BOLD}${GREEN}  Installation complete!${RESET}`);
  }
  log("");
  log("  What was installed:");
  log(`    ${CYAN}~/.claude/skills/${RESET}     ${countSkills()} skills`);
  log(`    ${CYAN}~/.claude/rules/${RESET}      ${countRules()} rules`);
  log(`    ${CYAN}~/.claude/hooks/${RESET}      ${countHooks()} hooks`);
  log(`    ${CYAN}~/.claude/sessions/${RESET}   persistent memory storage`);
  log(`    ${CYAN}~/.claude/settings.json${RESET}  hooks wired + MAX_THINKING_TOKENS=10000`);
  log("");
  log("  New in v4.0.0:");
  log(`    ${GREEN}+${RESET} Two-stage code review (spec compliance → code quality)`);
  log(`    ${GREEN}+${RESET} Anti-rationalization patterns in TDD, review, security`);
  log(`    ${GREEN}+${RESET} /worktree — isolated git worktree development`);
  log(`    ${GREEN}+${RESET} /subagent-dev — dispatch fresh subagents per task`);
  log(`    ${GREEN}+${RESET} /mode — aggressive/balanced/thorough optimization profiles`);
  log(`    ${GREEN}+${RESET} Persistent session memory across restarts`);
  log(`    ${GREEN}+${RESET} Progressive disclosure in /explore-area`);
  log(`    ${GREEN}+${RESET} CSO-optimized skill descriptions for better discovery`);
  log("");
  log("  Next steps:");
  log(`    1. Open Claude Code in any repo`);
  log(`    2. Type ${CYAN}/setup${RESET} to auto-generate CLAUDE.md for that project`);
  log(`    3. Everything else works automatically`);
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

  copyFileIfNotExists(
    path.join(TEMPLATES_DIR, "CLAUDE.md"),
    path.join(projectDir, "CLAUDE.md"),
    "CLAUDE.md"
  );

  copyFileIfNotExists(
    path.join(TEMPLATES_DIR, ".claudeignore"),
    path.join(projectDir, ".claudeignore"),
    ".claudeignore"
  );

  log("");

  const claudeDir = path.join(projectDir, ".claude");

  // Copy all skills dynamically
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

  // Copy all rules dynamically
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

  // Copy all hooks dynamically
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

  const settingsSrc = path.join(TEMPLATES_DIR, ".claude", "settings.json");
  const settingsDest = path.join(claudeDir, "settings.json");
  copyFileIfNotExists(settingsSrc, settingsDest, "settings.json (hook config)");

  log("");
  log(`${BOLD}${GREEN}  Installation complete!${RESET}`);
  log("");
  log(`  ${countSkills()} skills, ${countRules()} rules, ${countHooks()} hooks installed.`);
  log("  Edit CLAUDE.md with your project details, then start Claude Code.");
  log("");
}

function uninstall() {
  log("");
  log(`${BOLD}  Claude Code Optimizer — Uninstall${RESET}`);
  log("");

  // Dynamically find all installed skills
  const skillsDir = path.join(CLAUDE_HOME, "skills");
  const rulesDir = path.join(CLAUDE_HOME, "rules");
  const hooksDir = path.join(CLAUDE_HOME, "hooks");

  // Known skills from templates
  const skillsSrc = path.join(TEMPLATES_DIR, ".claude", "skills");
  const knownSkills = fs.existsSync(skillsSrc)
    ? fs.readdirSync(skillsSrc, { withFileTypes: true }).filter((e) => e.isDirectory()).map((e) => e.name)
    : [];

  // Known rules from templates
  const rulesSrc = path.join(TEMPLATES_DIR, ".claude", "rules");
  const knownRules = fs.existsSync(rulesSrc)
    ? fs.readdirSync(rulesSrc).filter((f) => f.endsWith(".md"))
    : [];

  // Known hooks from templates
  const hooksSrcDir = path.join(TEMPLATES_DIR, ".claude", "hooks");
  const knownHooks = fs.existsSync(hooksSrcDir)
    ? fs.readdirSync(hooksSrcDir).filter((f) => f.endsWith(".sh"))
    : [];

  const items = [
    ...knownSkills.map((s) => ({ path: path.join(skillsDir, s), label: `Skill: ${s}` })),
    ...knownRules.map((r) => ({ path: path.join(rulesDir, r), label: `Rule: ${r}` })),
    ...knownHooks.map((h) => ({ path: path.join(hooksDir, h), label: `Hook: ${h}` })),
    { path: path.join(CLAUDE_HOME, "settings.json"), label: "settings.json" },
    { path: path.join(CLAUDE_HOME, "CLAUDE.md.template"), label: "CLAUDE.md.template" },
    { path: path.join(CLAUDE_HOME, "claudeignore.template"), label: "claudeignore.template" },
    { path: path.join(CLAUDE_HOME, ".cco-version"), label: ".cco-version" },
    { path: path.join(CLAUDE_HOME, "sessions"), label: "sessions/" },
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
  log(`    ${CYAN}npx claude-code-optimizer${RESET}            Install globally (auto-detects upgrades)`);
  log(`    ${CYAN}npx claude-code-optimizer --update${RESET}   Force update all files to latest`);
  log(`    ${CYAN}npx claude-code-optimizer --project${RESET}  Install to current project`);
  log(`    ${CYAN}npx claude-code-optimizer --uninstall${RESET} Remove global installation`);
  log(`    ${CYAN}npx claude-code-optimizer --version${RESET}  Show version`);
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
} else if (flag === "--version" || flag === "-v") {
  console.log(VERSION);
} else if (flag === "--update") {
  // Force update: temporarily remove version file so installer treats it as upgrade
  try { fs.unlinkSync(VERSION_FILE); } catch (_) {}
  fs.writeFileSync(VERSION_FILE, "0.0.0"); // triggers upgrade path
  installGlobal();
} else if (flag === "--project" || flag === "-p") {
  installProject();
} else if (flag === "--uninstall" || flag === "-u") {
  uninstall();
} else if (flag && flag.startsWith("-")) {
  console.error(`Unknown flag: ${flag}. Run with --help for usage.`);
  process.exit(1);
} else {
  installGlobal();
}
