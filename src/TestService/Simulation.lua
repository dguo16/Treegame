-- Seeded policy model using production formulas, resets, claims and growth state machines.
-- Collection covers all owned plots; travel, pets, events and paid perks are excluded.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local R=require(S.Util.RollEngine)
local G=require(S.Util.GrowthCalculator)
local V=require(S.Util.ValueCalculator)
local J=require(S.Util.Journal)
local Collection=require(S.Util.Collection)
local Catalog=require(S.Util.PartCatalog)
local Placement=require(S.Util.PlacementRules)
local Growth=require(game.ServerScriptService.BuildATree.Services.GrowthService)
local Game=require(game.ServerScriptService.BuildATree.Services.GameService)
local FruitSizes=require(S.Util.FruitSizes)
local O=require(S.Util.PartOwnership)
local Simulation={}
local function interval(b)return V.Interval and V.Interval(b)or V.DropInterval({b.Roots.Stat})end
local function value(p,b,m)return V.Build(b,m or 1,1+p.Saplings*C.Math.RebirthPerSapling,1,Collection.Factors(p),nil,C.Upgrades.LeafPower.Values[p.Upgrades.LeafPower])end
local function score(p,b)return value(p,b)/interval(b)end
local function income(p)local n=0;for _,plot in p.Plots do n+=score(p,plot.Build)end;return n end
local function buy(p,key)
 local u=C.Upgrades[key];local l=p.Upgrades[key];if l>=#u.Values then return false end
 local cost=u.Prices and u.Prices[l]or math.floor(u.BasePrice*u.PriceGrowth^(l-1))
 if p.Coins<cost then return false end;p.Coins-=cost;p.Upgrades[key]+=1;return true
end
function Simulation.Run(seed,seconds,options)
 options=options or {};local unique=options.UniqueParts~=false;local Growth=unique and Growth or require(script.Parent.LegacyGrowth);local policy=C.Simulation.Policies[options.Policy or "Balanced"]
 assert(policy,"Unknown simulation policy")
 local casual=options.Casual==true;local saleEvery=options.SaleEvery or(casual and C.Simulation.Casual.SaleEvery or C.Simulation.ActiveSaleEvery)
 local rng=Random.new(seed or 42);local sizeRng=Random.new((seed or 42)+2701);local p=P.New(0);J.Scan(p);J.Login(p,0)
 local dt=C.Runtime.PickupTick;local duration=seconds or C.Simulation.Seconds
 local now,active,nextSale,nextRoll,rollBudget=0,0,0,0,C.Roll.FirstCoins
 local fruit={};local ascensions={};local collectionTimes={};local first300=nil;local replacements,queued,cancelled,sold,lost=0,0,0,0,0
 local sessionEnd=C.Simulation.Casual.SessionSeconds;local sessionIndex=0;local milestones={};local rewardCoins=0;local freeRolls=0
 p.Growth=Growth.New(P.Starter(),0,true,rng)
 local function equip(part)
  local candidate=P.Copy(p.Equipped);candidate[part.Slot]=part
  if score(p,candidate)>score(p,p.Equipped)then p.Equipped=candidate end
 end
 local function roll(free)
  if #p.Parts>=C.Runtime.MaxInventory then
   for i=#p.Parts,1,-1 do local part=p.Parts[i]
    if not part.InUse and p.Equipped[part.Slot].Id~=part.Id then p.Coins+=math.floor(C.Roll.BaseCost*C.Roll.PartSellFraction*part.Stat);table.remove(p.Parts,i)
     if #p.Parts<=C.Runtime.MaxInventory-#C.Slots then break end
    end
   end
  end
  local cost=free and 0 or R.Cost(p.Rolls,C.Upgrades.Discount.Values[p.Upgrades.Discount])
  if #p.Parts>=C.Runtime.MaxInventory or p.Coins<cost or(not free and rollBudget<cost)then return false end
  p.Coins-=cost;rollBudget-=cost;p.NextId+=1
  local part=R.Roll(rng,p,select(2,Collection.Factors(p)),tostring(p.NextId));table.insert(p.Parts,part);if not unique then equip(part)end;J.Discover(p,part);J.Add(p,"Rolls",1,now)
  nextRoll=now+C.Runtime.RollCooldown
  if p.Rolls>=C.Roll.LegendaryPity and not first300 then first300={Active=active,Wall=now}end
  return true
 end
 local targets={}
 local function greedy(old)
  local build=P.Starter()
  for _,slot in C.Slots do
   for _,part in p.Parts do if part.Slot==slot and(not part.InUse or(old and part.InUse==old.Id))then
    local candidate=table.clone(build);candidate[slot]=part
    if score(p,candidate)>score(p,build)then build=candidate end
   end end
  end
  return build
 end
 local function claims()
  J.Login(p,now)
  if J.ObserveIncome then J.ObserveIncome(p,now)end
  local before=p.Coins;J.Claim(p,"DailyLogin",now)
  for _,g in J.DailyGoals()do J.Claim(p,g.Key,now)end
  for _,g in J.Goals()do J.Claim(p,g.Key,now)end
  for _,g in Collection.Goals()do if not g.Optional then
   local claimed=Collection.Claim(p,g.Key,J.ObserveIncome(p,now),now)
   if claimed and not collectionTimes[g.Key]then collectionTimes[g.Key]={Active=active,Wall=now,Rolls=p.Journal.Totals.Rolls}end
  end end
  local gained=p.Coins-before;rewardCoins+=gained;rollBudget+=gained*policy.RollShare
  if now>=nextRoll and not p.Journal.Daily.Claims.FreeRoll and roll(true)then p.Journal.Daily.Claims.FreeRoll=true;freeRolls+=1 end
 end
 while active<duration do
  now+=dt;active+=dt;Growth.Step(p,now,1)
  for i,plot in p.Plots do if now>=plot.NextDrop then
   local m=R.Mutation(rng)
   if #fruit<C.Runtime.MaxFruit then table.insert(fruit,{Value=value(p,plot.Build,m.Mult)*(options.Sizes==false and 1 or FruitSizes.Roll(sizeRng).Value),Born=now,Ready=now+C.Inventory.FallSeconds+C.Inventory.BounceSeconds,Plot=i})else lost+=1 end
   plot.NextDrop=now+interval(plot.Build)
  end end
  for i=#fruit,1,-1 do local f=fruit[i]
   if now-f.Born>=C.Runtime.FruitLifetime then table.remove(fruit,i);lost+=1
   elseif now>=f.Ready and p.Bag.Count<C.Upgrades.Bag.Values[p.Upgrades.Bag]then p.Bag.Count+=1;p.Bag.Value+=f.Value;table.remove(fruit,i)end
  end
  if now>=nextSale then
   local sale=p.Bag.Value;p.Coins+=sale;p.TotalCoins+=sale;rollBudget+=sale*policy.RollShare;sold+=p.Bag.Count
   J.Add(p,"Sold",p.Bag.Count,now);p.Bag={Count=0,Value=0,Items={}};nextSale=now+saleEvery
   if options.Rewards~=false then claims()end
   -- Upgrade order is explicit and identical before/after tuning.
   buy(p,"LeafPower");buy(p,"Plots")
   local needed=0;for _,plot in p.Plots do needed+=saleEvery/interval(plot.Build)end
   if C.Upgrades.Bag.Values[p.Upgrades.Bag]<needed then buy(p,"Bag")end
   if options.Discounts then buy(p,"Discount")end
  end
  if now>=nextRoll then roll(false)end
  for pad=1,Growth.MaxPads(p)do local g=Growth.Get(p,pad)
   if g and g.State=="Ready"then
    local target=unique and targets[g.Id]or nil
    if not unique then for i=1,Catalog.MaxPlots(p)do if not p.Plots[i]then target=i;break end end
    if not target then for i,plot in p.Plots do if not target or score(p,plot.Build)<score(p,p.Plots[target].Build)then target=i end end end end
    if target then
     local plots,targets=Placement.Choices(p,Catalog.MaxPlots(p));local occupied=p.Plots[target]~=nil
     local selection={GrowthId=g.Id,GrowthPad=pad,Expires=now+C.Placement.SelectionSeconds,Plots=plots,Targets=targets}
     if Placement.Validate(p,selection,target,g.Id,Catalog.MaxPlots(p),now,occupied)and Growth.Swap(p,target,Catalog.MaxPlots(p),now,occupied,pad)then
      if occupied then replacements+=1 end;targets[g.Id]=nil;J.Add(p,"Plants",1,now)
      for i=#fruit,1,-1 do if fruit[i].Plot==target then table.remove(fruit,i);lost+=1 end end
     end
    end
   end
  end
  if now>=nextSale-dt and unique then
   local reserved={};local inFlight=#p.GrowthQueue
   for pad=1,Growth.MaxPads(p)do if Growth.Get(p,pad)then inFlight+=1 end end
   for _,target in targets do reserved[target]=true end
   local order={};for i=1,Catalog.MaxPlots(p)do if not reserved[i]then table.insert(order,i)end end
   table.sort(order,function(a,b)local aa=p.Plots[a];local bb=p.Plots[b];local av=aa and score(p,aa.Build)or -1;local bv=bb and score(p,bb.Build)or -1;if av==bv then return a<b end;return av<bv end)
   for _,target in order do
    if inFlight>=Growth.MaxPads(p)+Growth.QueueLimit(p)then break end
    local old=p.Plots[target];local build=greedy(old)
    if not old or score(p,build)>score(p,old.Build)*C.Simulation.ReplaceImprovement then
     if old then Growth.Salvage(p,old.Id,now);replacements+=1;for i=#fruit,1,-1 do if fruit[i].Plot==target then table.remove(fruit,i);lost+=1 end end end
     p.Equipped=build
     local known={};for _,row in O.Trees(p)do known[row.Tree.Id]=true end
     local ok=Growth.Queue(p,now)
     if ok then for _,row in O.Trees(p)do if not known[row.Tree.Id]then targets[row.Tree.Id]=target end end;inFlight+=1;queued+=1 end
    end
   end
  elseif now>=nextSale-dt then
   local best=score(p,p.Equipped);local needed=0
   for i=1,Catalog.MaxPlots(p)do if not p.Plots[i]or best>score(p,p.Plots[i].Build)*C.Simulation.ReplaceImprovement then needed+=1 end end
   -- Cancel obsolete queued snapshots by identity, preserving FIFO for useful builds.
   for i=#p.GrowthQueue,1,-1 do local q=p.GrowthQueue[i]
    if score(p,q.Build)<best/C.Simulation.ReplaceImprovement then Growth.CancelQueue(p,q.Id);cancelled+=1 end
   end
   local inFlight=#p.GrowthQueue;for pad=1,Growth.MaxPads(p)do if Growth.Get(p,pad)then inFlight+=1 end end
   while inFlight<needed and inFlight<Growth.MaxPads(p)+Growth.QueueLimit(p) do
    local ok=Growth.Queue(p,now);if not ok then break end;inFlight+=1;queued+=1
   end
  end
  local threshold=Game.AscensionThreshold and Game.AscensionThreshold(p)or C.Rebirth.Threshold
  if p.Coins>=threshold and p.Rolls>=C.Roll.LegendaryPity then
   table.insert(ascensions,{Active=active,Wall=now,RunActive=active-(ascensions[#ascensions]and ascensions[#ascensions].Active or 0),Coins=p.Coins,Saplings=p.Saplings})
   Game.RebirthProfile(p,false)
   for pad=1,C.Growth.MaxPads do local g=Growth.Get(p,pad);if g then g.Settled=now end end
   fruit={};targets={};rollBudget=C.Roll.FirstCoins;nextRoll=now;nextSale=now
   if #ascensions>=(options.Ascensions or C.Simulation.Ascensions)then break end
  end
  if casual and active>=sessionEnd then
   sessionIndex+=1;local nextStart=sessionIndex*C.Simulation.Casual.DaySeconds/C.Simulation.Casual.SessionsPerDay
   local away=math.max(0,nextStart-now);local off=math.floor(income(p)*math.min(away,C.Offline.Seconds)*C.Offline.Fraction)
   p.Coins+=off;rollBudget+=off*policy.RollShare;now+=away;Growth.Step(p,now,1);fruit={};sessionEnd+=C.Simulation.Casual.SessionSeconds
   if options.Rewards~=false then claims()end
  end
  if active%60<dt then milestones[tostring(math.floor(active))]={Coins=p.Coins,Income=income(p),Rolls=p.Rolls,Rebirths=p.Rebirths}end
  if active%600<dt then task.wait()end
 end
 return {Seed=seed,Active=active,Wall=now,First300=first300,Ascensions=ascensions,CollectionTimes=collectionTimes,Coins=p.Coins,Rolls=p.Rolls,Replacements=replacements,Queued=queued,Cancelled=cancelled,Sold=sold,Lost=lost,Rewards=rewardCoins,FreeRolls=freeRolls,Milestones=milestones}
end
function Simulation.Summary(results)
 local summary={Seeds=#results,Ascensions={}}
 local function metric(read)
  local a={};for _,r in results do local v=read(r);if v then table.insert(a,v)end end;table.sort(a)
  return {Reached=#a,MedianReached=a[math.ceil(#a*.5)],P90Reached=a[math.ceil(#a*.9)]}
 end
 summary.First300={Active=metric(function(r)return r.First300 and r.First300.Active end),Wall=metric(function(r)return r.First300 and r.First300.Wall end)}
 for i=1,C.Simulation.Ascensions do summary.Ascensions[i]={Active=metric(function(r)return r.Ascensions[i]and r.Ascensions[i].Active end),RunActive=metric(function(r)return r.Ascensions[i]and r.Ascensions[i].RunActive end),Wall=metric(function(r)return r.Ascensions[i]and r.Ascensions[i].Wall end)}end
 return summary
end
function Simulation.Median(seconds,options)
 local results={};for seed=1,C.Simulation.Seeds do table.insert(results,Simulation.Run(seed,seconds,options))end
 return Simulation.Summary(results)
end
function Simulation.TierAudit()
 local rows={};local p=P.New(0)
 for tier,r in C.Rarities do local b=P.Starter()
  for _,slot in C.Slots do b[slot].Tier=tier;b[slot].Stat=(r.Min+r.Max)/2*(slot=="Roots"and C.Math.RootBase or 1);b[slot].Name=C.PartNames[slot][tier]end
  table.insert(rows,{Tier=r.Name,Fruit=value(p,b),Interval=interval(b),Income=score(p,b),Grow=G.BuildTime and G.BuildTime(b,1)or G.GrowTime(G.Tier(b),1)})
 end;return rows
end
function Simulation.PriceAudit()
 local total=0;for n=0,C.Roll.LegendaryPity-1 do total+=R.Cost(n,1)end
 return {Roll50=R.Cost(49,1),Roll300=R.Cost(299,1),Cost300=total,Cap=R.Cost(1000000,1),Ascension=C.Rebirth.Threshold}
end
return Simulation
