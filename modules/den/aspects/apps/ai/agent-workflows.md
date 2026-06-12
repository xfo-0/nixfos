# Agent Workflows

## Beads

- If `.beads/` exists, inspect work before editing with `RUST_LOG=error br ready --json` and `RUST_LOG=error br coordination status --json`.
- Use `RUST_LOG=error br show <id> --json` before starting issue work.
- Claim active Beads work with `RUST_LOG=error br update <id> --status in_progress --assignee <agent-or-user>`.
- Close completed Beads work with `RUST_LOG=error br close <id> --reason "<summary>"`.
- Run `RUST_LOG=error br sync --flush-only` before staging `.beads/` changes.
- Do not run `br init` unless user explicitly approves creating Beads state in the repo.
- Prefer JSON output for agent reads; use plain output only for human-facing summaries.

## jujutsu

- VCS selection: if `.jj/` exists, the repo is jj-managed — use jj for all history operations. Never run raw `git commit`/`git checkout`/`git switch` in a jj repo; they detach HEAD and lose jj's auto-snapshots. Fall back to plain git only when the repo is not jj-managed.
- `@` is the working-copy commit and auto-snapshots every edit. Shape history with `jj describe`/`squash`/`new`/`bookmark set`; isolate a file from a mixed working copy with `jj split <paths>`; recover with `jj op log`/`jj op restore`.
- Prefer a dedicated jj bookmark for nontrivial changes.
- For concurrent or long-running work, isolate into a jj workspace via `moor ws add <repo> <name>` (nushell; own working-copy `@` at `<root>/<host>/<owner>/<name>@<ws>`); clean up with `moor ws rm <path>` after merge, then re-run `moor scan`.
- Inspect repo state before edits with `jj status`, `jj log`, and `jj bookmark list`.
- Delete or forget task bookmarks after their changes are merged.
- A floating `private: agent context` commit above `main` holds repo-local agent files (den-guidelines.md, docs/, .claude/, .opencode/). NEVER squash these paths into publishable commits — always pass explicit paths to `jj squash`, route private-file edits into the `private:` commit, and push via `jjp` (path-guarded) instead of raw `jj git push`.
- If the repo is not managed by jj, fall back to normal git workflow.

## Commits

- Use Conventional Commits unless repo history shows a stronger local convention.
- Prefer `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `build`, and `ci` types.
- Keep subject concise and value-focused.
- Do not push, or create PRs unless user explicitly asks.
