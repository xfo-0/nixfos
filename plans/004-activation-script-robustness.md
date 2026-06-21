# Plan 004: Make activation scripts fail loud-but-safe instead of silently breaking

> **Executor instructions**: Follow step by step; run every verification command.
> Honor STOP conditions. Update this plan's row in `plans/README.md` when done.
>
> **Drift check (run first)**: `git diff --stat 92ac7e5a..HEAD -- modules/den/aspects/apps/ai/claude.nix modules/den/aspects/apps/cad/freecad.nix modules/den/aspects/system/settings/nixos-config-sync.nix`
> If any changed, compare the excerpts below to the live files; on mismatch, STOP.
>
> **Reconciled 2026-06-20 (HEAD `6fa914f`)**: `claude.nix` *has* changed since
> `92ac7e5` (commit `db507bf` grew the file — added a codebase-memory-mcp
> derivation, two new skill installs, an extra `mcpServers` entry, and persist
> dirs). The drift check will flag it. This is **benign**: the two bare
> `json.loads` calls are untouched — they now sit at **lines 195 and 225** of
> the live file (verbatim match to Site 1 below). `freecad.nix` and
> `nixos-config-sync.nix` are unchanged. Proceed; the finding is intact.

## Status
- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: 001 (verify via `nix flake check`)
- **Category**: bug (robustness)
- **Planned at**: commit `92ac7e5a`, 2026-06-19

## Why this matters
Two home-manager activation scripts parse JSON state files with bare
`json.loads(...read_text())`. If `~/.claude.json` or `~/.claude/settings.json` is
ever corrupt (truncated by a crash, hand-edited badly), `json.loads` throws and
**home-manager activation aborts** — leaving the user unable to rebuild until they
manually repair the file. A third script (`nixos-config-sync`) rsyncs `~/nx` →
`/etc/nixos` with the exit status unchecked, so a failed sync passes silently and
the mirror goes stale without warning. This plan makes all three fail safely: skip
(don't clobber) on bad JSON, warn on a failed sync. The repo already has the
correct pattern — `opencode.nix`'s activation catches `JSONDecodeError`, prints a
message, and skips — so this is bringing two siblings in line with it.

## Current state
**Reference pattern to copy — `modules/den/aspects/apps/ai/opencode.nix`** already
does this (its activation):
```python
          try:
              data = json.loads(text)
          except json.JSONDecodeError:
              try:
                  data = json.loads(re.sub(r",(\s*[}\]])", r"\1", text))
              except json.JSONDecodeError as err:
                  print(f"opencodeAgentWorkflows: leaving unparseable {path} untouched: {err}")
                  raise SystemExit(0)
```
(The key move: on unparseable input, **print a warning and `raise SystemExit(0)`
— exit the activation snippet cleanly without rewriting the file**.)

**Site 1 — `modules/den/aspects/apps/ai/claude.nix`**, inside the
`home.activation.claudeConfig` Python heredoc, has TWO bare loads (live at
**lines 195 and 225** as of HEAD `6fa914f`):
```python
          settings = Path("${claudeDir}") / "settings.json"
          data = json.loads(settings.read_text()) if settings.exists() else {}
          ...
          claude_json = Path("${config.home.homeDirectory}/.claude.json")
          state = json.loads(claude_json.read_text()) if claude_json.exists() else {}
```

**Site 2 — `modules/den/aspects/apps/cad/freecad.nix:29`**, inside
`home.activation.freecadMcpServer`:
```python
          claude_json = Path("${config.home.homeDirectory}/.claude.json")
          state = json.loads(claude_json.read_text()) if claude_json.exists() else {}
```

**Site 3 — `modules/den/aspects/system/settings/nixos-config-sync.nix`**, the
activation `text` runs `rsync -a --delete --delete-excluded … "$src"/ "$dst"/`
inside an `if`-guard, with no check on rsync's exit status.

## Commands you will need
| Purpose | Command | Expected |
|---|---|---|
| Stage | `git add -A` | exit 0 |
| Eval grpht (covers claude + config-sync) | `nix eval --raw .#nixosConfigurations.grpht.config.system.build.toplevel.drvPath` | `.drv` path, no error |
| Build the HM activation script + check Python parses | (Step 4) | `python3 -m py_compile` exits 0 |
| Gate | `nix flake check` | exit 0 |

## Scope
**In scope:** the three files named above, each only at the lines shown.
**Out of scope:** any other activation logic (the statusline, the SessionStart
hook wiring, the MCP-server entries, the rsync excludes/guard condition). Don't
change *what* the scripts do on the happy path — only their failure handling.

## Git workflow
jj-managed — no `git commit`/`checkout`/`switch`. Edit + `git add -A`.

## Steps

### Step 1: Harden claude.nix JSON reads
In `claude.nix`'s `claudeConfig` Python, replace each
`X = json.loads(P.read_text()) if P.exists() else {}` with a guarded read that
skips on corruption rather than overwriting. Target shape for the `settings` read:
```python
          settings = Path("${claudeDir}") / "settings.json"
          if settings.exists():
              try:
                  data = json.loads(settings.read_text())
              except json.JSONDecodeError as err:
                  print(f"claudeConfig: leaving unparseable {settings} untouched: {err}")
                  raise SystemExit(0)
          else:
              data = {}
```
Apply the same shape to the `claude_json` / `state` read later in the same script.
Keep all surrounding logic (the hook merge, statusLine, mcpServers) unchanged —
it runs only when parsing succeeded.

### Step 2: Harden freecad.nix JSON read
In `freecad.nix`'s `freecadMcpServer` Python, apply the identical guarded-read
shape to the `claude_json` / `state` line. On `JSONDecodeError`, print a
`freecadMcpServer: leaving unparseable … untouched` message and `raise
SystemExit(0)`.

### Step 3: Make nixos-config-sync warn on rsync failure
In `nixos-config-sync.nix`, change the `rsync …` invocation so a failure prints a
warning to stderr instead of being ignored. Append to the rsync command:
```sh
              || echo "nixos-config-sync: rsync ~/nx -> /etc/nixos failed" >&2
```
Do **not** make it `exit 1` / fatal — a transient sync failure must not abort the
whole system activation; a visible warning is the goal. Keep the surrounding
`if [ -d "$src" ] && [ ! -L "$src" ] … ; then … fi` guard exactly as-is.

### Step 4: Verify Python still parses and hosts still eval
```sh
git add -A
# Build grpht's HM activation and syntax-check the embedded python:
nix eval --raw .#nixosConfigurations.grpht.config.system.build.toplevel.drvPath  # no error
```
To sanity-check the Python edits compile, extract and `py_compile` the statusline
is not needed; instead confirm the activation script builds without a Nix error
(the heredoc is embedded in a derivation, so an eval error would surface above).
**Verify**: the eval prints a `.drv` path with no traceback.

### Step 5: Gate
`nix flake check` → exit 0.

## Test plan
No unit framework. Verification:
- `nix flake check` exits 0 (all hosts still evaluate with the edited activations).
- Manual reasoning check (state in the plan, not executed): with a deliberately
  corrupt `~/.claude.json`, the new code prints a warning and exits 0 instead of
  raising — matching `opencode.nix`'s behavior. Do not actually corrupt the file.

## Done criteria
ALL must hold:
- [ ] Both `json.loads` sites in `claude.nix` are wrapped (try/except
      JSONDecodeError → warn + `SystemExit(0)`), and `freecad.nix`'s is too.
- [ ] `nixos-config-sync.nix`'s rsync has a non-fatal `|| echo … >&2` warning.
- [ ] `nix flake check` exits 0.
- [ ] Only the three named files changed (`git status`).
- [ ] `plans/README.md` row for 004 updated.

## STOP conditions
- Any of the three files doesn't match its "Current state" excerpt (drift).
- After edits, `nix flake check` fails on a host — report the error.
- You find the bare `json.loads` has already been wrapped (someone fixed it) —
  skip that site and note it.

## Maintenance notes
- The guarded-read pattern now appears in three places; if a fourth activation
  script reads JSON state, copy the same shape (or factor a tiny helper — not in
  scope here).
- Reviewer should confirm the failure branch **does not write the file** (skips),
  so a corrupt file is preserved for the user to inspect, never silently replaced.
