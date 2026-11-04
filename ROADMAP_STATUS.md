# Salvage and physical part ownership

Schema **11**, November 2 2026. Planted and queued trees now own their non-starter parts until salvage. See [SALVAGE_REPORT.md](SALVAGE_REPORT.md) for ownership rules, migration, all before/after tables and test details.

- Parts stay in inventory and count toward 500 while in use. Unlimited starter copies remain free. Locks prevent equip, sale and reuse; all three pads and queue preserve tree IDs through placement.
- Tree Parts → Garden and owned tree info list four parts and offer confirmed salvage. Salvage requires own-garden range and a short cooldown, unlocks identical parts, clears only that tree's fruit and refunds no coins. Replacement commits salvage and planting together through session-owned persistence.
- Idempotent migration preserves old trees and ownership, matches safe identities, retains ambiguous copies without creating duplicates, and reserves missing legacy capacity until recovery. Ascension clears trees and locks together.
- Two economy levers: Leaf Power 1/2/4/8/**64/224** and **+250% per Sapling**. Prices/odds/Marketplace IDs and mutation rules remain unchanged; first Ascension stays 1B. Balanced A1 **3.89 h**, P90 **5.26 h**, run two **2.42 h (62.2%)**. 300 rolls **103.60 min**, above the older 60–90-minute target.
- **15,374 assertions across 15 suites pass**, plus 40 client checks (**15,414 total**). Desktop and both phone orientations were checked. More, pets, fruit/Vault/size, authored geometry and draft purchase enable flags remain.
- Nothing was published or activated. Backend/device/multiplayer release checks remain open. The current 28-page handbook is in docs/.


## Historical model update

# Rare and Epic model update November 2 2026

Schema 10 adds both supplied 12-model packs. Common–Epic now have 48 authored models. Rare Blueberry is Crystalberry and Blackberry is Hazelfruit; variants, IDs, saved values, ownership, all build/harvest snapshots and discoveries/claims migrate without a wipe. The 80 new material meshes retain source shape, corrected facing and sRGB palettes; runtime fruit attachment heights were lowered under new opaque crowns for visibility.

All 14 suites pass (15,167 assertions), plus 53 server/client checks for 15,220, and three further live integration repeats. All 80 mesh assets load. Original Common/Uncommon models, lowered Clover, economy, odds, mutation cap, purchases, pets and compact More remain unchanged. See ASSET_REPORT.md and asset-validation/.

The 27-page handbook and catalog are updated and checked. No game publish or purchase activation occurred. Studio ends in Edit/default viewport, HTTP off, memory-test attribute and runners/fixtures removed. Backend, published-client/device and multiplayer release checks remain open.

## Historical rolling roadmap

# Vertical rolling update November 2 2026

Vertical 3D part reel, faded neighbors, honest per-roll name/mutation odds, best-of-batch reveal, complete paginated recent results, Hide/Skip and reduced-effects support are implemented. Rolls keep the garden visible instead of opening inventory automatically. More remains compact.

Schema 9 and all saved data stay unchanged. Config, RollEngine, prices, odds, luck/pity, cooldown, paid-random gates and Marketplace IDs are retained. All 13 suites pass (4,301 checks), plus 53 server/client presentation checks and three repeated live integrations. Desktop and simulated phone orientations were checked; the 27-page handbook is updated and rendered. See ROLLING_REPORT.md.

Studio ends in Edit/default viewport with HTTP off and temporary test settings/runners removed. Nothing was published or activated. Backend, physical devices and multiplayer/load remain release checks.

## Historical fruit roadmap

# Fruit revision November 1 2026

Schema 9 implements the Sell panel, quantity selection and previewed filters; separate 30-stack Vault; 105-entry optional Fruit Index and biggest-fruit record; six-item garden shelf; and server-rolled size classes. Vault and Fruit Index persist across Ascension, bag clears, retained fruit keeps value. Migration preserves old values/timestamps and repairs stack IDs. Exact-schema server requests, stale selection handling and rate limits are tested.

Size odds are 30/60/9/1 with value multipliers 0.8/1/1.5/2.5 and expected value exactly 1. Across 63 paired seeds, median first Ascension changed +1.016% (3.9367 to 3.9767 hours). All 3,666 checks across 12 suites pass; three additional live runs pass. The 27-page handbook is rendered and inspected. No shelf follow-up is needed.

Balance, prior collection/reward work, draft purchases, pets and protected economy/odds/Marketplace settings are retained. See FRUIT_REPORT.md for decisions, tradeoffs, migration, final Config and verification. The connected place has a real PlaceId; this revision used isolated memory-only test sessions and did not publish. Studio ends in Edit/default viewport, HTTP off, temporary test setting/runner removed. Backend, physical-device and multiplayer release checks remain open.

## Historical schema 8 roadmap

# Draft purchase revision November 1 2026

Schema 8 retains completed balance/Index work and revises disabled monetization drafts. Maxer/Rebirth Skip are removed; Mutation Luck is not offered. Third Growth Pad replaces overlapping entitlements with all-pad settlement/placement/credits and free third-Ascension access. Starter Pack is once per account with reference coins, two credits and fixed cosmetics. Journal inventory is reused; no paid pet features or new More tiles were added. All IDs and live prices remain zero; every proposal is Draft=true and all purchases are globally disabled.

All eleven suites pass: 3,526 assertions, plus three repeated live checks. The 25-page handbook is rendered/inspected. See MONETIZATION_REPORT.md for all 22 items, exact effects, proposed prices, free alternatives/times, policy review, migration and pet choices. Nothing is published, committed or pushed; backend/Marketplace/device/load release checks remain open.

## Historical collection roadmap

# Current collection revision November 1 2026

Schema 7 builds on the completed balance revision. Name and Mutation tracks, optional Legend, achievable partial mutation sets, capped permanent core-name bonuses, one earned pet slot, fixed cosmetic Medal shop, like cosmetics/signs, moved Chill-off defenses, removed Shield developer product and five-times Windstorm are implemented. Existing discoveries/claims/medals/likes migrate without a wipe and survive Ascension through the Journal. More stays compact; pet mechanics and prior balance tuning are retained.

3,170 checks pass, with StudioChecks passing three consecutive runs. Independent completion math, 512 production roll/pity samples and 21 collection-aware active policy runs are in COLLECTION_REPORT.md. The complete 420 tail remains optional and cosmetic-only. The handbook has 23 inspected pages. Studio finishes in Edit/default viewport; no publishing, real purchase activation or backend/device certification is claimed.

## Historical balance roadmap

# Current balance revision November 1 2026

This section supersedes the numerical balance and schema notes in the earlier roadmap below. The three requested balance steps are installed in Studio and maintained source: rarity-aware value/cadence and mixed-build timing; a continued roll sink, staged multiplicative Leaf Power and stronger/rising Ascension progression; and server-scaled, capped, audited daily/lifetime rewards. Schema is 6. The first Ascension threshold stays 1B; reset/retention remains intact. Existing parts, mutations, claims, Saplings, bought levels and saved growing-tree durations survive migration.

The primary 21-seed active model meets median targets (300 rolls 61.9 min, first reset 3.84 h, second run 2.33 h), with first-reset P90 4.68 h. RollFocused active first reset is 6.33 h and casual first reset remains 1.33 days because offline earnings stay enabled. These are model results with documented exclusions. See ECONOMY_REPORT.md for all six policies, tables, Config and uncertainty. TEST_REPORT.md records 2,994 passed checks.

Pass/product definitions and enable flags, sabotage, the Index and its fixed rewards, pets/events, plot prices and offline limits were not retuned. Core free progression, compact colorful UI and the lowered Clover geometry are retained. No public publishing or purchase activation occurred. Published backend, real-player, physical-device and multiplayer release checks remain open.

## Historical roadmap before the balance revision

# Build a Tree — November 1 roadmap update

Updated directly in connected Studio Place1, maintained in local source, and packaged in the accompanying ZIP. Studio ends in Edit mode; this is still an unpublished memory-only preview. No public release or live purchases were enabled. No named RBXL save is claimed.

## Implemented

- Explicit replacement: hold E at either ready growth tree, choose a gold occupied owned plot, then confirm Replace. Green empty plots plant immediately. Selection expires after 60 seconds. Tree ID, owner/garden range, unlocked plot and unchanged target are checked again on the server. D-pad/A/B placement is supported.
- Missing old-tree part identities return with the same stats and mutations. Planting already retains inventory parts, so existing IDs are not duplicated; free starter parts remain permanently available. Replacement refuses without changing either tree if recovered parts would exceed 500. Sell unequipped spare parts and retry. Nothing is automatically sold. Only that plot's outstanding fruit is cleared. Confirmation replay cannot grant twice.
- Roll exponent capped at 50: a late roll costs 10,836 coins before discounts. Late Leaf Power values are 5,000 and 10,000, replacing the 500,000/1,000,000 jump. Ascension already resets pricing and pity counters.
- Procedural Rare–Godly parts gain 1–5 fixed accents; Legendary+ world builds have one bounded aura/outline. Distance and Reduce Effects controls limit local effects. Authored Common/Uncommon geometry is preserved.
- Second growth pad unlocks free after first Ascension or with existing ExtraPlots. Two queued equipped-build snapshots start FIFO when a pad is vacated. Cancel by queue identity in Tree Parts. Ready trees stay until explicitly placed. Both pads settle offline; skip receipts bind to their actual tree ID. A ready-tree HUD button returns to the garden.
- Third lifetime roll guarantees Rare or better. Odds explains it and calculates the exact next-roll minimum. New onboarding covers roll, equip, grow, hold-E placement, collect, sell, Leaf Power and a new plot, with world guidance for world objectives.
- Tree Parts → Journal contains a 420-entry collection index, claimable collection/lifetime milestones, daily login coins, one free daily roll and three daily quests. Return-day progress never resets for missing days. Daily counters use server UTC days. Login reward is 100 + 25 × min(return days, 7). Free daily rolls advance the same roll/pity counters.
- Offline return summary, rarity-scaled reveals, skip controls, mutation messages, sale number pops and bounded toasts. Audio hooks, music/SFX toggles and volume settings exist; actual licensed audio IDs are still empty.
- Online garden visiting/liking, one like per target per UTC day while visiting, and a tallest-tree/server-rarity showcase in Journal. Fixed event keepsakes and participation medals reward Golden Rain harvests, Windstorm growth participation and successful cooperative raid participants. Trading remains deferred.
- News/update board and editable Config.News entries.
- Draft coin, growth-speed, extra-pad, auto-sell/sell-anywhere, mutation-luck and cosmetic passes, plus a Starter Pack product. Coin value doubles once in ValueCalculator; growth rate doubles through normal settlement. Auto-sell handles ordinary and Infinite bags. Mutation weights and effective Odds share one calculation. New purchasing and paid mutation luck remain disabled.
- Policy checks fail closed before join-policy lookup completes. Restricted accounts' paid gameplay entitlements stay inactive, including after Ascension. This code still needs a full published-place policy review before activation.
- Saving now proves lock ownership for every retry AND every UpdateAsync callback. Lost ownership closes gameplay access; failed/throwing reward transactions do not expose speculative rewards or leave a stuck busy flag. Deterministic fake-backend regressions cover these failures.

## Preserved Studio edit

The Clover foliage meshes had been moved down approximately 0.3956 studs in StarterTreeEditor since the supplied archive. This edit was discovered before syncing, backed up, exported into source, and retained. Tests now independently calculate the editable reference geometry rather than assuming its unedited canopy top. The server's sampled nominal height remains the ranking value; visual workbench edits can move the visible canopy relative to it. AssemblyVersion=2, EditorOrigin and ReferenceHeight remain intact.

## Validation

2,536 automated checks passed across Acceptance, AdminSecurity, WorldUX, StandardAssets, RoadmapPhase1, Progression, SaveFaults and live Integration. See TEST_REPORT.md. Phone Journal layouts were inspected on simulated iPhone 17 Pro portrait and landscape, then Studio returned to default. Xbox-resolution HUD was viewed; physical gamepad and console certification remain outstanding.

The load scene contained 64 maximum-height mixed-rarity trees and 150 fruit visuals: 3,376 parts, 734 mesh parts, 27 rarity emitters and 81 particles/second. One tested camera view measured 103,268 triangles and 99 draw calls (no shadow pass reported). A separate actual pooled-fruit test reached all 150 active anchors, then returned all 150 to the pool. This is Studio evidence, not eight real clients or low-end hardware certification.

## Remaining gates and deferred work

- Publish a private TEST place and verify real save/rejoin, lock contention, shutdown/disconnect, migration, offline settlement, global rankings, mesh permissions and real pending/duplicate/cancelled receipts. None can be certified from this unpublished preview.
- Review and approve proposed prices, create real Marketplace IDs, check regional/account policies and actual advertised odds before enabling purchases. New IDs/prices remain 0; EnableNewPurchases and MutationLuckEnabled remain false.
- Giftable developer products remain deferred until cross-player durable delivery and receipt reconciliation are designed and tested; no gifting is advertised or enabled. Trading is deferred as directed by the roadmap.
- Supply owned/licensed music and SFX IDs. Volume controls do not make empty audio IDs audible.
- Physical phone/tablet/console input and eight-client low-end load/network tests remain required. The Studio load scene is not a substitute.
- Draft store artwork/copy are included for review, not uploaded or published. Authored Rare–Godly meshes still await supplied assets; fallback presentation is implemented.

Schema is now 5; BuildATree_v1 stays the DataStore namespace. Schema 3/4 growth, parts, mutations and height data migrate without rerolling. Journal, discoveries, lifetime claims, return days and onboarding survive Ascension. Daily quests reset gently by UTC day.
