# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

"Downhill": a downhill longboarding game prototype. The **entire game is `index.html`**: HTML/CSS, then a single `<script type="module">`. It uses Three.js r160 from unpkg via an import map. There's no build step, no package.json, no tests, and no linter. It deploys as a static site (GitHub: `JacobDChamberlain/DownhillLongboardDomination`).

The prototype exists for **fast gameplay iteration**. Mechanics are meant to transfer 1:1 to Unity/Unreal later, so graphics, character animation and multiplayer are deliberately kept "good enough". `ROADMAP.md` (build order and triage) and `FULL_PASS.md` (visual-pass log and tunables) are the living plan. Update them when finishing roadmap items.

## Running and checking

```sh
python3 -m http.server 8000     # then open http://localhost:8000
```

- **Progressive enhancement is intentional.** Opening `index.html` directly (file://) still works: the HDRI, textures and GLB models can't be fetched there, so the game keeps its procedural fallbacks (shader sky dome, flat colors, box rider, cone trees). Every asset loader `.catch`es and logs `[assets] … unavailable`. Keep that pattern for new assets.
- **Syntax check** (the only automated check), after extracting the module script:
  ```sh
  sed -n '/<script type="module">/,/<\/script>/p' index.html | sed '1d;$d' > /tmp/m.mjs && node --check /tmp/m.mjs
  ```
- **Visual changes need an in-browser look.** Check the console for errors and hold ~60fps. Adaptive resolution hides frame drops by lowering the canvas size, so read `canvas.width` along with the fps.

## Architecture (index.html, top to bottom)

**The track is a parameter `u ∈ [0,1]`.** `buildRoadPoints()` gives a CatmullRom spline, sampled into `frames[0..SAMPLES]` of `{p, tan, side, up}`. The frames are *banked*: `side`/`up` are rolled into curves. `frameAt(u)` interpolates between them. Everything that sits on the course uses these frames:
- road, grass and guardrail strips, dashes, posts, trees
- ramps, gaps and items (`RAMPS`, `GAPS`, `ITEMS`, placed by `u`)
- the rider (`state.u` + `state.lateral` + `state.height`)

Anything new placed along the course should use frames too.

**Frame loop** (`frame()` at the bottom):
- While `gameState === 'PLAYING'`, it runs `update(dt)` (physics and gameplay, returning `info`), then `place(info)` (positions the skater, runs the camera modes and poses the rider), then `drawHud(info)`.
- It then renders through the post-processing `composer`. The Cinematic FX setting off means a plain `renderer.render`.
- `gameState` is a small state machine: PLAYING | PAUSED | SETTINGS | TITLE | ENTRY | RESULTS.
- Reaching `u ≥ 0.999` calls `finishRun()`, which leads to initials entry and the localStorage leaderboard (`downhill.scores`).

**Skater hierarchy:** `skater` (world position/heading) > `trickPivot` (air spins) > `lean` (carve roll). Rider-pose math works in **lean space**: +Z = down the road, +Y = up, and the rider faces −X (sideways, regular stance).

**Rider** (`buildRig`/`poseRider`):
- The Quaternius GLB is posed *procedurally* every frame: bones are reset to rest, then world-space helpers (`rotateWorld`, `turnWorld`, `aimWorld`, two-bone `ik2`) plant the feet, crouch, bend and twist the spine, and set the head and arms. There are no animation clips.
- Quirks:
  - GLTFLoader strips `.` from node names (`UpperArm.L` becomes `UpperArmL`).
  - The feet are separate bones parented to the armature root, not to the shins.
  - Skinned bounding boxes need `updateMatrixWorld(true)` before measuring.

**Rendering pipeline:**
- `RenderPass` → half-res `UnrealBloomPass` → `speedPass` (radial speed blur and chromatic aberration aimed at the travel direction; disabled when idle) → `finishPass`.
- `finishPass` does ACES tone mapping and sRGB itself through `#include <tonemapping_fragment>`, then applies grade, vignette, grain and letterbox. There's intentionally **no OutputPass**.
- MSAA is only enabled at pixel ratio below 2; it cost ~35fps on the half-float target.
- `adaptRes()` steps the pixel ratio through `RES_STEPS` to hold the frame rate.

**Terrain:** everything is generated from `frames[]`. The road runs on a ridge: the grass shoulders are two strips per side (never one sheet under the road, which pokes through where the banking twists), and rock cliff walls hang off each grass edge down to `CLIFF_FLOOR`. `BRIDGE` (a `u` range, tested with `onBridge(u)`) removes grass and cliffs, adds gorge walls, deck girder and piers, and physics clamps the rider inside the rails there. Water fills the valley at `LAKE_Y`. The huge surfaces (cliff chunks, lake) set a high `renderOrder` so near geometry draws first and the depth test skips hidden pixels.

**Chaos mode (`X`):**
- `setChaosMode()` saves the world lighting (fog, sun, hemisphere light, environment, far-scenery haze) on the way in and restores it on OFF. New per-mode changes must go through that save/restore.
- The music analyser taps the radio's `<audio>` through Web Audio, and only over http(s). On file:// that routing would silently mute cross-origin media, so a synthetic 120bpm beat stands in.

**Lighting/sky:**
- The HDRI is rotated at load (`aimHdri`) so its sun sits on `SUN_AZIMUTH`. The shadow light uses the same bearing at `SUN_LIGHT_ELEV`.
- Fog and far-scenery colors (`hazeMats`) are re-derived from the HDRI's away-from-sun horizon once it loads.
- The camera far plane (14000) must clear the ridgeline rings and valley disk, or they clip into a flat band at the horizon.

**Cameras (`C`):**
- chase, drone and trackside modes.
- Chase and drone smooth their *offset from the rider*, not world position. Lerping world position makes them trail far behind at speed.
- Trackside re-picks its spot when the rider passes it, or when a raycast against `groundMeshes` shows terrain blocking the view.

**Conventions:**
- Tunables are `SCREAMING_CASE` consts at the top of their section, with a comment on what they do (e.g. `CARVE_SCRUB`, `BLOOM_STRENGTH`, `TREE_CHANCE`, `STANCE`).
- Section banners are `// ----` comment blocks.

## Assets

- `assets/` holds CC0 assets only (Poly Haven HDRI and textures; Quaternius and other models via Poly Pizza). Record each new asset in `assets/CREDITS.md`.
- Keep downloads small: 1k textures, the 2k HDRI, and merged/deduped GLBs. The pines were combined with `@gltf-transform/cli` `merge` → `dedup` → `resize`.
- The radio `playlist` in the "Radio" section plays in array order starting at index 0. Tracks are `audio/*.mp3`.
