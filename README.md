# The Stilled Bell: Village v0

An unofficial, non-commercial *Wheel of Time* fan game prototype. The current MVP target is one small, walkable 3D village square in Godot, styled after the local `concepts/v0-awakening-graybox.png`. See [PLAN.md](PLAN.md) for the reduced asset and visual production plan. The Godot MCP bridge is an editor-only development add-on and is excluded from exports.

## Run

Open this directory in Godot 4.7.2 and press **F5** to run the project. The project starts at `game/visual_mvp.tscn`; move with WASD. The camera is fixed and only the central floor is walkable.

The first configured export target is macOS. Install matching Godot export templates, then use the **macOS** preset in **Project → Export**. Exported files belong in the ignored `builds/` directory. The main scene and rules check have been verified with Godot 4.7.2 in headless mode; no distributable build has been exported yet.

## Current v0

- The current scene combines a reference-derived static backdrop with a small 3D floor and the existing 3D movement controller.
- The next visual object is the protagonist. The current capsule is a placeholder until its silhouette matches the reference.
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

Run the checks with `godot --headless --path . --script tests/run_rules.gd`, `godot --headless --path . --script tests/run_keyboard.gd`, `godot --headless --path . res://tests/combat.tscn`, and `godot --headless --path . res://tests/arena.tscn`.
