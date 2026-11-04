-- Studio acceptance suite. Run from command bar; does not touch live DataStore keys or prompt purchases.
local Http=game:GetService("HttpService")
local S=game:GetService("ReplicatedStorage").BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local R=require(S.Util.RollEngine)
local G=require(S.Util.GrowthCalculator)
local V=require(S.Util.ValueCalculator)
local Validate=require(S.Util.IntentValidator)
local BagInventory=require(S.Util.BagInventory)
local Services=game:GetService("ServerScriptService").BuildATree.Services
local Growth=require(Services.GrowthService)
local Purchase=require(Services.PurchaseService)
local Catalog=require(S.Util.PartCatalog)
local Tests={}
function Tests.Run()
 local count=0
 local function check(value,message) assert(value,message); count+=1 end
 local function near(a,b) return math.abs(a-b)<1e-6 end
 check(near(V.FruitValue(2,{3,4},2,5,2,3,2),1080),"Value equation")
 check(near(V.DropInterval({100}),.5),"Interval floor")
 check(G.GrowTime(1,1)==5 and G.GrowTime(7,2)==3600,"Grow clamp")
 local build=P.Starter(); build.Trunk.Tier=7
 check(G.Tier(build)==2,"Tier uses floor of average, not maximum")
 local a,b=P.New(0),P.New(0); local ar,br=Random.new(987),Random.new(987)
 for i=1,100 do local x,y=R.Roll(ar,a,1,tostring(i)),R.Roll(br,b,1,tostring(i)); check(x.Tier==y.Tier and x.Slot==y.Slot and x.Stat==y.Stat,"Seeded roll mismatch") end
 -- Base frequencies measured without pity, whose guaranteed rolls intentionally alter frequencies.
 local frequencies=table.create(#C.Rarities,0); local rng=Random.new(1729); local weights,total=R.Weights(1,1); local n=100000
 for i=1,n do local tier=R.Choose(rng,weights,total); frequencies[tier]+=1; if i%1000==0 then task.wait() end end
 for i,r in C.Rarities do local expected=n*r.Weight/100; local tolerance=math.max(5,6*math.sqrt(expected*(1-r.Weight/100))); check(math.abs(frequencies[i]-expected)<=tolerance,"Rarity frequency outside 6-sigma tolerance: "..r.Name) end
 local pity=P.New(0); pity.EpicPity=49; check(R.Roll(rng,pity,1,"pity").Tier>=4,"Epic pity at 50")
 pity.LegendaryPity=299; check(R.Roll(rng,pity,1,"pity2").Tier>=5,"Legendary pity at 300")
 check(not Validate("Sell",{Value=1e9}),"Forged sale rejected")
 check(not Validate("Plant",{Time=0,Progress=1}),"Forged timestamps rejected")
 check(not Validate("Roll",{Count=0/0}),"NaN rejected")
 check(not Validate("Swap",{Plot=1,Coins=999}),"Extra keys rejected")
 check(Validate("Sell",{Revision=0,Stacks={{Id="stack",Quantity=1}}})and Validate("Roll",{}),"Valid intents")
 check(Validate("Teleport",{Destination="Garden"}) and not Validate("Teleport",{Destination="Garden",Position=0}),"Teleport accepts destination intent only")
 local bag={Count=0,Value=0,Items={}}
 BagInventory.Add(bag,4,2,{Name="Apple",Tier=2,Mutation="Golden"},120,"fruit1")
 BagInventory.Add(bag,4,1,{Name="Apple",Tier=2,Mutation="Golden"},140,"fruit2")
 check(bag.Count==3 and bag.Value==12 and #bag.Items==1,"Fruit stacks preserve count and exact value")
 check(bag.Items[1].ObtainedAt==120 and bag.Items[1].LastObtainedAt==140,"Server acquisition range retained")
 BagInventory.Add(bag,4,1,{Name="Apple",Tier=2,Mutation="Golden"},180,"fruit3")
 check(#bag.Items==1 and bag.Items[1].LastObtainedAt==180,"Acquisition minutes no longer fragment identical size-class stacks")
 local legacy={Count=2,Value=6}; BagInventory.Ensure(legacy)
 check(legacy.Items[1].Value==3 and legacy.Items[1].ObtainedAt==nil,"Legacy harvest preserves value without inventing an acquisition date")
 local g={Progress=0,Duration=100,Rate=1,Settled=0,State="Growing"}
 G.Rate(g,20,.5); G.Rate(g,40,3); G.Rate(g,50,1); check(g.Progress==60,"Lazy settlement across rate changes")
 G.Settle(g,90); check(g.State=="Ready","Growth schedule")
 local off=Growth.New(P.Starter(),0,false); G.Settle(off,1000); check(off.State=="Ready","Offline completion")
 local profile=P.New(0); profile.Plots={{Build=P.Starter(),State="Producing",NextDrop=0}}
 Growth.Plant(profile,0); check(#profile.Plots==1 and profile.Plots[1].State=="Producing","Plant preserves producer")
 check(not Growth.Swap(profile,1,1,0),"Cannot swap growing tree")
 Growth.Finish(profile); check(not Growth.Swap(profile,1,2,10),"Occupied plot rejects replacement")
 check(Growth.Swap(profile,2,2,10) and #profile.Plots==2,"Ready swap retains original producer")
 local tutorial=Growth.New(P.Starter(),0,true); profile.Growth=tutorial
 check(not Purchase.GrantGrow(profile,tutorial.Id,1,180),"No paid tutorial skip")
 profile.Growth=Growth.New(P.Starter(),0,false); local id=profile.Growth.Id
 check(Purchase.GrantGrow(profile,id,1,180),"Grow product covers remaining time")
 check(not Purchase.GrantGrow(profile,id,1,180),"Finished tree rejects duplicate grow grant")
 for key in C.Products do
  local p=P.New(0); p.Plots={{Build=P.Starter(),State="Producing",NextDrop=0}}; p.Growth=Growth.New(P.Starter(),os.time(),false)
  local granted=0
  local function grant(draft) granted+=1; Purchase.Grant(draft,key,os.time(),draft.Growth and draft.Growth.Id) end
  check(P.GrantOnce(p,key,grant),"First receipt: "..key)
  check(not P.GrantOnce(p,key,grant) and granted==1,"Duplicate receipt: "..key)
 end
 profile.Pets={{Id="x",Tier=1,Rarity=1,Shiny=true,Name="Acorn"}}; profile.Growth=Growth.New(P.Starter(),10,false)
 local roundtrip=Http:JSONDecode(Http:JSONEncode(profile)); check(roundtrip.Growth.Id==profile.Growth.Id and roundtrip.Plots[1].Build.Trunk.Stat==1 and roundtrip.Pets[1].Shiny,"Full profile JSON round-trip")
 -- Catalog expansion is reachable without changing rarity odds or removing old names.
 check(Catalog.Count()==84,"Three parts per type and rarity")
 local reached={}
 local cumulative=0
 for tier,rarity in C.Rarities do
  local target=(cumulative+rarity.Weight/2)/100;cumulative+=rarity.Weight
  for slotIndex,slot in C.Slots do
   check(#Catalog.Variants(slot,tier)==3 and Catalog.Variants(slot,tier)[1]==C.PartNames[slot][tier],"Existing catalog part remains available")
   for variant,name in Catalog.Variants(slot,tier) do
    check(not reached[name],"Catalog names are unique");reached[name]=true
    local integerCall=0;local numberCall=0
    local fake={NextInteger=function(_,lo,hi) integerCall+=1;return integerCall==1 and slotIndex or variant end,
     NextNumber=function(_,lo,hi) if lo then return (lo+hi)/2 end;numberCall+=1;return numberCall==1 and target or .999 end}
    local rolled=R.Roll(fake,P.New(0),1,"catalog")
    check(rolled.Name==name and rolled.Tier==tier and rolled.Slot==slot and rolled.Variant==variant,"Every catalog variant is rollable")
    check(rolled.Mutation=="Cosmic","Part rolls independently receive a mutation")
   end
  end
 end
 -- Mutation odds are independent of rarity luck and have explicit boundary coverage.
 for i,target in {.4,.86,.945,.9825,.9975} do
  local mutation=R.Mutation({NextNumber=function()return target end})
  check(mutation.Name==C.Mutations[i].Name and mutation.Mult==C.Mutations[i].Mult,"Every mutation bracket is reachable")
 end
 local saved=P.New(0);saved.Parts={{Id="mutant",Slot="Trunk",Tier=1,Name="Pine",Variant=2,Stat=1.1,Mutation="Cosmic"}}
 saved.Equipped.Trunk=P.Copy(saved.Parts[1]);saved.Growth=Growth.New(saved.Equipped,0,false)
 local restored=P.Migrate(Http:JSONDecode(Http:JSONEncode(saved)),0)
 check(restored.Parts[1].Name=="Pine" and restored.Parts[1].Variant==2 and restored.Parts[1].Mutation=="Cosmic","New part identity and mutation survive migration and serialization")
 check(restored.Equipped.Trunk.Mutation=="Cosmic" and restored.Growth.Build.Trunk.Mutation=="Cosmic","Equipped and growing trees retain part mutations")
 local original=P.Starter();local plain=V.Build(original,1,1,1,1)
 original.Trunk.Mutation="Golden"
 check(near(Catalog.Bonus(original),1.25) and near(V.Build(original,1,1,1,1),plain*1.25),"Each part contributes one quarter of its mutation multiplier")
 check(near(V.Build(original,5,1,1,1),plain*C.Economy.MutationCeiling),"Harvest and part mutation bonuses combine once")
 for _,slot in C.Slots do original[slot].Mutation="Cosmic" end
 check(Catalog.Bonus(original)==50,"Maximum part mutation bonus is 50x")
 local legacyProfile=P.New(0);legacyProfile.Parts={{Id="old",Name="Oak",Slot="Trunk",Tier=1,Stat=1.1}}
 legacyProfile.Plots={{Build=P.Starter(),State="Producing",NextDrop=0}}
 local migrated=P.Migrate(legacyProfile,0)
 check(migrated.Parts[1].Mutation=="None" and migrated.Parts[1].Name=="Oak" and migrated.Parts[1].Stat==1.1,"Migration preserves existing part identity and stats")
 check(migrated.Plots[1].HeightScale==1,"Existing trees keep normal scale")
 local low=Growth.New(P.Starter(),0,false,{NextNumber=function(_,lo,hi)return lo end})
 local high=Growth.New(P.Starter(),0,false,{NextNumber=function(_,lo,hi)return hi end})
 check(low.HeightScale==.75 and high.HeightScale==1.5,"Server height range includes both endpoints")
 check(G.Height(high.Build,high.HeightScale)==G.Height(low.Build,low.HeightScale)*2,"Height variation affects actual tree height")
 local tall=P.New(0);tall.Growth=high;G.Settle(high,10000)
 check(high.State=="Ready" and high.HeightScale==1.5,"Growth completion keeps sampled height")
 check(Growth.Swap(tall,6,6,10000) and tall.Plots[6].HeightScale==1.5,"Plot placement preserves sampled height")
 for i=1,5 do tall.Plots[i]=P.Copy(tall.Plots[6]) end
 local encoded=Http:JSONDecode(Http:JSONEncode(tall))
 check(encoded.Plots[6].HeightScale==1.5,"Height survives save serialization")
 local plots=P.New(0);plots.Upgrades.Plots=6
 check(Catalog.MaxPlots(plots)==6,"Six plots are reachable through coin upgrades")
 plots.Passes.ExtraPlots=true;check(Catalog.MaxPlots(plots)==6,"Pass never exposes a seventh production plot")
 plots.Upgrades.Plots=1;check(Catalog.MaxPlots(plots)==1,"Retired extra-plots entitlement never bypasses coin plot progression")
 print("Build a Tree acceptance: "..count.." assertions passed")
 print("Sample: fruit=",V.FruitValue(1,{1},1,1,1,1,1),"grow=",G.GrowTime(1,1),"drop=",V.DropInterval({.15}))
 return count
end
return Tests
