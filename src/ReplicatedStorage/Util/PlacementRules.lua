-- Server-owned selection snapshots bind both the ready build and the target tree.
local Pads=require(script.Parent.GrowthPads)
local Rules={}
function Rules.EmptyPlots(profile,maximum)
 local plots={};for i=1,maximum do if not profile.Plots[i]then table.insert(plots,i)end end;return plots
end
function Rules.Choices(profile,maximum)
 local plots,targets={},{};for i=1,maximum do table.insert(plots,i);targets[i]=profile.Plots[i] and (profile.Plots[i].Id or profile.Plots[i])or false end;return plots,targets
end
function Rules.Validate(profile,selection,index,growthId,maximum,now,confirmed)
 if not selection or selection.GrowthId~=growthId or now>=selection.Expires then return false,"Hold E at your grown tree again."end
 local pad=selection.GrowthPad or 1;local key=Pads.Key(pad)
 if not key or pad>Pads.Maximum(profile)then return false,"That growth pad is locked."end
 local g=profile[key]
 if not g or g.State~="Ready"or g.Id~=growthId then return false,"That tree is no longer ready."end
 if type(index)~="number"or index%1~=0 or index<1 or index>maximum or not table.find(selection.Plots,index)then return false,"That plot is not available."end
 if selection.Targets and selection.Targets[index]~=(profile.Plots[index]and(profile.Plots[index].Id or profile.Plots[index])or false)then return false,"That plot changed. Hold E at your grown tree again."end
 if profile.Plots[index] and not confirmed then return false,"Confirm replacement before changing this tree."end
 return true
end
return Rules
