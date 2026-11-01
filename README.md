# Build a Tree

## Current build — November 1, 2026

The approved roadmap's core loop and engagement features are now implemented in Studio and source, with disabled monetization drafts and a release-gate report. Read [ROADMAP_STATUS.md](ROADMAP_STATUS.md) first for exact behavior, preserved user edits, remaining work and migration notes. [ECONOMY_REPORT.md](ECONOMY_REPORT.md) contains the new price/pity audit and seeded simulation. [TEST_REPORT.md](TEST_REPORT.md) records 2,536 passing checks and their limits. Proposed prices, draft description and artwork are under marketing/.

Controls: roll, equip in Tree Parts, plant or queue a build, then hold E at a ready growth tree. Green plots plant; gold plots request explicit Replace confirmation. D-pad/A/B also select and cancel plots. Tree Parts → Journal contains Index, Daily, Goals, Gardens and News. More remains compact and unchanged. Pad 2 is earned on first Ascension or with ExtraPlots.

Profiles use schema 5 in BuildATree_v1. New purchases and paid mutation luck remain disabled; all IDs are 0. Audio controls are implemented but licensed audio IDs are still needed. Studio ends in Edit mode. The project has not been published or certified for release.

The older notes below document earlier revisions and may describe superseded controls. The current build and linked status report take precedence.

---

### Private admin panel

Only Roblox UserId **515156085** (`chikinnugggets`, verified via Roblox's username lookup) can use the admin commands. Open **More → Admin Panel**, or press **F4** outside a text field on desktop. The client hides the entry for other accounts; every command independently checks the fixed UserId on the server. Display-name matches, client flags and target-player fields do not authorize access.

- **Coins:** set, add or remove your balance. Supports plain numbers, comma separators, K/M/B/T/Qa/Qi suffixes and scientific notation. Values are bounded to 0–1e30; subtraction floors at zero. Lifetime earned-coins statistics are not fabricated.
- **Parts:** select any of four slots, seven rarities and three catalog variants; grant a copy, grant and equip it, or add all 84 catalog entries. Stats are generated from the server's catalog at the rarity's maximum, and the normal inventory cap still applies. Grants do not consume coins or change roll/pity counters.
- **Luck:** set an absolute personal part-roll luck override from 0.01× to 1,000,000×, or reset to normal pet/pass/boost luck. Effective odds still use the existing rarity system and pity rules. Other players, part/fruit mutations and egg odds are unaffected.

Coins, parts and the optional luck override are stored in your profile through the normal save system. The override survives Ascension until explicitly reset. The server retains a bounded 30-entry admin audit log. Unpublished Studio continues to use the existing memory-only preview behavior. The allowlist lives in `Services/AdminConfig.lua` on the server; no extra users, groups or creator-role bypasses are enabled.

### Square shop catalog

The shop now uses square, model-icon purchase tiles inspired by the supplied UI pack, while retaining this game's colors, rounded outlines and Fredoka lettering. Scroll through Garden Upgrades, Defenses and Pets & Eggs; all 15 tiles spend coins through the existing server-validated actions. Sell and Extras are not shop categories. Selling remains at the Sell stand/navigation button; optional purchases remain separate under More. Tile prices and owned/max states update after a purchase without resetting scroll during regular HUD updates. Phone layouts use three columns in landscape and two in portrait, with movement controls hidden while the shop is open.

A runnable Rojo source project, also installed into the connected Studio place. This is a playable first version, not a certified public-release build. See [TEST_REPORT.md](TEST_REPORT.md) for verified behavior and release gaps.

## Play

Press Play in Studio. A starter tree grows in five seconds. Roll a part, open **Tree Parts**, equip it, and Plant the new build on the Growth Pad. The old tree continues producing. Collect fruit by walking near it; step into the **red SELL zone** at the central market to sell automatically (or use the stand prompt). Buy **LeafPower** and other upgrades, hatch/equip/fuse pets, and add production plots. When a new tree is Ready, choose an unlocked, empty plot to plant into.

The top Shop, Garden and Sell buttons teleport to server-selected locations without opening menus. Click **Tree Parts** for the category-grid inventory and live build preview, or the **Bag** counter for fruit details and a rotating fruit model. Use **Growth** inside Tree Parts to swap a ready tree. Secondary controls are under More. Shop still opens when you walk into its blue zone. Chill Mode defaults **on**. Turn it off to participate in public-server sabotage. Both parties must opt in and finish five minutes of active play.

## Source layout

```
default.project.json
src/
  ReplicatedStorage/
    Config/init.lua                # all economic tables, odds, prices, product IDs
    Types.lua, Remotes.lua
    Util/                          # pure math, seeded RNG, profiles, validation, formatting
  ServerScriptService/
    Main.server.lua                # network boundary and shared schedulers
    Services/                      # Data, World, Game, Growth, Event, Purchase
  StarterPlayer/StarterPlayerScripts/
    Main.client.lua
    Controllers/                   # UI and cosmetic effects
  StarterGui/                      # UI is generated on PlayerGui in code
  TestService/                     # Acceptance, Integration, Simulation modules
```

Inside Studio, source is under **ServerScriptService → BuildATree**, **ReplicatedStorage → BuildATree**, and **StarterPlayer → StarterPlayerScripts → BuildATree**. The jumping test has been removed.

## Rojo setup

1. Install Rust/Cargo and Rojo (`cargo install rojo --locked`), or install an official Rojo release. Install the matching Rojo Studio plugin.
2. Open a terminal in this folder and run `rojo serve default.project.json`.
3. In Studio, open the Rojo plugin, connect to the displayed local port, review the sync changes, and accept them.
4. Press Play. Alternatively, `rojo build default.project.json -o build/BuildATree.rbxlx` builds a place file after creating `build/`.
5. Treat these source files as canonical. Export Studio edits to source before a future sync overwrites them.

The current connected place already contains the source; Rojo installation is only needed for ongoing source sync. No other package manager or runtime dependency is required by the game. World objects and companions use primitive Parts. Leaderboard podiums load player avatars through Roblox's avatar service. No manually supplied art or audio IDs are required.

## Implemented

- Four slots with seven named parts each, free Common defaults, seeded server rolls, published/effective odds, Epic and Legendary pity, inventory, equip/sell, batch unlocks, auto-roll entitlement and cosmetic vertical reel/reveal.
- Exact fruit/interval/tier/grow equations in pure modules; independent fruit mutations, colors/materials/particles; bag capacity, collection radius, fruit expiry and a bounded 150-part pool.
- Session-locked profiles, schema/migration hook, retry/backoff, autosave, shutdown save, timestamp-based boosts/offline production/growth. Unpublished Studio falls back to clearly logged, **nonpersistent** preview with purchases disabled.
- Main plot + Growth Pad, six coin-unlockable production plots; the optional entitlement unlocks two earlier, capped at six, hold-E ready-tree placement into highlighted empty plots, progress bars, local sapling scaling, watering, rate settlement, private-server growth and luck bonuses.
- Striped market stands with automatic sell/shop zones; bag, radius, discount, plot, batch, pet-slot and LeafPower upgrades. LeafPower adds another flat leaf-power contribution to the specified fruit-value equation, making the requested long-term economy attainable without changing its formula.
- Three egg tiers, five pets each, three-to-six equip slots, pet stats, Shiny fusion and local following companions.
- Queued Golden Rain, Windstorm and cooperative clickable Pest Raid; offline production capped by entitlement, full-speed offline growth, optional auto-roll, range ring, idle/offline reminder.
- Shake, Pest, Weather Trap and Prune with range, target cooldown, active-play protection, opt-out and per-victim theft budget. Scarecrow, spray, fence and shield defenses have visible primitive indicators.
- Ascension, permanent Golden Saplings, reset/replant, optional purchases, receipt ledger and deterministic Maxer.
- Top-left settings gear, tutorial progression/skip, number formatting, four physical global/server boards with top-three avatar podiums, Mythic/Godly announcements, VIP tag and gated terrace, basic pickup/sell/ready/reveal effects. Audio goes through `SoundConfig` and is intentionally silent until IDs are supplied.

## Security and persistence

Clients send exact-schema intents with small identifiers only. Unknown fields (including forged amounts, timestamps, progress and rewards), NaN, oversized strings and invalid action names are rejected. A token bucket limits the network boundary; gameplay adds roll, water, purchase, raid and target cooldowns. There are no client-callable RemoteFunctions.

DataStore records have a unique session token and expiring lease. Every write checks ownership using UpdateAsync. Transactional receipts copy the profile, apply the reward plus receipt ID to that copy, save them atomically, then publish the saved copy to the running game. A duplicate ID returns success without applying rewards twice. Lost sessions disconnect rather than continuing to write conflicting data.

`ProcessReceipt` defers while no player/profile/durable store is available. Product IDs default to zero; zero IDs cannot open purchase prompts. Unknown real product IDs defer for operator investigation. Configure each product ID exactly once. Do not remove an ID while receipts may remain pending.

Grow Now saves the requested tree ID before prompting and recomputes remaining time before granting. If the tree has changed or finished, it is **not** upgraded again: the purchase becomes a saved bracket-specific growth credit, redeemable explicitly on an eligible future tree. This avoids charging for nothing or leaving a legitimate receipt pending forever. Tutorial trees never accept skips. Coin packs and paid luck prompts are blocked when PolicyService restricts paid random items or policy lookup fails.

An optional cumulative prompt budget is enforced before prompting. This is an in-game self-limit, not a replacement for Roblox parental or account spending controls. A legitimate paid receipt is fulfilled even if the player changes their self-limit afterward.

## Tests

Run in Studio's Command Bar (Edit mode):

```lua
require(game.TestService.BuildATreeTests.Acceptance).Run()
require(game.TestService.BuildATreeTests.WorldUX).Run()
require(game.TestService.BuildATreeTests.Simulation).Run(42, 3600)
require(game.TestService.BuildATreeTests.Simulation).Median()
```

Run the reversible live smoke check on the **server** during a Studio playtest:

```lua
game.ServerScriptService.BuildATree.StudioChecks:Invoke(game.Players:GetPlayers()[1], "Run")
```

The Studio-only BindableFunction is not created on public servers. The smoke check temporarily replaces the test player's in-memory profile, exercises real game services and restores it. It never prompts purchases or deliberately writes test profiles to a production key. Do not run it concurrently with a save/purchase or manual gameplay.

The legacy simulation uses seeded active players, instant collection/sales, no paid boosts, no sabotage, no pets/events, upgrade priority and an income-relative roll budget. The shared value calculator now includes part mutation bonuses. Its automatic occupied-plot replacement policy differs from the current empty-only placement flow; revise that policy before treating new runs as current economy validation. It models all purchased production plots and an occupied growth pad. It asserts that production is never removed by a growing replacement; the first tutorial five seconds are the documented exception. It flags long inactivity and missed balance targets. These are policy-model results, **not measured median human-player outcomes**.

## Manual steps

1. **Publish a private TEST place**, enable Studio API access in Game Settings → Security, and verify persistent saves across rejoin. Never enable untrusted Studio plugins against production data.
2. Set the place's maximum players to **8**, matching `Runtime.MaxPlayers`; verify multi-client public and private servers. Raise the garden allocation limit before raising player count.
3. Create the gamepasses and developer products in Creator Dashboard, set real IDs in Config, confirm displayed prices match the actual listings, and test cancellation, pending/retry receipts, duplicate receipt delivery and policy-restricted accounts in the published test experience.
4. Private servers are configured and priced in Creator Dashboard → Monetization → Private Servers. Choose a subscription price after testing demand; the code detects private/reserved-server IDs and grants the configured free bonuses. No private-server price is hardcoded or claimed to be optimal.
5. Supply owned/licensed audio IDs in `SoundConfig`, or leave them empty for silent play. Configure Roblox music/SFX permissions for those assets.
6. Review the experience questionnaire, paid-random-item policy disclosures, supported regions and account controls before enabling paid random currency/luck. Test existing paid entitlements when a player's policy eligibility changes.
7. Complete the release-gap checks in TEST_REPORT, run a full hour with multiple real clients, tune the economy from observed play and profile budgets, and then publish the reviewed build publicly.

## Deliberately disabled / release gaps

- All actual sales and audio are placeholders until IDs are configured. Real DataStore/rejoin/session contention and real Marketplace receipt delivery could not be verified in the unpublished connected place.
- Global OrderedDataStore reads/writes and cross-server ranking still need published-place verification. Elaborate custom pet silhouettes, texture unlock cosmetics, particle trails/aura tiers, a fully authored icon reel, count-up sell animation, targeted world-space tutorial arrows, automatic friction-based purchase prompts, and a direct revenge-target button remain follow-up polish.
- We do not simulate input, evade Roblox idle disconnects or claim to extend Roblox's platform AFK timeout. Offline earnings and growth provide the supported continuation path. Private servers receive the coded economy/growth bonuses, not a fabricated engine timeout override.
- Economy targets are approximations, not all met. The current 21-seed model is faster at 5–15 minutes than the brief, close to the hour target, and needs human playtesting. See exact results in TEST_REPORT.
- Monetization and concurrency tests below remain release gates. This should be treated as a tested playable prototype until those gates pass, not advertised as fully publish-ready.

## Parts and harvest inventory update

Tree Parts has All Parts, Trunk, Leaves, Roots and Fruit tabs, paginated model-thumbnail grids, a selection/details panel, equip/sell actions, and a rotating preview of the currently equipped build. Common defaults can always be equipped again. Equipped inventory parts must be replaced before they can be sold.

Bag records retain server-supplied fruit name, rarity, mutation, exact coin value, quantity and acquisition timestamps. Identical fruit collected during one minute can share a stack; the details show first and last acquisition times in UTC. Old aggregate-only saves migrate to Saved Harvest without losing coins or inventing timestamps. The profile schema is now version 3, using the existing DataStore namespace.

Fruit falls from the canopy and bounces into place before it becomes collectible. Recycling cancels any outstanding tween. Full-bag collection attempts trigger red BAG FULL! CLICK SELL! text and a bobbing arrow toward the Sell teleport. Selling clears the warning.

Sign boards sit in front of their supporting posts and use a single outward-facing text surface with a depth offset. Inventory modals temporarily hide mobile movement controls and restore them when closed.

## Compact navigation and world interactions

More contains Odds, Ascension, Sabotage, Pets & Eggs, Passes, plus Admin for the authorized owner. These are square bubble tiles in a non-scrolling grid. Parts and Bag keep their existing external buttons. Settings opens from the round gear immediately after Roblox's topbar controls. The two-arrow Auto-Roll button sits beside Roll on desktop and immediately above its left edge on narrow screens; the existing Auto-Roll entitlement still applies.

Each manual or automatic roll chooses the largest unlocked, affordable batch, capped by inventory space. Costs include each successive roll's price increase. Partial batches can contain any count up to the unlocked maximum. Clients cannot supply a batch count.

Hold E near a ready growth-pad tree to select a destination. Only unlocked, empty plots on your own land glow. Hover adds an outline; click or tap places the tree. Escape/right-click cancels, and selections expire after 60 seconds. If all unlocked plots are occupied, the message directs the player to buy Tree Plots. Existing producing trees keep running. A purchased watering can uses the same in-world prompt while a tree is growing. Grow Now remains available in Passes.

Four physical boards around the market show global coins, global height, server coins and server height, each with three podium slots. Coin boards rank coins on hand; global balances can fall after spending. Global height preserves the best height reached, including across ascension; server height is the tallest currently producing tree. Server boards refresh every 5 seconds and global boards every 60 seconds. Coin scores use a monotonic integer logarithmic encoding to support the large economy; displayed global amounts are approximate at tiny relative increments. Podium avatars are cached (up to 24 templates), anchored and stripped of scripts. Empty ranks remain empty.

Global data requires a published test experience with API access. An unpublished preview displays an unavailable status instead of invented global ranks. Verify multi-server changes, zero balances, backend throttling, rank changes and avatar loading before release. Optional leaderboard writes run after profile saving on departure so ranking failures cannot delay the player's primary save.


## Catalog, part mutations and height expansion — October 31, 2026

There are **84 rollable parts**: three catalog choices in each of four slots for all seven rarities. Original names remain the first choice, so starter parts and existing saved identities stay valid. The server first rolls rarity with the existing luck/pity system, then chooses a slot and a catalog variant uniformly. Rarity odds are unchanged.

Every newly rolled part independently rolls the existing mutation distribution: None 80% (1×), Golden 12% (2×), Rainbow 5% (5×), Void 2.5% (15×), Cosmic 0.5% (50×). Rarity luck does not change mutation odds. The four equipped part mutation multipliers are **averaged** into one tree-value bonus: one Golden part and three normal parts give 1.25×; four Cosmic parts give 50×. This bonus multiplies the existing harvested-fruit mutation once. Raw part stats and root timing remain unchanged. A pruned slot contributes 1× while disabled.

Inventory thumbnails, selected details, roll reveals, the rotating tree preview and world trees show part mutations. Each catalog variant also has a distinct primitive silhouette. Admin can select each variant or grant all 84; deterministic admin grants are unmutated. Grant authorization remains server-side and self-only.

Each non-tutorial planting samples a server-owned height scale between **0.75 and 1.50** once. The visual grows toward that height and retains it when ready, placed, saved and restored. Taller trees do not increase coin value automatically. Tutorial and legacy trees use scale 1. Height is measured from the model base to canopy top, shared by models and leaderboard values, with base height 12 + average-tier × 1.5 studs. Inventory previews show the possible height range; the growth billboard shows the current height and the ready billboard shows final height. Part mutations stay attached to the build throughout.

Tree Plots now progresses through **1, 2, 3, 4, 5, 6**. Incremental costs retain the existing curve: 1,000 / 10,000 / 100,000 / 1,000,000 / 10,000,000 coins. The garden has six production beds and one separate Growth Pad. ExtraPlots adds two early unlocks with a strict six-bed cap; the shop blocks purchases once six are available, including through the pass.

Schema 3 retains the existing profile-store namespace and bag migration. Old parts gain an explicit None mutation without rerolling their stats or identities. Old growth and plot records gain height scale 1.

## Imported starter models — October 31, 2026

The user-supplied OakTrunk, CloverLeaves, Taproot and Apple GLBs were imported with Studio's 3D Importer under the current user creator. Seven mesh resources are stored as four reusable Models in ReplicatedStorage.BuildATree.Assets.Starter. The same templates are included in src/ReplicatedStorage/Assets/Starter.rbxmx for Rojo, and original GLB/OBJ/MTL source files are retained in asset-sources/starter. The supplied asset-building Python script was not executed or incorporated.

ImportedModels adapts these exact Common catalog identities to existing inventory previews and mixed tree builds, preserves the original flat material colors, and applies part mutations to trunk/leaves/roots and the apple body. The apple stem and leaf retain their own colors. Trunks/canopies fit existing height targets; the downward root mesh is compressed into an above-soil root base. Other catalog parts keep their existing visual models.

The imported apple is also used for hanging apples, Fruit Bag previews, and falling/collectible Apple fruit. Falling apples use three welded visual meshes on the existing pooled fruit anchor. Fall/bounce tweens now update CFrame so attached components move together. Recycling destroys the visual before returning the anchor to the pool. Mesh files are uploaded assets owned by the import creator; a different creator must arrange asset permissions or reimport the bundled original source files.

## Edit the starter tree visually

Stop Play. In Workspace, expand StarterTreeEditor and select its Trunk, Leaves or Roots Model group. Press F to focus it and use Move/Rotate. Position, rotation and mesh-size edits inside the named groups are copied into the assembled tree. The three Apple Models also control hanging-fruit placement. Keep EditorOrigin and each DefaultPivot value intact. Position/rotation edits are read on the next Play; the reference moves into ReplicatedStorage at runtime and is not shown in the garden. Moving the complete editor tree changes only its workbench location. This editor controls assembled-tree geometry. Individual inventory part models and dropped fruit retain the Assets.Starter templates. Save the place after editing. The bundled RBXMX reflects the layout at handoff; future Studio edits also need exporting to update the source archive.


## Edit the starter tree visually

Stop Play. In Workspace, expand StarterTreeEditor and select its Trunk, Leaves or Roots Model group. Press F to focus it and use Move/Rotate. Position, rotation and mesh-size edits inside the named groups are copied into the assembled tree. The three Apple Models also control hanging-fruit placement. Keep EditorOrigin and each DefaultPivot value intact. Position/rotation edits are read on the next Play; the reference moves into ReplicatedStorage at runtime and is not shown in the garden. Moving the complete editor tree changes only its workbench location. This editor controls assembled-tree geometry. Individual inventory part models and dropped fruit retain the Assets.Starter templates. Save the place after editing. The bundled RBXMX reflects the layout at handoff; future Studio edits also need exporting to update the source archive.


## Common model set 2 and 3

All 12 Common catalog parts now use imported models. Pine, Maple, Oakleaf, Sprout, Fibrous Root, Knotted Root, Cherry and Orange were added as eight separate models with 25 material meshes. They share the existing inventory, tree assembly, mutation and fruit-pool paths. StarterTreeEditor continues to control only the original Oak/Clover/Taproot/Apple build; its user-edited geometry is preserved. Other Common parts retain their own model shapes, and higher-rarity parts retain existing visuals. Original source files are bundled in asset-sources/common-set2 and common-set3.


## Standardized Common and Uncommon revision

The active model set now contains 24 imported parts: revised Common plus all Uncommon. Assembly preserves authored source coordinates: roots at Y=0, trunk at Y=0.6, canopy at Y=3.6. The 6.4-stud source tree scales uniformly to its server-owned height. Canopy fruit sockets and fruit attachment offsets come from the supplied assembly contract; hanging fruit is scaled to 65% of tree scale and its attachment meets the socket. Root/trunk/canopy shapes are no longer independently stretched. Procedural higher-rarity pieces normalize to compatible join heights for mixed builds. Mutations recolor fruit flesh/rind while retaining stem/leaf colors.

StarterTreeEditor was refreshed from standardized geometry. Whole component and contained-mesh edits still carry into gameplay. The previous hand-edited layout and old mesh templates are preserved in asset-sources/previous-layout and Studio ServerStorage.BeforeStandardizedRevision. They are reference backups, not active geometry overrides. Revised source files and assembly metadata are under asset-sources/standardized. Supplied Python scripts were not executed.
