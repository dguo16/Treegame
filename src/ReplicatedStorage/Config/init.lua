-- All economy, timing, visual, safety and marketplace tuning.
local C = {}
C.Schema = 11
C.Data = {Store = "BuildATree_v1", LockSeconds = 180, Autosave = 60, Retries = 4, Backoff = 1, CloseTimeout = 25}
C.Runtime = {Tick = 1, PickupTick = 0.25, AutoSellSeconds = 15, SaveTick = 60, MaxFruit = 150, FruitLifetime = 90, FruitSize = 1.25, FruitSpacing = 7, MaxPlayers = 8, PlotSpacing = 70, WorldRadius = 340, RemoteBurst = 12, RemotePerSecond = 4, RollCooldown = 2.5, UpsellCooldown = 90, ShopRange = 18, SabotageRange = 24, MaxInventory = 500, MaxPets = 150, MaxCoins = 1e30}
C.Rarities = {
 {Name="Common", Weight=60, Color=Color3.fromRGB(183,199,182), Min=1, Max=1.2, Effect=1, Announce=false, Grow=5},
 {Name="Uncommon", Weight=25, Color=Color3.fromRGB(103,228,135), Min=1.2, Max=1.4, Effect=2, Announce=false, Grow=10},
 {Name="Rare", Weight=10, Color=Color3.fromRGB(93,179,255), Min=1.4, Max=1.6, Effect=3, Announce=false, Grow=45},
 {Name="Epic", Weight=4, Color=Color3.fromRGB(199,121,255), Min=1.6, Max=1.8, Effect=4, Announce=false, Grow=180},
 {Name="Legendary", Weight=.9, Color=Color3.fromRGB(255,207,79), Min=1.8, Max=2, Effect=5, Announce=false, Grow=600},
 {Name="Mythic", Weight=.09, Color=Color3.fromRGB(255,101,144), Min=2, Max=2.2, Effect=6, Announce=true, Grow=1800},
 {Name="Godly", Weight=.01, Color=Color3.fromRGB(128,255,246), Min=2.2, Max=2.4, Effect=7, Announce=true, Grow=3600},
}
C.Slots = {"Trunk", "Leaves", "Roots", "Fruit"}
C.PartNames = {
 Trunk={"Oak", "Willow", "Sapphire Birch", "Amethyst Spiral", "Sunwood", "Dragon Bark", "Celestial Pillar"},
 Leaves={"Clover", "Fern", "Blue Maple", "Lavender Fan", "Solar Crown", "Phoenix Frond", "Starlight Canopy"},
 Roots={"Taproot", "Vine", "Coral Root", "Crystal Root", "Gilded Root", "Ember Tendril", "Astral Anchor"},
 Fruit={"Apple", "Pear", "Crystalberry", "Plum", "Starfruit", "Dragonfruit", "Moonfruit"},
}
-- Rare fruit replacements retain tier/variant identity through NameAliases.
C.PartVariants = {
 Trunk={{C.PartNames.Trunk[1],"Pine","Maple"},{C.PartNames.Trunk[2],"Aspen","Silver Birch"},{C.PartNames.Trunk[3],"Azure Cedar","Cobalt Palm"},{C.PartNames.Trunk[4],"Violet Willow","Rosewood Twist"},{C.PartNames.Trunk[5],"Amber Redwood","Royal Mahogany"},{C.PartNames.Trunk[6],"Phoenix Timber","Ancient Wyrmwood"},{C.PartNames.Trunk[7],"Infinity Spire","Worldtree Heart"}},
 Leaves={{C.PartNames.Leaves[1],"Oakleaf","Sprout"},{C.PartNames.Leaves[2],"Ivy","Palm Fan"},{C.PartNames.Leaves[3],"Frost Fern","Azure Blossom"},{C.PartNames.Leaves[4],"Orchid Cloud","Violet Wings"},{C.PartNames.Leaves[5],"Golden Halo","Amber Bloom"},{C.PartNames.Leaves[6],"Dragon Wings","Eternal Blossom"},{C.PartNames.Leaves[7],"Nebula Veil","Infinity Crown"}},
 Roots={{C.PartNames.Roots[1],"Fibrous Root","Knotted Root"},{C.PartNames.Roots[2],"Mangrove Root","Creeping Root"},{C.PartNames.Roots[3],"Frost Root","Azure Tangle"},{C.PartNames.Roots[4],"Amethyst Root","Orchid Tether"},{C.PartNames.Roots[5],"Royal Root","Sunstone Root"},{C.PartNames.Roots[6],"Phoenix Root","Ancient Coil"},{C.PartNames.Roots[7],"Eternity Root","Galaxy Tether"}},
 Fruit={{C.PartNames.Fruit[1],"Cherry","Orange"},{C.PartNames.Fruit[2],"Peach","Lemon"},{C.PartNames.Fruit[3],"Hazelfruit","Frostberry"},{C.PartNames.Fruit[4],"Pomegranate","Passionfruit"},{C.PartNames.Fruit[5],"Golden Mango","Sunmelon"},{C.PartNames.Fruit[6],"Phoenix Berry","Ember Peach"},{C.PartNames.Fruit[7],"Galaxy Grape","Infinity Fig"}},
}
C.Economy = {ValueScale=25, RarityFactor=1.17, MutationCeiling=2, RootIntervals={5,3.5,2.5,1.75,1.2,.8,.5}}
C.Math = {BaseFruitValue=1, LeafBase=1, BaseInterval=5, RootBase=.15, MinInterval=.5, MinGrowSeconds=5, MaxGrowSeconds=3600, RebirthPerSapling=2.5}
C.Roll = {SlowAfter=50, SlowGrowth=1.02, HardCap=1500000, BaseCost=10, CostGrowth=1.15, EpicPity=50, LegendaryPity=300, PartSellFraction=.4, FirstCoins=35, BatchSizes={1,5,10}, BatchPrice={0,2500,25000}}
C.Mutations = {
 {Name="None", Weight=80, Mult=1, Color=Color3.fromRGB(239,86,72), Material=Enum.Material.SmoothPlastic, Particles=0},
 {Name="Golden", Weight=12, Mult=2, Color=Color3.fromRGB(255,206,49), Material=Enum.Material.Metal, Particles=3},
 {Name="Rainbow", Weight=5, Mult=5, Color=Color3.fromRGB(111,255,219), Material=Enum.Material.Neon, Particles=6},
 {Name="Void", Weight=2.5, Mult=15, Color=Color3.fromRGB(115,46,181), Material=Enum.Material.Neon, Particles=10},
 {Name="Cosmic", Weight=.5, Mult=50, Color=Color3.fromRGB(210,239,255), Material=Enum.Material.Neon, Particles=16},
}
C.Growth = {PrivateRate=1.25, WaterReduction=10, WaterCooldown=30, WaterPrice=500, MainPlots=1, MaxCoinPlots=6, TotalPlots=6, HeightMin=.75, HeightMax=1.5, QueueLimit=2, MaxPads=3, Fields={"Growth","Growth2","Growth3"}, ThirdFreeAscensions=3, HighestTierWeight=.5}
C.Upgrades = {
 LeafPower={Values={1,2,4,8,64,224}, Prices={25,100000,1500000,15000000,75000000}, BasePrice=25, PriceGrowth=10},
 Bag={Values={10,25,50,100,200,500}, BasePrice=50, PriceGrowth=5},
 Radius={Values={8,12,18,26,34,40}, BasePrice=100, PriceGrowth=4},
 Discount={Values={1,.95,.9,.85,.8,.7}, BasePrice=250, PriceGrowth=5},
 Plots={Values={1,2,3,4,5,6}, BasePrice=1000, PriceGrowth=10},
 PetSlots={Values={3,4,5,6}, BasePrice=5000, PriceGrowth=10},
 Batch={Values={1,5,10}, BasePrice=2500, PriceGrowth=10},
}
C.Pets = {EggPrices={250,5000,100000}, Themes={"Squirrel","Bird","Beetle"}, Names={"Acorn", "Moss", "Bloom", "Crystal", "Sun"}, Weights={60,25,10,4,1}, Coin=.04, Luck=.03, Radius=.5, Speed=.3, Growth=.03, Shiny=2, MaxEquip=6}
C.Events = {Every=900, Order={"Golden Rain","Windstorm","Giant Pest Raid"}, Duration={["Golden Rain"]=120,Windstorm=60,["Giant Pest Raid"]=120}, RainCoins=5, RainGrowth=3, WindGrowth=5, RaidHealth=100, RaidReward=250, RaidHitCooldown=.2}
C.Sabotage = {Protection=300, Cooldown=30, PestDuration=20, PestRate=.5, PruneDuration=15, ShakeFraction=.1, MinuteCap=.25, Stun=3, ShieldDuration=60, TrapDuration=20, TrapRate=.5}
C.Defenses = {Scarecrow=250, BugSpray=500, Fence=2000, Shield=1000}
C.Offline = {Seconds=7200, PassSeconds=28800, Fraction=.5, InfiniteRadius=100, PrivateLuck=1.1}
C.Rebirth = {ThresholdGrowth=1.3, Threshold=1e9, SaplingDivisor=1e9, Exponent=.5, StartingCoins=35}
C.Simulation = {Seconds=129600, Seeds=21, Ascensions=5, ActiveSaleEvery=12, ReplaceImprovement=1.01, Policies={Balanced={RollShare=.5}, RollFocused={RollShare=.75}, UpgradeFocused={RollShare=.25}}, Casual={SaleEvery=45,SessionSeconds=1200,SessionsPerDay=3,DaySeconds=86400}}
-- Every price is a DRAFT proposal, never a configured/live price. IDs remain zero.
C.Monetization={EnableNewPurchases=false,MutationLuckEnabled=false,MutationLuckReview="Pending policy review; calculator only, never offered",CoinPackCap=100000000,StarterCoinCap=50000000}
C.PassOrder={"Coins","GrowthSpeed","ThirdPad","AutoSell","VIP","Luck","InfiniteBag","InfiniteRange","Speed","AutoRoll","Offline","Cosmetics"}
C.Passes={
 Coins={Name="Double Coins",Id=0,Price=0,ProposedPrice=399,PaidRandom=true,Description="×2 fruit value once, after rarity, Leaf Power, mutations, Saplings, pets, collection and events."},
 GrowthSpeed={Name="Double Growth Speed",Id=0,Price=0,ProposedPrice=299,PaidRandom=true,Description="×2 growth on every unlocked pad. Multiplies pets, private ×1.25 and one weather event: Rain ×3 OR Wind ×5."},
 ThirdPad={Name="Third Growth Pad",Id=0,Price=0,ProposedPrice=349,PaidRandom=true,Description="After first Ascension: pad 3 and queue 2 → 3. Free at third Ascension. No plots or early pad 2."},
 AutoSell={Name="AutoSell + Sell Anywhere",Id=0,Price=0,ProposedPrice=249,PaidRandom=true,Description="Sell from anywhere. With AutoSell ON, sells a full bag or every 15 seconds, including Infinite Bag."},
 VIP={Name="VIP",Id=0,Price=0,ProposedPrice=799,PaidRandom=true,Description="×1.10 fruit value, VIP terrace and golden garden petals. No rarity or mutation luck."},
 Luck={Name="Luck",Id=0,Price=0,ProposedPrice=399,PaidRandom=true,Description="×2 non-Common rarity weights, then normalize. Stacks with pets/earned luck. Exact next-roll Odds; no mutation or egg effect."},
 InfiniteBag={Name="Infinite Bag",Id=0,Price=0,ProposedPrice=449,PaidRandom=true,Description="No fruit-count bag limit. Does not sell fruit or change value/odds; AutoSell is separate."},
 InfiniteRange={Name="Infinite Range",Id=0,Price=0,ProposedPrice=349,PaidRandom=true,Description="100-stud pickup radius (not global). Collection convenience only; no mutation or egg effect."},
 Speed={Name="Speed",Id=0,Price=0,ProposedPrice=149,PaidRandom=true,Description="×2 walking speed after pet speed. Does not change tree growth or odds."},
 AutoRoll={Name="Auto Roll",Id=0,Price=0,ProposedPrice=299,PaidRandom=true,Description="Toggle automatic affordable batches. Same coin prices, inventory limit, guarantees and 2.5-second cooldown."},
 Offline={Name="Offline",Id=0,Price=0,ProposedPrice=299,PaidRandom=true,Description="Offline coin cap 2 → 8 hours, at the same 50% rate. No extra growth rate or offline queue chaining."},
 Cosmetics={Name="Cosmetic Bundle",Id=0,Price=0,ProposedPrice=199,PaidRandom=false,Description="Sunset Glow aura + Festival Pinwheel decoration. Visual only. Also 16 + 20 participation medals in Journal."},
}
C.ProductOrder={"StarterPack","CoinsS","CoinsM","CoinsL","SuperLucky","UltraLucky"}
C.Products={
 StarterPack={Name="Starter Pack",Id=0,Price=0,ProposedPrice=99,PaidRandom=true,Once=true,Seconds=1800,Cap=50000000,Credits=2,Cosmetics={"SproutPlanter","Bud"},Description="Once per account: 30 min reward reference income (cap 50M), 2 Grow10 credits, Sprout Planter and Bud title. No random grant."},
 CoinsS={Name="Small Coins",Id=0,Price=0,ProposedPrice=49,PaidRandom=true,Seconds=60,Cap=100000000,Description="1 minute of server reward reference income, capped at 100M. Can fund random rolls/eggs."},
 CoinsM={Name="Medium Coins",Id=0,Price=0,ProposedPrice=199,PaidRandom=true,Seconds=300,Cap=100000000,Description="5 minutes of server reward reference income, capped at 100M. Can fund random rolls/eggs."},
 CoinsL={Name="Large Coins",Id=0,Price=0,ProposedPrice=799,PaidRandom=true,Seconds=1800,Cap=100000000,Description="30 minutes of server reward reference income, capped at 100M. Can fund random rolls/eggs."},
 SuperLucky={Name="Super Lucky",Id=0,Price=0,ProposedPrice=99,PaidRandom=true,Duration=900,Factor=2,Description="15 minutes at ×2 rarity luck. Replaces current boost factor and extends remaining time. No mutation/egg effect."},
 UltraLucky={Name="Ultra Lucky",Id=0,Price=0,ProposedPrice=249,PaidRandom=true,Duration=900,Factor=4,Description="15 minutes at ×4 rarity luck. Replaces current boost factor and extends remaining time. No mutation/egg effect."},
 Grow3={Name="Grow Now ≤3 min",Id=0,Price=0,ProposedPrice=5,PaidRandom=true,Limit=180},
 Grow10={Name="Grow Now ≤10 min",Id=0,Price=0,ProposedPrice=25,PaidRandom=true,Limit=600},
 Grow30={Name="Grow Now ≤30 min",Id=0,Price=0,ProposedPrice=49,PaidRandom=true,Limit=1800},
 Grow60={Name="Grow Now ≤60 min",Id=0,Price=0,ProposedPrice=99,PaidRandom=true,Limit=3600},
}
for _,items in {C.Passes,C.Products}do for _,item in items do item.Draft=true end end
C.GrowProducts={"Grow3","Grow10","Grow30","Grow60"}
C.News={Version="Growing Together",Entries={"Pad 2 is free at first Ascension. Pad 3 and queue +1 are free at third Ascension.","Confirm replacements, recover missing parts, and queue equipped builds.","Your third lifetime roll guarantees Rare or better. Daily rolls are free.","Finish Common–Epic name sets. Mutation sets earn lasting cosmetics; Legend is optional.","Visit and like server gardens. Spend participation medals on cosmetics in Journal → Medals."}}
C.Rewards = {
 ReferenceSeconds=604800, MaxReferenceIncome=100000, MaxRewardSeconds=3600, MaxRewardCoins=100000000, AuditLimit=128,
 LoginBase=100, LoginStep=25, LoginDays=7, LoginMinSeconds=300, LoginMaxSeconds=600,
 DailySeconds={DailyRolls=180,DailySold=300,DailyPlants=420},
 MilestoneSeconds={300,900,1800,3600},
 Milestones={Rolls={{10,100},{50,1000},{300,10000},{1000,100000}},Plants={{1,50},{6,500},{25,5000},{100,100000}},Sold={{25,100},{100,1000},{1000,10000},{10000,100000}},TotalCoins={{10000,1000},{1000000,10000},{100000000,100000},{1000000000,1000000}}},
 Daily={{Key="DailyRolls",Metric="Rolls",Need=5,Coins=100,Title="Roll 5 parts"},{Key="DailySold",Metric="Sold",Need=25,Coins=150,Title="Sell 25 fruit"},{Key="DailyPlants",Metric="Plants",Need=1,Coins=200,Title="Plant 1 tree"}}
}
C.Collection={
 CoreMaxTier=4, CoinPerSet=.01, LuckPerSet=.01, CoinCap=.04, LuckCap=.04, ExtraPetSlots=1,
 CoinSeconds=120, CoinFloor=50, CoinCapReward=1000000,
 MutationNeeds={Golden=6,Rainbow=4,Void=3,Cosmic=1}, MutationOrder={"Golden","Rainbow","Void","Cosmic"},
 Likes={1,10,25,100}, LikeRewards={"Friendly","HeartPlanter","HeartGlow","Favorite"},
 AnalysisLuck={1,1.36,2,2.72}, AnalysisSeeds=128, AnalysisRollLimit=20000,
}
C.Cosmetics={Bundle={"SunsetGlow","Pinwheel"},Featured={"GreenGlow","GoldGlow","StarPlanter","HeartGlow","SunsetGlow","Pinwheel","SproutPlanter","Bud"},AuraRate=.5,AuraDistance=90,Items={
 SunsetGlow={Name="Sunset Glow",Slot="Aura",Color={255,155,110}},
 Pinwheel={Name="Festival Pinwheel",Slot="Decoration",Color={170,225,255}},
 SproutPlanter={Name="Sprout Planter",Slot="Decoration",Color={125,230,155}},
 Bud={Name="Bud",Slot="Title"},
 GreenGlow={Name="Meadow Glow",Slot="Aura",Color={110,230,130}},
 BlueGlow={Name="Bluebell Glow",Slot="Aura",Color={100,180,255}},
 VioletGlow={Name="Orchid Glow",Slot="Aura",Color={190,130,255}},
 GoldGlow={Name="Golden Glow",Slot="Aura",Color={255,210,90}},
 RainbowGlow={Name="Rainbow Glow",Slot="Aura",Color={130,245,220}},
 VoidGlow={Name="Twilight Glow",Slot="Aura",Color={135,90,200}},
 CosmicGlow={Name="Starlight Glow",Slot="Aura",Color={200,245,255}},
 HeartGlow={Name="Heart Glow",Slot="Aura",Color={255,145,185}},
 FlowerPlanter={Name="Flower Planter",Slot="Decoration",Color={250,175,210}},
 BluePlanter={Name="Bluebell Planter",Slot="Decoration",Color={110,185,255}},
 StarPlanter={Name="Star Planter",Slot="Decoration",Color={255,215,90}},
 HeartPlanter={Name="Heart Planter",Slot="Decoration",Color={255,130,170}},
 Lantern={Name="Garden Lantern",Slot="Decoration",Color={255,225,145}},
 Collector={Name="Part Collector",Slot="Title"},CoreCollector={Name="Orchard Curator",Slot="Title"},
 GoldenFinder={Name="Golden Finder",Slot="Title"},RainbowFinder={Name="Rainbow Finder",Slot="Title"},VoidFinder={Name="Void Finder",Slot="Title"},CosmicFinder={Name="Cosmic Finder",Slot="Title"},
 LegendaryCollector={Name="Legendary Collector",Slot="Title"},MythicCollector={Name="Mythic Collector",Slot="Title"},GodlyCollector={Name="Godly Collector",Slot="Title"},
 TrunkCollector={Name="Trunk Curator",Slot="Title"},LeavesCollector={Name="Canopy Curator",Slot="Title"},RootsCollector={Name="Root Curator",Slot="Title"},FruitCollector={Name="Fruit Curator",Slot="Title"},
 Legend5={Name="Legendary Archivist",Slot="Title"},Legend6={Name="Mythic Archivist",Slot="Title"},Legend7={Name="Godly Archivist",Slot="Title"},
 LegendAll={Name="Living Legend",Slot="Title"},AllNames={Name="Worldtree Curator",Slot="Title"},
 Friendly={Name="Friendly Gardener",Slot="Title"},Favorite={Name="Garden Favorite",Slot="Title"},EventFriend={Name="Event Friend",Slot="Title"},
 },
 MedalShop={{Key="SproutPlanter",Cost=2},{Key="Bud",Cost=2},{Key="SunsetGlow",Cost=16},{Key="Pinwheel",Cost=20},{Key="FlowerPlanter",Cost=2},{Key="Lantern",Cost=4},{Key="GreenGlow",Cost=6},{Key="BlueGlow",Cost=8},{Key="EventFriend",Cost=10},{Key="GoldGlow",Cost=12}},
}

for tier=1,C.Collection.CoreMaxTier do for _,mutation in C.Collection.MutationOrder do
 C.Cosmetics.Items["Mutation"..tier..mutation]={Name=C.Rarities[tier].Name.." "..mutation.." Curator",Slot="Title"}
end end
for _,slot in C.Slots do C.Cosmetics.Items["Legend"..slot.."Collector"]={Name="Worldtree "..slot.." Curator",Slot="Title"}end
C.SoundConfig = {Giant="rbxasset://sounds/electronicpingshort.wav",Roll="",Tick="",Reveal="",Collect="",Sell="",Ready="",Music=""}
C.RarityEffects={MaxAccentParts=5,MaxAuraRate=4,Distance=90}
C.UI = {RollDuration=2.5, RevealDuration=.5, MinimumTouch=44, ToastSeconds=4, ComboSeconds=2, PitchCap=2, PitchStep=.1, PetBob=.4, PetDistance=4, Shake={0,0,0,.2,.2,.5,1}}
-- Harvest size is independent of rarity/mutation/pets. Expected value is exactly 1.
C.FruitSizes={
 {Name="Small",Weight=30,Value=.8,Scale=.8},
 {Name="Normal",Weight=60,Value=1,Scale=1},
 {Name="Large",Weight=9,Value=1.5,Scale=1.25},
 {Name="Giant",Weight=1,Value=2.5,Scale=1.6},
}
C.FruitInventory={VaultStacks=30,ShelfSlots=6,MaxSaleStacks=256,SaleCooldown=.4,MoveCooldown=.25,GiantCooldown=6,GiantGlowRange=6,ShelfFruitSize=1}
C.Inventory={PageSize=24, RotateSpeed=.28, TeleportCooldown=1.5, FullWarningCooldown=2, FullWarningSeconds=3, FallSeconds=.55, BounceSeconds=.25}
C.Salvage={Cooldown=3,ConfirmationSeconds=30}
C.Placement={HoldSeconds=.8,PromptRange=14,SelectionSeconds=60,GardenRange=75,WaterHold=.35}
C.Leaderboards={CoinsStore="BuildATree_Coins_v1",HeightStore="BuildATree_Height_v1",GlobalRefresh=60,ServerRefresh=5,AvatarRetry=60,Rows=10}
return C
