-- Seeded, free-player policy model. Not a prediction of real-player retention.
-- Uses production rolls, mutations, bag limits, growth, inventory and placement rules.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local R=require(S.Util.RollEngine)
local G=require(S.Util.GrowthCalculator)
local V=require(S.Util.ValueCalculator)
local Catalog=require(S.Util.PartCatalog)
local Placement=require(S.Util.PlacementRules)
local Growth=require(game.ServerScriptService.BuildATree.Services.GrowthService)
local Simulation={}
local function value(p,build,mutation)
 return V.Build(build,mutation or 1,1+p.Saplings*C.Math.RebirthPerSapling,1,1,nil,C.Upgrades.LeafPower.Values[p.Upgrades.LeafPower])
end
local function score(p,build)return value(p,build)/V.DropInterval({build.Roots.Stat})end
local function buy(p,key)
 local up=C.Upgrades[key];local level=p.Upgrades[key]
 if level>=#up.Values then return false end
 local cost=up.Prices and up.Prices[level] or math.floor(up.BasePrice*up.PriceGrowth^(level-1))
 if p.Coins<cost then return false end
 p.Coins-=cost;p.Upgrades[key]+=1;return true
end
function Simulation.Run(seed,seconds,options)
 options=options or {};local rng=Random.new(seed or 42);local p=P.New(0)
 local duration=seconds or C.Simulation.Seconds;local step=C.Runtime.PickupTick
 local fruit={};local milestones={};local nextRoll=0;local nextSale=0;local first300=nil;local firstAscension=nil
 local lastPlantScore=-1;local replacements=0;local recovered=0;local discarded=0;local lostFruit=0;local sold=0
 p.Growth=Growth.New(P.Starter(),0,true,rng)
 for frame=1,math.ceil(duration/step)do
  local now=frame*step
  Growth.Step(p,now,1)
  -- Every harvested fruit rolls its own mutation; bags have real capacity.
  for i,plot in p.Plots do if now>=plot.NextDrop then
   local m=R.Mutation(rng)
   if #fruit<C.Runtime.MaxFruit then table.insert(fruit,{Value=value(p,plot.Build,m.Mult),At=now,Ready=now+C.Inventory.FallSeconds+C.Inventory.BounceSeconds,Plot=i})else lostFruit+=1 end
   plot.NextDrop=now+V.DropInterval({plot.Build.Roots.Stat})
  end end
  for i=#fruit,1,-1 do local f=fruit[i]
   if now-f.At>=C.Runtime.FruitLifetime then table.remove(fruit,i);lostFruit+=1
   elseif now>=f.Ready and p.Bag.Count<C.Upgrades.Bag.Values[p.Upgrades.Bag]then
    p.Bag.Count+=1;p.Bag.Value+=f.Value;table.remove(fruit,i)
   end
  end
  -- This model assumes active collection of all owned plots; test movement separately.
  -- SaleEvery=2 approximates frequent sell/garden teleporting; 12 adds travel friction.
  if now>=nextSale then
   p.Coins+=p.Bag.Value;p.TotalCoins+=p.Bag.Value;sold+=p.Bag.Count
   p.Bag={Count=0,Value=0,Items={}};nextSale=now+(options.SaleEvery or 12)
  end
  if not firstAscension and p.Coins>=C.Rebirth.Threshold then firstAscension=now end
  -- Goals are reported without triggering Ascension, so 300-roll reach remains visible.
  buy(p,"LeafPower")
  buy(p,"Plots")
  local capacity=C.Upgrades.Bag.Values[p.Upgrades.Bag]
  if capacity<#p.Plots*(options.SaleEvery or 12)/4 then buy(p,"Bag")end
  local income=0;for _,plot in p.Plots do income+=score(p,plot.Build)end
  if now>=nextRoll then
   local cost=R.Cost(p.Rolls,C.Upgrades.Discount.Values[p.Upgrades.Discount])
   if cost<=p.Coins and (p.Rolls==0 or cost<=income*C.Simulation.RollBudgetSeconds)then
    -- Recycle unequipped inventory only when needed. Never sell an equipped ID.
    if #p.Parts>=C.Runtime.MaxInventory then
     for i=#p.Parts,1,-1 do local part=p.Parts[i]
      if p.Equipped[part.Slot].Id~=part.Id then
       p.Coins+=math.floor(C.Roll.BaseCost*C.Roll.PartSellFraction*part.Stat);table.remove(p.Parts,i);discarded+=1
       if #p.Parts<=C.Runtime.MaxInventory-4 then break end
      end
     end
    end
    if #p.Parts<C.Runtime.MaxInventory then
     p.Coins-=cost;p.NextId+=1;local part=R.Roll(rng,p,1,tostring(p.NextId));table.insert(p.Parts,part)
     local candidate=P.Copy(p.Equipped);candidate[part.Slot]=part
     if score(p,candidate)>score(p,p.Equipped)then p.Equipped=P.Copy(candidate)end
     nextRoll=now+C.Runtime.RollCooldown
     if p.Rolls>=300 and not first300 then first300=now end
    end
   end
  end
  if p.Growth and p.Growth.State=="Ready"then
   local index=nil;for i=1,Catalog.MaxPlots(p)do if not p.Plots[i]then index=i;break end end
   if not index then
    for i,plot in p.Plots do if not index or score(p,plot.Build)<score(p,p.Plots[index].Build)then index=i end end
   end
   if index then
    -- Occupied plots always use a fresh, explicit confirmation, never implicit overwrite.
    local plots,targets=Placement.Choices(p,Catalog.MaxPlots(p));local selection={GrowthId=p.Growth.Id,Expires=now+C.Placement.SelectionSeconds,Plots=plots,Targets=targets}
    local occupied=p.Plots[index]~=nil
    local valid=Placement.Validate(p,selection,index,p.Growth.Id,Catalog.MaxPlots(p),now,occupied)
    if valid then
     local count=#Growth.ReturnParts(p,index)
     local ok=Growth.Swap(p,index,Catalog.MaxPlots(p),now,occupied)
     if ok then
      if occupied then replacements+=1;recovered+=count end
      for i=#fruit,1,-1 do if fruit[i].Plot==index then table.remove(fruit,i);lostFruit+=1 end end
     end
    end
   end
  end
  local currentScore=score(p,p.Equipped)
  if not p.Growth and currentScore>lastPlantScore then
   local success=Growth.Plant(p,now)
   if success then lastPlantScore=currentScore end
  end
  if frame%math.floor(60/step)==0 then
   milestones[tostring(math.floor(now))]={Coins=p.Coins,Income=income,Rolls=p.Rolls,Plots=#p.Plots,Tier=G.Tier(p.Equipped)}
  end
  if frame%math.floor(120/step)==0 then task.wait()end
 end
 return {Coins=p.Coins,Rolls=p.Rolls,Milestones=milestones,First300=first300,FirstAscension=firstAscension,Replacements=replacements,Recovered=recovered,Discarded=discarded,LostFruit=lostFruit,SoldFruit=sold,Inventory=#p.Parts,Policy="Free; no pets/events/paid perks; full-plot active collection; "..(options.SaleEvery or 12).."s selling; no Ascension reset"}
end
function Simulation.Median(seconds,options)
 local all={};for seed=1,C.Simulation.Seeds do table.insert(all,Simulation.Run(seed,seconds or C.Simulation.Seconds,options))end
 local output={};local middle=math.ceil(#all/2)
 for _,time in {60,300,900,1800,3600}do
  if time<=(seconds or C.Simulation.Seconds)then
   local row={};for _,key in {"Coins","Income","Rolls","Plots","Tier"}do
    local a={};for _,r in all do table.insert(a,r.Milestones[tostring(time)][key])end;table.sort(a);row[key]=a[middle]
   end;output[tostring(time)]=row
  end
 end
 for _,key in {"First300","FirstAscension"}do local a={};for _,r in all do if r[key]then table.insert(a,r[key])end end;table.sort(a);output[key]={Reached=#a,Seeds=#all,MedianReached=a[math.ceil(#a/2)]}end
 return output
end
function Simulation.PriceAudit()
 local rows={};for _,cap in {200,C.Runtime.MaxRollExponent}do
  local total=0;for n=0,299 do total+=math.floor(C.Roll.BaseCost*C.Roll.CostGrowth^math.min(n,cap))end
  table.insert(rows,{ExponentCap=cap,Roll50=math.floor(C.Roll.BaseCost*C.Roll.CostGrowth^math.min(49,cap)),Roll300=math.floor(C.Roll.BaseCost*C.Roll.CostGrowth^math.min(299,cap)),Cost300=total,Ascension=C.Rebirth.Threshold})
 end;return rows
end
return Simulation
