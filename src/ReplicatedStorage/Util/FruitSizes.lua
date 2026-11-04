-- Harvest-only size sampling. Rarity luck, pets and paid luck never enter this roll.
local C=require(script.Parent.Parent.Config)
local Sizes={}
function Sizes.Get(name)
 for rank,item in C.FruitSizes do if item.Name==name then return item,rank end end
 return C.FruitSizes[2],2
end
function Sizes.Roll(rng)
 local target=rng:NextNumber()*100;local sum=0
 for _,item in C.FruitSizes do sum+=item.Weight;if target<sum then return item end end
 return C.FruitSizes[#C.FruitSizes]
end
function Sizes.Expected()
 local total,value=0,0;for _,item in C.FruitSizes do total+=item.Weight;value+=item.Weight*item.Value end
 return value/total
end
return Sizes
