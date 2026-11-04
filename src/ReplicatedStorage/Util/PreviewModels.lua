-- Shared primitive models: catalog variants and part mutations match in the world and UI.
local S=script.Parent.Parent
local T=require(S.Theme)
local C=require(S.Config)
local Catalog=require(script.Parent.PartCatalog)
local G=require(script.Parent.GrowthCalculator)
local Imported=require(script.Parent.ImportedModels)
local M={}
local function piece(parent,name,size,pos,color,shape,item)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false
 if shape then p.Shape=shape end
 if item then Catalog.Style(p,item) end
 p.Parent=parent;return p
end
-- Fixed geometry budgets: Rare 1 accent through Godly 5; mutation colors win.
local function accents(model,item)
 local tier=item.Tier or 1;if tier<3 then return end
 local count=math.min(C.RarityEffects.MaxAccentParts,tier-2)
 local color=C.Rarities[tier].Color;local cf,size=model:GetBoundingBox()
 for i=1,count do
  local angle=(i/count)*math.pi*2;local slot=item.Slot or "Fruit"
  local radius=slot=="Leaves"and size.X*.30 or slot=="Roots"and size.X*.32 or slot=="Trunk"and size.X*.40 or size.X*.38
  local y=slot=="Trunk"and (-size.Y*.3+(i/(count+1))*size.Y*.6)or slot=="Roots"and 0 or size.Y*.12
  local dimension=slot=="Trunk"and Vector3.new(.25,.5,.25)or Vector3.new(.25,.35,.25)
  local p=piece(model,"RarityAccent",dimension,cf.Position+Vector3.new(math.cos(angle)*radius,y,math.sin(angle)*radius),color,nil,item)
  p.Material=tier>=5 and Enum.Material.Neon or Enum.Material.Glass;p.Orientation=Vector3.new(0,math.deg(angle),45)
 end
end
function M.Fruit(item)
 if Imported.Is(item,"Fruit") then local copy=table.clone(item);copy.Slot="Fruit";return Imported.Part(copy) end
 local model=Instance.new("Model");model.Name=item.Name or "Fruit"
 local tier=item.Tier or 1;local variant=Catalog.Variant({Name=item.Name,Slot="Fruit",Tier=tier})
 local color=T.Fruit[tier] or T.Red
 local fruit=piece(model,"Fruit",Vector3.new(2,2,2),Vector3.zero,color,Enum.PartType.Ball,item)
 if variant==2 then
  fruit.Size=Vector3.new(1.6,2,1.6)
  piece(model,"FruitTwin",Vector3.new(1.5,1.7,1.5),Vector3.new(1,.1,0),color,Enum.PartType.Ball,item)
 elseif variant==3 then
  fruit.Size=Vector3.new(1.8,2.3,1.8)
  for i=1,4 do local a=i*math.pi/2;piece(model,"FruitRidge",Vector3.new(.4,1.8,.4),Vector3.new(math.sin(a)*.8,0,math.cos(a)*.8),color,Enum.PartType.Ball,item) end
 elseif tier==2 then fruit.Size=Vector3.new(1.6,2.5,1.6)
 elseif tier==5 then
  for i=1,5 do local a=i*math.pi*2/5;piece(model,"StarLobe",Vector3.new(.75,.75,.75),Vector3.new(math.cos(a),math.sin(a),0),color,Enum.PartType.Ball,item) end
 elseif tier>=6 then fruit.Size=Vector3.new(1.8,2.4,1.8) end
 piece(model,"Stem",Vector3.new(.18,.65,.18),Vector3.new(0,1.25,0),T.Wood)
 piece(model,"Leaf",Vector3.new(.85,.18,.42),Vector3.new(.4,1.4,0),T.Green).Orientation=Vector3.new(0,0,25)
 if item.Mutation=="Cosmic" or item.Mutation=="Void" then
  for i=1,6 do local a=i*math.pi/3;local p=piece(model,"Orbit",Vector3.new(.18,.18,.18),Vector3.new(math.cos(a)*1.6,.3,math.sin(a)*1.6),color,Enum.PartType.Ball,item);p.Material=Enum.Material.Neon end
 end
 accents(model,item)
 return model
end
function M.Part(item)
 local imported=Imported.Part(item);if imported then return imported end
 if item.Slot=="Fruit" then return M.Fruit(item) end
 local model=Instance.new("Model");model.Name=item.Name
 local tier=item.Tier or 1;local variant=Catalog.Variant(item)
 if item.Slot=="Trunk" then
  piece(model,"Trunk",Vector3.new(1.3,3.5,1.3),Vector3.zero,T.Wood,nil,item)
  for i=1,variant do piece(model,"Branch",Vector3.new(1.7,.5,.5),Vector3.new(i%2==0 and -.7 or .7,-.6+i*.7,0),T.Wood,nil,item).Orientation=Vector3.new(0,0,i%2==0 and -25 or 25) end
  if variant==2 or tier>=3 then for _,y in {-1,.8} do piece(model,"RarityBand",Vector3.new(1.45,.22,1.45),Vector3.new(0,y,0),C.Rarities[tier].Color,nil,item) end end
  if variant==3 then for i=1,4 do piece(model,"Spiral",Vector3.new(1.5,.35,1.5),Vector3.new(0,-1.5+i*.65,0),C.Rarities[tier].Color,nil,item).Orientation=Vector3.new(0,i*30,0) end end
 elseif item.Slot=="Leaves" then
  for i=1,3 do
   local size=variant==2 and Vector3.new(2.4,.8,2.4) or variant==3 and Vector3.new(1.6,2.8,1.6) or Vector3.new(2.2,2.2,2.2)
   piece(model,"Leaves",size,Vector3.new((i-2)*.9,i==2 and .6 or 0,0),T.Leaves[tier],variant==3 and Enum.PartType.Block or Enum.PartType.Ball,item).Orientation=Vector3.new(0,(i-2)*25,(i-2)*12)
  end
 else
  piece(model,"RootCore",Vector3.new(.7,1.2,.7),Vector3.new(0,.3,0),T.Wood,nil,item)
  for i=1,3+variant do local a=i*math.pi*2/(3+variant);local r=piece(model,"Root",Vector3.new(.4,variant==3 and .8 or .4,2),Vector3.new(math.sin(a)*.8,-.4,math.cos(a)*.8),tier>=3 and C.Rarities[tier].Color or T.Wood,nil,item);r.Orientation=Vector3.new(0,math.deg(a),variant==2 and 15 or 0) end
 end
 accents(model,item)
 return model
end
function M.Tree(build,heightScale,world)
 local model=Instance.new("Model");model.Name="YourTree"
 local height=G.Height(build,heightScale);local scale=height/Imported.BaseHeight
 local anchor=piece(model,"Trunk",Vector3.new(.1,.1,.1),Vector3.new(0,.05,0),T.Wood);anchor.Transparency=1;anchor.PivotOffset=CFrame.new(0,-.05,0);model.PrimaryPart=anchor
 local origins={Roots=Vector3.zero,Trunk=Vector3.new(0,.6,0),Leaves=Vector3.new(0,3.6,0)}
 for _,slot in {"Roots","Trunk","Leaves"} do
  local component=M.Part(build[slot])
  if not Imported.Is(build[slot],slot) then
   local size=slot=="Trunk" and Vector3.new(2.2,3,1.8) or slot=="Leaves" and Vector3.new(3.4,2.8,3.4) or Vector3.new(3.7,.6,3.7)
   Imported.Fit(component,size,Vector3.new(0,size.Y/2,0))
  end
  component.WorldPivot=CFrame.identity;component:ScaleTo(scale);component:PivotTo(CFrame.new(origins[slot]*scale));Imported.Adjust(component,slot,height);component.Parent=model
 end
 for j=1,3 do
  local imported=Imported.Is(build.Fruit,"Fruit")
  local fruit=imported and Imported.Clone("Fruit",build.Fruit) or M.Fruit(build.Fruit)
  local fruitScale=scale*(imported and .65 or .325);fruit.WorldPivot=CFrame.identity;fruit:ScaleTo(fruitScale)
  local socket=(origins.Leaves+Imported.Socket(build,j))*scale
  fruit:PivotTo(CFrame.new(socket-Imported.Attach(build.Fruit)*fruitScale));fruit.Name="Fruit"..j;if build.Leaves.Name=="Clover" and build.Leaves.Tier==1 then Imported.Adjust(fruit,"Fruit"..j,height) end;fruit.Parent=model
 end
 if world then
  local tier=1;for _,slot in C.Slots do tier=math.max(tier,build[slot].Tier)end
  if tier>=5 then
   local aura=Instance.new("ParticleEmitter");aura.Name="RarityAura";aura.Texture="rbxasset://textures/particles/sparkles_main.dds";aura.Color=ColorSequence.new(C.Rarities[tier].Color);aura.LightEmission=.7;aura.Rate=math.min(C.RarityEffects.MaxAuraRate,tier-3);aura.Lifetime=NumberRange.new(.7,1.2);aura.Speed=NumberRange.new(1,2);aura.SpreadAngle=Vector2.new(180,180);aura.Size=NumberSequence.new(.16);aura.Parent=anchor
   local outline=Instance.new("Highlight");outline.Name="RarityGlow";outline.Adornee=model;outline.FillTransparency=1;outline.OutlineColor=C.Rarities[tier].Color;outline.OutlineTransparency=.55;outline.DepthMode=Enum.HighlightDepthMode.Occluded;outline.Parent=model
  end
 end
 if not world then piece(model,"Soil",Vector3.new(9,.3,9),Vector3.new(0,-.3,0),T.Soil) end
 return model
end
-- Harvest previews scale size classes; rolled tree parts have no fruit size.
function M.Harvest(item)
 local model=M.Fruit(item);model:ScaleTo(model:GetScale()*require(S.Util.FruitSizes).Get(item.Size).Scale);return model
end
return M
