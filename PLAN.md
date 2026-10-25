# 3D village MVP: one walkable visual scene

## Goal and reference

Build one tightly bounded walkable ring in Godot 4.7.2. The current reference is the local, intentionally untracked `concepts/v0-awakening-graybox.png`, annotated with the playable region. The fixed camera should resemble that frame. Only the protagonist and central paving need 3D geometry; the well, buildings, figures, magic, and distant paving can stay in a static background plate. This milestone requires movement only.

The current `v0-keyboard-three-minute` branch already has a player controller and earlier gameplay code. The visual MVP runs from `game/visual_mvp.tscn`; the earlier quest scene stays in `game/main.tscn` for reference. Reuse the player movement, with an opt-in elliptical boundary and fixed camera for this scene.

## Effort-saving art direction

- Restrict movement to the annotated central floor. No route to the well, stairs, buildings, or surrounding figures is required.
- Use a fixed camera so the static plate and 3D floor remain aligned. The player can move inside the ring but cannot rotate the view.
- Use the cleaned reference-derived plate for every noninteractive object. The 3D floor samples that plate from the fixed view, hiding the seam between the walkable floor and background paving.
- Spend modeling time on one protagonist mesh, clothing, sword, and idle/walk motion. Keep other figures and the awakening baked into the plate.
- Keep UI out of the comparison frame until the protagonist and walking space match the reference.

## Asset inventory

| Priority | Deliverable | Minimum production approach |
| --- | --- | --- |
| Done | Cleaned background plate | Image edit of the annotated reference; removes the drawn oval, red note, HUD, and foreground protagonist. Saved as `game/art/village_backdrop.png`. |
| Done | Central floor and boundary | Elliptical 3D mesh and ground collision in `game/visual_mvp.gd`; screen-projected plate color gives a continuous paving image. Player movement is clamped inside the ellipse. |
| Next | Protagonist | One faceted human mesh with clothing, hair, and sword matching the foreground silhouette; idle and walk animation. |
| Later, only if needed | Foot contact and UI | Improve the grounding shadow and add a small objective/health overlay after the protagonist comparison passes. |

The plate was produced with the built-in image generation edit tool from the user's local annotated reference. Its prompt was: preserve the exact village composition, architecture, people, magic, light and paving; remove the black oval, red note, foreground protagonist and HUD; reconstruct exposed paving; add no text or new objects. The original reference is local and ignored by Git, while the cleaned plate is saved in the project for version control. Godot alone is enough for the present scene. Blender becomes useful when shaping and animating the protagonist; keep editable source and export `.glb` if used.

## Production sequence and review gates

1. **Background and ring.** Use the cleaned plate, fixed camera, a small textured 3D floor, and bounded movement. Gate: the spawn image reproduces the reference scenery without a visible floor seam, and walking to every boundary keeps the player on screen. Current [ring capture](docs/visual-progress/arena.png) records this pass.
2. **Protagonist.** Replace the capsule with one faceted model. Match the reference silhouette, scale, clothing colors, hair, and sword from the fixed view before proceeding. Gate: compare spawn and walking screenshots side by side; no capsule or box anatomy remains.
3. **Movement presentation.** Add idle/walk motion and refine grounding if needed. Gate: feet stay visually planted across the whole ring and the plate/3D composite does not show obvious sliding or clipping.
4. **Optional UI.** Add only the reference HUD elements that improve the final view. Gate: no gameplay systems are required beyond movement.

## Compatibility renderer decision

**Keep Compatibility for this milestone.** The project already selects `gl_compatibility` in `project.godot`. A local launch of Godot 4.7.2 on Apple M4 Pro completed successfully with `--rendering-method gl_compatibility`; the engine reported `OpenGL API 4.1 Metal ... Compatibility` and exited without a renderer error.

The actual fixed-camera composite was run and captured in Compatibility on this machine. It uses a canvas backdrop, a 3D floor mesh, ambient and directional lighting, and the existing player controller. The baked magic needs no renderer effect. Compatibility remains sufficient for this scope.

This validates startup and the current composite, not the final protagonist model or frame rate. A fixed plate also means there is no background parallax; the camera must remain fixed. If free camera rotation becomes a requirement, the plate would need to be replaced by 3D scenery or multiple layered views.

Godot references: [renderer features](https://docs.godotengine.org/en/4.7/tutorials/rendering/renderers.html), [environment and post-processing](https://docs.godotengine.org/en/4.7/tutorials/3d/environment_and_post_processing.html), [3D scene import](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/importing_3d_scenes/available_formats.html).

## Incremental visual record

Compare each object in the running game from the same camera view before moving to the next. The earlier [paving](docs/visual-progress/paving.png), [covered well](docs/visual-progress/well.png), and [composition](docs/visual-progress/composition.png) captures document the discarded full-3D approach. The [ring capture](docs/visual-progress/arena.png) is the current spawn view. Movement was visually checked at the left, right, front, and back limits. The next object is the protagonist; its current capsule is intentionally still a placeholder.

## Definition of done

- A player can walk around the bounded ring without leaving the frame or entering the static background.
- A 16:9 screenshot from the fixed camera matches the reference's composition, color, figures, and magic, with a finished 3D protagonist in the foreground.
- The visible player and floor load without errors in Compatibility and remain coherent during movement.
- Source assets, comparison screenshots, and remaining visual gaps are recorded.

An exact pixel match from every camera angle is impossible with one still background, so this MVP intentionally fixes the camera and keeps the walkable area small.
