-- Local cosmetic feedback, floating pickups, reel shake and primitive pet companions.
local Tween=game:GetService("TweenService")
local Run=game:GetService("RunService")
local Debris=game:GetService("Debris")
local Players=game:GetService("Players")
local S=game:GetService("ReplicatedStorage"):WaitForChild("BuildATree")
local C=require(S.Config)
local Format=require(S.Util.FormatNumber)
local E={Combo=0,LastPickup=0,Pets={},Growth={},Settings={SFX=true,Music=true},ShakeUntil=0,Intensity=0}
function E.Sound(key,pitch)
 local id=C.SoundConfig[key]; if not id or id=="" or not E.Settings.SFX then return end
 local sound=Instance.new("Sound"); sound.SoundId=id; sound.PlaybackSpeed=pitch or 1; sound.Volume=E.Settings.SFXVolume or .4; sound.Parent=workspace.CurrentCamera; sound:Play(); Debris:AddItem(sound,5)
end
function E.Burst(position,color,count)
 if E.Settings.ReducedEffects then return end
 local anchor=Instance.new("Part"); anchor.Anchored=true; anchor.CanCollide=false; anchor.Transparency=1; anchor.Position=position; anchor.Parent=workspace
 local emitter=Instance.new("ParticleEmitter"); emitter.Color=ColorSequence.new(color); emitter.Speed=NumberRange.new(4,12); emitter.Lifetime=NumberRange.new(.4,1); emitter.SpreadAngle=Vector2.new(180,180); emitter.Rate=0; emitter.Parent=anchor; emitter:Emit(count); Debris:AddItem(anchor,2)
end
function E.Float(position,value)
 local anchor=Instance.new("Part"); anchor.Anchored=true; anchor.CanCollide=false; anchor.Transparency=1; anchor.Position=position; anchor.Parent=workspace
 local gui=Instance.new("BillboardGui"); gui.Size=UDim2.fromOffset(180,55); gui.AlwaysOnTop=true; gui.Parent=anchor
 local label=Instance.new("TextLabel"); label.Size=UDim2.fromScale(1,1); label.BackgroundTransparency=1; label.Text="+"..Format(value); label.TextColor3=Color3.fromRGB(255,226,104); label.Font=Enum.Font.GothamBold; label.TextSize=26; label.Parent=gui
 Tween:Create(anchor,TweenInfo.new(1),{Position=position+Vector3.new(0,5,0)}):Play(); Tween:Create(label,TweenInfo.new(1),{TextTransparency=1}):Play(); Debris:AddItem(anchor,1.1)
end
function E.Collect(data,hud)
 local now=os.clock(); E.Combo=now-E.LastPickup<C.UI.ComboSeconds and E.Combo+1 or 0; E.LastPickup=now
 E.Sound("Collect",math.min(C.UI.PitchCap,1+E.Combo*C.UI.PitchStep)); E.Float(data.Position,data.Value); E.Burst(data.Position,Color3.fromRGB(255,225,110),8)
 local pos,visible=workspace.CurrentCamera:WorldToViewportPoint(data.Position)
 if visible then
  local coin=Instance.new("Frame"); coin.Size=UDim2.fromOffset(15,15); coin.Position=UDim2.fromOffset(pos.X,pos.Y); coin.BackgroundColor3=Color3.fromRGB(255,220,85); coin.Parent=hud
  local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(1,0); corner.Parent=coin
  Tween:Create(coin,TweenInfo.new(.6),{Position=UDim2.fromScale(.5,.05),BackgroundTransparency=1}):Play(); Debris:AddItem(coin,.7)
 end
end
function E.Shake(tier)
 if E.Settings.ReducedShake then return end
 E.Intensity=C.UI.Shake[tier]; E.ShakeUntil=os.clock()+.5
end
function E.Update(state)
 E.Settings=state.Settings
 E.State=state
 local wanted={}
 for i,id in state.EquippedPets do wanted[id]=i
  if not E.Pets[id] then
   local pet=Instance.new("Part"); pet.Name="Companion"; pet.Shape=Enum.PartType.Ball; pet.Size=Vector3.new(1.5,1.5,1.5); pet.Anchored=true; pet.CanCollide=false; pet.CanQuery=false
   for _,p in state.Pets do if p.Id==id then pet.Color=C.Rarities[p.Rarity].Color; if p.Shiny then pet.Material=Enum.Material.Neon end end end
   pet.Parent=workspace; E.Pets[id]=pet
  end
 end
 for id,p in E.Pets do if not wanted[id] then p:Destroy(); E.Pets[id]=nil end end
 E.PetOrder=wanted
end
function E.Start()
 local music=Instance.new("Sound");music.Name="GardenMusic";music.Looped=true;music.SoundId=C.SoundConfig.Music;music.Parent=game:GetService("SoundService");E.Music=music
 local arrow=Instance.new("Part");arrow.Name="ObjectiveGuide";arrow.Size=Vector3.new(.1,.1,.1);arrow.Anchored=true;arrow.Transparency=1;arrow.CanCollide=false;arrow.CanTouch=false;arrow.CanQuery=false;arrow.Parent=workspace
 local guide=Instance.new("BillboardGui");guide.Name="ObjectiveArrow";guide.Size=UDim2.fromOffset(100,90);guide.AlwaysOnTop=true;guide.MaxDistance=300;guide.Parent=arrow
 local mark=Instance.new("TextLabel");mark.Size=UDim2.fromScale(1,1);mark.BackgroundTransparency=1;mark.Text="▼";mark.TextColor3=Color3.fromRGB(255,220,70);mark.TextStrokeColor3=Color3.fromRGB(50,65,40);mark.TextStrokeTransparency=0;mark.TextSize=60;mark.Parent=guide
 local ring=Instance.new("Part"); ring.Name="CollectionRange"; ring.Shape=Enum.PartType.Cylinder; ring.Anchored=true; ring.CanCollide=false; ring.CanQuery=false; ring.Transparency=.85; ring.Color=Color3.fromRGB(161,255,193); ring.Parent=workspace; E.Ring=ring
 Run.RenderStepped:Connect(function()
  local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
  if root then
   ring.Size=Vector3.new(.08,(E.Radius or 8)*2,(E.Radius or 8)*2); ring.CFrame=CFrame.new(root.Position-Vector3.new(0,2.8,0))*CFrame.Angles(0,0,math.pi/2)
   for id,pet in E.Pets do local i=E.PetOrder[id] or 1; local offset=Vector3.new(math.cos(i*2)*C.UI.PetDistance,1+math.sin(os.clock()*3+i)*C.UI.PetBob,math.sin(i*2)*C.UI.PetDistance); pet.Position=pet.Position:Lerp(root.Position+offset,.15) end
  end
  if os.clock()<E.ShakeUntil then workspace.CurrentCamera.CFrame*=CFrame.new((math.random()-.5)*E.Intensity,(math.random()-.5)*E.Intensity,0) end
 end)
 -- Growth visuals interpolate locally, while the server owns progress and timestamps.
 task.spawn(function() while true do task.wait(.1)
  local world=workspace:FindFirstChild("BuildATreeWorld")
  if E.Music then E.Music.Volume=E.Settings.Music and (E.Settings.MusicVolume or .4)or 0;if C.SoundConfig.Music~=""and not E.Music.IsPlaying then E.Music:Play()end end
  local state=E.State;local own=world and world:FindFirstChild("Garden_"..Players.LocalPlayer.UserId);local target
  if state and own then local step=state.Onboarding or 9;if step==4 then target=own:FindFirstChild(state.Growth and "Plot7"or "Plot8")elseif step==5 then target=own:FindFirstChild("Plot1")elseif step==6 then local stand=world:FindFirstChild("FruitSellStand");target=stand and stand:FindFirstChild("Counter")elseif step==7 or step==8 then local stand=world:FindFirstChild("GardenShopStand");target=stand and stand:FindFirstChild("Counter")end end
  guide.Enabled=target~=nil;if target then arrow.Position=target.Position+Vector3.new(0,7+math.sin(os.clock()*3),0)end
  if world then for _,garden in world:GetChildren() do if garden:IsA("Folder") and garden.Name:match("Garden_") then
   for _,model in garden:GetChildren() do if model:IsA("Model") and model.PrimaryPart and model:GetAttribute("GrowthState") then
    local aura=model.PrimaryPart:FindFirstChild("RarityAura");local root=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart");local enabled=not E.Settings.ReducedEffects and root and (root.Position-model.PrimaryPart.Position).Magnitude<C.RarityEffects.Distance
    if aura then aura.Enabled=enabled==true end;local glow=model:FindFirstChild("RarityGlow");if glow then glow.Enabled=enabled==true end
    local progress=model:GetAttribute("Progress") or 1; local state=model:GetAttribute("GrowthState")
    local target=state=="Growing" and math.max(.12,progress) or 1
    local current=model:GetScale(); if math.abs(current-target)>.005 then model:ScaleTo(current+(target-current)*.2) end
    local threshold=math.floor(progress*4); local previous=E.Growth[model] or 0
    if threshold>previous then E.Burst(model.PrimaryPart.Position,Color3.fromRGB(136,237,146),threshold==4 and 24 or 8); E.Growth[model]=threshold end
   end end
  end end end
  for model in E.Growth do if not model.Parent then E.Growth[model]=nil end end
 end end)
end
return E
