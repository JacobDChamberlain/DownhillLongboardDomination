# Downhill — Upgrade Roadmap

Living triage of the upgrade wishlist for the `skateGame` prototype (`index.html`,
single-file Three.js r160, no build step, deployed as a static site). Keep this
current so any session can pick up where the last left off.

The prototype's job is **fast gameplay iteration** — mechanics designed here
transfer 1:1 to Unity/Unreal later. Graphics fidelity, character animation, and
multiplayer do *not* transfer well and are where a real engine earns its keep, so
we deliberately defer those.

---

## ✅ Already done
- Carve scrub tuned to realistic amounts (`CARVE_SCRUB`)
- Arcade results board + high scores (localStorage), initials entry, `finishRun()` hook
- Distance readout under top speed (HUD)
- First hill eased so it opens smoothly (`START_EASE`) — big drop after preserved
- Track shortened ~half (`TRACK_LEN` / `TRACK_DROP`) — scenery-first
- Hangtime tracked per run + shown on the scoreboard (`Air` column)

---

## 🟢 Do now — stays in single-file Three.js, no backend, no engine
Kick-push, jump tricks (procedural), ramps, giant gaps + fall-reset, item pickups
(boost/endurance/free-death), wireframe/glitch mode, blinking-chaos sky,
audio-visualizer sky, starry/meme skies (need image assets), HUGE cliffs, bridges
over water, carve-down-mountainside sections, crowds at start/finish, cheering SFX
(needs audio asset), customizable board/player (colors), more detailed scenery,
the full post-processing visual pass (bloom / vignette / motion blur / chromatic
aberration; HDRI + textured tarmac need asset files).

## 🟡 Needs a backend or a fundamental architecture change
- **Global scoreboard** — needs a backend, *not* an engine. Cheapest: a BaaS
  (Supabase / Firebase) or tiny serverless + KV. Worth doing even in prototype.
- **Character animations** (walk-with-board, get-on/off, dances, polished tricks)
  — rigged glTF + `AnimationMixer`; the authoring pipeline is the real cost.
- **Multiplayer** — real-time netcode + server (WebSockets/WebRTC, Colyseus/
  Geckos.io). Biggest lift; fundamental architecture change.
- **Attack items that hit other players** — rides entirely on multiplayer.

## 🔴 Engine-territory (possible in web, but don't over-invest)
Almost nothing here is literally impossible in Three.js — 🔴 means "the web fights
you hardest here and your Unity/Unreal endgame pays off, so don't sink effort in."
- AAA "really beautiful graphics" (Nanite/Lumen-tier) — a quality ceiling.
- High-quality character animation & IK — creation/blending/retargeting tooling.
- The whole system at shippable quality at once (MP + combat + physics + animation
  + content pipeline).

---

## Build order (checked off as completed)

- [x] **1. Gameplay mechanics** — kick-push + meter/cooldown, procedural jump-tricks
  wired to score, ramps, giant gaps with fall-reset, item-pickup framework
  (rocket boost / endurance+ / free-death; attack items stubbed for multiplayer).
- [x] **2. Visual-chaos toys** — chaos mode on `X`: RAVE (strobing rainbow sky), VISUALIZER
  (music-driven spectrum bars), STARRY (night + Milky Way), GLITCH (wireframe world + screen
  tearing), all pulsing to the music. Meme/image skies still open (need image assets).
- [ ] **Rail grinds** — *done: I (gamepad Y) locks onto either guardrail from the air, THPS-style
  balance needle (A/D), Space hops off, bails, sparks, points per second; 50-50 and BOARDSLIDE
  (hold Shift).* TODO grind tricks:
  - [ ] Pick the grind by direction + I at lock-on, like THPS: nosegrind, 5-0, crooked, smith,
        feeble, lipslide, tailslide, noseslide
  - [ ] Switch grinds mid-rail (direction + I) with a combo multiplier
  - [ ] Grind → air trick → grind combos (score multiplier across the chain)
  - [ ] Manuals (tip up/down on the road) to link combos between rails
  - [ ] Per-trick balance difficulty (slides harder to hold than 50-50s)
  - [ ] Grind sound + landing sound
- [ ] **3. World & scenery** — *done: cliffs (road rides a ridge), bridge/viaduct over a
  fjord, crowds + arches at start/finish.* Still open: carve-down-mountainside sections, more
  roadside detail.
- [ ] **4. Full visual pass** — *post-processing, trailer cams, HDRI sky, PBR road/grass, rigged rider, pine forest done; ground detail/LOD next* — post-processing (bloom, vignette, motion blur,
  chromatic aberration); HDRI + textured tarmac need asset files added.
