-- Tree records retain their identity and physical part custody from queue to plot.
local S=game:GetService("ReplicatedStorage").BuildATree
local C=require(S.Config)
local G=require(S.Util.GrowthCalculator)
local P=require(S.Util.Profile)
local O=require(S.Util.PartOwnership)
local H=game:GetService("HttpService")
local Pads=require(S.Util.GrowthPads)
local Growth={}
local HeightRng=Random.new()
function Growth.New(build,now,tutorial,rng,id)
 return {Build=P.Copy(build),HeightScale=tutorial and 1 or (rng or HeightRng):NextNumber(C.Growth.HeightMin,C.Growth.HeightMax),Progress=0,Rate=1,Settled=now,Duration=tutorial and C.Math.MinGrowSeconds or G.BuildTime(build,1),State="Growing",Tutorial=tutorial,Id=id or H:GenerateGUID(false)}
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
function Growth.Free(p)for pad=1,Growth.MaxPads(p)do if not Growth.Get(p,pad)then return pad end end end
function Growth.Pump(p,now)
 p.GrowthQueue=p.GrowthQueue or {}
 while #p.GrowthQueue>0 do local pad=Growth.Free(p);if not pad then break end
  local q=table.remove(p.GrowthQueue,1);local g=Growth.New(q.Build,now,false,nil,q.Id)
  g.PartIds=q.PartIds;g.LegacyParts=q.LegacyParts;Growth.Set(p,pad,g)
 end
end
function Growth.Plant(p,now)
 local pad=Growth.Free(p)
 if not pad then return false,"Your growth pads are occupied. Queue another available build or place a ready tree."end
 local tree=Growth.New(p.Equipped,now,false);local ok,msg=O.Bind(p,tree);if not ok then return false,msg end
 Growth.Set(p,pad,tree);p.PartVersion=(p.PartVersion or 0)+1
 return true,"Tree growing on pad "..pad..". Its non-starter parts are now in use."
end
function Growth.Queue(p,now)
 if Growth.Free(p)and #(p.GrowthQueue or {})==0 then return Growth.Plant(p,now)end
 p.GrowthQueue=p.GrowthQueue or {}
 if #p.GrowthQueue>=Growth.QueueLimit(p)then return false,"Growth queue full ("..Growth.QueueLimit(p).."). Place or salvage a tree to free a pad."end
 local tree={Id=H:GenerateGUID(false),Build=P.Copy(p.Equipped),State="Queued"}
 local ok,msg=O.Bind(p,tree);if not ok then return false,msg end
 table.insert(p.GrowthQueue,tree);p.PartVersion=(p.PartVersion or 0)+1;Growth.Pump(p,now)
 return true,"Build queued and its non-starter parts locked. Changing equipment does not change this tree."
end
function Growth.CancelQueue(p,id)
 for i,q in p.GrowthQueue or {}do if q.Id==id then
  local ok,items=O.CanRelease(p,q);if not ok then return false,items end
  O.Release(p,q,items);table.remove(p.GrowthQueue,i);p.PartVersion=(p.PartVersion or 0)+1;return true,"Queued build cancelled. Its parts are available again."
 end end;return false,"That build is no longer queued."
end
function Growth.ReturnParts(p,index)local tree=p.Plots[index];return tree and O.Returns(p,tree)or {}end
function Growth.Swap(p,index,maxPlots,now,confirmed,pad)
 pad=pad or 1;local g=Growth.Get(p,pad)
 if pad<1 or pad>Growth.MaxPads(p)or not g or g.State~="Ready"then return false,"Your tree is still growing."end
 if index%1~=0 or index<1 or index>math.min(maxPlots,C.Growth.TotalPlots)then return false,"That plot is locked."end
 local valid,msg=O.Verify(p,g);if not valid then return false,msg end
 local old=p.Plots[index];local items={}
 if old then
  if not confirmed then return false,"Confirm salvage and replacement before changing this tree."end
  local ok,result=O.CanRelease(p,old);if not ok then return false,result end;items=result
 end
 -- Every check precedes mutation. The caller durably commits this whole profile draft.
 if old then O.Release(p,old,items)end
 g.State="Producing";g.NextDrop=now;g.HeightScale=g.HeightScale or 1
 p.Plots[index]=g;Growth.Set(p,pad,nil);Growth.Pump(p,now);p.PartVersion=(p.PartVersion or 0)+1
 return true,"Tree planted in plot "..index..(old and ". Old tree salvaged; its parts are available."or ".")
end
function Growth.Salvage(p,id,now)
 local tree,row=O.Find(p,id);if not tree then return false,"That tree is no longer yours."end
 if row.Kind=="Queue"then return Growth.CancelQueue(p,id)end
 local ok,items=O.CanRelease(p,tree);if not ok then return false,items end
 O.Release(p,tree,items)
 if row.Kind=="Plot"then p.Plots[row.Index]=nil else Growth.Set(p,row.Index,nil)end
 Growth.Pump(p,now);p.PartVersion=(p.PartVersion or 0)+1
 return true,"Tree salvaged. Its parts are available; growth progress and dropped fruit are cleared."
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
   if not p.Plots[1]then g.State="Producing";g.NextDrop=now;p.Plots[1]=g end
   Growth.Set(p,pad,nil);changed=true
  elseif previous~="Ready"and g.State=="Ready"then changed=true end
 end end
 Growth.Pump(p,now);return changed
end
return Growth
