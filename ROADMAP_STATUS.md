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
