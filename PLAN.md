# Village MVP: one fixed-camera visual scene

## Goal and reference

Build one tightly bounded village duel composition in Godot 4.7.2. The current reference is the local, intentionally untracked `concepts/v0-awakening-graybox.png`, annotated with the playable region. The fixed camera should resemble that frame. Only the protagonist and her opponent appear in the visual MVP. The central paving remains 3D; the foreground protagonist uses view-specific illustrated poses so her proportions and lighting match the background plate.

The project already has a player controller and earlier gameplay code. The visual MVP runs from `game/visual_mvp.tscn`; the earlier quest scene stays in `game/main.tscn` for reference. The visual scene reuses the controller and fixed camera with illustrated idle and walk poses.

## Effort-saving art direction

- Restrict movement to the central floor left of the opponent. No route to the well, stairs, buildings, or foreground props is required.
- Use a fixed camera so the static plate and 3D floor remain aligned. The player can move inside the ring but cannot rotate the view.
- Use the duel plate for the village, fixed magic, and opponent pose. The 3D floor samples that plate from the fixed view, hiding the seam between the walkable floor and background paving.
- Use a transparent illustrated protagonist for the fixed camera. Keep the experimental 3D model in the earlier playable scene until a matching animated asset is produced.
- Keep UI out of the comparison frame until the protagonist and walking space match the reference.

## Asset inventory

| Priority | Deliverable | Minimum production approach |
| --- | --- | --- |
| Done | Cleaned background plate | Image edit of the annotated reference; removes the drawn oval, red note, HUD, and foreground protagonist. Saved as `game/art/village_backdrop.png`. |
| In review | Duel plate | A further edit removes the three bystanders and restores the well, paving, and furniture behind them. The opponent and magic remain in `game/art/village_duel_backdrop.png`, shown in the [in-game duel capture](docs/visual-progress/duel-scene-review.png). |
| Done | Central floor and boundary | Elliptical 3D mesh and ground collision in `game/visual_mvp.gd`; screen-projected plate color gives a continuous paving image. Player movement is clamped inside the ellipse. |
| In review | Protagonist | The approved raised-hand pose remains the rear idle view. Matching front and side poses and two strides per direction appear in the [idle capture](docs/visual-progress/protagonist-motion-idle.png) and [walk capture](docs/visual-progress/protagonist-motion-walk.png). The earlier 3D model remains in the playable prototype. |
| In review | Foot contact and framing | The illustrated poses share a foot baseline and contact shadow. The walk ellipse now uses the empty left paving while keeping the protagonist out of the opponent's staging area. Longer movement still needs a player review for the limited frame count and static background perspective. |
| Later, only if needed | UI | Add a small objective/health overlay after the protagonist comparison passes. |

The original plate was produced with the built-in image generation edit tool from the user's local annotated reference. Its prompt was: preserve the exact village composition, architecture, people, magic, light and paving; remove the black oval, red note, foreground protagonist and HUD; reconstruct exposed paving; add no text or new objects. The duel edit removes only the green-clothed woman, gray-haired book holder, and blue-robed man while retaining the opponent, magic, camera, and sunset palette. The illustrated protagonist was generated from the same local reference as a transparent foreground cutout. The original reference is local and ignored by Git; the selected game-ready images are versioned under `game/art/`. Experimental production files remain local and unversioned.

## Production sequence and review gates

1. **Background and ring.** Use the cleaned plate, fixed camera, a small textured 3D floor, and bounded movement. Gate: the spawn image reproduces the reference scenery without a visible floor seam. The [ring capture](docs/visual-progress/arena.png) records this pass; character framing during movement belongs to the later movement pass.
2. **Protagonist.** Match the reference silhouette, scale, clothing colors, hair, sword, and reaching pose from the fixed view. Gate: compare the running scene at spawn with the reference. The approved illustrated pose is retained for rear idle; the new spawn capture preserves that direction.
3. **Movement presentation.** Use view-specific idle and alternating walk poses with a shared ground anchor. The illustrated pass was reviewed in the running Compatibility scene at spawn, at both horizontal bounds, and in a fixed-rate four-direction [movement capture](docs/visual-progress/protagonist-motion-review.mp4). Arena corrections no longer change her facing. The cycle is intentionally simple; player review of sustained movement remains the gate before declaring motion complete.
4. **Duel staging.** Remove the three bystanders, keep only the opponent in the plate, and give the protagonist room to move on the empty left paving. Gate: the running scene shows exactly the two duel participants and preserves the opponent's position and magic. The [duel capture](docs/visual-progress/duel-scene-review.png) records this pass.
5. **Opponent motion, when needed.** Extract the opponent from the plate and build a matching view-specific presentation before adding reactions or combat. Keep the current opponent pose static until this becomes the active milestone.
6. **Optional UI.** Add only HUD elements that improve the final view after both characters are accepted.

## Compatibility renderer decision

**Keep Compatibility for this milestone.** The project already selects `gl_compatibility` in `project.godot`. A local launch of Godot 4.7.2 on Apple M4 Pro completed successfully with `--rendering-method gl_compatibility`; the engine reported `OpenGL API 4.1 Metal ... Compatibility` and exited without a renderer error.

The actual fixed-camera composite was run and captured in Compatibility on this machine. It uses a canvas backdrop, a 3D floor mesh, ambient and directional lighting, and the existing player controller. The baked magic needs no renderer effect. Compatibility remains sufficient for this scope.

This validates startup and the current composite, not the final protagonist model or frame rate. A fixed plate also means there is no background parallax; the camera must remain fixed. If free camera rotation becomes a requirement, the plate would need to be replaced by 3D scenery or multiple layered views.

Godot references: [renderer features](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html), [environment and post-processing](https://docs.godotengine.org/en/4.7/tutorials/3d/environment_and_post_processing.html), [3D scene import](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html).

## Incremental visual record

Compare each object in the running game from the same camera view before moving to the next. The earlier [paving](docs/visual-progress/paving.png), [covered well](docs/visual-progress/well.png), and [composition](docs/visual-progress/composition.png) captures document the discarded full-3D approach. The [ring capture](docs/visual-progress/arena.png) records the earlier capsule view. The [model review](docs/visual-progress/protagonist-model.png) and [earlier playable capture](docs/visual-progress/protagonist-mvp.png) record the 3D prototype. The [illustrated candidate](docs/visual-progress/protagonist-illustrated-review.png) records the chosen direction. The [idle](docs/visual-progress/protagonist-motion-idle.png), [walking](docs/visual-progress/protagonist-motion-walk.png), and [four-direction motion](docs/visual-progress/protagonist-motion-review.mp4) captures document the protagonist pass. The [duel capture](docs/visual-progress/duel-scene-review.png) records the simplified cast and wider left staging area.

## Definition of done

- A 16:9 screenshot from the fixed camera matches the reference's composition, color, magic, and illustrated foreground protagonist while showing only the opponent as another character.
- The visible protagonist and floor load without errors in Compatibility.
- The illustrated movement pass receives player review before the walkable MVP is declared complete.
- Approved game-ready assets, comparison screenshots, and remaining visual gaps are recorded.

An exact pixel match from every camera angle is impossible with one still background, so this MVP intentionally fixes the camera and keeps the walkable area small.
