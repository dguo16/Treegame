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
 local liveEvent=require(game.ServerScriptService.BuildATree.Services.EventService);local previousEvent=P.Copy(liveEvent)
 local checks=0
 local function check(v,msg) assert(v,msg); checks+=1 end
 local ok,err=pcall(function()
  local p=P.New(os.time()); p.Upgrades.LeafPower=1; p.Coins=1000
  p.Plots={{Id="integration-original",PartIds={},Build=P.Starter(),State="Producing",NextDrop=os.time()}}; s.Profile=p
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
  -- Check canopy geometry itself; a random fruit may extend above the foliage.
  local leaf=p.Plots[2].Build.Leaves;local definition=require(S.Util.ImportedModels).Definition(leaf,"Leaves");local canopy=assert(tree:FindFirstChild(definition and definition.Asset or leaf.Name),"Rendered foliage component exists")
  local boundsCF,bounds=canopy:GetBoundingBox();check(math.abs(boundsCF.Position.Y+bounds.Y/2-tree:GetAttribute("BasePosition").Y-canopyHeight(p.Plots[2].Build,tree:GetAttribute("Height")))<.1,"Rendered canopy honors editable reference placement")
  -- Exercise actual server capability consumption and per-plot fruit cleanup.
  p.Growth=Growth.New(P.Starter(),os.time(),false);Growth.Finish(p)
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
  check(W.Gardens[player].Pads[6]~=nil and W.Gardens[player].Pads[8]~=nil and W.Gardens[player].Pads[9]~=nil,"Garden has six production pads and three growth pads")
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
  check(p.Bag.Count==2 and p.Coins==saleBefore,"Sell stand opens a panel without selling for new players")
  Game.Runtime[player].SellAt=0;check(Game.Sell(player),"Panel confirmation can sell in the Sell zone")
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
  Game.Runtime[player].SellAt=0;p.Passes.AutoSell=true;p.Bag={Count=1,Value=7,Items={}};character:PivotTo(CFrame.new(W.Gardens[player].Origin+Vector3.new(0,3,0)))
  check(Game.Sell(player) and p.Bag.Count==0,"Sell-anywhere still sells authoritative bag contents")
  Game.Runtime[player].SellAt=0;p.Passes.InfiniteBag=true;p.Settings.AutoSell=true;Game.Runtime[player].NextAutoSell=0;p.Bag={Count=1,Value=7,Items={}}
  local autoBefore=p.Coins;Game.Pickup();check(p.Bag.Count==0 and p.Coins==autoBefore+7,"Auto-sell also works with Infinite Bag via timed settlement")
  p.Passes.AutoSell=false;p.Passes.InfiniteBag=false;p.Settings.AutoSell=false
  local K=require(S.Util.Collection)
  local Event=require(game.ServerScriptService.BuildATree.Services.EventService)
  for tier=1,4 do for _,slot in C.Slots do for variant,name in C.PartVariants[slot][tier]do
   Journal.Discover(p,{Slot=slot,Tier=tier,Name=name,Variant=variant,Mutation="None"})
  end end end
  local luckBefore=Game.Luck(p,os.time(),player)
  check(Game.Intent(player,"ClaimCollection",{Key="Names1"}),"Live collection claim uses server eligibility")
  check(math.abs(Game.Luck(p,os.time(),player)/luckBefore-1.01)<1e-6,"Claimed collection bonus reaches real luck")
  local collectionCoins=p.Coins
  check(not Game.Intent(player,"ClaimCollection",{Key="Names1"})and p.Coins==collectionCoins,"Live collection replay is refused")
  check(Game.Intent(player,"EquipCosmetic",{Slot="Aura",Key="GreenGlow"}),"Owned earned aura equips")
  check(not Game.Intent(player,"EquipCosmetic",{Slot="Aura",Key="CosmicGlow"}),"Unowned cosmetic cannot equip")
  p.Journal.EventTokens=3
  check(Game.Intent(player,"BuyMedalCosmetic",{Key="FlowerPlanter"})and K.MedalBalance(p)==1,"Live Medal shop deducts its fixed price")
  check(not Game.Intent(player,"BuyMedalCosmetic",{Key="FlowerPlanter"})and K.MedalBalance(p)==1,"Live Medal duplicate cannot spend twice")
  check(Game.Intent(player,"EquipCosmetic",{Slot="Decoration",Key="FlowerPlanter"}),"Owned decoration equips")
  p.Journal.LikesReceived=10;local likesCoins=p.Coins
  check(Game.Intent(player,"ClaimLikes",{Key="Likes10"})and p.Coins==likesCoins,"Like milestone gives cosmetics without coins")
  W.Tree(player,1,p.Plots[1].Build,"Producing",1,p.Plots[1].HeightScale)
  W.Status(player,p,os.time());local garden=W.Gardens[player]
  local decoration=garden.Folder:FindFirstChild("EarnedDecoration");local partCount=0
  for _,item in decoration:GetDescendants()do if item:IsA("BasePart")then partCount+=1;check(not item.CanCollide,"Decoration cannot obstruct players")end end
  check(partCount<=7 and garden.Models[1].PrimaryPart.EarnedAura.Rate<=C.Cosmetics.AuraRate,"Cosmetic geometry and particles are bounded")
  local sign= garden.Folder.GardenName:FindFirstChildWhichIsA("TextLabel",true)
  check(sign and sign.Text:find("10 likes",1,true),"Garden sign displays received likes")
  check(Game.Intent(player,"ClaimCollection",{Key="CoreNames48"})and Game.MaxPetSlots(p)==C.Upgrades.PetSlots.Values[p.Upgrades.PetSlots]+1,"Major collection milestone grants its real equipped-pet slot")
  p.Coins=10000;p.Settings.Chill=true;local defenseCoins=p.Coins
  check(not Game.Buy(player,"Scarecrow")and p.Coins==defenseCoins,"Chill-on defense purchase is rejected without a charge")
  p.Settings.Chill=false;check(Game.Buy(player,"Scarecrow"),"Existing coin defense remains available with Chill off")
  p.Settings.Chill=true
  check(not Game.Intent(player,"Product",{Key="Shield"})and not p.PurchasePending,"Removed Shield product cannot prompt or create a purchase")
  local savedEvent=P.Copy(Event);local savedGrowth,savedGrowth2,savedQueue=p.Growth,p.Growth2,p.GrowthQueue
  local savedBag,savedRebirths=p.Bag,p.Rebirths;p.Rebirths=1;p.GrowthQueue={}
  for pad=1,2 do local g=Growth.New(P.Starter(),os.time(),false);g.Duration=3600;g.Progress=10;Growth.Set(p,pad,g)end
  local capacity=Game.Capacity(p);p.Bag={Count=capacity-1,Value=0,Items={}}
  for fruit,record in W.Fruit do if record.Owner==player then W.Recycle(fruit)end end
  local first=W.SpawnFruit(player,1,3,C.Mutations[1],os.time());local second=W.SpawnFruit(player,2,7,C.Mutations[1],os.time())
  Event.Current=nil;Event.Queue={"Windstorm"};Event.Next=1e30
  Game.Tick()
  check(Event.Current=="Windstorm"and p.Growth.State=="Growing"and p.Growth2.State=="Growing","Live Windstorm never instantly finishes either pad")
  check(p.Growth.Rate==Game.StandingGrowthRate(p)*C.Events.WindGrowth and p.Growth2.Rate==p.Growth.Rate,"Both live pads receive the Windstorm rate")
  check(p.Bag.Count==capacity and ((W.Fruit[first]~=nil and 1 or 0)+(W.Fruit[second]~=nil and 1 or 0))==1,"Windstorm collects outstanding fruit only within bag capacity")
  local now=os.time();Event.Ends=now-60
  for pad=1,2 do local g=Growth.Get(p,pad);g.Progress=0;g.Settled=now-120;g.Rate=Game.StandingGrowthRate(p)*C.Events.WindGrowth end
  Game.Settle(player,now)
  check(math.abs(p.Growth.Progress-360*Game.StandingGrowthRate(p))<1e-6,"Delayed event settlement stops the boost at its deadline")
  Game.Tick();check(Event.Current~="Windstorm"and p.Growth.Rate==Game.Rate(p,os.time()),"Windstorm end restores standing growth")
  if W.Fruit[first]then W.Recycle(first)end;if W.Fruit[second]then W.Recycle(second)end
  table.clear(Event);for key,value in savedEvent do Event[key]=value end
  p.Growth=savedGrowth;p.Growth2=savedGrowth2;p.GrowthQueue=savedQueue;p.Bag=savedBag;p.Rebirths=savedRebirths

  p.Coins=10000; check(Game.Egg(player,1),"Egg hatch works")
  check(Game.EquipPet(player,p.Pets[1].Id,false),"Equip pet works")
  -- Exercise the actual ninth world pad, placement capability and FIFO pump.
  local beforeThird={Equipped=P.Copy(p.Equipped),Growth=p.Growth,Growth2=p.Growth2,Growth3=p.Growth3,Queue=p.GrowthQueue,Rebirths=p.Rebirths,Pass=p.Passes.ThirdPad,Plots=p.Plots,Level=p.Upgrades.Plots,Restricted=p.PolicyRestricted}
  p.Equipped=P.Starter();p.Rebirths=1;p.Passes.ThirdPad=true;p.PolicyRestricted=false;p.GrowthQueue={};p.Plots=P.Copy(p.Plots);p.Plots[3]=nil;p.Upgrades.Plots=3
  for pad=1,3 do local tree=Growth.New(p.Equipped,os.time(),false);tree.Duration=3600;Growth.Set(p,pad,tree)end
  local one,two,three=p.Growth.Id,p.Growth2.Id,p.Growth3.Id
  check(Growth.MaxPads(p)==3 and Growth.QueueLimit(p)==3,"Third pass exposes one extra pad and queue place")
  Game.Tick();local garden=W.Gardens[player]
  check(garden.Models[9]and garden.Models[9]:GetAttribute("GrowthState")=="Growing","Third tree renders at world pad 9")
  check(garden.Pads[9]:GetAttribute("OwnerUserId")==player.UserId and garden.Pads[9]:GetAttribute("PlotIndex")==9,"Third world pad keeps server owner/index metadata")
  for _=1,3 do check(Game.Intent(player,"QueueTree",{}),"Live enhanced queue accepts three snapshots")end
  check(not Game.Intent(player,"QueueTree",{}),"Live enhanced queue rejects fourth snapshot")
  local snapshot=p.GrowthQueue[1].Build.Trunk.Stat;Growth.Finish(p,3);Game.Tick()
  check(garden.Models[9].PrimaryPart.TreeInteraction:GetAttribute("Kind")=="Ready","Third ready tree gets placement prompt")
  character:PivotTo(CFrame.new(garden.Pads[9].Position+Vector3.new(0,3,0)))
  check(Game.BeginPlacement(player,3),"Owner selects ready third-pad tree")
  check(not Game.PlaceTree(player,3,two),"Live third-pad capability rejects other pad ID")
  check(Game.PlaceTree(player,3,three),"Live third tree places in an empty unlocked production plot")
  check(p.Growth.Id==one and p.Growth2.Id==two and p.Growth3.Id~=three and p.Growth3.Build.Trunk.Stat==snapshot and #p.GrowthQueue==2,"Actual placement starts oldest snapshot on third pad only")
  local Purchase=require(game.ServerScriptService.BuildATree.Services.PurchaseService)
  check(not Game.Intent(player,"Product",{Key="Maxer"})and not Game.Intent(player,"Product",{Key="RebirthSkip"}),"Retired products cannot be requested through live intent")
  check(not Game.Intent(player,"Pass",{Key="MutationLuck"})and not Game.Intent(player,"Pass",{Key="ExtraPlots"}),"Retired passes have no live sale route")
  p.Passes.Cosmetics=true;Purchase.SyncCosmetics(p)
  check(Game.Intent(player,"EquipCosmetic",{Slot="Decoration",Key="Pinwheel"}),"New bundle decoration equips through live ownership validation")
  W.Status(player,p,os.time());local countParts=0;for _,part in garden.Folder.EarnedDecoration:GetDescendants()do if part:IsA("BasePart")then countParts+=1 end end
  check(countParts==7 and garden.Folder.EarnedDecoration:FindFirstChild("Blade"),"Pinwheel has distinct bounded seven-part visual")
  check(Game.Intent(player,"EquipCosmetic",{Slot="Decoration",Key=""}),"New cosmetic unequips through live intent")
  p.Equipped=beforeThird.Equipped;p.Growth=beforeThird.Growth;p.Growth2=beforeThird.Growth2;p.Growth3=beforeThird.Growth3;p.GrowthQueue=beforeThird.Queue;p.Rebirths=beforeThird.Rebirths;p.Passes.ThirdPad=beforeThird.Pass;p.Plots=beforeThird.Plots;p.Upgrades.Plots=beforeThird.Level;p.PolicyRestricted=beforeThird.Restricted
  for _,index in {3,7,8,9}do W.Invalidate(player,index)end
  p.Coins=C.Rebirth.Threshold; check(Game.RebirthProfile(p,false),"Ascension works")
  check(Growth.MaxPads(p)==2,"Ascension permanently unlocks second growth pad")
  check(Game.Intent(player,"Plant",{}) and p.Growth2~=nil,"Second pad plants while tutorial grows on first")
  Growth.Finish(p,2);character:PivotTo(CFrame.new(W.Gardens[player].Pads[8].Position+Vector3.new(0,3,0)))
  check(Game.BeginPlacement(player,2),"Second ready pad offers owned production plots")
  local secondId=p.Growth2.Id
  check(Game.PlaceTree(player,1,secondId) and p.Growth2==nil and p.Growth~=nil,"Second-pad placement preserves first growth record")
  check(not Game.PlaceTree(player,1,secondId),"Second-pad selection is consumed exactly once")
  check(p.Saplings>0 and p.Growth.Tutorial,"Ascension retains permanent reward and replants")
  checks+=require(game.TestService.BuildATreeTests.FruitIntegration).Run(Game,D,W,player)
  checks+=require(game.TestService.BuildATreeTests.SalvageIntegration).Run(Game,D,W,player)
  p.PolicyRestricted=true;p.Passes.Coins=true;p.Coins=Game.AscensionThreshold(p);check(Game.RebirthProfile(p,false) and p.PolicyRestricted and not require(S.Util.Entitlements).Has(p,"Coins"),"Policy restriction survives Ascension")
  Game.Tick()
 end)
 table.clear(liveEvent);for key,value in previousEvent do liveEvent[key]=value end
 s.Profile=original;Game.Runtime[player]=previousRuntime;Game.Runtime[player].RollAt=previousRollAt
 if previousPosition then character:PivotTo(previousPosition) end
 for i=1,C.Growth.TotalPlots+C.Growth.MaxPads do W.Invalidate(player,i) end
 for fruit,r in W.Fruit do if r.Owner==player then W.Recycle(fruit) end end
 W.Status(player,original,os.time());Game.State(player)
 assert(ok,err); print("Build a Tree integration: "..checks.." checks passed"); return checks
end
return Integration
