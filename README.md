# The Stilled Bell: Village v0

An unofficial, non-commercial *Wheel of Time* fan game prototype. The current v0 is one authored 3D village scene in Godot, built to match `concepts/v0-awakening-graybox.png`. It is a visual prototype and does not need to be playable yet. The Godot MCP bridge is an editor-only development add-on and is excluded from exports.

## Run

Open this directory in Godot 4.7.2 and press **F5** to run the project. The project starts at `game/main.tscn`.

The first configured export target is macOS. Install matching Godot export templates, then use the **macOS** preset in **Project → Export**. Exported files belong in the ignored `builds/` directory. The main scene and rules check have been verified with Godot 4.7.2 in headless mode; no distributable build has been exported yet.

## Current v0

- Open the project and inspect the single camera-ready village scene.
- The immediate work is character models, clothing, props, authored buildings, lighting, camera composition, and the blue-white awakening effect.
- Playability, controls, combat, quest flow, and localization are deferred until the visual scene is accepted.

The earlier playable route remains in the repository as reference material. It is not required for the current v0.

## Project map

- `game/main.gd` builds the village, interface, and authored episode flow.
- `game/session/` stores typed in-memory run state and fresh-run reset.
- `game/actors/` contains player, guard, and Power target behaviors.
- `game/village/village_quest_rules.gd` maps custody and testimony to outcomes.
- `game/i18n/strings.csv` contains all player-facing English and `pt_BR` text.
- `docs/V0_OPENING.md` records the episode's narrative and chronology decisions.
- `tests/run_rules.gd` is a headless rules/reset check.
- `tests/run_keyboard.gd` verifies keyboard-only gameplay bindings.
- `tests/combat.tscn` verifies the short encounter's two-hit guard defeat.

Run the checks with `godot --headless --path . --script tests/run_rules.gd`, `godot --headless --path . --script tests/run_keyboard.gd`, and `godot --headless --path . res://tests/combat.tscn`.
