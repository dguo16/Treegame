-- Pure fruit value and interval equations; no service calls or hidden tuning.
local C=require(script.Parent.Parent.Config)
local Catalog=require(script.Parent.PartCatalog)
local V={}
function V.FruitValue(base, leaves, trunk, mutation, rebirth, event, pass)
 local power=0; for _,v in leaves do power+=v end
 return (base+power)*trunk*mutation*rebirth*event*pass
end
function V.DropInterval(roots)
 local speed=0; for _,v in roots do speed+=v end
 return math.max(C.Math.MinInterval,C.Math.BaseInterval-speed)
end
function V.Build(build, mutation, rebirth, event, pass, pruned,leafPower,coinPass)
 return V.FruitValue(pruned=="Fruit" and C.Math.BaseFruitValue or build.Fruit.Stat,
 {pruned=="Leaves" and 0 or build.Leaves.Stat,pruned=="Leaves" and 0 or (leafPower or 0)},pruned=="Trunk" and 1 or build.Trunk.Stat,(mutation or 1)*Catalog.Bonus(build,pruned),rebirth or 1,event or 1,pass or 1)*(coinPass and 2 or 1)
end
return V
