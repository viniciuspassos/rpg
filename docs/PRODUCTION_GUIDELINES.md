# Game production guidelines

This is the working pipeline for producing the playable village v0. `PLAN.md` defines the current milestone and acceptance criteria; `ARCHITECTURE.md` defines runtime boundaries. Use this guide when planning or executing an art, world, animation, or integration task. Do not expand the milestone without updating `PLAN.md` first.

## Production target

Produce one convincing Godot scene before producing a larger world. The current target is the bounded village duel in `game/visual_mvp.tscn`, viewed through its fixed camera. Only the illustrated protagonist and separately layered static opponent remain in this visual scene; the central floor remains 3D. Directional idle and walk poses are in review, as recorded in `PLAN.md`. The earlier playable episode in `game/main.tscn` remains a compatibility check, not the visual acceptance target.

On 2026-10-31 the user decided that this duel is a battle scene of the real game, not a mockup. Characters therefore move to stylized low-poly 3D with a shared rig and shared animations, generated with the local ComfyUI install and finished in Blender; Godot remains the engine. The illustrated sprites stay in the scene until a 3D protagonist passes the fixed-camera gate. Read [Character and model generation](#character-and-model-generation) before producing any character or model.

Judge the result in the running Godot scene, at the intended viewport size and from the player's view. A Blender still is useful for inspecting an asset, but it does not prove that the asset reads well in motion, matches the plate, or runs acceptably in Godot.

## Reference intake

1. Identify the exact output being made: one asset, one visual pass, or one playable scene. Write down the camera view, scale, intended use, and a small set of visible acceptance criteria.
2. Inspect the relevant reference frames and tutorial sections. Extract techniques, measurements, and material or lighting decisions that serve the current output. Record timestamps or frame identifiers. Do not claim to have watched or transcribed a video when only its description or selected frames were available.
3. Separate transferable technique from the example's content. A forest tutorial may teach terrain breakup, vegetation distribution, PBR materials, and atmospheric lighting; its forest, cars, camera shots, and render settings are not requirements for this village.
4. Check the repository's current assets and visual record before making replacements. The local concept image and `GAME_DIRECTION.md` may be ignored by Git; preserve them and do not force-add them.

## Asset intake and safety

- Prefer existing repository assets. For a new asset, record its source URL, author, license, permitted game use and redistribution, and any attribution requirement before adding it to the project. “Free to download” alone is insufficient. Respect the project's open-source and no-paid-service constraints.
- Inspect downloaded archives before extraction for executable files, scripts, plugins, and unexpected paths. Open third-party `.blend` files with auto-execution disabled and inspect embedded scripts, drivers, and linked libraries before enabling anything. Do not run unreviewed add-ons or code from an asset pack.
- Keep generation scripts, Blender working files, and temporary renders local under the ignored `source_assets/` directory; keep visual reference inputs under the ignored `concepts/` directory. Commit only approved game-ready assets under `game/art/`, engine files needed to load them, and selected in-game comparison captures that document an accepted visual state. Keep provenance and license information in the task record when using third-party content.
- Use Blender for shaping, materials, rigging, and export. Use Godot for the final lighting, collision, camera, movement, and performance decisions. Export through a format Godot imports reliably, normally glTF/GLB. The production method is not part of the game runtime and does not need to be versioned.

## Build and review loop

Work in the following order, only for stages relevant to the current milestone:

| Stage | Output | Gate before moving on |
| --- | --- | --- |
| Composition | Camera, playable bounds, rough masses | Spawn view matches the chosen reference composition; movement stays on screen. |
| Ground | Walkable paving and contact surface | No visible seam with the plate; collision and feet agree with the image. |
| Hero asset | Silhouette, scale, clothing colors, sword | Spawn capture reads as the intended protagonist from the fixed camera; other positions and walking are reviewed separately. |
| Motion | Idle, walk, grounding, attack only when in scope | No obvious sliding, clipping, detached equipment, or unreadable action. |
| World detail | Only essential props, vegetation, and material variation | Added detail improves depth and legibility without obscuring the hero or the route. |
| Light and atmosphere | Godot scene lighting and restrained effects | Visuals remain coherent with the plate across the playable area and run acceptably. |

For each stage:

1. Make the smallest change that can test the visual hypothesis. Choose whatever local generation method efficiently improves the asset; the quality of its code is not an acceptance criterion.
2. Produce a cheap preview first. Use low sample stills or a simple viewport capture before any expensive render. Estimate long render cost before starting it.
3. Capture the running game at a fixed spawn view and at relevant movement extremes. Place the result beside the reference at the same framing and size.
4. Name at most three observable gaps, ordered by visual impact. Correct those gaps before adding new detail. If a pass fails twice without a clear improvement, stop and revise the approach rather than adding complexity.
5. Keep working files locally, save the approved export and in-game capture, and record the visual decision. Advance only when the stage gate is met or the remaining gap is explicitly accepted in `PLAN.md`.

Do not assume that more polygons, dense scatter, high sample counts, or photorealistic Cycles renders improve a real-time scene. Measure the imported scene and use the least detail that holds up from the game camera. Keep collisions, walkable space, and protagonist visibility ahead of decoration.

## Character and model generation

These rules come from the protagonist work of 2026-10-24 to 2026-11-04. It went through several approaches and many sessions before one passed. The method that passed is in [Step-by-step character method](#step-by-step-character-method). Apply these rules and that method to the opponent, future characters, and any other generated model.

### What went wrong with the protagonist

| Attempt | What happened | Lesson |
| --- | --- | --- |
| Blender model built by script from primitives (Codex, Oct 25) | It came out as a blocky "box doll" with block boots, a rigid cape, and an unreadable face ([capture](visual-progress/protagonist-model.png)). Several revision passes still looked "very different" from the reference. The user had to say that the target is cartoon-like, not realistic. One render also put the cape and sword on the wrong side. | Do not model organic characters from scripted primitives; the approach does not converge. Check left/right handedness against the reference in every view. |
| AI-illustrated pose per direction (`game/art/protagonist_motion.png`) | Every pose was a separate generation, so hair (bun or loose), face, and proportions drift between directions. The rear idle has the orange magic glow baked in, and the cutouts have a red fringe. Each direction has only two strides. The approach cannot scale to attacks, hits, an animated opponent, or a moving camera. | Pose images generated one by one are not one character. Derive every pose of a character from one model and one rig. Never bake effects, lighting, or background into a character texture. |
| Integration in the fixed scene | A larger model let her walk onto the painted stairs. The figure looked pasted on, with lighting and style that did not match the plate. | After any scale change, recheck the walk bounds and the plate contact. Judge the character only in the running scene. |
| Local ComfyUI image to 3D (Claude Code, Pixal3D multi-view, Oct 31) | The install was pinned to tag v0.41.3, so `comfy update` did nothing. The template needed `RemeshMesh` from v0.43.x. The turnaround sheet put painted beige panels on a black canvas. In both runs the template's saved view previews (`output/front_view_*.png`, `left_`, `back_`, `right_`) were the same flat beige rectangle, with no character in any view. The probable cause is that the background removal (BiRefNet) selected the panel. The first run still went on for over an hour (63 minutes in the texture stage at 1536) before anyone looked. The MCP wait went silent and aborted after 1800 s. A log monitor fired falsely on an older "Error" line. The Mac hibernated on battery mid-run, and ComfyUI hung after waking. | Inspect the first intermediate output before letting a long job continue. Match the template's example input exactly. Keep the machine awake and watch only new log lines. |
| Mixamo auto-rig of the assembled Body (Claude Code, Oct 31 to Nov 1) | The upload worked, but three times the rig ran for about 25 s and silently returned to the marker screen. The cause appeared only in the JSON of `/characters/<id>/monitor`: `ERROR occured on rig: Unknown error while generating motion`. The Body had six loose islands and open hems. | The auto-rigger needs one connected, closed shell. Rig a closed proxy once and reuse that skeleton for later characters (see [Rig and animation pipeline](#rig-and-animation-pipeline)). |
| Separately generated T-pose arm and smeared torso input (rig v2, Nov 1) | To get a T-pose, the hanging arms were cut off. One arm was then generated alone from a hanging-arm crop rotated to horizontal and mirrored, and it came out as a cone sleeve, a twig forearm, and a claw hand. The torso input had the cape erased by smearing pixels; image-to-3D turned the smear into a mantle over the shoulders, which was later hidden under a scripted navy dome. The user found the rigged model badly deformed. | Generate the arms attached to the torso, hanging in their natural pose, and convert them to a T-pose in 3D with the skeleton. To remove something covering a part in an input image, mirror the clean half and repaint flat facets. Never smear: the generator turns a smear into geometry. |
| Process | The user repeatedly had to ask for a list before generation, and for assets only, without gameplay, code, or tests. | Present the plan first when asked, and stay inside the asset scope. |

### Rules for every new character or model

1. **Plan before generating.** List the outputs, file locations, tool, and estimated cost (download size, run time) before producing media. When the user asks for a plan or says not to generate yet, stop after the list. Asset tasks do not include gameplay code, tests, or Godot wiring unless the user asks.
2. **One reference set per character.** Keep a turnaround of front, back, left, right, three-quarter, and an equipment detail under `source_assets/<character>/concepts/` (ignored by Git). Before generating, confirm that every view shows the same costume, hair, handedness, and proportions. Fix the reference set first if they disagree.
3. **Characters are 3D models generated in parts, on a shared skeleton.** Split the reference into parts: head and hair, torso with both arms attached, legs and boots, cape, sword, and pouch. Generate each part with a free local ComfyUI image-to-3D template. A whole body generated from one image or sheet comes out as one fused mesh that rigs poorly. In Blender, assemble the parts and smooth the joins with proportional editing. Then reduce polygons, use flat shading, clean the materials, and set the origin at the feet. Keep the sword and other props as separate objects parented to a hand or spine bone, so equipment side is an explicit choice. Rig and animate as described in [Rig and animation pipeline](#rig-and-animation-pipeline). The opponent and later characters reuse the protagonist's skeleton, scale, forward axis, and export settings. Do not generate new 2D pose images for a character, and do not script organic characters from primitives. Primitive blockouts are acceptable only for props and layout.
4. **Match the established canon.** Compare silhouette, palette, hair, equipment side, and scale with the canon below and the reference, from front, three-quarter, back, and the game camera. Mirrored equipment is a defect.
5. **Fail fast.** Run the cheapest version first and inspect every intermediate output that a pipeline saves. If two attempts fail without a clear improvement, stop and report what failed instead of adding detail.
6. **Keep characters clean.** Character textures contain no magic, glow, cast shadows, or background. Effects stay in their own layer or particles; scene lighting comes from Godot.
7. **Use only free, local tools.** Use free local ComfyUI templates with weights licensed for game use (record the license), plus Blender and Godot. Never use partner or API nodes such as Tripo, and never approve a credit spend. A validated workflow must report `spends_credits: false`.

### Step-by-step character method

This method produced the protagonist's rig v3 on 2026-11-04 (hand-off in `PLAN.md`). Use it for the opponent and every later humanoid.

- **Starting points.** The protagonist's working scripts are local, unversioned starting points under the ignored `source_assets/protagonist/`. Copy and adapt them; do not version them.
- **Gates.** Every step ends with a gate: open the saved images and compare them with the reference before going on. Stop after two failed attempts at the same step.
- **Running Blender.** Run Blender headless (`/Applications/Blender.app/Contents/MacOS/Blender -b ... -P script.py`) with one script per stage, and render after each stage.

1. **Reference set.** Collect the turnaround and the game reference as in rule 2. Resolve contradictions before generating; the protagonist's cape side is an example. When the user leaves a style choice open, pick the option that reuses existing work.
2. **One clean input image per part.** Make one front image per part on a uniform light background. The protagonist used RGB 232, 230, 228.
   - **Parts:** head and hair; torso with both arms; legs and boots; sword; any other prop.
   - **Remove what covers the part,** such as a cape, sword or pouch. Mirror the clean half across the body axis, then repaint the hidden areas, such as shoulder tops, as flat low-poly facets sampled from nearby colours.
   - **Arms:** keep them attached and hanging naturally, with complete open hands.
   - **Gate:** no pixels of the removed items, panels and equipment on the correct side, and no visible mirror seam.
   - **Scripts:** `rig/v3/input/scripts/`. `stage0_masks.py` fits the background and masks the scarf, `repaint_left.py` repaints the facets, and `build_v4.py` mirrors, restores panels, and crops.
3. **Image to 3D, shape only.** Run the free local TRELLIS.2 image-to-3D graph on each input, following the [ComfyUI checklist](#local-comfyui-image-to-3d-checklist).
   - **Variants:** for the hardest part, generate two input variants and keep the cleaner mesh.
   - **Graph:** `rig/v3/torso/wf_torso_arms_v4.json`, adapted by `rig/v3/torso/scripts/make_wf.py`. The input image is node 122; the output prefixes are nodes 302, 322 and 325.
   - **Cost:** 12 to 18 minutes per part on this M4 Pro.
   - **Gate:** first the saved input crop, then clay renders from front, three-quarter, back and side next to the reference.
4. **Assemble in Blender, keeping the natural pose.** Import the parts on one frame: final height, feet at z = 0, front = -Y (glTF +Z). Fit each part's scale and offset to the reference proportions and to its neighbouring parts, then decimate. The protagonist's v3 torso was fitted to the existing head and legs at scale 0.924. Then clean in separate stages, rendering after each:
   - trim ragged hem rims with planes and cap them;
   - taper and weld the joins, at the waist into the trousers and at the neck stub into the head;
   - paint flat matte materials by region, splitting borders with planes so they stay straight;
   - dissolve nearly coplanar faces until the body fits its budget (the protagonist: under 20,000 triangles).

   Then run an independent critic and fix only its top findings. For the protagonist these were panels flaring in profile, curled fingers, and patches on the crown and neck. Bake no light, shadow or glow.
   - **Scripts:** `rig/v3/assembly/scripts/` (`prep_torso.py`, then `w3b_stage2_panels.py` to `w3b_stage5_final.py`, then `w3c_stage*.py`).
   - **Gate:** concept | previous | new sheets in five views.
5. **Rig on the shared skeleton, with no new Mixamo upload.**
   - **Fit the joints.** Start from the protagonist's 33-bone `mixamorig:` armature (`rig/v3/final/protagonist_rigged_tpose_v3.blend`). Move only the joint positions onto the new mesh. The neck base goes at the collar and the head joint at the jaw line, so the neck can bend; then place shoulders, elbows, wrists, hips, knees and ankles. Keep every bone direction and roll, so Mixamo clips still apply, and log every move.
   - **Weight and bake.** Copy the armature with the arm chains rotated onto the hanging arms, weight the body in that pose, and bake it to the T-pose rest. Linear blend skinning (LBS), which Godot also uses, lifted the shoulder caps less than dual quaternions.
   - **Keep the neck blend in the neck.** Limit it by height so it cannot leak into the chest or belly.
   - **Scripts:** `rig/v3/final/scripts/`. Run `stage1_fit.py`, then `run_pipeline.py` (weights, LBS bake, bind; it uses `rig_lib.py` and `weights_v3.py`), then `stage4_bind.py` for the deliverables.
6. **Check and review.**
   - **Integrity:** run `check_rig.py` against the protagonist rig. Expect 33 bones with the same names and parents, no unweighted vertex, at most four influences, weights summing to 1, no wrong-side weight, a rest deviation under 0.1 mm, and no actions.
   - **Renders:** use `render_review.py`'s fixed views (front, three-quarter, back, side, game camera), at rest, posed, stress, head up and head down. Make sheets against the reference and the previous version.
   - **Critic:** finish with an independent critic.
   - **Acceptance view:** the running game becomes the acceptance view after the Godot import.

**Known limits** (protagonist v3):
- A two-bone skin cannot keep a hanging skirt intact in a deep squat; add two or three skirt bones.
- The fingers carry no weight, so the hands are rigid mittens.
- A sword grip has to be posed or modelled into the hand.

### Protagonist canon

The canon comes from the turnaround in `source_assets/protagonist/concepts/` and the local reference `concepts/v0-awakening-graybox.png`. Check these files when in doubt.

- Style: faceted low-poly, cartoon proportions, warm painterly light. Not realistic.
- Hair: brown, tied in a low bun at the back.
- Clothing: cream short sleeves, dark navy tunic with a tan front panel, brown belt with a pouch on her left hip, brown trousers, and tall brown boots with folded cuffs.
- Sword: a straight blade held low in her left hand. In the rear game view the sword is on the image's left; her right hand is free to cast the Power.
- Cape: none in this version. On 2026-11-04 the user removed the cape from the protagonist. The concept views and the game reference still show a red scarf-cape: ignore it when comparing, and exclude it from any image-to-3D input. If a cape returns later, its tail hangs on her right side, as the user chose on 2026-11-01 (matching `02-back.png` and the game reference; `01-front.png` and `05-front-three-quarter.png` show it on her left).

### Local ComfyUI image-to-3D checklist

The install is at `~/ComfyUI-Installs/comfyui/ComfyUI` (M4 Pro, 24 GB, MPS). Large outputs and models stay outside the repository.

1. **Version.** Run `git -C ~/ComfyUI-Installs/comfyui/ComfyUI describe --tags` and compare it with the version the template needs. A checkout pinned to a tag ignores `comfy update`, so switch versions explicitly. Switching reinstalls Python dependencies and needs the user's approval.
2. **Validate before running.** Clear the template's local check and run `validate_workflow`. Download only missing models from official sources such as Comfy-Org on Hugging Face, after checking their size and license.
3. **Input sheet.** Download the template's own example input and match its canvas size and view order. For Pixal3D multi-view, the canvas is 6336×2688 with front, left, back, and right, at the crop windows of nodes 338/341/342/345. Put the character on one uniform light background, with no panel borders and no black canvas. Keep the same scale and ground line in all views.
4. **First gate, within minutes.** The template saves the four cropped views to `output/` before generating the mesh. Open them at once. Each must show the whole character, and the four must differ. If any is blank, cropped, or identical to another, cancel the job and fix the input instead of waiting for the mesh.
5. **Cost.** At a 1536 upsample, the texture stage alone took 63 minutes. Use 1024 or lower for exploration and raise it only for an approved shape.
6. **Long runs.** Keep the Mac on AC power and run `caffeinate -i -w <ComfyUI pid>`. Do not rely on one long MCP wait. Poll the job status, or follow only new log lines (`tail -n0 -F user/comfyui_8188.log`) for `Prompt executed` or `Traceback`. After sleep or a crash, check that the server responds, restart it if it hangs, and resubmit.
7. **Review the mesh.** Copy the GLB from `output/3d/` to `source_assets/<character>/`. Render front, three-quarter, back, and game-camera views in Blender next to the reference before any cleanup, rig, or Godot import.

### Rig and animation pipeline

Approach approved by the user on 2026-10-31. It follows the workflows shown by the Manual de Criação and Stefan 3D AI channels, adapted to free, local tools and Godot.

1. **Skeleton.** Use the Mixamo humanoid skeleton for every humanoid, through Mixamo's auto-rigger or AccuRig (free, automatic). Its smaller bone set makes both automatic and agent-made animation easier.
   - **Where it came from.** The protagonist's skeleton came from one Mixamo auto-rig of a closed proxy (`source_assets/protagonist/rig/mixamo_download_proxy_v1/`). Mixamo accepts only one connected, closed shell. Otherwise it fails with `Unknown error while generating motion`, which only the `/monitor` response shows.
   - **Later characters.** They reuse that skeleton by fitting its joints to their mesh, as in step 5 of the [Step-by-step character method](#step-by-step-character-method), with no new upload.
   - **Extra bones.** The cape gets two or three extra bones on the spine, and a long skirt needs two or three of its own.
   - **Check the weights** at the shoulders, hips, and knees before animating.
2. **Library animations first.** Take idle, walk, run, sword attack, hit, and death from Mixamo or ActionForge, and keep the downloaded clips local under `source_assets/<character>/animations/`. Expect to edit most of them; they are a starting point, not final motion.
3. **Game-specific motion with an agent in Blender.** For motions no library covers, such as channelling the Power with a raised hand, let Codex or Claude Code adjust or create clips through the Blender MCP. Review each clip, give feedback with screenshots, and iterate. Two rounds per clip is normal.
4. **Video reference when needed.** When an agent's keyframes look stiff, record the motion yourself or generate a short reference video. Convert it to a Mixamo-skeleton clip with Motion2MixamoRig, which runs locally, then clean it up in Blender.
5. **Godot.** Export the GLB with the skeleton and clips. Map the bones with Godot's humanoid `BoneMap` / `SkeletonProfileHumanoid` so clips can be shared between characters. Drive the clips with an `AnimationTree`. Keep a small animation test scene that previews every clip of every character, and review motion there before the arena.
6. **Licenses.** Mixamo needs a free Adobe account and AccuRig a free Reallusion account. Record in the task the terms of each tool and of any downloaded clip, including Motion2MixamoRig and ActionForge, before versioning an exported asset.

### Blender MCP

Both agents control Blender through the official Blender Lab MCP server. In Blender 5.2, its `mcp` extension listens on `localhost:9876`. The server binary is `~/Library/Application Support/blender-mcp/venv/bin/blender-mcp`. It is registered as `blender` in Codex (`~/.codex/config.toml`) and in Claude Code (user scope, `claude mcp get blender`). Blender must be open with the extension enabled before an agent uses the tools. A new agent session is needed to pick up the tools after registration.

## Scene continuity

- Before starting, read the status in `PLAN.md`, the open issues under #20, and the newest accepted captures in `docs/visual-progress/`. That accepted state is the baseline; do not regress it.
- Change only the target. When replacing a character, keep the camera, plate, arena floor, walk bounds, magic layer, and the other combatant unchanged. Prove it with same-run before/after captures of the untouched elements.
- New combatants match the protagonist's scale, ground contact, lighting response, and palette, and keep their reference screen positions. Keep exactly two combatants and no villagers.
- Replace an approach only after the new one passes the same fixed-camera gate. Until then, the scene keeps the last accepted asset.
- Record decisions, superseded approaches, and remaining gaps in `PLAN.md` or the relevant issue, not only in an agent's private memory. Claude Code and Codex both work on this project and read `AGENTS.md` and this guide, but not each other's memory.
- End each session with a hand-off in `PLAN.md` or an issue comment. Name the files touched, the attempt and its result, the next step, and any local job still running with how to check it.

## Working with Codex and Claude Code

Give each task a narrow brief: **target file or scene, reference, one intended change, constraints, and acceptance evidence**. Ask for a comparison capture and a short account of what changed. Prefer a targeted follow-up over replaying the entire design history. Reuse existing code and assets; do not generate a whole world from a broad prompt.

Both agents follow `AGENTS.md` and this guide; neither one sees the other's private memory or session history. Agent-specific pitfalls seen so far:

- **Codex:** Blender 5.2 can fail to initialize Metal inside the sandbox and exit before opening the file. Rerun Blender with escalated permissions instead of debugging the model.
- **Claude Code:** a comfy-mcp `job` wait aborts after 1800 s without progress. Use a background monitor on new log lines for long runs. The worktree guard refuses git commands wrapped in `rtk`; inside an isolated worktree, run plain `git`.

Either agent may use local scripts, ComfyUI, or Blender tools to generate assets. Review any external script or add-on before execution. Keep generation code unversioned and spend review time on the resulting asset. Use subagents only for independent, clearly owned work when they reduce total effort; concurrent writers must use separate worktrees. The Claude artifact's named Sonnet handoff is not part of this workflow.

For gameplay behavior changes, follow repository test-driven practice. For asset generation, validate the visible output through paired reference and in-game captures and refine it until it matches the acceptance criteria. Do not add TDD or code tests for the generation method. Run relevant Godot checks only when engine integration or gameplay behavior changes. Report what was observed, what remains visibly different, and whether performance or integration changed. Avoid claiming a visual pass from a headless test alone.

## Completion record

A production task is complete when its acceptance view passes, the approved asset loads in Godot, relevant integration checks pass if needed, third-party provenance is recorded, and remaining visual gaps are written down. Update `PLAN.md` only to reflect a verified state or an explicit change of scope.

## Reference basis

- [Claude and Blender environment workflow](https://www.youtube.com/watch?v=Udahf4a0UwQ&t=156s): tutorial-led planning, staged construction, preview and comparison loops.
- [Claude Blender Workflow artifact](https://claude.ai/artifact/JQBq3LhmBGQNJsxnihm88A): source of the original cinematic workflow, adapted here for Codex and a playable Godot scene.
- [Hyper-Realistic Forest Blender tutorial](https://www.youtube.com/watch?v=OCg2_6XpITg): technique reference for terrain, vegetation, materials, lighting, and atmosphere. Its third-party asset links and paid add-ons require separate suitability and license review.
