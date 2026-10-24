# The Stilled Bell: Village v0

An unofficial, non-commercial *Wheel of Time* fan game prototype. This Godot 4 project is a short, third-person village episode built from original code and primitive graybox geometry. It uses no external game assets or runtime dependencies. The Godot MCP bridge is an editor-only development add-on and is excluded from exports.

## Run

Open this directory in Godot 4.7.2 and press **F5** to run the project. The project starts at `game/main.tscn`.

The first configured export target is macOS. Install matching Godot export templates, then use the **macOS** preset in **Project → Export**. Exported files belong in the ignored `builds/` directory. The main scene and rules check have been verified with Godot 4.7.2 in headless mode; no distributable build has been exported yet.

## Play

- **WASD** move; mouse rotates the third-person camera.
- **E** interacts with nearby people and objects.
- **Left mouse** attacks; **Space** dodges.
- **Q** uses the limited One Power after the awakening.
- **Esc** opens/closes the pause menu and releases the mouse cursor.

Talk to Mara and Tovin, pick up the rope by the well, and carry it to the bell. Hear Serah's request, read her sealed order, and ask Edrin and Mara what they will accept before returning to Serah. Defeat the guard, use the Power on the glowing stones, and choose who keeps the record and what you say about the awakening. The language toggle on the title screen switches between English and Brazilian Portuguese.

## Project map

- `game/main.gd` builds the village, interface, and authored episode flow.
- `game/session/` stores typed in-memory run state and fresh-run reset.
- `game/actors/` contains player, guard, and Power target behaviors.
- `game/village/village_quest_rules.gd` maps custody and testimony to outcomes.
- `game/i18n/strings.csv` contains all player-facing English and `pt_BR` text.
- `docs/V0_OPENING.md` records the episode's narrative and chronology decisions.
- `tests/run_rules.gd` is a headless rules/reset check.

Run the small rules check with `godot --headless --path . --script tests/run_rules.gd`.
