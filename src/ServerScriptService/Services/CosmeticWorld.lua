-- Bounded server-authored garden decorations and tree auras, never stats.
local C=require(game.ReplicatedStorage.BuildATree.Config)
local Collection=require(game.ReplicatedStorage.BuildATree.Util.Collection)
local CosmeticWorld={}
function CosmeticWorld.Apply(W,player,p)
 local g=W.Gardens[player];if not g then return end
 Collection.Ensure(p);local j=p.Journal;local equipped=j.Cosmetics.Equipped
 local function owned(slot)
  local key=equipped[slot];local item=C.Cosmetics.Items[key]
  return item and item.Slot==slot and j.Cosmetics.Owned[key]and item or nil
 end
 local title=owned("Title");local board=g.Folder:FindFirstChild("GardenName")
 if board then for _,label in board:GetDescendants()do if label:IsA("TextLabel")then
  label.Text=player.DisplayName.."'s Garden\n♥ "..(j.LikesReceived or 0).." likes"..(title and (" • "..title.Name)or "")
 end end end
 local decor=owned("Decoration");local key=decor and equipped.Decoration or ""
 if g.DecorationKey~=key then
  g.DecorationKey=key;local old=g.Folder:FindFirstChild("EarnedDecoration");if old then old:Destroy()end
  if decor then
   local model=Instance.new("Model");model.Name="EarnedDecoration";local pos=g.Origin+Vector3.new(23,0,25);local color=Color3.fromRGB(table.unpack(decor.Color))
   local function part(name,size,offset,tint,shape)
    local obj=W.Part(model,name,size,pos+offset,tint,shape);obj.CanCollide=false;obj.CanTouch=false;obj.CanQuery=false;return obj
   end
   part("Base",Vector3.new(4,1,4),Vector3.new(0,.5,0),Color3.fromRGB(168,112,76))
   if key=="Lantern"then
    part("Post",Vector3.new(.5,4,.5),Vector3.new(0,3,0),Color3.fromRGB(130,90,60))
    local glass=part("Lantern",Vector3.new(2,2,2),Vector3.new(0,5,0),color);glass.Material=Enum.Material.Neon;glass.Transparency=.2
   elseif key=="Pinwheel"then
    part("Post",Vector3.new(.3,4,.3),Vector3.new(0,3,0),Color3.fromRGB(130,90,60))
    for i=1,4 do local angle=math.rad(i*90);local blade=part("Blade",Vector3.new(1.6,.7,.2),Vector3.new(math.cos(angle)*.8,5+math.sin(angle)*.8,0),color);blade.Orientation=Vector3.new(0,0,i*90+25)end
    part("Hub",Vector3.new(.5,.5,.3),Vector3.new(0,5,-.2),Color3.fromRGB(255,215,90),Enum.PartType.Ball)
   else
    for _,x in {-1,0,1}do
     part("Stem",Vector3.new(.25,2,.25),Vector3.new(x,2,0),Color3.fromRGB(100,185,90))
     part("Bloom",Vector3.new(1.4,1.4,1.4),Vector3.new(x,3,0),color,Enum.PartType.Ball)
    end
   end
   model.Parent=g.Folder
  end
 end
 local aura=owned("Aura");local auraKey=aura and equipped.Aura or ""
 for index=1,C.Growth.TotalPlots do local tree=g.Models[index];local root=tree and tree.PrimaryPart
  if root then
   local emitter=root:FindFirstChild("EarnedAura")
   if emitter and emitter:GetAttribute("CosmeticKey")~=auraKey then emitter:Destroy();emitter=nil end
   if aura and not emitter then
    emitter=Instance.new("ParticleEmitter");emitter.Name="EarnedAura";emitter:SetAttribute("CosmeticKey",auraKey)
    emitter.Texture="rbxasset://textures/particles/sparkles_main.dds";emitter.Color=ColorSequence.new(Color3.fromRGB(table.unpack(aura.Color)))
    emitter.Rate=C.Cosmetics.AuraRate;emitter.Lifetime=NumberRange.new(1,2);emitter.Speed=NumberRange.new(.5,1)
    emitter.SpreadAngle=Vector2.new(180,180);emitter.Size=NumberSequence.new(.3);emitter.Parent=root
   end
  end
 end
end
return CosmeticWorld
