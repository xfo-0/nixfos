# Plan 005: Resolve the unused openspec scaffold (adopt with project context)

> **Executor instructions**: Follow step by step. Honor STOP conditions. Update
> this plan's row in `plans/README.md` when done.
>
> **Drift check (run first)**: `git diff --stat 92ac7e5a..HEAD -- openspec/`
> If `openspec/config.yaml` changed, read it before editing; on mismatch, STOP.

## Status
- **Priority**: P3
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: dx / direction
- **Planned at**: commit `92ac7e5a`, 2026-06-19

## Why this matters
`openspec/` was initialized (`openspec init`) and is **now in active use** — a
real change exists at `openspec/changes/graphify-nix-spike/` (proposal, design,
tasks, delta spec). So adoption is settled; what's still missing is **project
context**: `config.yaml` remains the untouched init template (all comments), so
every artifact the CLI generates runs without knowing this is a NixOS/den flake.
Issue tracking is done with beads (`.beads/`). This plan gives openspec its
project context (improving the AI output of the spike already underway and any
future change) and records the beads-vs-openspec boundary so the two tools don't
compete.

## Current state
`openspec/config.yaml` (whole file is the init template):
```yaml
schema: spec-driven

# Project context (optional)
# This is shown to AI when creating artifacts.
# ... (commented examples only) ...

# Per-artifact rules (optional)
# ... (commented examples only) ...
```
`openspec/changes/` now holds `graphify-nix-spike/` (a live change) plus
`archive/`; `openspec/specs/` is still empty. `.beads/` exists and is the live
issue/task tracker.

Repo conventions to encode in the context block (true facts about this repo):
- Tech: NixOS flake config built on the **den** framework (aspects / quirks /
  policies / schema). Hosts: grpht, AO05, nl0x.
- Verification: `nix flake check` (after plan 001) and
  `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.
- Conventions: Conventional Commits; no code comments unless non-obvious; edit
  `~/nx` (canonical), never `/etc/nixos` (derived mirror); pins via `tack`.
- Tracking split: **beads = issues/tasks; openspec = spec-driven change proposals**.

## Commands you will need
| Purpose | Command | Expected |
|---|---|---|
| Validate openspec config | `openspec validate` (if the CLI is on PATH) | exit 0 / no schema error |
| Stage | `git add -A` | exit 0 |

(If `openspec` is not on PATH, skip the validate command — it does not affect the
NixOS build. `nix flake check` does not cover `openspec/`.)

## Scope
**In scope:** `openspec/config.yaml`.
**Out of scope:** creating actual specs/changes (that happens organically when a
real change is proposed); `.beads/`; any `modules/**`; `den-guidelines.md`
(optional doc note is a follow-up, not required here).

## Git workflow
jj-managed — no `git commit`/`checkout`/`switch`. Edit + `git add -A`.

## Steps

### Step 1: Populate the context block
Edit `openspec/config.yaml` to fill in `context` (replace the commented examples;
keep `schema: spec-driven`):
```yaml
schema: spec-driven

context: |
  NixOS flake configuration built on the "den" framework (aspects, quirks,
  policies, schema). Hosts: grpht, AO05, nl0x. Canonical source is ~/nx;
  /etc/nixos is a derived read-only mirror — never edit it.
  Verification: `nix flake check` and
  `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.
  Conventions: Conventional Commits; self-documenting code (no comments unless a
  non-obvious workaround); inputs pinned via tack. Issue/task tracking lives in
  beads (.beads/); openspec is for spec-driven proposals on nontrivial changes.
```
Leave the `rules:` section commented unless the owner wants per-artifact rules.

### Step 2: Validate (best-effort) and stage
`openspec validate` if available → no error. Then `git add -A`.
**STOP** if `openspec validate` reports a schema error you can't resolve from the
message — report it; the template `schema: spec-driven` key must stay.

## Test plan
None (config/doc change; not covered by `nix flake check`). Validation is the
optional `openspec validate`.

## Done criteria
ALL must hold:
- [ ] `openspec/config.yaml` has a populated `context:` block with the repo facts.
- [ ] `openspec validate` passes, or the CLI is unavailable (note which).
- [ ] Only `openspec/config.yaml` changed (`git status`).
- [ ] `plans/README.md` row for 005 updated.

## STOP conditions
- `openspec validate` errors on the `context:` key — report.
- (The "owner wanted openspec removed" branch is now moot: a live change
  `graphify-nix-spike` exists, so removal is off the table. Do not delete
  `openspec/`.)

## Maintenance notes
- Adoption is confirmed by the live `graphify-nix-spike` change; the
  remove-in-favor-of-beads alternative is no longer on the table. This plan only
  supplies the missing project context.
- Optional follow-up (not in scope): add one line to `den-guidelines.md`
  recording the beads-vs-openspec split so future contributors know which to use.
