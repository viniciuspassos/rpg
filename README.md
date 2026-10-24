# The Stilled Bell: Village v0

An unofficial, non-commercial *Wheel of Time* fan game prototype. This Godot 4 project is a roughly three-minute, third-person village episode built from original code and temporary graybox geometry. It uses no external game assets or runtime dependencies. The Godot MCP bridge is an editor-only development add-on and is excluded from exports.

## Run

Open this directory in Godot 4.7.2 and press **F5** to run the project. The project starts at `game/main.tscn`.

The first configured export target is macOS. Install matching Godot export templates, then use the **macOS** preset in **Project → Export**. Exported files belong in the ignored `builds/` directory. The main scene and rules check have been verified with Godot 4.7.2 in headless mode; no distributable build has been exported yet.

## Play

- **WASD** move; **arrow keys** rotate the third-person camera.
- **E** interacts with nearby people and objects.
- **F** attacks; **Space** dodges.
- **Q** uses the limited One Power after the awakening.
- **Tab/arrow keys** select menu options; **Enter** confirms.
- **Esc** opens/closes the pause menu.

Find Serah in the square and hear her request and the order behind it. Defeat the guard, use the Power on the glowing stones, and choose who keeps the record and what you say about the awakening. The language toggle on the title screen switches between English and Brazilian Portuguese.

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
