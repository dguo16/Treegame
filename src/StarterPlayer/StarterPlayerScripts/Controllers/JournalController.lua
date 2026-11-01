local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local T=require(S.Theme)
local J=require(S.Util.Journal)
local Format=require(S.Util.FormatNumber)
local Controller={};Controller.__index=Controller
local function button(parent,name,text,pos,size,color,fn)
 local b=Instance.new("TextButton");b.Name=name;b.Text=text;b.Position=pos;b.Size=size;b.Font=Enum.Font.FredokaOne;b.TextSize=15;b.TextWrapped=true;b.BackgroundColor3=color;b.TextColor3=T.Ink;b.Parent=parent
 local r=Instance.new("UICorner");r.CornerRadius=UDim.new(0,12);r.Parent=b;b.Activated:Connect(fn);return b
end
function Controller.new(parent,send,onBack)
 local self=setmetatable({Send=send,Tab="Index",Page=1},Controller)
 local root=Instance.new("Frame");root.Name="GardenJournal";root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=T.Cream;root.Visible=false;root.Parent=parent;self.Root=root
 local tabs=Instance.new("ScrollingFrame");tabs.Size=UDim2.new(1,0,0,48);tabs.BackgroundTransparency=1;tabs.ScrollBarThickness=2;tabs.ScrollingDirection=Enum.ScrollingDirection.X;tabs.CanvasSize=UDim2.fromOffset(588,0);tabs.Parent=root
 for i,name in {"Parts","Index","Daily","Goals","Gardens","News"}do
  button(tabs,name,name,UDim2.fromOffset((i-1)*98,0),UDim2.fromOffset(92,44),T.Blue,function()if name=="Parts"then onBack();return end;self.Tab=name;self.Page=1;self:Render()end)
 end
 local scroll=Instance.new("ScrollingFrame");scroll.Position=UDim2.fromOffset(0,54);scroll.Size=UDim2.new(1,0,1,-54);scroll.BackgroundTransparency=1;scroll.ScrollBarThickness=5;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=root;self.Content=scroll
 local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,8);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=scroll
 local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,4);pad.PaddingRight=UDim.new(0,8);pad.PaddingBottom=UDim.new(0,12);pad.Parent=scroll
 return self
end
function Controller:Row(value,fn,color)
 local b=button(self.Content,"Entry",value,UDim2.new(),UDim2.new(1,-8,0,58),color or T.Paper,fn or function()end);b.LayoutOrder=#self.Content:GetChildren();b.AutoButtonColor=fn~=nil;b.TextScaled=true;local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=12;limit.MaxTextSize=18;limit.Parent=b
 return b
end
function Controller:Update(p)self.State=p;if self.Root.Visible then self:Render()end end
function Controller:Render()
 local p=self.State;if not p then return end;local j=p.Journal;if not j then return end
 for _,child in self.Content:GetChildren()do if not child:IsA("UIComponent")then child:Destroy()end end
 if self.Tab=="Index"then
  local found=J.Count(p);self:Row(found.." / 420 discovered • 84 parts × 5 mutations",nil,T.Gold)
  local entries={};for _,slot in C.Slots do for tier=1,#C.Rarities do for variant,name in C.PartVariants[slot][tier]do for _,mutation in C.Mutations do
   local key=slot..":"..tier..":"..variant..":"..mutation.Name;table.insert(entries,{Text=name.." • "..slot.." • "..C.Rarities[tier].Name.." • "..mutation.Name,Found=j.Found[key]})
  end end end end
  self:Row("Page "..self.Page.." / 18 • Tap for next page",function()self.Page=self.Page%18+1;self:Render()end,T.Blue)
  if self.Page>1 then self:Row("Previous page",function()self.Page-=1;self:Render()end,T.Blue)end
  for i=(self.Page-1)*24+1,math.min(self.Page*24,#entries)do local entry=entries[i];self:Row((entry.Found and "✓ "or "? ")..entry.Text,nil,entry.Found and T.Green or T.Paper)end
 elseif self.Tab=="Daily"then
  self:Row("Return days: "..j.LoginDays.." • Missing a day never removes progress. Daily rewards reset at 00:00 UTC.",nil,T.Gold)
  self:Row(j.Daily.Claims.DailyLogin and "Login reward claimed"or "Claim today's login coins",function()self.Send("ClaimJournal",{Key="DailyLogin"})end,T.Green)
  self:Row(j.Daily.Claims.FreeRoll and "Free roll claimed today"or "FREE DAILY ROLL • Uses the odds and pity shown in Odds",function()self.Send("DailyRoll",{})end,T.Gold)
  for _,goal in J.DailyGoals()do
   self:Row(goal.Title.." • "..math.min(goal.Need,J.Progress(p,goal,true)).." / "..goal.Need.." • "..(j.Daily.Claims[goal.Key]and "CLAIMED"or "+"..goal.Coins.." coins • Claim"),function()self.Send("ClaimJournal",{Key=goal.Key})end,T.Blue)
  end
 elseif self.Tab=="Goals"then
  self:Row("Intermediate milestones • Permanent claims survive Ascension",nil,T.Gold)
  for _,goal in J.Goals()do local goalKey=goal.Key;local progress=J.Progress(p,goal,false)
   self:Row(goal.Title.." • "..Format(math.min(goal.Need,progress)).." / "..Format(goal.Need).." • "..(j.Claims[goalKey]and "CLAIMED"or "+"..Format(goal.Coins).." coins • Claim"),function()self.Send("ClaimJournal",{Key=goalKey})end,progress>=goal.Need and T.Green or T.Paper)
  end
  self:Row("Event keepsakes: "..(j.EventTokens or 0).." participation medals",nil,T.Gold)
  for _,name in C.Events.Order do self:Row((j.Keepsakes[name]and "✓ "or "? ")..name.." keepsake",nil,T.Paper)end
 elseif self.Tab=="Gardens"then
  if p.Showcase then self:Row(p.Showcase.Name.." • Tallest producing tree: "..string.format("%.1f",p.Showcase.Height).." studs • Server rarest: "..C.Rarities[p.Showcase.Rarest].Name,nil,T.Gold)end
  for _,garden in p.GardenVisitors or {}do if garden.UserId~=game.Players.LocalPlayer.UserId then local id=garden.UserId
   self:Row("Visit "..garden.Name.." • "..garden.Likes.." likes",function()self.Send("VisitGarden",{Target=id})end,T.Blue)
   self:Row(j.Liked[tostring(id)]and "Liked today"or "Like this garden (while visiting)",function()self.Send("LikeGarden",{Target=id})end,T.Pink)
  end end
 elseif self.Tab=="News"then
  self:Row(C.News.Version,nil,T.Gold);for _,entry in C.News.Entries do self:Row(entry,nil,T.Paper)end
 end
end
return Controller
