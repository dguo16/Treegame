-- Seedable independent part/rarity rolls, effective odds, and exact pity counters.
local C=require(script.Parent.Parent.Config)
local Catalog=require(script.Parent.PartCatalog)
local R={}
function R.Weights(luck,minTier)
 local weights,total={},0
 for i,r in C.Rarities do
  local w=i<(minTier or 1) and 0 or r.Weight*(i==1 and 1 or luck)
  weights[i]=w; total+=w
 end
 return weights,total
end
function R.Choose(rng,weights,total)
 local target=rng:NextNumber()*total
 for i,w in weights do target-=w; if target<0 then return i end end
 return #weights
end
function R.Minimum(profile)
 local minimum=profile.LegendaryPity+1>=C.Roll.LegendaryPity and 5 or(profile.EpicPity+1>=C.Roll.EpicPity and 4 or 1)
 if profile.Rolls==2 and not profile.EarlyRareClaimed then minimum=math.max(3,minimum)end
 return minimum
end
function R.Roll(rng,profile,luck,id,mutationLuck)
 local minimum=R.Minimum(profile)
 if profile.Rolls==2 then profile.EarlyRareClaimed=true end
 local weights,total=R.Weights(luck,minimum)
 local tier=R.Choose(rng,weights,total); local rarity=C.Rarities[tier]
 local slot=C.Slots[rng:NextInteger(1,#C.Slots)]
 local stat=rng:NextNumber(rarity.Min,rarity.Max)
 if slot=="Roots" then stat*=C.Math.RootBase elseif slot=="Leaves" then stat*=C.Math.LeafBase end
 profile.EpicPity=tier>=4 and 0 or profile.EpicPity+1
 profile.LegendaryPity=tier>=5 and 0 or profile.LegendaryPity+1
 profile.Rolls+=1
 local variants=Catalog.Variants(slot,tier)
 local variant=rng:NextInteger(1,#variants);local mutation=R.Mutation(rng,mutationLuck)
 return {Id=id,Slot=slot,Tier=tier,Stat=stat,Name=variants[variant],Variant=variant,Mutation=mutation.Name}
end
function R.Cost(n,discount)
 local early=C.Roll.CostGrowth^math.min(n,C.Roll.SlowAfter)
 -- Clamp the exponent before raising it, even for an enormous saved counter.
 local maxLate=math.log(C.Roll.HardCap/(C.Roll.BaseCost*C.Roll.CostGrowth^C.Roll.SlowAfter))/math.log(C.Roll.SlowGrowth)
 local late=C.Roll.SlowGrowth^math.clamp(n-C.Roll.SlowAfter,0,maxLate)
 return math.floor(math.min(C.Roll.HardCap,C.Roll.BaseCost*early*late)*(discount or 1))
end
-- Pending policy review: non-default weights are calculator/test support only. Not sold or activated.
function R.MutationWeights(luck)
 local weights,total={},0;for i,m in C.Mutations do local w=m.Weight*(i==1 and 1 or(luck or 1));weights[i]=w;total+=w end
 return weights,total
end
function R.Mutation(rng,luck)
 local weights,total=R.MutationWeights(luck)
 return C.Mutations[R.Choose(rng,weights,total)]
end
return R
