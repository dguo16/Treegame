# Build a Tree salvage report

November 2, 2026 · profile schema 11 · local Studio and maintained source

Non-starter parts now belong to one queued, growing or planted tree until salvage. Their inventory rows remain present and counted; salvage unlocks them unchanged. The four free starter identities remain unlimited. All 15 suites pass: **15,374 assertions**, plus **40 client checks** for **15,414 total**. No game was published and no purchases were enabled.

The primary balanced simulation reaches first Ascension in **3.89 hours**, with **5.26-hour P90**. Run two takes **2.42 hours**, **62.2%** of run one. First Ascension remains 1B. Reaching 300 rolls now takes **103.60 active minutes**, above the older 60–90-minute target; that tradeoff is retained rather than changing roll prices or odds.

## Inspection before changes

| Record | Before | After |
|---|---|---|
| Owned parts | `Parts` rows with server IDs, stats, variant and mutation; no custody marker | Same rows plus `InUse = tree ID`; counted while deployed |
| Next equipped build | Four copied part records in `Equipped` | Same preview; locked rows cannot be reselected or planted again |
| Growth pads | `Growth`, `Growth2`, `Growth3`, each with ID, snapshot, duration, progress, height and state | Same fields plus `PartIds`; ID and locks persist through placement |
| Queue | ID and copied build; Pump created a different growth ID | Locks on entry; its ID and part references survive FIFO start |
| Production plots | Build, height, state and next drop; growth ID discarded | Same tree record moves to plot, retaining its ID and part references |
| Replacement | Confirmed ready-tree swap; appended missing old IDs, refused overflow | One saved transaction salvages old custody then transfers the ready tree; no duplicate rows |
| Ascension | Fresh profile cleared parts, plots, pads and queue | Same reset also clears all custody together |
| Starter parts | Separate `starter_` IDs from `Profile.Starter`, unlimited | Unchanged exemption; mixed builds lock only actual inventory parts |

The remote already had exact schemas, a 12-burst/4-per-second bucket, and server-owned IDs/outcomes. The only part sale route was `SellPart`; bulk/filtered Sell requests operate on fruit stacks, and Fuse operates on pets. Those separate systems were not repurposed.

Studio was rediscovered as Build a Tree, place 122763473283486, in Edit. Of 69 initial maintained sources, 68 matched disk. Studio's ImportedModels lacked the previous Rare/Epic lookup and fruit socket adjustment. That version was exported to `salvage/studio-before/ImportedModels.lua`, and maintained Rare/Epic support was restored. No other Studio source edit was overwritten. All 208 initial editable geometry records and both asset XML files remain unchanged.

## Final rules

- New planting and queue entry validate all four server-owned inventory identities before taking any locks. A deployed part cannot be equipped again, sold or used in another build. Admin single grants reject ID collisions; admin grants also respect counted capacity. There is no part-fusion or part bulk-sale feature to add here.
- Inventory retains all deployed rows. Rolls and batch sizing use that total plus any reserved missing legacy copies. Ordinary full-inventory salvage adds no rows and cannot overflow.
- Starter-only trees can fill every pad, queue and plot. Mixed builds lock only their non-starter rows.
- Tree Parts → Garden and owned world tree info list all four parts, stats and mutations. In-use tags name Plot N, Growth Pad N or Queue N in inventory and Journal browsing. The Salvage button stays above scrolling part details on phones. More has no new tile.
- Salvage requires a server-issued 30-second confirmation bound to the tree and location, own-garden range matching placement, and a 3-second cooldown. The server rechecks range and rejects expired, moved, forged or replayed requests. Cancelling invalidates the capability.
- Growing, ready and producing trees can be salvaged. The tree disappears, its own outstanding fruit is cleared, its parts unlock unchanged, and growth progress is lost. Coins, spent credits and other costs are not refunded. Unused paid skips retain the existing changed-tree credit rules.
- Queue cancellation unlocks that queued tree's parts. All three pads, Grow Now lookup, skips, FIFO start and offline settlement keep the same tree identity.
- Replacement keeps its existing explicit server confirmation. Old-tree unlocks and new-tree placement commit in one profile transaction; only the replaced plot's fruit is cleared.
- Plant, queue, cancel, replace and salvage use isolated profile drafts committed through the session-owned save backend. The profile becomes visible only after success. A mutation exception discards the draft; an uncertain durable write closes the session so an old in-memory profile cannot overwrite a possibly committed salvage. Saving/disconnect waits for the busy transaction. Stored tree removal and part unlocking are always one record update.
- Ascension still clears parts, equipment, producers, growth records and queue together. Ownership markers have no separate retained table that could leave orphan locks.

## Migration

Schema increases once, from 10 to 11. `OwnershipVersion=1` makes the custody migration idempotent. Names/variants normalize first through the existing migration. Existing IDs, raw stats, mutations, heights, progress, timing, discoveries, claims, fruit values, pets and purchase records remain.

An unambiguous identity/stat/mutation match binds exactly one held row. Repeated old use of an already matched ID and ambiguous equal-stat candidates remain legacy snapshots, without taking someone else's lock or creating another sellable inventory item. Truly missing copies remain in the tree with reserved capacity and materialize only when salvaged. Repeated missing use of the same legacy identity does not grant it twice. Existing growth and queue IDs are reserved before generating missing plot IDs, preserving pending receipt targets. Missing/duplicate inventory IDs are repaired without dropping rows.

| Migration fixture | Matched parts | Ambiguous parts | Missing parts | Starter exemptions | Reserved missing capacity |
|---|---:|---:|---:|---:|---:|
| Matching tree, repeated old tree, missing tree, starter tree | 4 | 4 | 4 | 4 | 4 |
| Two equal-stat inventory candidates for an ID-less snapshot | 3 | 1 | 0 | 0 | 0 |

The first fixture keeps all four trees and all four original inventory rows during migration. Salvaging the repeated tree adds no duplicate and does not clear the other tree's lock; salvaging the missing tree returns its four saved parts with identical data. Repeated migration and JSON save/load preserve IDs, counts and custody.

Legacy exception: if a save already contains 500 inventory rows plus a genuinely missing tree part, migration reports 501 owned capacity rather than deleting something. Further rolls/admin grants are blocked. Salvage moves that already reserved part into inventory while counted ownership stays 501; selling unlocked spares returns the save below the normal 500 limit. This preservation case and collision-safe tree-ID assignment have explicit tests. Existing ambiguous cloned trees are grandfathered until removed; no new cloned build can be planted.

These are fixture counts, not a claim about the user's live saves. No production profile was loaded or migrated during this task.

## Rolls needed to fill six plots

Independent 256-seed Monte Carlo uses base rarity weights, third-roll guarantee, Epic/Legendary pity and uniform slots. The old policy reused one best build six times. The new tier-focused audit keeps the best six distinct parts per slot and greedily assigns stronger sets first; **each** of the six floor-average build tiers must reach the row's target. Starter Commons make Common cost zero rolls. Production-plot purchase costs, growth waits, coins and Ascension resets are excluded from this roll-count audit. Those appear in the time model below. All 256 seeds reached every row within the 5M-roll audit bound.

| Minimum average tier on every plot | Old expected rolls | Unique-parts expected rolls | Unique median | Unique P90 |
|---|---:|---:|---:|---:|
| Common | 0.00 | 0.00 | 0 | 0 |
| Uncommon | 6.06 | 78.23 | 76 | 100 |
| Rare | 23.37 | 208.44 | 204 | 269 |
| Epic | 86.86 | 632.16 | 613 | 848 |
| Legendary | 546.32 | 3,108.84 | 2,973 | 4,132 |
| Mythic | 5,328.88 | 31,189.46 | 30,547 | 41,582 |
| Godly | 73,256.88 | 309,067.61 | 296,292 | 414,304 |

This is a tier-collection audit, not an income strategy or a time promise. Actual income-focused greedy choices also weigh stats, Roots and the existing mutation cap. Legendary–Godly full orchards remain a long tail.

## Before and after pacing

Each cell uses 21 seeds, current size rolls, rewards/collection claims and three Ascensions. The fresh before model runs the old copyable-build growth behavior with previous Config; after uses physical custody and final tuning. Balanced allocates 50% of revenue to rolls, RollFocused 75%, UpgradeFocused 25%. Sales occur every 12 seconds active or 45 seconds casual. Casual plays three 20-minute sessions per day, eight hours apart, with normal offline settlement. Models choose to Ascend after eligibility and 300 rolls in that run; that is a policy, not a game restriction. All 21 seeds reach all three Ascensions in every final policy.

The unique policy fills empty plots greedily from the best remaining available parts, using starters for weak slots. To reuse a producer's own pieces, it salvages that producer before queueing the improved build and includes the lost production while growth/queue completes. Targets are reserved by tree ID so several in-flight builds do not all claim the same plot. Inventory pruning never sells locked rows. Pet, weather, private/paid bonuses, actual movement/range coverage and multiplayer pool contention remain excluded. Random draw interleaving changes as production changes; paired seeds are reproducible policy samples, not identical roll histories.

Active times: minutes for 300 rolls; hours elsewhere. Ascension columns are cumulative; run two is a separate median and medians need not add exactly.

| Active policy | 300 rolls before → after min | A1 h | A2 h | A3 h | Run 2 h | A1 P90 h |
|---|---:|---:|---:|---:|---:|---:|
| Balanced | 59.50 → 103.60 | 3.84 → 3.89 | 6.19 → 6.27 | 8.49 → 7.54 | 2.14 → 2.42 | 4.64 → 5.26 |
| RollFocused | 48.80 → 101.45 | 5.86 → 5.71 | 9.61 → 9.01 | 12.88 → 10.70 | 3.78 → 3.16 | 7.59 → 7.73 |
| UpgradeFocused | 62.79 → 91.20 | 3.08 → 3.02 | 4.84 → 4.46 | 6.63 → 5.56 | 1.73 → 1.57 | 3.66 → 4.01 |

Casual Ascensions and elapsed 300-roll time are wall-clock hours, including offline periods. Active 300-roll minutes are shown separately.

| Casual policy | 300 active min before → after | 300 elapsed h | A1 elapsed h | A2 elapsed h | A3 elapsed h |
|---|---:|---:|---:|---:|---:|
| Balanced | 35.05 → 40.13 | 8.25 → 16.00 | 32.00 → 24.00 | 56.00 → 32.00 | 72.00 → 40.00 |
| RollFocused | 29.00 → 40.42 | 8.15 → 16.01 | 40.00 → 24.00 | 64.00 → 32.00 | 80.00 → 48.00 |
| UpgradeFocused | 40.67 → 41.55 | 16.01 → 16.03 | 32.00 → 24.00 | 48.00 → 32.00 | 64.00 → 48.00 |

Primary balanced targets pass: 3–5-hour median A1, P90 under 8 hours and run two at 50–65% of run one. All three active-policy A1 P90s are below 8 hours. RollFocused's 5.71-hour median remains above the primary 3–5-hour range because it spends more on rolls; no timer or threshold exemption forces it faster. The old 60–90-minute 300-roll target is not met. Casual offline income still accelerates elapsed progression and can make a later run only one session; no offline nerf was introduced.

For comparison, the historical schema-6 ECONOMY_REPORT recorded 61.9 minutes, 3.84 hours A1, 6.05 cumulative A2 and 8.52 cumulative A3, with 4.68-hour A1 P90 and a 2.33-hour second run. The prior fruit report's 63-seed A1 was 3.98 hours. The fresh before table is the direct comparison because it includes the current three-pad, claim and fruit-size behavior.

Without tuning, 21 balanced unique-parts seeds took 19.22 hours to A1, P90 25.06 hours; only 12 reached A2 in the 36-active-hour bound and none reached A3. Those censored results are retained in `salvage/unique-untuned.json`, not presented as complete-run medians. Small pilots and two full candidates are retained for review; final results are `salvage/after.json`.

## Income per tier and exact Config changes

Uniform unmutated midpoint-stat trees, Normal size, no Saplings/bonuses. Base per-tree income is unchanged. Max-garden columns assume six distinct equivalent sets, full collection, and the former/final maximum Leaf Power. They are theoretical production, before bag, movement, growth and collection losses. A free starter tree earns 10 base/sec; midpoint Common below is 13.31.

| Tier | Base coins/sec per tree, unchanged | Old max coins/sec, six plots | Final max coins/sec, six plots |
|---|---:|---:|---:|
| Common | 13.31 | 2,555.52 | 17,888.64 |
| Uncommon | 35.80 | 6,874.22 | 48,119.57 |
| Rare | 90.35 | 17,346.84 | 121,427.89 |
| Epic | 225.05 | 43,209.09 | 302,463.64 |
| Legendary | 557.52 | 107,044.70 | 749,312.92 |
| Mythic | 1,391.13 | 267,096.23 | 1,869,673.58 |
| Godly | 3,480.86 | 668,324.28 | 4,678,269.99 |

| Config field | Previous | Final | Reason |
|---|---|---|---|
| Schema | 10 | 11 | Idempotent physical custody migration |
| Leaf Power values | 1, 2, 4, 8, 16, 32 | 1, 2, 4, 8, 64, 224 | Restore first-run pace with distinct parts and replacement downtime |
| Income added per Sapling | 150% | 250% | Restore the second-run ratio; first Sapling is ×3.5 total |
| New Salvage rules | — | 3s cooldown, 30s confirmation | Short server cooldown and expiring authorization |

No price changed: Leaf Power still costs 25 / 100K / 1.5M / 15M / 75M. Roll price formula, plot costs, 1B threshold and 1.3 later-threshold growth, rarity/mutation odds, mutation cap, Marketplace IDs, draft proposals and disabled purchase flags are unchanged. Protected Config equality and unchanged file hashes are in `salvage/protected-config-audit.json`. Existing bought Leaf Power levels and Saplings immediately use the new multipliers; legacy duplicated orchards are preserved as required and may progress faster than a fresh unique-parts profile.

## Validation and retained work

| Suite | Passed assertions |
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
| **All 15 suites** | **15,374** |
| Additional client checks | 40 |
| **Total** | **15,414** |

SalvageChecks has 168 assertions; StudioChecks includes 39 live salvage assertions plus the existing live fruit checks. Coverage includes duplicate planting, deployed sales/equip, starter/mixed builds, full inventory, all pads and queue, growing/ready/planted salvage, replacement, stat/mutation preservation, migration matches/ambiguity/missing/collisions, Ascension, exact forged payloads, proximity, rate limits, cancellation/expiry/replay, and fake-backend failures before/after write and mid-mutation. An actual phone confirmation click removed the plot, changed locked count 12 → 8, and kept inventory count 12. Forty client assertions check tags, disabled equip/sell/plant actions, responsive visible touch targets, confirmations and restored actions after salvage. Desktop, iPhone 17 Pro portrait and landscape were inspected; Sensor orientation and existing safe-area clipping remain.

One old live fixture lacked the newly required producer ID; it now supplies a stable ID. Replacement and enhanced-queue fixtures use independent starter builds instead of reusing locked parts. Screen QA caught and fixed escaped UI line breaks before delivery. The final fresh console has no script errors. The 28-page handbook was rendered and reviewed; unchanged content was compared against the prior render.

Pets/eggs/fusion, fruit Sell/Vault/size/Index, collection rewards, likes, medals, weather, cosmetics, authored geometry, odds and draft purchasing logic remain. ValueCalculator, RollEngine, fruit inventory/size modules, PurchaseService and both asset XML files are byte-identical to the previous build. More has no added tile. Trading, gifting, paid pet features and authored Legendary–Godly models were not added.

Real backend save/rejoin, session contention and disconnect behavior still require a test-place check; fake stores prove atomic record behavior but cannot certify Roblox service availability or real receipts. Physical devices, multiplayer/load, backend leaderboards, published asset permissions and live commerce remain release gates. API access and HTTP remain off. Studio ends in Edit/default viewport with temporary test scripts and memory-test attribute removed. No publish, purchase activation, commit or push occurred.

Reproduction: run the 15 suites in README in a fresh isolated memory-only Play session. `Simulation.Run(seed,129600,{Policy="Balanced",Ascensions=3})` uses unique custody by default. `UniqueParts=false` selects the archived legacy growth module; restore the previous Leaf Power values and Sapling coefficient in an isolated session to reproduce before results, then restore Config. `salvage/fill_audit.cjs` reproduces the independent roll-count audit. Raw before/after rows, migration/test results and client fixture/check sources are included.
