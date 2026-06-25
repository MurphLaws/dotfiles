# Codebase Concerns

**Analysis Date:** 2026-06-25

## Security Considerations

### Hardcoded Localhost Bindings
**Risk:** Local development addresses hardcoded in code that may be exposed in version control
**Files:** 
- `nvim/.config/nvim/lua/illico/core/quarto_split.lua` (lines 3, 74)
- `nvim/.config/nvim/lua/illico/plugins/lsp/lspconfig.lua` (line 76)

**Current mitigation:** These are development-only addresses (127.0.0.1 localhost connections). No production exposure documented.

**Recommendations:** 
- Confirm these are development-only paths and add comments marking as such
- For Godot LSP (`127.0.0.1:6005`), document that this requires local Godot editor running

### Environment Variable Handling (GEMINI_API_KEY)
**Risk:** API key exposure if GEMINI_API_KEY environment variable is compromised
**Files:** `nvim/.config/nvim/lua/illico/plugins/codecompanion.lua` (line 380)
**Current mitigation:** Correctly uses `"cmd:echo $GEMINI_API_KEY"` to source from environment at runtime, not hardcoded. Good practice.
**Recommendations:** No changes needed — pattern is correct.

### Secrets Management Outside Repo
**Risk:** Missing secrets could break configuration on new machines
**Files:** 
- `claude/.config/zsh/conf.d/engram.zsh` (line 2-3)
- `.claude/settings.local.json` indicates file path awareness of secrets

**Current mitigation:** Documented that `~/.config/engram/cloud.env` (chmod 600, not versioned) holds ENGRAM_CLOUD_SERVER and other secrets. `.gitignore` not comprehensive.

**Recommendations:**
- Ensure `.gitignore` explicitly excludes `**/.env`, `**/cloud.env`, `**/*secret*`
- Document required environment variables in a `SETUP.md` or `ENV_TEMPLATE.md`
- Add CI/CD check to prevent secrets in commits

## Version & Plugin Drift

### Plugin Version Pinning Inconsistency
**Problem:** Mixed approach to version pinning creates unpredictable upgrade behavior
**Files:** `nvim/.config/nvim/lua/illico/plugins/`
**Details:**
- Some plugins use `version = "*"` (latest minor/patch): mini.lua, neorg.lua, mini-icons.lua, aerial.lua, etc.
- Some use `branch = "master"` (bleeding edge): treesitter.lua, some others
- Some use `version = false` (no auto-update): mini-files.lua
- Some pinned to major versions: nvim-cmp.lua uses `version = "v2.*"`

**Impact:** Lazy.nvim's checker is enabled (`lazy.lua`, line 30) with `notify = false`, so updates happen silently without user awareness. Breaking changes in dependencies could silently break configuration.

**Fix approach:**
1. Standardize on `version = "*"` for stable plugins (lock major, follow minor/patch)
2. For bleeding-edge branches (`treesitter.lua` line 4 — marked CRITICAL comment), document why and add a `notify = true` override
3. Disable auto-checker or enable notifications for visibility
4. Create a changelog/lock pattern to track known working versions

### Neovim 0.11 vs 0.10 Compatibility Layer (Tech Debt)
**Problem:** LSP config uses version branching for Neovim API changes
**Files:** `nvim/.config/nvim/lua/illico/plugins/lsp/lspconfig.lua` (lines 131-152)
**Details:** 
- Detects Neovim 0.11+ (new `vim.lsp.config()` API) vs 0.10 fallback
- Comment at line 16 notes "mantenida para esta versión. Quitar este branch al actualizar a nvim 0.12+."
- This maintenance burden grows with each Neovim major release

**Impact:** Dual code paths increase surface area for bugs; maintenance burden when 0.12 arrives.

**Fix approach:**
- Set minimum Neovim version requirement (document in setup docs)
- Remove 0.10 fallback path once majority of machines updated
- Track in CHANGELOG when this deprecation layer was added (for future cleanup milestone)

### Treesitter Branch Lock (Stability Concern)
**Problem:** Forced to `master` branch instead of semantic versioning
**Files:** `nvim/.config/nvim/lua/illico/plugins/treesitter.lua` (line 4)
**Details:** Comment states "CRITICAL: Forces the stable legacy version" but treesitter's main repo uses `main` branch, not `master`. This lock may be outdated or based on stale documentation.

**Impact:** Could prevent upstream fixes/security patches if `master` diverges from actual stable release channel.

**Fix approach:**
- Verify which branch treesitter maintains as stable
- Consider switching to `version = "*"` if stable releases are available
- Add comment explaining exactly which issue necessitated this lock (links to issues/PRs)

## Test Coverage Gaps

### No Unit/Integration Testing
**Problem:** Lua configuration is not tested
**Files:** All files under `nvim/.config/nvim/lua/illico/` and plugins
**Risk:** Breaking changes in configuration only discovered when Neovim starts. Critical features like LSP, completion, Quarto preview have no regression tests.

**Priority:** High for core features (LSP, completions, Godot integration)

**Safe modification approach:**
- Add nvim plugin test framework (e.g., plenary.nvim, luassert)
- Write smoke tests for critical paths: LSP attach, quarto_split job launch, codecompanion panel lifecycle

### Plugin Integration Testing Missing
**Problem:** Plugin interactions (lazy.nvim load order, keymaps conflicts, event handling) untested
**Files:** `nvim/.config/nvim/lua/illico/lazy.lua` and all plugin specs
**Risk:** Plugin order changes could break keybindings or features silently

## Fragile Areas

### Quarto Preview Script Dependencies
**Risk:** External script relies on hardcoded paths and binary expectations
**Files:** `nvim/.config/nvim/lua/illico/core/quarto_split.lua` (lines 4-6, 14-28)
**Details:**
- Hardcoded Python paths: `/opt/miniconda3/bin/python`, `/opt/homebrew/bin/python3`, `/usr/bin/python3`
- Fallback logic checks file existence but provides no installation guidance
- SRC, BIN, TILE paths use `~/.tmux/` and `~/.cache/` (non-standard locations)
- Port 7777/7778 hardcoded (potential conflicts on busy systems)

**Why fragile:** Breaking easily if:
- User updates conda/brew installations (paths change)
- ~/.tmux/scripts/ missing or not set up
- Port 7777 already in use
- QUARTO_PYTHON environment variable not set correctly

**Safe modification:**
1. Add validation function that checks prerequisites at startup
2. Document required scripts/binaries in setup guide
3. Consider fallback to `which python3` or `VIRTUAL_ENV` detection
4. Add error handling for port binding failures

### Godot LSP Configuration (Machine-Specific)
**Risk:** Direct TCP connection assumes Godot editor running on localhost:6005
**Files:** `nvim/.config/nvim/lua/illico/plugins/lsp/lspconfig.lua` (line 76)
**Details:** LSP connection dies silently if Godot editor not running; no fallback or user notification

**Impact:** GDScript editing fails silently without clear error message

**Safe modification:**
1. Add pre-flight check that Godot editor is accessible
2. Add helpful error message if connection fails
3. Document in setup: "Godot editor must be running with LSP enabled"

### Plugin State Management
**Risk:** Module-level state in codecompanion and quarto_split could cause issues with multiple Neovim instances or buffer reloads
**Files:**
- `nvim/.config/nvim/lua/illico/plugins/codecompanion.lua` (lines 9, 12)
- `nvim/.config/nvim/lua/illico/core/quarto_split.lua` (lines 31, 36, 101)

**Details:** Persistent panel/state tables could leak across buffers or cause memory issues

**Safe modification:** Validate that state cleanup happens on buffer delete/window close (appears to be done, but add tests)

## Commented-Out Code / Technical Debt

### Mason LSP Handler Migration (Incomplete)
**Problem:** Code moved but old patterns left as comments
**Files:** `nvim/.config/nvim/lua/illico/plugins/lsp/mason.lua` (lines 17-21, 65-66)
**Details:** 
- Lines 17-21 comment out imports with note "moved back to lspconfig.lua due to mason deprecated handlers"
- Lines 46, 62 have commented-out tools (eslint, eslint_d)
- Line 65-66 notes "BREAKING Change! Removed setup_handlers"

**Impact:** Unclear if eslint/eslint_d intentionally disabled or just not yet configured

**Fix approach:**
- Decide: keep commented tools as future options or remove entirely
- If intentional, add comment explaining why (e.g., "conflicts with prettier")
- If deprecated, remove comments entirely

### Blink.cmp Alternative (Not Used)
**Problem:** Commented dependency left in mason.lua
**Files:** `nvim/.config/nvim/lua/illico/plugins/lsp/mason.lua` (line 9)
**Details:** `-- "saghen/blink.cmp",` suggests evaluation of blink.cmp as nvim-cmp replacement but not adopted

**Impact:** Mental clutter; no functional impact

**Recommendation:** Either adopt blink.cmp or remove comment and document why nvim-cmp is preferred

### Semantic Tokens Disabled (Documented But Not Explained)
**Problem:** Semantic tokens disabled on gdshader_lsp without clear reasoning
**Files:** `nvim/.config/nvim/lua/illico/plugins/lsp/lspconfig.lua` (lines 79-86)
**Details:** Comment says "disabled because this server tokenizes very little and would otherwise override treesitter's gdshader highlights" but this is a workaround, not a permanent solution

**Recommendation:** Monitor gdshader-language-server releases; this may be fixable upstream

## Portability Concerns

### Shell Assumptions
**Problem:** Configuration assumes Zsh with specific plugin/setup expectations
**Files:**
- `taskwarrior/.task/task-aliases.zsh`
- `taskwarrior/.config/zsh/conf.d/taskwarrior.zsh`
- `claude/.config/zsh/conf.d/claude.zsh`
- `claude/.config/zsh/conf.d/engram.zsh`

**Impact:** Configuration breaks on non-Zsh shells (bash, fish, etc.). Not portable across machines without zsh setup.

**Recommendation:** Document zsh requirement or provide bash fallback; consider using XDG_CONFIG_HOME instead of hardcoded ~/.config

### macOS-Specific Paths
**Problem:** Some paths assume macOS with Homebrew/Miniconda
**Files:**
- `nvim/.config/nvim/lua/illico/core/quarto_split.lua` (lines 19-20: `/opt/homebrew/`, `/opt/miniconda3/`)
- `nvim/.config/nvim/lua/illico/core/keymaps.lua` (line 61: `open` command macOS-only)

**Impact:** Configuration fails on Linux. Not portable to WSL or Linux machines.

**Safe modification:**
1. Add platform detection via `vim.fn.has("mac")` / `has("unix")`
2. Provide Linux fallbacks (e.g., `xdg-open` instead of `open`)
3. Document OS requirements in setup guide

### Hardcoded Home Directory Expansion
**Problem:** Paths rely on `~` expansion, which works but non-standard in some contexts
**Files:** Multiple (quarto_split.lua, neorg.lua, img-clip.lua, etc.)
**Impact:** Works in user context but could fail in cron jobs, systemd services, or unusual shell contexts

**Recommendation:** Use `vim.fn.expand("~")` consistently (already done) but document this requires HOME env var to be set

## Missing Critical Documentation

### Setup / Installation Guide Missing
**Problem:** No SETUP.md or installation instructions for new machines
**Impact:** Hard for user to replicate dotfiles on new machine; hard to onboard if collaborating

**Files affected:** All configuration
**Recommendation:** Create `.planning/SETUP.md` with:
- System requirements (Neovim 0.11+, Zsh, Homebrew paths, Python env)
- Installation steps (stow, config directories to create)
- Required environment variables (GEMINI_API_KEY, ENGRAM_CLOUD_SERVER, QUARTO_PYTHON)
- Optional integrations (Godot editor, tmux scripts, task-git)

### No Dependency Lock
**Problem:** lazy.nvim auto-updates enabled but no lock file tracked
**Impact:** Each machine may have different plugin versions; hard to reproduce issues

**Recommendation:** Consider committing `nvim/.config/nvim/lazy-lock.json` (if lazy.nvim generates it) to version control

## Performance Bottlenecks

### Quarto Preview Spinner Overhead
**Problem:** Quarto preview uses polling timer with 100ms interval for spinner animation
**Files:** `nvim/.config/nvim/lua/illico/core/quarto_split.lua` (lines 155-157)
**Details:** Timer fires every 100ms even if no visible progress; could drain battery on laptops

**Impact:** Minimal but continuous CPU usage during preview launch (up to 90 seconds with timeout)

**Improvement path:**
- Use event-driven updates instead of timer polling
- Stop spinner explicitly when ready instead of timeout

### Color Scheme Definitions (Large File)
**Problem:** `colors/superset.lua` is 382 lines of explicit highlight definitions
**Files:** `nvim/.config/nvim/colors/superset.lua`
**Impact:** Startup overhead; maintenance burden

**Improvement:** Consider using a color scheme library or reducing redundant definitions

## Known Workarounds / Limitations

### Treesitter Master Branch Lock
- **Workaround:** `branch = "master"` in treesitter config
- **Status:** Documented as CRITICAL but unclear when/why this was needed
- **Follow-up:** Verify with upstream repo

### LSP Semantic Tokens Disabled (gdshader)
- **Workaround:** Manually disable in on_init callback
- **Status:** Functional but not ideal
- **Follow-up:** Monitor gdshader-language-server for updates

### Quarto Python Resolution
- **Workaround:** Multi-path fallback + QUARTO_PYTHON override
- **Status:** Works but fragile across conda/brew updates
- **Follow-up:** Consider using VIRTUAL_ENV or PATH-based detection

---

*Concerns audit: 2026-06-25*
