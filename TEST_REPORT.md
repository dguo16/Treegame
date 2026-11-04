# Salvage verification November 2 2026

Schema 11. All **15 suites pass, 15,374 assertions**, plus **40 client checks** for **15,414 total**. No persistent player profile, live purchase or published game was changed.

| Suite | Pass count |
|---|---:|
| Progression | 39 |
| Acceptance | 455 |
| StudioChecks | 186 |
| CommerceChecks | 338 |
| AuthoredAssets | 10866 |
| SalvageChecks | 168 |
| FruitChecks | 104 |
| RollPresentation | 635 |
| Balance | 458 |
| SaveFaults | 22 |
| CollectionChecks | 157 |
| AdminSecurity | 125 |
| RoadmapPhase1 | 77 |
| StandardAssets | 1708 |
| WorldUX | 36 |

SalvageChecks: 168. StudioChecks: 186, including 39 live salvage and 35 live fruit checks. Forty additional client checks cover locked controls, location tags, actual recovery and desktop/phone portrait/landscape touch visibility. The actual phone click left 12 inventory parts and reduced locks 12 → 8 while removing plot 1. Final console is clean except the expected isolated-memory preview notice and pre-existing Hello world messages.

Migration fixtures: 4 matched / 4 ambiguous / 4 missing / 4 starter (4 reserved), plus 3 matched / 1 ambiguous for an ID-less snapshot. Extra cases verify tree-ID collision avoidance, idempotence and preservation of legacy over-cap custody. Fake backend tests cover errors before write, ambiguous errors after commit, disconnect and interrupted/cancelled mutation; uncertain writes close the session.

126 before and 126 final policy runs (21 seeds × six policies), three Ascensions each; all final seeds reach all three. Independent 256-seed tier audit and retained tuning evidence are in salvage/. Balanced A1 3.89 h, P90 5.26 h, second run 2.42 h, 62.2%; all active-policy A1 P90s under 8 h. 300-roll median 103.60 minutes misses the older target. See SALVAGE_REPORT.md for every table and limitations.

73 maintained sources match Studio at final verification; all 208 prior geometry records are unchanged. Both XML assets and protected odds/fruit/purchase modules retain their hashes. The 28-page handbook is rendered/inspected. Temporary runner and memory attribute are removed after testing; Studio ends in Edit/default viewport, HTTP/API off. No publish, activation, commit or push. Real backend/receipts, physical devices and multiplayer remain separate release checks.

## Historical verification below

# Rare and Epic asset verification November 2 2026

Schema 10 applies 24 authored Rare/Epic models and migrates Blueberry→Crystalberry and Blackberry→Hazelfruit while preserving tier/variant identities. All **14 suites pass (15,167 assertions)**, plus **25 live server feedback** and **28 client checks**, for **15,220 checks including the additional checks**. Three further StudioChecks runs pass at 147 checks each and are excluded from that headline total. All 80 new MeshIds fetched successfully.

The new AuthoredAssets suite passes 10,866 checks: all 1,728 completed-tier root/trunk/crown combinations, shared joins and fruit offsets, mutation recoloring and botanical accents, every new named part, all new Giant harvest variants, stable old/new collection keys, schema-9 migration through ownership/equipment/production/all growth pads/queues/pending snapshots/Bag/Vault/Fruit Index/biggest records, preserved values/times/claims, and idempotence. Existing balance, purchase/receipt, authority, save-fault, fruit/Vault and rolling suites pass.

The prior procedural-accent fixture now checks authored Rare/Epic models; the original bounded procedural expectations remain for Legendary–Godly. The procedural harvest fixture uses Legendary Starfruit since Epic Plum is now authored. A floating-point attachment assertion was adjusted to the existing geometry tolerance; runtime values were not changed to satisfy it.

Studio inspection covered all 24 standalone models, Rare/Epic assembled trees and mixed earlier-tier trees, the cut Passionfruit, and fruit visibility under all six new crowns. The source surface socket heights hid fruit inside opaque Epic crowns; runtime heights for the new six canopies cap at 0.4 while retaining source X/Z and fruit offsets. Original contracts remain archived. Import rotation and sRGB colors were corrected and checked against source bounds.

All 66 initial scripts matched disk; all 69 final scripts match. All 104 original geometry records are unchanged. The final model set is 48 Models/137 MeshParts, including 24 new Models/80 meshes. All 24 old model XML elements are unchanged; StarterTreeEditor is byte-identical. Config differs only in schema, two catalog names and a comment, preserving prices, odds, value math, mutation ceiling, purchase IDs and disabled flags.

The 27-page handbook was rendered with background Word/Poppler. Five changed pages were inspected; the other 22 PNGs match the prior inspected render byte-for-byte. README, PART_CATALOG, ROADMAP_STATUS, TEST_RESULTS and ASSET_REPORT are updated; source asset packs, mapping, IDs and preservation evidence are in asset-sources/standardized and asset-validation. Supplied generation scripts were not run.

All Play checks used isolated memory-only profiles with HTTP/API access off. Mesh assets uploaded to the same Roblox owner as the experience; no game publish or purchase activation occurred. Studio ends in Edit/default viewport with test attribute/runners/fixtures removed. Real backend, published-client permissions, physical devices and multiplayer performance remain release checks.

## Historical rolling verification

# Vertical rolling verification November 2 2026

Schema remains 9; this is a presentation update. All **13 suites pass (4,301 checks)**. Additional live server feedback checks pass (25) and client presentation checks pass (28), for **4,354 checks including the additional server/client checks**. StudioChecks also passed three additional consecutive runs of 147 checks each, excluded from that headline total.

The new 635-check RollPresentation suite verifies exact name/mutation odds under ordinary and guaranteed rolls, 310 seeded outcome comparisons, no metadata RNG consumption, unchanged pity progression, complete bounded batch history and correct best-of-batch choice. The extra server checks verify all ten production awards and feedback identities, third-roll guarantee, original cooldown and no stored odds fields. Client checks exercise queued five/ten batches, hidden/skip/reduced-effects behavior, every result preview/odds, ten-row pagination and no forced inventory opening. Reproducible integration scripts and JSON results are in rolling/.

Desktop and iPhone 17 Pro simulated portrait/landscape reel and summary screens were inspected. All visible tested text fits; safe-area resize timing, compact landscape layout, touch overlap and ready-tree notice placement were corrected. Sensor orientation, CoreUISafeInsets and clipping remain. Real devices and multiplayer load are not certified.

All 63 initial maintained sources matched Studio before changes. All 66 final sources match disk; 104 geometry records remain identical, including lowered Clover. Config is byte-identical, protecting prices, odds, cooldown, Marketplace IDs and existing flags. Profile schema, purchase/receipt behavior and server intent schemas are unchanged.

The handbook remains 27 rendered pages: pages 1/4 updated and inspected, other 25 PNGs byte-identical to the previously inspected version. Background Word/Poppler rendering was reused because the bundled LibreOffice renderer was unavailable in the prior task. README, ROADMAP_STATUS, TEST_RESULTS and ROLLING_REPORT are updated. Final source/project copies and ZIP contents are verified.

All Play checks used explicitly isolated memory-only profiles. Studio ends in Edit/default viewport, HTTP off, temporary runners/test attribute removed. No publishing, commit, push or purchase activation occurred. Real backend/save contention, live receipts, physical devices and multiplayer/load remain release checks.

## Historical fruit revision verification

# Fruit revision verification November 1 2026

Profile schema 9. This section supersedes current-state statements in the historical reports below.

All 12 suites pass: **3,666 assertions**. StudioChecks passed three additional consecutive runs, 147 checks each. Final fresh Play explicitly forced a memory-only profile; the test attribute and temporary runner were removed afterward. The live test harness now refuses persistent profiles. See TEST_RESULTS.json and fruit/final-tests.json.

| Suite | Checks |
|---|---:|
| Progression | 39 |
| Acceptance | 455 |
| StudioChecks | 147 |
| CommerceChecks | 338 |
| FruitChecks | 104 |
| Balance | 458 |
| SaveFaults | 22 |
| CollectionChecks | 157 |
| AdminSecurity | 125 |
| RoadmapPhase1 | 77 |
| StandardAssets | 1708 |
| WorldUX | 36 |

FruitChecks and live FruitIntegration cover partial/current/stale/future sales, new arrivals during selection, exact schemas and forged amounts, payload bounds, cooldowns, all Vault exclusions, capacity and full-bag unlock refusal, quantity counters, schema-8 idempotent migration, stable IDs/unknown timestamps/conserved values, stack blending, Ascension retention, exact size expectation and independent sampling, imported/procedural scaling, welded tween anchors, recycle cleanup, Giant cooldown and safe six-fruit shelf placement.

The size expected value is exactly 1. All 63 paired seeds reached first Ascension. Before/after medians: 3.9367 / 3.9767 hours (+1.016%); means: 4.0131 / 4.0308 (+0.440%); P90: 4.7567 / 4.6367. Raw results and reproducible calls are in fruit/ and FRUIT_REPORT.md. The 12-second manual Sell All policy excludes real panel/travel time, pets, events, paid/private bonuses and Vault banking.

Desktop and simulated iPhone 17 Pro landscape (750x381) and portrait (401x778) Sell screens were inspected. A clipped portrait estimate was corrected and rechecked: all visible Sell text fits, including the coin estimate, with touch controls hidden. Vault and Fruit Index were inspected on desktop/portrait. The six-fruit shelf was inspected; fixtures remain cosmetic and non-colliding. Imported/procedural Giant bounds are checked against the unchanged center-based collection radius; the HUD bag-full arrow remains separate. Parent-Sound preload verified the bundled Giant ping loaded at 0.72 seconds. Harness-only inspection mistakes were corrected; the final fresh suite run passed without gameplay errors.

Before edits, 57 maintained Lua sources matched disk. Final count is 63 and all normalized source hashes match Studio. All 104 geometry records match both the starting Studio snapshot and disk, preserving lowered Clover and assembly contract. Protected Config comparison, after excluding only schema/size/Vault/Giant-sound additions and newline normalization, is identical: no price, existing odds, Marketplace ID or mutation-cap changes.

The 27-page handbook was rendered with background Word and bundled Poppler after the packaged LibreOffice renderer proved unavailable. Every page was inspected; final edited pages were re-rendered and rechecked. README, TEST_RESULTS, ROADMAP_STATUS, FRUIT_REPORT and the packaged handbook are updated. Historical balance/collection/commerce evidence remains included.

Current connected PlaceId is 122763473283486, GameId 10774301287. This is no longer an unnamed zero-ID place; visibility was not changed or inferred. API access was off. Temporary runner/test attribute/fixtures were removed, and Studio ends in Edit/default viewport with HTTP off. No publishing, commit, push or purchase activation occurred. Real backend save/rejoin/session contention, live receipts, cross-server data, physical devices and multiplayer load remain release checks.

## Historical schema 8 purchase verification

# Draft purchase revision verification November 1 2026

Profile schema 8. **3,526 checks pass across all eleven suites** in the final fresh Play session. Pure/service modules ran through normal server Scripts. StudioChecks additionally passed three consecutive repeated runs with no failures after the canopy fixture correction. All Marketplace IDs/live prices are zero, every catalog item is Draft=true and purchase enable flags remain false. No real purchase or publishing occurred.

| Suite | Passed |
|---|---:|
| Progression | 39 |
| Acceptance | 455 |
| StudioChecks | 111 |
| CommerceChecks | 338 |
| Balance | 458 |
| SaveFaults | 22 |
| CollectionChecks | 157 |
| AdminSecurity | 125 |
| RoadmapPhase1 | 77 |
| StandardAssets | 1708 |
| WorldUX | 36 |
| Total | 3526 |

CommerceChecks has 338 assertions against the production PurchaseService and DataService factories with a fake Marketplace/backend: each product request, duplicate receipt, restriction, cancellation and draft kill switch; each pass request, cancel, verified ownership, duplicate callback, restriction and earned-Ascension persistence; all-item spending budgets; locked reference-income quotes/caps; Starter one-per-account and historical consumption; migration; three-pad immutable identity/queue/placement/credits/offline/weather; eight featured cosmetics/ownership/free alternatives; and exact prospective luck. SaveFaults retains session ownership, retry/reentry, throw isolation and no speculative reward exposure coverage.

Acceptance is four assertions lower than schema 7 because the two removed products no longer run their two generic receipt-grant checks. Progression is one lower because the retired Mutation Luck offer is no longer in its five-item draft list. CollectionChecks adds schema-7 migration coverage. StudioChecks grows from 94 to 111 with actual ninth-pad ownership, rendering, queue bound, placement capability, FIFO pump, retired-route rejection and seven-part Pinwheel/equip/unequip checks. No valid gameplay assertion was weakened.

A pre-existing intermittent canopy check compared the full tree bounds against a foliage-only Clover reference, so a random rolled fruit could protrude above that reference. It now measures the declared foliage component using ImportedModels.Definition and its Asset mapping, retaining the same geometry expectation/tolerance. The edited source model was not changed to satisfy the test.

All 21 production-simulator Balanced seeds reached the third Ascension within 12 active hours: first median 4.01 h; third median 8.73 h, P90 9.26. These timings exclude pets, events, paid/private perks, travel and actual human behavior. Raw results and every pass/product proposal are in commerce/ and MONETIZATION_REPORT.md.

Initial comparison found all 55 maintained Lua sources matching Studio and 104 editable/imported geometry records matching disk. Final maintained Lua count is 57. The manually lowered Clover and assembly contract remain. Final Studio/source/canonical/ZIP checks are recorded at packaging. Desktop and iPhone 17 Pro landscape (750x381) and portrait (401x778) Passes layouts were inspected: square tiles, readable exact effects, draft/zero-ID text, no clipped tile text, hidden overlapping touch controls and panel above HUD. Odds and Journal Style were inspected; More remains compact with no extra tile. Sensor orientation, CoreUISafeInsets HUD clipping and None topbar clipping are retained. These are simulated UI checks, not physical-device certification.

The handbook has 25 rendered, inspected pages. The bundled LibreOffice renderer was unavailable; background Word export and bundled Poppler supplied the render. A blank page and connector-exported catalog symbol encoding were corrected and rechecked. README, TEST_RESULTS, draft catalog, handbook, local project copies and ZIP are updated. Studio ends in Edit/default viewport, HTTP off. Nothing was committed, pushed or published. Real backend, live receipts/regional prices, physical devices and multiplayer remain release checks.

## Historical collection verification

# Collection and feature verification November 1 2026

Schema 7. **3,170 checks passed** in a fresh isolated Play session. All existing suites and the new CollectionChecks ran through normal server Scripts; StudioChecks invoked actual running services after readiness and passed three consecutive runs. No test or game runtime errors remain in the final session. The two pre-existing Workspace hello messages and memory-only preview warning are expected.

| Suite | Passed |
|---|---:|
| Acceptance | 459 |
| AdminSecurity | 125 |
| WorldUX | 36 |
| StandardAssets | 1708 |
| RoadmapPhase1 | 77 |
| Progression | 40 |
| SaveFaults | 22 |
| Balance | 458 |
| CollectionChecks | 151 |
| StudioChecks | 94 |
| Total | 3170 |

Acceptance is two assertions lower than schema 6 because the removed Shield product no longer runs the two per-product receipt-grant assertions; no remaining product coverage was removed. New collection/service assertions cover the replacement behavior.

Coverage includes valid/invalid discovery identities, any-mutation name deduplication, schemas 3–6 migration and idempotence, archived legacy payouts/no replay, partial set targets, core reward caps, actual value/luck/slot effects, no mutation/egg changes, Ascension retention, optional cosmetic-only tail, medal prices/duplicates/insufficient funds, cosmetic ownership and slot checks, received-like milestones, self/UTC-like limits, bounded non-colliding decorations/auras, all named event durations, both-pad Windstorm rates, fruit capacity, delayed deadline settlement, offline standing rates, removed Shield product and Chill-on purchase rejection. Event unit fixtures are isolated, and integration restores profiles, runtime, event state, geometry and temporary fruit even after failures.

Independent math covers every one of 41 sets, all four luck scenarios and the optional 420 tail. The real RollEngine/pity check ran 128 seeds for each luck (512 samples), all completing the core names. The final 21-seed collection-aware active economy run includes earned coin/luck bonuses and automatic claims. See COLLECTION_REPORT.md and collection/ for raw evidence. These measurements are separate from assertion counts.

All 55 final maintained Lua sources are compared with Studio at packaging. Initial comparison found all 51 existing sources matching; 104 editable/imported geometry records also matched. The preserved lowered Clover canopy and source assembly assets are unchanged. Desktop and iPhone 17 Pro landscape Index/Medals/Sabotage screens were inspected; the next-closest hint was moved near the top for short screens. HUD uses CoreUISafeInsets with clipping and GardenTopbar uses None with clipping, under Sensor orientation. Physical devices and broader multiplayer remain unverified. Studio returns to Edit and the default viewport after review.

The updated handbook has 23 rendered, inspected pages. README, source, canonical copy and ZIP include schema 7 and the collection report. Purchases remain disabled, HTTP remains off, and the place remains unpublished memory-only. Real saves/rejoins, receipts, cross-server data, physical devices and full-player load remain release checks.

## Historical balance verification

# Balance revision verification November 1 2026

Profile schema 6. The final isolated fresh Play session passed **2,994 checks**. Tests ran through normal server Scripts and StudioChecks used the actual running service harness after readiness. The session was stopped after the final UI review. No game runtime errors appeared in the final clean session; the memory-only preview warning and two pre-existing Workspace hello messages are expected.

| Suite | Passed |
|---|---:|
| Acceptance | 461 |
| AdminSecurity | 125 |
| WorldUX | 36 |
| StandardAssets | 1708 |
| RoadmapPhase1 | 77 |
| Progression | 40 |
| SaveFaults | 22 |
| Balance | 458 |
| StudioChecks | 67 |
| Total | 2994 |

Balance covers rarity power and 2–3× full-tier income jumps, all slot improvements, multiplicative Leaf Power, Root cadence/floor, mixed-build growth, combined mutation ceiling, price continuity/caps/huge counters, 300-roll spending, rising thresholds/overflow, legacy schemas 3/4/5, unchanged identities/mutations/bought levels/Saplings/claims, retained in-flight durations, reward reference exclusions and weak swaps, expiry, claim-time amounts, static floors, every daily/milestone step, reward caps, replay rejection, actual wallet deltas, bounded audit storage, save roundtrip and Ascension retention. Existing acceptance/security/asset/service checks still pass.

The corrected simulator was measured before economy changes, then after tuning. Each version has 21 seeds for each of three active and three casual policies (126 runs per version), through up to five Ascensions. All final seeds reached every reported milestone. See ECONOMY_REPORT.md and balance/before.json, balance/after.json, balance/Config.json. Primary active results: 300 rolls 61.9 min; first Ascension 3.84 h; P90 4.68 h; second run 2.33 h. Casual first reset is 1.33 elapsed days, missing the several-day aspiration; RollFocused active first reset is 6.33 h. These limits are retained, not hidden by claiming every policy met every target.

Before overwriting source, all maintained Lua containers matched disk and 104 editable/imported geometry records were compared with no differences. The lowered Clover reference and assembly metadata are preserved. Desktop HUD baseline label, Leaf Power ×1→×2/25-coin tile, exact mutation Odds with cap, and Journal live scaled amounts were inspected. The updated 21-page handbook was rendered and every page reviewed.

No Marketplace, sabotage, Index reward/odds, pet, event, plot-price or offline-limit retune was made. New purchases stay disabled. This is still unpublished memory-only Studio evidence, not real DataStore/rejoin, receipts, multiplayer, physical devices, movement/retention validation or release readiness. Final source/ZIP verification is recorded by the packaging manifest.

## Historical verification before this balance revision

# Latest verification — November 1, 2026

This section supersedes historical counts and empty-only placement notes below. All tests ran in an isolated memory-only Studio server Play session. The session was stopped afterward. There were no game runtime errors in the final console; the memory-only preview warning is expected.

| Suite | Passed |
|---|---:|
| Acceptance | 461 |
| AdminSecurity | 125 |
| WorldUX | 36 |
| StandardAssets | 1,708 |
| RoadmapPhase1 | 77 |
| Progression | 40 |
| SaveFaults | 22 |
| Live Integration | 67 |
| Total | 2,536 |

Replacement coverage includes confirmation, capability expiry, target/tree changes, 500-slot boundaries, equipped/already-held IDs, free starter identities, concurrent/replayed confirmations, sampled height, actual owned-plot placement and plot-specific fruit cleanup. Growth coverage includes both pads, first-Ascension/ExtraPlots unlocks, bounded FIFO snapshots, cancellation by immutable ID, offline settlement, schema migration and receipt tree binding. Progression covers the 420-entry index, timestamps, daily resets, no missed-day punishment, claim replay protection, early rarity guarantee, effective mutation odds and staged entitlements. SaveFaults uses the production DataService with an injected deterministic backend; it covers ambiguous failures, fresh ownership on retries and callback reentry, no speculative grants, exceptions releasing busy state, duplicates and release. It does not call real DataStores or prove real receipt delivery.

The lowered Clover workbench foliage was preserved and exported. Geometry checks now derive customized reference height independently; they do not erase the edit to satisfy the original template height.

UI evidence: desktop Journal interaction; simulated iPhone 17 Pro portrait (401×778 viewport) and landscape (750×381) Journal; Xbox resolution 1919×1079 HUD observation. The short-landscape Journal was expanded after inspection. Physical controller gameplay and overscan/accessibility certification are still pending.

Load evidence: 64 mixed-rarity maximum-height tree models plus 150 fruit visuals, 3,376 parts / 734 MeshParts / 27 rarity emitters / 81 particles per second. Tested camera view: 103,268 triangles / 99 draw calls. Separate real pool check reached 150 active anchors / 0 available, then recycled to 150 available. This is not eight-player network or mobile hardware certification.

Economy findings and missed historical early targets are in ECONOMY_REPORT.md. Remaining launch requirements and deferred gifting/trading are in ROADMAP_STATUS.md. All Marketplace IDs remain 0; audio IDs remain blank. No public launch readiness is claimed.

## Historical verification notes

# Verification report

## October 31, 2026 — catalog, part mutations, growth height and six plots

Latest verification in connected Place1:

- Acceptance: **459 passed**. Includes all 84 catalog identities being rollable, preservation of old names, independent part mutations and all five mutation brackets, combined mutation value arithmetic, schema-3 migration, JSON round-trip of mutated parts/builds, height endpoints and retained height after growth/placement/save, and the six-plot cap.
- AdminSecurity: **125 passed**. Covers access to all catalog variants, owner-only new grant intent, forged mutation rejection, invalid catalog index rejection, and existing bounded authorization/audit behavior.
- WorldUX: **36 passed**.
- Live Integration: **44 passed**. Includes purchases of plots five and six, no charge for a seventh plot, exactly six production pads, height retained during placement, and agreement between rendered model bounds and recorded height.
- Total: **664 checks passed**. No new runtime errors in the final playtest console.
- Visually inspected populated inventory and mutated tree previews on desktop and iPhone 17 Pro portrait/landscape. Darkened mutation detail text for contrast and placed preview model/stats beside each other on short landscape screens.
- Inspected a six-tree garden with 0.75–1.50 height scales, distinct normal/mutated components, and a partially grown tree. Live client bounds confirmed ground anchoring to within 0.000006 studs and target-height agreement to within 0.000003 studs.
- Studio returned to its default desktop viewport. Temporary visual Script self-deleted; the session was restarted to remove all fixture parts, coins and trees. Verified a clean profile with 35 coins, zero rolled parts and plot-upgrade level 1 after the reversible integration harness restored its original profile.
- All 21 changed Studio sources matched local sources by checksum before packaging.

Existing published-save, cross-server ranking and real Marketplace release checks remain outstanding. Serialization and migration checks do not replace a published-place save/rejoin test. Historical economy simulation figures below predate this expansion; the legacy simulator still models automatic replacement of occupied plots and should be revised before using it for a new economy-balancing pass. No new human economy or maximum-player performance claim is made.

Verified in connected Place1, October 30, 2026.

## Self-only admin panel

- Verified username `chikinnugggets` resolves to UserId 515156085 and that the connected Studio player has the same ID. The server allowlist uses this immutable ID.
- **65 admin security assertions passed**: owner authorization, display-name spoof rejection, denial of every admin action for a synthetic non-owner, no unauthorized profile mutation, forged target/stat rejection, finite and bounded numeric input, catalog-backed grants, inventory-cap atomicity, luck reset and bounded audit history.
- The existing **157** acceptance assertions passed. The live service suite now passes **35** checks, including admin balance changes, grant/equip, full-catalog grants, actual roll-luck override and exclusion of a different account.
- Through the actual panel, set the balance to 1M, applied 100× luck and granted/equipped the Godly Celestial Pillar with the correct server-side stat (2.4). Inspected the three-tab layout and result feedback.
- Verified both F4 and More → Admin Panel entry paths, including phone portrait layout and hiding/restoring mobile controls for the modal.
- Admin-only changes do not add target-player controls or arbitrary code execution. All admin intents pass the existing network rate limiter and exact payload validation before server authorization/mutation. GUI visibility is not treated as an authorization boundary.
- Backend persistence still needs the published-place verification described below. Security tests use synthetic non-owner actors; the connected live test was the authorized single player.

## Square shop catalog update

- Inspected the supplied `YourUiPack!.rbxm` as read-only binary model data. Its framed icon tiles and three-column grid informed the layout; no external images or scripts were imported.
- Replaced the shop's wide category bars with 15 square purchase tiles grouped into upgrades, defenses and eggs. Sell and Extras are absent from the catalog. Existing HUD colors, font, outlines and gradients remain.
- Checked that every tile has equal rendered width/height and that the canvas exceeds the visible scrolling area. Desktop measured 1,636 pixels of canvas against about 372 visible pixels before the egg-odds info line was added.
- Verified scroll position survives server snapshots. Bought Leaf Power through a real tile: the server charged 25 coins, advanced the level from 1 to 2, and the tile updated its next price to 10,000 coins.
- Visually checked desktop and iPhone 17 Pro landscape/portrait. Confirmed phone movement controls are hidden while the shop is open. Egg hatch odds remain displayed in the egg section.
- No game errors observed during these targeted UI/purchase checks. Existing backend release gates remain unchanged.

## Parts, bag and navigation update

- **157** automated assertions passed, including legacy-bag migration, value/count-preserving stacks, server acquisition-time ranges and forged teleport payload rejection.
- **29** live integration checks passed, including equipped part operations, falling-fruit collection gating, Shop/Garden/Sell teleports, destination rejection, cooldowns and landing outside the automatic shop-opening zone.
- Clicked category tabs, selected a Godly trunk and equipped it through the real UI; the server profile confirmed tier 7. The test was run with temporary memory-only visual fixtures and the original profile was restored afterward.
- Inspected a filled fruit bag with multiple fruit tiers and mutations. Confirmed the selected fruit model changes its pivot while slowly rotating, and inspected the server-generated value, rarity, mutation and acquisition timestamp shown at left. Acquisition is displayed in UTC; stacks retain first/last timestamps.
- Triggered a full-bag pickup attempt and observed the exact warning text and bobbing Sell arrow. Clicked Sell: teleport completed, the bag emptied and the warning cleared. Clicked Shop: arrived near the stand without opening a menu.
- A separate live animation probe verified that fruit descends from its canopy position, reaches its landing time, and recycles invisibly with no active record left behind. Temporary test scripts were removed.
- Inspected the fence and welcome boards: one SurfaceGui per sign, positive text depth offset, and boards physically separated from posts.
- Parts and bag layouts checked on desktop and iPhone 17 Pro landscape/portrait. Phone controls are hidden for the inventory modal and restored afterward so they do not cover pagination or action buttons.
- Published-save and real-purchase release gates listed below remain unchanged. This update uses schema version 2 without changing the existing save namespace.

## Colorful garden redesign

- Replaced dark control panels with rounded, outlined action buttons, bright semantic colors, playful Fredoka lettering, press/hover feedback, cream menu surfaces and illustrated text-badge shop cards. Blue Shop, green Garden and red Sell anchor the top navigation; secondary actions live in More.
- Rebuilt the map as eight fenced gardens along a central avenue, with bordered beds, wooden markers, hedges, flowers, colorful trees, block hills and a central striped market. Vacant gardens remain visible before a player claims them. A generated map preview is also present in Edit mode.
- Removed Hazel. Red Sell and blue Shop stands have clearly marked walk-in zones plus prompts. Sales still use the authoritative bag and range checks.
- The unchanged 152-assertion suite passed again. The extended live integration suite passed **22** checks, including automatic sell-zone behavior, shop-zone entry and removal of the NPC. No game errors observed; only the expected nonpersistent Studio-preview warning.
- Desktop HUD, shop cards, market stands, and iPhone 17 Pro landscape/portrait were visually inspected. The narrow-screen roll label was shortened to avoid wrapping/clipping. No external images or asset IDs were added.

## Automated and live results

- 152 pure/service assertions passed: exact sample math, grow clamps, average tier, 100 matching seeded rolls, 100,000 base rarity samples with six-sigma tolerance, pity boundaries, payload rejection, rate changes, offline growth, no-dead-time swaps, tutorial skip exclusion, finished-tree skip rejection, duplicate reward application for every configured product and JSON profile round-trip.
- 19 reversible live integration checks passed: roll charge/result, equip, plant, keep producer, reject early swap, accept ready swap, authoritative sale, duplicate sale rejection, bag/leaf upgrades, pooled spawn, automatic pickup, hatch/equip pet, ascension/reset/replant and shared tick execution.
- Live forged `Sell {Value=999999999}` and `Plant {Progress=1, Time=0}` requests were rejected. The original profile remained at 35 coins with one producing plot.
- No game errors observed during those live checks. The expected memory-only preview warning was emitted because the place is unpublished.
- Desktop HUD/garden captured and inspected. iPhone 17 Pro landscape inspection found overlapping minimum-size controls; the responsive phone layout was corrected to central Roll/Garden/Shop/More controls with secondary menus.
- Rechecked the corrected iPhone 17 Pro HUD in both landscape and portrait. Landscape action buttons measured approximately 162×50 logical pixels; the bag button was 480×48. Joystick and jump controls remained outside the central action group in both captures. Safe-area mode is CoreUISafeInsets and the place supports Sensor orientation. Studio was reset to its default viewport afterward.

## Economy model

21 fixed seeds, 3,600 simulated seconds per seed. No idle interval exceeded 60 seconds; every simulated replacement retained production. The simulation intentionally ignores mutation premiums, paid boosts, events and pets and assumes immediate pickup/sale. It does not model human attention, walking time, bag limitations or conversion rates.

| Time | Median coins on hand | Median production/sec |
|---|---:|---:|
| 1 minute | 353 | 54 |
| 5 minutes | 1,363 | 289 |
| 15 minutes | 51,938 | 519 |
| 30 minutes | 2,121,968 | 2,666 |
| 60 minutes | 733,716,191 | 688,467 |

This does **not** meet every requested target: 5-minute income and 15-minute coins are high; 30-minute coins are about 2.1× target; the hour coins are about 0.73× target. Ascension unlock timing varies by seed and strategy; 45 minutes is not guaranteed. The simulation emits target-miss warnings. LeafPower levels/prices, plot costs and rarity multipliers are the main tuning controls.

## Release gates not yet verified

1. Published test-place DataStore load/save/rejoin, occupied-lock rejection, lease refresh, throttling/outage retries, simultaneous removal/shutdown and server handoff. A JSON round-trip is **not** an actual backend persistence test.
2. Full ProcessReceipt lifecycle with real IDs and Roblox delivery: pending delivery, retry after save failure, duplicate delivery after rejoin, two purchases close together, receipts after cancellation, changed growth tree, policy eligibility changes and successful ownership refresh. The automated duplicate tests cover grant/ledger helpers; they do **not** claim to reproduce Roblox's backend.
3. Multi-client sabotage, cap boundaries across multiple attackers, defenses, event expiry, private servers and maximum-player join churn. The server implements checks, but the connected single-player test cannot establish all adversarial concurrency properties.
4. Profile size after prolonged purchases/inventory use, DataStore budgets and an eight-player fruit-pool saturation test. Receipt IDs are retained for idempotence; monitor record size before high-volume production use.
5. Physical phone portrait/landscape and tablet checks, safe areas, virtual joystick/jump overlap and menu scrolling at low resolution. Simulator visual checks are not a substitute for a physical-device test.
6. Human economy testing and the explicitly listed UI/content polish in README. No input-bypass anti-idle script is included.

## Compact More, world placement and physical rankings

- Passed 36 targeted assertions for automatic batch selection (including partial affordability, escalating prices and inventory limits), exact intent schemas, empty/unlocked plot eligibility, selection expiry, stale tree rejection, ranking integer encoding and stable ties.
- Existing acceptance suite: 157 passed. Admin authorization suite: 65 passed. Live integration suite: 37 passed, including rejecting occupied destinations while preserving an existing producing tree.
- Desktop More shows six owner-only square tiles in two rows. Phone portrait measured a 360×305 menu containing 93×93 tiles, with scrolling disabled and equal canvas/view heights of 225 pixels. Removed navigation entries are absent.
- Inspected the round top-left gear and two-arrow auto-roll control on desktop and iPhone 17 Pro portrait. Normal Auto-Roll entitlement checks remain active.
- Exercised the actual hold-E prompt, green empty-plot highlight, white hover outline and click placement. Corrected raw pointer ray coordinates and prevented touch controls/ready prompts from consuming placement clicks. The server confirmed the growth pad cleared, plot 2 gained a tree and plot 1 remained producing.
- Four world-board models contain 12 podium slots. In the single-player preview, each server board receives the player's avatar; unfilled/global-unavailable ranks remain empty. Avatar placement uses body bounds and aligns accessory welds before anchoring so detached initial accessory positions cannot shrink the entire avatar.
- Global backend population, multi-server ordering and persistent top-three avatar changes remain unverified in this unpublished place. This update adds the implementation, not a claim of completed backend verification. Temporary visual fixtures are removed when the playtest is reset.
- Live affordability check: with ten-roll capacity unlocked, zero previous rolls and 65 coins, the button offered ×4 / 49 coins. Clicking it produced four parts, increased rolls to 4 and left 16 coins.

## Imported starter asset verification — October 31, 2026

- Existing suites passed after asset integration: Acceptance 459, AdminSecurity 125, WorldUX 36, live Integration 44 (664 total). Live Integration was rerun after the CFrame tween correction and again passed all 44 checks.
- 50 additional visual geometry checks passed in the client: imported mesh presence for all four starter slots across all five mutation states, and correct base anchoring/height at 0.75, 1.00 and 1.50 height scales.
- The all-starter world tree uses 13 MeshParts referencing seven unique mesh resources and retains a 13.5-stud default height.
- A normal server Script spawned a Golden Apple, waited through fall and bounce, verified all three visual meshes stayed within 0.56 studs of the anchor, and verified recycle removed the visual. The check passed and the Script deleted itself.
- Inventory thumbnails and the assembled rotating preview were visually inspected in Studio. Flat material colors were restored explicitly because the GLB importer displayed gray materials.
- Original GLB/OBJ/MTL files and the reusable RBXMX templates are bundled with source. Published-place asset access/moderation in a different creator's experience remains outside this local preview check.
Starter tree editor: verified moving each Trunk/Leaves/Roots Model by (0.5, 0, 0.25) changes the assembled gameplay component by that offset; restored all references afterward. Confirmed reference is hidden in ReplicatedStorage during Play and available in Workspace after Stop. Preserved the user's root center adjustment to 0.1 studs. No runtime errors in the check session.

User-edited tree layout captured: preserved the lowered trunk, offset roots, all three apple positions and the third apple rotation. Added full reference-geometry application so edits to meshes and hanging apples carry into generated trees. Client comparison passed 39 position/size/rotation assertions across all 13 visible MeshParts, plus two canopy-height assertions at minimum/maximum growth scale (41 total). Content preloading succeeded and the resulting preview was visually inspected. Ground-relative canopy height is checked separately from below-ground roots/trunk geometry.

The updated live integration suite passed all 44 checks with the user-edited layout. Studio returned to Edit mode with the tree workbench visible.

## Common sets 2 and 3 verification — October 31, 2026

- Imported eight additional asset models from the two supplied archives through Studio's native importer, using one combined GLB import kit that preserves separate material meshes. The original source GLB/OBJ/MTL files remain bundled separately. Supplied Python generation scripts were not executed.
- ReplicatedStorage.BuildATree.Assets.Starter now holds all 12 Common catalog models with 32 total MeshPart resources. Source templates in Starter.rbxmx were updated to match.
- Existing suites passed: Acceptance 459, AdminSecurity 125, WorldUX 36, Live Integration 44 (664 total).
- Client geometry verification passed 141 checks: all 12 parts across all five mutation states (60), plus all 81 Common builds with correct canopy target height. Fruit stems/leaves remain separate from the mutated body color.
- Normal-server fall/bounce/recycle checks passed for Apple, Cherry and Orange; each retained three attached mesh groups and cleaned its visual on recycling.
- ContentProvider preload succeeded for all 32 mesh resources, with no failed asset fetches. Inventory trunk thumbnails and an assembled Pine/Oakleaf/Fibrous Root/Cherry tree were visually inspected after loading.
- Temporary inventory and equipped-part fixtures were cleared by stopping the nonpersistent preview. The existing StarterTreeEditor layout was retained. Higher-rarity catalog visuals are still the previous procedural models.
## Standardized Common and Uncommon assets — October 31, 2026

- Replaced 12 Common assets with the supplied modular revision and added all 12 Uncommon assets: 24 active models, 57 material meshes. Original mesh source files and assembly metadata are bundled under asset-sources/standardized. Supplied Python scripts were not executed.
- Native importer facing conversion was corrected with a 180-degree Y transform on the saved mesh templates, matching the exported source coordinates and canopy sockets. Linear GLB material colors were converted to the intended sRGB colors for MeshPart.Color.
- Shared source joins now use roots at 0, trunk at 0.6, canopy at 3.6, total source height 6.4. The whole tree scales uniformly to its server-owned height. Higher-rarity procedural components normalize to compatible join heights for mixed builds.
- Fruit placement uses canopy socket minus scaled fruit attachment offset. Individual fruit models have stable Fruit1/Fruit2/Fruit3 names, avoiding replicated child-order differences. Fruit flesh/rind mutations preserve stem and leaf colors.
- Final automated suites: Acceptance 459, AdminSecurity 125, WorldUX 36, Live Integration 44, StandardAssets 1708 — 2372 checks total. StandardAssets covers all 24 parts across five mutation states, all 216 root/trunk/canopy combinations at minimum and maximum height, and 108 socket checks across all 36 fruit/canopy pairings.
- StandardAssets also passed after resetting editor Model pivots to their source-reload bounding-box defaults. Canonical gameplay join pivots remain stable.
- Normal-server live checks passed for all six fruit types through fall, bounce, welded mesh movement and recycling cleanup. All 57 resources preloaded successfully with no failed fetches.
- Refreshed the active StarterTreeEditor using standardized geometry and preserved the earlier hand-edited reference in Studio ServerStorage.BeforeStandardizedRevision and asset-sources/previous-layout. The standard editor remains editable and its mesh transforms carry into the assembled starter build.
- Visually inspected the revised starter thumbnails and an Uncommon Willow/Fern/Vine/Pear tree. Stopped the memory-only test session to clear temporary inventories and returned Studio to Edit mode.
- Published-place asset access, multi-client/device performance and real save/rejoin release checks remain separate from these local checks.
