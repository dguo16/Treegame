-- Stable catalog lookup and a shared mutation contract for rolls, saves and visuals.
local C=require(script.Parent.Parent.Config)
local Entitlements=require(script.Parent.Entitlements)
local Catalog={}
function Catalog.Variants(slot,tier) return C.PartVariants[slot] and C.PartVariants[slot][tier] end
function Catalog.Variant(item)
 local names=Catalog.Variants(item.Slot,item.Tier)
 return names and table.find(names,item.Name) or 1
end
function Catalog.Count()
 local count=0;for _,slot in C.Slots do for tier=1,#C.Rarities do count+=#Catalog.Variants(slot,tier) end end;return count
end
function Catalog.Mutation(item)
 for _,m in C.Mutations do if m.Name==item.Mutation then return m end end
 return C.Mutations[1]
end
-- Each equipped part contributes one quarter of the combined fruit-value multiplier.
-- Four unmutated parts give 1x; four 50x parts give 50x, without exponential stacking.
function Catalog.Bonus(build,pruned)
 local total=0;for _,slot in C.Slots do total+=slot==pruned and 1 or Catalog.Mutation(build[slot]).Mult end
 return total/#C.Slots
end
function Catalog.MaxPlots(profile)
 local level=math.clamp(profile.Upgrades.Plots or 1,1,#C.Upgrades.Plots.Values)
 return math.min(C.Growth.TotalPlots,C.Upgrades.Plots.Values[level]+(Entitlements.Has(profile,"ExtraPlots")and C.Growth.ExtraPassPlots or 0))
end
function Catalog.Style(part,item)
 local mutation=Catalog.Mutation(item)
 if mutation.Name~="None" then part.Color=mutation.Color;part.Material=mutation.Material end
 return part
end
return Catalog
