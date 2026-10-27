# The Stilled Bell: Village v0

An unofficial, non-commercial *Wheel of Time* fan game prototype. The current MVP target is one small, walkable 3D village square in Godot, styled after the local `concepts/v0-awakening-graybox.png`. See [PLAN.md](PLAN.md) for the reduced asset and visual production plan, and [the production guidelines](docs/PRODUCTION_GUIDELINES.md) for the art and world pipeline. The Godot MCP bridge is an editor-only development add-on and is excluded from exports.

## Run

Open this directory in Godot 4.7.2 and press **F5** to run the visual MVP. It starts at `game/visual_mvp.tscn`; move the illustrated protagonist with WASD. The camera is fixed and only the central floor is walkable.

For the earlier playable village episode, open `game/main.tscn` in Godot and run that scene with **F6**. It uses the same 3D protagonist and supports the existing quest, combat, and language choices. Use WASD to move, E to interact, F to attack, Space to dodge, Q for the Power after awakening, and the arrow keys to turn the episode camera.

The first configured export target is macOS. Install the matching Godot export templates, then use the **macOS** preset in **Project → Export**. Two local builds are in the ignored `builds/` directory: `TheStilledBell-v0-macos.zip` starts the walkable visual MVP, and `TheStilledBell-v0-episode-macos.zip` starts the earlier village episode with the same protagonist. Unzip them into separate folders because the app bundles have the same name. Both were launched in headless smoke checks on this Mac. They use ad-hoc code signing and have not been notarized.

## Current v0

- The current visual scene is a fixed-camera duel with only the protagonist and opponent visible. It combines a reference-derived backdrop, a small 3D floor, the existing movement controller, and illustrated poses for idle and walking.
- The opponent and magic are currently part of `game/art/village_duel_backdrop.png`; they remain static while the scene's visual composition is reviewed. The earlier playable episode in `game/main.tscn` still contains its original cast and gameplay.
- The visual scene uses `game/art/protagonist_motion.png`, including the approved raised-hand pose at rest and directional walk frames. The earlier playable episode still uses `game/art/protagonist.glb`. Production files stay local and unversioned under `source_assets/`; selected in-game captures are in `docs/visual-progress/`.
- Combat, quest flow, and localization are deferred until the visual scene is accepted.

The earlier quest and combat route remains in `game/main.tscn` as reference material. Only its movement behavior is required for this milestone.

## Project map

- `game/main.gd` builds the village, interface, and authored episode flow.
- `game/visual_mvp.gd` builds the fixed-camera ring scene and static backdrop.
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

Run the checks with `godot --headless --path . --script tests/run_rules.gd`, `godot --headless --path . --script tests/run_keyboard.gd`, `godot --headless --path . res://tests/combat.tscn`, `godot --headless --path . res://tests/arena.tscn`, `godot --headless --path . res://tests/protagonist.tscn`, and `godot --headless --path . res://tests/visual_presentation.tscn`.
