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
- Run timer (mm:ss, top centre) from the green light to the finish line
- First hill eased so it opens smoothly (`START_EASE`) — big drop after preserved
- Track shortened ~half (`TRACK_LEN` / `TRACK_DROP`) — scenery-first
- Hangtime tracked per run + shown on the scoreboard (`Air` column)

---

## 🎯 Up next — suggested order
Quick feel fixes first (they make every run better), then the tricks/scoring overhaul, then
content. The carving rewrite is the big one: do it before building more switchback-style maps.
1. Bug & feel fixes (below) — respawn loop, spin landing stance, kicker ramps, coast steering
2. Tricks & scoring overhaul — spin controls, landing judgement + crashes, grind boost/scoring
3. Sound effects (ollie, grind, landing, crash, crowd)
4. Free carving / real steering (engine-level change to the rider model)
5. Night tracks + unlocks, then the loop-de-loop track
6. Characters, weapons, mobile, online

---

## 🐛 Bugs & feel fixes
- [x] **Gap respawn loop** — falling in respawns you just before the kicker at half speed,
  usually below `GAP_MIN_SPEED`, so you can never clear it (the free-death pickup just happens to
  sit before it). Respawn further back and/or restore enough speed for the jump.
- [x] **Spin landing** — landing a half-turn unwinds the rider back to the original facing
  (`trickPivot.rotation.y *= 0.7`). Land in whichever stance you're facing (odd 180s = switch).
- [x] **Kicker ramps** — they only fire if you're on the ground as you cross them
  (`kickerLaunch`), so jumping into one goes straight through. Make them real kickers that launch
  you whenever you touch them.
- [x] **Steer during the finish coast** — keep A/D lateral control while the pit stop brakes you
  (only speed is automatic).
- [x] **Boardslide lean** — balance lean should rock across the rail (forward/back from the
  rider's view), not along it.

## 🛹 Tricks & scoring
- [x] **Air spin controls** — spin with A/D *after* leaving the ground; holding a direction
  before Space is awkward and scrubs speed.
- [x] **Landing judgement** — generous landing window with three results: clean (right on
  either stance), SKETCHY! (rough but no crash, fewer points), bail → crash scene.
- [x] **Grind momentum** — small, brief speed boost on lock-on and on hop-off; you can still
  slow to a stop on the rail as now.
- [x] **Grind scoring by distance**, not seconds, so fast grinds pay more (THPS scores by time
  on the rail, as far as I know, but distance suits a downhill game) — combine with the
  per-trick values in the grind TODO list below.
- [ ] **More tricks** — see the grind trick list below; also flip tricks, more grabs, manuals.
- [x] **Combos** — tricks started within 2.5s of touching down chain; the chain pays a bonus
  (10% × points × extra tricks) and feeds the Biggest Combo ranking; a bail loses it.
- [ ] **CPU racers** — AI riders to race against (next up).
- [x] **End-of-race stats board** — before initials, ←/→ or Tab cycles the ranking: fastest
  time, high score, biggest combo, longest hangtime, speed demon (top speed), etc.

## 🗺️ Tracks & levels
- [ ] **Free carving / real steering** — right now the rider is locked to the track (`u` +
  lateral offset), like changing lanes in a drag race: you can't carve a corner or miss one.
  Real steering means a free heading on the road surface, so you can take hairpins with
  a drift/carve (NFS Underground 2-style grip → slide), or miss the turn, hit the rail and fly
  off the ledge. Biggest mechanics change on the list; do it before more switchback maps.
- [ ] **Night tracks** — night versions of each track, unlocked by beating the day one
  (with an unlock notification). Street lights and nightlife lights; fireflies in the level 1
  forest.
- [ ] **Loop-de-loop track** — booster pads with glowing arrows before the loop so you have the
  speed; you can fly off if you leave the road.
- [ ] Fleshed-out track select — previews, best times, on the title screen *(basic Track Select
  in the Esc menu + Next Race are done)*.
- [ ] Keep the rider out of the mountain on level 1 (parked — "reminds me of the old days").

## 🎨 Presentation & chaos modes
- [ ] **Pickups brighter**, stand out more (labels and beams are in; push the glow/size).
- [ ] **Sound effects** — ollie pop, grind loop, landing, crash, crowd cheers (synth or CC0).
- [ ] **Rave mode** — glowsticks on the crowd; more bass (low-shelf boost on the music via Web
  Audio; only works over http(s), like the analyser).
- [ ] **Starry mode** — brighter stars, more cosmic activity: huge nearby planets with flowing
  storms, and once in a blue moon a UFO zips by.
- [ ] Meme/image skies (need image assets).

## ⚔️ Combat & weapons
- [ ] **Weapons in hand** — stick, bottle, rock visibly held by the rider.
- [ ] **Glitter / confetti bomb** — detailed particle burst that blinds whoever it hits for a few
  seconds until it clears. Needs targets: other players (online) or AI riders; could hit the
  crowd in the pit brawl.
- [ ] **Punches** — F / J for left / right fist, with a first-person view option. Ties into the
  pit brawl below.

## 👤 Characters & customization
- [x] **Character select** — *done: a turntable carousel before the race (on load, from the title
  screen, and "Change Rider" on the end screen); ← → spins, Enter rides, last pick remembered.
  Eight Quaternius riders on the same rig + THE OG (box rider, own board).* Still open: stats per
  rider, the OG in the pit brawl (he has no animations), rider-specific boards.
- [ ] **Keep the OG version playable** — the pre-visual-upgrade build is commit `c66d8dc`
  ("Gameplay batch"). Tag it (`og`) and optionally serve it at `/og/`.
- [ ] Customizable board/player colors.

## 🚀 Platform & release
- [ ] **Mobile friendly** — touch controls (steer by tilt or thumb zones, tap to jump), perf
  presets. Set a target release date.
- [ ] **Paid options** — cosmetic customization. Photo-on-your-rider/board is possible entirely
  in the browser: the photo becomes a texture on the player's device and is never uploaded
  or stored.
- [ ] **2-player online** — see Multiplayer below.
- [ ] **Run inside the maldevera.com merch booth** — yes, the game is a static page, so the site
  can embed it with an `<iframe>` pointing at the Render URL (most site builders have an
  embed/code block). Needs `allow="autoplay; fullscreen; gamepad"` on the iframe, and keyboard
  focus has to go into the frame (click to play).

---

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
- [x] **Pit brawl** — *done: F + J after the finish (pit orbit, stats, board or end screen) steps
  you off the board; walk the finish pit (WASD, Shift runs, C/H/X still work), F / J punch
  left / right using the rider model's own clips; spectators in reach get knocked down (death clip)
  and are back up next run. A STICK pickup swings (Sword_Slash) and sweeps everyone in front; other
  weapons change reach. Esc goes back to the results.* Still open: weapons visible in hand,
  thrown rock, crowd reactions (flee / fight back), a first-person option.
- [x] **3. World & scenery** — *done: cliffs (road rides a ridge), bridge/viaduct over a
  fjord, crowds + arches at start/finish, enclosed pits at both ends (crowd all round), finish
  coast-to-a-stop + pit camera + staged results, start flyover + three-light countdown,
  mountainside walls (rock face rising on the inside of two curves), roadside rocks / bushes /
  grass tufts, **level 2 "Switchback Pass"** (six traverses joined by hairpins down a
  heightfield mountain face, `?level=2`), per-level leaderboards, **Next Race** on the final
  screen (music carries over), **Track Select** in the Esc menu.* Ideas: a fleshed-out track select
  (previews, best times, on the title screen), more levels,
  keep the rider out of the mountain on level 1.
- [ ] **4. Full visual pass** — *post-processing, trailer cams, HDRI sky, PBR road/grass, rigged rider, pine forest, ground detail (grass tufts, rocks, bushes) + distance LOD done* — post-processing (bloom, vignette, motion blur,
  chromatic aberration); HDRI + textured tarmac need asset files added.
