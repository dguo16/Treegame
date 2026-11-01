-- Category grids, selection details and rotating ViewportFrame models for parts and harvests.
local Run=game:GetService("RunService")
local Player=game:GetService("Players").LocalPlayer
local S=game:GetService("ReplicatedStorage"):WaitForChild("BuildATree")
local C=require(S.Config)
local T=require(S.Theme)
local P=require(S.Util.Profile)
local G=require(S.Util.GrowthCalculator)
local V=require(S.Util.ValueCalculator)
local Models=require(S.Util.PreviewModels)
local Catalog=require(S.Util.PartCatalog)
local JournalController=require(script.Parent.JournalController)
local Format=require(S.Util.FormatNumber)
local Inventory={}; Inventory.__index=Inventory
local blue=Color3.fromRGB(72,183,241)
local pale=Color3.fromRGB(202,237,255)
local function round(parent,color,radius)
 parent.BackgroundColor3=color; parent.BorderSizePixel=0
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,radius or 14); corner.Parent=parent
 local stroke=Instance.new("UIStroke"); stroke.Color=T.Ink; stroke.Thickness=2; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; stroke.Parent=parent
end
local function frame(parent,name,color)
 local f=Instance.new("Frame"); f.Name=name; round(f,color); f.Parent=parent; return f
end
local function text(parent,value,size,color)
 local t=Instance.new("TextLabel"); t.BackgroundTransparency=1; t.Text=value; t.Font=Enum.Font.FredokaOne; t.TextSize=size or 18; t.TextWrapped=true; t.TextColor3=color or T.Ink; t.Parent=parent; return t
end
local function button(parent,name,value,color,callback)
 local b=Instance.new("TextButton"); b.Name=name; b.Text=value; b.Font=Enum.Font.FredokaOne; b.TextSize=18; b.TextWrapped=true; b.TextColor3=T.Cream; b.TextStrokeColor3=T.Ink; b.TextStrokeTransparency=0; round(b,color); b.Parent=parent
 local min=Instance.new("UISizeConstraint"); min.MinSize=Vector2.new(44,44); min.Parent=b
 b.Activated:Connect(callback); return b
end
local function viewport(parent,name,model)
 local vp=Instance.new("ViewportFrame"); vp.Name=name; vp.BackgroundTransparency=1; vp.Ambient=Color3.fromRGB(210,210,210); vp.LightColor=Color3.new(1,1,1); vp.LightDirection=Vector3.new(-1,-1,-1); vp.Parent=parent
 local world=Instance.new("WorldModel"); world.Parent=vp; model.Parent=world
 local cf,size=model:GetBoundingBox(); local distance=math.max(size.X,size.Y,size.Z)*2.1
 local camera=Instance.new("Camera"); camera.FieldOfView=35; camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance*.7,distance*.3,distance),cf.Position); camera.Parent=vp; vp.CurrentCamera=camera
 return vp,model:GetPivot()
end
local function growthAction(p)
 if not p or not p.Growth or ((p.MaxGrowthPads or 1)>1 and not p.Growth2)then return "Plant"end
 if p.Growth.State=="Ready"or(p.Growth2 and p.Growth2.State=="Ready")then return "Visit"end
 return "Queue"
end
function Inventory.new(gui,send)
 local self=setmetatable({Send=send,Mode="Parts",Category="All Parts",Page=1,Selected=nil,State=nil,MainModel=nil},Inventory)
 self.Root=frame(gui,"InventoryWindow",blue); self.Root.Visible=false
 self.Root.ZIndex=10
 local title=text(self.Root,"TREE PARTS",30,T.Cream); title.Name="Title"; title.TextStrokeColor3=T.Ink; title.TextStrokeTransparency=0; title.Position=UDim2.fromOffset(18,6); title.Size=UDim2.new(1,-90,0,44); self.Title=title
 local close=button(self.Root,"Close","×",T.Red,function() self:Close() end); close.Size=UDim2.fromOffset(44,44); close.Position=UDim2.new(1,-54,0,6)
 self.Tabs=Instance.new("ScrollingFrame"); self.Tabs.Name="Categories"; self.Tabs.BackgroundTransparency=1; self.Tabs.BorderSizePixel=0; self.Tabs.ScrollBarThickness=3; self.Tabs.Size=UDim2.new(1,-24,0,52); self.Tabs.Position=UDim2.fromOffset(12,56); self.Tabs.CanvasSize=UDim2.fromOffset(580,0); self.Tabs.ScrollingDirection=Enum.ScrollingDirection.X; self.Tabs.Parent=self.Root
 self.Body=Instance.new("Frame"); self.Body.Name="Body"; self.Body.BackgroundTransparency=1; self.Body.Position=UDim2.fromOffset(12,114); self.Body.Size=UDim2.new(1,-24,1,-180); self.Body.Parent=self.Root
 self.Details=Instance.new("ScrollingFrame"); self.Details.Name="SelectedDetails"; round(self.Details,pale); self.Details.ScrollBarThickness=4; self.Details.AutomaticCanvasSize=Enum.AutomaticSize.Y; self.Details.CanvasSize=UDim2.new(); self.Details.Parent=self.Body
 local list=Instance.new("UIListLayout"); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Padding=UDim.new(0,9); list.Parent=self.Details
 local padding=Instance.new("UIPadding"); padding.PaddingTop=UDim.new(0,12); padding.PaddingLeft=UDim.new(0,9); padding.PaddingRight=UDim.new(0,9); padding.PaddingBottom=UDim.new(0,12); padding.Parent=self.Details
 self.Grid=Instance.new("ScrollingFrame"); self.Grid.Name="ItemGrid"; round(self.Grid,Color3.fromRGB(126,208,250)); self.Grid.ScrollBarThickness=5; self.Grid.AutomaticCanvasSize=Enum.AutomaticSize.Y; self.Grid.CanvasSize=UDim2.new(); self.Grid.Parent=self.Body
 self.Layout=Instance.new("UIGridLayout"); self.Layout.SortOrder=Enum.SortOrder.LayoutOrder; self.Layout.CellPadding=UDim2.fromOffset(8,8); self.Layout.Parent=self.Grid
 local pad=Instance.new("UIPadding"); pad.PaddingTop=UDim.new(0,7); pad.PaddingLeft=UDim.new(0,7); pad.PaddingBottom=UDim.new(0,7); pad.Parent=self.Grid
 self.Empty=text(self.Body,"",18); self.Empty.Name="EmptyGridState"; self.Empty.Visible=false; self.Empty.ZIndex=3
 self.Preview=frame(self.Body,"ModelPreview",pale)
 self.PreviewTitle=text(self.Preview,"YOUR NEXT TREE",21); self.PreviewTitle.Size=UDim2.new(1,-12,0,50); self.PreviewTitle.Position=UDim2.fromOffset(6,6)
 self.PreviewStats=text(self.Preview,"",16); self.PreviewStats.Size=UDim2.new(1,-12,0,76); self.PreviewStats.Position=UDim2.new(0,6,1,-82)
 local previous=button(self.Root,"Previous","<",T.Purple,function() if self.Page>1 then self.Page-=1; self:Refresh(true) end end); previous.Position=UDim2.new(0,12,1,-54); previous.Size=UDim2.fromOffset(44,44);self.Previous=previous
 self.Pages=text(self.Root,"1 / 1",18,T.Cream); self.Pages.Position=UDim2.new(0,60,1,-54); self.Pages.Size=UDim2.fromOffset(66,44)
 local nextPage=button(self.Root,"Next",">",T.Purple,function() self.Page=math.min(self.TotalPages or 1,self.Page+1); self:Refresh(true) end); nextPage.Position=UDim2.new(0,132,1,-54); nextPage.Size=UDim2.fromOffset(44,44);self.Next=nextPage
 self.Primary=button(self.Root,"Primary","PLANT TREE",T.Green,function() if self.Mode=="Parts" then local action=growthAction(self.State);if action=="Visit"then self:Close();send("Teleport",{Destination="Garden"})else send(action=="Queue"and "QueueTree"or "Plant",{})end else self:Close();send("Teleport",{Destination="Sell"})end end)
 self.Primary.Position=UDim2.new(.55,0,1,-54); self.Primary.Size=UDim2.new(.43,-12,0,44)
 for _,b in {self.Primary} do b.TextScaled=true; local limit=Instance.new("UITextSizeConstraint"); limit.MinTextSize=12; limit.MaxTextSize=18; limit.Parent=b end
 self.Journal=JournalController.new(self.Body,send,function()self.Category="All Parts";self:Refresh(true)end)
 local function resize() self:Resize() end
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize); self.Grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:Cells() end); self:Resize()
 Run.RenderStepped:Connect(function()
  if self.Root.Visible then self:HideTouchControls() end
  if self.Root.Visible and self.MainModel and self.MainModel.Parent then self.MainModel:PivotTo(self.MainPivot*CFrame.Angles(0,(os.clock()-self.RotationStart)*C.Inventory.RotateSpeed,0)) end
 end)
 return self
end
function Inventory:Resize()
 local size=workspace.CurrentCamera.ViewportSize; local narrow=size.X<650; local small=size.Y<500
 self.Root.Size=(narrow or small) and UDim2.fromScale(.96,.98) or UDim2.fromScale(.9,.82)
 self.Root.Position=(narrow or small) and UDim2.fromScale(.02,.01) or UDim2.fromScale(.05,.1)
 self.Details.Position=UDim2.fromScale(0,0); self.Details.Size=narrow and UDim2.fromScale(.44,.48) or UDim2.fromScale(.24,1)
 self.Preview.Position=narrow and UDim2.fromScale(.46,0) or UDim2.fromScale(.70,0); self.Preview.Size=narrow and UDim2.fromScale(.54,.48) or UDim2.fromScale(.30,1)
 self.Grid.Position=narrow and UDim2.fromScale(0,.50) or UDim2.fromScale(.255,0); self.Grid.Size=narrow and UDim2.fromScale(1,.50) or UDim2.fromScale(.43,1)
 self.Empty.Position=self.Grid.Position; self.Empty.Size=self.Grid.Size
 self:LayoutPreview()
 self.Primary.Position=UDim2.new(narrow and .52 or .55,0,1,-54);self.Primary.Size=UDim2.new(narrow and .46 or .43,-12,0,44)
 self:Cells()
end
function Inventory:LayoutPreview()
 local size=workspace.CurrentCamera.ViewportSize;local compact=size.X<650 or size.Y<500;local landscape=size.Y<500 and size.X>=650
 local vp=self.Preview:FindFirstChild("RotatingModel")
 self.PreviewTitle.TextSize=compact and 15 or 21;self.PreviewTitle.Size=UDim2.new(1,-12,0,landscape and 24 or compact and 30 or 50)
 self.PreviewStats.TextSize=landscape and 12 or compact and 13 or 16
 if landscape then
  self.PreviewStats.Position=UDim2.new(.5,0,0,30);self.PreviewStats.Size=UDim2.new(.5,-6,1,-36)
  if vp then vp.Position=UDim2.fromOffset(0,28);vp.Size=UDim2.new(.5,0,1,-34) end
 else
  local footer=compact and 66 or 106
  self.PreviewStats.Size=UDim2.new(1,-12,0,footer);self.PreviewStats.Position=UDim2.new(0,6,1,-footer-6)
  if vp then vp.Position=UDim2.fromOffset(0,compact and 36 or 56);vp.Size=UDim2.new(1,0,1,compact and -112 or -182) end
 end
end
function Inventory:Cells()
 local width=self.Grid.AbsoluteSize.X-20; local columns=math.clamp(math.floor(width/90),2,5)
 self.Layout.CellSize=UDim2.fromOffset(math.max(58,math.floor((width-(columns-1)*8)/columns)),96)
end
function Inventory:HideTouchControls()
 local touch=Player.PlayerGui:FindFirstChild("TouchGui")
 if touch then
  if self.TouchWasEnabled==nil then self.TouchWasEnabled=touch.Enabled end
  self.TouchGui=touch; touch.Enabled=false
 end
end
function Inventory:Close()
 self.Root.Visible=false; self.MainModel=nil; self.Hash=nil
 if self.TouchGui and self.TouchGui.Parent and self.TouchWasEnabled~=nil then self.TouchGui.Enabled=self.TouchWasEnabled end
 self.TouchGui=nil; self.TouchWasEnabled=nil
end
function Inventory:Open(mode)
 self.Mode=mode; self.Category=mode=="Parts" and "All Parts" or "All Fruit"; self.Selected=nil; self.Page=1; self.Hash=nil; self.MainKey=nil; self.Root.Visible=true
 self:HideTouchControls()
 self.Root:SetAttribute("Mode",mode); self:Resize(); self:Refresh(true)
end
function Inventory:Update(state)
 self.State=state; if self.Root.Visible then self:Refresh(false) end
end
function Inventory:Items()
 local out={}; if self.Mode=="Parts" then
  for _,slot in C.Slots do table.insert(out,P.Starter()[slot]) end
  for i=#self.State.Parts,1,-1 do table.insert(out,self.State.Parts[i]) end
 else for i=#(self.State.Bag.Items or {}),1,-1 do table.insert(out,self.State.Bag.Items[i]) end end
 local filtered={}; for _,item in out do if self.Category=="All Parts" or self.Category=="All Fruit" or (self.Mode=="Parts" and item.Slot==self.Category) or (self.Mode=="Bag" and item.Mutation==self.Category) then table.insert(filtered,item) end end
 return filtered,out
end
function Inventory:Detail(value,color)
 local label=text(self.Details,value,17,color); label.LayoutOrder=#self.Details:GetChildren(); label.Size=UDim2.new(1,-3,0,54); return label
end
function Inventory:Selection(item)
 for _,child in self.Details:GetChildren() do if not child:IsA("UIComponent") then child:Destroy() end end
 if self.Mode=="Parts"then
  self:Detail("Growth pads: "..(self.State.MaxGrowthPads or 1).." / 2 • Queue: "..#(self.State.GrowthQueue or {}).." / "..C.Growth.QueueLimit..((self.State.MaxGrowthPads or 1)==1 and "\nAscend to unlock pad 2"or ""))
  for index,queued in self.State.GrowthQueue or {}do
   local queuedId=queued.Id;local cancel=button(self.Details,"CancelQueued_"..index,"CANCEL QUEUED "..index,T.Blue,function()self.Send("CancelQueuedTree",{QueueId=queuedId})end);cancel.LayoutOrder=#self.Details:GetChildren();cancel.Size=UDim2.new(1,-3,0,44)
  end
 end
 if not item then self:Detail(self.Mode=="Parts" and "Select a tree part" or "Your fruit details appear here"); return end
 self:Detail(item.Name)
 self:Detail(C.Rarities[item.Tier or 1].Name..(item.Slot and " • "..item.Slot or " fruit"))
 if self.Mode=="Parts" then
  local current=self.State.Equipped[item.Slot]
  self:Detail(string.format("Stat: %.2f\nEquipped: %.2f",item.Stat,current.Stat))
  local mutation=Catalog.Mutation(item);self:Detail(mutation.Name.." • "..mutation.Mult.."× mutation",mutation.Name~="None" and mutation.Color:Lerp(T.Ink,.65) or T.Ink)
  local equip=button(self.Details,"Equip","EQUIP",T.Green,function() self.Send("Equip",{Id=item.Id}) end); equip.LayoutOrder=#self.Details:GetChildren(); equip.Size=UDim2.new(1,-3,0,44)
  if not item.Id:match("^starter_") then local sell=button(self.Details,"SellPart","SELL PART",T.Red,function() self.Send("SellPart",{Id=item.Id}) end); sell.LayoutOrder=#self.Details:GetChildren(); sell.Size=UDim2.new(1,-3,0,44) end
 else
  self:Detail("Worth "..Format(item.Value).." coins each\n"..Format(item.Value*item.Count).." coins total")
  self:Detail("Mutation: "..(item.Mutation or "None").."\nQuantity: "..item.Count)
  self:Detail(item.ObtainedAt and ("Obtained\n"..os.date("!%b %d, %H:%M:%S UTC",item.ObtainedAt)) or "Obtained before this update\nExact time unavailable")
  if item.LastObtainedAt and item.LastObtainedAt~=item.ObtainedAt then self:Detail("Last in stack\n"..os.date("!%H:%M:%S UTC",item.LastObtainedAt)) end
 end
end
function Inventory:Refresh(force)
 if not self.State then return end
 local p=self.State; local key=self.Mode..":"..self.Category..":"..self.Page..":"..tostring(self.Selected)
 if self.Mode=="Parts"then key..=":"..tostring(p.Journal and p.Journal.Version or 0);key..=":"..(p.Growth2 and p.Growth2.Id..p.Growth2.State or "None")..":"..(p.MaxGrowthPads or 1);for _,q in p.GrowthQueue or {}do key..=":"..q.Id end;key..=":"..p.Rolls..":"..#p.Parts..":"..(p.Growth and p.Growth.Id..p.Growth.State or "None"); for _,slot in C.Slots do local item=p.Equipped[slot]; key..=":"..item.Id..":"..item.Stat end
 else key..=":"..p.Bag.Count..":"..p.Bag.Value..":"..p.NextId end
 if self.Journal and self.Journal.Root.Visible then self.Journal:Update(p)end
 if not force and key==self.Hash then return end; self.Hash=key
 self.Title.Text=self.Mode=="Parts" and "TREE PARTS" or "FRUIT BAG"; self.Primary.Text=self.Mode=="Parts" and (growthAction(p)=="Plant"and "PLANT TREE"or growthAction(p)=="Visit"and "PLACE TREE"or "QUEUE BUILD")or "GO TO SELL"; self.Primary.BackgroundColor3=self.Mode=="Parts" and T.Green or T.Red
 for _,child in self.Tabs:GetChildren() do child:Destroy() end
 local categories=self.Mode=="Parts" and {"All Parts","Trunk","Leaves","Roots","Fruit","Journal"} or {"All Fruit","None","Golden","Rainbow","Void","Cosmic"}
 local x=3; for _,category in categories do
  local tab=button(self.Tabs,category,category:upper(),category==self.Category and T.Gold or T.Purple,function() self.Category=category; self.Selected=nil; self.Page=1; self.Grid.CanvasPosition=Vector2.zero; self:Refresh(true) end)
  tab.Position=UDim2.fromOffset(x,3); tab.Size=UDim2.fromOffset(category:find("All") and 108 or 91,44); x+=tab.Size.X.Offset+8
 end; self.Tabs.CanvasSize=UDim2.fromOffset(x+4,0)
 local journal=self.Mode=="Parts"and self.Category=="Journal"
 self.Tabs.Visible=not journal;self.Previous.Visible=not journal;self.Next.Visible=not journal;self.Pages.Visible=not journal
 self.Journal.Root.Position=UDim2.fromOffset(0,-58);self.Journal.Root.Size=UDim2.new(1,0,1,104)
 self.Journal.Root.Visible=journal;self.Details.Visible=not journal;self.Grid.Visible=not journal;self.Preview.Visible=not journal;self.Primary.Visible=not journal
 self.Journal:Update(p)
 if journal then self.Empty.Visible=false;self.TotalPages=1;self.Pages.Text="Journal";return end
 local items,all=self:Items(); local selected
 for _,item in all do if item.Id==self.Selected then selected=item end end
 if not selected and self.Mode=="Bag" then selected=items[1]; self.Selected=selected and selected.Id end
 self:Selection(selected)
 for _,child in self.Grid:GetChildren() do if not child:IsA("UIComponent") then child:Destroy() end end
 self.TotalPages=math.max(1,math.ceil(#items/C.Inventory.PageSize)); self.Page=math.min(self.Page,self.TotalPages); self.Pages.Text=self.Page.." / "..self.TotalPages
 for index=(self.Page-1)*C.Inventory.PageSize+1,math.min(self.Page*C.Inventory.PageSize,#items) do
  local item=items[index]; local equipped=self.Mode=="Parts" and p.Equipped[item.Slot].Id==item.Id
  local tint=C.Rarities[item.Tier or 1].Color:Lerp(T.Cream,.65)
  if self.Mode=="Bag" or self.Mode=="Parts" then for _,mutation in C.Mutations do if mutation.Name==item.Mutation and mutation.Name~="None" then tint=mutation.Color:Lerp(T.Cream,.65) end end end
  local cell=button(self.Grid,"Item_"..item.Id,"",equipped and T.Green or tint,function() self.Selected=item.Id; self:Refresh(true) end); cell.LayoutOrder=index; cell:SetAttribute("ItemId",item.Id)
  if selected and selected.Id==item.Id then cell.UIStroke.Color=T.Purple; cell.UIStroke.Thickness=4 end
  local vp=viewport(cell,"Thumbnail",self.Mode=="Parts" and Models.Part(item) or Models.Fruit(item)); vp.Position=UDim2.fromOffset(2,1); vp.Size=UDim2.new(1,-4,0,59)
  local name=text(cell,item.Name,12); name.Size=UDim2.new(1,-4,0,18); name.Position=UDim2.fromOffset(2,59); name.TextWrapped=false; name.TextTruncate=Enum.TextTruncate.AtEnd
  local stat=text(cell,self.Mode=="Parts" and (equipped and "EQUIPPED" or (Catalog.Mutation(item).Name~="None" and Catalog.Mutation(item).Name or C.Rarities[item.Tier].Name)) or ("×"..item.Count.." • "..Format(item.Value)),12); stat.Size=UDim2.new(1,-4,0,17); stat.Position=UDim2.fromOffset(2,77)
 end
 self.Empty.Visible=#items==0; self.Empty.Text=self.Mode=="Bag" and "Your bag is empty!\nCollect fruit from your trees." or "No parts in this category yet."
 local modelKey=self.Mode=="Parts" and "Tree" or (selected and selected.Id or "Empty")
 if self.Mode=="Parts" then for _,slot in C.Slots do modelKey..=p.Equipped[slot].Id..p.Equipped[slot].Stat end end
 if modelKey~=self.MainKey then
  self.MainKey=modelKey; self.MainModel=nil
  local old=self.Preview:FindFirstChild("RotatingModel"); if old then old:Destroy() end
  local model=self.Mode=="Parts" and Models.Tree(p.Equipped) or (selected and Models.Fruit(selected))
  if model then
   local vp,pivot=viewport(self.Preview,"RotatingModel",model);self:LayoutPreview()
   self.MainModel=model; self.MainPivot=pivot; self.RotationStart=os.clock()
  end
 end
 if self.Mode=="Parts" then
  local tier=G.Tier(p.Equipped); self.PreviewTitle.Text="YOUR NEXT TREE"; self.PreviewStats.Text=C.Rarities[tier].Name.." • "..G.GrowTime(tier,1).."s grow\n"..Format(V.Build(p.Equipped,1,1,1,1,nil,C.Upgrades.LeafPower.Values[p.Upgrades.LeafPower or 1])).." coins / fruit\n"..string.format("%.1f–%.1f studs • %.2f× parts",G.Height(p.Equipped,C.Growth.HeightMin),G.Height(p.Equipped,C.Growth.HeightMax),Catalog.Bonus(p.Equipped))
 else self.PreviewTitle.Text=selected and selected.Name or "YOUR HARVEST"; self.PreviewStats.Text=selected and ((selected.Mutation or "None").." • "..C.Rarities[selected.Tier or 1].Name) or "Walk near fruit to fill your bag." end
 self:Cells()
end
return Inventory
