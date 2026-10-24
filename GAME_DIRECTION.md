# Game direction

## Working concept

An original fantasy action RPG drawing on the broad appeal of *The Wheel of Time*, *The Witcher*, *Tibia*, and *Mass Effect*: a lived-in world, consequential choices, memorable companions, exploration, and responsive combat. Treat these works as inspiration for tone and design patterns, not as material to reproduce. Use original characters, places, factions, plotlines, dialogue, and visual identity.

## Technology

- **Project constraints:** Use open-source tools and software only. Do not introduce paid services at the repository level, including paid hosting, CI, storage, APIs, or subscriptions. Prefer local workflows and self-hostable options. Before adding a dependency or service, verify its license and whether its intended use requires payment; flag any uncertain cases for review.
- **Engine:** Godot 4, using GDScript for engine-facing gameplay and tools.
- **JavaScript:** Use JavaScript/TypeScript where it fits standalone tooling, content pipelines, web services, or companion tools. Godot's native scripting and editor workflows are the default for core gameplay; avoid adding a JavaScript runtime/plugin until a concrete need justifies its maintenance cost.
- **3D/art:** Blender for later modeling, animation, scene polish, and asset export. Begin with graybox geometry and simple materials.
- **Version control:** Git; keep source assets and project configuration in the repository, and exclude generated/import caches.

## Language policy

- Write all project documentation, code, identifiers, variable names, comments, commit messages, tooling, and other development materials in English.
- The game must support English and Brazilian Portuguese (`pt-BR`) for player-facing gameplay content, including dialogue, quest text, UI, and other in-game text.
- Keep player-facing text localizable and separate from gameplay logic so both languages can be maintained consistently. Use English as the source language for development and content authoring unless a localization workflow later establishes a better approach.

## Design pillars

1. **A world with depth:** distinct cultures, histories, dangers, and places worth exploring.
2. **Choices with consequences:** dialogue and quest decisions affect relationships, factions, and later events.
3. **Build-your-own hero:** combat and progression support multiple approaches, including a distinctive magic system.
4. **Companions matter:** recruitable characters have clear perspectives, personal arcs, and reactions to the player's choices.
5. **Readable, satisfying play:** responsive controls, clear combat feedback, and a useful early gameplay loop before content scale.

## Initial scope

Start with a small vertical slice: one original location, one controllable player, one interaction or quest, one combat encounter, and one consequential choice. Validate the feel and production workflow before expanding the world or committing to detailed assets.

## Near-term decisions

- Choose the initial camera and combat perspective before building levels.
- Define the smallest fun gameplay loop and prototype it with placeholders.
- Keep narrative, dialogue, and item data in formats that are easy to edit and validate; choose a format when the first content pipeline is implemented.
- Track original IP boundaries: inspiration is fine; do not copy protected names, characters, dialogue, maps, or distinctive story material.

## Optional open-source tools to consider later

- **TypeScript + Node.js:** scripts for validating content, batch-processing assets, or building small editor utilities.
- **Blender:** DCC workflow for custom models, animation, and scene work once the slice is proven.
- **Git LFS:** open-source client; use only with a free or self-hosted storage option, since hosted storage may cost money.
- **Krita or GIMP:** concept art and texture editing, if needed.
- **Audacity:** basic sound editing, if needed.

Add tools only when a concrete production need appears; keep the first prototype lean. Open-source software can still rely on paid hosting or services, so evaluate both the software license and operating cost before adopting it.
