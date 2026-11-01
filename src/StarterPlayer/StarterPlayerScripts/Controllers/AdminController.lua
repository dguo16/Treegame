-- Self-only admin interface. Visibility is convenient; authorization always runs on the server.
local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
local S=game:GetService("ReplicatedStorage").BuildATree
local C=require(S.Config)
local T=require(S.Theme)
local Models=require(S.Util.PreviewModels)
local Catalog=require(S.Util.PartCatalog)
local Format=require(S.Util.FormatNumber)
local Admin={};Admin.__index=Admin
local function luckText(value)return value<1 and tostring(value)or Format(value)end
local function style(object,color)
 object.BackgroundColor3=color;object.BorderSizePixel=0
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,14);corner.Parent=object
 local stroke=Instance.new("UIStroke");stroke.Color=T.Ink;stroke.Thickness=2;stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;stroke.Parent=object
end
local function label(parent,value,height,size)
 local t=Instance.new("TextLabel");t.Text=value;t.Font=Enum.Font.FredokaOne;t.TextSize=size or 18;t.TextColor3=T.Ink;t.BackgroundTransparency=1;t.TextWrapped=true;t.Size=UDim2.new(1,-8,0,height or 44);t.LayoutOrder=#parent:GetChildren();t.Parent=parent;return t
end
local function button(parent,name,value,color,callback)
 local b=Instance.new("TextButton");b.Name=name;b.Text=value;b.Font=Enum.Font.FredokaOne;b.TextSize=18;b.TextScaled=true;b.TextColor3=T.Cream;b.TextStrokeColor3=T.Ink;b.TextStrokeTransparency=0;b.LayoutOrder=#parent:GetChildren();style(b,color);b.Parent=parent
 local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=11;limit.MaxTextSize=20;limit.Parent=b
 local size=Instance.new("UISizeConstraint");size.MinSize=Vector2.new(44,44);size.Parent=b
 b.Activated:Connect(callback);return b
end
local function input(parent,name,placeholder)
 local box=Instance.new("TextBox");box.Name=name;box.Size=UDim2.new(1,-8,0,50);box.LayoutOrder=#parent:GetChildren();box.Text="";box.PlaceholderText=placeholder;box.PlaceholderColor3=Color3.fromRGB(126,112,91);box.TextColor3=T.Ink;box.Font=Enum.Font.FredokaOne;box.TextSize=21;box.ClearTextOnFocus=false;style(box,T.Paper);box.Parent=parent
 box:GetPropertyChangedSignal("Text"):Connect(function()if #box.Text>40 then box.Text=box.Text:sub(1,40)end end);return box
end
local function row(parent,height,columns)
 local f=Instance.new("Frame");f.LayoutOrder=#parent:GetChildren();f.Size=UDim2.new(1,-8,0,height);f.BackgroundTransparency=1;f.Parent=parent
 local grid=Instance.new("UIGridLayout");grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.CellSize=UDim2.new(1/columns,-8,0,44);grid.CellPadding=UDim2.fromOffset(8,8);grid.Parent=f;return f
end
function Admin.new(gui,send,onOpen,onInventory)
 local self=setmetatable({Gui=gui,Send=send,OnOpen=onOpen,OnInventory=onInventory,Page="Coins",Slot="Trunk",Tier=1},Admin)
 Input.InputBegan:Connect(function(key,processed)
  if not processed and not Input:GetFocusedTextBox() and key.KeyCode==Enum.KeyCode.F4 and self.State and self.State.IsAdmin then
   if self.Root and self.Root.Visible then self:Close()else onOpen()end
  end
 end)
 return self
end
function Admin:Create()
 if self.Root then return end
 local root=Instance.new("Frame");root.Name="AdminWindow";root.AnchorPoint=Vector2.new(.5,.5);root.Position=UDim2.fromScale(.5,.5);root.Size=UDim2.fromScale(.78,.82);root.Visible=false;root.ZIndex=15;style(root,T.Cream);root.Parent=self.Gui;self.Root=root
 local max=Instance.new("UISizeConstraint");max.MaxSize=Vector2.new(900,680);max.Parent=root
 local title=label(root,"ADMIN PANEL",48,25);title.Size=UDim2.new(1,-76,0,48);title.Position=UDim2.fromOffset(10,6);title.TextColor3=T.Purple
 local close=button(root,"Close","×",T.Red,function()self:Close()end);close.Position=UDim2.new(1,-54,0,8);close.Size=UDim2.fromOffset(44,44)
 local tabs=row(root,44,3);tabs.Name="Tabs";tabs.Position=UDim2.fromOffset(12,60);tabs.Size=UDim2.new(1,-16,0,44)
 for _,page in {"Coins","Parts","Luck"} do button(tabs,page,page:upper(),T.Purple,function()self.Page=page;self:Build()end)end
 local content=Instance.new("ScrollingFrame");content.Name="Content";content.BackgroundTransparency=1;content.BorderSizePixel=0;content.Position=UDim2.fromOffset(12,116);content.Size=UDim2.new(1,-24,1,-180);content.AutomaticCanvasSize=Enum.AutomaticSize.Y;content.CanvasSize=UDim2.new();content.ScrollBarThickness=6;content.Parent=root;self.Content=content
 local list=Instance.new("UIListLayout");list.SortOrder=Enum.SortOrder.LayoutOrder;list.Padding=UDim.new(0,10);list.Parent=content
 local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,4);pad.PaddingBottom=UDim.new(0,8);pad.PaddingLeft=UDim.new(0,4);pad.Parent=content
 self.Status=label(root,"Only your account can use these controls.",48,17);self.Status.Name="Status";self.Status.Position=UDim2.new(0,12,1,-54);self.Status.Size=UDim2.new(1,-24,0,48)
 local function resize()
  local vp=workspace.CurrentCamera.ViewportSize;local small=vp.X<700 or vp.Y<500
  root.Size=small and UDim2.fromScale(.96,.98)or UDim2.fromScale(.78,.82)
  if root.Visible then local touch=Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui");if touch then if self.TouchEnabled==nil then self.TouchEnabled=touch.Enabled end;self.TouchGui=touch;touch.Enabled=false end end
 end
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize);resize()
end
function Admin:Close()
 if self.Root then self.Root.Visible=false end
 if self.TouchGui and self.TouchGui.Parent and self.TouchEnabled~=nil then self.TouchGui.Enabled=self.TouchEnabled end
 self.TouchGui=nil;self.TouchEnabled=nil
end
function Admin:Open()
 if not self.State or not self.State.IsAdmin then return end
 self:Create();self.Root.Visible=true
 local touch=Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
 if touch then if self.TouchEnabled==nil then self.TouchEnabled=touch.Enabled end;self.TouchGui=touch;touch.Enabled=false end
 self:Build()
end
function Admin:Update(state)
 self.State=state
 if not state.IsAdmin then self:Close();if self.Root then self.Root:Destroy();self.Root=nil end;return end
 if self.Balance and self.Balance.Parent then self.Balance.Text="Your coins: "..Format(state.Coins) end
 if self.Luck and self.Luck.Parent then self.Luck.Text="Effective roll luck: "..luckText(state.Luck).."×\n"..(state.Admin and state.Admin.LuckOverride and "Admin override is active" or "Using normal pet / boost / pass luck") end
end
function Admin:Result(result)
 if not self.Status then return end
 self.Status.Text=result.Message;self.Status.TextColor3=result.Success and Color3.fromRGB(38,124,60)or T.Red
end
function Admin:Build()
 local p=self.State;if not p or not p.IsAdmin or not self.Content then return end
 for _,child in self.Content:GetChildren()do if not child:IsA("UIComponent")then child:Destroy()end end
 self.Balance=nil;self.Luck=nil;self.Content.CanvasPosition=Vector2.zero
 local body=self.Content
 if self.Page=="Coins" then
  self.Balance=label(body,"Your coins: "..Format(p.Coins),46,24)
  label(body,"Set your balance, add coins, or remove coins. Amounts accept K, M, B, T or scientific notation.",64,17)
  local amount=input(body,"CoinAmount","Example: 1M, 1B, 1e20")
  local quick=row(body,44,4);quick.Name="CoinPresets"
  for _,value in {"1K","1M","1B","1T"}do button(quick,value,value,T.Gold,function()amount.Text=value end)end
  local actions=row(body,62,3);actions.Name="CoinActions"
  for _,mode in {"Set","Add","Remove"}do local b=button(actions,mode,mode:upper(),mode=="Remove"and T.Red or mode=="Set"and T.Blue or T.Green,function()self.Send("AdminCoins",{Mode=mode,Amount=amount.Text})end);b:SetAttribute("AdminOperation",mode)end
  label(body,"Changes affect your balance only and save with your profile.",48,16)
 elseif self.Page=="Luck" then
  self.Luck=label(body,"Effective roll luck: "..luckText(p.Luck).."×",62,23)
  label(body,"Override your own part-roll luck. This does not change other players, part/fruit mutations or egg odds.",64,17)
  local amount=input(body,"LuckMultiplier","Custom multiplier: 0.01 to 1M")
  local quick=row(body,44,4);quick.Name="LuckPresets"
  for _,value in {1,10,100,1000}do button(quick,"Luck"..value,value.."×",T.Gold,function()amount.Text=tostring(value);self.Send("AdminLuck",{Multiplier=amount.Text})end)end
  local actions=row(body,44,2);actions.Name="LuckActions"
  button(actions,"ApplyLuck","APPLY LUCK",T.Purple,function()self.Send("AdminLuck",{Multiplier=amount.Text})end)
  button(actions,"ResetLuck","RESET NORMAL",T.Blue,function()self.Send("AdminResetLuck",{})end)
  label(body,"The override stays until you reset it. Actual rarity chances are shown under More → Odds.",64,16)
 elseif self.Page=="Parts" then
  label(body,"CHOOSE PART TYPE",30,20)
  local slots=row(body,44,4);slots.Name="PartTypes"
  for _,slot in C.Slots do button(slots,slot,slot:upper(),slot==self.Slot and T.Gold or T.Blue,function()self.Slot=slot;self:Build()end)end
  label(body,"CHOOSE RARITY",30,20)
  local tiers=row(body,100,4);tiers.Name="Rarities"
  for tier,rarity in C.Rarities do button(tiers,rarity.Name,rarity.Name,rarity.Color,function()self.Tier=tier;self:Build()end)end
  local variants=Catalog.Variants(self.Slot,self.Tier);self.Variant=math.clamp(self.Variant or 1,1,#variants)
  local choices=row(body,52,3);choices.Name="Variants"
  for index,name in variants do button(choices,"Variant"..index,name,index==self.Variant and T.Gold or T.Blue,function()self.Variant=index;self:Build()end) end
  label(body,C.Rarities[self.Tier].Name.." "..variants[self.Variant].."\nGrants the maximum stat for this part's rarity.",56,21)
  local vp=Instance.new("ViewportFrame");vp.Name="PartPreview";vp.Size=UDim2.new(1,-8,0,130);vp.LayoutOrder=#body:GetChildren();vp.BackgroundTransparency=0;style(vp,T.Paper);vp.Ambient=Color3.fromRGB(210,210,210);vp.LightColor=Color3.new(1,1,1);vp.Parent=body
  local world=Instance.new("WorldModel");world.Parent=vp;local model=Models.Part({Name=variants[self.Variant],Slot=self.Slot,Tier=self.Tier});model.Parent=world
  local cf,size=model:GetBoundingBox();local distance=math.max(size.X,size.Y,size.Z)*1.9;local camera=Instance.new("Camera");camera.FieldOfView=35;camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance*.7,distance*.3,distance),cf.Position);camera.Parent=vp;vp.CurrentCamera=camera
  local actions=row(body,44,2);actions.Name="PartActions"
  button(actions,"GivePart","GIVE PART",T.Green,function()self.Send("AdminCatalogPart",{Slot=self.Slot,Tier=self.Tier,Choice=self.Variant..":Give"})end)
  button(actions,"GiveEquip","GIVE & EQUIP",T.Blue,function()self.Send("AdminCatalogPart",{Slot=self.Slot,Tier=self.Tier,Choice=self.Variant..":Equip"})end)
  local all=button(body,"GiveAll","GRANT ALL "..Catalog.Count().." PARTS",T.Purple,function()self.Send("AdminAllParts",{})end);all.LayoutOrder=#body:GetChildren();all.Size=UDim2.new(1,-8,0,48)
  local inspect=button(body,"Inventory","OPEN MY TREE PARTS",T.Gold,function()self:Close();self.OnInventory()end);inspect.LayoutOrder=#body:GetChildren();inspect.Size=UDim2.new(1,-8,0,44)
 end
 self:Update(p)
end
return Admin
