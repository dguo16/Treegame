-- A cosmetic vertical reel for already awarded server results.
local Tween=game:GetService("TweenService")
local Run=game:GetService("RunService")
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local T=require(S.Theme)
local Models=require(S.Util.PreviewModels)
local Catalog=require(S.Util.PartCatalog)
local Display=require(S.Util.RollDisplay)
local Effects=require(script.Parent.Effects)
local Roll={};Roll.__index=Roll
local function round(x,color)
 x.BackgroundColor3=color;x.BorderSizePixel=0
 local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,16);c.Parent=x
 local s=Instance.new("UIStroke");s.Color=T.Ink;s.Thickness=2;s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Parent=x
end
local function label(parent,name,value,size)
 local x=Instance.new("TextLabel");x.Name=name;x.Text=value;x.TextSize=size or 18;x.TextWrapped=true;x.Font=Enum.Font.FredokaOne;x.TextColor3=T.Ink;x.BackgroundTransparency=1;x.Parent=parent
 return x
end
local function button(parent,name,value,fn)
 local b=Instance.new("TextButton");b.Name=name;b.Text=value;b.Font=Enum.Font.FredokaOne;b.TextSize=14;b.TextWrapped=true;b.TextColor3=T.Ink;round(b,T.Cream);b.Parent=parent;b.Activated:Connect(fn);return b
end
local function preview(parent,item)
 local vp=Instance.new("ViewportFrame");vp.Name="PartPreview";vp.BackgroundTransparency=1;vp.Ambient=Color3.fromRGB(210,210,210);vp.LightColor=Color3.new(1,1,1);vp.Parent=parent
 local world=Instance.new("WorldModel");world.Parent=vp
 local model=Models.Part(item);model.Parent=world
 local cf,size=model:GetBoundingBox();local d=math.max(size.X,size.Y,size.Z)*2
 local camera=Instance.new("Camera");camera.FieldOfView=35;camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(d*.6,d*.25,d),cf.Position);camera.Parent=vp;vp.CurrentCamera=camera
 return vp
end
function Roll.new(gui)
 local self=setmetatable({Queue={},History={},Hidden=false,Busy=false,State=nil,Rng=Random.new()},Roll)
 self.Root=Instance.new("Frame");self.Root.Name="RollReel";self.Root.BackgroundTransparency=1;self.Root.ZIndex=25;self.Root.Visible=false;self.Root.AnchorPoint=Vector2.new(.5,1);self.Root.Parent=gui
 self.Title=label(self.Root,"Title","GROW SOMETHING GREAT",20);self.Title.TextColor3=T.Cream;self.Title.TextStrokeColor3=T.Ink;self.Title.TextStrokeTransparency=0;self.Title.Size=UDim2.new(1,0,0,26)
 self.Track=Instance.new("Frame");self.Track.Name="VerticalTrack";self.Track.BackgroundTransparency=1;self.Track.ClipsDescendants=true;self.Track.Parent=self.Root
 self.Center=Instance.new("Frame");self.Center.Name="CenterHighlight";round(self.Center,T.Cream);self.Center.BackgroundTransparency=.08;self.Center.Parent=self.Track
 self.Belt=Instance.new("Frame");self.Belt.Name="ReelItems";self.Belt.BackgroundTransparency=1;self.Belt.ZIndex=2;self.Belt.Parent=self.Track
 self.Description=label(self.Root,"ResultDetails","",17);self.Description.TextColor3=T.Cream;self.Description.TextStrokeColor3=T.Ink;self.Description.TextStrokeTransparency=0
 self.Odds=label(self.Root,"ResultOdds","",14);self.Odds.TextColor3=T.Cream;self.Odds.TextStrokeColor3=T.Ink;self.Odds.TextStrokeTransparency=0
 self.Skip=button(self.Root,"Skip","SKIP ANIMATION",function()self.SkipRequested=true end)
 self.Controls=Instance.new("Frame");self.Controls.Name="RollControls";self.Controls.BackgroundTransparency=1;self.Controls.AnchorPoint=Vector2.new(.5,1);self.Controls.ZIndex=26;self.Controls.Parent=gui
 self.Review=button(self.Controls,"RollResults","ROLL RESULTS",function()self:ShowSummary()end);self.Review.Size=UDim2.new(.61,-4,1,0)
 self.Toggle=button(self.Controls,"HideReel","HIDE REEL",function()self.Hidden=not self.Hidden;self.SkipRequested=true;self.Root.Visible=false;self.Toggle.Text=self.Hidden and "SHOW REEL"or "HIDE REEL"end);self.Toggle.Position=UDim2.fromScale(.61,0);self.Toggle.Size=UDim2.new(.39,0,1,0)
 self.Summary=Instance.new("Frame");self.Summary.Name="RollResultsSummary";self.Summary.AnchorPoint=Vector2.new(.5,.5);self.Summary.Position=UDim2.fromScale(.5,.49);self.Summary.ZIndex=30;round(self.Summary,T.Cream);self.Summary.Visible=false;self.Summary.Parent=gui
 self.SummaryTitle=label(self.Summary,"Title","RECENT ROLLS",20);self.SummaryTitle.Position=UDim2.fromOffset(12,4);self.SummaryTitle.Size=UDim2.new(1,-176,0,44)
 local previous=button(self.Summary,"PreviousPage","<",function()self.Page=math.max(1,(self.Page or 1)-1);self:ShowSummary(true)end);previous.Size=UDim2.fromOffset(44,44);previous.Position=UDim2.new(1,-152,0,4)
 local nextPage=button(self.Summary,"NextPage",">",function()self.Page=math.min(math.max(1,math.ceil(#self.History/10)),(self.Page or 1)+1);self:ShowSummary(true)end);nextPage.Size=UDim2.fromOffset(44,44);nextPage.Position=UDim2.new(1,-102,0,4)
 local close=button(self.Summary,"Close","X",function()self.Summary.Visible=false end);close.Size=UDim2.fromOffset(44,44);close.Position=UDim2.new(1,-52,0,4);close.BackgroundColor3=T.Red
 self.List=Instance.new("ScrollingFrame");self.List.Name="EveryAwardedPart";self.List.Position=UDim2.fromOffset(10,54);self.List.Size=UDim2.new(1,-20,1,-64);self.List.BackgroundTransparency=1;self.List.BorderSizePixel=0;self.List.ScrollBarThickness=5;self.List.AutomaticCanvasSize=Enum.AutomaticSize.Y;self.List.CanvasSize=UDim2.new();self.List.Parent=self.Summary
 local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,8);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=self.List
 local pad=Instance.new("UIPadding");pad.PaddingTop=UDim.new(0,3);pad.PaddingLeft=UDim.new(0,3);pad.PaddingBottom=UDim.new(0,5);pad.Parent=self.List
 self.SummaryHint=label(self.List,"Hint","",14);self.SummaryHint.Size=UDim2.new(1,-12,0,42);self.SummaryHint.LayoutOrder=0
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()self:Resize()end)
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()task.defer(function()self:Resize()end)end)
 Run.RenderStepped:Connect(function()
  local modal=false;for _,name in {"Menu","InventoryWindow","SellPanel"}do local window=gui:FindFirstChild(name);if window and window.Visible then modal=true end end
  self.Controls.Visible=#self.History>0 and not modal and not(self.Root.Visible and gui.AbsoluteSize.Y<450)
  for _,name in {"TutorialHint","EventLabel","TreeReady"}do local hint=gui:FindFirstChild(name);self.HintVisibility=self.HintVisibility or {};if hint then if self.Root.Visible then if self.HintVisibility[name]==nil then self.HintVisibility[name]=hint.Visible end;hint.Visible=false elseif self.HintVisibility[name]~=nil then hint.Visible=self.HintVisibility[name];self.HintVisibility[name]=nil end end end
  if modal then self.Root.Visible=false;self.Summary.Visible=false end
  local touch=game.Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
  if self.Summary.Visible and touch then if not self.Touch then self.Touch=touch;self.TouchEnabled=touch.Enabled end;touch.Enabled=false
  elseif self.Touch then if self.Touch.Parent then self.Touch.Enabled=self.TouchEnabled end;self.Touch=nil end
 end)
 self:Resize();self.Controls.Visible=false
 return self
end
function Roll:Resize()
 local area=self.Root.Parent.AbsoluteSize;local short=area.Y<450
 local width=math.min(420,area.X*.88);local height=short and 150 or math.min(350,area.Y-230)
 height=math.max(150,height)
 self.Root.Size=UDim2.fromOffset(width,height);self.Root.Position=UDim2.new(.5,0,1,short and -100 or -210)
 self.Track.Position=UDim2.fromOffset(4,30);self.Track.Size=UDim2.new(1,-8,1,-120)
 local trackHeight=height-120;self.RowHeight=math.max(38,trackHeight*.48)
 self.Center.Size=UDim2.new(1,-8,0,self.RowHeight);self.Center.Position=UDim2.new(0,4,.5,-self.RowHeight/2)
 self.Belt.Size=UDim2.new(1,0,0,self.RowHeight*3);self.Belt.Position=UDim2.new(0,0,.5,-self.RowHeight*1.5)
 self.Description.Position=UDim2.new(0,0,1,-86);self.Description.Size=UDim2.new(1,0,0,22);self.Description.TextSize=short and 13 or 17
 self.Odds.Position=UDim2.new(0,0,1,-64);self.Odds.Size=UDim2.new(1,0,0,30);self.Odds.TextSize=short and 11 or 13
 self.Skip.Position=UDim2.new(.2,0,1,-30);self.Skip.Size=UDim2.new(.6,0,0,44);self.Skip.Position=UDim2.new(.2,0,1,-44)
 self.Controls.Size=UDim2.fromOffset(math.min(330,area.X*.88),44);self.Controls.Position=UDim2.new(.5,0,1,short and -82 or -156)
 self.Summary.Size=UDim2.fromOffset(math.min(650,area.X*.94),math.max(180,area.Y*.88))
 if short then
  self.Root.BackgroundColor3=T.Cream;self.Root.BackgroundTransparency=.04
  if not self.Root:FindFirstChild("UICorner")then round(self.Root,T.Cream);self.Root.BackgroundTransparency=.04 end
  self.Title.TextColor3=T.Ink;self.Title.TextStrokeTransparency=1
  self.Description.TextColor3=T.Ink;self.Description.TextStrokeTransparency=1;self.Odds.TextColor3=T.Ink;self.Odds.TextStrokeTransparency=1
  self.Track.Position=UDim2.fromOffset(4,26);self.Track.Size=UDim2.new(1,-112,0,66);self.RowHeight=44
  self.Center.Size=UDim2.new(1,-8,0,44);self.Center.Position=UDim2.new(0,4,.5,-22);self.Belt.Size=UDim2.new(1,0,0,132);self.Belt.Position=UDim2.new(0,0,.5,-66)
  self.Description.Position=UDim2.fromOffset(4,94);self.Description.Size=UDim2.new(1,-8,0,20);self.Odds.Position=UDim2.fromOffset(4,115);self.Odds.Size=UDim2.new(1,-8,0,31)
  self.Skip.Position=UDim2.new(1,-104,0,38);self.Skip.Size=UDim2.fromOffset(98,44)
 else
  self.Root.BackgroundTransparency=1;local stroke=self.Root:FindFirstChildOfClass("UIStroke");if stroke then stroke.Enabled=false end
  self.Title.TextColor3=T.Cream;self.Title.TextStrokeTransparency=0;self.Description.TextColor3=T.Cream;self.Description.TextStrokeTransparency=0;self.Odds.TextColor3=T.Cream;self.Odds.TextStrokeTransparency=0
 end
 local stroke=self.Root:FindFirstChildOfClass("UIStroke");if stroke then stroke.Enabled=short end
 if self.Items then self:Draw(self.Items)end
end
function Roll:Update(state)
 self.State=state
 if state.Settings.SkipRolls or state.Settings.ReducedEffects then self.SkipRequested=true end
end
function Roll:Decoration()
 local slot=C.Slots[self.Rng:NextInteger(1,#C.Slots)];local tier=self.Rng:NextInteger(1,#C.Rarities);local names=Catalog.Variants(slot,tier)
 return {Name=names[self.Rng:NextInteger(1,#names)],Slot=slot,Tier=tier,Mutation="None",Variant=1,Stat=1}
end
function Roll:Draw(items)
 self.Items=items
 for _,x in self.Belt:GetChildren()do x:Destroy()end
 for i,item in items do
  local row=Instance.new("Frame");row.Name="ReelRow"..i;row.BackgroundTransparency=1;row.Size=UDim2.new(1,0,0,self.RowHeight);row.Position=UDim2.fromOffset(0,(i-1)*self.RowHeight);row.Parent=self.Belt
  local vp=preview(row,item);vp.Position=UDim2.fromScale(.02,.03);vp.Size=UDim2.fromScale(.32,.94);vp.ImageTransparency=i==2 and 0 or .72
  local name=label(row,"PartName",item.Name,20);name.TextScaled=true;local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=12;limit.MaxTextSize=23;limit.Parent=name;name.Position=UDim2.fromScale(.35,.05);name.Size=UDim2.fromScale(.63,.62);name.TextTransparency=i==2 and 0 or .65
  local tier=label(row,"Rarity",C.Rarities[item.Tier].Name.." "..item.Slot,13);tier.Position=UDim2.fromScale(.35,.65);tier.Size=UDim2.fromScale(.63,.3);tier.TextTransparency=i==2 and 0 or .65
 end
end
function Roll:Animate(results)
 local best=Display.Best(results);local settings=self.State and self.State.Settings or {}
 self.SkipRequested=settings.SkipRolls or settings.ReducedEffects or self.Hidden
 self.Title.Text="ROLLING "..#results..(#results==1 and " PART"or " PARTS");self.Description.Text="Finding your next tree part...";self.Odds.Text="Preview animation | see Odds for your current chances."
 self.Root.Visible=not self.Hidden and not self.Summary.Visible;self.Skip.Visible=true
 local duration=math.max(0,C.UI.RollDuration-C.UI.RevealDuration);local started=os.clock();local items={self:Decoration(),self:Decoration(),self:Decoration()}
 while os.clock()-started<duration and not self.SkipRequested do
  self:Draw(items);self.Belt.Position=UDim2.new(0,0,.5,-self.RowHeight*1.5)
  local elapsed=os.clock()-started;local step=.09+elapsed*.08
  local tween=Tween:Create(self.Belt,TweenInfo.new(step,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,.5,-self.RowHeight*2.5)});tween:Play()
  Effects.Sound("Tick",1+elapsed/math.max(duration,.1));task.wait(step)
  items={items[2],items[3],self:Decoration()}
 end
 self.Belt.Position=UDim2.new(0,0,.5,-self.RowHeight*1.5);self:Draw({items[2],best,items[3]})
 self.Title.Text=#results>1 and("BEST OF "..#results.." | ALL PARTS SAVED")or "YOUR NEW PART"
 self.Description.Text=Display.Detail(best);self.Odds.Text=Display.OddsText(best);self.Center.BackgroundColor3=C.Rarities[best.Tier].Color;self.Skip.Visible=false
 if not self.Hidden and not settings.SkipRolls then
  Effects.Sound("Reveal")
  if not settings.ReducedEffects and best.Tier>=4 then
   Effects.Shake(best.Tier);local root=game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
   if root then Effects.Burst(root.Position,C.Rarities[best.Tier].Color,math.min(40,best.Tier*5))end
  end
 end
 task.wait(self.Hidden and .03 or settings.SkipRolls and .12 or(self.State and self.State.AutoRoll)and .32 or .85)
 self.Root.Visible=false;self.Center.BackgroundColor3=T.Cream
 if #results>1 and not self.Hidden and not(self.State and self.State.AutoRoll)and #self.Queue==0 then self:ShowSummary()end
end
function Roll:Push(results)
 if #results==0 then return end
 Display.Remember(self.History,results);self.LatestCount=#results;self.Controls.Visible=true;self.Review.Text="RESULTS ("..#results..")"
 if self.Summary.Visible then self:ShowSummary()end
 table.insert(self.Queue,results)
 if self.Busy then return end
 self.Busy=true
 task.spawn(function()
  while #self.Queue>0 do
   local batch=table.remove(self.Queue,1)
   local ok,err=pcall(function()self:Animate(batch)end)
   if not ok then warn("Roll presentation: "..tostring(err));self.Root.Visible=false end
  end
  self.Busy=false
 end)
end
function Roll:ShowSummary(keepPage)
 if not keepPage then self.Page=1 end
 self.Root.Visible=false;self.SkipRequested=true;self.Summary.Visible=true
 for _,x in self.List:GetChildren()do if not x:IsA("UIComponent")and x~=self.SummaryHint then x:Destroy()end end
 self.SummaryHint.Text="Latest batch: "..(self.LatestCount or 0).." | Page "..(self.Page or 1).." / "..math.max(1,math.ceil(#self.History/10))..". Last 100 awards. Name + mutation odds; raw stat varies."
 if #self.History==0 then return end
 local first=math.max(1,#self.History-((self.Page or 1)-1)*10)
 for i=first,math.max(1,first-9),-1 do
  local item=self.History[i];local row=Instance.new("Frame");row.Name="Award_"..item.Id;round(row,T.Paper);row.Size=UDim2.new(1,-14,0,112);row.LayoutOrder=#self.History-i+1;row.Parent=self.List
  local vp=preview(row,item);vp.Size=UDim2.new(.23,0,1,-8);vp.Position=UDim2.fromOffset(2,4)
  local title=label(row,"PartName",item.Name,18);title.Position=UDim2.fromScale(.25,0);title.Size=UDim2.new(.73,0,0,30)
  local detail=label(row,"Details",Display.Detail(item).."\n"..Display.OddsText(item).."\nRaw stat: "..string.format("%.3f",item.Stat),13);detail.Position=UDim2.new(.25,0,0,31);detail.Size=UDim2.new(.73,0,1,-35)
 end
 self.List.CanvasPosition=Vector2.zero
end
return Roll
