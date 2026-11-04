-- Intent-only sales: snapshot estimates on the client, all value/ownership on server.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local T=require(S.Theme)
local Format=require(S.Util.FormatNumber)
local Bag=require(S.Util.BagInventory)
local Controller={};Controller.__index=Controller
local function style(x,color)
 x.BackgroundColor3=color;x.BorderSizePixel=0
 local r=Instance.new("UICorner");r.CornerRadius=UDim.new(0,14);r.Parent=x
 local stroke=Instance.new("UIStroke");stroke.Color=T.Ink;stroke.Thickness=2;stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;stroke.Parent=x
end
local function text(parent,name,value,size)
 local x=Instance.new("TextLabel");x.Name=name;x.Text=value;x.Font=Enum.Font.FredokaOne;x.TextSize=size or 18;x.TextWrapped=true;x.TextColor3=T.Ink;x.BackgroundTransparency=1;x.Parent=parent;return x
end
local function button(parent,name,value,color,fn)
 local x=Instance.new("TextButton");x.Name=name;x.Text=value;x.Font=Enum.Font.FredokaOne;x.TextSize=16;x.TextColor3=T.Ink;x.TextWrapped=true;style(x,color);x.Parent=parent;x.Activated:Connect(fn);return x
end
function Controller.new(gui,send,toast)
 local self=setmetatable({Send=send,Toast=toast,Selected={},SelectMode=false},Controller)
 local root=Instance.new("Frame");root.Name="SellPanel";style(root,T.Cream);root.ZIndex=20;root.Visible=false;root.Parent=gui;self.Root=root
 local title=text(root,"Title","SELL YOUR HARVEST",26);title.Position=UDim2.fromOffset(14,7);title.Size=UDim2.new(1,-80,0,44)
 local close=button(root,"Close","X",T.Red,function()self:Close()end);close.Position=UDim2.new(1,-54,0,7);close.Size=UDim2.fromOffset(44,44)
 self.Mode=button(root,"SelectMode","SELECT STACKS",T.Blue,function()self.SelectMode=not self.SelectMode;self:Render()end);self.Mode.Position=UDim2.fromOffset(12,58);self.Mode.Size=UDim2.fromOffset(150,44)
 local filters=Instance.new("ScrollingFrame");filters.Name="QuickFilters";filters.BackgroundTransparency=1;filters.BorderSizePixel=0;filters.Position=UDim2.fromOffset(174,56);filters.Size=UDim2.new(1,-186,0,49);filters.CanvasSize=UDim2.fromOffset(830,0);filters.ScrollingDirection=Enum.ScrollingDirection.X;filters.ScrollBarThickness=3;filters.Parent=root
 local function filter(name,label,x,width,kind)
  local b=button(filters,name,label,T.Gold,function()self:Choose(kind)end);b.Position=UDim2.fromOffset(x,2);b.Size=UDim2.fromOffset(width,44)
 end
 filter("KeepMutated","EXCEPT MUTATED",2,180,"Plain")
 filter("Unlocked","EXCEPT LOCKED",192,180,"All")
 self.Below=Instance.new("TextBox");self.Below.Name="BelowValue";self.Below.Text="100";self.Below.PlaceholderText="Unit value";self.Below.ClearTextOnFocus=false;self.Below.Font=Enum.Font.FredokaOne;self.Below.TextSize=17;style(self.Below,T.Paper);self.Below.Size=UDim2.fromOffset(110,44);self.Below.Position=UDim2.fromOffset(382,2);self.Below.Parent=filters
 filter("Below","BELOW VALUE",502,170,"Below")
 local vault=button(filters,"VaultHelp","VAULT STAYS SAFE",T.Purple,function()self.Toast("Locked fruit stays in your separate Vault. Unlock it in Fruit Bag > Vault.")end);vault.Size=UDim2.fromOffset(150,44);vault.Position=UDim2.fromOffset(682,2)
 local info=text(root,"SnapshotHint","New fruit can arrive while you choose. Available quantities and the final payout are confirmed when you sell.",14);info.Position=UDim2.fromOffset(12,110);info.Size=UDim2.new(1,-24,0,34)
 local scroll=Instance.new("ScrollingFrame");scroll.Name="FruitStacks";scroll.Position=UDim2.fromOffset(12,150);scroll.Size=UDim2.new(1,-24,1,-248);scroll.BackgroundTransparency=1;scroll.BorderSizePixel=0;scroll.ScrollBarThickness=6;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=root;self.Content=scroll
 local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,9);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=scroll
 local padding=Instance.new("UIPadding");padding.PaddingLeft=UDim.new(0,4);padding.PaddingRight=UDim.new(0,10);padding.PaddingTop=UDim.new(0,4);padding.PaddingBottom=UDim.new(0,6);padding.Parent=scroll
 self.Total=text(root,"LiveTotal","",18);self.Total.TextScaled=true;local totalLimit=Instance.new("UITextSizeConstraint");totalLimit.MinTextSize=12;totalLimit.MaxTextSize=18;totalLimit.Parent=self.Total;self.Total.Size=UDim2.new(1,-24,0,34);self.Total.Position=UDim2.new(0,12,1,-90)
 self.Sell=button(root,"SellAll","SELL ALL UNLOCKED",T.Green,function()self:Begin(self.SelectMode and "Selected"or "All")end);self.Sell.Position=UDim2.new(.08,0,1,-54);self.Sell.Size=UDim2.new(.84,0,0,46);self.Sell.TextSize=22
 local function resize()
  local vp=workspace.CurrentCamera.ViewportSize;local small=vp.Y<500
  root.Size=UDim2.new(.94,0,1,-18);root.Position=UDim2.fromScale(.03,.01)
  if small then
   self.Mode.Position=UDim2.fromOffset(12,53);filters.Position=UDim2.fromOffset(174,51)
   info.Visible=false;scroll.Position=UDim2.fromOffset(12,105);scroll.Size=UDim2.new(1,-24,1,-194)
  else info.Visible=true;scroll.Position=UDim2.fromOffset(12,150);scroll.Size=UDim2.new(1,-24,1,-248)end
 end
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize);Run.RenderStepped:Connect(function()if self.Root.Visible then self:HideTouchControls()end end);resize();return self
end
function Controller:HideTouchControls()
 local touch=Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
 if touch then if self.Touch~=touch then self.Touch=touch;self.TouchEnabled=touch.Enabled end;touch.Enabled=false end
end
function Controller:Close()
 self.Root.Visible=false;self.Pending=nil;self.Busy=false;self.CurrentKey=nil
 if self.Touch and self.Touch.Parent then self.Touch.Enabled=self.TouchEnabled end;self.Touch=nil
end
function Controller:Open()
 self.Selected={};self.SelectMode=false;self.Root.Visible=true
 self:HideTouchControls()
 self:Render()
end
function Controller:Update(p)self.State=p;if self.Root.Visible then self:Render()end end
function Controller:Rows(kind)
 local rows={};local below=tonumber(self.Below.Text)
 if kind=="Below"and(not below or below~=below or below<0 or below>1e30)then self.Toast("Enter a valid unit value.");return nil end
 for _,item in self.State.Bag.Items or {}do if not item.Locked then
  local quantity=kind=="Selected"and(self.Selected[item.Id]or 0)or item.Count
  if quantity>0 and(kind~="Plain"or item.Mutation=="None")and(kind~="Below"or item.Value<below)then table.insert(rows,{Id=item.Id,Quantity=math.min(quantity,item.Count)})end
 end end
 return rows
end
function Controller:Choose(kind)
 local rows=self:Rows(kind);if not rows then return end
 self.Selected={};for _,row in rows do self.Selected[row.Id]=row.Quantity end;self.SelectMode=true;self:Render()
end
function Controller:Begin(kind)
 if self.Busy then self.Toast("Finishing your sale...");return end
 local rows=self:Rows(kind);if not rows then return end
 if #rows==0 then self.Toast("No unlocked fruit matches this choice.");return end
 self.Pending=rows;self.Busy=true;self:NextBatch(self.State.Bag.Revision)
end
function Controller:NextBatch(revision)
 if not self.Pending or not self.Root.Visible then self.Busy=false;return end
 local rows={};for _=1,math.min(C.FruitInventory.MaxSaleStacks,#self.Pending)do table.insert(rows,table.remove(self.Pending,1))end
 if #rows==0 then self.Pending=nil;self.Busy=false;self.Selected={};self:Render();return end
 self.CurrentKey=Bag.SaleKey(revision,rows);local key=self.CurrentKey
 self.Send("Sell",{Revision=revision,Stacks=rows})
 task.delay(10,function()if self.Busy and self.CurrentKey==key then self.Busy=false;self.Pending=nil;self.CurrentKey=nil;self.Toast("Sale not confirmed yet. Check your refreshed bag before trying again.");self:Render()end end)
end
function Controller:Result(result)
 if not self.Busy or result.RequestKey~=self.CurrentKey then return end
 self.CurrentKey=nil
 if result.Stale then self.Toast((result.Message or "Bag changed.").." Missing: "..(result.Missing or 0).."; quantities adjusted: "..(result.Adjusted or 0))end
 if not self.Busy then return end
 if not result.Revision then self.Pending=nil;self.Busy=false;return end
 task.delay(C.FruitInventory.SaleCooldown+.1,function()self:NextBatch(result.Revision)end)
end
function Controller:Render()
 local p=self.State;if not p then return end
 local saved=self.Content.CanvasPosition
 for _,x in self.Content:GetChildren()do if not x:IsA("UIComponent")then x:Destroy()end end
 self.Mode.Text=self.SelectMode and "SELECT MODE: ON"or "SELECT STACKS"
 self.Sell.Text=self.Busy and "SELLING..."or(self.SelectMode and "SELL SELECTED"or "SELL ALL UNLOCKED")
 local value,count=0,0
 for i,item in p.Bag.Items or {}do
  local id=item.Id;local chosen=self.SelectMode and(self.Selected[id]or 0)or item.Count
  chosen=math.min(chosen,item.Count);if not item.Locked then value+=item.Value*chosen;count+=chosen end
  local row=Instance.new("Frame");row.Name="Stack_"..id;row.Size=UDim2.new(1,-8,0,78);row.LayoutOrder=i;style(row,self.Selected[id]and T.Green or T.Paper);row.Parent=self.Content
  local description=item.Name.." - "..item.Size.." - "..item.Mutation.."\n"..item.Count.." fruit - avg "..Format(item.Value).." each - "..Format(item.TotalValue).." total"
  local pick=button(row,"Select",description,self.Selected[id]and T.Green or T.Paper,function()
   self.SelectMode=true;if self.Selected[id]~=nil then self.Selected[id]=nil else self.Selected[id]=item.Count end;self:Render()
  end);pick.Size=UDim2.new(1,-164,1,-8);pick.Position=UDim2.fromOffset(4,4);pick.TextSize=15
  local quantity=text(row,"Quantity",self.Selected[id]and tostring(self.Selected[id])or "--",16);quantity.Size=UDim2.fromOffset(52,44);quantity.Position=UDim2.new(1,-108,.5,-22)
  local minus=button(row,"Minus","-",T.Blue,function()self.SelectMode=true;self.Selected[id]=math.max(0,(self.Selected[id]or 0)-1);self:Render()end);minus.Size=UDim2.fromOffset(44,44);minus.Position=UDim2.new(1,-156,.5,-22)
  local plus=button(row,"Plus","+",T.Blue,function()self.SelectMode=true;self.Selected[id]=math.min(item.Count,(self.Selected[id]or 0)+1);self:Render()end);plus.Size=UDim2.fromOffset(44,44);plus.Position=UDim2.new(1,-52,.5,-22)
 end
 if #(p.Bag.Items or {})==0 then local empty=text(self.Content,"Empty","Your bag is empty. Locked fruit stays in your Vault.",18);empty.LayoutOrder=1;empty.Size=UDim2.new(1,-8,0,70)end
 local locked=text(self.Content,"LockedHeader","LOCKED VAULT - excluded from every sale",18);locked.Size=UDim2.new(1,-8,0,44);locked.LayoutOrder=10000
 for i,item in p.Vault.Items or {}do local line=text(self.Content,"Locked_"..item.Id,item.Name.." - "..item.Size.." - "..item.Mutation.." x"..item.Count.." - LOCKED",15);line.Size=UDim2.new(1,-8,0,48);line.LayoutOrder=10000+i end
 self.Total.Text="YOU'LL GET "..Format(value).." COINS - "..count.." fruit (current estimate)"
 task.defer(function()if self.Content.Parent then self.Content.CanvasPosition=saved end end)
end
return Controller
