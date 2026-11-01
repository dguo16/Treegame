-- Studio-only reversible smoke test against the running services; no durable writes or real charges.
local S=game:GetService("ReplicatedStorage").BuildATree
local P=require(S.Util.Profile)
local C=require(S.Config)
local Growth=require(game.ServerScriptService.BuildATree.Services.GrowthService)
local Catalog=require(S.Util.PartCatalog)
local G=require(S.Util.GrowthCalculator)
local Integration={}
-- Whole-tree workbench edits intentionally override standardized Clover geometry.
local function canopyHeight(build,height)
 local editor=S:FindFirstChild("StarterTreeEditor")or workspace:FindFirstChild("StarterTreeEditor")
 if build.Leaves.Name~="Clover"or build.Leaves.Tier~=1 or not editor then return height end
 local origin=editor.EditorOrigin.CFrame;local top=-math.huge
 for _,part in editor.Leaves:GetDescendants()do if part:IsA("BasePart")then
  for _,x in {-1,1}do for _,y in {-1,1}do for _,z in {-1,1}do
   local point=origin:PointToObjectSpace(part.CFrame:PointToWorldSpace(part.Size*Vector3.new(x,y,z)/2));top=math.max(top,point.Y)
  end end end
 end end
 return top*height/editor.ReferenceHeight.Value
end
function Integration.Run(Game,D,W,player)
 local s=D.Sessions[player]; assert(s and not s.Busy,"Wait for profile load")
 local original=s.Profile; local previousRuntime=P.Copy(Game.Runtime[player]);local previousRollAt=Game.Runtime[player].RollAt
 local character=player.Character; local previousPosition=character and character:GetPivot()
 local checks=0
 local function check(v,msg) assert(v,msg); checks+=1 end
 local ok,err=pcall(function()
  local p=P.New(os.time()); p.Upgrades.LeafPower=1; p.Coins=1000
  p.Plots={{Build=P.Starter(),State="Producing",NextDrop=os.time()}}; s.Profile=p
  Game.Runtime[player].RollAt=0
  check(Game.Roll(player,false),"Roll works")
  check(#p.Parts==1 and p.Coins<1000,"Roll charged and stored")
  check(Game.Intent(player,"Equip",{Id=p.Parts[1].Id}),"Equip works")
  check(Game.Intent(player,"Plant",{}),"Plant works")
  check(p.Plots[1].State=="Producing" and p.Growth~=nil,"No dead time on Plant")
  check(not Growth.Swap(p,1,1,os.time()),"Growing swap rejected")
  Growth.Finish(p)
  p.Upgrades.Plots=2;character:PivotTo(CFrame.new(W.Gardens[player].Pads[7].Position+Vector3.new(0,3,0)))
  check(Game.BeginPlacement(player),"Ready tree starts owner plot selection")
  local growthId=p.Growth.Id;local heightScale=p.Growth.HeightScale
  check(not Game.PlaceTree(player,1,growthId),"Occupied plot requires confirmation")
  check(Game.Runtime[player].Placement.Confirmation~=nil,"Server issues replacement confirmation token")
  check(not Game.PlaceTree(player,1,growthId,"forged"),"Forged confirmation rejected")
  check(Game.Intent(player,"PlaceTree",{Plot=2,GrowthId=growthId}),"Ready tree plants in selected empty plot")
  check(p.Growth==nil and #p.Plots==2 and p.Plots[1].State=="Producing","Placement retained original producing tree")
  check(p.Plots[2].HeightScale==heightScale,"Live placement preserves height")
  local tree=W.Tree(player,2,p.Plots[2].Build,"Producing",1,heightScale)
  check(math.abs(tree:GetAttribute("Height")-G.Height(p.Plots[2].Build,heightScale))<1e-6,"World and recorded tree height agree")
  local boundsCF,bounds=tree:GetBoundingBox();check(math.abs(boundsCF.Position.Y+bounds.Y/2-tree:GetAttribute("BasePosition").Y-canopyHeight(p.Plots[2].Build,tree:GetAttribute("Height")))<.1,"Rendered canopy honors editable reference placement")
  -- Exercise actual server capability consumption and per-plot fruit cleanup.
  p.Growth=Growth.New(p.Equipped,os.time(),false);Growth.Finish(p)
  character:PivotTo(CFrame.new(W.Gardens[player].Pads[7].Position+Vector3.new(0,3,0)))
  check(Game.BeginPlacement(player),"Replacement selection begins with occupied plots")
  local replacementId=p.Growth.Id
  local oldFruit=W.SpawnFruit(player,1,3,C.Mutations[1],os.time())
  local otherFruit=W.SpawnFruit(player,2,3,C.Mutations[1],os.time())
  check(not Game.PlaceTree(player,1,replacementId),"Replacement only offers confirmation")
  local token=Game.Runtime[player].Placement.Confirmation.Token
  check(Game.Intent(player,"ReplaceTree",{Plot=1,GrowthId=replacementId,Token=token}),"Server confirmation replaces owned tree")
  check(W.Fruit[oldFruit]==nil and W.Fruit[otherFruit]~=nil,"Only replaced plot's pending fruit is cleaned up")
  local partCount=#p.Parts
  check(not Game.PlaceTree(player,1,replacementId,token) and #p.Parts==partCount,"Replayed/concurrent confirmation cannot grant twice")
  p.Coins=1e9;p.Upgrades.Plots=4
  check(Game.Buy(player,"Plots") and Game.MaxPlots(p)==5,"Plot five can be bought")
  check(Game.Buy(player,"Plots") and Game.MaxPlots(p)==6,"Plot six can be bought")
  local balance=p.Coins;check(not Game.Buy(player,"Plots") and p.Coins==balance,"Seventh plot cannot be bought or charged")
  check(W.Gardens[player].Pads[6]~=nil and W.Gardens[player].Pads[8]~=nil and W.Gardens[player].Pads[9]==nil,"Garden has six production pads and two growth pads")
  character:PivotTo(CFrame.new(W.Shop+Vector3.new(0,0,3)))
  p.Bag={Count=2,Value=5}; local before=p.Coins
  check(Game.Sell(player),"Sell works in range")
  check(p.Coins==before+5 and p.Bag.Count==0,"Sale matches authoritative contents")
  check(not Game.Sell(player),"Cannot sell twice")
  p.Coins=1000; check(Game.Buy(player,"Bag"),"Bag upgrade works")
  check(Game.Buy(player,"LeafPower"),"Leaf power upgrade works")
  local mutation=C.Mutations[1]; local fruit=W.SpawnFruit(player,1,3,mutation,os.time())
  check(fruit~=nil,"Pooled fruit spawned")
  check(W.Fruit[fruit].ReadyAt>W.Fruit[fruit].Born,"Falling fruit is not collectible before landing")
  if W.Fruit[fruit].Tween then W.Fruit[fruit].Tween:Cancel(); W.Fruit[fruit].Tween:Destroy(); W.Fruit[fruit].Tween=nil end
  W.Fruit[fruit].ReadyAt=0
  fruit.Position=character.HumanoidRootPart.Position
  local count=p.Bag.Count; Game.Pickup(); check(p.Bag.Count>count,"Auto pickup works")
  p.Bag={Count=2,Value=9}; local saleBefore=p.Coins
  character:PivotTo(CFrame.new(W.Zones.Sell.Position+Vector3.new(0,3,0))); Game.Pickup()
  check(p.Bag.Count==0 and p.Coins==saleBefore+9,"Sell stand zone auto-sells authoritative bag")
  character:PivotTo(CFrame.new(W.Zones.Shop.Position+Vector3.new(0,3,0))); Game.Pickup()
  check(Game.Runtime[player].InShop==true,"Shop stand zone opens on entry")
  check(not W.Root:FindFirstChild("Hazel the Gardener"),"NPC replaced by market stands")
  Game.Runtime[player].TeleportAt=0
  check(Game.Teleport(player,"Shop"),"Shop teleport succeeds")
  check((character.HumanoidRootPart.Position-W.Zones.Shop.Position).Magnitude>W.Zones.Shop.Radius,"Shop teleport lands outside automatic menu zone")
  check(not Game.Teleport(player,"Sell"),"Teleport cooldown enforced")
  Game.Runtime[player].TeleportAt=0
  check(not Game.Teleport(player,"ArbitraryPosition"),"Unknown teleport rejected")
  check(Game.Teleport(player,"Garden"),"Garden teleport succeeds")
  Game.Runtime[player].TeleportAt=0
  check(Game.Teleport(player,"Sell"),"Sell teleport succeeds")
  local Admin=require(game.ServerScriptService.BuildATree.Services.AdminService)
  if Admin.IsAdmin(player)then
   check(Game.Intent(player,"AdminCoins",{Mode="Set",Amount="1M"})and p.Coins==1e6,"Live admin coin set")
   check(Game.Intent(player,"AdminPart",{Slot="Fruit",Tier=7,Equip=true})and p.Equipped.Fruit.Tier==7,"Live admin grant and equip")
   local n=#p.Parts;check(Game.Intent(player,"AdminAllParts",{})and #p.Parts==n+Catalog.Count(),"Live admin full catalog grant")
   check(Game.Intent(player,"AdminLuck",{Multiplier="100"})and Game.Luck(p,os.time(),player)==100,"Admin override reaches real roll luck")
   check(Game.Luck(p,os.time(),{UserId=player.UserId+1})~=100,"Admin override cannot affect another account")
   check(Game.Intent(player,"AdminResetLuck",{})and Admin.Override(p)==nil,"Live admin luck reset")
  end
  local Journal=require(S.Util.Journal)
  Game.Runtime[player].RollAt=0;local coinsBefore=p.Coins;local rollsBefore=p.Rolls
  check(Game.Intent(player,"DailyRoll",{}) and p.Coins==coinsBefore and p.Rolls==rollsBefore+1,"Daily roll is free and advances real pity counters")
  check(not Game.Intent(player,"DailyRoll",{}) and p.Rolls==rollsBefore+1,"Daily roll replay cannot duplicate a reward")
  check(Game.Intent(player,"ClaimJournal",{Key="DailyLogin"}),"Live login reward claims")
  check(not Game.Intent(player,"ClaimJournal",{Key="DailyLogin"}),"Live login replay rejected")
  check(not Game.Intent(player,"VisitGarden",{Target=player.UserId}),"Self visit is rejected")
  check(not Game.Intent(player,"VisitGarden",{Target=1.5}),"Fractional gardener identity rejected")
  p.Passes.Coins=true;local value=Game.Value(p,p.Plots[1].Build,1,os.time());p.Passes.Coins=false
  check(value==Game.Value(p,p.Plots[1].Build,1,os.time())*2,"Coin pass reaches live value equation exactly once")
  p.Passes.GrowthSpeed=true;local rate=Game.Rate(p,os.time());p.Passes.GrowthSpeed=false
  check(rate==Game.Rate(p,os.time())*2,"Growth-speed entitlement doubles live rate")
  p.Passes.AutoSell=true;p.Bag={Count=1,Value=7,Items={}};character:PivotTo(CFrame.new(W.Gardens[player].Origin+Vector3.new(0,3,0)))
  check(Game.Sell(player) and p.Bag.Count==0,"Sell-anywhere still sells authoritative bag contents")
  p.Passes.InfiniteBag=true;p.Settings.AutoSell=true;Game.Runtime[player].NextAutoSell=0;p.Bag={Count=1,Value=7,Items={}}
  local autoBefore=p.Coins;Game.Pickup();check(p.Bag.Count==0 and p.Coins==autoBefore+7,"Auto-sell also works with Infinite Bag via timed settlement")
  p.Passes.AutoSell=false;p.Passes.InfiniteBag=false;p.Settings.AutoSell=false
  p.Coins=10000; check(Game.Egg(player,1),"Egg hatch works")
  check(Game.EquipPet(player,p.Pets[1].Id,false),"Equip pet works")
  p.Coins=C.Rebirth.Threshold; check(Game.RebirthProfile(p,false),"Ascension works")
  check(Growth.MaxPads(p)==2,"Ascension permanently unlocks second growth pad")
  check(Game.Intent(player,"Plant",{}) and p.Growth2~=nil,"Second pad plants while tutorial grows on first")
  Growth.Finish(p,2);character:PivotTo(CFrame.new(W.Gardens[player].Pads[8].Position+Vector3.new(0,3,0)))
  check(Game.BeginPlacement(player,2),"Second ready pad offers owned production plots")
  local secondId=p.Growth2.Id
  check(Game.PlaceTree(player,1,secondId) and p.Growth2==nil and p.Growth~=nil,"Second-pad placement preserves first growth record")
  check(not Game.PlaceTree(player,1,secondId),"Second-pad selection is consumed exactly once")
  check(p.Saplings>0 and p.Growth.Tutorial,"Ascension retains permanent reward and replants")
  p.PolicyRestricted=true;p.Passes.Coins=true;p.Coins=C.Rebirth.Threshold;check(Game.RebirthProfile(p,false) and p.PolicyRestricted and not require(S.Util.Entitlements).Has(p,"Coins"),"Policy restriction survives Ascension")
  Game.Tick()
 end)
 s.Profile=original;Game.Runtime[player]=previousRuntime;Game.Runtime[player].RollAt=previousRollAt
 if previousPosition then character:PivotTo(previousPosition) end
 for i=1,8 do W.Invalidate(player,i) end
 for fruit,r in W.Fruit do if r.Owner==player then W.Recycle(fruit) end end
 Game.State(player)
 assert(ok,err); print("Build a Tree integration: "..checks.." checks passed"); return checks
end
return Integration
