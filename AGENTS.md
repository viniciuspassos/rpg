# Project agent instructions

@/Users/viniciuspassos/.codex/RTK.md

## Start every task from the latest main

Before creating a plan or starting any project work:

1. Inspect the current branch and working tree, including untracked files and ignored local drafts that a checkout could overwrite.
2. Fetch `origin` to obtain the latest remote `main`.
3. Check out local `main` and update it to `origin/main` using a fast-forward-only update. Do not start planning or implementation from a stale branch.
4. If local changes or divergent commits prevent a safe update, preserve them in a separate branch, worktree, or backup first. Never discard user work or overwrite ignored drafts. If needed, use an isolated checkout of `origin/main` to begin the task safely.
5. Create any task branch from that updated baseline. Recheck remote `main` before merging and resolve conflicts without losing unrelated changes.

## Engineering practices

- Prefer relevant installed MCP tools. For supported GitHub operations, use the GitHub MCP.
- Prefix every shell command with `rtk`, including each command in a chain.
- Inspect existing code and the issue tracker before implementation. Keep unrelated changes out of commits.
- Keep changes minimal, reuse existing code, and avoid unnecessary abstractions.
- Use strong types; do not introduce `any`. Prefer `unknown` with narrowing or explicit types where applicable, and typed GDScript for gameplay.
- Keep new functions within cyclomatic complexity 10, nesting depth 3, four parameters, and 80 lines. Parameter and line limits may be relaxed for tests; follow stricter repository rules where configured.
- Use test-driven development for behavior changes: failing test, minimum implementation, then refactor. Do not delete or weaken tests to make changes pass.
- Delegate independent work only when useful and authorized. Concurrent writers must use separate working trees and have explicit scope and constraints.
- Write project documentation, code, comments, commit messages, and issues in English. Support English and Brazilian Portuguese for player-facing content.
- Follow `PLAN.md` for v0 scope. `GAME_DIRECTION.md` is a local direction draft and may be intentionally excluded from version control; preserve it and do not force-add it without authorization.
