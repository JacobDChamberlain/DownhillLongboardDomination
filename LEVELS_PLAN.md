# Levels 4–6 plan: the Desert world

Draft, October 11, 2026. Nothing here is built yet. Start once free carve is settled (see Prerequisites).

## The pattern

Each world has **two "normal" courses, then one "weird" one**. The weird course is the reward for finishing the world, so it should feel like a different game for a minute.

| World | Normal 1 (flowing) | Normal 2 (technical) | Weird (reward) |
| --- | --- | --- | --- |
| Alpine (done) | 1 Ridge Run | 2 Switchback Pass | 3 Loop Heights |
| **Desert (this plan)** | **4 Mesa Run** *(working name)* | **5 Slot Canyon** *(working name)* | **6 TBD** (cosmic/nightmare #2) |

The next batch is **levels 4 and 5**. Level 6 comes after them, as the world's reward. Once world 1 is read as Alpine 1–2 plus Loop Heights, there's no slot left for an "Alpine #4". It could come back later as a bonus track or a mirror/variant.

That gives RELEASE_PLAN.md's "4 worlds × 3 courses" as: Alpine, Desert, then two more worlds (Coastal City is the obvious third).

---

## Prerequisites (before any level-4 code)

1. **Free carve settled.** *(Done: PRs #24, #25.)* Merge `feat/cpu-carve` after play-testing, then decide: keep/tune carve, SLIDE chip and sound, and whether classic stays. The new courses are **tuned for free carve** and must still be playable in classic.
2. **Level descriptors instead of `IS_*` checks.** *(Done on `refactor/level-descriptors`, Nov 1 2026: 86 checks → 15 course-content ones; see CLAUDE.md "Levels".)* There are about 80 `IS_RIDGE` / `IS_SWITCH` / `IS_LOOP` checks today. Adding three more levels as more `IS_*` checks would make every one of them a three-way branch. Move the per-level differences onto the `LEVELS` entries as data and features, for example:
   ```js
   { id: 'mesa', world: 'desert', name: 'MESA RUN', build: buildMesaPoints,
     terrain: 'heightfield',          // 'ridge' (L1) | 'heightfield' (L2, desert) | 'sky' (L3)
     rails: 'partial', cliffs: false, bankMax: 0.30, physics: 'normal',   // 'stunt' = L3 rules
     palette: DESERT, scenery: desertScenery, crowdZones: …, items: …, ramps: …, gaps: … }
   ```
   Then `IS_LOOP && …` becomes `LV.physics === 'stunt' && …`, and so on. Do it as its own branch with **no behaviour change**, and play all six existing variants before building on it. This is the biggest risk in the plan, so it needs a careful diff review.
3. **Optional, and recommended against for now:** RELEASE_PLAN.md's split into ES modules. It helps at 12 courses, but it's a big diff to do in the middle of content work. Revisit after level 6.

## Shared work for every new level (checklist)

- [ ] `LEVELS` entry (id, name, lbKey, shot/shotNight) and a `build…Points()` course builder
- [ ] `supabase/schema.sql`: add `<id>` and `<id>-night` to the `level` check (both places), plus a time floor in the sanity trigger. **The user re-runs it in the Supabase SQL Editor.**
- [ ] Track select: the 3×2 grid becomes **one page per world** (3 courses × day/night), with left/right or Q/E to switch worlds and a world name header. Locked worlds show as locked.
- [ ] Unlock chain: `unlockOnFinish` already opens `LEVEL_IDX + 1`, so finishing 3 opens 4. Check that the night unlock and the unlock screen work across the world boundary.
- [ ] Finish pit / arena (`ARENAS`), `FINISH_U`, `PIT_*`, `STOP_U` for the new course end
- [ ] `ITEMS`, `RAMPS`, `GAPS`, crowd zones, `DETAIL_U_MIN`
- [ ] CPU racers: `CPU_CORNER` / `CPU_LOOKAHEAD` checked on the new bends; there should be no corner where every CPU crashes or every CPU brakes to a crawl
- [ ] Free riding: `groundAt` / `leaveFree` rules for leaving the road
- [ ] Night version: lamps, crowd glowsticks, headlamp. Desert night = big clear star sky, campfires instead of street lamps in places.
- [ ] Track screenshots (`assets/tracks/<id>.jpg` and `-night.jpg`, 640×360 from the course tour)
- [ ] `warmUp()` covers the new materials
- [ ] Debug: the 9 key (skip to just before the finish) works
- [ ] Docs: CLAUDE.md architecture section, ROADMAP.md, RELEASE_PLAN.md counts, `assets/CREDITS.md`

## Desert world kit (built once, shared by 4–6)

Everything CC0 and small, per CLAUDE.md:

- **Sky:** a 2k Poly Haven desert/clear-sky HDRI, aimed with `aimHdri` to a low afternoon sun. Fog and haze come from it as today: warm, dusty and thin.
- **Ground:** reuse level 2's heightfield system (`TERRAIN_STEP`, road shelves via `nearestRoad`, `groundize`, `steepAt`). New 1k textures: red sand, sandstone. Add a **strata** tint in the terrain shader (horizontal bands by world Y) so cliffs read as canyon rock.
- **Road:** sun-bleached asphalt, with a sand-drift decal at road edges.
- **Scenery** (Poly Pizza / Quaternius CC0, merged → dedup → resize): saguaro and barrel cactus, Joshua trees, boulders, dry brush/tumbleweeds, distant **mesas and buttes** (cheap far-scenery meshes with the haze material), a water tower, power-line poles.
- **Ambient life:** tumbleweeds rolling across the road (a hazard: hit one and it bursts, small speed loss); vultures circling; heat shimmer near the ground in daylight (a cheap screen-space wobble in `finishPass`, masked to the lower screen, **off at night**).
- **Free riding:** sand is slower than the road but rideable. Dunes give small natural kickers.

## Level 4: Mesa Run (flowing)

**Feel:** the desert version of Ridge Run. Long, fast, sweeping carves across open desert, with big views. It's the course that teaches free carve at speed.

- **Layout:** start up on a mesa top, drop off its rim on a long sweeping descent, then cross the flats with long S-bends, and finish in a dry lakebed.
- **Carve tuning:** grip holds `CARVE_GRIP / R` → for a bend of radius R, the top speed is √(60·R). Keep most bends at **R ≥ 120** (holds ~85 u/s, so you can carve them flat out). Put **two or three tighter ones (R 80–100)** after fast straights, so braking and sliding are a real choice. A debug overlay that prints R and the max speed at each bend would make this easy to tune.
- **Signature moments:**
  1. **Natural arch:** the road passes under a huge sandstone arch. There's an optional kicker line off a rock lip to the side that clears a dry wash (a `GAP`).
  2. **Dry wash dip:** the road drops into a wash and back up, so you get air at speed.
  3. **Mesa rim drop:** the first descent has no rails. Go wide and you're off-road, riding free down the mesa slope (like level 1's cliff, but rideable sand, so it's a real shortcut with a risk).
- **Rails:** only on the mesa rim descent; open desert elsewhere.
- **Crowd:** start, the arch, finish.

### TODO: the worm abduction (decided Nov 1 2026: replaces Mesa Run's burst-out-of-the-side exit)

The user's idea, with **our own names and designs** (not Dune's "no-ship" / "Caladan": real legal risk for a Steam release):
1. You ride into the giant worm's mouth (as now).
2. The camera pulls out: a vast, silent alien ship looms over the desert and snatches the worm in a beam.
3. It carries the worm off to a lush ocean world (a green planet seen from orbit, then down through the clouds).
4. Cut back inside the worm: a loop in its gut, you turn around, and ride back out of the mouth, out of the ship's hold, onto the new world.
5. The rest of the run is on the ocean world: waterfalls off cliffs, lakes, castles on crags, green everywhere.

What it takes: a scripted cutscene (camera + ship + worm, with the race clock paused); a teleport in `u` (the ocean-world track is a separate stretch of the same spline far from the desert, joined by a hidden link everyone skips, CPUs included); a second biome mid-level (fog, light, terrain colours, scenery switch at the hand-off: today the look is per level); a loop inside the worm on a normal-physics level (level 3's `STUNT` rules applied per section); new scenery (water, waterfalls, castles). Mesa Run would become the desert world's long "weird" course; level 6 then needs a new idea.

## Level 5: Slot Canyon (technical)

**Feel:** the desert version of Switchback Pass. Tight, walled-in and technical. Braking and slides decide the race.

- **Layout:** switchbacks down a canyon wall (a smaller `SB`-style traverse set), then a long **slot canyon** section: narrow and twisting, with rock walls instead of rails, and a road about 60% of normal width. It ends at an old mine yard pit.
- **Carve tuning:** the hairpins sit near level 2's (R ~70 → ~65 u/s). The slot section is a run of **R 50–70 kinks back to back**, so you're either sliding or tucked, never cruising. Every bend in the slot is visible before you reach it (lighting helps: sun shafts from above).
- **Signature moments:**
  1. **The slot:** walls that rise high above you, light shafts, echoing sound (a reverb send on the rolling loop while inside).
  2. **Mine trestle:** a wooden trestle bridge over a side canyon, with grindable rails on its edges (a long grind line), then a tunnel through the rock.
  3. **Shortcut:** an optional ledge gap that skips one switchback, the way hopping a rail does on level 2.
- **Rails:** the switchbacks have them (hop them to ride the canyon wall). In the slot, the walls are the rails: impacts cost speed (`state.atEdge`).
- **New code:** a narrow road width per section (`ROAD_HALF_WIDTH` becomes a function of `u`), and canyon-wall meshes generated from frames, like level 1's gorge walls.

## Level 6: the weird one (pick later)

The reward course, using the stunt physics (`physics: 'stunt'`, level 3 rules) plus one new mechanic. Candidates:

- **A: Mirage / Area 51.** A desert airbase at night where the course leaves the ground: a **UFO tractor beam** section of low gravity (long floaty air for big tricks), a **corkscrew** through a radar dish, and a gravity flip under a hovering mothership. Fits the desert world best.
- **B: Sandworm.** *(Used in level 4 instead, Nov 2026: Mesa Run's giant worm swallows the road and you burst out of its side. A level 6 could still go further: riding its back, a wall-ride tube.)* You ride along the back and *through* a giant burrowing worm (an original design). The course is a **wall-ride tube** inside it. The leviathan code (instanced segments on a path) is reused at a much larger scale.
- **C: Mirror canyon.** A heat-shimmer dream: the course reflects into a copy of itself upside down, and you swap between them through ramps. Uses the level 3 inverted-frame physics.

New mechanics in order of cost: low-gravity zones (cheap) < corkscrew (frames already roll by parallel transport) < wall ride (a new contact mode, the most work).

## Build order

*Progress (Nov 1 2026): steps 1–2 done; step 3 done (world pages, `mesa` schema ids); step 5 first pass done on `feat/mesa-run` (layout, features, procedural desert look standing in for step 4's assets).*

1. Settle free carve and merge `feat/cpu-carve`.
2. Level-descriptor refactor (no behaviour change) → play all 6 variants → merge.
3. Track select with world pages, plus the schema ids for `mesa` / `slot`.
4. Desert world kit (assets, terrain strata, scenery, sky).
5. Level 4, Mesa Run: layout → carve tuning → features → CPUs → night → screenshots.
6. Level 5, Slot Canyon: the same, plus variable road width and the slot walls.
7. Pick the level 6 concept, then build it.

Each step is its own branch, play-tested before merge.

## Open questions

- Names: Mesa Run and Slot Canyon are placeholders.
- Should the Desert world unlock from finishing level 3, or from finishing levels 1–3 in any place?
- Level 6 concept: A, B, C or something else.
- Do carve leaderboards go online now (`*-carve` level ids), since every new course is tuned for carve?
