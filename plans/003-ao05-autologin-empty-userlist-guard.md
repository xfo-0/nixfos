# Plan 003: Guard AO05 autologin against an empty normal-user list

> **Executor instructions**: Follow step by step; run the verification commands.
> Honor STOP conditions. Update this plan's row in `plans/README.md` when done.
>
> **Drift check (run first)**: `git diff --stat 92ac7e5a..HEAD -- modules/den/hosts/AO05/configuration.nix`
> If it changed, compare the excerpt below to the live file; on mismatch, STOP.

## Status
- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: 001 (verify via `nix flake check`)
- **Category**: bug (latent eval crash)
- **Planned at**: commit `92ac7e5a`, 2026-06-19

## Why this matters
AO05's greetd config derives the autologin user with
`lib.head (builtins.attrNames normalUsers)`. `lib.head []` throws
("list index out of bounds") and **aborts evaluation of the whole host**. Today
AO05 has a normal user (`xfo`), so the list is non-empty and it works — but the
expression is a latent landmine: any future change that leaves AO05 with no
normal user (e.g. a refactor of user provisioning, or reusing this block on a
headless host) turns a config tweak into a hard eval failure with an opaque
error. A one-line fallback makes the failure mode explicit and safe.

## Current state
`modules/den/hosts/AO05/configuration.nix`, the greetd block (around lines 70–90):
```nix
          let
            normalUsers = lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users;
            firstUserName = lib.head (builtins.attrNames normalUsers);
            niriSession = "${config.programs.niri.package}/bin/niri-session";
          in
          {
            services.greetd = {
              enable = true;
              useTextGreeter = true;
              settings = {
                terminal.vt = 1;
                default_session = {
                  user = "greeter";
                  command = "${pkgs.greetd}/bin/agreety --cmd ${niriSession}";
                };
                initial_session = {
                  user = firstUserName;
                  command = niriSession;
                };
              };
            };
          };
```
`firstUserName` is used only at `initial_session.user`. This pattern exists
**only** in this file (confirmed: no other host or aspect uses `firstUserName` or
this `lib.head (builtins.attrNames …)` shape).

## Commands you will need
| Purpose | Command | Expected |
|---|---|---|
| Stage | `git add -A` | exit 0 |
| Eval AO05 | `nix eval --raw .#nixosConfigurations.AO05.config.system.build.toplevel.drvPath` | a `.drv` path, no error |
| Confirm autologin user still xfo | `nix eval --raw .#nixosConfigurations.AO05.config.services.greetd.settings.initial_session.user` | `xfo` |
| Gate | `nix flake check` | exit 0 |

## Scope
**In scope:** `modules/den/hosts/AO05/configuration.nix` — only the
`firstUserName` binding line.
**Out of scope:** the greetd settings, the `default_session`, niri, any other
host. Do not change which user actually autologs in today (must remain `xfo`).

## Git workflow
jj-managed — no `git commit`/`checkout`/`switch`. Edit + `git add -A`.

## Steps

### Step 1: Add a fallback to the head expression
Change the `firstUserName` binding from:
```nix
            firstUserName = lib.head (builtins.attrNames normalUsers);
```
to:
```nix
            firstUserName = lib.head (builtins.attrNames normalUsers ++ [ "root" ]);
```
This keeps the current behavior (when a normal user exists, it is still chosen —
`normalUsers` names come first in the list), and only falls back to `"root"` if
there are literally no normal users, so evaluation can never throw here.

### Step 2: Verify behavior is unchanged today and eval is safe
```sh
git add -A
nix eval --raw .#nixosConfigurations.AO05.config.services.greetd.settings.initial_session.user
```
**Verify**: prints `xfo` (the existing normal user is still selected; the fallback
did not change today's outcome).

### Step 3: Gate
`nix flake check` → exit 0.

## Test plan
No unit framework. Verification is the eval in Step 2 (autologin user is still
`xfo`) plus `nix flake check`. The guard's empty-list branch can't be exercised
without removing AO05's user, which is out of scope; the fallback is the
protection and the Step 2 eval confirms no regression.

## Done criteria
ALL must hold:
- [ ] `firstUserName` binding includes the `++ [ "root" ]` fallback.
- [ ] `nix eval … AO05 … initial_session.user` returns `xfo`.
- [ ] `nix flake check` exits 0.
- [ ] Only `modules/den/hosts/AO05/configuration.nix` changed (`git status`).
- [ ] `plans/README.md` row for 003 updated.

## STOP conditions
- The greetd block doesn't match the "Current state" excerpt (drift) — report.
- After the edit, `initial_session.user` is anything other than `xfo` — report
  (the fallback should never trigger today; if it does, `normalUsers` is empty,
  which is a separate problem to surface).

## Maintenance notes
- The `"root"` fallback exists only to keep evaluation total; autologin as root
  is not intended. If AO05 ever legitimately has no normal user, revisit whether
  greetd autologin should be disabled instead of falling back to root.
- A reviewer should confirm the fallback name comes **last** in the list so a
  real normal user always wins.
