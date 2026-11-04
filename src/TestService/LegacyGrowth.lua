-- Growth-pad state machine and lazy progress settlement; producing plots stay live.
local S=game:GetService("ReplicatedStorage").BuildATree
local C=require(S.Config)
local G=require(S.Util.GrowthCalculator)
local P=require(S.Util.Profile)
local H=game:GetService("HttpService")
local Entitlements=require(S.Util.Entitlements)
local Pads=require(S.Util.GrowthPads)
local Growth={}
local HeightRng=Random.new()
function Growth.New(build,now,tutorial,rng)
 return {Build=P.Copy(build),HeightScale=tutorial and 1 or (rng or HeightRng):NextNumber(C.Growth.HeightMin,C.Growth.HeightMax),Progress=0,Rate=1,Settled=now,Duration=tutorial and C.Math.MinGrowSeconds or G.BuildTime(build,1),State="Growing",Tutorial=tutorial,Id=H:GenerateGUID(false)}
end
function Growth.MaxPads(p)return Pads.Maximum(p)end
function Growth.QueueLimit(p)return Pads.QueueLimit(p)end
function Growth.Get(p,pad)local key=Pads.Key(pad);return key and p[key]end
function Growth.Set(p,pad,value)local key=Pads.Key(pad);assert(key,"Invalid growth pad");p[key]=value end
function Growth.Find(p,id)
 for pad=1,C.Growth.MaxPads do local g=Growth.Get(p,pad);if g and g.Id==id then return g,pad end end
end
function Growth.Active(p)
 for pad=1,C.Growth.MaxPads do local g=Growth.Get(p,pad);if g and g.State=="Growing"and not g.Tutorial then return g,pad end end
end
function Growth.Free(p)
 for pad=1,Growth.MaxPads(p)do if not Growth.Get(p,pad)then return pad end end
end
function Growth.Pump(p,now)
 p.GrowthQueue=p.GrowthQueue or {}
 while #p.GrowthQueue>0 do local pad=Growth.Free(p);if not pad then break end
  local queued=table.remove(p.GrowthQueue,1);Growth.Set(p,pad,Growth.New(queued.Build,now,false))
 end
end
function Growth.Plant(p,now)
 Growth.Pump(p,now);local pad=Growth.Free(p)
 if not pad then return false,"Your growth pads are occupied. Queue this build or place a ready tree."end
 Growth.Set(p,pad,Growth.New(p.Equipped,now,false));return true,"New tree planted on growth pad "..pad..". Existing trees keep producing."
end
function Growth.Queue(p,now)
 Growth.Pump(p,now);if Growth.Free(p)then return Growth.Plant(p,now)end
 if #p.GrowthQueue>=Growth.QueueLimit(p) then return false,"Growth queue full ("..Growth.QueueLimit(p).."). Place a ready tree to free a pad."end
 table.insert(p.GrowthQueue,{Id=H:GenerateGUID(false),Build=P.Copy(p.Equipped)})
 return true,"Build queued. It starts when a growth pad is empty; later equipment changes do not change it."
end
function Growth.CancelQueue(p,id)
 for i,queued in p.GrowthQueue or {}do if queued.Id==id then table.remove(p.GrowthQueue,i);return true,"Queued build removed."end end
 return false,"That build is no longer queued."
end
-- Planting copies equipped parts; return only identities missing from inventory.
-- Starter parts are permanently available and must never become sellable duplicates.
function Growth.ReturnParts(p,index)
 local known,items={},{};for _,part in p.Parts do known[part.Id]=true end
 local plot=p.Plots[index];if plot then for _,slot in C.Slots do local part=plot.Build[slot]
  if part.Id~="starter_"..slot and not known[part.Id]then known[part.Id]=true;table.insert(items,P.Copy(part))end
 end end
 return items
end
function Growth.Swap(p,index,maxPlots,now,confirmed,pad)
 pad=pad or 1;local g=Growth.Get(p,pad)
 if pad<1 or pad>Growth.MaxPads(p)or not g or g.State~="Ready"then return false,"Your tree is still growing."end
 if index%1~=0 or index<1 or index>math.min(maxPlots,C.Growth.TotalPlots) then return false,"That plot is locked." end
 local returned={}
 if p.Plots[index]then
  if not confirmed then return false,"Confirm replacement before changing this tree."end
  returned=Growth.ReturnParts(p,index)
  if #p.Parts+#returned>C.Runtime.MaxInventory then return false,"Not enough part inventory space. Sell unequipped spare parts, then hold E again. Your trees are unchanged."end
 end
 -- No yields or mutations occur until every check passes.
 for _,part in returned do table.insert(p.Parts,part)end
 p.Plots[index]={Build=P.Copy(g.Build),HeightScale=g.HeightScale or 1,State="Producing",NextDrop=now};Growth.Set(p,pad,nil);Growth.Pump(p,now)
 return true,"Tree planted in plot "..index..(#returned>0 and (" • "..#returned.." recovered parts returned.")or "")
end
function Growth.Finish(p,pad)
 local g=Growth.Get(p,pad or 1);if not g or g.State=="Ready"then return false end
 g.Progress=g.Duration;g.State="Ready";return true
end
function Growth.FinishAll(p)for pad=1,C.Growth.MaxPads do Growth.Finish(p,pad)end end
function Growth.Step(p,now,rate)
 local changed=false
 for pad=1,C.Growth.MaxPads do local g=Growth.Get(p,pad);if g then
  local previous=g.State;G.Rate(g,now,rate)
  if g.State=="Ready"and g.Tutorial then
   if not p.Plots[1]then p.Plots[1]={Build=P.Copy(g.Build),HeightScale=g.HeightScale or 1,State="Producing",NextDrop=now}end
   Growth.Set(p,pad,nil);changed=true
  elseif previous~="Ready"and g.State=="Ready"then changed=true end
 end end
 Growth.Pump(p,now);return changed
end
return Growth
