# Full Visual Pass — TODO

Next stage of graphics work, to layer **on top of** the lean pass that's already
in `index.html` (golden-hour lighting, layered ridgelines, aerial-perspective
fog, speed cues, banked winding track).

The lean pass deliberately kept the "double-click `index.html` to run" property.
The full pass will likely break that (see **Dependencies / serving** below), so it
was split out on purpose. Everything from the lean pass stays — this is additive.

---

## Goals (unchanged priorities)
1. **Speed** — make velocity even more visceral.
2. **Scale** — make the landscape feel vast.
3. **Realism** — cinematic, physically-based look.

## Scope — what the full pass adds

### 1. Post-processing stack (`EffectComposer`)
- `RenderPass` → `UnrealBloomPass` (subtle bloom on sun/highlights)
- Vignette (darkened edges to focus the frame)
- **Motion blur** and/or radial blur scaled by `speedT` — the biggest speed upgrade
- Mild **chromatic aberration** that ramps in at high speed
- Move the existing `toneMapping` into an `OutputPass` if needed for correct ordering
- Addons live at `three/addons/postprocessing/*` (import map already points at
  `three@0.160.0/examples/jsm/`)

### 2. HDRI / image-based lighting
- Replace the procedural `RoomEnvironment` with a real outdoor **HDRI** loaded via
  `RGBELoader` + `PMREMGenerator` for believable ambient light and reflections
- Optionally use the HDRI as the skybox instead of the shader dome
- Pick a golden-hour / mountain-pass `.hdr` (e.g. from Poly Haven)

### 3. Higher-detail geometry & materials
- **Textured tarmac**: albedo + normal + roughness maps on the road ribbon (with
  proper UVs along the spline); painted lines as texture rather than geometry
- **Continuous metal guardrail** mesh (currently just posts)
- Grass texture / scattered detail; better tree models or billboard imposters
- **LOD** on ridgelines/trees and instanced roadside detail to hold framerate

### 4. Extra polish (optional)
- Depth of field on distant peaks
- Sun flare, god rays
- Ambient occlusion (SSAO/GTAO) for contact shadows
- Dynamic time-of-day

---

## Dependencies / serving (IMPORTANT)
- HDRIs and texture files are **fetched**, which browsers block from `file://`.
  Once the full pass lands you'll need a local server, e.g.:
  ```
  python3 -m http.server 8000
  # then open http://localhost:8000
  ```
- Add asset files under something like `assets/` (hdri, textures). Note: large
  binaries in git — consider Git LFS if they get big.

## Acceptance criteria
- Still runs (via local server); `node --check` on the extracted module passes;
  no console errors.
- ~60fps target on an M-series Mac at 1440p — use LOD/instancing/culling.
- Everything that moves with the road `frames[]` still lines up.
- Add 2–3 tunable constants (bloom strength, motion-blur amount, HDRI exposure)
  near the top of their sections.

## Current tunables already in `index.html` (lean pass)
- `FOG_DENSITY` (0.0004) — haze thickness / ridge visibility
- `BANK_GAIN` / `MAX_BANK` (1.4 / 0.30) — how hard the road banks into turns
- sun `intensity` (3.2) and `toneMappingExposure` (1.05) — overall brightness
- wind-streak count/opacity and `targetFov` — speed-cue intensity (in `place()`)

## Where things live in `index.html`
- Renderer + tone mapping: top of the module script
- Palette / fog / sky dome / lighting / environment: "Scene, camera, renderer"
- Road spline + banking: `buildRoadPoints()` and the banking loop after `frames[]`
- Ridgelines + valley: end of the "Guardrail posts + roadside trees" block
- Speed cues: `wind` factory after the skater; FOV/shake in `place()`
