-- Shared valuation for server production, previews, rewards and simulation.
local C=require(script.Parent.Parent.Config)
local Catalog=require(script.Parent.PartCatalog)
local Sizes=require(script.Parent.FruitSizes)
local V={}
function V.FruitValue(base,leaves,trunk,mutation,rebirth,event,pass)
 local power=0;for _,v in leaves do power+=v end
 return (base+power)*trunk*mutation*rebirth*event*pass
end
-- Legacy scalar helper remains available; live builds use rarity-aware Interval.
function V.DropInterval(roots)
 local speed=0;for _,v in roots do speed+=v end
 return math.max(C.Math.MinInterval,C.Math.BaseInterval-speed)
end
function V.Interval(build)
 local root=build.Roots;local rarity=C.Rarities[root.Tier]
 return math.max(C.Math.MinInterval,C.Economy.RootIntervals[root.Tier]*rarity.Min*C.Math.RootBase/math.max(root.Stat,C.Math.RootBase))
end
function V.Mutation(build,harvest,pruned)
 return math.min(C.Economy.MutationCeiling,Catalog.Bonus(build,pruned)*(harvest or 1))
end
function V.Build(build,mutation,rebirth,event,pass,pruned,leafPower,coinPass,fruitSize)
 local fruit=pruned=="Fruit"and C.Math.BaseFruitValue or build.Fruit.Stat*Catalog.Power(build.Fruit)
 local leaves=pruned=="Leaves"and 0 or build.Leaves.Stat*Catalog.Power(build.Leaves)
 local trunk=pruned=="Trunk"and 1 or build.Trunk.Stat*Catalog.Power(build.Trunk)
 return C.Economy.ValueScale*V.FruitValue(fruit,{leaves},trunk,V.Mutation(build,mutation,pruned),rebirth or 1,event or 1,pass or 1)*(pruned=="Leaves"and 1 or(leafPower or 1))*Sizes.Get(fruitSize).Value*(coinPass and 2 or 1)
end
return V
