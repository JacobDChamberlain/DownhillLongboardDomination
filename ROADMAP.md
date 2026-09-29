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
*(Done since the last list: the feel fixes, the tricks & scoring overhaul, CPU racers, the global
board, off-road riding, and level 3 with its loops.)* Quick wins first, then the bigger systems.
1. **Quick wins:** rider renames (Bob, CIA), brawl tuning (walk ×2, faster punch + fall, mouse look,
   K kicks the crowd), HUD moves (landing call over your head, place under the map), speed boost
   for clean landings, and a **9** debug key that skips to just before the finish line.
2. **Presentation:** pre-race course flyover, level 1 sea giants, sound effects.
3. **New riders:** Hesher, Mime, Cthulhu (safe to use).
4. **Starry mode upgrade** (done).
5. **Track select screen + unlock progression** (done), then **night tracks** with the unlock screen.
6. Then **2-player** — only after the user has played 5.
7. Later: difficulty levels + cheat codes, unlockable riders, free carving, weapons in hand (water
   bottle explosions), mobile.

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
- [x] **CPU racers** — *done: three AI riders (RAZ, KOJI, MEL) on the start grid with you; same
  physics, always tucked, per-rider skill + a light rubber band; inside line through bends,
  dodge whoever's ahead, kickers with gap assist, shoulder bumps; POS x/4 under the timer and
  your place on the results. They tuck and sit up on their own (your cruise/tuck poses blended),
  wobble off the line, bail some kicker landings and stumble at speed, take rocket boosts;
  **K** kicks a racer beside you (Road Rash style); they're knockable in the pit brawl.
  Results: a THIS RACE standings window (same rankings) before the all-time board. Minimap
  top-left: the course to shape with a dot per racer.* Ideas: difficulty setting, CPUs kicking
  back, CPU tricks you can see.
- [x] **End-of-race stats board** — before initials, ←/→ or Tab cycles the ranking: fastest
  time, high score, biggest combo, longest hangtime, speed demon (top speed), etc.

## 🗺️ Tracks & levels
- [ ] **Free carving / real steering** — *partly there: off the road you already ride free (hop a level-2 rail and bomb the mountainside, or ride off a level-1 cliff); the road itself is still track-locked.* — right now the rider is locked to the track (`u` +
  lateral offset), like changing lanes in a drag race: you can't carve a corner or miss one.
  Real steering means a free heading on the road surface, so you can take hairpins with
  a drift/carve (NFS Underground 2-style grip → slide), or miss the turn, hit the rail and fly
  off the ledge. Biggest mechanics change on the list; do it before more switchback maps.
- [x] **Night tracks** — *done: `?night=1` on any level: moonlit starry sky with a big moon ahead, moonlight shadows, street lamps with light pools (levels 1–2), a rider headlamp, fireflies in the trees, glowsticks in the crowd, sweeping searchlights, neon road edges on level 3; own local + world leaderboards (re-run `supabase/schema.sql` for the `*-night` level ids). The unlock screen after FINISH! plays for every unlock (lock rattles, pops and cracks in half, the track fades in).* Was: night versions of each track, unlocked by winning (1st) the day one.
  Street lights and nightlife lights; fireflies in the level 1 forest. **Unlock screen:** right
  after the FINISH! screen when one unlocks, the night track's screenshot goes from blacked
  out/faded to fully visible with a quick lock-breaking animation.
- [x] **Loop-de-loop track** — *done: level 3 "Loop Heights" (`?level=3`): a sky course on pillars —
  a loop, three shrinking loops in a row, a lip into a ~540-unit gap, a figure-8 banked nearly sideways
  at its ends, a mountain-sized loop (R 230), the finish. Real loop physics (fall off if too slow over
  the top, slide off banks without enough grip), open edges, boost pads that guarantee the stretch ahead
  for everyone (CPUs too). A last half-twist hangs the run-out and finish pit upside down (crowd
  and all; the track holds you there).* Ideas: a crash-cam replay of falls, loop-specific trick
  points, a pit brawl on the ceiling (off in level 3's upside-down pit for now).
- [x] **Track select screen + unlocks** — *done: title → track select → rider select → race; screenshots of each track in a 3×2 grid (the selection highlighted gold), night versions under each day track (unlocked ones say COMING SOON until the night tracks land), best times, lock + requirement for locked ones, and a shake if you pick one; the Esc menu's Track Select opens the same screen. Unlocks saved in localStorage. Debug: Shift+U on the track select unlocks everything.*
  Flow: title → track select → rider select → race. Three windows with a screenshot of each track;
  move to pick one, the selected one highlighted; each night track sits under its day track.
  Unlocks (saved locally), starting with only level 1 open:
  - finish level 1 (any place) → level 2; 1st on level 1 → level 1 night
  - finish level 2 (any place) → level 3; 1st on level 2 → level 2 night
  - 1st on level 3 → level 3 night
- [ ] Keep the rider out of the mountain on level 1 (parked — "reminds me of the old days").

## ✨ Quick wins (from the second wishlist)
- [x] **Rename riders:** HARD HAT → **BOB**, THE SUIT → **CIA** (just labels in `RIDERS`).
- [x] **Brawl tuning:**
  - walk and sprint **twice as fast** (currently 5.2 / 9.5 u/s)
  - a **quicker punch**, and spectators **fall down faster** (speed up those two animation clips)
  - **mouse moves the camera** while you walk, the same as on the board
  - **K kicks** spectators too, not just racers
- [x] **HUD moves:**
  - the landing call (**clean / SKETCHY!**) pops just above the rider's head
  - the race **place** (POS x/4) moves from under the timer to under the minimap
- [x] **Clean landings pay speed:** land any trick clean and get a small speed boost (sketchy ones
  don't).
- [x] **FINISH page stats in two columns** (names left, numbers right, before initials). *Already
  done in the finish-flow update.*

## 🎨 Presentation & chaos modes
- [x] **Pickups brighter**, stand out more (labels and beams are in; push the glow/size).
- [x] **Sound effects** — *done: all synthesized (Web Audio, no files): ollie pop, landing thud + sketchy scrape, crash, rolling-wheels loop (grittier on grass), grind scrape loop, pickup chime, boost whoosh, punch/kick smack + swing, crowd roar by proximity with cheers, sea splashes; Effects Volume in Settings.* Was: — ollie pop, grind loop, landing, crash, crowd cheers (synth or CC0).
- [ ] **Rave mode** — glowsticks on the crowd; more bass (low-shelf boost on the music via Web
  Audio; only works over http(s), like the analyser).
- [x] **Starry mode** — *done: coloured stars in four layers (the bright ones bloom), drifting
  nebula clouds along the milky band, shooting stars, three planets hung around each course's
  heading (a ringed gas giant, an ice giant, a small red one; over the valley on level 2) with
  bands that shear by latitude, a churning storm vortex, atmosphere glow and night-side lightning
  that bursts on the beat. Once in a blue moon (first visit 20–35 s in, then every 70–150 s) a UFO
  zips in, hovers over the road with its beam on to a theremin warble, and shoots off. Debug: **8**
  switches to STARRY and calls the UFO.* Was: brighter stars, more cosmic activity: huge nearby
  planets with flowing storms, and once in a blue moon a UFO zips by.
- [ ] Meme/image skies (need image assets).
- [x] **Pre-race course flyover:** before the start cam cuts to you, a short tour of the track's
  highlights (the gap, the loops, the bridge). Hand-picked camera points per level, skippable like
  the current flyover.
- [x] **Level 3 monsters:** *done: a hideous Lovecraftian leviathan (~2500 long, 5× the whale: lamprey maw ringed with teeth, burning throat, a spray of glowing eyes, writhing face tentacles, bone spines) leaps up out of the depths and threads the monster loop's hoop as you reach the top; three demon dragons (horned, glowing eyes, ember-lit hides, flapping bat wings) weave over and under the figure-8 while you ride it.*
- [x] **End menu:** Next Race (straight into it, same rider) / Restart / Quit, centred; pause menu options centred.
- [x] **Level 1 sea giants:** mountain-sized whales and dolphins breaching out of the lake beside
  the course and arcing *over the bridge*. Needs a CC0 whale/dolphin model (or a stylized
  procedural one), a breach path + splash, and one timed to cross as you ride the viaduct.

## ⚔️ Combat & weapons
- [ ] **Weapons in hand** — stick, bottle, rock visibly held by the rider.
- [ ] **Glitter / confetti bomb** — detailed particle burst that blinds whoever it hits for a few
  seconds until it clears. Needs targets: other players (online) or AI riders; could hit the
  crowd in the pit brawl.
- [ ] **Punches** — F / J for left / right fist, with a first-person view option. Ties into the
  pit brawl below.
- [ ] **Water bottle explosions:** some spectators blow up when hit with the water bottle: a small
  mushroom cloud and body parts flying. It's a tone call (cartoony or gory?); cheapest is a
  particle burst plus the model split into a few flung chunks.

## 👤 Characters & customization
- [x] **Character select** — *done: a turntable carousel before the race (on load, from the title
  screen; to switch riders, Quit → track select → rider select); ← → spins, Enter rides, last pick remembered.
  Eight Quaternius riders on the same rig + THE OG (box rider, own board).* Still open: stats per
  rider, the OG in the pit brawl (he has no animations), rider-specific boards.
- [ ] **Keep the OG version playable** — the pre-visual-upgrade build is commit `c66d8dc`
  ("Gameplay batch"). Tag it (`og`) and optionally serve it at `/og/`.
- [ ] Customizable board/player colors.
- [x] **New riders:** **Hesher**, **Mime**, **Cthulhu** — *done as looks on the existing models
  (`LOOKS`): recolors by material name, shader stripes (the mime's shirt), glowing eyes, and
  procedural bits pinned to bones (long hair + mustache; beret + scarf; face tentacles + bat
  wings). They ride, crash and brawl like everyone else, and show up as CPU rivals too.*
- [ ] **Unlockable riders** — needs an unlock system first (what earns each: beat a track, a
  score, a secret) plus a locked slot on the carousel. Wishlist: Godzilla, Otto (The Simpsons),
  Pennywise, Freddy Krueger, Jackie Chan, LeBron James, Jak & Daxter, Ratchet & Clank, Courage
  the Cowardly Dog, the Grim Reaper, and **Wyatt** (a friend, modeled in Meshy; probably no
  animations, so he rides stiff, which is fine).
  - *Heads-up:* nearly all of these are someone else's characters or a real person's likeness.
    Fine in a private build, but a public or paid release would need licences, so ship
    look-alike originals instead (a giant lizard, a creepy clown, a horror-slasher, a kung-fu
    star…). The Grim Reaper and Wyatt (with his OK) are free to use.
  - None have CC0 models; each needs a custom model rigged to the shared skeleton to ride.

## 🔊 Sounds to replace
Every sound effect is currently a **synthesized placeholder** (Web Audio, no files), and they're all
likely to be replaced with real recordings. Each one is a method on `sfx` (search for its name in
`index.html`). The swap: load the file into an `AudioBuffer` once at startup, then play it from
that method (keep the shared `audioCtx`; don't create a context mid-run).

| Sound | Method | Plays when |
|---|---|---|
| [ ] Ollie pop | `sfx.pop()` | any jump: Space, kicker launch, grind hop-off |
| [ ] Landing thud | `sfx.land(false)` | landing from the air |
| [ ] Sketchy landing scrape | `sfx.land(true)` | a sketchy landing (added on top of the thud) |
| [ ] Crash | `sfx.crash()` | you bail: a bad landing or losing a grind |
| [ ] CPU crash (quieter, by distance) | `sfx.crash(k)` | a CPU racer wipes out near the camera |
| [ ] Rolling wheels (loop) | `sfx.update` → `roll` | always while riding; louder with speed, grittier on grass |
| [ ] Grind scrape (loop) | `sfx.update` → `grindL` / `grindH` | while grinding a rail |
| [ ] Crowd (loop) + cheers | `sfx.update` → `crowdL`, `sfx.cheer()` | near any crowd; swells at the finish and on knockouts |
| [ ] Pickup chime | `sfx.pickup()` | endurance / free death / weapon pickups |
| [ ] Rocket boost whoosh | `sfx.whoosh(true)` | the rocket boost pickup |
| [ ] Boost pad whoosh | `sfx.whoosh(false)` | level 3 boost pads |
| [ ] Punch / kick swing | `sfx.swing()` | throwing a punch or kick in the pit brawl |
| [ ] Hit smack | `sfx.hit()` | a punch/kick landing; kicking a racer or a fan |
| [ ] Splash | `sfx.splash(dist)` | a whale or dolphin leaving or entering the lake (level 1) |
| [ ] Unlock | `sfx.unlock()` | the lock breaking on the unlock screen |
| [ ] UFO warble | `sfx.ufo(in, hover, out)` | the STARRY-mode UFO flying in, hovering and zipping off |
| [ ] Countdown beeps | `beep()` | the three start lights (not in `sfx`; uses the music volume) |

Nice-to-haves once real audio is in: wind rush at speed, board clack on kicks, a crowd "ohhh" on
crashes, whale song, a separate volume for the crowd.

## 🎮 Game options
- [ ] **Difficulty levels** (Easy / Normal / Hard): scales the CPU racers (`CPU_SKILL`, rubber band,
  how often they crash) and maybe landing generosity.
- [ ] **Cheat codes:** typed on the title screen or in the pause menu. Ideas: big head, moon
  gravity, infinite boost, always clean landings, all riders unlocked, chaos mode forced on.
  Cheated runs go on their own **cheat leaderboard** (world + local) with a field listing every
  cheat used that session, shown on the board as tags, rather than being left off the boards.

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
- **Global scoreboard** — *built: Supabase table + RLS + sanity trigger (`supabase/schema.sql`), WORLD board after ALL TIME; turns on once `SUPABASE_URL` / `SUPABASE_KEY` are set in `index.html`.* Originally: needs a backend, *not* an engine. Cheapest: a BaaS
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
