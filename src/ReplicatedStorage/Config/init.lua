-- All economy, timing, visual, safety and marketplace tuning.
local C = {}
C.Schema = 5
C.Data = {Store = "BuildATree_v1", LockSeconds = 180, Autosave = 60, Retries = 4, Backoff = 1, CloseTimeout = 25}
C.Runtime = {Tick = 1, PickupTick = 0.25, AutoSellSeconds = 15, SaveTick = 60, MaxFruit = 150, FruitLifetime = 90, FruitSize = 1.25, FruitSpacing = 7, MaxPlayers = 8, PlotSpacing = 70, WorldRadius = 340, RemoteBurst = 12, RemotePerSecond = 4, RollCooldown = 2.5, UpsellCooldown = 90, ShopRange = 18, SabotageRange = 24, MaxInventory = 500, MaxPets = 150, MaxRollExponent = 50, MaxCoins = 1e30}
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
 Fruit={"Apple", "Pear", "Blueberry", "Plum", "Starfruit", "Dragonfruit", "Moonfruit"},
}
-- Original names remain stable for existing saves and starter parts.
C.PartVariants = {
 Trunk={{C.PartNames.Trunk[1],"Pine","Maple"},{C.PartNames.Trunk[2],"Aspen","Silver Birch"},{C.PartNames.Trunk[3],"Azure Cedar","Cobalt Palm"},{C.PartNames.Trunk[4],"Violet Willow","Rosewood Twist"},{C.PartNames.Trunk[5],"Amber Redwood","Royal Mahogany"},{C.PartNames.Trunk[6],"Phoenix Timber","Ancient Wyrmwood"},{C.PartNames.Trunk[7],"Infinity Spire","Worldtree Heart"}},
 Leaves={{C.PartNames.Leaves[1],"Oakleaf","Sprout"},{C.PartNames.Leaves[2],"Ivy","Palm Fan"},{C.PartNames.Leaves[3],"Frost Fern","Azure Blossom"},{C.PartNames.Leaves[4],"Orchid Cloud","Violet Wings"},{C.PartNames.Leaves[5],"Golden Halo","Amber Bloom"},{C.PartNames.Leaves[6],"Dragon Wings","Eternal Blossom"},{C.PartNames.Leaves[7],"Nebula Veil","Infinity Crown"}},
 Roots={{C.PartNames.Roots[1],"Fibrous Root","Knotted Root"},{C.PartNames.Roots[2],"Mangrove Root","Creeping Root"},{C.PartNames.Roots[3],"Frost Root","Azure Tangle"},{C.PartNames.Roots[4],"Amethyst Root","Orchid Tether"},{C.PartNames.Roots[5],"Royal Root","Sunstone Root"},{C.PartNames.Roots[6],"Phoenix Root","Ancient Coil"},{C.PartNames.Roots[7],"Eternity Root","Galaxy Tether"}},
 Fruit={{C.PartNames.Fruit[1],"Cherry","Orange"},{C.PartNames.Fruit[2],"Peach","Lemon"},{C.PartNames.Fruit[3],"Blackberry","Frostberry"},{C.PartNames.Fruit[4],"Pomegranate","Passionfruit"},{C.PartNames.Fruit[5],"Golden Mango","Sunmelon"},{C.PartNames.Fruit[6],"Phoenix Berry","Ember Peach"},{C.PartNames.Fruit[7],"Galaxy Grape","Infinity Fig"}},
}
C.Math = {BaseFruitValue=1, LeafBase=1, BaseInterval=5, RootBase=.15, MinInterval=.5, MinGrowSeconds=5, MaxGrowSeconds=3600, RebirthPerSapling=.25}
C.Roll = {BaseCost=10, CostGrowth=1.15, EpicPity=50, LegendaryPity=300, PartSellFraction=.4, FirstCoins=35, BatchSizes={1,5,10}, BatchPrice={0,2500,25000}}
C.Mutations = {
 {Name="None", Weight=80, Mult=1, Color=Color3.fromRGB(239,86,72), Material=Enum.Material.SmoothPlastic, Particles=0},
 {Name="Golden", Weight=12, Mult=2, Color=Color3.fromRGB(255,206,49), Material=Enum.Material.Metal, Particles=3},
 {Name="Rainbow", Weight=5, Mult=5, Color=Color3.fromRGB(111,255,219), Material=Enum.Material.Neon, Particles=6},
 {Name="Void", Weight=2.5, Mult=15, Color=Color3.fromRGB(115,46,181), Material=Enum.Material.Neon, Particles=10},
 {Name="Cosmic", Weight=.5, Mult=50, Color=Color3.fromRGB(210,239,255), Material=Enum.Material.Neon, Particles=16},
}
C.Growth = {PrivateRate=1.25, WaterReduction=10, WaterCooldown=30, WaterPrice=500, MainPlots=1, MaxCoinPlots=6, ExtraPassPlots=2, TotalPlots=6, HeightMin=.75, HeightMax=1.5, QueueLimit=2}
C.Upgrades = {
 LeafPower={Values={0,100,500,2000,5000,10000}, Prices={25,10000,150000,3000000,1000000000}, BasePrice=25, PriceGrowth=10},
 Bag={Values={10,25,50,100,200,500}, BasePrice=50, PriceGrowth=5},
 Radius={Values={8,12,18,26,34,40}, BasePrice=100, PriceGrowth=4},
 Discount={Values={1,.95,.9,.85,.8,.7}, BasePrice=250, PriceGrowth=5},
 Plots={Values={1,2,3,4,5,6}, BasePrice=1000, PriceGrowth=10},
 PetSlots={Values={3,4,5,6}, BasePrice=5000, PriceGrowth=10},
 Batch={Values={1,5,10}, BasePrice=2500, PriceGrowth=10},
}
C.Pets = {EggPrices={250,5000,100000}, Themes={"Squirrel","Bird","Beetle"}, Names={"Acorn", "Moss", "Bloom", "Crystal", "Sun"}, Weights={60,25,10,4,1}, Coin=.04, Luck=.03, Radius=.5, Speed=.3, Growth=.03, Shiny=2, MaxEquip=6}
C.Events = {Every=900, Order={"Golden Rain","Windstorm","Giant Pest Raid"}, Duration={120,60,120}, RainCoins=5, RainGrowth=3, RaidHealth=100, RaidReward=250, RaidHitCooldown=.2}
C.Sabotage = {Protection=300, Cooldown=30, PestDuration=20, PestRate=.5, PruneDuration=15, ShakeFraction=.1, MinuteCap=.25, Stun=3, ShieldDuration=60, TrapDuration=20, TrapRate=.5}
C.Defenses = {Scarecrow=250, BugSpray=500, Fence=2000, Shield=1000}
C.Offline = {Seconds=7200, PassSeconds=28800, Fraction=.5, InfiniteRadius=100, PrivateLuck=1.1}
C.Rebirth = {Threshold=1e9, SaplingDivisor=1e9, Exponent=.5, StartingCoins=35}
C.Simulation = {Seconds=3600, Seeds=21, RollBudgetSeconds=10, Targets={[900]=10000,[1800]=1000000,[3600]=1000000000}, Tolerance=2}
C.Passes = {Luck={Id=0,Price=399}, AutoRoll={Id=0,Price=299}, InfiniteBag={Id=0,Price=449}, InfiniteRange={Id=0,Price=349}, Speed={Id=0,Price=149}, VIP={Id=0,Price=799}, ExtraPlots={Id=0,Price=349}, Offline={Id=0,Price=0}}
C.Products = {CoinsS={Id=0,Price=49,Seconds=60}, CoinsM={Id=0,Price=199,Seconds=300}, CoinsL={Id=0,Price=799,Seconds=1800}, SuperLucky={Id=0,Price=99,Duration=900,Factor=2}, UltraLucky={Id=0,Price=249,Duration=900,Factor=4}, Maxer={Id=0,Price=599}, Shield={Id=0,Price=49}, RebirthSkip={Id=0,Price=399}, Grow3={Id=0,Price=5,Limit=180}, Grow10={Id=0,Price=25,Limit=600}, Grow30={Id=0,Price=49,Limit=1800}, Grow60={Id=0,Price=99,Limit=3600}}
-- Draft prices are proposals. New purchases stay disabled until reviewed and configured.
C.Monetization={EnableNewPurchases=false,MutationLuckEnabled=false}
C.Passes.Coins={Id=0,Price=0,ProposedPrice=399,New=true,Description="Double fruit value; applied once, separately from Saplings and events."}
C.Passes.GrowthSpeed={Id=0,Price=0,ProposedPrice=299,New=true,Description="Double growth rate on both growth pads."}
C.Passes.GrowthPad={Id=0,Price=0,ProposedPrice=299,New=true,Description="Unlock growth pad 2 early. Also earned free on first Ascension."}
C.Passes.AutoSell={Id=0,Price=0,ProposedPrice=249,New=true,Description="Sell anywhere and optionally auto-sell a full bag."}
C.Passes.MutationLuck={Id=0,Price=0,ProposedPrice=499,New=true,Description="Double non-default mutation weights; actual effective odds appear in Odds."}
C.Passes.Cosmetics={Id=0,Price=0,ProposedPrice=149,New=true,Description="Decorative golden garden aura. No progression bonus."}
C.Passes.ExtraPlots.Description="Two earlier production plots (maximum six), plus growth pad 2. Both also earned free."
C.Passes.VIP.Description="VIP terrace, existing 10% coin bonus, and decorative garden aura."
C.Products.StarterPack={Id=0,Price=0,ProposedPrice=99,New=true,Seconds=60,Description="60 seconds of current base tree income plus one 10-minute growth-skip credit."}
C.GrowProducts={"Grow3","Grow10","Grow30","Grow60"}
C.News={Version="Growing Together",Entries={"Two growth pads: unlock pad 2 by Ascending, or with ExtraPlots.","Confirm replacements, recover missing parts, and queue two builds.","Your third lifetime roll guarantees Rare or better. Daily rolls are free.","Discover 420 part/mutation combinations. Claim daily and lifetime goals in the Journal.","Visit and like server gardens. Event participation earns permanent keepsakes."}}
C.SoundConfig = {Roll="",Tick="",Reveal="",Collect="",Sell="",Ready="",Music=""}
C.RarityEffects={MaxAccentParts=5,MaxAuraRate=4,Distance=90}
C.UI = {RollDuration=2.5, RevealDuration=.5, MinimumTouch=44, ToastSeconds=4, ComboSeconds=2, PitchCap=2, PitchStep=.1, PetBob=.4, PetDistance=4, Shake={0,0,0,.2,.2,.5,1}}
C.Inventory={PageSize=24, RotateSpeed=.28, TeleportCooldown=1.5, FullWarningCooldown=2, FullWarningSeconds=3, FallSeconds=.55, BounceSeconds=.25}
C.Placement={HoldSeconds=.8,PromptRange=14,SelectionSeconds=60,GardenRange=75,WaterHold=.35}
C.Leaderboards={CoinsStore="BuildATree_Coins_v1",HeightStore="BuildATree_Height_v1",GlobalRefresh=60,ServerRefresh=5,AvatarRetry=60,Rows=10}
return C
