# Game production guidelines

This is the working pipeline for producing the Bellfold v0 scene. `PLAN.md` defines the current milestone, stages, and gates; `ARCHITECTURE.md` defines runtime boundaries. Use this guide when planning or executing an art, world, animation, or integration task. Do not expand the milestone without updating `PLAN.md` first.

## Production target

Produce one convincing, playable, linear third-person scene in Godot before producing anything larger. It should feel like a large world through vistas and set pieces while the player follows one authored route. The scene outline and stage gates are in `PLAN.md`.

On 2026-11-11 the user replaced the earlier pipeline (ComfyUI image-to-3D, Blender, then Godot) and the fixed-camera painted-plate scene. The reasons were cost and results: the generated characters needed many sessions and still deformed, and a fixed plate cannot support a moving camera. The new pipeline is:

| Who | Produces |
| --- | --- |
| External image model (run by the user) | Concept frames per beat, tileable painted textures, distant matte paintings, decals, UI art, and, only later, turnarounds for a custom protagonist |
| Agents (Claude Code or Codex) | Level layout and graybox, gameplay and camera code, shaders, procedural geometry, kitbashing of CC0 packs, character adaptation, animation setup, VFX, lighting, UI, captures, and records |
| User | Image generation from agent briefs, play tests, and acceptance decisions |

ComfyUI is no longer part of the pipeline. Blender is optional: an agent may run it headless from a script for a conversion or mesh fix that Godot cannot do, but the user never needs to open it.

Judge every result in the running Godot scene, from the gameplay camera, at the intended viewport size. An asset preview is useful for inspection, but it does not prove that the asset reads well in motion or runs acceptably.

## Reference intake

1. Identify the exact output: one asset, one visual pass, or one beat of the scene. Write down the camera view, scale, intended use, and a small set of visible acceptance criteria.
2. Inspect the relevant reference images in `references/` and the beat table in `PLAN.md`. Extract composition, palette, light direction, and density; do not copy a reference pixel for pixel.
3. Separate transferable technique from an example's content. A tutorial or showcase video can teach a technique; its content, camera shots, and settings are not requirements. Do not claim to have watched a video when only its description or selected frames were available.
4. The game is inspired by *The Wheel of Time*. Inspiration is fine; do not reproduce characters, art, or text from the books, the show, or other games.

## Asset intake and safety

- Prefer existing repository assets, then CC0 packs (Quaternius, KayKit, Kenney, Poly Haven), then other assets whose license allows use in games. For each third-party asset, record source URL, author, license, permitted use and redistribution, and attribution needs before committing it. "Free to download" alone is insufficient. Avoid non-commercial and no-derivatives licenses.
- Download originals from the author's official page. A re-hosted copy is acceptable for a quick preview only.
- Inspect downloaded archives before extraction for executable files, scripts, plugins, and unexpected paths. Open third-party `.blend` files only headless with auto-execution disabled. Do not run unreviewed add-ons or code from an asset pack.
- Keep working files, downloads, and temporary renders local under the ignored `source_assets/`; keep image-model inputs and outputs under the ignored `concepts/`. Commit only game-ready assets under `game/art/` (or a pack folder under it), the engine files that load them, and selected captures that document an accepted state.
- Use glTF/GLB for 3D imports.

## Image briefs for the external image model

Agents write the brief; the user runs it in an image model and drops the result in `concepts/`. Each brief names the output's use, size, and constraints. Record the tool and prompt next to the file.

| Output | Format and constraints |
| --- | --- |
| Concept frame for a beat | 16:9, the gameplay camera's height and angle, the palette from `Paleta e interface da praça-7.png` |
| Tileable texture (paving, plaster, wood, thatch, roof tiles) | Square, 1024 or 2048 px, seamless on all edges, top-down and flat-lit, no cast shadows, no highlights, no perspective |
| Distant matte painting | Wide (for example 4096×1024), horizon at a stated height, no foreground objects, light direction matching the scene's sun |
| Decal or UI element | Transparent PNG, no shadow baked in |

Check every tileable texture tiled 3×3 in Godot before using it. Reject images with text, signatures, or watermarks.

## Build and review loop

Work through the stages in `PLAN.md` in order. For each stage:

1. Make the smallest change that can test the visual or gameplay hypothesis.
2. Capture the running game at the beat's spawn view and at relevant extremes. Place the capture beside the reference at the same size.
3. Name at most three observable gaps, ordered by impact. Fix those before adding detail. If a pass fails twice without clear improvement, stop and change the approach rather than adding complexity.
4. Save the accepted capture under `docs/visual-progress/`, and record the decision and remaining gaps in `PLAN.md`.

Keep collisions, readable routes, and protagonist visibility ahead of decoration. Use the least detail that holds up from the gameplay camera, and measure frame rate on the user's Mac after each environment pass.

## Level design for a linear scene

- Block out the whole route first with boxes and CSG. Play it end to end before adding art.
- Use natural boundaries: cliffs, houses, walls, fences, and props. Invisible walls only where nothing else fits, and never where the player expects to walk.
- Frame each vista: a framing element in the foreground, a clear focal point, and a matte painting or low-detail card for anything the player cannot reach.
- Separate beats with gates, narrow passages, or doors, so each area loads and reads on its own.
- Keep the camera clear: no tall props between the camera and the player on the main route; test with the camera's collision probe.

## Character and model generation

These rules replace the ComfyUI and Blender character method. Its lessons still apply and are listed under [Lessons from the superseded pipeline](#lessons-from-the-superseded-pipeline).

1. **Plan before producing.** List outputs, locations, sources, and cost before downloading or changing anything. When the user asks for a plan or says not to produce yet, stop after the list. Asset tasks exclude gameplay code, tests, and wiring unless the user asks.
2. **Start from a CC0 base with a skeleton and animations.** The protagonist uses Quaternius's *Ultimate Modular Women* "Medieval" model; the guard and Mara use models from the same Quaternius modular packs, so all characters share proportions and skeleton. Do not model organic characters from scripted primitives, and do not generate new 2D pose images per direction.
3. **Adapt, do not rebuild.** Recolor materials to the palette, swap or hide modular parts, and attach separate meshes for the cape, sword, pouch, and hair. Keep equipment as separate nodes attached with `BoneAttachment3D`, so the side is an explicit choice. Prefer doing this in Godot; use a headless Blender script only when a mesh must be merged or edited.
4. **Match the canon.** Compare silhouette, palette, hair, equipment side, and scale with the canon below and the references, from front, three-quarter, back, and the gameplay camera. Mirrored equipment is a defect.
5. **Keep characters clean.** No magic, glow, cast shadows, or background in a character texture. Effects are particles or separate meshes; lighting comes from Godot.
6. **Keep the mesh replaceable.** Gameplay, animation trees, and attachments depend on the skeleton and bone names, never on a specific mesh. A future custom protagonist only needs to be skinned to the same skeleton.

### Protagonist canon

- Style: stylized low-poly with human proportions, warm painterly light. Not realistic, not chibi.
- Hair: brown, tied in a low bun at the back. For v0, a red hood is an accepted alternative if no fitting hair mesh exists (open decision in `PLAN.md`).
- Clothing: cream short sleeves, dark navy tunic with a tan front panel, brown belt with a pouch on her left hip, brown trousers, tall brown boots with folded cuffs.
- Sword: a straight blade held low in her left hand. Her right hand is free to cast the Power.
- Cape: a red scarf-cape over the shoulders, with its tail hanging on her right side (user decision, 2026-11-01).

## Rig and animation pipeline

1. **Skeleton.** Use the skeleton that comes with the Quaternius base. Map it to Godot's `SkeletonProfileHumanoid` with a `BoneMap` in the import settings, so clips can be shared between characters and packs.
2. **Library animations first.** Use the clips that come with the base, then Quaternius's Universal Animation Library, then Mixamo, retargeted in Godot. Keep downloaded clips local under `source_assets/<character>/animations/` until an approved set is exported.
3. **Cape and cloth.** Start with a few bones driven by a simple spring script or `SpringBoneSimulator3D`; avoid full cloth simulation.
4. **Game-specific motion.** For a motion no library covers, such as channelling the Power, first try blending or layering library clips in an `AnimationTree`. Only if that fails, author the clip in Godot's animation editor or with a headless Blender script, and review it frame by frame.
5. **Test scene.** Keep a small animation test scene that previews every clip of every character, and review motion there before the level.
6. **Licenses.** Record the terms for each clip source. Mixamo needs a free Adobe account; its raw files must not be redistributed outside the game.

## Lessons from the superseded pipeline

The fixed-camera scene and the ComfyUI and Blender protagonist (2026-10-24 to 2026-11-04) failed in ways that still apply. Details are in git history up to commit `e905491`.

| What happened | Rule that still applies |
| --- | --- |
| A character scripted from primitives became a blocky doll; equipment ended up on the wrong side | Do not script organic characters from primitives. Check handedness in every view. |
| One illustrated pose per direction drifted in hair, face, and proportions, and had glow baked in | Derive every pose of a character from one model and one rig. Never bake effects or light into a character. |
| A larger model walked onto painted stairs and looked pasted on | After any scale change, recheck walk bounds and ground contact in the running scene. |
| A long generation ran for an hour on a blank input before anyone looked | Inspect the first intermediate output within minutes. Stop after two failed attempts. |
| The rigged model deformed because of smeared inputs and separately generated parts | Fix the input instead of hiding the defect downstream. |
| The user repeatedly had to ask for a plan first, and for assets only | Present the plan first when asked, and stay inside the asked scope. |

## Scene continuity

- Before starting, read the status in `PLAN.md` and the newest accepted captures in `docs/visual-progress/`. That accepted state is the baseline; do not regress it.
- Change only the target. When replacing a character or a beat's art, keep the route, collisions, camera rules, and other characters unchanged, and prove it with before and after captures.
- Replace an approach only after the new one passes the same gate. Until then, keep the last accepted asset.
- Record decisions, superseded approaches, and remaining gaps in `PLAN.md` or the relevant issue, not only in an agent's private memory. Claude Code and Codex both work on this project and read `AGENTS.md` and this guide, but not each other's memory.
- End each session with a hand-off in `PLAN.md`: files touched, what was tried and the result, the next step, and any local job still running.

## Working with Codex and Claude Code

Give each task a narrow brief: **target file or scene, reference, one intended change, constraints, and acceptance evidence**. Ask for a comparison capture and a short account of what changed. Reuse existing code and assets; do not generate a whole world from one broad prompt.

For gameplay behavior changes, follow the repository's test-driven practice. For asset work, validate the visible output through paired reference and in-game captures. Do not add code tests for an asset's production method. Report what was observed, what remains visibly different, and whether performance changed. A headless test alone never proves a visual pass.

Use subagents only for independent, clearly owned work when they reduce total effort; concurrent writers use separate worktrees.

## Completion record

A production task is complete when its gate passes in the running game, the asset loads in Godot, relevant integration checks pass, third-party provenance is recorded, and remaining gaps are written down. Update `PLAN.md` only to reflect a verified state or an explicit change of scope.
