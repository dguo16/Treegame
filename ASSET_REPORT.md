# Authored Rare and Epic models
November 2 2026 · Build a Tree · profile schema 10

Both supplied packs are applied: **24 new catalog models, comprising 80 material meshes**. They replace the procedural Rare/Epic visuals in trees, inventory, the rolling reel, harvests and Vault displays. The packs contain colored geometry and flat materials, not separate texture images. Common/Uncommon assets and the hand-adjusted Clover remain intact.

## Catalog changes

| Previous Rare fruit | Current name | Stable identity |
|---|---|---|
| Blueberry | Crystalberry | Fruit, tier 3, variant 1 |
| Blackberry | Hazelfruit | Fruit, tier 3, variant 2 |

Frostberry stays variant 3. The supplied RoyalPlumFruit model represents the existing Epic name Plum; no other catalog name was changed. The catalog remains 84 named parts and 420 name/mutation combinations. The optional Fruit Index remains 105 identities.

## New models

| Tier | Slot | Catalog names |
|---|---|---|
| Rare | Trunk | Sapphire Birch, Azure Cedar, Cobalt Palm |
| Rare | Leaves | Blue Maple, Frost Fern, Azure Blossom |
| Rare | Roots | Coral Root, Frost Root, Azure Tangle |
| Rare | Fruit | Crystalberry, Hazelfruit, Frostberry |
| Epic | Trunk | Amethyst Spiral, Violet Willow, Rosewood Twist |
| Epic | Leaves | Lavender Fan, Orchid Cloud, Violet Wings |
| Epic | Roots | Crystal Root, Amethyst Root, Orchid Tether |
| Epic | Fruit | Plum, Pomegranate, Passionfruit |

All 48 Common-through-Epic parts now use authored templates. There are 137 active template MeshParts in total. Legendary through Godly retain their procedural models and bounded accents.

## Import and assembly

The supplied GLBs were combined without modifying their geometry, then imported through Studio under user 515156085, the same owner as the connected experience. Their 80 mesh assets were uploaded to that owner's Roblox inventory as required for runtime MeshIds. No game publish, purchase activation or purchase-ID change was performed.

The importer reversed the X/Z-facing direction. A single 180-degree Y correction restored authored coordinates; every material-group center and dimension was checked against the GLB accessor bounds. Maximum center error was about 0.00000011 studs. Templates are already corrected and must not be rotated again.

Linear GLB material colors were converted to intended sRGB MeshPart colors. Named material groups and relative transforms remain intact. Mutations recolor eligible surfaces while retaining fruit stems/leaves under the existing rule. No mutation odds or economic multiplier changed.

The shared assembly uses roots at Y=0, trunk at Y=0.6, canopy at Y=3.6 and uniform tree scale based on the 6.4-stud reference. Hanging fruit retains its 65% scale. Authored fruit attachment offsets and canopy X/Z socket positions are used.

The first assembled inspection showed that the new opaque Epic crowns hid fruit at their supplied surface-height sockets. Runtime socket Y is therefore capped at **0.4 source studs for the six new Rare/Epic canopies**, placing fruit beneath the crown. Original source contracts remain archived unchanged. Existing Common/Uncommon sockets and the Clover workbench override are unchanged. All six new crown/fruit pairings were visually checked after this correction.

The raw imported kit is retained in Studio ServerStorage as RareEpicKit_ImportedBackup. Active corrected templates are in ReplicatedStorage.BuildATree.Assets.Starter and the maintained Starter.rbxmx. Original GLB/OBJ/MTL files, previews, manifests and assembly contracts are included under asset-sources/standardized/rare and epic. Supplied Python generation/validation scripts were retained as source material and were not executed.

## Schema 9 to 10 migration

An idempotent name migration updates the two Rare fruit names throughout saved records:
- Owned and equipped parts, producing trees, all three growth pads and queued builds.
- Bag and Vault stacks, Fruit Index entries and biggest-fruit records.
- Nested pending purchase/build snapshots, preserving their binding IDs.

IDs, tier/variant positions, raw stats, mutations, size classes, counts, saved sale totals, timestamps, growth progress, durations, heights, coins, pets, entitlements and credits stay intact. Missing timestamps remain unknown. Existing stacks are not merged or financially revalued.

Part and Fruit Index discovery keys already use stable tier/variant identities. They remain unchanged, as do claims and recorded rewards. Legacy names also resolve through catalog/mesh lookups, preventing old Blackberry from falling back to variant 1. Migration invalidates display caches and does not replay rewards.

## Verification

All **14 suites pass: 15,167 assertions**, including **10,866 authored-model/migration checks**. The additional live roll-feedback checks pass (25) and client presentation checks pass (28), giving **15,220 checks including those additional checks**. StudioChecks separately passed three additional consecutive runs at 147 checks each; these repeats are excluded from the headline total.

| Suite | Checks |
|---|---:|
| Progression | 39 |
| Acceptance | 455 |
| StudioChecks | 147 |
| CommerceChecks | 338 |
| AuthoredAssets | 10866 |
| FruitChecks | 104 |
| RollPresentation | 635 |
| Balance | 458 |
| SaveFaults | 22 |
| CollectionChecks | 157 |
| AdminSecurity | 125 |
| RoadmapPhase1 | 77 |
| StandardAssets | 1708 |
| WorldUX | 36 |
| Additional server feedback | 25 |
| Additional client presentation | 28 |

Coverage includes all 1,728 Common-through-Epic root/trunk/canopy combinations, shared joins and fruit attachments; all 24 new definitions; every material group under all four mutations; botanical accent preservation; new harvested-fruit Giant scaling; old/new name-key equivalence; schema-9 migration and repeated migration; saved values/timestamps; all pads, queues and pending snapshots; retained discoveries and claims. Existing commerce, receipt, authority, balance, fruit/Vault and rolling suites still pass.

Prior fallback-only visual fixtures were updated to check authored Rare/Epic models; procedural accent checks remain for Legendary-through-Godly. The procedural harvest fixture now uses Legendary Starfruit because Epic Plum is authored.

**All 80 new mesh content IDs loaded successfully**, with no failures, in the isolated Studio session. The uploader and place owner match. This establishes current Studio access; published-client/device/load verification remains a release check.

Before editing, all 66 maintained Studio sources matched disk. Final count is 69 and final source hashes match. All 104 original geometry records are unchanged; the final snapshot has 208 records after adding the 24 models and 80 meshes. All 24 preexisting model XML elements are unchanged and StarterTreeEditor.rbxmx is byte-identical to the starting copy.

The 27-page handbook is updated and rendered: pages 1, 3, 24, 25 and 27 were inspected; the remaining 22 PNGs are byte-identical to the previously inspected render. README, PART_CATALOG, ROADMAP_STATUS, TEST_REPORT and TEST_RESULTS are updated. The ZIP includes corrected model source, assets, migration and verification evidence.

## Preserved scope and final state

Config comparison is identical after excluding only schema 9→10, the two catalog name replacements and their explanatory comment. Prices, odds, value formula, mutation cap, luck, pity, growth rules, Marketplace purchase IDs and disabled purchase flags are unchanged. No pet, sabotage, monetization or new More feature was added.

All checks used explicitly isolated memory-only profiles with API access off. Temporary test runners and preview fixtures were removed, the test attribute cleared, and Studio returned to Edit/default viewport with HTTP off. No game publishing, commit, push or purchase activation occurred. Live backend saves/receipts, physical devices and full multiplayer performance remain separate release checks.
