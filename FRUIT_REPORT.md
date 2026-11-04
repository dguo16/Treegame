# Fruit selling and Vault revision
November 1 2026 • profile schema 9

The Sell panel, separate 30-stack Vault, optional Fruit Index, biggest-fruit record, six-item garden shelf and four harvest sizes are implemented. The completed schema-8 balance, collection and draft-purchase work is retained. Nothing was published, committed, pushed or activated for purchase.

## Final Config

| Setting | Final value |
|---|---:|
| Profile schema | 9 |
| Vault capacity | 30 stacks, separate from bag fruit capacity |
| Display shelf | First 6 vaulted stacks, miniature models |
| Sale payload maximum | 256 distinct stacks per request |
| Sale cooldown | 0.4 seconds |
| Lock/unlock cooldown | 0.25 seconds |
| Giant cue cooldown | 6 seconds per owner, plus client limit |
| Giant light | Range 6, brightness 0.5, no shadows |
| Shelf base longest dimension | 1 stud, then class visual scale |
| Harvest pool/lifetime | Existing 150 anchors / 90 seconds |
| Giant SFX | Bundled rbxasset://sounds/electronicpingshort.wav |

| Harvest size | Exact chance | Coin multiplier | Uniform visual scale |
|---|---:|---:|---:|
| Small | 30% | ×0.8 | ×0.8 |
| Normal | 60% | ×1 | ×1 |
| Large | 9% | ×1.5 | ×1.25 |
| Giant | 1% | ×2.5 | ×1.6 |

Sizes are sampled on the server at spawn with a separate random stream. Rarity luck, paid luck, pets and pity do not change their odds. Rolled tree parts do not receive harvest sizes. Odds shows the exact distribution and expected value.

## Value and pacing

For an ordinary unpruned build:

`25 × (FruitStat × 1.17^(FruitTier−1) + LeavesStat × 1.17^(LeavesTier−1)) × TrunkStat × 1.17^(TrunkTier−1) × LeafPower × min(2, averagePartMutation × harvestMutation) × SizeValue × SaplingFactor × EventFactor × eligiblePlayerFactors × DoubleCoins`

Eligible player factors retain existing pet, VIP, collection and temporary penalty rules. SaplingFactor is 1 + 1.5 × earned Saplings; Golden Rain's coin event factor remains ×5. DoubleCoins is either 1 or 2 and applies once after the other factors. Existing pruning substitutions remain unchanged. Size is outside the unchanged combined mutation ceiling of ×2.

For a 50-coin baseline fruit: Small 40, Normal 50, Large 75, Giant 125. At the mutation ceiling the Giant is 250; Double Coins makes it 500. Expected size value is **0.30×0.8 + 0.60×1 + 0.09×1.5 + 0.01×2.5 = exactly 1**.

The same production simulator ran 63 paired seeds, before with size fixed to Normal and after with size sampled. Both sides use the same Balanced policy, 12-second explicit Sell All decisions, rewards, production formulas and first-Ascension requirement.

| First Ascension | Before sizes | After sizes | Change |
|---|---:|---:|---:|
| Reached | 63 / 63 | 63 / 63 | — |
| Median active hours | 3.9367 | 3.9767 | +1.016% |
| Mean active hours | 4.0131 | 4.0308 | +0.440% |
| 90th percentile hours | 4.7567 | 4.6367 | −2.523% |

This meets the requested few-percent pacing check. An initial 21-pair pilot was expanded to 63 pairs to reduce small-sample uncertainty. Raw final results are in fruit/size-pacing-63.json; this is a reproducible policy comparison, not a promise for an individual player. No pets, paid/private perks, weather, walking, real human panel time or Vault banking are modeled. The separate size random stream avoids directly perturbing part/mutation draws, but changed income can still change decisions and later draw trajectories.

Reproduce in an isolated Studio session with TestService.BuildATreeTests.Simulation.Run(seed,43200,{SaleEvery=12,Policy="Balanced",Ascensions=1,Sizes=false}) and the same call with Sizes=true for seeds 1–63.

## Sell decisions and authority

Entering Sell or using its prompt opens the panel by default; the existing bag/SELL travel controls still go to the market. The large default button sells every unlocked bag item. Select mode supports whole stacks and partial quantities, with a live estimate from the current server snapshot. The quick filters select a preview; the player confirms with Sell Selected. The below-value filter compares the stack's average unit value.

Locked Vault entries remain visible and are excluded from every filter and sale. Quick sell on entry is separate from AutoSell, defaults off and bypasses the panel only when enabled. AutoSell and Sell Anywhere retain their existing entitlement and policy checks and never sell Vault contents. Windstorm collects into the ordinary bag only.

A sale intent contains only Revision and Stacks, with exact row keys Id and Quantity. The server checks exact schemas, finite integer quantities, duplicate IDs, payload limits, ownership, market range or eligible AutoSell entitlement, cooldown and stack availability. It recomputes the payout; client amounts and totals are rejected.

A future revision rejects. A current revision requesting too much rejects atomically. An older revision sells only remaining valid selected quantities, clamps reduced stacks and reports missing/adjusted stacks. New arrivals are not added to an existing selection automatically. Quantity-based Journal, daily and lifetime sold counters advance by what actually sold. Correlated server feedback prevents unrelated AutoSell results from advancing a panel batch; failures release its busy state. A ten-second timeout stops the batch and asks the player to check refreshed inventory, without automatic retries.

## Locking and Ascension decisions

The Vault holds **30 stacks**, not 30 individual fruit. Lock moves the whole stack outside normal bag capacity. Unlock returns the whole stack only if the bag has room; otherwise the clear refusal leaves both inventories unchanged. IDs survive moves. Locking does not require a purchase or market visit.

**Vault, Fruit Index and biggest-fruit record survive Ascension; ordinary bag contents clear.** Vault fruit keeps its saved sale value, so it can be unlocked and sold in a later run when capacity permits. This deliberately allows limited value banking across resets. A large retained stack may require bag upgrades before it can be unlocked. No stat bonus is awarded for keeping or displaying it.

The shelf shows up to six miniature vaulted stacks, uses no harvest anchors and has no collision or gameplay effect. It refreshes on Vault revision. Models sit above their planks; class scaling is retained.

## Stack grouping and schema 8 migration

New fruit groups by Name + Tier + Mutation + Size. Exact value and acquisition minute no longer split otherwise identical stacks. Every stack stores Count, TotalValue and average Value; a partial sale receives a proportional share. This conserves total value and limits clutter, at the cost of losing individual unit prices within a blended stack.

Migration runs once to schema 9 and is idempotent:
- Existing stacks become Normal and keep saved quantities, unit values and total value. Legacy stacks are not financially consolidated during migration.
- Valid unique stack IDs remain; missing, malformed or duplicate IDs receive new server IDs, including anonymous Saved Harvest.
- Existing acquisition timestamps remain; missing timestamps stay unknown.
- Separate Vault, Fruit Index, bag revision and QuickSellOnEntry=false defaults are initialized without wiping existing progression.
- Known legacy bag fruit derives Normal discoveries. Anonymous Saved Harvest keeps value without inventing a catalog identity or discovery time.
- Prior collection discoveries/claims, balances, parts, trees, growth queues, pets, entitlements, credits, cosmetics, medals, likes and the balance revision remain intact.

Fruit Index tracks 21 harvest names × 5 mutations = **105 optional discoveries**, listing discovered sizes. Biggest Fruit records the highest collected size class and known discovery time, not invented weight. Selling a fruit never erases it. Neither feature adds required milestones or gameplay rewards.

## World and UI checks

Imported and procedural harvest models scale uniformly, remain welded to the existing tweened pooled anchor and recycle size/mesh/glow cleanly. Giant's light and short cue respect distance, SFX settings and reduced effects, with per-owner and client rate limits. A parented Sound using the bundled asset loaded successfully with length 0.72 seconds.

Desktop and simulated iPhone 17 Pro landscape/portrait Sell views were inspected; the narrow estimate was corrected and all visible Sell text fits on the final portrait screen. Touch controls hide while Sell is open. Vault and Fruit Index were inspected on desktop/portrait, and the six-item shelf was inspected in the garden. No new More tile was added. Sensor orientation, HUD CoreUISafeInsets clipping and topbar None clipping remain. The HUD bag-full warning/arrow stays separate from scaled fruit; pickup distance still uses the unchanged center-based radius. The largest anchor is 2 studs versus the starting 8-stud radius; size does not expand pickup range. These are Studio checks, not physical-device certification.

## Final verification

**All 12 suites pass: 3,666 assertions.** StudioChecks also passed three additional consecutive runs at 147 checks each.

| Suite | Passed checks |
|---|---:|
| Acceptance | 455 |
| AdminSecurity | 125 |
| WorldUX | 36 |
| StandardAssets | 1,708 |
| RoadmapPhase1 | 77 |
| Progression | 39 |
| SaveFaults | 22 |
| Balance | 458 |
| CollectionChecks | 157 |
| CommerceChecks | 338 |
| FruitChecks | 104 |
| StudioChecks including live FruitIntegration | 147 |

Coverage includes schema-8 migration/idempotence, stable IDs, timestamp/value preservation, stack grouping, partial/stale/future sales, forged payloads, bounds, rate limits, new arrivals during selection, every locked-fruit sale/collection path, capacity, full-bag unlock refusal, quantity counters, Ascension retention, exact size math and sampling boundaries, pooled imported/procedural visuals, Giant cooldown and shelf placement.

Before editing, all 57 maintained Lua sources and 104 geometry records matched disk. Final maintained source count is 63. Geometry and lowered Clover are preserved. Final source/copy/ZIP verification is recorded with the package.

The connected place has PlaceId 122763473283486 and GameId 10774301287; earlier documents calling it unpublished describe historical sessions. API access was off and all current Play verification explicitly forced memory-only profiles. A Studio-only TestMemoryOnly hook and live-test guard prevent accidental tests against durable player profiles. Temporary runners, fixtures and the test attribute are removed at completion; Studio returns to Edit/default viewport with HTTP off.

## Left unchanged and remaining release checks

No purchase price, existing rarity/mutation/egg odds, Marketplace ID, mutation ceiling, pet stat/egg/fusion rule, sabotage feature, paid feature or free-progression requirement changed. Purchases remain disabled and all configured IDs/live prices remain zero. Existing draft purchase and receipt tests still pass.

README, TEST_REPORT, TEST_RESULTS, ROADMAP_STATUS and the 27-page rendered handbook are updated. Shelf work is included rather than deferred. Real save/rejoin against a test backend, live receipt delivery, cross-server data, physical devices and multiplayer/load testing remain separate release checks. No cloud publishing or purchase activation was performed.
