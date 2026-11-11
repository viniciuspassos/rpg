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

- For every interaction with GitHub, use the Codex GitHub plugin when it supports the operation. Use another method only when the plugin is unavailable or lacks the needed capability.
- Prefix every shell command with `rtk`, including each command in a chain.
- Inspect existing code and the issue tracker before implementation. Keep unrelated changes out of commits.
- Keep changes minimal, reuse existing code, and avoid unnecessary abstractions.
- Use strong types; do not introduce `any`. Prefer `unknown` with narrowing or explicit types where applicable, and typed GDScript for gameplay.
- Keep new functions within cyclomatic complexity 10, nesting depth 3, four parameters, and 80 lines. Parameter and line limits may be relaxed for tests; follow stricter repository rules where configured.
- Use test-driven development for gameplay and other behavior changes: failing test, minimum implementation, then refactor. Do not delete or weaken tests to make changes pass.
- Delegate independent work only when useful and authorized. Concurrent writers must use separate working trees and have explicit scope and constraints.
- Write project documentation, code, comments, commit messages, and issues in English. Support English and Brazilian Portuguese for player-facing content.
- Follow `PLAN.md` for v0 scope. `GAME_DIRECTION.md` is a local direction draft and may be intentionally excluded from version control; preserve it and do not force-add it without authorization.
- When creating a pull request, use `.github/PULL_REQUEST_TEMPLATE.md` as its body. Fill every section with the actual change and validation evidence; mark sections that do not apply rather than leaving placeholders.

## Asset production

- Follow `docs/PRODUCTION_GUIDELINES.md` for world, character, animation, and other visual asset work.
- For Claude Code, route asset production through the `art-director` agent (`.claude/agents/art-director.md`). It only orchestrates: it briefs worker subagents, sets their model and effort, and reviews each delivery visually against the reference in a Gauntlet loop.
- For Codex, the same agent lives in `.codex/agents/art-director.toml` with OpenAI model names and reasoning efforts. Its instructions mirror the Claude version; when you change one, change the other.
- Judge asset work by the output in the running game against the chosen reference. Use gameplay-camera captures and focused visual revisions until the result meets the stated acceptance criteria. Do not require TDD, code tests, or code quality review for asset generation itself; test gameplay behavior and engine integration when those change.
- Keep asset-production scripts, downloads, temporary renders, and image-model inputs local and unversioned. Version only approved game-ready assets and engine files needed to load them. The generation method is an internal production choice, not part of the game runtime.
- Before producing or changing any character or model, read "Character and model generation", "Rig and animation pipeline", and "Scene continuity" in `docs/PRODUCTION_GUIDELINES.md`. The pipeline changed on 2026-11-11:
  - When the user asks for a plan or says not to produce yet, list the outputs, locations, sources, and cost, then stop. Asset tasks exclude gameplay code, tests, and wiring unless requested.
  - The current scene is a linear third-person scene, not the earlier fixed-camera plate. Characters start from CC0 Quaternius bases with their skeleton and animations, adapted to the palette; the mesh must stay replaceable on the same skeleton. Do not script organic characters from primitives, and do not generate 2D pose images per direction.
  - ComfyUI is no longer used. Blender is optional and runs only headless from an agent's script; the user does not need to open it. Static images (concepts, tileable textures, matte paintings) come from an external image model, from briefs written as described in the guidelines.
  - Record source URL, author, and license for every third-party asset before committing it.
  - Check handedness and equipment side against the canon. Bake no glow, shadow, or background into a character.
  - Inspect the first intermediate output early, and stop and report after two failed attempts.
  - Change only the target asset. Record decisions, remaining gaps, and a hand-off in `PLAN.md` or the issue, so either Claude Code or Codex can continue.
