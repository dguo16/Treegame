-- Presentation metadata only. No RNG, grants, profile changes or client authority.
local C=require(script.Parent.Parent.Config)
local R=require(script.Parent.RollEngine)
local Catalog=require(script.Parent.PartCatalog)
local D={}
function D.Context(profile,luck,mutationLuck)
 return {Minimum=R.Minimum(profile),Luck=luck,MutationLuck=mutationLuck or 1}
end
function D.Result(part,context)
 local copy=table.clone(part)
 local weights,total=R.Weights(context.Luck,context.Minimum)
 local mutationWeights,mutationTotal=R.MutationWeights(context.MutationLuck)
 local mutationIndex=1
 for i,m in C.Mutations do if m.Name==part.Mutation then mutationIndex=i;break end end
 copy.RollOdds={Chance=weights[part.Tier]/total/#C.Slots/#Catalog.Variants(part.Slot,part.Tier)*mutationWeights[mutationIndex]/mutationTotal,Luck=context.Luck,Minimum=context.Minimum}
 return copy
end
function D.OddsText(part)
 local chance=part.RollOdds and part.RollOdds.Chance
 if not chance or chance<=0 then return "Odds unavailable for this earlier roll"end
 local percent=string.format("%.6f",chance*100):gsub("0+$",""):gsub("%.$","")
 return "Name + mutation: "..percent.."% | approx. 1 in "..string.format("%.1f",1/chance)
end
function D.Detail(part)
 return C.Rarities[part.Tier].Name.." "..part.Slot.." | "..(part.Mutation or "None")
end
function D.Best(results)
 local best=results[1]
 for _,part in results do
  if part.Tier>best.Tier or(part.Tier==best.Tier and Catalog.Mutation(part).Mult>Catalog.Mutation(best).Mult)then best=part end
 end
 return best
end
function D.Remember(history,results)
 for _,part in results do table.insert(history,part)end
 while #history>100 do table.remove(history,1)end
end
return D
