# Vertical rolling presentation
November 2 2026 · Build a Tree · schema 9 retained

The rolling presentation now uses a vertical reel of actual 3D tree-part previews with faded neighbors and a highlighted center result. It keeps the garden visible and uses the existing colorful Fredoka bubble style. Manual roll, Auto Roll and batch selection retain their existing server rules. No More tile was added.

## Player experience

- The reveal shows the awarded part's name, slot, rarity and mutation, plus its name-and-mutation probability for that specific roll. The displayed reciprocal is labeled approximate; raw stat is separate.
- Batches highlight the highest-rarity awarded part, using mutation multiplier only to break equal-rarity ties. A manual batch opens the full results summary afterward; automatic rolling keeps the world clear.
- Results retains the last 100 awards for the current session, with ten per page. Every part in a five- or ten-part batch can be inspected, including its 3D preview and own odds.
- Hide Reel is a session-only presentation preference. Awards and recent history continue while hidden. Skip Animation and the existing Skip Rolls setting do not alter cooldown, price, grants or odds.
- Reduced Effects removes the rolling motion and rare particle burst; Reduced Shake and SFX preferences retain their existing rules. Rare highlights use rarity color and bounded effects, with no new audio asset.
- Rolls no longer automatically open Tree Parts. Players can keep watching the garden and open their inventory when they choose.
- Existing Roll/Auto controls remain. Results/Hide controls sit above them; ready-tree notices were moved clear of this row. Short landscape screens use a compact readable card. Menus suppress the reel controls and the results list hides overlapping touch controls.

The animation's intermediate parts are decorative previews and do not represent a weighted draw history. The reel labels them as a preview animation. Only the final center result and the complete result list describe actual awards.

## Accurate odds and server authority

Before each production roll, the server snapshots current rarity luck, mutation luck and the strongest applicable minimum rarity. After the existing RollEngine chooses the part, the feedback copy receives its name-and-mutation chance:

rarity weight / eligible total × 1 / 4 slots × 1 / 3 named variants × mutation weight / mutation total.

This includes the lifetime third-roll Rare guarantee and Epic/Legendary pity, even when a batch crosses a guarantee boundary. It excludes the continuously rolled raw stat. Percentages are rounded for display; the 1-in-X value is approximate. Missing old odds are labeled unavailable rather than invented.

The server still owns the award and charges exactly as before. Metadata is added only to the outgoing feedback copy and is not persisted into the owned part. No remote intent, client-supplied amount or grant path was added. The presentation uses its own decorative RNG and does not consume any production RNG draws.

Config is byte-for-byte identical to the task's starting snapshot. Prices, cooldown, rarity/mutation/egg/size odds, pity, luck rules, Marketplace IDs, paid-random policy gates and disabled purchase flags are unchanged. RollEngine, Profile, purchase/receipt code, pets, growth, fruit/Vault rules and world assets were not changed. Schema remains 9 because no saved fields were added.

## Reliability and bounded work

The old presenter discarded feedback while already animating. The new presenter queues overlapping receipts and records every award before animating. Auto presentation fits within the existing 2.5-second roll interval, and hidden/skip modes drain rapidly. Recent history is bounded at 100; the live reel has three models and a summary page has at most ten model previews. Opening another main panel suppresses reel overlays. Safe-area resizing listens to ScreenGui size after device insets settle.

## Verification

All 13 existing/current suites pass: **4,301 checks**, including **635 new roll-presentation checks**. There are also **25 live server feedback checks** and **28 client presentation checks**, for **4,354 checks including the extra integration runs**. The standard live StudioChecks suite separately passed three additional consecutive runs of 147 checks each; those repeats are not added to the headline total.

| Suite | Checks |
|---|---:|
| Progression | 39 |
| Acceptance | 455 |
| StudioChecks | 147 |
| CommerceChecks | 338 |
| FruitChecks | 104 |
| RollPresentation | 635 |
| Balance | 458 |
| SaveFaults | 22 |
| CollectionChecks | 157 |
| AdminSecurity | 125 |
| RoadmapPhase1 | 77 |
| StandardAssets | 1708 |
| WorldUX | 36 |
| Additional live roll feedback | 25 |
| Additional client presentation | 28 |

New coverage verifies base and mutation odds, third-roll/Epic/Legendary guarantees, seeded award equivalence over 310 rolls, no RNG consumption by metadata, no stored feedback fields, complete ten-part server batches, original cooldown enforcement, queued five/ten-part feedback, hidden/skip/reduced-effects retention, bounded history, summary pagination and no automatic inventory opening.

Desktop (1631×753), simulated iPhone 17 Pro landscape (750×381) and portrait (401×778) were inspected. Visible reel and summary text fit; portrait/landscape layout and touch-control overlaps were corrected. ScreenOrientation remains Sensor, HUD CoreUISafeInsets and safe-area clipping remain enabled. These are Studio simulations, not physical-device or multiplayer/load certification.

The 27-page handbook was rendered with background Word and bundled Poppler. Pages 1 and 4 changed and were visually inspected; the other 25 page PNGs are byte-identical to the previously inspected fruit-revision render.

## Delivery and scope

Before editing, all 63 maintained Studio sources matched disk. There are now 66 maintained sources: RollDisplay, RollController and RollPresentation are new; GameService, UIController and HudControls were updated. Final hashes and model checks are recorded in rolling/studio-verification.json.

README, TEST_REPORT, TEST_RESULTS, ROADMAP_STATUS and the handbook are updated. Reproducible additional check scripts are in rolling/ outside the Rojo runtime tree. The current ZIP includes prior balance, collection, commerce and fruit evidence.

Tests used explicitly isolated memory-only Studio profiles with API access off. Temporary runners/fixtures and TestMemoryOnly were removed; Studio ends in Edit/default viewport, HTTP off. The connected PlaceId is 122763473283486. No cloud publish, commit, push or purchase activation was performed. Backend/live receipts, physical devices and multiplayer load remain separate release checks.
