-- Primitive catalog icons inspired by the reference pack's framed model tiles.
local S=game:GetService("ReplicatedStorage").BuildATree
local T=require(S.Theme)
local Preview=require(S.Util.PreviewModels)
local Profile=require(S.Util.Profile)
local Icons={}
local function part(model,name,size,pos,color,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=pos;p.Color=color;p.Anchored=true;p.CanCollide=false;p.Material=Enum.Material.SmoothPlastic;if shape then p.Shape=shape end;p.Parent=model;return p
end
function Icons.Make(kind)
 if kind=="LeafPower" then return Preview.Part(Profile.Starter().Leaves) end
 if kind=="Plots" then return Preview.Tree(Profile.Starter()) end
 local model=Instance.new("Model");model.Name=kind
 if kind=="Bag" then
  part(model,"Backpack",Vector3.new(2,2.4,.9),Vector3.zero,T.Blue)
  part(model,"Pocket",Vector3.new(1.5,.8,.35),Vector3.new(0,-.5,.6),T.Gold)
  for _,x in {-.55,.55} do part(model,"Strap",Vector3.new(.25,2.7,.2),Vector3.new(x,0,-.6),T.Purple) end
  part(model,"Handle",Vector3.new(.8,.25,.25),Vector3.new(0,1.4,0),T.Ink)
 elseif kind=="Radius" then
  for _,x in {-1,1} do part(model,"MagnetArm",Vector3.new(.6,2,.6),Vector3.new(x,.4,0),T.Red);part(model,"Tip",Vector3.new(.6,.5,.6),Vector3.new(x,1.4,0),T.Cream) end
  part(model,"MagnetBase",Vector3.new(2.6,.6,.6),Vector3.new(0,-.6,0),T.Red)
  part(model,"Fruit",Vector3.new(.7,.7,.7),Vector3.new(0,1.7,.2),T.Gold,Enum.PartType.Ball)
 elseif kind=="Discount" then
  for i=1,4 do local coin=part(model,"Coin",Vector3.new(.25,1.8,1.8),Vector3.new((i%2)*.3,i*.3,0),T.Gold,Enum.PartType.Cylinder);coin.Orientation=Vector3.new(0,0,90) end
 elseif kind=="Batch" then
  for i=1,3 do local fruit=Preview.Fruit({Name="Apple",Tier=i,Mutation="None"});fruit:ScaleTo(.65);fruit:PivotTo(CFrame.new((i-2)*1.5,0,0));fruit.Parent=model end
 elseif kind=="PetSlots" then
  for i=1,3 do local color=({T.Pink,T.Blue,T.Gold})[i];part(model,"Buddy",Vector3.new(1,1,1),Vector3.new((i-2)*1.2,0,0),color,Enum.PartType.Ball);for _,x in {-.3,.3} do part(model,"Ear",Vector3.new(.3,.6,.4),Vector3.new((i-2)*1.2+x,.6,0),color,Enum.PartType.Ball) end end
 elseif kind=="Water" then
  part(model,"Can",Vector3.new(1.6,1.8,1.3),Vector3.zero,T.Teal)
  local spout=part(model,"Spout",Vector3.new(1.5,.35,.4),Vector3.new(1.1,.4,0),T.Teal);spout.Orientation=Vector3.new(0,0,30)
  for _,y in {-.6,.6} do part(model,"Handle",Vector3.new(.9,.2,.25),Vector3.new(-1,y,0),T.Blue) end
  part(model,"HandleSide",Vector3.new(.2,1.4,.25),Vector3.new(-1.4,0,0),T.Blue)
 elseif kind=="Scarecrow" then
  part(model,"Post",Vector3.new(.35,3.2,.35),Vector3.zero,T.Wood);part(model,"Arms",Vector3.new(2.7,.3,.3),Vector3.new(0,.3,0),T.Wood)
  part(model,"Head",Vector3.new(1.2,1.2,1.2),Vector3.new(0,1.3,0),T.Gold,Enum.PartType.Ball);part(model,"Hat",Vector3.new(1.7,.25,1.4),Vector3.new(0,2,0),T.Green)
 elseif kind=="BugSpray" then
  part(model,"Bottle",Vector3.new(1.4,2,1),Vector3.zero,T.Teal);part(model,"Cap",Vector3.new(.8,.35,.8),Vector3.new(0,1.2,0),T.Blue);part(model,"Sprayer",Vector3.new(1.4,.3,.4),Vector3.new(.2,1.5,0),T.Cream)
 elseif kind=="Fence" then
  for _,x in {-1.3,1.3} do part(model,"Post",Vector3.new(.35,2.7,.35),Vector3.new(x,0,0),T.Wood) end
  for _,y in {-.6,.6} do local rail=part(model,"ElectricRail",Vector3.new(2.8,.3,.3),Vector3.new(0,y,0),T.Blue);rail.Material=Enum.Material.Neon end
 elseif kind=="Shield" then
  local bubble=part(model,"Shield",Vector3.new(2.7,2.7,2.7),Vector3.zero,T.Blue,Enum.PartType.Ball);bubble.Transparency=.45
  part(model,"Core",Vector3.new(1.2,1.5,1.2),Vector3.zero,T.Cream,Enum.PartType.Ball)
 elseif kind:match("^Egg") then
  local tier=tonumber(kind:match("%d+")) or 1;local color=({T.Green,T.Blue,T.Pink})[tier]
  part(model,"Egg",Vector3.new(1.8,2.4,1.8),Vector3.zero,T.Cream,Enum.PartType.Ball)
  for i=1,5 do local a=i*math.pi*2/5;part(model,"EggSpot",Vector3.new(.5,.6,.25),Vector3.new(math.sin(a)*.7,math.cos(a)*.7,.75),color,Enum.PartType.Ball) end
 end
 return model
end
function Icons.Viewport(parent,kind)
 local vp=Instance.new("ViewportFrame");vp.Name="Icon";vp.BackgroundTransparency=1;vp.Size=UDim2.fromScale(1,1);vp.Ambient=Color3.fromRGB(210,210,210);vp.LightColor=Color3.new(1,1,1);vp.LightDirection=Vector3.new(-1,-1,-1);vp.Parent=parent
 local world=Instance.new("WorldModel");world.Parent=vp;local model=Icons.Make(kind);model.Parent=world
 local cf,size=model:GetBoundingBox();local distance=math.max(size.X,size.Y,size.Z)*1.8
 local camera=Instance.new("Camera");camera.FieldOfView=35;camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance*.6,distance*.35,distance),cf.Position);camera.Parent=vp;vp.CurrentCamera=camera
 return vp
end
return Icons
