# Plan 002: Stop passing the Tailscale OAuth secret on the curl command line

> **Executor instructions**: Follow step by step; run every verification command.
> Honor STOP conditions. Update this plan's row in `plans/README.md` when done.
>
> **Drift check (run first)**: `git diff --stat 92ac7e5a..HEAD -- modules/den/aspects/network/tailnet.nix`
> If it changed, compare the "Current state" excerpt below against the live file;
> on mismatch, STOP.

## Status
- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: 001 (use `nix flake check` to verify)
- **Category**: security
- **Planned at**: commit `92ac7e5a`, 2026-06-19

## Why this matters
`modules/den/aspects/network/tailnet.nix` defines a `tailnet-acl` command that
pushes the tailnet ACL via the Tailscale API. It mints a token by passing the
**OAuth `client_secret` as a `curl -d` argument**. Command-line arguments are
world-readable via `ps`/`/proc/<pid>/cmdline` for the lifetime of the `curl`
process, so any local user on the host can read this credential while the push
runs. That secret can rewrite the entire tailnet's ACL policy. The fix moves the
secret off `argv` and onto `curl`'s stdin (read by a shell builtin, which is not
a separate process and never appears in the process table).

## Current state
`modules/den/aspects/network/tailnet.nix` — the `tailnet-acl` push command is a
`pkgs.writeShellApplication` whose `text` contains (around lines 100–112):
```sh
sops_file="''${NX:-$HOME/nx}/.secrets/common/tailscale-api.yaml"
SOPS_AGE_KEY="$(ssh-to-age -private-key -i "$HOME/.ssh/id_ed25519")"
export SOPS_AGE_KEY
cid="$(sops decrypt --extract '["client_id"]' "$sops_file")"
csec="$(sops decrypt --extract '["client_secret"]' "$sops_file")"
tok="$(curl -fsS -d "client_id=$cid" -d "client_secret=$csec" \
  https://api.tailscale.com/api/v2/oauth/token | jq -r .access_token)"
curl -fsS -X POST \
  -H "Authorization: Bearer $tok" \
  -H "Content-Type: application/json" \
  --data-binary @"$acl" \
  https://api.tailscale.com/api/v2/tailnet/-/acl
```
The problem is the `-d "client_secret=$csec"` (and `-d "client_id=$cid"`) on the
`curl` argv. `''${...}` is Nix-string escaping for a literal `${...}` in the
generated shell script — preserve that escaping exactly when editing.

Note: this is a `writeShellApplication`, which runs the script under
`set -euo pipefail` and **without** `set -x` (no command tracing), so there is no
trace-based leak — only the argv exposure.

## Commands you will need
| Purpose | Command | Expected |
|---|---|---|
| Stage | `git add -A` | exit 0 |
| Eval the aspect | `nix eval --raw .#nixosConfigurations.grpht.config.system.build.toplevel.drvPath` | a `/nix/store/...-grpht....drv` path, no error |
| Gate | `nix flake check` | exit 0 |
| Inspect generated script | (see Step 2) | no `client_secret=` on a curl `-d`/`-u` line |

## Scope
**In scope:** `modules/den/aspects/network/tailnet.nix` (only the `text = ''…''`
of the `tailnet-acl` command).
**Out of scope:** the ACL-generation logic (`buildPolicy`, the `tailnet-grant`
quirk, `resolveGrant`) — do not touch. The sops file path and the `--data-binary
@"$acl"` POST (the ACL body is not secret) — leave as-is.

## Git workflow
jj-managed repo — no `git commit`/`checkout`/`switch`. Edit files; `git add -A`
so the flake sees changes. Operator commits via jj.

## Steps

### Step 1: Move the credentials onto curl's stdin
Replace the token-minting line (the `tok="$(curl … -d "client_id=$cid" -d
"client_secret=$csec" …)"` line) with a form body fed via stdin. Target shape:
```sh
tok="$(printf 'grant_type=client_credentials&client_id=%s&client_secret=%s' "$cid" "$csec" \
  | curl -fsS --data @- https://api.tailscale.com/api/v2/oauth/token \
  | jq -r .access_token)"
```
Why this is safe: `printf` is a bash builtin in `writeShellApplication`'s shell,
so it does not fork a process and its arguments never appear in `ps`/`/proc`.
`curl --data @-` reads the POST body from stdin, so neither secret is ever on a
process command line.

Keep the second `curl` (the ACL POST) unchanged — it carries only the bearer
token in a header (headers are also argv-visible, but a short-lived access token
is far lower value than the long-lived client_secret; moving the body off argv is
the high-value fix). If you want to also harden the bearer-token call, that is
noted under Maintenance — do **not** expand scope here.

### Step 2: Verify the secret is gone from argv in the built script
Build the command and inspect the generated script:
```sh
git add -A
drv=$(nix eval --raw ".#nixosConfigurations.grpht.config.environment.systemPackages" \
  --apply 'ps: (builtins.head (builtins.filter (p: (p.name or "") == "tailnet-acl") ps)).drvPath')
out=$(nix build --no-link --print-out-paths "$drv^out")
grep -nE 'client_secret|client_id' "$out"/bin/tailnet-acl
```
**Verify**: the only matches are inside the `printf` format string / the stdin
pipeline — there is **no** `curl … -d "client_secret=…"` and no `-u
"$cid:$csec"`. The `printf … | curl --data @-` form is present.

### Step 3: Gate
`nix flake check` → exit 0 (host-grpht eval check passes with the edited aspect).

## Test plan
No unit tests; verification is the build-and-grep in Step 2 plus the eval gate.
- Confirmed behavior unchanged: the script still mints a token and POSTs the ACL;
  only the transport of credentials to `curl` changed (argv → stdin).

## Done criteria
ALL must hold:
- [ ] `nix flake check` exits 0.
- [ ] In the built `bin/tailnet-acl`, no secret is passed via `curl -d`/`-u`
      (Step 2 grep shows only the `printf | curl --data @-` form).
- [ ] Only `modules/den/aspects/network/tailnet.nix` changed (`git status`).
- [ ] `plans/README.md` row for 002 updated.

## STOP conditions
- The `text` block doesn't match the "Current state" excerpt (drift) — report.
- After the edit, `tailnet-acl show` (which prints the ACL JSON and does not need
  the secret) errors — report; the `show` path must keep working.
- `nix flake check` fails on `host-grpht` after the edit — report the error.

## Maintenance notes
- Deferred follow-up: the ACL-POST `curl` passes the bearer token in an
  `Authorization` header (argv-visible). It's a short-lived token, lower risk, so
  left out of scope; if you later want it off argv too, use `-H @file` or
  `--config` with a 0600 temp file.
- This command only works once `.secrets/common/tailscale-api.yaml` (the OAuth
  client) is provisioned — that's a separate, already-tracked TODO. This plan
  does not provision it.
- A reviewer should confirm `printf` is a builtin in the generated script's shell
  (it is, under `writeShellApplication`/bash) — if the shell ever changes, re-check.
