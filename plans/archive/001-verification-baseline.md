# Plan 001: A `nix flake check` gate that evaluates every host

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving on. If a
> "STOP conditions" item occurs, stop and report — do not improvise. When done,
> update this plan's row in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 92ac7e5a..HEAD -- modules/flake-parts/treefmt.nix flake.nix default.nix`
> If any of those changed, compare the "Current state" excerpts below against
> the live files before proceeding; on mismatch, treat as a STOP condition.

## Status
- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: tests / dx
- **Planned at**: commit `92ac7e5a`, 2026-06-19

## Why this matters
This is a NixOS flake config for 3 hosts (`grpht`, `AO05`, `nl0x`) with **no
automated way to know the whole fleet still evaluates**. Today an eval-breaking
change (a bad pin, a typo in an aspect, a removed option) is only discovered when
someone runs `nh os switch` on each host. `nix flake check` already runs a
`treefmt` check but evaluates **zero** host configs. Adding a per-host eval gate
turns "did I break a host?" into one command — and it is the prerequisite that
makes every other change in this plan set safe to verify.

## Current state
- `flake.nix` (whole file):
  ```nix
  {
    outputs =
      { self, ... }@args:
      (import ./.) {
        tackOverrides = args.tackOverrides or { };
        flakeSelf = self;
      };
  }
  ```
- The flake is assembled by `default.nix` → `modules/` via flake-parts +
  `import-tree` (every `*.nix` under `modules/` is auto-imported; **a new file in
  `modules/flake-parts/` is picked up automatically — no registration needed**).
- `modules/flake-parts/treefmt.nix` (whole file) — shows the flake-parts +
  `perSystem` convention to match:
  ```nix
  { inputs, ... }:
  {
    flake-file.inputs.treefmt-nix.url = "gh:numtide/treefmt-nix";
    imports = [ inputs.treefmt-nix.flakeModule ];
    perSystem =
      { ... }:
      {
        treefmt = {
          projectRoot = inputs.self;
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          settings.excludes = [ ".secrets/**" ];
        };
      };
  }
  ```
- Confirmed today: `nix eval .#checks.x86_64-linux --apply builtins.attrNames`
  → `[ "treefmt" ]` (only the auto-generated treefmt check; no host checks).
- All 3 hosts are `x86_64-linux` (verify in Step 1).
- Verification idiom used throughout this repo:
  `nix eval --raw .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`
  — referencing `.drvPath` forces a host to **evaluate** (instantiate) without
  building the whole system. This plan wraps that in a check.

## Commands you will need
| Purpose | Command | Expected on success |
|---|---|---|
| Stage new files (flake eval ignores untracked files) | `git add -A` | exit 0 |
| List checks | `nix eval .#checks.x86_64-linux --apply builtins.attrNames` | includes `host-grpht`, `host-AO05`, `host-nl0x`, `treefmt` |
| Run the gate | `nix flake check` | exit 0 |
| List hosts | `nix eval .#nixosConfigurations --apply builtins.attrNames` | `[ "AO05" "grpht" "nl0x" ]` |

## Scope
**In scope:**
- `modules/flake-parts/checks.nix` (create)
- `modules/flake-parts/treefmt.nix` (modify — Step 2 only)

**Out of scope:**
- Any `modules/den/**` file, any host config, any pin. This plan only adds a
  read-only verification gate; it must not change what any host builds.
- CI / GitHub Actions — see Maintenance notes; not part of this plan.

## Git workflow
- This repo is **jj-managed** (a `.jj/` dir exists). Do not run `git commit`,
  `git checkout`, or `git switch`. Make file edits only; the operator commits via
  jj. `git add -A` is fine and is required so flake eval sees new files.
- Commit style if asked later: Conventional Commits (e.g. `feat(checks): …`).

## Steps

### Step 1: Confirm host names and systems
Run `nix eval .#nixosConfigurations --apply builtins.attrNames`.
**Verify**: output is `[ "AO05" "grpht" "nl0x" ]` (order may vary). If a host is
missing or extra, use the actual list in Step 2 instead of the hardcoded one.
Then confirm each is x86_64-linux:
`nix eval --raw .#nixosConfigurations.grpht.pkgs.system` → `x86_64-linux`.
**STOP** if any host is not `x86_64-linux` — the Step 2 module filters by system,
which already handles this, but you must confirm the filter expression resolves
`.pkgs.system` without error first.

### Step 2: Create the per-host eval checks module
Create `modules/flake-parts/checks.nix` with this content:
```nix
{ self, lib, ... }:
{
  perSystem =
    { system, pkgs, ... }:
    {
      checks = lib.mapAttrs' (
        name: cfg:
        lib.nameValuePair "host-${name}" (
          pkgs.runCommand "eval-host-${name}" { } ''
            echo ${cfg.config.system.build.toplevel.drvPath} > "$out"
          ''
        )
      ) (lib.filterAttrs (_: cfg: cfg.pkgs.system == system) self.nixosConfigurations);
    };
}
```
Why this shape: the `runCommand` is trivial (writes a string), but referencing
`cfg.config.system.build.toplevel.drvPath` forces each host to **evaluate**.
`nix flake check` builds these trivial derivations, so it fails iff a host fails
to evaluate — a fast eval gate, not a full system build.

Then: `git add -A` (so the new file is visible to the flake).

**Verify**: `nix eval .#checks.x86_64-linux --apply builtins.attrNames`
→ includes `host-grpht`, `host-AO05`, `host-nl0x`, and `treefmt`.
**STOP** if you get an "infinite recursion" or "attribute 'self' missing" error:
in that case the flake-parts module args differ here — try replacing the top
arg `{ self, lib, ... }` with `{ config, lib, ... }` and `self.nixosConfigurations`
with `config.flake.nixosConfigurations`, re-run, and if it still errors, stop and
report the exact error.

### Step 3: Run the gate
`nix flake check`
**Verify**: exits 0. This now evaluates all hosts + runs treefmt.
**STOP** if a `host-*` check fails: that means a host currently doesn't evaluate
at `HEAD` — report which host and the error; do not try to fix the host in this
plan (that's a separate finding).

### Step 4 (optional enhancement): add deadnix + statix to treefmt
treefmt-nix can run these linters as part of the existing `treefmt` check. In
`modules/flake-parts/treefmt.nix`, add inside `treefmt = { … }`:
```nix
        programs.deadnix.enable = true;
        programs.statix.enable = true;
```
Then `git add -A` and run `nix flake check`.
**Verify / decide**:
- If `nix flake check` still exits 0 → keep the change.
- If it now **fails** because deadnix/statix found pre-existing dead code or lint
  issues, that is expected on a never-linted repo. Do **NOT** start fixing lint
  across `modules/`. Instead: **revert this Step 4 edit** (`git checkout --` is
  forbidden here; just delete the two lines you added), re-run `nix flake check`
  to confirm green, and record in `plans/README.md` a note: "deadnix/statix
  surfaced N issues — deferred to a dedicated cleanup plan." The eval gate
  (Steps 1–3) is the load-bearing deliverable; linters are a bonus only if clean.

## Test plan
There is no unit-test framework in this repo; the checks **are** the tests.
- New "tests": `checks.<system>.host-<name>` for each host (added in Step 2).
- Verification: `nix flake check` exits 0; `nix eval .#checks.x86_64-linux
  --apply builtins.attrNames` lists one `host-*` per host plus `treefmt`.

## Done criteria
ALL must hold:
- [ ] `modules/flake-parts/checks.nix` exists and is `git add`ed.
- [ ] `nix eval .#checks.x86_64-linux --apply builtins.attrNames` lists
      `host-grpht`, `host-AO05`, `host-nl0x`, `treefmt`.
- [ ] `nix flake check` exits 0.
- [ ] No file under `modules/den/**` or any host config changed (`git status`).
- [ ] `plans/README.md` row for 001 updated.

## STOP conditions
- The check module errors with infinite recursion / missing `self` after trying
  the Step 2 fallback.
- A `host-*` check fails (a host doesn't evaluate at HEAD) — report, don't fix here.
- deadnix/statix would make the gate red and fixing is non-trivial — revert Step 4
  per its instructions, keep the eval gate green.

## Maintenance notes
- Once this lands, **every other plan in this set is verified with `nix flake
  check`** instead of per-host eval.
- Follow-up deliberately deferred: a CI workflow (e.g. a forge action running
  `nix flake check`). The repo has no CI today and its remote/runner setup is
  unknown; add CI once a runner with Nix is available. The check itself is
  CI-ready as written.
- If a 4th host is added, it is picked up automatically by the `mapAttrs'` over
  `self.nixosConfigurations` — no edit needed.
- A reviewer should confirm the checks are **eval-only** (trivial `runCommand`),
  not accidentally building full systems (which would make `nix flake check`
  very slow).
