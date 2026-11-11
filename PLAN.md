# Bellfold v0: one linear third-person scene

## Decision record (2026-11-11)

The user changed the milestone and the production pipeline on 2026-11-11:

- **Scope.** One playable, linear scene in the style of a modern action-adventure: it feels like a large world through vistas and set pieces, but the player follows one authored path. No open world.
- **Camera.** Third-person, over the shoulder, player-controlled. It replaces the fixed camera and the painted background plate of the earlier visual MVP.
- **Engine.** Stay on Godot 4.7.2. Unreal was considered and rejected: the target look is stylized and painterly, not photoreal, and Godot's text-based scenes, scripts, and shaders let Claude Code or Codex do most of the work directly.
- **Pipeline.** ComfyUI is dropped. The user does not need to open Blender. An external image model produces static images only (concepts, tileable textures, distant matte paintings). Agents do everything else: layout, code, shaders, procedural geometry, VFX, lighting, kitbashing, integration, and captures. See `docs/PRODUCTION_GUIDELINES.md`.
- **Characters.** Start from free CC0 base characters with a skeleton and animations, adapted to the reference palette. The protagonist uses Quaternius's *Ultimate Modular Women* "Medieval" model ([comparison](docs/visual-progress/base-character-comparison.png)). A better or custom protagonist can replace the mesh later on the same skeleton, without gameplay changes.

Superseded, kept for reference: the fixed-camera duel in `game/visual_mvp.tscn` with its plates, illustrated sprites, and magic layer; the ComfyUI and Blender protagonist (rig v3, local under `source_assets/protagonist/`); and the opponent reference pack. Their full history, hand-offs, and acceptance records are in git history up to commit `e905491`. Do not continue that work unless the user reopens it.

## Scene outline

A short episode, about 5 to 10 minutes of play, drawn from the references in `references/` and the story in `docs/V0_OPENING.md`.

| Beat | Place | Play | Main reference |
| --- | --- | --- | --- |
| 1. Dawn road | Road into Bellfold, valley vista, bell frame at the village edge | Walk and camera tutorial; first vista; one gate that hides the edge of the level | `O sino imóvel ao amanhecer-9.png` |
| 2. Village square | Square with the bell, well, stairs, houses | Meet Mara and see the ledger; short dialogue; objective | `Paleta e interface da praça-7.png`, `Mara, guardiã do velho livro-3.png` |
| 3. Duel | Central paving of the square | Melee fight against the guard: attack, dodge, block | `Duelo ao amanhecer em Bellfold-5.png` |
| 4. Awakening | Same square | Scripted set piece: stones lift, the bell rings, the Power reacts | `O despertar das pedras-4.png`, `O despertar do sino de bronze-10.png` |
| 5. Consequence | Square, toward the road out | Short closing beat with Mara and the ledger; end card | `Livro fiscal com fólio remendado-6.png`, `Pergaminho oficial selado-8.png` |

Cast for v0: the protagonist, the guard, and Mara. Serah and other villagers are optional and come only after the gates below pass. The narrative and outcome rules in `docs/V0_OPENING.md` stay valid; the full custody and testimony choices can stay in the existing quest director and be trimmed for this scene if needed.

How the scene fakes a large world:

- One path with gentle branches that rejoin. Cliffs, walls, fences, and houses form the boundaries instead of invisible walls wherever possible.
- Distant hills, sky, and far villages are matte paintings or low-detail cards, lit to match.
- Narrow passages and gates separate beats and hide anything not yet needed.
- The camera is controlled near set pieces so the player looks at the vista or the action.

## Production stages and gates

Each stage ends with a capture from the running game, beside the relevant reference, at 1280×720 or higher. Stop and report after two failed passes at the same gate.

| # | Stage | Output | Gate | Rough estimate |
| --- | --- | --- | --- | --- |
| 0 | Plan and docs | This plan, updated guidelines and agent instructions | User approves the direction | Done |
| 1 | Graybox | New scene `game/levels/bellfold_dawn.tscn` built from boxes and CSG: road, square, boundaries, beat triggers. Third-person controller and camera reused from `game/actors/player.gd`. Renderer decision (see below) | The whole route is playable start to end, the camera never clips or loses the player, every boundary holds, and the vistas are framed | 2 to 3 sessions |
| 2 | Characters | Protagonist, guard, and Mara from CC0 bases, recolored to the palette, with cape, sword, and hair or hood adapted. Godot import with a humanoid `BoneMap`, an `AnimationTree`, and an animation test scene | Each character reads correctly from the gameplay camera; idle, walk, run, attack, hit, dodge, and death play without sliding or detached equipment | 2 to 3 sessions |
| 3 | Look | Stylized shading, dawn sun, sky, fog, color grading; first painted textures from the image model | A capture of the square at spawn matches the palette and light of `Paleta e interface da praça-7.png` | 2 sessions |
| 4 | Environment kit | Houses, walls, fences, bell frame, well, stairs, props from CC0 packs plus procedural pieces (paving, walls, stones); matte paintings for the far background | Each beat's capture reads like its reference in composition and density, at a stable frame rate on the user's Mac | 3 to 4 sessions |
| 5 | Combat and set piece | Duel tuning, hit feedback, the stone and bell awakening with particles and camera work | The duel is readable and fair in a play test; the awakening reads like its references | 3 to 4 sessions |
| 6 | Polish | Minimal HUD, dialogue in English and pt-BR, audio placeholders, end card, macOS export | The user plays the full scene in an exported build | 1 to 2 sessions |

The estimates are rough and count focused agent sessions, not calendar time. The biggest risks are character quality and combat feel; the gates are ordered so both are visible early.

## Open decisions

- **Renderer.** The project uses Compatibility. Compatibility lacks volumetric fog, SSAO, SDFGI, and some post-processing that help the dawn atmosphere. Recommendation: test Forward+ during stage 1 on the user's Mac and switch if it runs well; record the result here.
- **Protagonist head.** The Medieval base has a hood and short hair; the canon has a low bun. Choose in stage 2 between the hood in the canon red, or a hair mesh from the same pack.
- **Sword hand.** The base holds the sword in her right hand; the canon puts it in her left. Attaching the sword to the left hand bone is the default; check that attack clips still read.
- **Animation coverage.** The modular pack has about 24 clips. Block, side dodges, and combos must come from Quaternius's Universal Animation Library or Mixamo through Godot retargeting. Confirm in stage 2 that the base skeleton maps cleanly to `SkeletonProfileHumanoid`.

## Asset sources

Record source URL, author, license, and attribution needs for every third-party asset before it is committed (see the guidelines).

| Need | First choice | License |
| --- | --- | --- |
| Characters | Quaternius Ultimate Modular Women and Men (quaternius.com) | CC0 |
| Animations | Quaternius Universal Animation Library; Mixamo as a fallback | CC0; Mixamo terms (free Adobe account, use in games allowed, no redistribution of raw files) |
| Medieval village pieces and props | Quaternius and KayKit medieval packs, Kenney | CC0 |
| Textures and HDRIs | Painted tileable textures from the image model; Poly Haven only where a photo texture is repainted or stylized | Own output; CC0 |
| Distant vistas, concepts, UI art | External image model | Own output; record tool and prompt |

## Definition of done

- The scene runs from start to end in Godot 4.7.2 with keyboard input, without errors.
- Each beat has an accepted capture beside its reference in `docs/visual-progress/`.
- The duel and the awakening pass a play test by the user.
- Player-facing text exists in English and pt-BR.
- Every third-party asset's provenance and license is recorded, and remaining gaps are written here.
- A macOS export of the scene launches.

## Status and hand-off

- 2026-11-11: direction and pipeline changed as recorded above. The base-character comparison was rendered from the CC0 models (re-hosted copies used for the preview only; download the originals from quaternius.com and kaylousberg.com before integration). No game files changed. Next: stage 1, graybox.
