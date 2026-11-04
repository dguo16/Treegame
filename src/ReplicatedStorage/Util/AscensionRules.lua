-- Pure shared threshold; no changes to reset/retention or product grants.
local C=require(script.Parent.Parent.Config)
local A={}
function A.Threshold(p)
 local factor=C.Rebirth.ThresholdGrowth
 if factor==1 then return C.Rebirth.Threshold end
 local maximum=math.log(C.Runtime.MaxCoins/C.Rebirth.Threshold)/math.log(factor)
 return math.min(C.Runtime.MaxCoins,C.Rebirth.Threshold*factor^math.clamp(p.Rebirths or 0,0,maximum))
end
return A
