# Game production guidelines

This is the working pipeline for producing the playable village v0. `PLAN.md` defines the current milestone and acceptance criteria; `ARCHITECTURE.md` defines runtime boundaries. Use this guide when planning or executing an art, world, animation, or integration task. Do not expand the milestone without updating `PLAN.md` first.

## Production target

Produce one convincing Godot scene before producing a larger world. The current target is the bounded village duel in `game/visual_mvp.tscn`, viewed through its fixed camera. Only the illustrated protagonist and painted opponent remain in this visual scene; the central floor remains 3D. Directional idle and walk poses are in review, as recorded in `PLAN.md`. The earlier playable episode in `game/main.tscn` remains a compatibility check, not the visual acceptance target.

Judge the result in the running Godot scene, at the intended viewport size and from the player's view. A Blender still is useful for inspecting an asset, but it does not prove that the asset reads well in motion, matches the plate, or runs acceptably in Godot.

## Reference intake

1. Identify the exact output being made: one asset, one visual pass, or one playable scene. Write down the camera view, scale, intended use, and a small set of visible acceptance criteria.
2. Inspect the relevant reference frames and tutorial sections. Extract techniques, measurements, and material or lighting decisions that serve the current output. Record timestamps or frame identifiers. Do not claim to have watched or transcribed a video when only its description or selected frames were available.
3. Separate transferable technique from the example's content. A forest tutorial may teach terrain breakup, vegetation distribution, PBR materials, and atmospheric lighting; its forest, cars, camera shots, and render settings are not requirements for this village.
4. Check the repository's current assets and visual record before making replacements. The local concept image and `GAME_DIRECTION.md` may be ignored by Git; preserve them and do not force-add them.

## Asset intake and safety

- Prefer existing repository assets. For a new asset, record its source URL, author, license, permitted game use and redistribution, and any attribution requirement before adding it to the project. “Free to download” alone is insufficient. Respect the project's open-source and no-paid-service constraints.
- Inspect downloaded archives before extraction for executable files, scripts, plugins, and unexpected paths. Open third-party `.blend` files with auto-execution disabled and inspect embedded scripts, drivers, and linked libraries before enabling anything. Do not run unreviewed add-ons or code from an asset pack.
- Keep generation scripts, Blender working files, and temporary renders local under the ignored `source_assets/` directory; keep visual reference inputs under the ignored `concepts/` directory. Commit only approved game-ready assets under `game/art/`, engine files needed to load them, and selected in-game comparison captures that document an accepted visual state. Keep provenance and license information in the task record when using third-party content.
- Use Blender for shaping, materials, rigging, and export. Use Godot for the final lighting, collision, camera, movement, and performance decisions. Export through a format Godot imports reliably, normally glTF/GLB. The production method is not part of the game runtime and does not need to be versioned.

## Build and review loop

Work in the following order, only for stages relevant to the current milestone:

| Stage | Output | Gate before moving on |
| --- | --- | --- |
| Composition | Camera, playable bounds, rough masses | Spawn view matches the chosen reference composition; movement stays on screen. |
| Ground | Walkable paving and contact surface | No visible seam with the plate; collision and feet agree with the image. |
| Hero asset | Silhouette, scale, clothing colors, sword | Spawn capture reads as the intended protagonist from the fixed camera; other positions and walking are reviewed separately. |
| Motion | Idle, walk, grounding, attack only when in scope | No obvious sliding, clipping, detached equipment, or unreadable action. |
| World detail | Only essential props, vegetation, and material variation | Added detail improves depth and legibility without obscuring the hero or the route. |
| Light and atmosphere | Godot scene lighting and restrained effects | Visuals remain coherent with the plate across the playable area and run acceptably. |

For each stage:

1. Make the smallest change that can test the visual hypothesis. Choose whatever local generation method efficiently improves the asset; the quality of its code is not an acceptance criterion.
2. Produce a cheap preview first. Use low sample stills or a simple viewport capture before any expensive render. Estimate long render cost before starting it.
3. Capture the running game at a fixed spawn view and at relevant movement extremes. Place the result beside the reference at the same framing and size.
4. Name at most three observable gaps, ordered by visual impact. Correct those gaps before adding new detail. If a pass fails twice without a clear improvement, stop and revise the approach rather than adding complexity.
5. Keep working files locally, save the approved export and in-game capture, and record the visual decision. Advance only when the stage gate is met or the remaining gap is explicitly accepted in `PLAN.md`.

Do not assume that more polygons, dense scatter, high sample counts, or photorealistic Cycles renders improve a real-time scene. Measure the imported scene and use the least detail that holds up from the game camera. Keep collisions, walkable space, and protagonist visibility ahead of decoration.

## Working with Codex

Give each task a narrow brief: **target file or scene, reference, one intended change, constraints, and acceptance evidence**. Ask for a comparison capture and a short account of what changed. Prefer a targeted follow-up over replaying the entire design history. Reuse existing code and assets; do not generate a whole world from a broad prompt.

Codex may use local scripts or Blender tools to generate assets. Review any external script or add-on before execution. Keep generation code unversioned and spend review time on the resulting asset. Use subagents only for independent, clearly owned work when they reduce total effort; concurrent writers must use separate worktrees. The Claude artifact's named Sonnet handoff is not part of this workflow.

For gameplay behavior changes, follow repository test-driven practice. For asset generation, validate the visible output through paired reference and in-game captures and refine it until it matches the acceptance criteria. Do not add TDD or code tests for the generation method. Run relevant Godot checks only when engine integration or gameplay behavior changes. Report what was observed, what remains visibly different, and whether performance or integration changed. Avoid claiming a visual pass from a headless test alone.

## Completion record

A production task is complete when its acceptance view passes, the approved asset loads in Godot, relevant integration checks pass if needed, third-party provenance is recorded, and remaining visual gaps are written down. Update `PLAN.md` only to reflect a verified state or an explicit change of scope.

## Reference basis

- [Claude and Blender environment workflow](https://www.youtube.com/watch?v=Udahf4a0UwQ&t=156s): tutorial-led planning, staged construction, preview and comparison loops.
- [Claude Blender Workflow artifact](https://claude.ai/artifact/JQBq3LhmBGQNJsxnihm88A): source of the original cinematic workflow, adapted here for Codex and a playable Godot scene.
- [Hyper-Realistic Forest Blender tutorial](https://www.youtube.com/watch?v=OCg2_6XpITg): technique reference for terrain, vegetation, materials, lighting, and atmosphere. Its third-party asset links and paid add-ons require separate suitability and license review.
