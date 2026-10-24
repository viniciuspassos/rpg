# v0 implementation plan

Tracking issue: [#3 — Build v0: a playable village opening with awakening and consequential choices](https://github.com/viniciuspassos/rpg/issues/3).

## Goal

Deliver a 15–30 minute playable village episode based on the local `GAME_DIRECTION.md` direction draft, which is intentionally not tracked in this repository. This plan includes the implementation scope independently of that draft. A new player must be able to launch the exported build, understand their objective, explore, complete one combat encounter, discover and try the One Power, make a consequential decision, and see its result without developer guidance. All player-facing content must work in English and Brazilian Portuguese (`pt-BR`).

Current baseline: project direction only; no Godot project or gameplay implementation exists yet. This plan describes work to do, not completed features.

## Scope

- Godot 4 with typed GDScript; open-source tools and no paid services.
- One compact graybox village, third-person camera, and real-time combat.
- One player with male/female selection and provisional presentation; include at least one contextual NPC reaction for each selection.
- Two origin options and two motivation options, selected during initial setup. These affect dialogue and the personal task's framing, not separate levels or quest chains.
- Three recurring villagers, one visitor, and one enemy archetype. A close acquaintance accompanies part of the quest and reacts to its outcome.
- One quest, one combat encounter, one basic weapon attack, one dodge, and one limited controllable One Power ability introduced after the involuntary awakening.
- Two main record-custody outcomes. The player's account of the awakening modifies reactions and ending dialogue within those outcomes.
- Pause, restart, defeat/retry, objective display, basic combat feedback, language selection, and an ending screen.
- One desktop export target. Select it before project setup; keyboard and mouse are the initial input baseline.

## 1. Lock the opening design — P0

- [ ] Choose the desktop target, record the Godot version, and specify input bindings and camera behavior.
- [ ] Name and locate the village; select a precise event anchor within the established book-period window.
- [ ] Record what has already happened, what news the village knows, and what remains available for later divergence.
- [ ] Write the opening prophecy fragment, its provenance, how the record survived, and its author-facing meaning. Separate fact, uncertainty, and faction interpretation.
- [ ] Define the visitor's concrete objective, who orders the attempted seizure, and why the dispute escalates.
- [ ] Define the three villagers' goals, relationships, and conflicting views of the imperial inheritance.
- [ ] Write two origins and two motivations. Map each to a dialogue variation or task framing change.
- [ ] Write the six quest beats: personal task, request, seizure, awakening, custody/testimony, and consequence.
- [ ] Specify the two custody recipients and the testimony options, including what witnesses know independently of the player.
- [ ] Write an outcome table mapping each decision to a relationship change and an immediate visible response. Include the companion's reaction and the reason to leave the village.

Exit condition: the mission can be walked through on paper from start to both endings, with clear objectives, understandable stakes, and no unexplained escalation. Do not require the full campaign or all prophecy fragments to be written.

## 2. Build the playable foundation — P1

Depends on the camera, controls, and platform decisions in step 1.

- [ ] Create the Godot project, initial scene, input map, export preset, and minimal run/export instructions.
- [ ] Keep source assets and project configuration under version control; exclude generated/import caches and exported builds.
- [ ] Verify licenses and cost constraints before introducing dependencies or assets; record attribution where needed.
- [ ] Implement movement, camera, collisions, and a reusable interaction prompt.
- [ ] Build the compact village with placeholder geometry and a readable route through the quest.
- [ ] Implement basic attack, dodge, health, one enemy behavior, damage feedback, defeat, and retry.
- [ ] Implement the scripted involuntary awakening and a separate limited player-controlled ability afterward. Communicate its limits and availability.

Exit condition: movement and combat are playable in graybox; the encounter can be won, lost, and restarted without trapping the player. The ability can be tested after the awakening without adding a second combat encounter.

## 3. Connect story, choices, and consequences — P1

Depends on step 1's script and step 2's interaction and gameplay foundation.

- [ ] Choose the smallest editable content format supported by the actual needs; keep dialogue and quest text separate from gameplay logic.
- [ ] Implement initial character choices and their specified dialogue/task variations.
- [ ] Implement dialogue conditions, current objective, quest progression, and decision state.
- [ ] Connect all six opening beats to the playable location and encounter.
- [ ] Make the close acquaintance accompany the relevant segment and react to the decision; omit party management and combat AI.
- [ ] Implement both custody outcomes and testimony reactions without duplicating the whole quest.
- [ ] Show a relationship change and a concrete scene, access, or assistance change before the ending screen.
- [ ] Keep choices consistent for the current playthrough. A fresh run must clear them; retry must restore a coherent encounter state without duplicating consequences.

Exit condition: both endings are reachable, choices have visible effects in the episode, and neither protagonist selection is forced into a permanent allegiance or prophecy interpretation.

## 4. Make the slice independently playable — P1

Build localization support with the first content in step 3; complete presentation after the quest is connected.

- [ ] Add concise controls/tutorial prompts, current objective, health, interaction and combat feedback, pause, restart, and ending UI.
- [ ] Provide English source text and `pt-BR` translations for all player-facing strings, including character setup and both endings.
- [ ] Implement language selection and check layout, accents, missing keys, and text overflow in both languages.
- [ ] Add minimal sound or visual cues needed to read attacks, damage, interaction, and the awakening. Final assets and voice acting are not required.
- [ ] Export a build for the selected desktop platform and document how to launch it.

Exit condition: someone unfamiliar with the project can play the exported build without editor access or live explanations.

## 5. Validate the complete episode — P2

- [ ] For gameplay behavior changes, write focused failing tests first, then implement and refactor. Cover quest transitions, decision outcomes, retry/reset state, and localization completeness where automation is meaningful.
- [ ] Verify both custody outcomes and every testimony variant against the outcome table.
- [ ] Verify both protagonist selections and all origin/motivation variations without requiring redundant full playthroughs for every combination.
- [ ] Complete the episode in English and `pt-BR`; exercise both endings in both languages.
- [ ] Test defeat/retry, pause/resume, and a fresh run after finishing. Check for skipped beats, stale choices, duplicate rewards/events, and softlocks.
- [ ] Run the exported build and inspect runtime errors, collisions, camera behavior, and combat feedback.
- [ ] Observe a new player without coaching: record completion time, where objectives become unclear, whether combat is readable, and how they describe their choice's consequence.
- [ ] Fix blocking defects and repeat affected checks. Record remaining nonblocking issues and the tested build/version.

## Definition of done

- The exported build launches on the selected platform and supports a complete 15–30 minute episode without developer guidance.
- The player explores, interacts, completes combat, experiences the awakening, and tries one controllable ability.
- Initial character choices have their promised contextual effects.
- Both local endings work; custody and testimony affect visible reactions consistently.
- The companion reacts, and at least one relationship plus one concrete local response changes.
- All player-facing content works in English and `pt-BR`.
- Defeat/retry and a new playthrough work without stale or contradictory quest state.
- No known crash or progression blocker remains in the tested paths; verification results and run/export instructions are recorded.

## Explicitly deferred

Open world, additional regions, full faction entry or leadership systems, founding a channeler order, Rand's confrontation, the Last Battle, extensive skill trees, crafting, economy, party management, companion combat AI, detailed visual customization, voice acting, final art, and disk save/load. Session state and coherent retry are sufficient for this short slice. Public distribution is a separate milestone subject to the fan-work review already required by the direction document.

## Delivery order

Lock the small story and gameplay contract → prototype movement and combat → connect the quest and local consequences → finish bilingual presentation → export and validate with a new player. Expand content only after the complete loop meets the definition of done.
