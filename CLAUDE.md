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

**Riders / character select:** `RIDERS` is the roster. `setRider(i)` rebuilds the rig from a clone of a cached GLB (`loadRider`), or drops back to the box rider for THE OG (`file: null`). All rigged riders are Quaternius characters sharing one rig (`CharacterArmature`, same bone names + clips), so `poseRider` and the pit brawl work on any of them. New riders must use that rig. They're slimmed with gltf-transform: keep the clips the game uses, `prune({ keepLeaves: true })` (the `*_end` leaf bones are IK targets), `quantize`. The carousel (`openSelect` / `updateSelect` / `renderSelectPass`) is its own scene drawn over the dimmed world. A roster entry can carry a `look` (`LOOKS`). `dressRider()` runs at rest pose wherever a rider is built (`buildRig`, the carousel, CPUs): it clones and recolors materials by name, adds shader stripes and emissive eyes, and pins procedural accessories to bones with `bone.attach()`. Accessory positions are in the model's own rest space: +Z forward, head top ≈ 1.82, face ≈ z 0.21. On the base model the tee is the material `LightBrown`, not `White`.

**Global leaderboard:** Supabase over its REST API (plain `fetch`, no SDK). `supabase/schema.sql` holds the table, the row-level-security policies (read + insert only) and the sanity trigger (time floor per level, air/score/combo limits, a small initials blocklist, a throttle). A new level needs its id added to the table's `level` check. There's no minimum time on purpose: off-road shortcuts make short runs legit. Schema changes only take effect once someone re-runs `supabase/schema.sql` in the Supabase SQL Editor, since the game's key can't change the database. The game only goes online when `SUPABASE_URL` and `SUPABASE_KEY` are set and the page is served over http(s); otherwise the WORLD page is skipped.

**Free riding** (`state.free`, `updateFree`): leaving the road switches the rider from track space (`u` / `lateral`) to world space (`free.pos` / `free.dir`). Level 2: hop a rail. Level 1: go past `FREE_CLIFF_EDGE`. The ground is `groundAt(x, z)`: the terrain on level 2, the valley floor on level 1. `place()` builds a stand-in frame (`freeFrame()`) so the cameras and pose code don't change. Landing on any road (`nearestRoad`) calls `rejoinRoad`, which puts you back on the track there. Falling too far calls `leaveFree`, which respawns you where you left the road. Rails and edges cost speed once on impact (`state.atEdge`); riding along them doesn't.

**CPU racers** (`cpus`, `updateCpus`): each CPU keeps its own `u` / `lat` / `speed` and runs a simplified copy of the player physics. Its roster model wears the player's current bone pose (`snapshotPose`; same rig), falling back to Idle when the player is THE OG. Balance knobs: `CPU_SKILL`, `CPU_RUBBER`, `CPU_KICK_BELOW`. `racePlace()` feeds the POS readout and `lastRun.place`.

**Rider** (`buildRig`/`poseRider`):
- The Quaternius GLB is posed *procedurally* every frame: bones are reset to rest, then world-space helpers (`rotateWorld`, `turnWorld`, `aimWorld`, two-bone `ik2`) plant the feet, crouch, bend and twist the spine, and set the head and arms. There are no animation clips.
- Quirks:
  - GLTFLoader strips `.` from node names (`UpperArm.L` becomes `UpperArmL`).
  - The feet are separate bones parented to the armature root, not to the shins.
  - Skinned bounding boxes need `updateMatrixWorld(true)` before measuring.

**Menus + unlocks:** a fresh load shows the title → `openTrackSel('title')` (the `TRACKSEL` state: a 3×2 grid of `LEVELS[i].shot` screenshots, night versions under their day track) → `openSelect()` (rider carousel) → run. Picking another track calls `gotoLevel(n)`, which reloads with `sessionStorage 'downhill.flow' = 'rider'` so the new page skips straight to the rider select (Next Race too). The Esc menu's Track Select opens the same screen (`from: 'pause'`). Unlocks live in `localStorage 'downhill.unlocks'` (`{'1','2','3','1n',…}`): `crossFinish` calls `unlockOnFinish(place)`, where any finish opens the next track and 1st opens this track's night version. It stores what it opened in `lastRun.unlocked`. Debug: Shift+U on the track select unlocks everything. Track screenshots are `assets/tracks/*.jpg` (640×360, grabbed from the course tour).

**Night tracks** (`?night=1`, `NIGHT`): the same course with a separate leaderboard (`lbKey + '.night'`, world level id `LB_LEVEL` = `<id>-night`). The HDRI is skipped. `chaosSky` stays on in STARRY mode with `uPlanets` 0 and a quieter nebula (`uNeb`), and the big moon (`uMoon`) sits on the gas giant's bearing. `SUN_LIGHT_DIR` becomes moonlight. `setChaosMode(0)` returns to this night look, not to day. The "Night tracks" section adds:
- street lamps (levels 1–2): instanced posts, additive light-pool decals, and `LAMP_LIGHTS` real point lights that hop to the nearest lamps
- a headlamp spotlight on `skater`
- fireflies (a `Points` shader around `trees`)
- crowd glowsticks (`addGlowstick`, called from the spectator spawner)
- searchlights
- neon `glowMats` on level 3

Any `pow()` in these shaders gets a clamped base. One NaN pixel is enough: the bloom mip chain spreads it over the whole screen, which goes black.

**Level 3 monsters** (`updateMonsters`): a leviathan (instanced lumpy segments along a parabola through the monster loop's hoop, scrubbed by `state.u` so its head passes through as you reach the top) and `DRAGONS` demon dragons flying a wider figure-8 around `LP.eight` while you're on it. `resetMonsters()` runs in `resetRun`.

**Unlock screen:** `advanceStats` shows `#unlock` (state `UNLOCK`) once when `lastRun.unlocked` is non-empty. The lock animation is pure CSS keyframes, and each card's `--d` staggers it.

**Run flow:** `beginRun()` → COUNTDOWN (flyover + lights, `updateStart`) → PLAYING → crossing `FINISH_U` freezes `lastRun` and hands over to `updateCoast` (controlled stop at `PIT_STOP_U`) → PIT (`pitCam` orbit) → STATS → ENTRY (if placed) → RESULTS. `results.el.dataset.stage` drives which parts of the results panel show. The last stretch of `buildRoadPoints` is levelled/straightened from `END_LEVEL_T`; `inPit(u)` drops grass, cliffs and rails there in favour of the arena geometry (`ARENAS`).

**Rendering pipeline:**
- `RenderPass` → half-res `UnrealBloomPass` → `speedPass` (radial speed blur and chromatic aberration aimed at the travel direction; disabled when idle) → `finishPass`.
- `finishPass` does ACES tone mapping and sRGB itself through `#include <tonemapping_fragment>`, then applies grade, vignette, grain and letterbox. There's intentionally **no OutputPass**.
- MSAA is only enabled at pixel ratio below 2; it cost ~35fps on the half-float target.
- `adaptRes()` steps the pixel ratio through `RES_STEPS` to hold the frame rate.
- **Hitch traps (macOS Chrome):**
  - Don't redraw DOM elements over the canvas during play. Each redraw makes the compositor reshuffle its overlays: a 0.1–2s freeze. HUD text that changes mid-run belongs in the canvas; the trick popup is a canvas-texture quad drawn by `renderHudPass()`. Fading an element's `opacity` is fine.
  - Don't create an `AudioContext` mid-run; creating one blocks for ~0.5s. Use the shared `audioCtx`.
- **Sound effects** (`sfx`): synthesized on `audioCtx`: one-shots (`pop`, `land`, `crash`, `whoosh`, `hit`, …) plus looping noise beds (roll, grind, crowd) steered each frame by `sfx.update`. Add new sounds as methods there and call them with `sfx?.name()`; `sfx` is null when Web Audio isn't available.
  - `warmUp()` draws one hidden frame with everything visible once loading goes quiet, so shaders and textures aren't first prepared mid-run.

**Levels:** `LEVELS` picks the course from `?level=N` (1-based) at load; `LV` / `IS_SWITCH` gate the per-level code. Level 1 (Ridge Run) is `buildRoadPoints`'s ridge; level 2 (Switchback Pass) returns `buildSwitchbackPoints()` (`SB` tunables, `sbLegs`, `sbMidU(leg, off)` to place features on a traverse). Each level has its own leaderboard key (`LV.lbKey`). Track Select (Esc menu) and "Next Race" on the END screen both call `gotoLevel(n)`, which reloads with the next `?level=` and carries the radio track/time through `sessionStorage 'downhill.radio'`.

**Level 3 (Loop Heights, `IS_LOOP`):** `buildLoopPoints()` is a turtle (straight / loop / lip / gap / figure8) that records every feature's arc length in `LP`; `lpU(s)` turns that into `u`. Frames:
- Loops carry `up` by parallel transport. A loop that steps sideways isn't planar, so the leftover roll is spread evenly round it.
- Only the figure-8 banks, up to `MAX_BANK` 1.45 rad (about 83°).

Physics only on this level:
- Gravity is signed (climbs slow you). In the stunt sections (`inStunt`) you're forced into a tuck.
- Stick-to-the-track: `N = v²·(CURV·up) + G·up.y`, and dropping off an inverted section happens when `N < 0`. On banks (`onBank`), the pull along `side` has to be held by `LOOP_MU·N`, or you slide.
- The edges are open: going over one calls `enterFree(…, true)` with your real 3D velocity. Falls respawn you before the last entry pad.
- No drag in the air, because the gap is a ~6 s flight. The gap's `minSpeed` sets the launch speed.

`BOOST_PADS`: `computePadMins()` simulates each stretch (sitting up, the worst case) to get a speed window. `padBoost` clamps you into it; CPUs use the same pads. The camera rolls with the track (`camUp`). Every new level id also has to be added to `supabase/schema.sql`.

**Terrain:** everything is generated from `frames[]`. The road runs on a ridge: the grass shoulders are two strips per side (never one sheet under the road, which pokes through where the banking twists), and rock cliff walls hang off each grass edge down to `CLIFF_FLOOR`. `BRIDGE` (a `u` range, tested with `onBridge(u)`) removes grass and cliffs, adds gorge walls, deck girder and piers, and physics clamps the rider inside the rails there. Water fills the valley at `LAKE_Y`. The huge surfaces (cliff chunks, lake) set a high `renderOrder` so near geometry draws first and the depth test skips hidden pixels. Level 2 skips the ridge cliffs, bridge and mountain walls and instead builds one heightfield mesh (`TERRAIN_STEP` grid, shelves carved for the road via `nearestRoad`, pits flattened, border falls off to `CLIFF_FLOOR`); place scenery on it with `groundize(p, dy)` / `terrainHeightAt(x, z)` and skip steep spots with `steepAt`. Every camera goes through `keepAboveGround()`: from inside the hill its faces are culled and the ground looks see-through.

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
