# Downhill — Release Readiness Plan

Written Sep 29, 2026. Live, editable copy: https://claude.ai/code/artifact/522caa13-32d8-4a79-8597-8b35c1b8fb6f
(this file is a snapshot; keep the two in step when the plan changes).

## Summary

Downhill has a strong, distinctive core but only about 25% of the content of a sellable game. Recommendation: ship a **premium $14.99 game on Steam (Windows, Mac, Steam Deck) on Thursday, May 13, 2027**. Before that, put up a **free web demo** (itch.io, CrazyGames) and show a demo at **Steam Next Fest in February 2027**.

The gap is not graphics. It is **content** (3 tracks → 12), **structure** (1 mode → 5, plus a career that ties them together), **retention** (ghosts, dailies, achievements, a real save) and **release hygiene**:

- Licensed music must go.
- Every sound effect is a placeholder.
- The game needs a title you can search for.
- It needs a desktop wrapper with Steamworks.

Stay on web tech for 1.0. Vampire Survivors (Phaser) and CrossCode (HTML5) both sold millions on Steam as wrapped web games. A Unity port pays off only if a console deal shows up after launch.

The benchmark prices and sales below are from memory and approximate. Check them before quoting them to anyone.

## What exists today

The game is 11 weeks old (first commit July 11, 2026). It is one 6,456-line `index.html`, and its mechanics and spectacle are well past prototype level.

| Area | Current state | Release-ready? |
| --- | --- | --- |
| Tracks | 3 courses (Ridge Run, Switchback Pass, Loop Heights), each with a night version: 6 variants | No: about 25% of target |
| Modes | 1: race against 3 CPUs, scored on time, tricks, air and combo | No |
| Riders | 12 (8 Quaternius models, 3 re-dressed looks, THE OG) | Count yes; stats and cosmetics no |
| Tricks | Ollie, 180s, one grab, revert, 50-50, boardslide, combos | Thin: 8 grind tricks still open |
| Combat | K kick while racing; pit brawl after the finish | Good hook, underused |
| Progression | Track unlocks only (finish opens the next track, 1st opens night) | No: there is no meta-loop |
| Save data | 5 loose localStorage keys (scores, unlocks, rider, name, flow) | No: no versioning, cloud or export |
| Online | Supabase world leaderboard, with a server-side sanity trigger | Partial: can be spoofed |
| Input | Keyboard, mouse, gamepad (stick, triggers, face buttons) | Partial: no rebinding, menu nav unclear |
| Audio | All sound effects synthesized; 10 music tracks (90 MB), some commercially released | No (see Legal) |
| Platforms | Web browser only | No |
| Quality | Adaptive resolution, 60 fps target, a hitch-avoidance discipline | Good foundation; no tests |

## Comparable games

Successful indie downhill and arcade racers launch at $15–$25 with 12–20 courses, 4–6 modes or challenge layers, and a reason to replay every course (ghosts, medals, dailies). All figures are approximate and from memory.

| Game | Launch price | Launch content | What Downhill should take from it |
| --- | --- | --- | --- |
| Lonely Mountains: Downhill (2019) | ~$20 | 4 mountains × 4 trails, per-trail challenges, time-of-day | Per-course challenge lists; a small world count with several routes through each |
| Descenders (2019) | ~$25 | Procedural worlds in ~6 biomes, crew system, online lobbies | A run-based career with stakes; boss jumps |
| Downhill Domination (PS2, 2003) | ~$20 then | ~16 tracks, career, combat, bike upgrades | The closest ancestor: combat racing + career. Also a trademark risk for the name |
| Road Redemption (2017) | ~$20 | Roguelite combat-racing campaign, weapons, 4-player split-screen | Combat as a whole mode; local co-op |
| Trackmania (any) | Free to $30 | Time trials, ghosts, daily and seasonal tracks | Ghosts plus a daily track is the cheapest retention there is |
| Alto's Odyssey | $4.99 mobile | Endless runs, 180 goals, 6 characters | What a mobile version should look like later |
| Tony Hawk's Pro Skater 1+2 | $40 | ~20 levels, 2-minute goal runs, create-a-skater | The trick-attack mode and goal lists |

What's common: **a career that paces unlocks**, **medal times per course**, **ghost racing**, **cosmetic unlocks** and **a controller-first UI**. Downhill has none of these yet.

## Content: exact launch targets

**12 courses: 4 worlds × 3 courses.** With night versions that's 24 variants, and with mirrored versions 48 races. This matches Lonely Mountains' 16 trails at a slightly lower price. It gives about 5–8 hours to finish the career and far more to master it. That's the bar for $14.99 if you want to avoid "too short" reviews.

| Item | Today | Launch | Notes |
| --- | --- | --- | --- |
| Worlds (biomes) | 1.5 (alpine ridge + sky course) | 4 | e.g. Alpine (have), Desert Canyon, Coastal City (streets, stairs, traffic), Cosmic/Nightmare (Loop Heights' home) |
| Courses | 3 | 12 | 3 per world: a flowing one, a technical one (hairpins), a stunt one (loops, gaps). Reuse terrain and scenery within a world |
| Night versions | 3 | 12 | Nearly free per course once the lamp and sky systems exist |
| Mirror mode | 0 | All 12 | Cheap: flip the spline. Unlock after the career |
| Riders | 12 | 16 | 12 at start + 4 unlockable originals (the lizard, clown, reaper and slasher ideas, as original designs) |
| Boards (decks) | 1 | 20 | Deck art is just textures; add wheels/trucks colors (8 each) |
| Outfits and colors per rider | 1 | 3–4 | The `LOOKS` recolor system already does this |
| Tricks | ~8 | 25 | 8 grinds (already listed), 6 grabs, 4 flips, manuals, 2 no-comply/slide tricks |
| Achievements | 0 | 40 | Steam and Deck expect them; cheap to add |
| Music tracks | 7 active (not cleared) | 15–20 cleared | See Audio |

Don't add a 4th level before the **free-steering road** change in the roadmap. Every course built on track-locked physics will need to be re-tuned after that change.

## Game modes: ship 5, add 2 after launch

The race already scores tricks, air and combos. Most new modes are new rules over the same run, not new systems.

| # | Mode | What it is | Why | Cost |
| --- | --- | --- | --- | --- |
| 1 | **Career ("Tour")** | 4 cups (one per world) × 3 races + a final. Points by place; each race has 3 side goals (score X, air Y, knock out Z). Stars unlock worlds, riders and boards | The spine of the game: without it, content is a menu, not a journey | High |
| 2 | **Quick Race** | Today's mode: any unlocked course vs 3 CPUs, with difficulty Easy/Normal/Hard | Exists | Low |
| 3 | **Time Trial + ghosts** | Solo run with bronze/silver/gold/dev medal times. Race your best ghost, a friend's, or the world #1's ghost pulled from Supabase | Top retention driver for the genre; also real anti-cheat (you can replay a ghost to validate it) | Medium |
| 4 | **Trick Attack** | A 2-minute score run on a course section (THPS style) with course-specific goals: hidden letters, named gaps, a rail line | Uses the trick system you've built; makes tracks feel like levels | Medium |
| 5 | **Brawl Race** | Road Rash rules: 6 riders, weapon pickups, knockouts score, last place each lap eliminated | Your most distinctive hook (kicks, pit brawl, weapons ideas); nobody else in skate games does it | Medium |
| + | **Daily Descent** (at launch if time allows) | One seeded course and modifier a day (moon gravity, big heads), one attempt counts, global board | Cheap on Supabase; brings people back every day | Low |
| + | **Free Ride** (post-launch) | No timer, whole mountain open, collectibles | Relaxed play; you already have free-riding | Low |

The cheat-code ideas fit as **modifiers**. Unlock them in the career; runs that use them go to a separate board, as already planned.

## Progression and save data

**Yes, a real save is required.** Today, clearing browser data wipes all progress, and nothing syncs between machines.

1. **One versioned save object** (`{version, profile, career, unlocks, cosmetics, bests, ghosts, settings, stats}`), written through one `save()` with a migration step per version. Keep localStorage for the web demo, but write to a file on desktop.
2. **Steam Cloud** sync of that file (free with Steamworks). Keep 3 rolling backups and recover from a corrupt save.
3. **Settings saved separately** from progress, so "reset progress" doesn't also reset graphics and controls.
4. **Currency** ("Stoke") earned by every race, even a last place, and spent on boards, outfits and colors. This gives a losing run value, which is what keeps players going.
5. **Medals and stars per course**: 3 career goals plus 4 time medals. The unlocks table reads from these instead of hand-coded rules.
6. **Lifetime stats page**: distance, air, knockouts, bails. Mostly already tracked per run.
7. **Rider stats: skip them.** Stats make players pick the best rider instead of the one they like, and they complicate balance and leaderboards. Keep riders cosmetic.

No in-app purchases in a premium game: sell cosmetics only as a later DLC pack, if at all. The photo-on-your-board idea is a good, privacy-safe free feature.

## Multiplayer

**Ship local 2-player split-screen and asynchronous ghosts at launch. Hold off on real-time online.**

| Kind | Launch? | Why |
| --- | --- | --- |
| Async ghosts + leaderboards | Yes | Almost all the social value of online at a fraction of the cost. Supabase already carries it. Store ghosts as compressed input or pose samples |
| Local split-screen, 2 players | Yes | Steam **Remote Play Together** turns local multiplayer into online play with friends, free. Couch play also fits Brawl Race. Costs: 2 viewports rendered, so the budget per view drops. Ship a lower-detail split-screen preset |
| 4-player split-screen | Post-launch | Road Redemption did it; the performance cost is real in WebGL |
| Real-time online racing | Post-launch, only if sales justify it | Needs netcode, relay servers, matchmaking, anti-cheat and moderation. Several months of work plus ongoing server bills. For a small indie game, lobbies go empty within weeks |

Recommended order: ghosts → split-screen → (after launch) online private lobbies through Steam networking, with no public matchmaking.

## Platforms

**Launch on Steam (Windows + macOS + Steam Deck). Use the web as the demo and marketing funnel. Mobile and consoles come after launch.**

| Platform | When | What it takes |
| --- | --- | --- |
| Steam: Windows, macOS | 1.0 | Wrap in Electron (or Tauri) with `steamworks.js` for achievements, cloud saves and overlay. Ship the audio and assets locally. Sign and notarize the Mac build. $100 app fee |
| Steam Deck | 1.0 | Aim for "Verified": full controller UI, readable text at 1280×800, no keyboard-only prompts, a 30/60 fps preset. This is where many racing players are |
| Web demo | Feb 2027 | Courses 1–2 only, with a "Wishlist on Steam" button. itch.io + CrazyGames/Poki (portals pay ad revenue share and drive traffic). The current build is nearly this already |
| Mobile (iOS/Android) | Post-launch, 2028 at earliest | A different product: touch controls (thumb zones or tilt), 30 fps on mid-range phones, short sessions, likely $4.99 premium like Alto's. WebGL in a WebView works but the port needs a perf pass. Don't let it shape 1.0 |
| Consoles (Switch 2, PlayStation, Xbox) | Post-launch, if 1.0 sells | Realistically needs a Unity port or a porting partner, plus dev kits and certification. That's when the "mechanics transfer 1:1 to Unity" plan pays off |

## Graphics, audio and feel

**Graphics don't need to be better; they need to be consistent.** Low-poly Quaternius characters stand on photo-scanned PBR asphalt under a real HDRI sky. That mix of styles is the thing that reads as "asset flip" in screenshots. Pick one art direction and push it across the game.

- **Art direction:** stylized (flat and gradient shading, hand-tuned palettes per world, outlines optional). This is cheaper, runs faster on Deck and mobile, ages well, and matches the characters. Write a one-page style guide.
- **Signature visuals per world:** each world needs its own "trailer shot", like the leviathan loop and the whale bridge. Plan one per course.
- **Character animation:** procedural posing is fine for riding. Missing: a ragdoll or authored crash tumble, get-on/off-board, a podium and celebration, and idle fidgets on the grid.
- **UI and menus:** a proper UI art pass with one font family, iconography, controller button glyphs (Xbox/PS/Deck), transitions and menu sounds. The menus are what reviewers see first.
- **Game feel:** hit-stop on kicks and knockouts, camera shake on landings, controller rumble, and a speed-lines and wind audio layer. These are cheap and give a big lift.
- **Audio (a release blocker):** replace all ~18 synthesized placeholder sounds with recorded ones (the list already exists in `ROADMAP.md`). Add wind, board clack and crowd reactions. Budget: CC0 or a sound library at $0–$300, or a freelance sound designer at ~$1,500–$3,000.
- **Music (a release blocker):** replace all of it with 15–20 cleared tracks. Options: commission 1–2 artists, license from indie labels, or use a buyout library. Offer an in-game radio "streamer-safe" toggle.

## Technical, legal and QA

### Legal (fix these first; each one can get the game pulled)

- **Music:** the playlist includes "Move That Dope" (Future), "No Heart" (21 Savage & Metro Boomin) and "Incredible" (M.Beat feat. General Levy). These are commercially released tracks. Even a free public web build can draw DMCA takedowns. Remove them from the public build now, and clear every other track in writing.
- **Name:** "Downhill" can't be found in a store search. The repo name echoes *Downhill Domination* (Sony/Incognito, 2003), which is a trademark risk. Pick a distinctive title and run a USPTO/EUIPO search before the Steam page goes up.
- **Characters:** the unlockable-rider wishlist (Godzilla, Pennywise, LeBron, and others) must become original designs, as the roadmap already notes.
- **Assets:** the CC0 models and textures are fine. Keep `CREDITS.md` complete and add the font licences.
- **Privacy:** the world board stores initials and Supabase sees IP addresses. You need a privacy policy, plus a EULA or terms page.
- **Age rating:** Steam uses a content survey. The pit brawl, knockouts and gore ideas (exploding spectators) push the rating up. Decide the tone before marketing.
- **Business:** form an LLC before taking revenue, and fill in the Steam tax and bank forms (they take weeks to process).

### Technical

- **Code structure:** one 6,456-line file will slow down 4× the content. Split it into ES modules with no build step (import maps already work): `track/`, `physics/`, `rider/`, `ui/`, `modes/`, `save/`.
- **Courses as data:** move each course into its own module or JSON (spline recipe, features, scenery, medal times), so adding a course doesn't mean touching the physics.
- **Input:** full key and pad rebinding, menu navigation by controller everywhere, button glyphs that switch with the device, rumble.
- **Settings:** graphics presets (Low/Medium/High/Deck), resolution scale, fps cap, FOV, motion blur, camera shake, and a toggle for the chromatic aberration, bloom and grain effects. Separate music, SFX and crowd volumes.
- **Accessibility:** colorblind-safe UI, text size, hold-vs-toggle for tuck and brake, reduced flashing (chaos modes and strobes need a photosensitivity warning and a toggle).
- **Localization:** English + French, Italian, German, Spanish (EFIGS) + Simplified Chinese + Brazilian Portuguese at launch. Chinese-speaking players are a large share of Steam. Pull all UI strings into one table now.
- **Leaderboard integrity:** move from "sanity trigger" to ghost-validated submissions for the top 100.
- **Telemetry (opt-in):** where people quit, which courses they restart, crash reports. Also needed to tune difficulty.
- **Performance:** a Deck and integrated-GPU budget, a load-time budget (90 MB of audio today; stream it), no hitches on a fresh install.

### QA

There are no automated tests today. Before launch:

- Headless physics regression tests: seeded runs that must finish within a time tolerance.
- A save-migration test.
- A closed playtest of 30–50 people in December–January (Steam Playtest is free).
- A full platform pass on Windows (NVIDIA, AMD, Intel), macOS and Deck.

## Release method and pricing

**A self-published, premium 1.0 on Steam at $14.99, with a 15% launch discount. Put the free web demo out early to build wishlists.**

- **Why not Early Access:** an arcade racer is judged on content count, and players read Early Access as "unfinished". You also get only one launch spike in Steam's algorithm. Use a Steam Playtest and the demo for feedback instead.
- **Why not free-to-play:** F2P needs live-ops, a monetization design and a large audience. None of that suits a solo developer.
- **Why $14.99:** below Lonely Mountains and Descenders (about $20–$25) because of fewer courses. At $9.99, reviewers read the game as a toy. You can go to $19.99 if the career plus Brawl Race land well.
- **Wishlists:** a common industry rule of thumb is ~7,000+ wishlists at launch to reach Steam's "Popular Upcoming" list. Treat this as the go/no-go signal for the date.
- **Marketing that fits this game:** 15–30 second vertical clips on TikTok, YouTube Shorts and Reddit (r/longboarding, r/indiegaming, r/WebGames). The leviathan loop, whale over the bridge, kicking racers and crowd brawls are ready-made clips. Also a 60-second trailer, a press kit, and outreach to 100 small and mid-sized streamers and curators with keys 2 weeks before launch.
- **Events:** Steam Next Fest (February 2027) with the demo. Apply to 2–3 digital showcases (e.g. indie-focused ones) and Steam sports and racing themed sales.
- **Publisher?** Optional. Publishers like No More Robots (Descenders) sign this genre. A deal would trade 30–50% of revenue for marketing and porting. Pitch after the demo has numbers.

## Revenue: first 12 months

**Central estimate: $10k–$30k net in year one. Plan around $5k.** These are industry rules of thumb, not researched data. Around half of Steam games earn under a few thousand dollars in their lifetime.

**You keep about $6.50 per copy.** The $14.99 price shrinks after discounts, regional pricing, refunds (~8%), VAT and Steam's 30%. Income tax comes on top.

| Outcome | Wishlists at launch | Copies in year 1 | Net to you |
| --- | --- | --- | --- |
| Worst case: no marketing at all | 0–300 | 10–150 | $65–$1,000, so a net loss after costs |
| Flop | under 2,000 | 200–800 | $1k–$5k |
| **Likely:** a first solo game with steady marketing | 2,000–7,000 | 1,000–4,000 | **$6k–$26k** |
| Good: Popular Upcoming, a few viral clips | 7,000–20,000 | 5,000–15,000 | $30k–$100k |
| Breakout: a clip blows up, big streamers pick it up | 50,000+ | 50,000–200,000 | $300k–$1.3M |

- **Rule of thumb:** year-one copies ≈ 0.3–0.7 × wishlists at launch. Wishlists are the number to watch from the day the Steam page goes up.
- **Unmarketed, Steam won't find you.** Around 40 games launch on Steam every day. With no wishlists, you get a day or two on the new-releases list and then disappear. Most of the copies in that row would be friends and family.
- **Costs:** about $3k–$8k in total, covering the Steam fee ($100, refunded after $1,000 in sales), cleared music plus sound effects, capsule art and an LLC. The worst case loses roughly that amount. The upside: 11 weeks of work already exists, and there's no debt.
- **Web demo ads** on CrazyGames or Poki add a few hundred to a couple of thousand dollars.

## Timeline: target Thursday, May 13, 2027

| Milestone | Dates |
| --- | --- |
| Foundation work | Oct 1 – Nov 30, 2026 |
| Steam page live | Nov 30, 2026 |
| Modes + 9 new courses | Nov 15, 2026 – Mar 15, 2027 |
| Closed playtest | Dec 15, 2026 – Jan 31, 2027 |
| Next Fest demo (dates are estimates until Valve confirms) | Feb 22 – Mar 1, 2027 |
| Content lock | Mar 15, 2027 |
| Polish, audio, languages | Mar 1 – Apr 29, 2027 |
| Release candidate | Apr 29, 2027 |
| **Launch, $14.99** | **May 13, 2027** |

The Steam page has to be live by November 30 to collect about 5 months of wishlists. Content lock on March 15 leaves 8 weeks for polish. If wishlists are under ~7,000 at Next Fest, or content lock slips, move launch to the week after Steam Next Fest in June 2027. Don't cut the career or Time Trial to hold the date.

## Release checklist

The must-haves for 1.0 on May 13, 2027, in rough build order. Anything not listed here is post-launch.

**Now (October 2026)**

- [ ] Pull the commercial tracks from the public build
- [ ] Choose a final title and run a trademark search
- [ ] Commit to an art direction and write a one-page style guide
- [ ] Split `index.html` into modules; courses as data
- [ ] Free steering on the road (the roadmap's biggest mechanics change)

**Foundation (Oct–Nov)**

- [ ] Versioned save system + settings file
- [ ] Full controller UI, rebinding, button glyphs
- [ ] Electron + Steamworks shell running on Windows, Mac and Deck
- [ ] Steam page live with capsule art, 5 screenshots and a teaser (by Nov 30)

**Content and modes (Nov–Mar)**

- [ ] Time Trial + ghosts + medal times
- [ ] Career ("Tour") with currency and unlocks
- [ ] Trick Attack; Brawl Race
- [ ] Worlds 2, 3 and 4 (9 new courses) + their night versions + mirror mode
- [ ] 2-player split-screen
- [ ] 4 unlockable original riders, 20 boards, outfits
- [ ] 17 more tricks (grinds, grabs, flips, manuals)
- [ ] Daily Descent (stretch goal)

**Polish and release (Mar–May)**

- [ ] All sound effects recorded; 15–20 cleared music tracks
- [ ] UI art pass, crash animation, game-feel pass
- [ ] 40 achievements, Steam Cloud, lifetime stats
- [ ] Settings, accessibility, photosensitivity warning
- [ ] Localization (7 languages)
- [ ] Ghost-validated leaderboards; opt-in telemetry
- [ ] Privacy policy, EULA, age-rating survey, LLC, Steam tax forms
- [ ] Trailer, press kit, key outreach
- [ ] Release candidate on Deck "Verified" review
