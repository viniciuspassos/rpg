# Village MVP: one fixed-camera visual scene

## Goal and reference

Build one tightly bounded village duel composition in Godot 4.7.2. The current reference is the local, intentionally untracked `concepts/v0-awakening-graybox.png`, annotated with the playable region. The fixed camera should resemble that frame. Only the protagonist and her opponent appear in the visual MVP; there are no villagers or other bystanders in this scene. The central paving remains 3D; the foreground protagonist uses view-specific illustrated poses so her proportions and lighting match the background plate.

The project already has a player controller and earlier gameplay code. The visual MVP runs from `game/visual_mvp.tscn`; the earlier quest scene stays in `game/main.tscn` for reference. The visual scene reuses the controller and fixed camera with illustrated idle and walk poses.

## Effort-saving art direction

- Use the central paving around both duel participants as the arena. An invisible 3D collision boundary keeps combatants out of the well, stairs, buildings, and foreground props.
- Use a fixed camera so the static plate and 3D floor remain aligned. The player can move inside the ring but cannot rotate the view.
- Use the duel plate for the village and fixed magic. Show the opponent with the existing transparent art on a camera-aligned 3D sprite, ready for later animation. Scale the existing 3D paving asset across the duel area and sample the plate from the fixed view, hiding the seam between the arena and background paving.
- Use a transparent illustrated protagonist for the fixed camera. Keep the experimental 3D model in the earlier playable scene until a matching animated asset is produced.
- Keep UI out of the comparison frame until the protagonist and walking space match the reference.

## Asset inventory

| Priority | Deliverable | Minimum production approach |
| --- | --- | --- |
| Done | Cleaned background plate | Image edit of the annotated reference; removes the drawn oval, red note, HUD, and foreground protagonist. Saved as `game/art/village_backdrop.png`. |
| Done | Duel plate and static opponent | `game/art/village_duel_empty.png` retains the village and fixed magic without any character. `game/art/opponent_static.png` is a transparent, independent pose placed in 3D depth. The earlier combined plate remains as a reference. |
| Done | Duel arena and boundary | `game/art/arena_paving.glb` covers the duel floor with fixed-view paving color. An invisible 3D collision ring contains the protagonist and future 3D combatants. |
| In review | Protagonist | The approved raised-hand pose remains the rear idle view. Matching front and side poses and two strides per direction appear in the [idle capture](docs/visual-progress/protagonist-motion-idle.png) and [walk capture](docs/visual-progress/protagonist-motion-walk.png). The earlier 3D model remains in the playable prototype. |
| In review | Foot contact and framing | The illustrated poses share a foot baseline and contact shadow. The revised spawn allows movement toward the center and directly to the right. A real-input route reached the center, approached the opponent, stopped at the wall, and returned without leaving the frame. Close overlap with the fixed opponent pose, limited walk frames, and the static background perspective still need player review. |
| Later, only if needed | UI | Add a small objective/health overlay after the protagonist comparison passes. |

The completed arena rows describe a functional visual baseline, not final asset approval. Before gameplay mechanics, produce and visually review these remaining assets in order:

1. **Shaded 3D paving (in review).** The arena now uses shallow 3D relief shaped from the existing painted stone contrast, a UV color texture, and restrained scene-light contribution. The fixed magic and rim still blend with the duel plate because a fully independent UV color created doubled paving lines in the fixed view. The [spawn capture](docs/visual-progress/arena-paving-spawn.png) and [movement capture](docs/visual-progress/arena-paving-movement.png) show no visible arena edge or foot clipping. The depth is intentionally subtle; review it at game scale before accepting this visual gate.
2. **Arena-edge details (in review).** A small GLB now places faceted stones, broken timber, and a wooden bucket on empty painted paving beyond the left arena boundary. Existing static foreground props cover the right side, so a candidate right-hand cluster was removed after it appeared in front of a painted crate. The [spawn capture](docs/visual-progress/arena-edge-spawn.png) and [left-limit capture](docs/visual-progress/arena-edge-left.png) show no duplicate object or hidden combatant. A real-input route still reached the center and both barriers; the new details have no collision and do not narrow it. Review their scale and color before accepting this visual gate.
3. **Independent magic assets.** Separate only the combat-area glow, dust, papers, and debris that need motion from the background plate; use restrained 2D/3D layers that match its illustrated palette. Gate: the effect reads at spawn and across the arena without duplicate baked elements or loss of character visibility. This is visual asset work, not ability gameplay.
4. **Two-combatant presentation pack.** Choose one consistent illustrated-sprite or stylized-3D approach for the protagonist and opponent. Complete the poses and supporting assets needed for readable idle, movement, attack, impact, and Power presentation, replacing the opponent's single fixed pose. Gate: both silhouettes remain clear at close range, hold their ground contact, and match the reference across the walkable area. No villagers, visitor, or companion assets belong to this scene.

Keep generation scripts, Blender working files, and temporary renders local and unversioned. Version only approved game-ready assets, engine files needed to load them, and selected in-game captures. Start gameplay mechanics after these four visual gates pass or a remaining gap is explicitly accepted here.

The paving relief and albedo were derived from the project's own clean village plate; no third-party asset was added. The original plate was produced with the built-in image generation edit tool from the user's local annotated reference. Its prompt was: preserve the exact village composition, architecture, people, magic, light and paving; remove the black oval, red note, foreground protagonist and HUD; reconstruct exposed paving; add no text or new objects. The first duel edit removed the three bystanders; a later pass separated the opponent into a transparent layer over the empty duel plate. The illustrated protagonist was generated from the same local reference as a transparent foreground cutout. The original reference is local and ignored by Git; the selected game-ready images are versioned under `game/art/`. Experimental production files remain local and unversioned.

The edge-detail GLB was modeled locally without third-party assets.

## Production sequence and review gates

1. **Background and arena.** Use the duel plate, fixed camera, a textured 3D floor across both combatants, and an invisible collision boundary. The [arena capture](docs/visual-progress/arena-barrier-review.png) has no visible floor seam. The [movement capture](docs/visual-progress/arena-movement-review.png) shows the protagonist inside the arena after real input. A route from spawn crossed the center, reached the right wall, and returned. Edge captures kept her on screen and away from the village props; collision checks covered eight directions and a second 3D body. The earlier [ring capture](docs/visual-progress/arena.png) records the smaller predecessor.
2. **Protagonist.** Match the reference silhouette, scale, clothing colors, hair, sword, and reaching pose from the fixed view. Gate: compare the running scene at spawn with the reference. The approved illustrated pose is retained for rear idle; the new spawn capture preserves that direction.
3. **Movement presentation.** Use view-specific idle and alternating walk poses with a shared ground anchor. The illustrated pass was reviewed in the running Compatibility scene at spawn, at both horizontal bounds, and in a fixed-rate four-direction [movement capture](docs/visual-progress/protagonist-motion-review.mp4). Arena corrections no longer change her facing. The cycle is intentionally simple; player review of sustained movement remains the gate before declaring motion complete.
4. **Duel staging.** Remove the three bystanders, keep the opponent separate from the plate, and give the protagonist room to move through the central paving. Gate: the running scene shows exactly the two duel participants and preserves the opponent's screen position and magic. The [duel capture](docs/visual-progress/duel-scene-review.png) records the earlier left-side pass.
5. **Opponent separation.** The opponent now uses the existing transparent image as a camera-aligned 3D sprite over the clean duel plate. Its depth is independent of the background. Keep the pose static in this milestone; close overlap with the protagonist still needs replacement art or motion, and reactions remain later work.
6. **Optional UI.** Add only HUD elements that improve the final view after both characters are accepted.

## Compatibility renderer decision

**Keep Compatibility for this milestone.** The project already selects `gl_compatibility` in `project.godot`. A local launch of Godot 4.7.2 on Apple M4 Pro completed successfully with `--rendering-method gl_compatibility`; the engine reported `OpenGL API 4.1 Metal ... Compatibility` and exited without a renderer error.

The actual fixed-camera composite was run and captured in Compatibility on this machine. It uses a canvas backdrop, a 3D floor mesh, ambient and directional lighting, and the existing player controller. The baked magic needs no renderer effect. Compatibility remains sufficient for this scope.

This validates startup and the current composite, not the final protagonist model or frame rate. A fixed plate also means there is no background parallax; the camera must remain fixed. If free camera rotation becomes a requirement, the plate would need to be replaced by 3D scenery or multiple layered views.

Godot references: [renderer features](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html), [environment and post-processing](https://docs.godotengine.org/en/4.7/tutorials/3d/environment_and_post_processing.html), [3D scene import](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html).

## Incremental visual record

Compare each object in the running game from the same camera view before moving to the next. The earlier [paving](docs/visual-progress/paving.png), [covered well](docs/visual-progress/well.png), and [composition](docs/visual-progress/composition.png) captures document the discarded full-3D approach. The [ring capture](docs/visual-progress/arena.png) records the earlier capsule view. The [model review](docs/visual-progress/protagonist-model.png) and [earlier playable capture](docs/visual-progress/protagonist-mvp.png) record the 3D prototype. The [illustrated candidate](docs/visual-progress/protagonist-illustrated-review.png) records the chosen direction. The [idle](docs/visual-progress/protagonist-motion-idle.png), [walking](docs/visual-progress/protagonist-motion-walk.png), and [four-direction motion](docs/visual-progress/protagonist-motion-review.mp4) captures document the protagonist pass. The [duel capture](docs/visual-progress/duel-scene-review.png) records the earlier left staging area; the [arena capture](docs/visual-progress/arena-barrier-review.png) and [movement capture](docs/visual-progress/arena-movement-review.png) record the enlarged 3D duel space. The opponent remains a static pose, so close overlap and combat reactions still need a later visual pass.

## Definition of done

- A 16:9 screenshot from the fixed camera matches the reference's composition, color, magic, and illustrated foreground protagonist while showing only the opponent as another character.
- The visible protagonist and floor load without errors in Compatibility.
- The illustrated movement pass receives player review before the walkable MVP is declared complete.
- Approved game-ready assets, comparison screenshots, and remaining visual gaps are recorded.

An exact pixel match from every camera angle is impossible with one still background, so this MVP intentionally fixes the camera and keeps the walkable area small.
