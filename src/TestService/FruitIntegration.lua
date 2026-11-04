-- Reversible live-service checks. Invoked only by the isolated Studio harness.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local B=require(S.Util.BagInventory)
local F=require(S.Util.FruitCollection)
local J=require(S.Util.Journal)
local Sizes=require(S.Util.FruitSizes)
local Test={}
function Test.Run(Game,D,W,player)
 local session=D.Sessions[player];local previous=session.Profile;local runtime=P.Copy(Game.Runtime[player]);local position=player.Character:GetPivot()
 local feedback=Game.Feedback;local oldSizeRng=Game.SizeRng;local event=require(game.ServerScriptService.BuildATree.Services.EventService);local oldEvent=P.Copy(event)
 local checks=0;local function check(v,msg)assert(v,msg);checks+=1 end
 local events={};Game.Feedback=function(actor,kind,data)if actor==player then table.insert(events,{Kind=kind,Data=data})else feedback(actor,kind,data)end end
 local ok,err=pcall(function()
  local p=P.New(os.time());p.Plots={{Build=P.Starter(),State="Producing",NextDrop=1e30}};p.Rebirths=1;session.Profile=p
  local rt=Game.Runtime[player];rt.SellAt=0;rt.FruitMoveAt=0;rt.InSell=nil
  event.Current=nil;event.Queue={};event.Next=1e30
  for fruit,record in W.Fruit do if record.Owner==player then W.Recycle(fruit)end end
  local function add(name,value,count,size,mutation,tier)
   B.Add(p.Bag,value,count,{Name=name,Tier=tier or 1,Mutation=mutation or "None",Size=size or "Normal"},os.time());return p.Bag.Items[#p.Bag.Items].Id
  end
  local function resetSale()rt.SellAt=0 end
  local function atSell()player.Character:PivotTo(CFrame.new(W.Zones.Sell.Position+Vector3.new(0,3,0)))end
  local plain=add("Apple",10,4,"Normal");local mutated=add("Cherry",50,2,"Giant","Golden")
  check(Game.Intent(player,"LockFruit",{StackId=mutated,Revision=p.Bag.Revision})and p.Bag.Count==4 and #p.Vault.Items==1,"Live locking transfers a stack out of bag capacity")
  local vaultId=p.Vault.Items[1].Id;local vaultValue=p.Vault.Items[1].TotalValue
  player.Character:PivotTo(CFrame.new(W.Gardens[player].Origin+Vector3.new(0,3,0)))
  check(not Game.Sell(player,p.Bag.Revision,{{Id=plain,Quantity=1}})and p.Bag.Count==4,"Manual sale requires Sell proximity")
  local rejected=events[#events]
  check(rejected.Kind=="SaleResult"and rejected.Data.RequestKey==B.SaleKey(p.Bag.Revision,{{Id=plain,Quantity=1}})and rejected.Data.Revision==nil,"Rejected proximity request resolves only its matching UI sale")
  atSell();local coins=p.Coins;Game.Pickup()
  local panel=false;for _,e in events do if e.Kind=="SellPanel"then panel=true end end
  check(panel and p.Coins==coins and p.Bag.Count==4,"Entering Sell opens panel with no automatic sale by default")
  local revision=p.Bag.Revision;Game.AddBag(p,20,1,{Name="Apple",Tier=1,Mutation="None",Size="Normal"})
  local soldBefore=J.Ensure(p).Totals.Sold;resetSale()
  check(Game.Intent(player,"Sell",{Revision=revision,Stacks={{Id=plain,Quantity=2},{Id=vaultId,Quantity=2}}}),"Stale panel race sells only still-valid selected bag fruit")
  check(p.Bag.Count==3 and J.Ensure(p).Totals.Sold==soldBefore+2,"Daily/lifetime counters use actual partial quantity")
  check(p.Vault.Items[1].Id==vaultId and p.Vault.Items[1].TotalValue==vaultValue,"Stale locked selection never sells Vault fruit")
  local result;for _,e in events do if e.Kind=="SaleResult"then result=e.Data end end
  check(result.RequestKey==B.SaleKey(revision,{{Id=plain,Quantity=2},{Id=vaultId,Quantity=2}})and result.Stale and result.Missing==1 and result.Count==2 and result.Coins==24,"Changed selection reports missing stack and recomputed payout")
  local count=p.Bag.Count;check(not Game.Intent(player,"Sell",{Revision=p.Bag.Revision,Stacks={{Id=plain,Quantity=1}}})and p.Bag.Count==count,"Live sale cooldown blocks rapid repeated requests")
  resetSale();check(not Game.Intent(player,"Sell",{Revision=p.Bag.Revision+1,Stacks={{Id=plain,Quantity=1}}}),"Live future revision rejects")
  resetSale();check(not Game.Intent(player,"Sell",{Revision=p.Bag.Revision,Stacks={{Id=plain,Quantity=100}}})and p.Bag.Count==count,"Live current-revision oversell cannot remove or pay fruit")
  resetSale();check(Game.Sell(player)and p.Bag.Count==0 and p.Vault.Items[1].TotalValue==vaultValue,"Server Sell All excludes locked Vault")
  p.Settings.QuickSellOnEntry=true;add("Apple",7,2);coins=p.Coins;resetSale();rt.InSell=nil;Game.Pickup()
  check(p.Bag.Count==0 and p.Coins==coins+14 and p.Vault.Items[1].TotalValue==vaultValue,"Quick sell on entry bypasses panel and protects Vault")
  p.Settings.QuickSellOnEntry=false;p.Passes.AutoSell=true;player.Character:PivotTo(CFrame.new(W.Gardens[player].Origin+Vector3.new(0,3,0)))
  add("Apple",9,2);resetSale();coins=p.Coins
  check(Game.Sell(player)and p.Coins==coins+18 and p.Vault.Items[1].TotalValue==vaultValue,"Sell Anywhere bypasses panel but never sells locked fruit")
  add("Apple",11,2);p.Settings.AutoSell=true;rt.NextAutoSell=0;resetSale();coins=p.Coins;Game.Pickup()
  check(p.Bag.Count==0 and p.Coins==coins+22 and p.Vault.Items[1].TotalValue==vaultValue,"AutoSell full/timed path protects Vault")
  p.Passes.InfiniteBag=true;add("Apple",5,2);rt.NextAutoSell=0;resetSale();Game.Pickup()
  check(p.Bag.Count==0 and p.Vault.Items[1].TotalValue==vaultValue,"Infinite Bag timed AutoSell protects Vault")
  p.Passes.AutoSell=false;p.Passes.InfiniteBag=false;p.Settings.AutoSell=false
  add("Apple",5,10);rt.FruitMoveAt=0
  check(not Game.Intent(player,"UnlockFruit",{StackId=vaultId,Revision=p.Bag.Revision})and #p.Vault.Items==1,"Full free bag refuses Vault unlock with no loss")
  atSell();resetSale();Game.Sell(player);rt.FruitMoveAt=0
  check(Game.Intent(player,"UnlockFruit",{StackId=vaultId,Revision=p.Bag.Revision})and p.Bag.Count==2 and #p.Vault.Items==0,"Unlock restores stack and original identity when capacity allows")
  rt.FruitMoveAt=0;check(Game.Intent(player,"LockFruit",{StackId=vaultId,Revision=p.Bag.Revision}),"Vault stack can be locked again")
  local extra=add("Orange",2,1);check(not Game.Intent(player,"LockFruit",{StackId=extra,Revision=p.Bag.Revision})and p.Bag.Count==1,"Live move cooldown blocks lock spam")
  atSell();resetSale();Game.Sell(player)
  local beforeTotal=p.Vault.Items[1].TotalValue
  local fruit=W.SpawnFruit(player,1,8,C.Mutations[1],os.time(),{Name="Apple",Tier=1,Mutation="None",Size="Large"})
  event.Current=nil;event.Queue={"Windstorm"};event.Next=1e30;Game.Tick()
  check(p.Bag.Count==1 and p.Vault.Items[1].TotalValue==beforeTotal and not W.Fruit[fruit],"Windstorm collects to bag and never consumes or modifies Vault")
  check(F.Count(p)>=1 and p.FruitIndex.Found["1:1:None"].Sizes.Large,"Windstorm-collected fruit records its actual size")
  event.Current=nil;event.Queue={};event.Next=1e30
  resetSale();Game.Sell(player)
  local normal=W.SpawnFruit(player,1,4,C.Mutations[1],os.time(),{Name="Apple",Tier=1,Mutation="None",Size="Normal"})
  local giant=W.SpawnFruit(player,1,10,C.Mutations[1],os.time(),{Name="Apple",Tier=1,Mutation="None",Size="Giant"})
  local _,a=normal.ImportedVisual:GetBoundingBox();local _,b=giant.ImportedVisual:GetBoundingBox()
  check(math.abs(b.X/a.X-1.6)<1e-5 and math.abs(b.Y/a.Y-1.6)<1e-5 and math.abs(b.Z/a.Z-1.6)<1e-5,"Imported Giant fruit scales uniformly on every axis")
  check(giant.GiantGlow.Range==C.FruitInventory.GiantGlowRange and giant.GiantGlow.Brightness<=.5,"Giant glow is small and bounded")
  check(W.Fruit[giant].ReadyAt>W.Fruit[giant].Born and C.Runtime.MaxFruit==150 and C.Runtime.FruitLifetime==90,"Size classes keep fall delay, pool cap and lifetime")
  local allWelded=true;for _,part in giant.ImportedVisual:GetDescendants()do if part:IsA("BasePart")then if part.Anchored or not part:FindFirstChildOfClass("WeldConstraint")or part.CanCollide then allWelded=false end end end
  check(allWelded and W.Fruit[giant].Tween~=nil,"Scaled mesh remains welded to the CFrame-tweened pooled anchor")
  check(giant.Size.X<=2 and C.Upgrades.Radius.Values[1]>=giant.Size.X,"Largest anchor remains within the starting collection radius")
  W.Recycle(normal);W.Recycle(giant)
  check(not giant:FindFirstChild("ImportedVisual")and not giant:FindFirstChild("GiantGlow")and giant.Size.X==C.Runtime.FruitSize,"Recycle clears Giant size, mesh and glow before reuse")
  local procedural=W.SpawnFruit(player,1,10,C.Mutations[1],os.time(),{Name=C.PartVariants.Fruit[5][1],Tier=5,Mutation="None",Size="Giant"})
  check(procedural.ImportedVisual:FindFirstChild("Stem")and procedural:GetAttribute("SizeClass")=="Giant","Procedural fruit mesh uses the same size-class path")
  W.Recycle(procedural)
  p.Upgrades.Plots=2;p.Plots[2]=P.Copy(p.Plots[1]);for _,plot in p.Plots do plot.NextDrop=0 end
  Game.SizeRng={NextNumber=function()return .995 end};rt.GiantAt=0;local firstEvents=#events;Game.Pickup()
  local giantEvents=0;for i=firstEvents+1,#events do if events[i].Kind=="GiantFruit"then giantEvents+=1 end end
  check(giantEvents==1,"Multiple Giant spawns share one per-owner sound-cue cooldown")
  for _,plot in p.Plots do plot.NextDrop=0 end;Game.Pickup();local repeated=0;for i=firstEvents+1,#events do if events[i].Kind=="GiantFruit"then repeated+=1 end end
  check(repeated==1,"Repeated Giant spawns cannot spam the cue")
  for fruit,record in W.Fruit do if record.Owner==player then W.Recycle(fruit)end end
  for i=1,7 do local id=add("TestFruit"..i,1,1,"Giant");rt.FruitMoveAt=0;Game.MoveFruit(player,id,p.Bag.Revision,true)end
  W.Status(player,p,os.time());local shelf=W.Gardens[player].Folder.VaultShelf;local displayed=0;local safe=true
  for _,model in shelf:GetChildren()do if model:IsA("Model")and model.Name:find("VaultFruit_")then displayed+=1;for _,part in model:GetDescendants()do if part:IsA("BasePart")and part.CanCollide then safe=false end end end end
  local seated=true;for _,model in shelf:GetChildren()do if model:IsA("Model")and model.Name:find("VaultFruit_")then local cf,bounds=model:GetBoundingBox();local i=tonumber(model.Name:match("%d+"));local plank=W.Gardens[player].Origin.Y+(i<=3 and 1 or 3.5)+.15;if cf.Position.Y-bounds.Y/2<plank-1e-5 then seated=false end end end
  check(seated,"Shelf fruit sits above its plank without Giant clipping")
  check(displayed==6 and safe,"Garden shelf displays at most six non-colliding vaulted-fruit miniatures")
  local poolCount=#W.Pool;W.Status(player,p,os.time());check(#W.Pool==poolCount,"Cosmetic shelf never consumes pooled harvest anchors")
  F.Discover(p,{Name="Apple",Tier=1,Mutation="Golden",Size="Giant"},os.time());local largest=p.FruitIndex.Biggest.Size;local vaulted=#p.Vault.Items
  p.Coins=Game.AscensionThreshold(p);check(Game.RebirthProfile(p)and p.Bag.Count==0 and #p.Vault.Items==vaulted and p.FruitIndex.Biggest.Size==largest,"Actual Ascension retains Vault/Index/record and clears the ordinary bag")
 end)
 Game.Feedback=feedback;Game.SizeRng=oldSizeRng;session.Profile=previous;Game.Runtime[player]=runtime
 table.clear(event);for key,value in oldEvent do event[key]=value end
 for fruit,record in W.Fruit do if record.Owner==player then W.Recycle(fruit)end end
 local garden=W.Gardens[player];if garden then local shelf=garden.Folder:FindFirstChild("VaultShelf");if shelf then shelf:Destroy()end;garden.VaultShelfRevision=nil end
 player.Character:PivotTo(position);assert(ok,err)
 print("Build a Tree live fruit: "..checks.." checks passed");return checks
end
return Test
