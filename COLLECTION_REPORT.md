# Build a Tree collection and feature report

November 1, 2026 · America/New_York · schema 7

The previous balance work was verified complete before this task: schema 6, the new value/Roots/Leaf Power formula, rising roll/Ascension prices and income-scaled rewards were already installed. The new achievable core is **48 Common–Epic names**, plus partial mutation sets. The collection-aware 21-seed active policy completed all 48 in every seed: **median 3.25 hours**, P90 **4.22 hours**. Full 420-combination completion is optional and grants a title only.

## Tracks and chosen milestones

Name Index deduplicates any mutation into 84 names, with Common–Epic (48 names) as its core completion goal. Mutation Index has four first-find tiers plus 16 partial distinct-name sets for Common–Epic. Legend retains the old complete 420-combination browse view and optional rare-name/full-mutation archives. Optional goals never grant coins, stat bonuses or the required extra pet slot. The next-closest hint selects only unfinished core sets and is visible near the top on short screens.

| Family | Target | Lasting reward |
| --- | --- | --- |
| Core rarity names | 12 names each: Common / Uncommon / Rare / Epic | Each +1% coins and +1% rarity luck; total caps +4% each; a distinct cosmetic |
| Core slot names | Each slot’s 12 Common–Epic names | Trunk / Canopy / Root / Fruit Curator title |
| Core Name Index | All 48 Common–Epic names | Orchard Curator title and +1 equipped-pet slot |
| First mutations | Any Golden / Rainbow / Void / Cosmic part | Matching Finder title |
| Mutation sets | Per core rarity: 6 Golden, 4 Rainbow, 3 Void, 1 Cosmic distinct names | A distinct rarity-and-mutation Curator title; Common sets also grant an aura |
| Optional names | Legendary–Godly rarity names, all 21 names per slot, all 84 names | Collector / Worldtree Curator titles |
| Optional mutation archives | 60 combinations per Legendary–Godly rarity; all 420 | Archivist / Living Legend titles only |

Core sets supplement their lasting reward with `floor(min(1,000,000, max(50, rewardReferenceIncome × 120)))` coins. The existing reward-reference cap also applies. Amounts are computed on the server at claim time and actual paid amounts are audited. There is no timer or missed-day penalty. Equipping or buying a cosmetic never grants the collection stat bonus: the server derives bonuses only from the four claimed core rarity-name sets.

## Expected rolls and time for every set

The included `collection_math.py` computes coupon-collector expectations from the disclosed rarity/mutation weights. Complete equal-probability sets use harmonic sums; mixed-rarity sets integrate the probability that all coupons have been seen, using Poissonization. This is an independent-odds calculation from empty sets, excluding pity and free starter discoveries. It deliberately exposes the long tail instead of rounding rare outcomes into zero. Numerical integration was cross-checked against the closed-form Common name expectation.

Luck examples: base 1×; three tier-1 Epic pets give `1 + 3 × 4 × .03 = 1.36×`; Luck pass alone 2×; pets plus pass 2.72× when account eligibility permits. Pets and their bonuses were not retuned. Rarity luck scales non-Common weights and normalizes, so it can slow Common completion. It does not alter mutation or egg odds. New earned collection luck can add up to a further 1.04 multiplier as sets are claimed.

The 15-seconds-per-roll column is an illustrative conversion, **not measured play time**. The 2.5-second cooldown is a theoretical fastest rate; coin affordability can make a roll much slower. The measured economy-policy table below supplies actual modeled active times, including spending, growth, selling, free daily rolls, claims and resets.

| Set | Base rolls | Pets 1.36× | Pass 2× | Pets + pass 2.72× | Base time at 15s/roll |
| --- | --- | --- | --- | --- | --- |
| Common names (12) | 62.1 | 71.0 | 86.9 | 104.8 | 0.26 h |
| Uncommon names (12) | 149.0 | 125.3 | 104.3 | 92.4 | 0.62 h |
| Rare names (12) | 372.4 | 313.2 | 260.7 | 231.1 | 1.55 h |
| Epic names (12) | 931.0 | 783.1 | 651.7 | 577.7 | 3.88 h |
| Legendary names (12) (optional) | 4,137.6 | 3,480.5 | 2,896.3 | 2,567.8 | 17.24 h |
| Mythic names (12) (optional) | 41,376.1 | 34,804.6 | 28,963.3 | 25,677.5 | 172.40 h |
| Godly names (12) (optional) | 372,385.3 | 313,241.7 | 260,669.7 | 231,097.9 | 1,551.61 h |
| Trunk names Common–Epic (12) | 572.6 | 481.7 | 400.9 | 355.9 | 2.39 h |
| Trunk all names (21) (optional) | 220,167.9 | 185,200.0 | 154,117.5 | 136,633.6 | 917.37 h |
| Leaves names Common–Epic (12) | 572.6 | 481.7 | 400.9 | 355.9 | 2.39 h |
| Leaves all names (21) (optional) | 220,167.9 | 185,200.0 | 154,117.5 | 136,633.6 | 917.37 h |
| Roots names Common–Epic (12) | 572.6 | 481.7 | 400.9 | 355.9 | 2.39 h |
| Roots all names (21) (optional) | 220,167.9 | 185,200.0 | 154,117.5 | 136,633.6 | 917.37 h |
| Fruit names Common–Epic (12) | 572.6 | 481.7 | 400.9 | 355.9 | 2.39 h |
| Fruit all names (21) (optional) | 220,167.9 | 185,200.0 | 154,117.5 | 136,633.6 | 917.37 h |
| Any Golden | 8.3 | 8.3 | 8.3 | 8.3 | 0.03 h |
| Any Rainbow | 20.0 | 20.0 | 20.0 | 20.0 | 0.08 h |
| Any Void | 40.0 | 40.0 | 40.0 | 40.0 | 0.17 h |
| Any Cosmic | 200.0 | 200.0 | 200.0 | 200.0 | 0.83 h |
| Common Golden distinct names (6/12) | 108.9 | 124.5 | 152.4 | 183.8 | 0.45 h |
| Common Rainbow distinct names (4/12) | 154.1 | 176.3 | 215.8 | 260.2 | 0.64 h |
| Common Void distinct names (3/12) | 219.4 | 251.0 | 307.2 | 370.3 | 0.91 h |
| Common Cosmic distinct names (1/12) | 333.3 | 381.3 | 466.7 | 562.7 | 1.39 h |
| Uncommon Golden distinct names (6/12) | 261.3 | 219.8 | 182.9 | 162.1 | 1.09 h |
| Uncommon Rainbow distinct names (4/12) | 369.9 | 311.2 | 259.0 | 229.6 | 1.54 h |
| Uncommon Void distinct names (3/12) | 526.5 | 442.9 | 368.6 | 326.8 | 2.19 h |
| Uncommon Cosmic distinct names (1/12) | 800.0 | 672.9 | 560.0 | 496.5 | 3.33 h |
| Rare Golden distinct names (6/12) | 653.2 | 549.5 | 457.2 | 405.4 | 2.72 h |
| Rare Rainbow distinct names (4/12) | 924.8 | 778.0 | 647.4 | 574.0 | 3.85 h |
| Rare Void distinct names (3/12) | 1,316.4 | 1,107.3 | 921.5 | 816.9 | 5.48 h |
| Rare Cosmic distinct names (1/12) | 2,000.0 | 1,682.4 | 1,400.0 | 1,241.2 | 8.33 h |
| Epic Golden distinct names (6/12) | 1,633.0 | 1,373.7 | 1,143.1 | 1,013.4 | 6.80 h |
| Epic Rainbow distinct names (4/12) | 2,312.1 | 1,944.9 | 1,618.5 | 1,434.9 | 9.63 h |
| Epic Void distinct names (3/12) | 3,290.9 | 2,768.2 | 2,303.6 | 2,042.3 | 13.71 h |
| Epic Cosmic distinct names (1/12) | 5,000.0 | 4,205.9 | 3,500.0 | 3,102.9 | 20.83 h |
| Common–Epic all names (48) | 937.3 | 788.4 | 656.1 | 581.7 | 3.91 h |
| All names (84) (optional) | 372,385.8 | 313,242.2 | 260,670.1 | 231,098.3 | 1,551.61 h |
| Legendary all mutation combinations (60) (optional) | 827,624.1 | 696,177.9 | 579,336.9 | 513,613.8 | 3,448.43 h |
| Mythic all mutation combinations (60) (optional) | 8,276,241.3 | 6,961,779.5 | 5,793,368.9 | 5,136,138.0 | 34,484.34 h |
| Godly all mutation combinations (60) (optional) | 74,486,172.0 | 62,656,015.2 | 52,140,320.4 | 46,225,242.0 | 310,359.05 h |
| All combinations (420) (optional) | 74,486,259.8 | 62,656,089.1 | 52,140,381.9 | 46,225,296.5 | 310,359.42 h |

For scale, all 84 names take about 258.6 hours even at uninterrupted 2.5-second rolling. All 420 combinations take about 51,727 hours at that same theoretical rate. Their rewards are cosmetic bragging rights rather than completion requirements. Partial Common–Epic mutation targets make several sets reachable without collecting all twelve Cosmic names.

## Production roll and pity cross-check

Each fixed-luck sample used the real RollEngine, early guarantee, Epic/Legendary pity, independent mutations and four free starter discoveries, for 128 deterministic seeds. It did not assume a particular coin balance or roll frequency. All 128 seeds completed the core at each tested luck.

| Fixed luck | Mean rolls for core 48 | Median rolls | P90 rolls | Median mutation sets complete at roll 1000 |
| --- | --- | --- | --- | --- |
| 1 | 869.5 | 791 | 1272 | 10 / 16 |
| 1.36 | 730.0 | 697 | 1083 | 11 / 16 |
| 2 | 619.7 | 576 | 912 | 12 / 16 |
| 2.72 | 552.8 | 491 | 852 | 12 / 16 |

## Measured collection-aware active policy

21 seeds used the production economy simulator, 12-second all-plot selling, a 50% rolling budget, actual growth/queue/replacement, income-scaled rewards, new collection claims and earned coin/luck bonuses. The policy bought Leaf Power, plots and carrying capacity, and continued through two Ascensions (12-hour active budget). Pets, events, paid/private perks and actual walking were excluded. The earned pet slot has no income effect in this pet-free model. The timestamps below are automatic **claim** times, at most one sale interval after a discoverable set completes.

| Core set | Reached within two-reset run | Median among reached | P90 among reached |
| --- | --- | --- | --- |
| Common names (12) | 21/21 | 0.03 h | 0.14 h |
| Uncommon names (12) | 21/21 | 0.18 h | 0.36 h |
| Rare names (12) | 21/21 | 1.15 h | 1.75 h |
| Epic names (12) | 21/21 | 3.25 h | 4.22 h |
| Trunk names Common–Epic (12) | 21/21 | 1.91 h | 3.47 h |
| Leaves names Common–Epic (12) | 21/21 | 1.71 h | 4.04 h |
| Roots names Common–Epic (12) | 21/21 | 1.75 h | 3.13 h |
| Fruit names Common–Epic (12) | 21/21 | 1.51 h | 4.11 h |
| Any Golden | 21/21 | 0.01 h | 0.01 h |
| Any Rainbow | 21/21 | 0.01 h | 0.04 h |
| Any Void | 21/21 | 0.02 h | 0.08 h |
| Any Cosmic | 21/21 | 0.11 h | 1.12 h |
| Common Golden distinct names (6/12) | 21/21 | 0.18 h | 0.36 h |
| Common Rainbow distinct names (4/12) | 21/21 | 0.19 h | 0.51 h |
| Common Void distinct names (3/12) | 21/21 | 0.23 h | 1.06 h |
| Common Cosmic distinct names (1/12) | 21/21 | 0.20 h | 3.01 h |
| Uncommon Golden distinct names (6/12) | 21/21 | 0.41 h | 1.13 h |
| Uncommon Rainbow distinct names (4/12) | 21/21 | 1.05 h | 1.35 h |
| Uncommon Void distinct names (3/12) | 21/21 | 2.25 h | 4.29 h |
| Uncommon Cosmic distinct names (1/12) | 21/21 | 1.86 h | 4.63 h |
| Rare Golden distinct names (6/12) | 21/21 | 2.17 h | 4.10 h |
| Rare Rainbow distinct names (4/12) | 20/21 | 3.47 h | 5.05 h |
| Rare Void distinct names (3/12) | 17/21 | 4.50 h | 6.55 h |
| Rare Cosmic distinct names (1/12) | 13/21 | 2.60 h | 5.60 h |
| Epic Golden distinct names (6/12) | 17/21 | 4.14 h | 6.03 h |
| Epic Rainbow distinct names (4/12) | 11/21 | 4.51 h | 5.94 h |
| Epic Void distinct names (3/12) | 8/21 | 5.25 h | 8.09 h |
| Epic Cosmic distinct names (1/12) | 7/21 | 3.85 h | 4.24 h |
| Common–Epic all names (48) | 21/21 | 3.25 h | 4.22 h |

Only rows with 21/21 are all-seed medians. Longer mutation goals, especially Epic Cosmic, are not all expected to complete during this short run. They are ongoing targets; the core Name Index and several mutation sets finish within the measured target timeframe. These are policy estimates rather than human retention, movement or multiplayer evidence.

First Ascension in this new collection-aware sample has median **4.01 hours**. The underlying schema-6 balance values were not retuned. The prior ECONOMY_REPORT is a preserved baseline; its older exact medians should not be presented as the new collection build’s measurements.

## Final reward list

| Set | Permanent cosmetic or bonus | Coins |
| --- | --- | --- |
| Common names | +1% coins and +1% rarity luck; Meadow Glow | Max(50, 2 min reference), cap 1M |
| Uncommon names | +1% coins and +1% rarity luck; Bluebell Glow | Max(50, 2 min reference), cap 1M |
| Rare names | +1% coins and +1% rarity luck; Orchid Glow | Max(50, 2 min reference), cap 1M |
| Epic names | +1% coins and +1% rarity luck; Star Planter | Max(50, 2 min reference), cap 1M |
| Legendary names (optional) | Legendary Collector | 0 |
| Mythic names (optional) | Mythic Collector | 0 |
| Godly names (optional) | Godly Collector | 0 |
| Trunk names • Common–Epic | Trunk Curator | Max(50, 2 min reference), cap 1M |
| Trunk • all rarities (optional) | Worldtree Trunk Curator | 0 |
| Leaves names • Common–Epic | Canopy Curator | Max(50, 2 min reference), cap 1M |
| Leaves • all rarities (optional) | Worldtree Leaves Curator | 0 |
| Roots names • Common–Epic | Root Curator | Max(50, 2 min reference), cap 1M |
| Roots • all rarities (optional) | Worldtree Roots Curator | 0 |
| Fruit names • Common–Epic | Fruit Curator | Max(50, 2 min reference), cap 1M |
| Fruit • all rarities (optional) | Worldtree Fruit Curator | 0 |
| Find any Golden part | Golden Finder | Max(50, 2 min reference), cap 1M |
| Find any Rainbow part | Rainbow Finder | Max(50, 2 min reference), cap 1M |
| Find any Void part | Void Finder | Max(50, 2 min reference), cap 1M |
| Find any Cosmic part | Cosmic Finder | Max(50, 2 min reference), cap 1M |
| Common Golden names | Common Golden Curator + Golden Glow | Max(50, 2 min reference), cap 1M |
| Common Rainbow names | Common Rainbow Curator + Rainbow Glow | Max(50, 2 min reference), cap 1M |
| Common Void names | Common Void Curator + Twilight Glow | Max(50, 2 min reference), cap 1M |
| Common Cosmic names | Common Cosmic Curator + Starlight Glow | Max(50, 2 min reference), cap 1M |
| Uncommon Golden names | Uncommon Golden Curator | Max(50, 2 min reference), cap 1M |
| Uncommon Rainbow names | Uncommon Rainbow Curator | Max(50, 2 min reference), cap 1M |
| Uncommon Void names | Uncommon Void Curator | Max(50, 2 min reference), cap 1M |
| Uncommon Cosmic names | Uncommon Cosmic Curator | Max(50, 2 min reference), cap 1M |
| Rare Golden names | Rare Golden Curator | Max(50, 2 min reference), cap 1M |
| Rare Rainbow names | Rare Rainbow Curator | Max(50, 2 min reference), cap 1M |
| Rare Void names | Rare Void Curator | Max(50, 2 min reference), cap 1M |
| Rare Cosmic names | Rare Cosmic Curator | Max(50, 2 min reference), cap 1M |
| Epic Golden names | Epic Golden Curator | Max(50, 2 min reference), cap 1M |
| Epic Rainbow names | Epic Rainbow Curator | Max(50, 2 min reference), cap 1M |
| Epic Void names | Epic Void Curator | Max(50, 2 min reference), cap 1M |
| Epic Cosmic names | Epic Cosmic Curator | Max(50, 2 min reference), cap 1M |
| Common–Epic name collection | +1 equipped-pet slot; Orchard Curator | Max(50, 2 min reference), cap 1M |
| All 84 names (optional) | Worldtree Curator | 0 |
| Legendary • all mutations (optional) | Legendary Archivist | 0 |
| Mythic • all mutations (optional) | Mythic Archivist | 0 |
| Godly • all mutations (optional) | Godly Archivist | 0 |
| All 420 combinations (optional) | Living Legend | 0 |

Maximum earned core collection bonuses are +4% coin value and +4% rarity luck, independent of which cosmetic is equipped. Mutation odds and eggs stay unchanged. The extra equipped-pet slot adds to the current coin-bought capacity: 3–6 becomes 4–7. Its claim survives Ascension, while the original coin upgrade still resets. Existing retained equipped-pet identities are not forcibly changed.

## Medals and likes

| Medal item | Cost | Slot |
| --- | --- | --- |
| Flower Planter | 2 | Decoration |
| Garden Lantern | 4 | Decoration |
| Meadow Glow | 6 | Aura |
| Bluebell Glow | 8 | Aura |
| Event Friend | 10 | Title |
| Golden Glow | 12 | Aura |

All Medal shop purchases are deterministic, cosmetic-only and once per owned item. A cosmetic already earned through collection cannot charge medals again. Available balance is lifetime EventTokens minus MedalSpent; spending never removes the keepsake or lifetime medal total. Style equips one Aura, Decoration and Title, with server ownership/slot validation. Earned auras use at most 0.5 particles/second per production tree and respect Reduced Effects/distance. A decoration uses at most seven non-colliding parts.

| Received likes | Cosmetic |
| --- | --- |
| 1 | Friendly Gardener |
| 10 | Heart Planter |
| 25 | Heart Glow |
| 100 | Garden Favorite |

Likes never pay coins or stats. Existing one-like-per-target-per-UTC-day, online-target/session availability, proximity, self-like rejection and remote-rate limits remain. Cosmetic milestones are claim-once and the received total/title appears on the owner’s garden sign. No trading, gifting or cross-server cosmetic transfer was added.

## Windstorm and sabotage placement

Windstorm gives ×5 growth for its 60-second duration and retains the outstanding-fruit collection effect within bag capacity. It does not instantly complete either pad. Both pads settle at the old rate before transitions; a delayed tick splits elapsed growth at the actual event deadline. Offline joins settle using standing rates, so a saved temporary Windstorm or Golden Rain rate cannot multiply an entire absence. Existing Golden Rain value/rate and raid rewards remain.

The new event tests also found and fixed an existing duration lookup mismatch: durations were positional while the scheduler indexed by event name. Durations are now keyed by Golden Rain, Windstorm and Giant Pest Raid, with their existing 120/60/120 seconds. Each named event has a regression check and an isolated Studio-only test factory avoids contaminating live event state.

Scarecrow, Bug Spray, Electric Fence and the coin-bought Shield moved from main Shop tiles to More → Sabotage and appear only when Chill is off. The server also refuses purchases while Chill is on. Existing sabotage effects, defenses, prices and default peaceful Chill setting remain. Shield was removed from the developer-product catalog and grant/prompt route; its coin defense remains. All prior Marketplace IDs were zero, and no paid system was enabled.

## Schema 7 migration

- The full Journal.Found map is retained. Valid existing combination identities derive `Journal.Collection.Names` without rerolling or inventing discoveries. The four free starter names remain discoverable. Parts, raw stats, mutations, queued snapshots, existing growth durations, Saplings, bought upgrades and daily/lifetime progress are preserved.
- Old `Journal.Claims.Index12/42/84/168/336/420` remain consumed and are copied with any recorded payout into `Collection.LegacyClaims`. Those retired endpoints cannot pay again. There is no honest one-to-one mapping from a combination count to a particular name set, so new set eligibility derives from actual discoveries. New lasting set rewards are separate once-only claims.
- Existing lifetime EventTokens migrate with MedalSpent=0, retaining every earned medal. Existing LikesReceived and current-day liked-target records remain. New ownership, equip selections, set claims, paid set amounts, medal spending/purchases and cosmetic-like claims live in the retained Journal and survive Ascension.
- Migration is idempotent and tested for schemas 3, 4, 5 and 6. Historical unknown payout amounts are not invented. Schema stays in BuildATree_v1; no DataStore namespace reset or profile wipe occurred.

## Validation and unchanged scope

| Suite | Passed |
| --- | --- |
| Progression | 40 |
| Acceptance | 459 |
| StudioChecks | 94 |
| Balance | 458 |
| SaveFaults | 22 |
| CollectionChecks | 151 |
| AdminSecurity | 125 |
| RoadmapPhase1 | 77 |
| StandardAssets | 1708 |
| WorldUX | 36 |
| Total | 3170 |

All ten suites ran in a fresh isolated Play session. StudioChecks additionally passed three consecutive runs after fixture cleanup was made independent of prior owned fruit. Coverage includes migration/claim replay, catalog identity, partial set counts, caps, actual coin/luck/slot effects, absent mutation/egg changes, medal duplicate/insufficient-balance handling, cosmetic ownership and slot validation, like UTC/self rules, visual bounds, named event scheduling, both-pad Windstorm, deadline splitting and offline settlement. The 512 fixed-luck samples and 21 collection-aware economy runs are separate measurements, not assertion-count inflation.

Before writing, all 51 maintained scripts matched Studio and 104 editable/imported geometry records matched disk. The lowered Clover edit and asset assembly contract were preserved. Final sources, model files, canonical copy and ZIP are verified after sync. The 23-page handbook was rendered and every page inspected. Desktop and iPhone 17 Pro landscape Journal layouts were checked; ScreenOrientation is Sensor, BuildATreeHUD uses CoreUISafeInsets with device clipping, and GardenTopbar uses None with device clipping. These checks are not physical-device certification. Studio ends in Edit with default viewport restored.

The existing balance formula, prices, 1B first threshold, Sapling/Ascension curve and income-scaled daily/lifetime rewards remain. New collection bonuses are the explicitly requested addition. Pet odds, stats, pricing, fusion and other pet mechanics remain, apart from the earned extra slot and accurate text. No additional sabotage feature, Marketplace activation, new admin user, unrelated visual overhaul or external service was introduced.

Remaining release checks are unchanged: the place is unpublished and memory-only; real saves/rejoins, session contention, global backend, live receipt behavior, physical devices and full multiplayer/low-end load are not certified. Long-tail Legend completion remains extraordinarily rare by design and only cosmetic. Illustrative roll-rate times should not be confused with the measured active-policy times.

