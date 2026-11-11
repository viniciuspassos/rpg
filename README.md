# The Stilled Bell: Village v0

An unofficial, non-commercial *Wheel of Time* fan game prototype. The current target is one short, linear, third-person scene in Godot: a dawn road into Bellfold, the village square, a duel, and the awakening, styled after the images in `references/`. See [PLAN.md](PLAN.md) for the scene outline, stages, and decisions, and [the production guidelines](docs/PRODUCTION_GUIDELINES.md) for the art and world pipeline. The Godot MCP bridge is an editor-only development add-on and is excluded from exports.

## Run

Open this directory in Godot 4.7.2 and press **F5**. The main scene is the stage 1 graybox of the linear dawn scene, `game/levels/bellfold_dawn.tscn`: WASD to move, Space to dodge, and the arrow keys to turn and tilt the camera. Follow the road through the village gate to the square, then out by the south passage to the end gate. The superseded fixed-camera visual MVP is still in `game/visual_mvp.tscn` (run it with **F6**). The project renders with Forward+ (see `PLAN.md`).

For the earlier playable village episode, open `game/main.tscn` in Godot and run that scene with **F6**. It uses the same 3D protagonist and supports the existing quest, combat, and language choices. Use WASD to move, E to interact, F to attack, Space to dodge, Q for the Power after awakening, and the arrow keys to turn the episode camera.

The first configured export target is macOS. Install the matching Godot export templates, then use the **macOS** preset in **Project → Export**. Two local builds are in the ignored `builds/` directory: `TheStilledBell-v0-macos.zip` starts the walkable visual MVP, and `TheStilledBell-v0-episode-macos.zip` starts the earlier village episode with the same protagonist. Unzip them into separate folders because the app bundles have the same name. Both were launched in headless smoke checks on this Mac. They use ad-hoc code signing and have not been notarized.

## Current v0

- On 2026-11-11 the milestone changed to one linear third-person scene, produced without ComfyUI: CC0 base characters adapted to the palette, agent-built levels, shaders, and effects, and static images from an external image model. See `PLAN.md` and `docs/PRODUCTION_GUIDELINES.md`.
- The fixed-camera duel in `game/visual_mvp.tscn` and its painted plates and illustrated sprites are superseded and kept only as reference until the new scene replaces them.
- The earlier playable episode in `game/main.tscn` has the third-person controller, camera, combat, quest flow, and localization that the new scene will reuse.

## Project map

- `game/levels/bellfold_dawn.tscn` and `.gd` hold the linear v0 scene: graybox route, boundaries, beat triggers, and runtime player spawn.
- `game/main.gd` builds the village, interface, and authored episode flow.
- `game/visual_mvp.gd` builds the superseded fixed-camera ring scene and static backdrop.
- `game/session/` stores typed in-memory run state and fresh-run reset.
- `game/actors/` contains player, guard, and Power target behaviors.
- `game/village/village_quest_rules.gd` maps custody and testimony to outcomes.
- `game/i18n/strings.csv` contains all player-facing English and `pt_BR` text.
- `docs/V0_OPENING.md` records the episode's narrative and chronology decisions.
- `tests/run_rules.gd` is a headless rules/reset check.
- `tests/run_keyboard.gd` verifies keyboard-only gameplay bindings.
- `tests/combat.tscn` verifies the short encounter's two-hit guard defeat.
- `tests/arena.tscn` verifies that movement is clamped to the ring.
- `tests/protagonist.tscn` verifies the imported model, sword attachment, and walk motion.
- `tests/visual_presentation.tscn` verifies illustrated pose selection, ground anchoring, and fixed-camera framing.
- `tests/bellfold_route.tscn` walks the dawn scene end to end and checks beat order, boundaries, and camera clearance (the stage 1 gate).
- `tests/capture_bellfold_views.tscn` saves the gate captures and measures frame rate; it needs a window (see the header of `tests/run_capture_bellfold_views.gd`).

Run the checks with `godot --headless --path . --script tests/run_rules.gd`, `godot --headless --path . --script tests/run_keyboard.gd`, `godot --headless --path . res://tests/combat.tscn`, `godot --headless --path . res://tests/arena.tscn`, `godot --headless --path . res://tests/protagonist.tscn`, `godot --headless --path . res://tests/visual_presentation.tscn`, and `godot --headless --path . res://tests/bellfold_route.tscn`. On a fresh clone, run `godot --headless --path . --import` once first so the script classes are registered.
