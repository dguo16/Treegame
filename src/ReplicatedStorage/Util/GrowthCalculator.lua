-- Pure timestamp settlement. Rate changes settle before assigning the next rate.
local C=require(script.Parent.Parent.Config)
local G={}
function G.Tier(build)
 local sum=0; for _,slot in C.Slots do sum+=build[slot].Tier end
 return math.max(1,math.floor(sum/#C.Slots))
end
-- Height is sampled once by the server when planting; legacy trees keep scale 1.
function G.Height(build,scale)
 if type(scale)~="number" or scale~=scale then scale=1 end
 return (12+G.Tier(build)*1.5)*math.clamp(scale,C.Growth.HeightMin,C.Growth.HeightMax)
end
function G.GrowTime(tier,modifier)
 return math.clamp(C.Rarities[tier].Grow*modifier,C.Math.MinGrowSeconds,C.Math.MaxGrowSeconds)
end
function G.Settle(g,now)
 g.Progress=math.min(g.Duration,g.Progress+math.max(0,now-g.Settled)*g.Rate)
 g.Settled=now
 if g.Progress>=g.Duration then g.State="Ready" end
 return g
end
function G.Rate(g,now,rate) G.Settle(g,now); g.Rate=rate; return g end
function G.Remaining(g) return math.max(0,g.Duration-g.Progress)/math.max(g.Rate,.001) end
return G
