-- Standardized Common/Uncommon models and authored join/socket metadata.
local S=script.Parent.Parent
local Catalog=require(script.Parent.PartCatalog)
local Templates=S:WaitForChild("Assets"):WaitForChild("Starter")
local A={BaseHeight=6.4}
local definitions={
 ["Trunk:Oak"]={Asset="OakTrunk",Tier=1,Attach={0,0,0},Sockets={}},
 ["Trunk:Pine"]={Asset="PineTrunk",Tier=1,Attach={0,0,0},Sockets={}},
 ["Trunk:Maple"]={Asset="MapleTrunk",Tier=1,Attach={0,0,0},Sockets={}},
 ["Trunk:Willow"]={Asset="WillowTrunk",Tier=2,Attach={0,0,0},Sockets={}},
 ["Trunk:Aspen"]={Asset="AspenTrunk",Tier=2,Attach={0,0,0},Sockets={}},
 ["Trunk:Silver Birch"]={Asset="SilverBirchTrunk",Tier=2,Attach={0,0,0},Sockets={}},
 ["Leaves:Clover"]={Asset="CloverLeaves",Tier=1,Attach={0,0,0},Sockets={{0.990403,0.359659,0.677571},{-0.677571,0.394825,0.990403},{-0.990403,0.363852,-0.677571},{0.677571,0.391043,-0.990403}}},
 ["Leaves:Oakleaf"]={Asset="OakleafLeaves",Tier=1,Attach={0,0,0},Sockets={{0.990403,0.537883,0.677571},{-0.677571,0.558749,0.990403},{-0.866602,1.003925,-0.592875},{0.677571,0.749522,-0.990403}}},
 ["Leaves:Sprout"]={Asset="SproutLeaves",Tier=1,Attach={0,0,0},Sockets={{0.990403,0.983417,0.677571},{-0.677571,0.997523,0.990403},{-0.866602,1.055083,-0.592875},{0.677571,1.541987,-0.990403}}},
 ["Leaves:Fern"]={Asset="FernLeaves",Tier=2,Attach={0,0,0},Sockets={{0.990403,0.371452,0.677571},{-0.677571,0.493948,0.990403},{-0.990403,0.299796,-0.677571},{0.677571,0.283277,-0.990403}}},
 ["Leaves:Ivy"]={Asset="IvyLeaves",Tier=2,Attach={0,0,0},Sockets={{0.990403,0.426631,0.677571},{-0.677571,0.609102,0.990403},{-0.990403,0.400598,-0.677571},{0.677571,0.324943,-0.990403}}},
 ["Leaves:Palm Fan"]={Asset="PalmFanLeaves",Tier=2,Attach={0,0,0},Sockets={{0.990403,2.255072,0.677571},{-0.677571,2.283296,0.990403},{-0.990403,2.255072,-0.677571},{0.677571,2.283296,-0.990403}}},
 ["Roots:Taproot"]={Asset="Taproot",Tier=1,Attach={0,0,0},Sockets={}},
 ["Roots:Fibrous Root"]={Asset="FibrousRoot",Tier=1,Attach={0,0,0},Sockets={}},
 ["Roots:Knotted Root"]={Asset="KnottedRoot",Tier=1,Attach={0,0,0},Sockets={}},
 ["Roots:Vine"]={Asset="VineRoots",Tier=2,Attach={0,0,0},Sockets={}},
 ["Roots:Mangrove Root"]={Asset="MangroveRoot",Tier=2,Attach={0,0,0},Sockets={}},
 ["Roots:Creeping Root"]={Asset="CreepingRoot",Tier=2,Attach={0,0,0},Sockets={}},
 ["Fruit:Apple"]={Asset="Apple",Tier=1,Attach={0.04999999999999999,0.59309,0},Sockets={}},
 ["Fruit:Cherry"]={Asset="CherryFruit",Tier=1,Attach={0,0.6974679487179486,0},Sockets={}},
 ["Fruit:Orange"]={Asset="OrangeFruit",Tier=1,Attach={0.019607843137254905,0.5196078431372549,0},Sockets={}},
 ["Fruit:Pear"]={Asset="PearFruit",Tier=2,Attach={0.14049209893414852,0.8467913579041795,0},Sockets={}},
 ["Fruit:Peach"]={Asset="PeachFruit",Tier=2,Attach={0.015000000000000025,0.60500000002059,0},Sockets={}},
 ["Fruit:Lemon"]={Asset="LemonFruit",Tier=2,Attach={0,0.3741,0},Sockets={}}
}
function A.Definition(item,slot)
 if type(item.Name)~="string" then return nil end
 local d=definitions[slot..":"..item.Name]
 return d and d.Tier==(item.Tier or 1) and d or nil
end
function A.Is(item,slot) return slot~=nil and A.Definition(item,slot)~=nil end
function A.Clone(slot,item)
 local d=assert(A.Definition(item,slot));local model=Templates[d.Asset]:Clone();model.WorldPivot=CFrame.identity
 model:SetAttribute("ImportedStarter",slot);model:SetAttribute("CatalogName",item.Name)
 for _,p in model:GetDescendants() do if p:IsA("BasePart") then
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false
  if slot~="Fruit" or (not p.Name:find("Stem") and not p.Name:find("Leaf")) then Catalog.Style(p,item) end
 end end
 return model
end
function A.Fit(model,size,center)
 local cf,old=model:GetBoundingBox();local ratio=size.Y/old.Y
 for _,p in model:GetDescendants() do if p:IsA("BasePart") then p.Size*=ratio;p.CFrame=CFrame.new((p.Position-cf.Position)*ratio+center)*p.CFrame.Rotation end end
 model.WorldPivot=CFrame.identity;return model
end
function A.Part(item)
 if not A.Is(item,item.Slot) then return nil end
 local model=A.Clone(item.Slot,item)
 if item.Slot=="Fruit" then for _,p in model:GetDescendants() do if p:IsA("BasePart") then p.Size*=2;p.CFrame=CFrame.new(p.Position*2)*p.CFrame.Rotation end end end
 return model
end
-- Edits to the refreshed reference remain available without applying legacy geometry.
function A.Adjust(component,key,height)
 local editor=S:FindFirstChild("StarterTreeEditor") or workspace:FindFirstChild("StarterTreeEditor")
 if not editor or not editor:FindFirstChild("AssemblyVersion") or editor.AssemblyVersion.Value~=2 then return end
 local name=component:GetAttribute("CatalogName");local expected=({Trunk="Oak",Leaves="Clover",Roots="Taproot"})[key] or "Apple"
 if name~=expected then return end
 local origin=editor.EditorOrigin.CFrame;local ref=editor:FindFirstChild(key)
 if not ref then return end
 local ratio=height/(editor:FindFirstChild("ReferenceHeight") and editor.ReferenceHeight.Value or 13.5)
 for _,p in component:GetDescendants() do if p:IsA("BasePart") then local original=ref:FindFirstChild(p.Name,true);if original and original:IsA("BasePart") then local cf=origin:ToObjectSpace(original.CFrame);p.Size=original.Size*ratio;p.CFrame=CFrame.new(cf.Position*ratio)*cf.Rotation end end end
 -- Keep canonical join pivots even when editor Models are reloaded from source.
end
function A.Socket(build,index)
 local d=A.Definition(build.Leaves,"Leaves")
 local sockets=d and d.Sockets or {{1.2,.4,.8},{-.8,.4,1.2},{-1.2,.4,-.8}}
 return Vector3.new(table.unpack(sockets[(index-1)%#sockets+1]))
end
function A.Attach(item)
 local d=A.Definition(item,"Fruit");return d and Vector3.new(table.unpack(d.Attach)) or Vector3.new(0,1.55,0)
end
return A
