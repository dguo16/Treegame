local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local T=require(S.Theme)
local J=require(S.Util.Journal)
local Collection=require(S.Util.Collection)
local Fruits=require(S.Util.FruitCollection)
local Format=require(S.Util.FormatNumber)
local O=require(S.Util.PartOwnership)
local Controller={};Controller.__index=Controller
local function button(parent,name,text,pos,size,color,fn)
 local b=Instance.new("TextButton");b.Name=name;b.Text=text;b.Position=pos;b.Size=size;b.Font=Enum.Font.FredokaOne;b.TextSize=15;b.TextWrapped=true;b.BackgroundColor3=color;b.TextColor3=T.Ink;b.Parent=parent
 local r=Instance.new("UICorner");r.CornerRadius=UDim.new(0,12);r.Parent=b;b.Activated:Connect(fn);return b
end
function Controller.new(parent,send,onBack)
 local self=setmetatable({Send=send,Tab="Index",Page=1,IndexTrack="Names",IndexMode="Sets"},Controller)
 local root=Instance.new("Frame");root.Name="GardenJournal";root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=T.Cream;root.Visible=false;root.Parent=parent;self.Root=root
 local tabs=Instance.new("ScrollingFrame");tabs.Size=UDim2.new(1,0,0,48);tabs.BackgroundTransparency=1;tabs.ScrollBarThickness=2;tabs.ScrollingDirection=Enum.ScrollingDirection.X;tabs.CanvasSize=UDim2.fromOffset(882,0);tabs.Parent=root
 for i,name in {"Parts","Index","Fruit Index","Daily","Goals","Medals","Style","Gardens","News"}do
  button(tabs,name,name,UDim2.fromOffset((i-1)*98,0),UDim2.fromOffset(92,44),T.Blue,function()if name=="Parts"then onBack();return end;self.Tab=name;self.Page=1;self:Render()end)
 end
 local scroll=Instance.new("ScrollingFrame");scroll.Position=UDim2.fromOffset(0,54);scroll.Size=UDim2.new(1,0,1,-54);scroll.BackgroundTransparency=1;scroll.ScrollBarThickness=5;scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y;scroll.CanvasSize=UDim2.new();scroll.Parent=root;self.Content=scroll
 local list=Instance.new("UIListLayout");list.Padding=UDim.new(0,8);list.SortOrder=Enum.SortOrder.LayoutOrder;list.Parent=scroll
 local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,4);pad.PaddingRight=UDim.new(0,8);pad.PaddingBottom=UDim.new(0,12);pad.Parent=scroll
 return self
end
function Controller:Row(value,fn,color,height)
 local b=button(self.Content,"Entry",value,UDim2.new(),UDim2.new(1,-8,0,height or 58),color or T.Paper,fn or function()end);b.LayoutOrder=#self.Content:GetChildren();b.AutoButtonColor=fn~=nil;b.TextScaled=true;local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=12;limit.MaxTextSize=18;limit.Parent=b
 return b
end
function Controller:Update(p)self.State=p;if self.Root.Visible then self:Render()end end
function Controller:Render()
 local p=self.State;if not p then return end;local j=p.Journal;if not j then return end
 local quotes=p.RewardState and p.RewardState.Quotes or {}
 local function amount(key,fallback)return Format(quotes[key]or fallback or 0)end
 local function paid(key,daily)local map=daily and j.Daily.Paid or j.Paid;return map and map[key]end
 for _,child in self.Content:GetChildren()do if not child:IsA("UIComponent")then child:Destroy()end end
 if self.Tab=="Fruit Index"then
  self:Row("FRUIT INDEX - "..Fruits.Count(p).." / 105 name and mutation discoveries. Optional; no rewards or stat bonuses.",nil,T.Gold)
  local record=p.FruitIndex.Biggest
  self:Row(record and("BIGGEST FRUIT: "..record.Size.." "..record.Name.." - "..record.Mutation.." - visual x"..record.Scale..(record.At and ""or " - legacy time unknown"))or "Collect fruit to start your biggest-fruit record.",nil,T.Green,78)
  self:Row("Each entry shows discovered size classes. Sizes are fixed 30 / 60 / 9 / 1 percent; rarity luck and pets never change them. Vault fruit survives Ascension.",nil,T.Paper,78)
  local rows={};for _,entry in p.FruitIndex.Found do table.insert(rows,entry)end;table.sort(rows,function(a,b)if a.Tier~=b.Tier then return a.Tier<b.Tier end;return a.Name..a.Mutation<b.Name..b.Mutation end)
  local pages=math.max(1,math.ceil(#rows/24));self.Page=math.min(self.Page,pages)
  for i=(self.Page-1)*24+1,math.min(self.Page*24,#rows)do local entry=rows[i];local sizes={};for _,size in C.FruitSizes do if entry.Sizes[size.Name]then table.insert(sizes,size.Name)end end
   self:Row(entry.Name.." - "..entry.Mutation.." - sizes: "..table.concat(sizes,", "),nil,C.Rarities[entry.Tier].Color:Lerp(T.Cream,.65),68)
  end
  self:Row("Page "..self.Page.." / "..pages.." - Next",function()self.Page=self.Page%pages+1;self:Render()end,T.Blue)
 elseif self.Tab=="Index"then
  local track=self.IndexTrack;local core=Collection.Progress(p,Collection.Find("CoreNames48"));local names=Collection.Progress(p,Collection.Find("AllNames84"))
  local mutationSets,claimedSets=0,0
  for _,g in Collection.Goals()do if g.Kind=="Mutation"or g.Kind=="AnyMutation"then mutationSets+=1;if j.Collection.Claims[g.Key]then claimedSets+=1 end end end
  local summary=track=="Legend"and("Optional Legend: "..J.Count(p).." / 420 combinations")or(track=="Mutations"and("Mutation sets: "..claimedSets.." / "..mutationSets.." claimed • Partial name targets; long tail optional")or("Name Index: "..core.." / 48 core • "..names.." / 84 total names (rare tail optional)"))
  self:Row(summary,nil,T.Gold)
  if track=="Legend"then self:Row("LEGEND • Optional long tail. Titles and cosmetics only; no required milestones or stats.",nil,T.Pink)
  else local nextSet=p.CollectionNext or Collection.Next(p)
   self:Row(nextSet and ("Next closest: "..nextSet.Title.." • "..nextSet.Progress.." / "..nextSet.Need)or "All core collection sets complete!",nil,T.Green)
  end
  self:Row(track.." • Tap to switch Names / Mutations / Legend",function()self.IndexTrack=track=="Names"and "Mutations"or(track=="Mutations"and "Legend"or "Names");self.Page=1;self:Render()end,T.Blue)
  self:Row(self.IndexMode.." • Tap to switch Sets / Browse",function()self.IndexMode=self.IndexMode=="Sets"and "Browse"or "Sets";self.Page=1;self:Render()end,T.Blue)
  if self.IndexMode=="Sets"then
   for _,goal in Collection.Goals()do local g=goal
    local include=track=="Legend"and g.Optional or(track=="Names"and not g.Optional and(g.Kind=="Names"or g.Kind=="CoreSlot"or g.Kind=="CoreNames"))or(track=="Mutations"and not g.Optional and(g.Kind=="Mutation"or g.Kind=="AnyMutation"))
    if include then
     local progress=Collection.Progress(p,g);local claimed=j.Collection.Claims[g.Key];local reward=C.Cosmetics.Items[g.Cosmetic].Name;if g.ExtraCosmetic then reward..=" + "..C.Cosmetics.Items[g.ExtraCosmetic].Name end
     if g.Stat then reward="+1% coins +1% rarity luck (caps +4%) • "..reward end
     if g.Key=="CoreNames48"then reward="+1 equipped-pet slot • "..reward end
     local coins=Collection.Quote(p,g.Key,p.RewardState and p.RewardState.Reference or 0)
     local suffix=claimed and "CLAIMED"or(reward..(coins>0 and (" • +"..Format(coins).." coins")or ""))
     self:Row(g.Title.." • "..progress.." / "..g.Need.." • "..suffix,function()self.Send("ClaimCollection",{Key=g.Key})end,claimed and T.Paper or(progress>=g.Need and T.Green or T.Blue),82)
    end
   end
  else
   local inUse={};for _,part in p.Parts do if part.InUse then local key=part.Slot..":"..part.Tier..":"..part.Variant;inUse[key]=O.Label(p,part);inUse[key..":"..(part.Mutation or "None")]=O.Label(p,part)end end
   local entries={};for _,slot in C.Slots do for tier=1,#C.Rarities do for variant,name in C.PartVariants[slot][tier]do
    if track=="Names"then table.insert(entries,{Text=name..(inUse[slot..":"..tier..":"..variant]and (" • "..inUse[slot..":"..tier..":"..variant])or "").." • "..slot.." • "..C.Rarities[tier].Name..(tier>C.Collection.CoreMaxTier and " • optional"or ""),Found=j.Collection.Names[slot..":"..tier..":"..variant]})
    else for _,mutation in C.Mutations do
     if track=="Legend"or tier<=C.Collection.CoreMaxTier then table.insert(entries,{Text=name..(inUse[slot..":"..tier..":"..variant..":"..mutation.Name]and (" • "..inUse[slot..":"..tier..":"..variant..":"..mutation.Name])or "").." • "..C.Rarities[tier].Name.." • "..mutation.Name,Found=j.Found[slot..":"..tier..":"..variant..":"..mutation.Name]})end
    end end
   end end end
   local pages=math.max(1,math.ceil(#entries/C.Inventory.PageSize));self.Page=math.min(self.Page,pages)
   self:Row("Page "..self.Page.." / "..pages.." • Tap for next",function()self.Page=self.Page%pages+1;self:Render()end,T.Blue)
   if self.Page>1 then self:Row("Previous page",function()self.Page-=1;self:Render()end,T.Blue)end
   for i=(self.Page-1)*C.Inventory.PageSize+1,math.min(self.Page*C.Inventory.PageSize,#entries)do local e=entries[i];self:Row((e.Found and "✓ "or "? ")..e.Text,nil,e.Found and T.Green or T.Paper)end
  end
 elseif self.Tab=="Daily"then
  self:Row("Return days: "..j.LoginDays.." • Missing a day never removes progress. Daily rewards reset at 00:00 UTC.",nil,T.Gold)
  self:Row(j.Daily.Claims.DailyLogin and ("Login claimed • +"..Format(paid("DailyLogin",true)or 0).." coins paid")or ("Claim login • +"..amount("DailyLogin").." coins"),function()self.Send("ClaimJournal",{Key="DailyLogin"})end,T.Green)
  self:Row("Rewards use your best baseline garden income over "..math.floor(C.Rewards.ReferenceSeconds/86400).." days, with caps. Amounts update at claim time. Missing days never resets return days.",nil,T.Paper)
  self:Row(j.Daily.Claims.FreeRoll and "Free roll claimed today"or "FREE DAILY ROLL • Uses the odds and pity shown in Odds",function()self.Send("DailyRoll",{})end,T.Gold)
  for _,goal in J.DailyGoals()do
   self:Row(goal.Title.." • "..math.min(goal.Need,J.Progress(p,goal,true)).." / "..goal.Need.." • "..(j.Daily.Claims[goal.Key]and ("CLAIMED • +"..Format(paid(goal.Key,true)or 0).." paid")or "+"..amount(goal.Key,goal.Coins).." coins • Claim"),function()self.Send("ClaimJournal",{Key=goal.Key})end,T.Blue)
  end
 elseif self.Tab=="Goals"then
  self:Row("Intermediate milestones • Permanent claims survive Ascension",nil,T.Gold)
  for _,goal in J.Goals()do local goalKey=goal.Key;local progress=J.Progress(p,goal,false)
   self:Row(goal.Title.." • "..Format(math.min(goal.Need,progress)).." / "..Format(goal.Need).." • "..(j.Claims[goalKey]and (paid(goalKey,false)and "CLAIMED • +"..Format(paid(goalKey,false)).." paid"or "CLAIMED")or "+"..amount(goalKey,goal.Coins).." coins • Claim"),function()self.Send("ClaimJournal",{Key=goalKey})end,progress>=goal.Need and T.Green or T.Paper)
  end
  self:Row("Event keepsakes • "..Collection.MedalBalance(p).." medals available in the Medals shop",nil,T.Gold)
  for _,name in C.Events.Order do self:Row((j.Keepsakes[name]and "✓ "or "? ")..name.." keepsake",nil,T.Paper)end
 elseif self.Tab=="Medals"then
  self:Row(Collection.MedalBalance(p).." medals available • "..(j.EventTokens or 0).." earned lifetime • Cosmetic purchases only, no random outcomes",nil,T.Gold)
  for _,shop in C.Cosmetics.MedalShop do local item=shop;local owned=j.Cosmetics.Owned[item.Key]
   self:Row(C.Cosmetics.Items[item.Key].Name.." • "..item.Cost.." medals • "..(owned and "OWNED"or "Buy"),function()self.Send("BuyMedalCosmetic",{Key=item.Key})end,owned and T.Paper or T.Green)
  end
 elseif self.Tab=="Style"then
  self:Row("Earn cosmetics through sets, medals and likes. Equip one aura, decoration and title. Cosmetics do not add stats.",nil,T.Gold)
  for _,slot in {"Aura","Decoration","Title"}do local selectedSlot=slot
   self:Row("Clear "..slot,function()self.Send("EquipCosmetic",{Slot=selectedSlot,Key=""})end,T.Blue)
   local keys={};for key,item in C.Cosmetics.Items do if item.Slot==slot and j.Cosmetics.Owned[key]then table.insert(keys,key)end end;table.sort(keys)
   for _,key in keys do local id=key;self:Row(C.Cosmetics.Items[id].Name..(j.Cosmetics.Equipped[slot]==id and " • EQUIPPED"or " • Equip"),function()self.Send("EquipCosmetic",{Slot=selectedSlot,Key=id})end,T.Paper)end
  end
 elseif self.Tab=="Gardens"then
  self:Row("Your garden: "..(j.LikesReceived or 0).." likes received • shown on your garden sign",nil,T.Gold)
  for i,need in C.Collection.Likes do local key="Likes"..need;local reward=C.Cosmetics.Items[C.Collection.LikeRewards[i]].Name
   self:Row(need.." likes • "..reward..(j.Cosmetics.LikesClaims[key]and " • CLAIMED"or " • Claim"),function()self.Send("ClaimLikes",{Key=key})end,T.Green)
  end
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
