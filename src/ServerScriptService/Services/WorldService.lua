-- Colorful primitive market village, fenced gardens and bounded fruit pool.
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("BuildATree")
local C=require(Shared.Config)
local T=require(Shared.Theme)
local G=require(Shared.Util.GrowthCalculator)
local Tween=game:GetService("TweenService")
local Imported=require(Shared.Util.ImportedModels)
local W={Gardens={},Fruit={},Pool={},Slots={},Zones={},Vacant={}}
local function part(parent,name,size,position,color,shape)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.Position=position; p.Anchored=true; p.Color=color; p.Material=Enum.Material.SmoothPlastic; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end p.Parent=parent; return p
end
W.Part=part
function W.Billboard(parent,text,color)
 local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(180,50); gui.StudsOffset=Vector3.new(0,4,0); gui.AlwaysOnTop=false; gui.MaxDistance=65; gui.Parent=parent
 local label=Instance.new("TextLabel"); label.Name="Label"; label.Size=UDim2.fromScale(1,.72); label.BackgroundTransparency=1; label.Text=text; label.Font=Enum.Font.FredokaOne; label.TextSize=20; label.TextColor3=color or T.Cream; label.TextStrokeColor3=T.Ink; label.TextStrokeTransparency=0; label.Parent=gui
 local bar=Instance.new("Frame"); bar.Name="Bar"; bar.Position=UDim2.fromScale(.05,.82); bar.Size=UDim2.fromScale(.9,.12); bar.BackgroundColor3=color or T.Green; bar.BorderSizePixel=0; bar.Visible=false; bar.Parent=gui
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(1,0); corner.Parent=bar
 return gui
end
local function sign(parent,name,message,pos,size,color)
 -- Put the sign in front of its support posts, and render text on one face only.
 local board=part(parent,name,size,pos+Vector3.new(0,0,1),color)
 for _,face in {Enum.NormalId.Back} do
  local surface=Instance.new("SurfaceGui"); surface.Face=face; surface.ZOffset=2; surface.AlwaysOnTop=false; surface.CanvasSize=Vector2.new(700,200); surface.Parent=board
  local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(.94,.9); label.Position=UDim2.fromScale(.03,.05); label.BackgroundTransparency=1; label.Text=message; label.TextColor3=T.Cream; label.Font=Enum.Font.FredokaOne; label.TextScaled=true; label.TextStrokeColor3=T.Ink; label.TextStrokeTransparency=0; label.Parent=surface
 end
 return board
end
local function fence(parent,origin)
 for _,side in {-1,1} do
  for z=-36,36,9 do part(parent,"FencePost",Vector3.new(1,4,1),origin+Vector3.new(side*30,1.6,z),T.DarkWood) end
  for _,h in {1,2.5} do part(parent,"FenceRail",Vector3.new(.5,.6,72),origin+Vector3.new(side*30,h,0),T.Wood) end
 end
 for x=-30,30,10 do
  part(parent,"FencePost",Vector3.new(1,4,1),origin+Vector3.new(x,1.6,-36),T.DarkWood)
  if math.abs(x)>5 then part(parent,"GatePost",Vector3.new(1,4,1),origin+Vector3.new(x,1.6,36),T.DarkWood) end
 end
 for _,h in {1,2.5} do
  part(parent,"BackRail",Vector3.new(60,.6,.5),origin+Vector3.new(0,h,-36),T.Wood)
  for _,side in {-1,1} do part(parent,"GateRail",Vector3.new(24,.6,.5),origin+Vector3.new(side*18,h,36),T.Wood) end
 end
end
local function scenicTree(parent,pos,color,height)
 local trunk=part(parent,"SceneryTrunk",Vector3.new(2,height,2),pos+Vector3.new(0,height/2,0),T.Wood)
 for j=1,3 do
  local leaf=part(parent,"SceneryCanopy",Vector3.new(8,7,8),pos+Vector3.new((j-2)*3,height+(j==2 and 3 or 0),0),color,Enum.PartType.Ball); leaf.CanCollide=false
 end
 return trunk
end
local function stand(root,name,pos,color,caption,kind)
 local model=Instance.new("Model"); model.Name=name; model.Parent=root
 local counter=part(model,"Counter",Vector3.new(16,3,5),pos+Vector3.new(0,1.5,0),T.Wood)
 part(model,"CounterTop",Vector3.new(17,.5,6),pos+Vector3.new(0,3.2,0),T.DarkWood)
 for _,x in {-7.4,7.4} do part(model,"AwningPost",Vector3.new(.65,9,.65),pos+Vector3.new(x,4.5,0),T.DarkWood) end
 for i=1,10 do
  local stripe=part(model,"CanopyStripe",Vector3.new(1.8,.5,9),pos+Vector3.new((i-5.5)*1.8,9.2,0),i%2==0 and T.Cream or color); stripe.Orientation=Vector3.new(-8,0,0)
  part(model,"ScallopedTrim",Vector3.new(1.8,1,1),pos+Vector3.new((i-5.5)*1.8,8.7,4.5),i%2==0 and T.Cream or color,Enum.PartType.Ball)
 end
 sign(model,"MarketSign",caption,pos+Vector3.new(0,12,0),Vector3.new(20,3,.6),color)
 for i=1,3 do
  local crate=part(model,"ProduceCrate",Vector3.new(3,1,3),pos+Vector3.new((i-2)*4,3.8,0),T.DarkWood)
  for j=1,3 do part(model,"DisplayFruit",Vector3.new(1.2,1.2,1.2),crate.Position+Vector3.new((j-2)*.8,1,0),T.Fruit[i],Enum.PartType.Ball) end
 end
 local zone=part(model,"WelcomeZone",Vector3.new(17,.12,10),pos+Vector3.new(0,.05,9),color); zone.Material=Enum.Material.Neon; zone.Transparency=.35; zone.CanCollide=false
 local label=W.Billboard(zone,kind=="Sell" and "SELL FRUIT HERE" or "STEP IN TO SHOP",T.Cream); label.StudsOffset=Vector3.new(0,1,0); label.MaxDistance=100
 local prompt=Instance.new("ProximityPrompt"); prompt.ActionText=kind=="Sell" and "Sell all fruit" or "Open shop"; prompt.ObjectText=caption; prompt.HoldDuration=0; prompt.MaxActivationDistance=C.Runtime.ShopRange; prompt.Parent=counter
 W.Zones[kind]={Position=zone.Position,Radius=8}
 return prompt
end
function W.Init()
 local old=workspace:FindFirstChild("BuildATreeWorld"); if old then old:Destroy() end
 local root=Instance.new("Folder"); root.Name="BuildATreeWorld"; root.Parent=workspace; W.Root=root
 local lighting=game:GetService("Lighting"); lighting.ClockTime=13.5; lighting.Brightness=2; lighting.Ambient=Color3.fromRGB(110,115,100); lighting.OutdoorAmbient=Color3.fromRGB(135,145,120)
 local grade=lighting:FindFirstChild("GardenColor") or Instance.new("ColorCorrectionEffect"); grade.Name="GardenColor"; grade.Saturation=.04; grade.Contrast=.02; grade.Parent=lighting
 part(root,"Meadow",Vector3.new(680,2,680),Vector3.new(0,-.5,80),T.Grass)
 -- Small row-sized subtrees bound each insertion into the live DataModel.
 for z=-130,310,20 do
  local row=Instance.new("Folder"); row.Name="GrassTiles"
  for x=-160,160,20 do
   local tile=part(row,"Grass",Vector3.new(20,.1,20),Vector3.new(x,.56,z),((x+z)/20)%2==0 and T.Grass or T.GrassAlt); tile.TopSurface=Enum.SurfaceType.Studs
  end
  row.Parent=root; task.wait()
 end
 part(root,"GardenAvenue",Vector3.new(19,.25,360),Vector3.new(0,.72,125),T.Path)
 part(root,"MarketSquare",Vector3.new(112,.25,70),Vector3.new(0,.73,-55),T.Path)
 for z=-5,275,10 do part(root,"AvenuePaver",Vector3.new(2,.08,4),Vector3.new(0,.9,z),Color3.fromRGB(255,240,198)) end
 -- Layered block hills frame the play area without external terrain or textures.
 for _,side in {-1,1} do
  part(root,"OrchardCliff",Vector3.new(35,25,470),Vector3.new(side*190,10,90),Color3.fromRGB(199,145,87))
  part(root,"HillGrass",Vector3.new(39,2,474),Vector3.new(side*190,23,90),T.Green)
  for z=-110,310,35 do
   part(root,"CliffInset",Vector3.new(1,23,15),Vector3.new(side*172,10,z),Color3.fromRGB(218,164,101))
   scenicTree(root,Vector3.new(side*146,.6,z),z%2==0 and T.Green or T.Lime,8)
  end
 end
 for _,z in {-155,330} do part(root,"EndHill",Vector3.new(415,23,25),Vector3.new(0,10,z),Color3.fromRGB(199,145,87)); part(root,"EndGrass",Vector3.new(420,2,29),Vector3.new(0,22,z),T.Green) end
 W.Shop=Vector3.new(-25,2,-61)
 W.Prompt=stand(root,"FruitSellStand",Vector3.new(-25,.9,-61),T.Red,"SELL FRUIT","Sell")
 W.ShopPrompt=stand(root,"GardenShopStand",Vector3.new(25,.9,-61),T.Blue,"GARDEN SHOP","Shop")
 for _,x in {-57,57} do scenicTree(root,Vector3.new(x,.6,-55),T.Pink,10); scenicTree(root,Vector3.new(x,.6,-85),T.Green,8) end
 for _,x in {-44,44} do for z=-35,290,65 do
  for j=1,3 do local shrub=part(root,"PathHedge",Vector3.new(4,3,4),Vector3.new(x+(j-2)*3,1.5,z),T.Green,Enum.PartType.Ball); shrub.CanCollide=false end
 end end
 local spawn=Instance.new("SpawnLocation"); spawn.Name="GardenSpawn"; spawn.Size=Vector3.new(8,.2,8); spawn.Position=Vector3.new(0,.95,-32); spawn.Transparency=1; spawn.Neutral=true; spawn.Parent=root
 local news=sign(root,"UpdateNews",C.News.Version.."\nTREE PARTS → JOURNAL\nCollections • Daily goals • News",Vector3.new(25,5,-95),Vector3.new(18,6,.6),T.Blue)
 local welcome=sign(root,"WelcomeBoard","BUILD A TREE",Vector3.new(0,13,-95),Vector3.new(34,5,1),T.Green)
 for _,x in {-15,15} do part(root,"WelcomePost",Vector3.new(1,14,1),Vector3.new(x,6,-95),T.DarkWood) end
 local vip=part(root,"VIPTerrace",Vector3.new(24,.5,18),Vector3.new(0,1,-117),T.Gold); W.Billboard(vip,"VIP GARDEN",T.Gold); W.VIPPosition=vip.Position
 for i=1,C.Runtime.MaxFruit do
  local fruit=part(root,"PooledFruit",Vector3.new(1,1,1)*C.Runtime.FruitSize,Vector3.new(0,-100,0),T.Red,Enum.PartType.Ball)
  fruit.CanCollide=false; fruit.CanTouch=false; fruit.CanQuery=false; fruit.Transparency=1
  local emitter=Instance.new("ParticleEmitter"); emitter.Name="Mutation"; emitter.Rate=0; emitter.Lifetime=NumberRange.new(.5,1); emitter.Speed=NumberRange.new(1,3); emitter.Parent=fruit; table.insert(W.Pool,fruit)
 end
 for i=1,C.Runtime.MaxPlayers do
  local placeholder={UserId=-i,DisplayName="Unclaimed"}
  local garden=W.Assign(placeholder); garden.Folder.Name="AvailableGarden_"..i; W.Vacant[i]=garden.Folder; W.Gardens[placeholder]=nil; task.wait()
 end
 table.clear(W.Slots)
end
function W.Assign(player)
 local slot; for i=1,C.Runtime.MaxPlayers do if not W.Slots[i] then slot=i; break end end
 if not slot then return nil end; W.Slots[slot]=player
 if W.Vacant[slot] then W.Vacant[slot]:Destroy(); W.Vacant[slot]=nil end
 local folder=Instance.new("Folder"); folder.Name="Garden_"..player.UserId; folder.Parent=W.Root
 local side=slot%2==1 and 1 or -1
 local origin=Vector3.new(side*59,1.1,math.floor((slot-1)/2)*86)
 local g={Folder=folder,Origin=origin,Slot=slot,Models={},Pads={}}; W.Gardens[player]=g
 part(folder,"GardenLawn",Vector3.new(60,.3,72),origin+Vector3.new(0,-.3,0),T.Grass)
 fence(folder,origin)
 part(folder,"GardenWalk",Vector3.new(8,.15,65),origin+Vector3.new(0,.01,0),T.Path)
 part(folder,"AvenueConnection",Vector3.new(math.abs(origin.X),.16,8),Vector3.new(origin.X/2,.88,origin.Z+36),T.Path)
 for i=1,C.Growth.TotalPlots+2 do
  local offset=i>=7 and Vector3.new(i==7 and -9 or 9,.2,23) or Vector3.new(((i-1)%3-1)*18,.2,math.floor((i-1)/3)*18-22)
  local pos=origin+offset
  part(folder,"BedBorder",Vector3.new(15,.5,15),pos,T.DarkWood)
  local pad=part(folder,"Plot"..i,Vector3.new(13.5,.55,13.5),pos+Vector3.new(0,.15,0),i>=7 and Color3.fromRGB(124,175,67) or T.Soil); g.Pads[i]=pad
  pad:SetAttribute("OwnerUserId",player.UserId);pad:SetAttribute("PlotIndex",i)
  local marker=sign(folder,"PlotMarker",i>=7 and ("GROW "..(i-6)) or tostring(i),pos+Vector3.new(5,1.5,5),Vector3.new(i>=7 and 4 or 2,1.5,.25),i>=7 and T.Green or T.Wood)
 end
 sign(folder,"GardenName",player.DisplayName.."'s Garden",origin+Vector3.new(18,4,36),Vector3.new(23,3,.5),T.Green)
 for _,x in {-27,27} do
  for z=-25,25,10 do part(folder,"Flower",Vector3.new(.6,1.2,.6),origin+Vector3.new(x,.7,z),z%20==5 and T.Gold or T.Pink,Enum.PartType.Ball) end
 end
 return g
end

function W.Status(player,p,now)
 local g=W.Gardens[player]; if not g then return end
 local extra=g.Pads[8];local unlocked=require(script.Parent.GrowthService).MaxPads(p)>1
 extra.Color=unlocked and T.Green or T.Soil
 local label=extra:FindFirstChild("UnlockHint")
 if not label then label=W.Billboard(extra,"",T.Gold);label.Name="UnlockHint"end
 label.Label.Text=unlocked and ""or "Ascend to unlock pad 2";label.Enabled=not unlocked
 local Entitlements=require(game.ReplicatedStorage.BuildATree.Util.Entitlements)
 local statuses={GardenAura=Entitlements.Has(p,"Cosmetics")or Entitlements.Has(p,"VIP"),Scarecrow=p.Defenses.Scarecrow,Fence=p.Defenses.Fence,Shield=(p.Boosts.ShieldUntil or 0)>now,Pests=(p.Boosts.PestUntil or 0)>now}
 for name,active in statuses do
  local existing=g.Folder:FindFirstChild(name)
  if active and not existing then
   local model=Instance.new("Model"); model.Name=name
   if name=="GardenAura"then
    for _,x in {-25,25}do local glow=part(model,"GoldenPetal",Vector3.new(1,.2,1),g.Origin+Vector3.new(x,1,29),Color3.fromRGB(255,213,85),Enum.PartType.Ball);glow.Material=Enum.Material.Neon end
   elseif name=="Scarecrow" then
    part(model,"Post",Vector3.new(.5,6,.5),g.Origin+Vector3.new(23,3,0),Color3.fromRGB(138,91,56))
    part(model,"Arms",Vector3.new(5,.5,.5),g.Origin+Vector3.new(23,4,0),Color3.fromRGB(138,91,56))
    part(model,"Pumpkin",Vector3.new(2,2,2),g.Origin+Vector3.new(23,6,0),Color3.fromRGB(244,160,62),Enum.PartType.Ball)
   elseif name=="Shield" then local bubble=part(model,"Bubble",Vector3.new(65,40,60),g.Origin,Color3.fromRGB(103,204,255),Enum.PartType.Ball); bubble.Transparency=.85; bubble.CanCollide=false
   elseif name=="Fence" then for _,x in {-27,27} do local fence=part(model,"ElectricRail",Vector3.new(.3,3,45),g.Origin+Vector3.new(x,1,0),Color3.fromRGB(96,224,255)); fence.Material=Enum.Material.Neon; fence.Transparency=.5 end
   elseif name=="Pests" then for i=1,5 do part(model,"Bug",Vector3.new(.8,.5,1),g.Origin+Vector3.new(-17+i,2,0),Color3.fromRGB(71,43,80),Enum.PartType.Ball) end end
   model.Parent=g.Folder
  elseif not active and existing then existing:Destroy() end
 end
end
function W.Tree(player,index,build,state,progress,heightScale)
 local g=W.Gardens[player];if not g then return end
 local key=tostring(index)..state..tostring(heightScale or 1)
 for _,slot in C.Slots do local item=build[slot];key..=":"..tostring(item.Id)..":"..item.Name..":"..tostring(item.Mutation) end
 local existing=g.Models[index]
 if not existing or existing:GetAttribute("BuildKey")~=key then
  if existing then existing:Destroy() end
  local model=require(game.ReplicatedStorage.BuildATree.Util.PreviewModels).Tree(build,heightScale,true)
  model.Name="Tree_"..index;model:SetAttribute("BuildKey",key)
  local base=g.Pads[index].Position+Vector3.new(0,.5,0);model:PivotTo(CFrame.new(base))
  local height=G.Height(build,heightScale)
  model:SetAttribute("BasePosition",base);model:SetAttribute("Height",height)
  local label=W.Billboard(model.PrimaryPart,state=="Producing" and string.format("%.1f studs",height) or state,C.Rarities[G.Tier(build)].Color);label.Name="Progress"
  if state=="Producing" then label.Bar.Visible=false end
  model.Parent=g.Folder;g.Models[index]=model;existing=model
 end
 existing:SetAttribute("GrowthState",state);existing:SetAttribute("Progress",progress or 1)
 return existing
end
function W.GrowthPrompt(player,kind,callback,index)
 local g=W.Gardens[player];local model=g and g.Models[index or 7];if not model or not model.PrimaryPart then return end
 local old=model.PrimaryPart:FindFirstChild("TreeInteraction")
 if old and old:GetAttribute("Kind")==kind then return end
 if old then old:Destroy()end
 local prompt=Instance.new("ProximityPrompt");prompt.Name="TreeInteraction";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.RequiresLineOfSight=false;prompt.MaxActivationDistance=C.Placement.PromptRange
 prompt.HoldDuration=kind=="Ready"and C.Placement.HoldSeconds or C.Placement.WaterHold
 prompt.ActionText=kind=="Ready"and "Plant / replace a tree"or "Water tree";prompt.ObjectText=kind=="Ready"and "Fully grown tree"or "Growing tree"
 prompt:SetAttribute("OwnerUserId",player.UserId);prompt:SetAttribute("Kind",kind);prompt.Parent=model.PrimaryPart;prompt.Triggered:Connect(callback)
end
function W.Invalidate(player,index)
 local g=W.Gardens[player]; if g and g.Models[index] then g.Models[index]:Destroy(); g.Models[index]=nil end
end
function W.SpawnFruit(player,index,value,mutation,now,metadata)
 if #W.Pool==0 then return end
 local g=W.Gardens[player]; if not g then return end
 local fruit=table.remove(W.Pool)
 local landing=g.Pads[index].Position+Vector3.new(math.random(-C.Runtime.FruitSpacing,C.Runtime.FruitSpacing),2,math.random(-C.Runtime.FruitSpacing,C.Runtime.FruitSpacing))
 local tree=g.Models[index]; local height=tree and tree:GetAttribute("Height") or 9
 fruit.Position=g.Pads[index].Position+Vector3.new(math.random(-2,2),height-1,math.random(-2,2)); fruit.Orientation=Vector3.zero
 fruit.Color=mutation.Color; fruit.Material=mutation.Material; fruit.Transparency=0
 fruit.Mutation.Color=ColorSequence.new(mutation.Color); fruit.Mutation.Rate=mutation.Particles
 fruit:SetAttribute("Owner",player.UserId); fruit:SetAttribute("Value",value); fruit:SetAttribute("MutationName",mutation.Name)
 if metadata and Imported.Is(metadata,"Fruit") then
  local copy=table.clone(metadata);copy.Slot="Fruit";local visual=Imported.Part(copy);visual.Name="ImportedVisual"
  visual:ScaleTo(C.Runtime.FruitSize/2);visual:PivotTo(fruit.CFrame);visual.Parent=fruit;fruit.Transparency=1
  for _,p in visual:GetDescendants() do if p:IsA("BasePart") then
   p.Anchored=false;p.Massless=true;p.CanQuery=false
   local weld=Instance.new("WeldConstraint");weld.Part0=fruit;weld.Part1=p;weld.Parent=p
  end end
 end
 local record={Owner=player,Value=value,Born=now,Index=index,Metadata=metadata or {Name="Harvest Fruit",Tier=1,Mutation=mutation.Name},ReadyAt=now+C.Inventory.FallSeconds+C.Inventory.BounceSeconds}
 W.Fruit[fruit]=record
 local fall=Tween:Create(fruit,TweenInfo.new(C.Inventory.FallSeconds,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{CFrame=CFrame.new(landing+Vector3.new(0,.8,0))*CFrame.Angles(math.rad(25),math.rad(80),math.rad(20))})
 record.Tween=fall
 fall.Completed:Connect(function(state)
  if state~=Enum.PlaybackState.Completed or W.Fruit[fruit]~=record then return end
  fall:Destroy()
  local bounce=Tween:Create(fruit,TweenInfo.new(C.Inventory.BounceSeconds,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{CFrame=CFrame.new(landing)*CFrame.Angles(0,math.rad(95),0)}); record.Tween=bounce; bounce:Play()
 end)
 fall:Play(); return fruit
end
function W.ClearPlotFruit(player,index)
 local remove={};for fruit,r in W.Fruit do if r.Owner==player and r.Index==index then table.insert(remove,fruit)end end
 for _,fruit in remove do W.Recycle(fruit)end
end
function W.Recycle(fruit)
 if not W.Fruit[fruit] then return end
 local record=W.Fruit[fruit]; W.Fruit[fruit]=nil
 local visual=fruit:FindFirstChild("ImportedVisual");if visual then visual:Destroy() end
 if record.Tween then record.Tween:Cancel(); record.Tween:Destroy() end
 fruit.Transparency=1; fruit.Position=Vector3.new(0,-100,0); fruit.Mutation.Rate=0; fruit:SetAttribute("Owner",nil); table.insert(W.Pool,fruit)
end
function W.Remove(player)
 local g=W.Gardens[player]; if g then
  for _,model in g.Models do model:Destroy() end
  for _,name in {"Scarecrow","Fence","Shield","Pests"} do local prop=g.Folder:FindFirstChild(name); if prop then prop:Destroy() end end
  local board=g.Folder:FindFirstChild("GardenName"); if board then for _,label in board:GetDescendants() do if label:IsA("TextLabel") then label.Text="Unclaimed Garden" end end end
  g.Folder.Name="AvailableGarden_"..g.Slot; W.Vacant[g.Slot]=g.Folder; W.Slots[g.Slot]=nil; W.Gardens[player]=nil
 end
 for fruit,record in W.Fruit do if record.Owner==player then W.Recycle(fruit) end end
end
return W
