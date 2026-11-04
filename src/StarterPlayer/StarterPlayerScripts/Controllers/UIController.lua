-- Mobile-first intent-only UI, live odds/comparisons, reel animation, shop and settings.
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local S=game:GetService("ReplicatedStorage"):WaitForChild("BuildATree")
local C=require(S.Config)
local T=require(S.Theme)
local G=require(S.Util.GrowthCalculator)
local V=require(S.Util.ValueCalculator)
local R=require(S.Util.RollEngine)
local Catalog=require(S.Util.PartCatalog)
local P=require(S.Util.Profile)
local Format=require(S.Util.FormatNumber)
local Effects=require(script.Parent.Effects)
local InventoryController=require(script.Parent.InventoryController)
local ShopGraphics=require(script.Parent.ShopGraphics)
local AdminController=require(script.Parent.AdminController)
local HudControls=require(script.Parent.HudControls)
local PlotController=require(script.Parent.PlotController)
local SellController=require(script.Parent.SellController)
local RollController=require(script.Parent.RollController)
local UI={State=nil,Tab=nil,SeenRoll=false,Rolling=false}
local gui,coins,bag,roll,plant,eventLabel,tutorial,toastStack,panel,content,heading,reel,footer,nav,sellNav,fullWarning,fullArrow
local colors={Background=T.Cream,Panel=T.Paper,Green=T.Green,Gold=T.Gold,Text=T.Ink}
local function decorate(object)
 local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,18); corner.Parent=object
 local stroke=Instance.new("UIStroke"); stroke.Color=T.Ink; stroke.Thickness=3; stroke.Transparency=0; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; stroke.Parent=object
 local gradient=Instance.new("UIGradient"); gradient.Rotation=90; gradient.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(218,218,218)); gradient.Parent=object
end
local function actionColor(value)
 local v=string.lower(value)
 if v=="×" or v:find("sell") or v:find("prune") or v:find("trap") then return T.Red end
 if v:find("robux") or v:find("pass") or v:find("ascen") or v:find("optional") then return T.Purple end
 if v:find("pet") or v:find("egg") or v:find("fuse") then return T.Pink end
 if v:find("shop") or v:find("water") or v:find("bag") or v:find("equip") then return T.Blue end
 if v:find("roll") or v:find("odds") or v:find("coin") or v:find("upgrade") then return T.Gold end
 if v:find("setting") or v:find("more") or v:find("player") then return T.Teal end
 return T.Green
end
local function text(parent,value,size)
 local label=Instance.new("TextLabel"); label.LayoutOrder=#parent:GetChildren(); label.BackgroundTransparency=1; label.Text=value; label.TextColor3=colors.Text; label.Font=Enum.Font.FredokaOne; label.TextSize=size or 18; label.TextWrapped=true; label.Parent=parent; return label
end
local function button(parent,value,callback)
 local b=Instance.new("TextButton"); b.LayoutOrder=#parent:GetChildren(); b.Text=value; b.Font=Enum.Font.FredokaOne; b.TextSize=20; b.TextWrapped=true; b.TextColor3=T.Cream; b.TextStrokeColor3=T.Ink; b.TextStrokeTransparency=0; b.BackgroundColor3=actionColor(value); b.AutoButtonColor=false; b.Size=UDim2.new(1,-8,0,58); b.Parent=parent; decorate(b)
 local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10); pad.Parent=b
 local constraint=Instance.new("UISizeConstraint"); constraint.MinSize=Vector2.new(C.UI.MinimumTouch,C.UI.MinimumTouch); constraint.Parent=b
 local scale=Instance.new("UIScale"); scale.Parent=b
 local function bounce(to) Tween:Create(scale,TweenInfo.new(.12,Enum.EasingStyle.Back),{Scale=to}):Play() end
 b.MouseEnter:Connect(function() bounce(1.025) end); b.MouseLeave:Connect(function() bounce(1) end)
 b.MouseButton1Down:Connect(function() bounce(.95) end); b.MouseButton1Up:Connect(function() bounce(1) end)
 b.Activated:Connect(callback); return b
end
local function send(action,args) UI.Network.Intent:FireServer(action,args or {}) end
local function row(value,callback) return button(content,value,callback or function() end) end
local function shopSection(title,color,items,description)
 local caption=text(content,title,23);caption.Name="ShopSectionTitle";caption.Size=UDim2.new(1,-8,0,40);caption.TextXAlignment=Enum.TextXAlignment.Left
 if description then local info=text(content,description,16);info.Name="ShopSectionInfo";info.Size=UDim2.new(1,-8,0,54);info.TextXAlignment=Enum.TextXAlignment.Left end
 local group=Instance.new("Frame");group.Name=title;group.BackgroundTransparency=1;group.LayoutOrder=#content:GetChildren();group.Parent=content
 local width=math.max(120,content.AbsoluteSize.X-24)
 local columns=workspace.CurrentCamera.ViewportSize.X<650 and 2 or 3
 local gap=14;local side=math.min(230,math.floor((width-gap*(columns-1))/columns))
 group.Size=UDim2.new(1,-12,0,math.ceil(#items/columns)*(side+gap)-gap+8)
 local grid=Instance.new("UIGridLayout");grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.HorizontalAlignment=Enum.HorizontalAlignment.Center;grid.CellPadding=UDim2.fromOffset(gap,gap);grid.CellSize=UDim2.fromOffset(side,side);grid.FillDirectionMaxCells=columns;grid.Parent=group
 for index,item in items do
  local tile=button(group,item.Title,function() if not item.Owned then send(item.Action,item.Args) else UI.Toast(item.Maxed and "Already at maximum!" or "Already owned!") end end)
  tile.Name="ShopTile_"..item.Key;tile.LayoutOrder=index;tile.Text="";tile.BackgroundColor3=item.Owned and color:Lerp(T.Cream,.6) or color;tile:SetAttribute("ShopItem",item.Key)
  tile.UICorner.CornerRadius=UDim.new(0,12)
  local titleLabel=text(tile,item.Title,22);titleLabel.Name="ItemTitle";titleLabel.Size=UDim2.new(1,-8,.22,0);titleLabel.Position=UDim2.new(0,4,.025,0);titleLabel.TextColor3=T.Cream;titleLabel.TextStrokeColor3=T.Ink;titleLabel.TextStrokeTransparency=0;titleLabel.TextScaled=true
  local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=13;limit.MaxTextSize=22;limit.Parent=titleLabel
  local inset=Instance.new("Frame");inset.Name="IconBox";inset.Position=UDim2.fromScale(.15,.25);inset.Size=UDim2.fromScale(.7,.43);inset.BackgroundColor3=T.Cream;inset.Parent=tile
  local round=Instance.new("UICorner");round.CornerRadius=UDim.new(0,10);round.Parent=inset
  local border=Instance.new("UIStroke");border.Color=T.Ink;border.Transparency=.65;border.Parent=inset
  ShopGraphics.Viewport(inset,item.Icon)
  local detail=text(tile,item.Detail,16);detail.Name="UpgradeDetail";detail.Position=UDim2.fromScale(0,.685);detail.Size=UDim2.fromScale(1,.12);detail.TextScaled=true
  local detailLimit=Instance.new("UITextSizeConstraint");detailLimit.MinTextSize=12;detailLimit.MaxTextSize=16;detailLimit.Parent=detail
  local price=text(tile,item.Owned and (item.Maxed and "MAXED OUT" or "OWNED") or (Format(item.Price).." coins"),19)
  price.Name="Price";price.Position=UDim2.fromScale(.04,.825);price.Size=UDim2.fromScale(.92,.14);price.BackgroundTransparency=0;price.BackgroundColor3=T.Cream;price.TextScaled=true
  local pc=Instance.new("UICorner");pc.CornerRadius=UDim.new(0,8);pc.Parent=price
  local pl=Instance.new("UITextSizeConstraint");pl.MinTextSize=12;pl.MaxTextSize=19;pl.Parent=price
 end
end
local function shopCatalog(p)
 local upgrades={}
 local names={LeafPower="Leaf Power",Bag="Bigger Bag",Radius="Fruit Magnet",Discount="Cheaper Rolls",Plots="Tree Plots",PetSlots="Pet Slots",Batch="Multi Roll"}
 for _,kind in {"LeafPower","Bag","Radius","Discount","Plots","PetSlots","Batch"} do
  local up=C.Upgrades[kind];local level=p.Upgrades[kind] or 1;local nextValue=up.Values[level+1];local price=up.Prices and up.Prices[level] or up.BasePrice*up.PriceGrowth^(level-1)
  local currentValue=up.Values[level]
  if kind=="PetSlots"then local extra=(p.MaxPetSlots or currentValue)-currentValue;currentValue+=extra;if nextValue then nextValue+=extra end end
  if kind=="Plots" then currentValue=p.MaxPlots;nextValue=currentValue<C.Growth.TotalPlots and math.min(C.Growth.TotalPlots,currentValue+1) or nil end
  local detail=(kind=="LeafPower"and "×"or "")..tostring(currentValue)..(nextValue and " → "..(kind=="LeafPower"and "×"or "")..tostring(nextValue) or " • Fully upgraded")
  table.insert(upgrades,{Key=kind,Title=names[kind],Icon=kind,Detail=detail,Price=price or 0,Owned=not nextValue,Maxed=not nextValue,Action="Buy",Args={Kind=kind}})
 end
 table.insert(upgrades,{Key="Water",Title="Watering Can",Icon="Water",Detail="Water to speed up growth",Price=C.Growth.WaterPrice,Owned=p.Defenses.Water,Action="Buy",Args={Kind="Water"}})
 shopSection("GARDEN UPGRADES",T.Gold,upgrades)
 local eggs={}
 for tier,price in C.Pets.EggPrices do table.insert(eggs,{Key="Egg"..tier,Title=C.Pets.Themes[tier].." Egg",Icon="Egg"..tier,Detail="Tier "..tier.." • Hatch a buddy",Price=price,Action="Egg",Args={Tier=tier}}) end
 local odds={};for rarity,weight in C.Pets.Weights do table.insert(odds,C.Rarities[rarity].Name.." "..weight.."%") end
 shopSection("PETS & EGGS",T.Pink,eggs,"Hatch odds: "..table.concat(odds," • "))
end
local function moreMenu(p)
 local entries={{"Odds","%",T.Gold,"Odds"},{"Ascension","★",T.Purple,"Ascension"},{"Sabotage","⚔",T.Red,"Sabotage"},{"Pets & Eggs","♥",T.Pink,"Pets / Eggs"},{"Passes","+",T.Blue,"Robux"}}
 if p.IsAdmin then table.insert(entries,{"Admin","⚙",T.Teal,"Admin"})end
 local columns=3;local gap=14;local rows=math.ceil(#entries/columns)
 local side=math.floor(math.min(160,(content.AbsoluteSize.X-32)/columns-8,(content.AbsoluteSize.Y-24-gap*(rows-1))/rows))
 side=math.max(44,side)
 local group=Instance.new("Frame");group.Name="MoreGrid";group.Size=UDim2.new(1,-12,0,rows*side+gap*(rows-1));group.BackgroundTransparency=1;group.Parent=content
 local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(side,side);grid.CellPadding=UDim2.fromOffset(gap,gap);grid.HorizontalAlignment=Enum.HorizontalAlignment.Center;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=group
 for index,item in entries do
  local b=button(group,item[1],function()UI.Open(item[4])end);b.Name="More_"..item[4];b.LayoutOrder=index;b.Text="";b.BackgroundColor3=item[3];b.UICorner.CornerRadius=UDim.new(0,20)
  local icon=text(b,item[2],42);icon.Font=Enum.Font.GothamBold;icon.Size=UDim2.fromScale(1,.6);icon.Position=UDim2.fromScale(0,.06);icon.TextColor3=T.Cream;icon.TextStrokeColor3=T.Ink;icon.TextStrokeTransparency=0
  local name=text(b,item[1],18);name.Size=UDim2.fromScale(1,.28);name.Position=UDim2.fromScale(0,.67);name.TextColor3=T.Cream;name.TextStrokeColor3=T.Ink;name.TextStrokeTransparency=0;name.TextScaled=true
  local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=11;limit.MaxTextSize=18;limit.Parent=name
 end
end
local function label(value,color)
 local t=text(content,value,18); t.Size=UDim2.new(1,-8,0,80); t.BackgroundTransparency=0; t.BackgroundColor3=T.Paper; t.TextColor3=T.Ink; decorate(t)
 if color then local accent=Instance.new("Frame"); accent.Size=UDim2.new(0,7,1,-20); accent.Position=UDim2.fromOffset(8,10); accent.BackgroundColor3=color; accent.BorderSizePixel=0; accent.Parent=t; local round=Instance.new("UICorner"); round.CornerRadius=UDim.new(1,0); round.Parent=accent end
 local pad=Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,24); pad.PaddingRight=UDim.new(0,12); pad.Parent=t
 return t
end
function UI.Toast(message)
 local active={};for _,child in toastStack:GetChildren()do if child:IsA("GuiObject")then table.insert(active,child)end end
 while #active>=3 do table.remove(active,1):Destroy()end
 local t=text(toastStack,message,16); t.Size=UDim2.new(1,0,0,60); t.BackgroundColor3=colors.Background; t.BackgroundTransparency=.1; decorate(t)
 task.delay(C.UI.ToastSeconds,function() if t.Parent then t:Destroy() end end)
end
local function comparison(build)
 return string.format("%s • %.0fs grow • %s / fruit • %.1fs drops",C.Rarities[G.Tier(build)].Name,G.BuildTime(build,1),Format(V.Build(build,1,1,1,1)),V.Interval(build))
end
function UI.RenderMenu()
 if UI.Tab~="Shop"and UI.Tab~="More"and UI.Tab~="Robux"then UI.RestoreShopTouch()end
 if not UI.Tab or not UI.State then panel.Visible=false; return end
 panel.ZIndex=UI.Tab=="Robux"and 15 or 1;panel.Visible=true; heading.Text=UI.Tab=="Robux"and "PASSES • DRAFTS"or string.upper(UI.Tab)
 content.ScrollingEnabled=UI.Tab~="More";content.ScrollBarThickness=UI.Tab=="More"and 0 or 8;content.AutomaticCanvasSize=UI.Tab=="More"and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
 if UI.Tab=="More"then
  content.CanvasSize=UDim2.new();local hash=tostring(UI.State.IsAdmin)..":"..tostring(content.AbsoluteSize)
  if UI.MoreHash==hash then return end;UI.MoreHash=hash
 else UI.MoreHash=nil end
 if UI.Tab=="Shop"or UI.Tab=="More"or UI.Tab=="Robux"then local touch=Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui");if touch then if not UI.ShopTouch then UI.ShopTouch={Gui=touch,Enabled=touch.Enabled}end;touch.Enabled=false end end
 if UI.Tab=="Shop" then
  local touch=Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui")
  if touch then if not UI.ShopTouch then UI.ShopTouch={Gui=touch,Enabled=touch.Enabled} end;touch.Enabled=false end
  local p=UI.State;local hash="Shop:"..math.floor(content.AbsoluteSize.X)..":"..math.floor(workspace.CurrentCamera.ViewportSize.X)
  for _,kind in {"LeafPower","Bag","Radius","Discount","Plots","PetSlots","Batch"} do hash..=":"..tostring(p.Upgrades[kind]) end
  for _,kind in {"Scarecrow","Fence","Water"} do hash..=":"..tostring(p.Defenses[kind]) end
  if UI.ShopHash==hash then return end;UI.ShopHash=hash
 else UI.ShopHash=nil end
 if UI.Tab=="Robux"then
  local hash=tostring(content.AbsoluteSize)..":"..tostring(UI.State.PaidRandom)..":"..tostring(UI.State.MaxGrowthPads)
  for _,key in C.PassOrder do hash..=":"..tostring(UI.State.Passes[key])end
  hash..=":"..tostring(UI.State.Journal.Version)..":"..tostring(UI.State.ProductsOwned.StarterPack)..":"..tostring(UI.State.RewardState.Reference)
  if UI.PurchaseHash==hash then return end;UI.PurchaseHash=hash
 else UI.PurchaseHash=nil end
 local savedScroll=content.CanvasPosition
 for _,child in content:GetChildren() do if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end end
 local p=UI.State
 if UI.Tab=="More"then moreMenu(p)
 elseif UI.Tab=="Shop"then
  shopCatalog(p)
 elseif UI.Tab=="Sell" then
  label("Step into the red SELL zone at the market. Your fruit is worth "..Format(p.Bag.Value).." coins!")
  row("Open Sell panel",function()UI.Open("Sell")end)
 elseif UI.Tab=="Upgrades" then
  local names={LeafPower="Leaf Power",Bag="Bigger Bag",Radius="Fruit Magnet",Discount="Cheaper Rolls",Plots="More Tree Plots",PetSlots="More Pet Buddies",Batch="Multi Roll"}
  for _,kind in {"LeafPower","Bag","Radius","Discount","Plots","PetSlots","Batch"} do local up=C.Upgrades[kind]; local level=p.Upgrades[kind] or 1
   if up.Values[level+1] then row(names[kind].." → "..(kind=="LeafPower"and "×"or "")..up.Values[level+1].." • "..Format(up.Prices and up.Prices[level] or up.BasePrice*up.PriceGrowth^(level-1)).." coins",function() send("Buy",{Kind=kind}) end) else label(names[kind].." • MAX") end
  end
  row("Watering Can • "..Format(C.Growth.WaterPrice).." coins",function() send("Buy",{Kind="Water"}) end)
 elseif UI.Tab=="Pets / Eggs" then
  label("Egg odds: 60%, 25%, 10%, 4%, 1%. Current pet capacity: "..(p.MaxPetSlots or 3)..". Orchard Curator adds one permanent slot. Fuse three identical pets for 2× stats.")
  for tier,price in C.Pets.EggPrices do row(C.Pets.Themes[tier].." egg • "..Format(price).." coins",function() send("Egg",{Tier=tier}) end) end
  for _,pet in p.Pets do
   row((pet.Shiny and "Shiny " or "")..pet.Name..(table.find(p.EquippedPets,pet.Id) and " • EQUIPPED" or " • Equip"),function() send("EquipPet",{Id=pet.Id}) end)
   if not pet.Shiny then row("Fuse three "..pet.Name,function() send("Fuse",{Id=pet.Id}) end) end
  end
 elseif UI.Tab=="Odds" then
  label("Real current odds • luck "..string.format("%.2f",p.Luck).."×\nPity: Epic+ "..p.EpicPity.."/50 • Legendary+ "..p.LegendaryPity.."/300")
  label("Earned collection rarity luck: ×"..string.format("%.2f",p.CollectionBonuses and p.CollectionBonuses.Luck or 1).." (included above; max +4%). It does not affect mutations or eggs.")
  local min=R.Minimum(p)
  if p.PaidRandom then
   label("Draft purchase previews for this next roll, including current pity. Lucky products replace the boost factor and extend its time. Mutation and egg odds stay unchanged.")
   for _,key in {"Luck","SuperLucky","UltraLucky"}do
    local luck=p.PurchaseLuck[key];local future,total=R.Weights(luck,min);local lines={(C.Passes[key]or C.Products[key]).Name.." • preview luck "..string.format("%.3f",luck).."×"}
    for i,r in C.Rarities do table.insert(lines,r.Name.." "..string.format("%.5f",future[i]/total*100).."%")end
    local preview=label(table.concat(lines,"\n"),T.Blue);preview.Size=UDim2.new(1,-8,0,210)
   end
  end
  local weights,total=R.Weights(p.Luck,min)
  for i,r in C.Rarities do label(string.format("%s • base %g%% • next roll %.5f%%\nGrows in %ds • stats %.2f–%.2f",r.Name,r.Weight,weights[i]/total*100,r.Grow,r.Min,r.Max),r.Color) end
  label("Your third lifetime roll guarantees Rare or better. Daily free rolls use the same pity and odds. Each rarity has 12 equally likely named parts; each specific name has one twelfth of its rarity chance.")
  label("Each part roll and each harvested fruit independently rolls a mutation. Part choices within each type and rarity are equally likely.")
  label("Part mutation factors are averaged, multiplied by the harvest factor, then capped at ×"..C.Economy.MutationCeiling.." combined. Listed factors are raw before this cap. Height varies from 75% to 150% when planting.")
  label("Rarity power: ×"..C.Economy.RarityFactor.." per tier on Fruit, Leaves and Trunk. Leaf Power multiplies total value. Roots use rarity-based drop intervals; mixed build grow time also weights its highest tier.")
  label("Harvest sizes are separate from mutations. Pets, rarity luck and paid luck do not change size odds. Size multiplies after the mutation ceiling, before Double Coins; expected size value is exactly x1.")
  for _,size in C.FruitSizes do label(size.Name.." - "..size.Weight.."% - value x"..size.Value.." - visual x"..size.Scale,T.Gold)end
  local mutationWeights,mutationTotal=R.MutationWeights(p.MutationLuck or 1)
  for i,m in C.Mutations do label(m.Name.." • base "..m.Weight.."% • current "..string.format("%.5f",mutationWeights[i]/mutationTotal*100).."% • "..m.Mult.."× raw (combined cap ×"..C.Economy.MutationCeiling..")",m.Color)end
 elseif UI.Tab=="Settings" then
  for _,key in {"Music","SFX","Chill","ReducedShake","ReducedEffects","SkipRolls","AutoSell","QuickSellOnEntry"} do row((key=="QuickSellOnEntry"and "Quick sell on entry"or key)..": "..tostring(p.Settings[key]),function() send("Setting",{Key=key,Value=not p.Settings[key]}) end) end
  for _,key in {"MusicVolume","SFXVolume"}do for _,volume in {0,.25,.5,.75,1}do row(key..": "..math.floor(volume*100).."%",function()send("Setting",{Key=key,Value=volume})end)end end
  label("Optional cumulative in-game prompt budget. 0 = no self-imposed limit. Roblox account spending controls also apply.")
  for _,limit in {0,100,500,1000} do row("Prompt budget: "..limit.." Robux",function() send("Setting",{Key="SpendingLimit",Value=limit}) end) end
  row("Skip tutorial",function() send("Tutorial",{Skip=true}) end)
 elseif UI.Tab=="Robux" then
  heading.Text="PASSES • DRAFTS"
  label("All prices are proposals. Purchases are disabled; every Marketplace ID is 0. Core progression stays free.",T.Gold)
  if not p.PaidRandom then label("Paid gameplay items are unavailable for this account. Cosmetic-only items and earned progression remain available.")end
  row("Exact current and preview Odds • before any purchase",function()UI.Open("Odds")end)
  local function section(title,keys,source,action,color)
   local caption=text(content,title,23);caption.Size=UDim2.new(1,-8,0,38);caption.TextXAlignment=Enum.TextXAlignment.Left
   local width=math.max(140,content.AbsoluteSize.X-24);local vp=workspace.CurrentCamera.ViewportSize
   local columns=vp.X<650 and 1 or(vp.X<1000 and 2 or 3)
   local side=math.min(350,math.max(170,math.floor(content.AbsoluteSize.Y-16)),math.floor((width-14*(columns-1))/columns))
   local group=Instance.new("Frame");group.Name=title;group.BackgroundTransparency=1;group.LayoutOrder=#content:GetChildren();group.Size=UDim2.new(1,-12,0,math.ceil(#keys/columns)*(side+14));group.Parent=content
   local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.fromOffset(side,side);grid.CellPadding=UDim2.fromOffset(14,14);grid.HorizontalAlignment=Enum.HorizontalAlignment.Center;grid.SortOrder=Enum.SortOrder.LayoutOrder;grid.Parent=group
   for i,key in keys do
    local id=key;local item=source[id];local owned=action=="Pass"and p.Passes[id]or(item.Once and p.ProductsOwned[id]);local restricted=item.PaidRandom and not p.PaidRandom
    local earned=id=="ThirdPad"and(p.MaxGrowthPads or 1)>=3
    if id=="Cosmetics"then local all=true;for _,key in C.Cosmetics.Bundle do if not p.Journal.Cosmetics.Owned[key]then all=false end end;earned=all end
    local tile=button(group,"",function()
     if owned or earned then UI.Toast("Already owned or earned.")
     elseif restricted then UI.Toast("Unavailable for this account. Free progression stays available.")
     elseif item.Limit then send("GrowNow",{})else send(action,{Key=id})end
    end)
    tile.Name="PurchaseTile_"..id;tile.LayoutOrder=i;tile:SetAttribute("PurchaseKey",id);tile:SetAttribute("Restricted",restricted);tile.BackgroundColor3=(owned or earned)and T.Teal or color
    local name=text(tile,item.Name,24);name.Name="ItemTitle";name.Position=UDim2.fromScale(.035,.03);name.Size=UDim2.fromScale(.93,.16);name.TextColor3=T.Cream;name.TextStrokeColor3=T.Ink;name.TextStrokeTransparency=0;name.TextScaled=true
    local n=Instance.new("UITextSizeConstraint");n.MinTextSize=14;n.MaxTextSize=24;n.Parent=name
    local description=item.Description or("Finishes the first eligible active tree with ≤"..math.floor(item.Limit/60).." min remaining, across all pads. Changed tree → reusable credit. Free: wait or water.")
    if item.Seconds then description..=" Current server reference quote: "..Format(math.floor(math.min(item.Cap,(p.RewardState.Reference or 0)*item.Seconds))).." coins."end
    local detail=text(tile,description,17);detail.Name="ExactEffect";detail.BackgroundTransparency=0;detail.BackgroundColor3=T.Cream;detail.Position=UDim2.fromScale(.04,.22);detail.Size=UDim2.fromScale(.92,.54);detail.TextScaled=true
    local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,12);corner.Parent=detail
    local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,8);pad.PaddingRight=UDim.new(0,8);pad.PaddingTop=UDim.new(0,8);pad.PaddingBottom=UDim.new(0,8);pad.Parent=detail
    local d=Instance.new("UITextSizeConstraint");d.MinTextSize=12;d.MaxTextSize=17;d.Parent=detail
    local status=(owned or earned)and "OWNED / EARNED"or(restricted and "UNAVAILABLE FOR ACCOUNT"or("DRAFT • "..item.ProposedPrice.." Robux"))
    local price=text(tile,status.."\n"..((owned or earned)and "Journal → Style for cosmetics"or "Not configured • no charge"),16);price.Name="DraftPrice";price.Position=UDim2.fromScale(.03,.79);price.Size=UDim2.fromScale(.94,.18);price.TextScaled=true;price.TextColor3=T.Cream;price.TextStrokeColor3=T.Ink;price.TextStrokeTransparency=0
    local pc=Instance.new("UITextSizeConstraint");pc.MinTextSize=11;pc.MaxTextSize=16;pc.Parent=price
   end
  end
  section("LASTING PASSES",C.PassOrder,C.Passes,"Pass",T.Blue)
  section("OPTIONAL PRODUCTS",C.ProductOrder,C.Products,"Product",T.Purple)
  label("Coin amounts use server reward reference income, excluding paid, pet and weather boosts. Starter Pack locks its quote before the prompt. Luck products use exact current Odds.")
  section("GROW NOW BRACKETS",C.GrowProducts,C.Products,"Product",T.Green)
  row("Use a saved growth credit",function()send("RedeemGrow",{})end)
  row("Cosmetic inventory • Journal → Style",function()UI.Open("Tree Parts");UI.Inventory.Category="Journal";UI.Inventory.Journal.Tab="Style";UI.Inventory:Refresh(true)end)
 elseif UI.Tab=="Ascension" then
  label("Ascend at "..Format(p.AscensionThreshold or C.Rebirth.Threshold).." coins. Preview: +"..p.Preview.." Golden Saplings (each +"..(C.Math.RebirthPerSapling*100).."% base income).\nResets coins, parts and plots. Keep pets, permanent bonuses and purchases.",colors.Gold)
  row("Confirm Ascension • reset this garden",function() send("Rebirth",{Confirm=true}) end)
 elseif UI.Tab=="Sabotage" then
  row("Chill: "..(p.Settings.Chill and "ON • peaceful garden"or "OFF • sabotage enabled").." • Toggle",function()send("Setting",{Key="Chill",Value=not p.Settings.Chill})end)
  if not p.Settings.Chill then
   local names={Scarecrow="Scarecrow",BugSpray="Bug Spray",Fence="Electric Fence",Shield="Shield Bubble"}
   for _,kind in {"Scarecrow","BugSpray","Fence","Shield"}do local key=kind
    row(names[key].." • "..Format(C.Defenses[key]).." coins"..((key=="Scarecrow"or key=="Fence")and p.Defenses[key]and " • OWNED"or ""),function()send("Buy",{Kind=key})end)
   end
  else label("Turn Chill off to view sabotage defenses. Peaceful progression remains free.")end
  label(p.Private and "Private gardens have sabotage disabled, +10% luck and +25% growth." or "Chill Mode must be off for both players. Actions require proximity and respect protection.")
  for _,player in Players:GetPlayers() do if not p.Settings.Chill and player~=Players.LocalPlayer then
   label(player.DisplayName)
   for _,kind in {"Shake","Pest","Trap","Prune"} do row(kind.." "..player.DisplayName,function() send("Sabotage",{Target=player.UserId,Kind=kind}) end) end
  end end
 end
 task.defer(function() content.CanvasPosition=savedScroll end)
end
function UI.RestoreShopTouch()
 if UI.ShopTouch then if UI.ShopTouch.Gui.Parent then UI.ShopTouch.Gui.Enabled=UI.ShopTouch.Enabled end;UI.ShopTouch=nil end
end
function UI.Open(tab)
 if UI.RollDisplay then UI.RollDisplay.Summary.Visible=false end
 if UI.SellPanel then UI.SellPanel:Close()end
 if UI.Placement and UI.Placement.Selection then UI.Placement:Clear();send("CancelPlacement",{})end
 UI.RestoreShopTouch()
 if UI.Admin then UI.Admin:Close()end
 if tab=="Admin"then
  UI.Tab=nil;panel.Visible=false;if UI.Inventory then UI.Inventory:Close()end
  if UI.State and UI.State.IsAdmin and UI.Admin then UI.Admin:Open()end;return
 end
 if tab=="Sell"then
  UI.Tab=nil;panel.Visible=false;if UI.Inventory then UI.Inventory:Close()end;UI.SellPanel:Open();return
 end
 UI.ShopHash=nil
 UI.MoreHash=nil
 UI.PurchaseHash=nil
 if tab=="Garden" then tab="Tree Parts" end
 if UI.Inventory then
  if tab=="Tree Parts" or tab=="Bag" then UI.Tab=nil; panel.Visible=false; UI.Inventory:Open(tab=="Bag" and "Bag" or "Parts"); return end
  UI.Inventory:Close()
 end
 UI.Tab=tab; content.CanvasPosition=Vector2.zero;if UI.ResizeMenu then UI.ResizeMenu() end;UI.RenderMenu()
end
function UI.Travel(destination)
 if UI.RollDisplay then UI.RollDisplay.Summary.Visible=false end
 if UI.SellPanel then UI.SellPanel:Close()end
 if UI.Placement and UI.Placement.Selection then UI.Placement:Clear();send("CancelPlacement",{})end
 UI.RestoreShopTouch()
 if UI.Admin then UI.Admin:Close()end
 UI.Tab=nil; panel.Visible=false; if UI.Inventory then UI.Inventory:Close() end
 send("Teleport",{Destination=destination})
end
function UI.Reel(results)
 UI.SeenRoll=true;UI.RollDisplay:Push(results)
end
function UI.ReturnSummary(data)
 local old=gui:FindFirstChild("OfflineReturn");if old then old:Destroy()end
 local box=Instance.new("Frame");box.Name="OfflineReturn";box.AnchorPoint=Vector2.new(.5,.5);box.Position=UDim2.fromScale(.5,.5);box.Size=UDim2.new(.88,0,.58,0);box.BackgroundColor3=T.Cream;box.ZIndex=35;box.Parent=gui;decorate(box)
 local limit=Instance.new("UISizeConstraint");limit.MaxSize=Vector2.new(500,300);limit.Parent=box
 local message=text(box,"WELCOME BACK!\nWhile you were away: +"..Format(data.Coins).." coins\n"..data.Ready.." trees ready to place\nOffline earnings cap: "..math.floor(data.Cap/3600).." hours",23);message.Size=UDim2.new(.9,0,.70,0);message.Position=UDim2.fromScale(.05,.03);message.TextScaled=true;message.ZIndex=36
 local done=button(box,"LET'S GROW",function()box:Destroy()end);done.Size=UDim2.new(.8,0,0,48);done.Position=UDim2.new(.1,0,1,-58);done.ZIndex=36;done.BackgroundColor3=T.Green
end
function UI.Update(state)
 UI.State=state;if UI.RollDisplay then UI.RollDisplay:Update(state)end;if UI.SellPanel then UI.SellPanel:Update(state)end;Effects.Update(state); Effects.Radius=state.Radius
 if UI.Admin then UI.Admin:Update(state)end
 if UI.Hud then UI.Hud:Update(state)end
 if UI.Placement then UI.Placement:Update(state)end
 if UI.Inventory then UI.Inventory:Update(state) end
 coins.Text=Format(state.Coins).." COINS\n+"..Format(state.Income).." base / sec"
 bag.Text="BAG "..state.Bag.Count.." / "..tostring(state.Capacity).."\n"..Format(state.Bag.Value).." coins of fruit"
 local full=type(state.Capacity)=="number" and state.Bag.Count>=state.Capacity
 bag.TextColor3=T.Cream; bag.BackgroundColor3=full and T.Red or T.Blue; if full then bag.Text="BAG FULL! Visit SELL" end
 local compact=workspace.CurrentCamera.ViewportSize.X<650
 local count=math.max(1,state.RollCount or 1);local cost=(state.RollCount or 0)>0 and state.RollTotalCost or state.RollCost
 roll.Text="ROLL ×"..count.."\n"..Format(cost)..(compact and ""or " coins")
 plant.Text=state.Growth and (state.Growth.State=="Ready" and "TREE READY" or "GROWING • "..math.ceil(G.Remaining(state.Growth)).."s") or "PLANT TREE"
 if compact then plant.Text=state.Growth and (state.Growth.State=="Ready" and "READY!" or "GROW\n"..math.ceil(G.Remaining(state.Growth)).."s") or "PLANT\nTREE" end
 plant.Text=compact and "PARTS" or "TREE PARTS"
 eventLabel.Text=state.Event.Name and (state.Event.Name.." • "..math.max(0,state.Event.Ends-os.time()).."s"..(state.Event.Name=="Giant Pest Raid" and " • Click bugs at market!" or "")) or "Plant a little. Grow a lot!"
 local steps={"↓ Roll your first part! Third roll: Rare+ guaranteed.","Open TREE PARTS and equip your rolled part.","In TREE PARTS, tap PLANT TREE.","Hold E at the ready growth tree, then select a plot.","Walk near your trees to collect fruit.","Click SELL to sell your fruit.","Visit SHOP and buy Leaf Power (25 coins).","Unlock another Tree Plot at SHOP.",""}
 tutorial.Text=steps[state.Onboarding or 9]or "";tutorial.Visible=(state.Onboarding or 9)<9
 local showFull=fullWarning and os.clock()<(UI.FullWarningUntil or 0) and full
 if fullWarning then fullWarning.Visible=showFull; fullArrow.Visible=showFull; if showFull then eventLabel.Visible=false; tutorial.Visible=false else eventLabel.Visible=true end end
 UI.RenderMenu()
end
function UI.Start(network)
 UI.Network=network
 gui=Instance.new("ScreenGui"); gui.Name="BuildATreeHUD"; gui.ResetOnSpawn=false; gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets; gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
 coins=text(gui,"Your garden is loading...",23); coins.Name="Coins"; coins.BackgroundColor3=T.Gold; coins.BackgroundTransparency=0; decorate(coins)
 bag=button(gui,"Bag",function() UI.Open("Bag") end); bag.Name="Bag"; bag.BackgroundColor3=T.Blue
 nav=Instance.new("Frame"); nav.Name="TopNavigation"; nav.BackgroundTransparency=1; nav.Parent=gui
 local navGrid=Instance.new("UIGridLayout"); navGrid.SortOrder=Enum.SortOrder.LayoutOrder; navGrid.CellSize=UDim2.new(.32,0,1,-5); navGrid.CellPadding=UDim2.fromScale(.015,0); navGrid.Parent=nav
 local shopNav=button(nav,"SHOP",function() UI.Travel("Shop") end); shopNav.Name="ShopTeleport"; shopNav.BackgroundColor3=T.Blue
 local gardenNav=button(nav,"GARDEN",function() UI.Travel("Garden") end); gardenNav.Name="GardenTeleport"; gardenNav.BackgroundColor3=T.Green
 sellNav=button(nav,"SELL",function() UI.Travel("Sell") end); sellNav.Name="SellTeleport"; sellNav.BackgroundColor3=T.Red
 fullArrow=text(sellNav,"▲",32); fullArrow.TextColor3=T.Red; fullArrow.Name="SellArrow"; fullArrow.AnchorPoint=Vector2.new(.5,0); fullArrow.Position=UDim2.new(.5,0,1,6); fullArrow.Size=UDim2.fromOffset(46,38); fullArrow.TextStrokeColor3=T.Cream; fullArrow.TextStrokeTransparency=0; fullArrow.Visible=false; fullArrow.ZIndex=20
 Tween:Create(fullArrow,TweenInfo.new(.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Position=UDim2.new(.5,0,1,18)}):Play()
 fullWarning=text(gui,"BAG FULL! CLICK SELL!",25); fullWarning.TextColor3=T.Red; fullWarning.Name="BagFullWarning"; fullWarning.TextStrokeColor3=T.Cream; fullWarning.TextStrokeTransparency=0; fullWarning.Visible=false; fullWarning.ZIndex=20
 eventLabel=text(gui,"",17); eventLabel.Name="EventLabel"; eventLabel.TextColor3=T.Cream; eventLabel.TextStrokeColor3=T.Ink; eventLabel.TextStrokeTransparency=0
 tutorial=text(gui,"",19);tutorial.Name="TutorialHint"; tutorial.TextColor3=T.Cream; tutorial.TextStrokeColor3=T.Ink; tutorial.TextStrokeTransparency=0
 footer=Instance.new("Frame"); footer.Name="PrimaryActions"; footer.BackgroundTransparency=1; footer.Parent=gui
 local grid=Instance.new("UIGridLayout"); grid.SortOrder=Enum.SortOrder.LayoutOrder; grid.CellSize=UDim2.new(.32,0,1,-6); grid.CellPadding=UDim2.fromScale(.015,0); grid.Parent=footer
 roll=button(footer,"ROLL",function() if not UI.RollDisplay or not UI.RollDisplay.Busy then send("Roll",{}) end end); roll.BackgroundColor3=T.Gold; roll.TextSize=24; roll.TextScaled=true
 local rollTextSize=Instance.new("UITextSizeConstraint"); rollTextSize.MinTextSize=12; rollTextSize.MaxTextSize=24; rollTextSize.Parent=roll
 plant=button(footer,"TREE PARTS",function() UI.Open("Tree Parts") end); plant.Name="TreePartsButton"; plant.BackgroundColor3=T.Green
 button(footer,"MORE",function() UI.Open("More") end).BackgroundColor3=T.Teal
 local function responsive()
  local vp=workspace.CurrentCamera.ViewportSize
  local mobile=game:GetService("UserInputService").TouchEnabled or vp.X<700 or vp.Y<500
  local stacked=vp.X<650
  nav.Position=UDim2.new(stacked and .04 or .27,0,0,8); nav.Size=UDim2.new(stacked and .92 or .46,0,0,mobile and 50 or 58)
  coins.Position=UDim2.new(stacked and .04 or .02,0,0,stacked and 65 or 8); coins.Size=UDim2.new(stacked and .44 or .22,0,0,56)
  bag.Position=UDim2.new(stacked and .52 or .76,0,0,stacked and 65 or 8); bag.Size=UDim2.new(stacked and .44 or .22,0,0,56)
  coins.TextSize=mobile and 18 or 23; bag.TextSize=mobile and 17 or 21
  eventLabel.Position=UDim2.new(.15,0,0,stacked and 127 or 78); eventLabel.Size=UDim2.new(.7,0,0,26)
  tutorial.Position=UDim2.new(.1,0,0,stacked and 155 or 110); tutorial.Size=UDim2.new(.8,0,0,32)
  fullWarning.Position=UDim2.new(.05,0,0,stacked and 127 or 78); fullWarning.Size=UDim2.new(.90,0,0,56); fullWarning.TextSize=stacked and 21 or 25
  footer.Size=UDim2.new(mobile and .56 or .5,0,0,mobile and 64 or 80)
  footer.Position=UDim2.new(mobile and .22 or .25,0,1,mobile and -76 or -96)
  roll.TextSize=mobile and 18 or 24; plant.TextSize=mobile and 16 or 21
  if panel then
   if UI.Tab=="More"then
    local area=gui.AbsoluteSize;local w=math.min(area.X*.90,620);local tile=math.min(160,(w*.95-32)/3-8);local h=math.min(area.Y*.9,430,tile*2+114);panel.Size=UDim2.fromOffset(w,h);panel.Position=UDim2.new(.5,-w/2,.5,-h/2)
   elseif UI.Tab=="Robux"then panel.Size=UDim2.new(.94,0,1,-20);panel.Position=UDim2.fromScale(.03,.01)
   elseif mobile and UI.Tab=="Shop"then panel.Size=UDim2.new(.94,0,1,-20);panel.Position=UDim2.fromScale(.03,.01)
   else panel.Size=mobile and UDim2.new(.92,0,1,-100) or UDim2.fromScale(.7,.65);panel.Position=UDim2.fromScale(mobile and .04 or .15,mobile and .01 or .16) end
  end
 end
 UI.ResizeMenu=responsive
 workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive); responsive()

 toastStack=Instance.new("Frame"); toastStack.BackgroundTransparency=1; toastStack.AnchorPoint=Vector2.new(.5,0); toastStack.Position=UDim2.fromScale(.5,.3); toastStack.Size=UDim2.fromScale(.86,.3); toastStack.Parent=gui
 local toastSize=Instance.new("UISizeConstraint"); toastSize.MaxSize=Vector2.new(560,250); toastSize.Parent=toastStack
 local stack=Instance.new("UIListLayout"); stack.Padding=UDim.new(0,6); stack.Parent=toastStack
 panel=Instance.new("Frame"); panel.Name="Menu"; panel.Size=UDim2.fromScale(.9,.62); panel.Position=UDim2.fromScale(.05,.18); panel.BackgroundColor3=colors.Background; panel.Visible=false; panel.Parent=gui; decorate(panel)
 heading=text(panel,"Garden",28); heading.Size=UDim2.new(1,-78,0,48); heading.Position=UDim2.fromOffset(10,8); heading.BackgroundTransparency=0; heading.BackgroundColor3=T.Green; heading.TextColor3=T.Cream; heading.TextStrokeColor3=T.Ink; heading.TextStrokeTransparency=0; decorate(heading)
 local close=button(panel,"×",function() UI.RestoreShopTouch();UI.Tab=nil;panel.Visible=false end);close.Size=UDim2.fromOffset(48,48);close.Position=UDim2.new(1,-58,0,8);close.BackgroundColor3=T.Red;close.TextSize=30
 content=Instance.new("ScrollingFrame"); content.Position=UDim2.new(.025,0,0,70); content.Size=UDim2.new(.95,0,1,-80); content.BackgroundTransparency=1; content.BorderSizePixel=0; content.ScrollBarThickness=7; content.ScrollBarImageColor3=T.Wood; content.AutomaticCanvasSize=Enum.AutomaticSize.Y; content.CanvasSize=UDim2.new(); content.Parent=panel
 content.ScrollingDirection=Enum.ScrollingDirection.Y;content.ScrollBarThickness=8
 local list=Instance.new("UIListLayout"); list.SortOrder=Enum.SortOrder.LayoutOrder; list.Padding=UDim.new(0,12); list.Parent=content
 local padding=Instance.new("UIPadding"); padding.PaddingTop=UDim.new(0,5); padding.PaddingLeft=UDim.new(0,5); padding.PaddingRight=UDim.new(0,5); padding.PaddingBottom=UDim.new(0,5); padding.Parent=content
 content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()if UI.Tab=="Shop"or UI.Tab=="More"or UI.Tab=="Robux"then UI.ShopHash=nil;UI.MoreHash=nil;task.defer(UI.RenderMenu)end end)
 UI.RollDisplay=RollController.new(gui);if UI.State then UI.RollDisplay:Update(UI.State)end
 network.State.OnClientEvent:Connect(UI.Update)
 network.Feedback.OnClientEvent:Connect(function(kind,data)
  if kind=="AdminResult"then if UI.Admin then UI.Admin:Result(data)end
  elseif kind=="Roll" then task.spawn(UI.Reel,data)
  elseif kind=="Collect" then Effects.Collect(data,gui)
  elseif kind=="Sell" then Effects.Float(data.Position,data.Value);Effects.Sound("Sell"); Effects.Burst(data.Position,colors.Gold,40); UI.Toast("Sold for +"..Format(data.Value).." coins")
  elseif kind=="OfflineSummary"then UI.ReturnSummary(data)
  elseif kind=="Ready" then Effects.Sound("Ready"); UI.Toast("Your tree is ready! Hold E near it to choose a plot.")
  elseif kind=="SelectPlot"then UI.Tab=nil;panel.Visible=false;UI.Inventory:Close();if UI.Admin then UI.Admin:Close()end;UI.RestoreShopTouch();UI.Placement:Begin(data)
  elseif kind=="TreeInfo"then UI.Open("Tree Parts");UI.Inventory.Category="Garden";UI.Inventory.SelectedTreeId=data.TreeId;UI.Inventory:Refresh(true)
  elseif kind=="ConfirmSalvage"then UI.Placement:ConfirmSalvage(data)
  elseif kind=="ConfirmReplacement"then UI.Placement:Confirm(data)
  elseif kind=="PlacementDone"then UI.Placement:Clear()
  elseif kind=="BagFull" then UI.FullWarningUntil=os.clock()+C.Inventory.FullWarningSeconds; if UI.State then UI.Update(UI.State) end
  elseif kind=="SellPanel"then UI.Open("Sell")
  elseif kind=="SaleResult"then if UI.SellPanel then UI.SellPanel:Result(data)end
  elseif kind=="GiantFruit"then Effects.Giant(data)
  elseif kind=="Shop" then UI.Open("Shop")
  elseif kind=="Revenge" then UI.Toast(data.Text); UI.Open("Sabotage")
  else UI.Toast(tostring(data)) end
 end)
 UI.Inventory=InventoryController.new(gui,send)
 UI.Admin=AdminController.new(gui,send,function()UI.Open("Admin")end,function()UI.Open("Tree Parts")end)
 UI.Placement=PlotController.new(gui,send)
 UI.SellPanel=SellController.new(gui,send,UI.Toast);if UI.State then UI.SellPanel:Update(UI.State)end
 UI.Hud=HudControls.new(gui,roll,function()UI.Open("Settings")end,function()send("AutoRoll",{})end,function()UI.Travel("Garden")end)
 Effects.Start()
 responsive()
end
return UI
