# Project agent instructions

@/Users/viniciuspassos/.codex/RTK.md

## Start every task from the latest main

Before creating a plan or starting any project work:

1. Inspect the current branch and working tree, including untracked files and ignored local drafts that a checkout could overwrite.
2. Run `rtk git switch main`.
3. Run `rtk git pull --ff-only origin main`. Only start planning or implementation after the pull succeeds. Do not reuse a stale task branch as the starting point.
4. Create the task branch from this updated `main`, then implement the changes. The normal flow is: checkout main → pull → task branch → implementation. Do not create archive branches as a routine step.
5. For parallel sessions, use a separate worktree and task branch per session, each based on the latest remote `main`. Never switch branches in a working tree another session is using. In an isolated worktree where `main` is already checked out elsewhere, fetch `origin` and create the task branch from `origin/main` instead.
6. If uncommitted changes or divergent local history block the switch or pull, stop before overwriting anything and resolve that specific condition. Never discard user work. Recheck remote `main` before merging; starting from an updated base reduces conflicts but does not eliminate conflicts between concurrent edits.

## Engineering practices

- Prefer relevant installed MCP tools. For supported GitHub operations, use the GitHub MCP.
- Prefix every shell command with `rtk`, including each command in a chain.
- Inspect existing code and the issue tracker before implementation. Keep unrelated changes out of commits.
- Keep changes minimal, reuse existing code, and avoid unnecessary abstractions.
- Use strong types; do not introduce `any`. Prefer `unknown` with narrowing or explicit types where applicable, and typed GDScript for gameplay.
- Keep new functions within cyclomatic complexity 10, nesting depth 3, four parameters, and 80 lines. Parameter and line limits may be relaxed for tests; follow stricter repository rules where configured.
- Use test-driven development for gameplay and other behavior changes: failing test, minimum implementation, then refactor. Do not delete or weaken tests to make changes pass.
- Delegate independent work only when useful and authorized. Concurrent writers must use separate working trees and have explicit scope and constraints.
- Write project documentation, code, comments, commit messages, and issues in English. Support English and Brazilian Portuguese for player-facing content.
- Follow `PLAN.md` for v0 scope. `GAME_DIRECTION.md` is a local direction draft and may be intentionally excluded from version control; preserve it and do not force-add it without authorization.

## Asset production

- Follow `docs/PRODUCTION_GUIDELINES.md` for world, character, animation, and other visual asset work.
- Judge asset work by the output in the running game against the chosen reference. Use fixed-view captures and focused visual revisions until the result meets the stated acceptance criteria. Do not require TDD, code tests, or code quality review for asset generation itself; test gameplay behavior and engine integration when those change.
- Keep asset-generation scripts, Blender working files, temporary renders, and other production inputs local and unversioned. Version only approved game-ready assets and engine files needed to load them. The generation method is an internal production choice, not part of the game runtime.
