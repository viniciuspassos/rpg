# v0 implementation plan

Tracking issue: [#3 — Build v0: a visual village scene](https://github.com/viniciuspassos/rpg/issues/3).

## Goal

Deliver one authored 3D village scene based on the local `GAME_DIRECTION.md` direction draft, which is intentionally not tracked in this repository. This v0 is a visual prototype and does not need to be playable. The scene should recreate the composition, modeled characters, warm lighting, architecture, and blue-white awakening effect from `concepts/v0-awakening-graybox.png`. Gameplay, controls, quest flow, combat, localization, and export validation are deferred.

Current baseline: the repository contains a Godot project with a procedural village graybox and an earlier playable experiment. That experiment is reference code, not the v0 acceptance target. The next step is visual production for one scene; no playable loop is required for this milestone.

## Scope

- Godot 4 with typed GDScript; open-source tools and no paid services.
- One compact village scene with stylized modeled characters and environment art matching the local concept image.
- One player with male/female selection and provisional presentation; include at least one contextual NPC reaction for each selection.
- Two origin options and two motivation options, selected during initial setup. These affect the opening dialogue, not separate levels or quest chains.
- Three recurring villagers, one visitor, and one enemy archetype. A close acquaintance accompanies part of the quest and reacts to its outcome.
- One staged awakening pose and blue-white Power effect; the effect does not need to be interactive.
- One desktop preview target for visual review. Keyboard controls are deferred.

## 1. Lock the opening design — P0

- [x] Choose the desktop target, record the Godot version, and specify input bindings and camera behavior.
- [x] Name and locate the village; select a precise event anchor within the established book-period window.
- [x] Record what has already happened, what news the village knows, and what remains available for later divergence.
- [x] Write the opening prophecy fragment, its provenance, how the record survived, and its author-facing meaning. Separate fact, uncertainty, and faction interpretation.
- [x] Define the visitor's concrete objective, who orders the attempted seizure, and why the dispute escalates.
- [x] Define the three villagers' goals, relationships, and conflicting views of the imperial inheritance.
- [x] Write two origins and two motivations. Map each to a dialogue variation or task framing change.
- [x] Write the short route: request, seizure, awakening, Power trial, custody/testimony, and consequence.
- [x] Specify the two custody recipients and the testimony options, including what witnesses know independently of the player.
- [x] Write an outcome table mapping each decision to a relationship change and an immediate visible response. Include the companion's reaction and the reason to leave the village.

Exit condition: the mission can be walked through on paper from start to both endings, with clear objectives, understandable stakes, and no unexplained escalation. Do not require the full campaign or all prophecy fragments to be written.

## 2. Build the visual scene — P0

Depends on the camera, controls, and platform decisions in step 1.

- [x] Create the Godot project, initial scene, input map, export preset, and minimal run/export instructions.
- [x] Keep source assets and project configuration under version control; exclude generated/import caches and exported builds.
- [x] Verify licenses and cost constraints before introducing dependencies or assets; record attribution where needed.
- [ ] Replace placeholder geometry with authored village meshes, roofs, stairs, market props, banner, well, and stone paving.
- [ ] Create or source properly licensed stylized human models for the protagonist, guard, villagers, and archivist; rig and pose them in Blender.
- [ ] Build clothing, hair, weapons, and readable silhouettes for the characters in the reference composition.
- [ ] Stage the characters in one camera composition matching the concept image.
- [ ] Add warm sunset lighting, shadows, atmospheric depth, and the blue-white awakening effect.

Exit condition: the project opens directly into one camera-ready 3D scene that can be compared with the reference image. No input, combat, quest progression, or restart flow is required.

Visual acceptance for v0: compare a rendered screenshot against `concepts/v0-awakening-graybox.png` at the target resolution. Model and rig game assets in Blender; use ComfyUI for concept variations, texture references, or paintovers where useful. The screenshot is the acceptance artifact, not a playable build.

## 3. Deferred gameplay and story — later milestone

This work starts after the visual scene is accepted.

- [x] Choose the smallest editable content format supported by the actual needs; keep dialogue and quest text separate from gameplay logic.
- [x] Implement initial character choices and their specified dialogue/task variations.
- [x] Implement dialogue conditions, current objective, quest progression, and decision state.
- [x] Connect all six opening beats to the playable location and encounter.
- [x] Make the close acquaintance accompany the relevant segment and react to the decision; omit party management and combat AI.
- [x] Implement both custody outcomes and testimony reactions without duplicating the whole quest.
- [x] Show a relationship change and a concrete scene, access, or assistance change before the ending screen.
- [x] Keep choices consistent for the current playthrough. A fresh run must clear them; retry must restore a coherent encounter state without duplicating consequences.

Exit condition: both endings are reachable, choices have visible effects in the episode, and neither protagonist selection is forced into a permanent allegiance or prophecy interpretation.

## 4. Deferred playable slice — later milestone

Build localization support with the first content in step 3; complete presentation after the quest is connected.

- [ ] Add controls/tutorial prompts, objectives, health, interaction and combat feedback after visual acceptance.
- [ ] Provide English source text and `pt-BR` translations when playable content is authored.
- [ ] Add pause, restart, defeat/retry, and ending UI when the playable slice begins.
- [ ] Export a playable build only in the later milestone.

Exit condition: deferred until the visual scene is accepted and gameplay work is authorized.

## 5. Validate the visual scene — P1

- [ ] Open the scene in Godot and capture the target camera view.
- [ ] Compare composition, character silhouettes, architecture, palette, lighting, shadows, and Power effect against the reference.
- [ ] Check that imported meshes, textures, rigs, and licenses load without errors.
- [ ] Record the accepted screenshot and remaining visual gaps.

## Definition of done

- The project opens into one camera-ready 3D village scene.
- Visible characters and key architecture use authored or properly licensed models instead of placeholders.
- Composition, warm lighting, shadows, character poses, and the blue-white awakening effect are visibly close to the reference image.
- A comparison screenshot and visual gap list are recorded.
- Playability, controls, quest flow, localization, combat, and export are explicitly deferred.

## Explicitly deferred

Open world, additional regions, full faction entry or leadership systems, founding a channeler order, Rand's confrontation, the Last Battle, extensive skill trees, crafting, economy, party management, companion combat AI, detailed visual customization, voice acting, final art, and disk save/load. Session state and coherent retry are sufficient for this short slice. Public distribution is a separate milestone subject to the fan-work review already required by the direction document.

## Delivery order

Produce character and environment art in Blender → stage the single scene in Godot → tune lighting, camera, and Power effect → capture and compare the reference screenshot → begin gameplay after visual acceptance.
