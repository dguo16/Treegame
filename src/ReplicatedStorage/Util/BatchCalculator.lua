-- Pure best-affordable batch selection; includes each roll's escalating cost.
local C=require(script.Parent.Parent.Config)
local R=require(script.Parent.RollEngine)
local Batch={}
function Batch.Choose(rolls,coins,upgrade,discount,freeSlots)
 local limit=C.Upgrades.Batch.Values[upgrade]or C.Upgrades.Batch.Values[1]
 limit=math.min(limit,freeSlots or limit)
 local count,total=0,0
 for i=1,limit do local cost=R.Cost(rolls+i-1,discount);if total+cost>coins then break end;total+=cost;count=i end
 return count,total
end
return Batch
