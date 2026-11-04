# Current salvage economy November 2 2026

Schema 11 replaces repeated best-build planting with unique non-starter parts and real salvage/growth downtime. Full before/after active and casual tables, roll counts per tier, income per tier and uncertainty are in [SALVAGE_REPORT.md](SALVAGE_REPORT.md); raw runs are in salvage/.

Leaf Power becomes 1/2/4/8/64/224, each Sapling adds 250%, and all prices/odds/thresholds stay unchanged. Balanced A1 is 3.89 h (P90 5.26 h), second run 2.42 h (62.2%). 300 rolls take 103.60 min, exceeding the older 60–90-minute target. RollFocused A1 median 5.71 h is above the primary median target; its P90 is 7.73 h. All 21 seeds per final policy reach three Ascensions. The 1B first threshold remains.

## Historical schema 6 report

# Build a Tree balance report

November 1, 2026 · America/New_York · profile schema 6

The balanced active policy meets the requested median targets: **61.9 minutes to 300 rolls**, **3.84 hours to first Ascension**, and **2.33 hours for run two** (60.5% of run one). First-Ascension P90 is **4.68 hours**. The first threshold remains **1 billion coins**. All new tuning is in Config. These are simulated policy results, not real-player or launch-readiness measurements.

Two qualifications matter: the roll-focused active policy spends enough to push its first reset to 6.33 hours; the casual policy receives normal offline earnings and reaches its first reset in about 1.33 elapsed days, rather than several days. No extra reset timer or offline nerf was introduced to force those results.

## Simulator corrections and method

The shipped simulator had a single active policy, one-pad placement handling, no repeated reset, no daily/milestone claims and no casual schedule. The request referred to three existing policies; inspection found one. This revision explicitly adds three revenue-allocation policies and a casual variant for each. The corrected baseline ran before changing the economy. It supersedes the older 13.1-minute / 47.6-minute historical estimates.

Each before/after cell uses the same **21 seeds**, a 0.25-second pickup step, actual RollEngine/pity/mutation code, the 500-part cap, equipped-safe spare selling, actual inventory/growth/queue functions, both free-unlocked growth pads, a two-build FIFO queue, identity-based queue cancellation, explicit placement validation and confirmed replacement. Ready trees retain their pad until placement. Replacement clears only the corresponding simulated fruit. The simulation uses production reset/retention and Journal claim functions, including the daily free roll and UTC claims.

Balanced allocates 50% of sale and reward revenue to a rolling budget; RollFocused uses 75%, UpgradeFocused 25%. They buy Leaf Power then plots when affordable, expand bags for expected collection, equip the build with better baseline value per second, fill empty plots and replace weaker trees. They choose to Ascend after eligibility and at least 300 rolls in that run. This last condition is a policy choice, not a game gate. No discounts or batch capacity are purchased in these measurements; rolls are singles, obeying the normal cooldown. Discounts can be enabled with the simulator option for separate sensitivity tests.

Active collection covers all owned plots and sells every 12 seconds. Casual collection sells every 45 seconds, plays 20 minutes per session and starts three sessions per day, eight hours apart. Between sessions it receives the existing two-hour-capped, 50% baseline offline income; both pads settle, while ready trees/queue still wait for explicit placement. Daily claims occur at the correct UTC day. The model starts at UTC day zero with no prior claims.

Pets, weather, raid rewards, private/paid bonuses, real walking/range coverage, eight-player pool contention and human attention are excluded. Rolled/harvest mutations use the production probabilities. Timing changes can change random draw interleaving; a seed is reproducible within a configuration, not a promise of identical part identities across different price curves. All 21 seeds reached every reported milestone in each final policy; no conditional-reach median is presented as an all-player median. P90 is the 19th sorted observation. Independent medians of run times do not necessarily sum to a median cumulative time.

## Before and after balanced active play

| Measure | Corrected baseline | Final |
| --- | --- | --- |
| 300 rolls | 12.9 min | 61.9 min |
| Ascension 1, cumulative | 0.85 h | 3.84 h |
| Ascension 2, cumulative | 1.58 h | 6.05 h |
| Ascension 3, cumulative | 2.26 h | 8.52 h |
| Run 2, duration | 0.77 h | 2.33 h |
| Run 3, duration | 0.63 h | 2.25 h |
| First Ascension P90 | 1.02 h | 4.68 h |

| Run | Median duration | P90 duration | Fastest seed |
| --- | --- | --- | --- |
| 1 | 3.84 h | 4.68 h | 2.79 h |
| 2 | 2.33 h | 2.67 h | 1.88 h |
| 3 | 2.25 h | 2.68 h | 1.83 h |
| 4 | 1.95 h | 2.22 h | 1.42 h |
| 5 | 1.95 h | 2.27 h | 1.71 h |

All sampled active runs 2–5 across all three policies stayed over one hour; the fastest was 1.15 h. This is a sample result, not a forced one-hour lock or a guarantee for every possible lucky build.

## Three active policies

| Policy | 300 rolls before → after | Ascension 1 cumulative | Ascension 2 cumulative | Ascension 3 cumulative | Final A1 P90 |
| --- | --- | --- | --- | --- | --- |
| Balanced | 12.9 min → 61.9 min | 0.85 h → 3.84 h | 1.58 h → 6.05 h | 2.26 h → 8.52 h | 4.68 h |
| RollFocused | 13.0 min → 58.4 min | 0.82 h → 6.33 h | 1.65 h → 10.53 h | 2.30 h → 13.86 h | 7.43 h |
| UpgradeFocused | 13.1 min → 61.4 min | 0.83 h → 3.07 h | 1.55 h → 5.06 h | 2.18 h → 7.14 h | 3.58 h |

The primary balanced policy satisfies the 60–90 minute roll and 3–5 hour first-reset targets. UpgradeFocused also falls inside the first-reset target. RollFocused gets pity slightly sooner (58.4 minutes) but spends 75% of ongoing revenue rolling, so its median first reset is outside 3–5 hours; P90 still remains below eight hours. Coin spending stays a real tradeoff instead of a free late-game action.

## Casual policy and elapsed days

| Policy | 300 rolls, active minutes | A1 elapsed before → after | A2 elapsed before → after | A3 elapsed before → after | Final A1 play time |
| --- | --- | --- | --- | --- | --- |
| Balanced | 14.9 min → 35.8 min | 0.34 days → 1.33 days | 1.00 days → 2.33 days | 1.34 days → 3.00 days | 80.0 min |
| RollFocused | 14.9 min → 31.3 min | 0.34 days → 1.67 days | 1.00 days → 2.67 days | 1.34 days → 3.67 days | 100.0 min |
| UpgradeFocused | 15.7 min → 40.9 min | 0.35 days → 1.00 days | 1.00 days → 2.00 days | 1.34 days → 2.67 days | 60.8 min |

Balanced casual reaches 300 rolls after 8.26 h elapsed and first Ascension after 32.00 h elapsed. That lands in the second calendar day, so the several-day first-reset aspiration is **not met**. Later casual runs often need only 40–60 minutes of active play because offline earnings continue between visits. The one-hour later-run observation above applies to continuous active policies. Altering offline rewards would be an additional balance lever; it was left intact.

## Income per full rarity tier

One tree, all four parts at the same rarity, midpoint saved raw stats, no mutations, no Saplings/events/pets/passes. Base Leaf Power is level 1 in each respective build. Baseline currency scale also changed, so ratios between adjacent final tiers are the clearest test of rarity progression.

| Rarity | Old coins/sec | New coins/sec | New tier jump | Old → new drop seconds | New coins/fruit |
| --- | --- | --- | --- | --- | --- |
| Common | 0.501 | 13.310 | — | 4.835 → 4.545 | 60.50 |
| Uncommon | 0.703 | 35.803 | 2.69× | 4.805 → 3.231 | 115.67 |
| Rare | 0.942 | 90.348 | 2.52× | 4.775 → 2.333 | 210.81 |
| Epic | 1.218 | 225.047 | 2.49× | 4.745 → 1.647 | 370.67 |
| Legendary | 1.531 | 557.524 | 2.48× | 4.715 → 1.137 | 633.82 |
| Mythic | 1.883 | 1391.126 | 2.50× | 4.685 → 0.762 | 1059.91 |
| Godly | 2.273 | 3480.856 | 2.50× | 4.655 → 0.500 | 1740.43 |

Common → Godly income grows from **4.54×** in the baseline to **261.52×** in the final build. Full Godly/Common fruit value alone is **28.77×**; Roots supply the rest of the income gain. This deliberately targets the requested 2–3× whole-build income jump, rather than independently multiplying several slots by 2.5–3× per tier (which would compound far beyond the desired range). The per-slot rarity factor is 1.17; raw stats still matter and are not rerolled.

At maximum Leaf Power, the final one-tree values in the table multiply by 32. The free starter produces 50 base coins per fruit every 5 seconds; the first 25-coin upgrade makes it 100 per fruit. Better parts keep the same relative advantage at every Leaf Power level. A Godly trunk with three Commons retains height/build tier 2, but new growth takes 600 seconds instead of 10; the duration tier weights the highest part equally with the floor-average tier.

## Mutation cap and its tradeoff

The combined factor is **min(2, raw part-factor average × raw harvest factor)**. This was selected below the smallest adjacent full-tier midpoint income gain (about 2.48×). Four Cosmic parts with a Cosmic harvest previously yielded 2,500×; they now yield 2×. A single Golden part with an ordinary harvest remains 1.25×. All None parts average 1.20× value over harvest outcomes under the cap (80% ×1, 20% ×2). Outcome probabilities, saved names, materials and discoveries remain unchanged, and Odds labels raw factors plus the combined cap.

The tradeoff is substantial: Rainbow, Void and Cosmic raw factors often saturate at the same monetary cap. Their visual/collection distinctions remain, but higher raw mutation factors do not always add more income. This prioritizes the request that a lucky mutation cannot overtake a full rarity tier. Whether those reveals still feel sufficiently exciting needs player feedback; no claim of tested player preference is made.

## Rewards versus reference income

Rewards are computed by the server at claim time. Reference is the highest baseline producing-garden income observed in the past 604,800 seconds, capped at 100,000 coins/second. It includes current Leaf Power, earned Saplings and the capped part-mutation factor with harvest ×1; it excludes pets, passes, temporary events/boosts, offline grants and rewards themselves. A weak swap does not lower a live seven-day peak. The peak and claim records survive Ascension; they do not create a daily replay route.

For every scaled reward: `floor(min(100M, max(static floor, reference × min(configured seconds, 3600))))`. The table assumes the reference shown, before any wallet-space limit. Login days accumulate with no missed-day reset.

| Reference coins/sec | Login day 1 | Login day 7 | Roll / sell / plant quests | Lifetime steps 1 / 2 / 3 / 4 |
| --- | --- | --- | --- | --- |
| 1 | 300 | 600 | 180 / 300 / 420 | 300 / 900 / 1,800 / 3,600 |
| 100 | 30,000 | 60,000 | 18,000 / 30,000 / 42,000 | 30,000 / 90,000 / 180,000 / 360,000 |
| 10,000 | 3,000,000 | 6,000,000 | 1,800,000 / 3,000,000 / 4,200,000 | 3,000,000 / 9,000,000 / 18,000,000 / 36,000,000 |
| 100,000 | 30,000,000 | 60,000,000 | 18,000,000 / 30,000,000 / 42,000,000 | 30,000,000 / 90,000,000 / 100,000,000 / 100,000,000 |

Old login was 125–275 coins, old quests 100/150/200 coins, and old three-step lifetime floors were at most 100K. The existing three lifetime thresholds/claim keys stay valid; a fourth step was added as requested: Rolls 1,000, Plants 100, Sold 10,000 and TotalCoins 1B. Four steps use 5/15/30/60 minutes. **Index thresholds, odds, discoveries and its six fixed payouts are unchanged.** The free daily roll stays unchanged.

Actual paid wallet deltas are saved in lifetime `Journal.Paid` or current `Daily.Paid`. `Journal.RewardLog` retains the latest 128 records with key, server timestamp, reference, quote and actual paid amount. A wallet at the global coin ceiling can receive zero; the audit reports zero rather than an invented transfer. Old claims remain consumed without invented historical paid amounts. Daily logs reset gently at UTC midnight while the bounded audit survives. Above 100K actual income/second, rewards stop scaling linearly because of the deliberate reference/coin caps; this is a limit on the “meaningful all game” goal.

## Final Config values and selected levers

Selected levers: rarity-aware value and Roots, multiplicative Leaf Power with staged costs, slower continued roll inflation, a stronger existing Sapling bonus, rising later thresholds, and income-scaled rewards. Plot prices, cooldowns, pets, events, offline limits and paid systems were not retuned. Trials with base value scale 20 gave a roughly six-hour first reset; scale 25 with immediate cheap upgrades made pity too quick. Staging Leaf Power costs achieved the active targets while retaining the first 25-coin doubling and a 75M top cost.

| Config field | Final value |
| --- | --- |
| Schema | 6; BuildATree_v1 namespace unchanged |
| Economy.ValueScale | 25 |
| Economy.RarityFactor | 1.17 per part tier above Common |
| Economy.MutationCeiling | 2 |
| Economy.RootIntervals | 5, 3.5, 2.5, 1.75, 1.2, 0.8, 0.5 seconds |
| Math.MinInterval / RootBase | 0.5 seconds / 0.15 saved raw stat scale |
| Growth.HighestTierWeight | 0.5 |
| LeafPower.Values | 1, 2, 4, 8, 16, 32 |
| LeafPower.Prices | 25, 100000, 1500000, 15000000, 75000000 |
| Roll.BaseCost / CostGrowth | 10 / 1.15 |
| Roll.SlowAfter / SlowGrowth / HardCap | 50 / 1.02 / 1500000 |
| First 300 ordinary rolls | 76072264 undiscounted; 7.607% of first threshold |
| Epic / Legendary pity | 50 / 300, unchanged |
| Rebirth.Threshold / ThresholdGrowth | 1e9 / 1.3 |
| Rebirth.SaplingDivisor / Exponent | 1e9 / 0.5, unchanged |
| Math.RebirthPerSapling | 1.5 (+150%; one Sapling gives total ×2.5) |
| Rewards.ReferenceSeconds / MaxReferenceIncome | 604800 / 100000 |
| Rewards.MaxRewardSeconds / MaxRewardCoins | 3600 / 100000000 |
| Rewards.LoginBase / LoginStep / LoginDays | 100 / 25 / 7 static floor |
| Rewards.LoginMinSeconds / LoginMaxSeconds | 300 / 600 |
| Rewards.DailySeconds | DailyRolls=180; DailySold=300; DailyPlants=420 |
| Rewards.MilestoneSeconds | 300, 900, 1800, 3600 |
| Rewards.AuditLimit | 128 |
| Simulation.Seconds / Seeds / Ascensions | 129600 active seconds maximum / 21 / 5 |
| Simulation.Policies.RollShare | Balanced=.5; RollFocused=.75; UpgradeFocused=.25 |
| Simulation.Casual | 45-second selling; 1200-second sessions; 3 sessions per 86400 seconds |
| Simulation.ActiveSaleEvery / ReplaceImprovement | 12 seconds / 1.01 |

| Lifetime family | Thresholds | Static coin floors |
| --- | --- | --- |
| TotalCoins | 10000, 1000000, 100000000, 1000000000 | 1000, 10000, 100000, 1000000 |
| Rolls | 10, 50, 300, 1000 | 100, 1000, 10000, 100000 |
| Plants | 1, 6, 25, 100 | 50, 500, 5000, 100000 |
| Sold | 25, 100, 1000, 10000 | 100, 1000, 10000, 100000 |

First five thresholds: 1B, 1.3B, 1.69B, 2.197B, 2.8561B. The threshold calculation clamps its exponent at the value derived from the global coin limit, so enormous counters remain finite. Setting the growth factor to one is supported. All parts, mutations, identities, claims, bought Leaf Power levels and Saplings survive migration from schemas 3/4/5. Saved growing-tree durations are deliberately preserved rather than restarted or extended.

## Verification and source state

| Suite | Passed |
| --- | --- |
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

Tests ran in an isolated fresh Play session through normal server Scripts; StudioChecks invoked the actual running-game harness after readiness. Balance regressions cover every new formula, overflow bounds, three legacy schemas, claim-time pricing, weak-swap reference protection, expiry, static floors, caps, duplicate claims, wallet limits, audit bounds, serialization and reset retention. Normal script execution is used because MCP module caches can be distinct from game-script caches. Final simulations also ran through normal Scripts with a recorded Config audit.

Before sync, every maintained Lua source matched Studio. The editable reference/imported templates were backed up and 104 geometry records compared with disk without differences. The lowered Clover canopy was preserved. Desktop Shop, baseline HUD, exact Odds and Journal reward copy were reviewed; the handbook was rendered and all 21 pages inspected. This session does not extend earlier phone/controller certification claims.

GitHub checkout was verified on main with origin https://github.com/dguo16/Treegame.git, clean at the start, and local/pushed commit 7b71b75b51dea450cac48f0fefdb6199836f5567. Required .rbxmx models were already tracked and its ignore rule had already been fixed. Local maintained sources and the canonical project are updated; this task does not commit or push new changes. The ZIP includes updated source, test evidence, reports and handbook; its manifest is verified by SHA-256 during packaging.

## Deliberately unchanged and remaining uncertainty

- Pass/product definitions, IDs/prices/enable flags, purchase/receipt code, sabotage rules, the Index and its fixed rewards, pets, events, plot prices and offline rules remain intact. Shared income valuation changes naturally affect existing income-based systems; no new paid behavior was enabled.
- Core free progression, colorful bubble UI, compact More menu, asset assembly contract, inventory identity recovery and all reset/retention rules remain intact. No trading, gifting, new paid routes, new admin users or arbitrary execution route was added.
- Casual first reset remains quicker in elapsed days than requested because offline earnings matter. The roll-focused spending policy remains slower than the primary 3–5 hour median target. Saturating high mutations and capped very-late rewards require play feedback.
- Pets/events, retained pet equipment, real collection movement and human spending choices can materially accelerate or slow these times. They were not changed or certified by this simulation.
- The place remains unpublished and memory-only; real DataStores, rejoin/session contention, global rankings, purchases, multiplayer and physical-device performance remain unverified release checks. No production-ready claim or named RBXL delivery is made.

Reproduce with `Simulation.Median(129600, {Policy="Balanced"})` or `{Policy="Balanced", Casual=true}` in a normal isolated server Script. Raw before/after runs and Config are under `balance/` in the source ZIP.
