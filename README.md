# Build a Tree

Schema **11**, November 2 2026. Planted and queued trees now own their non-starter parts until salvage. See [SALVAGE_REPORT.md](SALVAGE_REPORT.md) for ownership rules, migration, all before/after tables and test details.

- Parts stay in inventory and count toward 500 while in use. Unlimited starter copies remain free. Locks prevent equip, sale and reuse; all three pads and queue preserve tree IDs through placement.
- Tree Parts → Garden and owned tree info list four parts and offer confirmed salvage. Salvage requires own-garden range and a short cooldown, unlocks identical parts, clears only that tree's fruit and refunds no coins. Replacement commits salvage and planting together through session-owned persistence.
- Idempotent migration preserves old trees and ownership, matches safe identities, retains ambiguous copies without creating duplicates, and reserves missing legacy capacity until recovery. Ascension clears trees and locks together.
- Two economy levers: Leaf Power 1/2/4/8/**64/224** and **+250% per Sapling**. Prices/odds/Marketplace IDs and mutation rules remain unchanged; first Ascension stays 1B. Balanced A1 **3.89 h**, P90 **5.26 h**, run two **2.42 h (62.2%)**. 300 rolls **103.60 min**, above the older 60–90-minute target.
- **15,374 assertions across 15 suites pass**, plus 40 client checks (**15,414 total**). Desktop and both phone orientations were checked. More, pets, fruit/Vault/size, authored geometry and draft purchase enable flags remain.
- Nothing was published or activated. Backend/device/multiplayer release checks remain open. The current 28-page handbook is in docs/.

## Previous Rare and Epic update

Schema **10**, November 2 2026. Both supplied Rare/Epic packs are applied: 24 authored models and 80 material meshes. Rare Blueberry becomes Crystalberry; Blackberry becomes Hazelfruit. Existing ownership, values, discoveries and claims migrate without loss. See [ASSET_REPORT.md](ASSET_REPORT.md).

- Common through Epic now use 48 authored templates (137 MeshParts). Legendary through Godly keep their procedural visuals.
- New models appear in trees, rolling, inventory, harvests and Vault displays. New canopy attachment heights were lowered for visible fruit; original source files/contracts are retained.
- Schema-9 names migrate across owned/equipped parts, all tree and growth snapshots, Bag/Vault and Fruit Index records. IDs, variants, stats, saved values, timestamps and claims remain.
- **15,167 checks across 14 suites pass**, plus 53 additional server/client checks (**15,220 total**), three repeated live integrations and successful loads for all 80 new meshes.
- All 104 original geometry records and the hand-adjusted Clover are unchanged. Prices, odds, purchase IDs and purchase enable flags are unchanged. Nothing was published to the live game.

## Previous rolling update

Schema **9**, November 2 2026. Rolling now uses a vertical reel of actual 3D parts, faded neighbors, honest per-roll odds and complete batch results. See [ROLLING_REPORT.md](ROLLING_REPORT.md).

- Best-of-batch reveal plus every awarded part in Results: ten per page, last 100 this session.
- Hide/Skip affects presentation only; Auto Roll keeps collecting results. Reduced effects and shake preferences are respected.
- Rolls keep the garden visible and no longer force Tree Parts open. More remains compact.
- All 13 suites pass: **4,301 checks**, plus 25 live feedback and 28 client checks (**4,354 total**), and three additional repeated live suites.
- Config, prices, odds, luck, pity, cooldown, Marketplace IDs and paid-random gating are unchanged. No save migration or schema bump is needed. Purchases remain disabled.

## Fruit and Vault foundation

Schema **9** fruit revision, November 1 2026. Sell opens a selection panel by default; fruit can be locked in a separate Vault; harvested fruit now has four size classes. Completed balance, achievable Index and disabled draft purchases are retained. See [FRUIT_REPORT.md](FRUIT_REPORT.md) for Config, formula, migration and simulation.

- Sell All Unlocked, partial quantities and previewed filters send only server revision, stack IDs and quantities. The server recomputes payouts and reports stale selections. Quick sell on entry defaults off.
- Vault holds 30 stacks outside bag capacity. All sale paths and Windstorm exclude it. Unlock requires room for the whole stack.
- Vault, Fruit Index and biggest-fruit record survive Ascension; bag clears. Vault keeps saved value, allowing limited banking between runs.
- Optional Fruit Index has 105 name/mutation discoveries and lists collected sizes. The cosmetic garden shelf displays six vaulted items. More stays compact.
- Small/Normal/Large/Giant odds are 30/60/9/1%, value factors 0.8/1/1.5/2.5, visual scales 0.8/1/1.25/1.6. Expected value is exactly 1. Size is outside the unchanged ×2 mutation cap; Double Coins applies once.
- Schema-8 stacks become Normal with values and known timestamps preserved. Missing/duplicate IDs are repaired. New stacks group by name, tier, mutation and size with a conserved total and average unit price.
- The prior fruit revision passed 3,666 checks across 12 suites. The 63-pair first-Ascension simulation gives 3.9367 h before and 3.9767 h after (+1.016%). The 27-page handbook is in docs/.

## Retained draft purchase revision

All 12 passes and 10 products remain Id=0, Price=0 and Draft=true; EnableNewPurchases=false. Proposals and free alternatives remain in MONETIZATION_REPORT.md.

- Maxer and Rebirth Skip products/grant paths are removed. Mutation Luck is not offered; its calculator is explicitly pending policy review and live mutation luck is always 1.
- Third Growth Pad replaces ExtraPlots and Extra Growth Pad. Pad 2 is free after first Ascension. Pad 3 and queue 2 to 3 activate with the pass after first Ascension, or free at third Ascension. No current entitlement unlocks production plots or an early second pad. All six production plots still use coin upgrades.
- Pads 1/2/3 use Growth/Growth2/Growth3 and world indices 7/8/9. Identity-bound placement, replacement, growth, FIFO snapshots, watering selection, Grow Now, credits, offline settlement, event deadlines, height records and reset cleanup support all three. Queue entries never automatically replace a producer.
- Starter Pack is once per account: 30 minutes of saved server reward-reference income (cap 50M), two Grow10 credits, Sprout Planter and Bud title. Coin packs now use the same reference instead of temporary/paid/pet-boosted current income, capped at 100M. No client-provided payout or price is accepted.
- Double Coins applies once after the other value factors. Double Growth multiplies every pad with pet growth, eligible private x1.25 and one weather event (Rain x3 OR Wind x5). Super/Ultra keep their existing factor-replacement and time-extension rule, disclosed in descriptions and exact numeric purchase previews in Odds.
- Square Passes tiles show draft prices, exact effects, quotes and account availability. Touch controls hide behind the panel; portrait and landscape layouts were inspected. More has no new tile and remains compact.
- Reuse Journal > Style for owned cosmetics and equip/clear. Eight featured items include existing Index/Medal/like rewards plus four new fixed bundle items. Cosmetic Bundle grants Sunset Glow and Festival Pinwheel; free alternatives cost 16/20 medals. Starter cosmetics cost 2 medals each. No cosmetic has stats or random outcomes. Existing cosmetics remain owned. Already earned bundle items cannot prompt a redundant purchase.
- Schema 8 converts retired pad ownership and preserves historical second-pad access, occupied plots, saved tree identities/durations/heights, queues and all prior collection/balance data. Old Starter Pack logs stay consumed; no coins or credits replay. Passes, bundle ownership, cosmetics and credits survive Ascension.
- The existing conservative paid-random gate remains for every paid gameplay item, including indirect coin routes; fixed cosmetics are exempt. Receipts use session-owned durable transactions, duplicate protection and policy rechecks. Cancellation grants nothing; spending limits remain. All Marketplace tests use Studio-only fake dependencies.

The earlier schema-8 21-seed policy is retained as historical evidence in commerce/. The current size comparison and suite counts are reported above and in FRUIT_REPORT.md.

## Balance and collection foundation

Fruit value uses 25 x (rarity-scaled Fruit + rarity-scaled Leaves) x rarity-scaled Trunk x whole-build Leaf Power x min(2, averaged part mutation x harvest mutation) x Saplings x events x player factors. Rarity power is 1.17 per tier; Roots use rarity intervals down to 0.5 seconds. Leaf Power is 1/2/4/8/64/224. First Ascension stays 1B, later thresholds scale 1.3 per reset and each earned Sapling adds 250% base income. The roll curve keeps its late sink and cap.

Names tracks 84 any-mutation names, with 48 Common-Epic names as core completion. Mutation sets target 6 Golden / 4 Rainbow / 3 Void / 1 Cosmic distinct names per core rarity. The 420-combination Legend is optional and cosmetic only. Four core rarity sets cap earned coin/luck bonuses at +4% each; all 48 grant one permanent equipped-pet slot. Discoveries, claims, medals, likes and cosmetics persist through Ascension. See [COLLECTION_REPORT.md](COLLECTION_REPORT.md) and [ECONOMY_REPORT.md](ECONOMY_REPORT.md) for prior measured baselines.

Chill starts on. Coin defenses appear only in More > Sabotage when Chill is off. Shield is not a developer product. Windstorm is x5 growth for 60 seconds with fruit collection, not instant completion. Pets, eggs, stats, prices and fusion were not monetized or retuned.

## Play and assets

Start with 35 coins and free Oak/Clover/Taproot/Apple parts. Roll, equip in Tree Parts, plant or queue a build, collect landed fruit and visit Sell. SHOP/GARDEN/SELL are travel controls. Hold E at a ready tree to choose an empty plot or confirm replacement. Only the selected plot's fruit is cleared. Non-starter parts lock to one queued/growing/planted tree. Tree Parts → Garden provides confirmed salvage; replacement unlocks the old tree and transfers the ready one atomically.

Maintain the colorful Fredoka bubble UI. More contains Odds, Ascension, Sabotage, Pets/ Eggs, Passes and owner-only Admin. Settings stays a small gear. Leaderboards remain in the world. ScreenOrientation is Sensor; safe-area clipping is retained.

Common-through-Epic imported source models remain tracked in src/. Preserve AssemblyVersion=2, EditorOrigin, ReferenceHeight=13.5, named Fruit1-3 sockets and the lowered Clover geometry. Do not ignore *.rbxmx. default.project.json maps this maintained source into Studio through Rojo. Only owner UserId 515156085 has admin controls; no new privileged user was added.

## Reproduce all suites

Use an isolated fresh Play session after startup. In Edit, set the DataService ModuleScript attribute TestMemoryOnly=true before starting Play; the hook is Studio-only and keeps the running profile away from durable stores. Wait for the profile and character. Live checks now refuse a persistent profile. Module fixtures use fake stores and do not prompt real purchases:

```lua
local tests = game.TestService.BuildATreeTests
for _, name in {"Acceptance", "AdminSecurity", "WorldUX", "StandardAssets", "RoadmapPhase1", "Progression", "SaveFaults", "Balance", "CollectionChecks", "CommerceChecks", "FruitChecks", "RollPresentation", "AuthoredAssets", "SalvageChecks"} do
 require(tests[name]).Run()
end
game.ServerScriptService.BuildATree.StudioChecks:Invoke(game.Players:GetPlayers()[1], "Run")
```

Run the code from a normal temporary server Script. After stopping Play, remove the temporary runner and TestMemoryOnly attribute in Edit. Invoke live checks through the normal game harness, after the profile and character are ready. Do not run concurrently with manual gameplay or purchases. TestService modules follow the project's existing harness; no external testing package is required.

The connected place now has PlaceId 122763473283486; historical unpublished notes describe earlier sessions. This revision used explicitly isolated memory-only profiles with API access off. Studio ends in Edit/default viewport, HTTP off, test attribute and runners removed. No cloud publishing or purchase activation was performed. Real save/rejoin, session contention, receipt delivery, global backend, physical devices and multiplayer load need separate test-place verification. Giant uses a verified bundled ping; other audio remains unconfigured. Trading and gifting remain deferred.
