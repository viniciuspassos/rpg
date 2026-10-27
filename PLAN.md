# Village MVP: one fixed-camera visual scene

## Goal and reference

Build one tightly bounded village composition in Godot 4.7.2. The current reference is the local, intentionally untracked `concepts/v0-awakening-graybox.png`, annotated with the playable region. The fixed camera should resemble that frame. The central paving remains 3D; the foreground protagonist uses a view-specific illustrated sprite so her pose, proportions, and lighting match the background plate. Movement presentation is deferred while the visual identity is reviewed.

The project already has a player controller and earlier gameplay code. The visual MVP runs from `game/visual_mvp.tscn`; the earlier quest scene stays in `game/main.tscn` for reference. The visual scene reuses the controller and fixed camera, while movement presentation remains outside this visual pass.

## Effort-saving art direction

- Restrict movement to the annotated central floor. No route to the well, stairs, buildings, or surrounding figures is required.
- Use a fixed camera so the static plate and 3D floor remain aligned. The player can move inside the ring but cannot rotate the view.
- Use the cleaned reference-derived plate for every noninteractive object. The 3D floor samples that plate from the fixed view, hiding the seam between the walkable floor and background paving.
- Use a transparent illustrated protagonist for the fixed camera. Keep the experimental 3D model in the earlier playable scene until a matching animated asset is produced.
- Keep UI out of the comparison frame until the protagonist and walking space match the reference.

## Asset inventory

| Priority | Deliverable | Minimum production approach |
| --- | --- | --- |
| Done | Cleaned background plate | Image edit of the annotated reference; removes the drawn oval, red note, HUD, and foreground protagonist. Saved as `game/art/village_backdrop.png`. |
| Done | Central floor and boundary | Elliptical 3D mesh and ground collision in `game/visual_mvp.gd`; screen-projected plate color gives a continuous paving image. Player movement is clamped inside the ellipse. |
| In review | Protagonist | A transparent illustrated sprite derived from the local concept is placed in the fixed-camera scene. Its pose and rendering are much closer to the plate in the [spawn capture](docs/visual-progress/protagonist-illustrated-review.png). The earlier 3D model remains in the playable prototype. |
| In progress | Foot contact | The visual scene has a broader contact shadow; animation and foot placement during walking remain deferred. |
| Later, only if needed | UI | Add a small objective/health overlay after the protagonist comparison passes. |

The plate was produced with the built-in image generation edit tool from the user's local annotated reference. Its prompt was: preserve the exact village composition, architecture, people, magic, light and paving; remove the black oval, red note, foreground protagonist and HUD; reconstruct exposed paving; add no text or new objects. The illustrated protagonist was generated from the same local reference as a transparent foreground cutout, preserving her rear view, costume, sword, reaching hand, and sunset lighting while removing the oval, HUD, magic, and other figures. The original reference is local and ignored by Git; the selected game-ready images are versioned under `game/art/`. Experimental Blender files remain local and unversioned.

## Production sequence and review gates

1. **Background and ring.** Use the cleaned plate, fixed camera, a small textured 3D floor, and bounded movement. Gate: the spawn image reproduces the reference scenery without a visible floor seam. The [ring capture](docs/visual-progress/arena.png) records this pass; character framing during movement belongs to the later movement pass.
2. **Protagonist.** Match the reference silhouette, scale, clothing colors, hair, sword, and reaching pose from the fixed view. Gate: compare the running scene at spawn with the reference. The illustrated candidate passes the local spawn comparison and awaits review. A second arena position can crop the sprite, which remains part of the movement presentation pass.
3. **Movement presentation.** Produce a matching animated 3D character or an appropriate view-specific animation pass before treating movement visuals as complete. Gate: feet stay visually planted across the ring with no obvious sliding or clipping. This stage is deferred.
4. **Optional UI.** Add only the reference HUD elements that improve the final view. Gate: no gameplay systems are required beyond movement.

## Compatibility renderer decision

**Keep Compatibility for this milestone.** The project already selects `gl_compatibility` in `project.godot`. A local launch of Godot 4.7.2 on Apple M4 Pro completed successfully with `--rendering-method gl_compatibility`; the engine reported `OpenGL API 4.1 Metal ... Compatibility` and exited without a renderer error.

The actual fixed-camera composite was run and captured in Compatibility on this machine. It uses a canvas backdrop, a 3D floor mesh, ambient and directional lighting, and the existing player controller. The baked magic needs no renderer effect. Compatibility remains sufficient for this scope.

This validates startup and the current composite, not the final protagonist model or frame rate. A fixed plate also means there is no background parallax; the camera must remain fixed. If free camera rotation becomes a requirement, the plate would need to be replaced by 3D scenery or multiple layered views.

Godot references: [renderer features](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html), [environment and post-processing](https://docs.godotengine.org/en/4.7/tutorials/3d/environment_and_post_processing.html), [3D scene import](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html).

## Incremental visual record

Compare each object in the running game from the same camera view before moving to the next. The earlier [paving](docs/visual-progress/paving.png), [covered well](docs/visual-progress/well.png), and [composition](docs/visual-progress/composition.png) captures document the discarded full-3D approach. The [ring capture](docs/visual-progress/arena.png) records the earlier capsule view. The [model review](docs/visual-progress/protagonist-model.png) and [earlier playable capture](docs/visual-progress/protagonist-mvp.png) record the 3D prototype. The [illustrated candidate](docs/visual-progress/protagonist-illustrated-review.png) records the current fixed-camera composition. Movement visuals need a separate pass before acceptance.

## Definition of done

- A 16:9 screenshot from the fixed camera matches the reference's composition, color, figures, magic, and illustrated foreground protagonist.
- The visible protagonist and floor load without errors in Compatibility.
- Movement visuals receive a separate acceptance pass before the walkable MVP is declared complete.
- Approved game-ready assets, comparison screenshots, and remaining visual gaps are recorded.

An exact pixel match from every camera angle is impossible with one still background, so this MVP intentionally fixes the camera and keeps the walkable area small.
