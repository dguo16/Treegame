-- Authoritative gameplay orchestration. Every intent is validated before entering this service.
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local Policy=game:GetService("PolicyService")
local S=game:GetService("ReplicatedStorage").BuildATree
local C=require(S.Config)
local V=require(S.Util.ValueCalculator)
local G=require(S.Util.GrowthCalculator)
local R=require(S.Util.RollEngine)
local P=require(S.Util.Profile)
local BagInventory=require(S.Util.BagInventory)
local D=require(script.Parent.DataService)
local W=require(script.Parent.WorldService)
local Growth=require(script.Parent.GrowthService)
local Event=require(script.Parent.EventService)
local Admin=require(script.Parent.AdminService)
local AdminConfig=require(script.Parent.AdminConfig)
local Batch=require(S.Util.BatchCalculator)
local Placement=require(S.Util.PlacementRules)
local Catalog=require(S.Util.PartCatalog)
local Journal=require(S.Util.Journal)
local Entitlements=require(S.Util.Entitlements)
local Game={Runtime={},Rng=Random.new(),Private=game.PrivateServerId~=""}
function Game.Init(network) Game.Network=network end
function Game.Feedback(player,kind,data) Game.Network.Feedback:FireClient(player,kind,data) end
function Game.Toast(player,message) Game.Feedback(player,"Toast",message) end
function Game.Id(p) p.NextId+=1; return tostring(p.NextId) end
function Game.PetStats(p)
 local totals={Coin=0,Luck=0,Radius=0,Speed=0,Growth=0}
 for _,id in p.EquippedPets do for _,pet in p.Pets do if pet.Id==id then
  local mult=pet.Tier*pet.Rarity*(pet.Shiny and C.Pets.Shiny or 1)
  for key in totals do totals[key]+=C.Pets[key]*mult end
 end end end return totals
end
function Game.MaxPlots(p) return Catalog.MaxPlots(p) end
function Game.Capacity(p) return Entitlements.Has(p,"InfiniteBag") and math.huge or C.Upgrades.Bag.Values[p.Upgrades.Bag] end
function Game.Radius(p) return Entitlements.Has(p,"InfiniteRange") and C.Offline.InfiniteRadius or C.Upgrades.Radius.Values[p.Upgrades.Radius]+Game.PetStats(p).Radius end
function Game.Luck(p,now,player)
 if Admin.IsAdmin(player) then local override=Admin.Override(p);if override then return override end end
 local boost=not p.PolicyRestricted and p.Boosts.LuckUntil and p.Boosts.LuckUntil>now and p.Boosts.LuckFactor or 1
 return (1+Game.PetStats(p).Luck)*(Entitlements.Has(p,"Luck") and 2 or 1)*(Game.Private and not p.PolicyRestricted and C.Offline.PrivateLuck or 1)*boost
end
function Game.MutationLuck(p)
 return C.Monetization.MutationLuckEnabled and Entitlements.Has(p,"MutationLuck")and 2 or 1
end
function Game.Value(p,build,mutation,now)
 local pet=Game.PetStats(p); local event=Event.Current=="Golden Rain" and C.Events.RainCoins or 1
 local prune=p.Boosts.PruneUntil and p.Boosts.PruneUntil>now and p.Boosts.Pruned or nil
 local trap=p.Boosts.TrapUntil and p.Boosts.TrapUntil>now and C.Sabotage.TrapRate or 1
 return V.Build(build,mutation,1+p.Saplings*C.Math.RebirthPerSapling,event,(Entitlements.Has(p,"VIP") and 1.1 or 1)*(1+pet.Coin)*trap,prune,C.Upgrades.LeafPower.Values[p.Upgrades.LeafPower or 1],Entitlements.Has(p,"Coins"))
end
function Game.Income(p,now)
 local total=0
 for _,plot in p.Plots do total+=Game.Value(p,plot.Build,1,now)/V.DropInterval({plot.Build.Roots.Stat}) end
 return total
end
function Game.Rate(p,now)
 return (Entitlements.Has(p,"GrowthSpeed")and 2 or 1)*(Game.Private and not p.PolicyRestricted and C.Growth.PrivateRate or 1)*(1+Game.PetStats(p).Growth)*(Event.Current=="Golden Rain" and C.Events.RainGrowth or 1)*(p.Boosts.PestUntil and p.Boosts.PestUntil>now and C.Sabotage.PestRate or 1)
end
function Game.Settle(player,now)
 local p=D.Get(player);if p then for pad=1,2 do local g=Growth.Get(p,pad);if g then
  local old=g.State;G.Rate(g,now,Game.Rate(p,now))
  if old~="Ready"and g.State=="Ready"then Game.Runtime[player].NotifyReady=true end
 end end end
end
function Game.State(player)
 local p=D.Get(player); if not p then return end
 Journal.Touch(p,os.time())
 local rt=Game.Runtime[player]; local copy=P.Copy(p)
 copy.Receipts=nil; copy.PurchaseLog=nil; copy.PendingGrow=nil
 copy.Capacity=Game.Capacity(p)==math.huge and "Infinite" or Game.Capacity(p); copy.Radius=Game.Radius(p); copy.MaxPlots=Game.MaxPlots(p)
 copy.Income=Game.Income(p,os.time()); copy.RollCost=R.Cost(p.Rolls,C.Upgrades.Discount.Values[p.Upgrades.Discount]); copy.Luck=Game.Luck(p,os.time(),player)
 copy.MutationLuck=Game.MutationLuck(p)
 copy.MaxGrowthPads=Growth.MaxPads(p)
 copy.GardenVisitors={};local bestHeight=0;local rarest=1
 for other in Game.Runtime do local op=D.Get(other);if op then
  table.insert(copy.GardenVisitors,{UserId=other.UserId,Name=other.DisplayName,Likes=Journal.Ensure(op).LikesReceived or 0})
  for _,plot in op.Plots do local height=G.Height(plot.Build,plot.HeightScale);if height>bestHeight then bestHeight=height;copy.Showcase={Name=other.DisplayName,Height=height}end
   for _,part in plot.Build do rarest=math.max(rarest,part.Tier)end
  end
 end end
 if copy.Showcase then copy.Showcase.Rarest=rarest end
 copy.IsAdmin=Admin.IsAdmin(player);copy.AdminControls=nil
 if copy.IsAdmin then copy.Admin={LuckOverride=Admin.Override(p),MinLuck=AdminConfig.MinLuck,MaxLuck=AdminConfig.MaxLuck,MaxCoins=C.Runtime.MaxCoins} end
 copy.Event={Name=Event.Current,Ends=Event.Ends,Next=Event.Next,Health=Event.Health}; copy.Preview=math.max(1,math.floor((p.Coins/C.Rebirth.SaplingDivisor)^C.Rebirth.Exponent))
 copy.PaidRandom=rt and rt.PaidRandom or false; copy.Persistent=D.Persistent(player); copy.Private=Game.Private
 copy.RollCount,copy.RollTotalCost=Batch.Choose(p.Rolls,p.Coins,p.Upgrades.Batch,C.Upgrades.Discount.Values[p.Upgrades.Discount],C.Runtime.MaxInventory-#p.Parts)
 Game.Network.State:FireClient(player,copy)
end
function Game.AddBag(p,value,count,metadata)
 local accepted=math.min(count or 1,math.max(0,Game.Capacity(p)-p.Bag.Count))
 if accepted<=0 then return false end
 BagInventory.Add(p.Bag,value,accepted,metadata,os.time(),Game.Id(p)); return true
end
function Game.Teleport(player,destination)
 local rt=Game.Runtime[player]; local g=W.Gardens[player]
 local character=player.Character; local root=character and character:FindFirstChild("HumanoidRootPart"); local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if not rt or not root or not humanoid or humanoid.Health<=0 or not g then return false,"Your character is not ready yet." end
 local now=workspace:GetServerTimeNow()
 if (rt.TeleportAt or 0)>now then return false end
 local position,look
 if destination=="Garden" then position=g.Origin+Vector3.new(0,5,31); look=g.Origin
 elseif destination=="Shop" then position=W.Zones.Shop.Position+Vector3.new(0,4,11); look=W.ShopPrompt.Parent.Position
 elseif destination=="Sell" then position=W.Zones.Sell.Position+Vector3.new(0,4,0); look=W.Shop
 else return false,"Unknown destination." end
 if (D.Get(player).Boosts.StunUntil or 0)>os.time() then return false,"Wait for the stun to end." end
 rt.TeleportAt=now+C.Inventory.TeleportCooldown; humanoid.Sit=false
 root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero; character:PivotTo(CFrame.lookAt(position,look))
 return true
end
function Game.Join(player)
 local p,err=D.Load(player); if not p then player:Kick(err); return end
 if not player.Parent then D.Save(player,true); return end
 if not W.Assign(player) then D.Save(player,true); player:Kick("All gardens are occupied. Please join another server."); return end
 local now=os.time();local away=math.max(0,now-p.LastSeen);Journal.Login(p,now)
 local rt={Joined=now,RollAt=0,Tokens=C.Runtime.RemoteBurst,LastToken=workspace:GetServerTimeNow(),Sabotage={},Steal={},PaidRandom=false,LastUpsell=0,LastRaid=0}
 p.PolicyRestricted=true;Game.Runtime[player]=rt
 local policyOK,policy=pcall(function() return Policy:GetPolicyInfoForPlayerAsync(player) end)
 rt.PaidRandom=policyOK and not policy.ArePaidRandomItemsRestricted;p.PolicyRestricted=not rt.PaidRandom
 local off=math.floor(Game.Income(p,p.LastSeen)*math.min(away,Entitlements.Has(p,"Offline") and C.Offline.PassSeconds or C.Offline.Seconds)*C.Offline.Fraction)
 p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+off)
 -- Offline growth settles both pads without applying temporary weather or pests.
 for pad=1,2 do local g=Growth.Get(p,pad);if g then
  g.Rate=(Game.Private and not p.PolicyRestricted and C.Growth.PrivateRate or 1)*(1+Game.PetStats(p).Growth)*(Entitlements.Has(p,"GrowthSpeed")and 2 or 1)
 end end
 Growth.Step(p,now,Game.Rate(p,now))
 if #p.Plots==0 and not p.Growth and not p.Growth2 then p.Growth=Growth.New(P.Starter(),now,true) end
 p.LastSeen=now
 local stats=Instance.new("Folder"); stats.Name="leaderstats"; stats.Parent=player
 local coins=Instance.new("NumberValue"); coins.Name="Coins"; coins.Parent=stats
 local height=Instance.new("NumberValue"); height.Name="Tallest Tree"; height.Parent=stats
 player.CharacterAdded:Connect(function(character)
  local root=character:WaitForChild("HumanoidRootPart",10)
  if root and W.Gardens[player] then character:PivotTo(CFrame.lookAt(W.Gardens[player].Origin+Vector3.new(0,5,31),W.Gardens[player].Origin)) end
 end)
 if player.Character then player.Character:PivotTo(CFrame.lookAt(W.Gardens[player].Origin+Vector3.new(0,5,31),W.Gardens[player].Origin)) end
 Game.State(player)
 task.delay(3,function()if player.Parent then
  local ready=(p.Growth and p.Growth.State=="Ready"and 1 or 0)+(p.Growth2 and p.Growth2.State=="Ready"and 1 or 0)
  if away>=60 then Game.Feedback(player,"OfflineSummary",{Away=away,Coins=off,Ready=ready,Cap=Entitlements.Has(p,"Offline") and C.Offline.PassSeconds or C.Offline.Seconds})else Game.Toast(player,"Welcome! Open Tree Parts → Journal for collections and daily goals.")end
 end end)
end
function Game.Sell(player)
 local p=D.Get(player); local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root or ((root.Position-W.Shop).Magnitude>C.Runtime.ShopRange and not Entitlements.Has(p,"AutoSell"))then return false,"Step into the red SELL zone at the market." end
 if p.Bag.Count<=0 then return false,"Your bag is empty." end
 Journal.Add(p,"Sold",p.Bag.Count,os.time());if p.Onboarding==6 then p.Onboarding=7 end
 local value=p.Bag.Value; p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+value); p.TotalCoins+=value; p.Bag={Count=0,Value=0,Items={}}
 if p.Tutorial==4 then p.Tutorial=5 end
 Game.Feedback(player,"Sell",{Value=value,Position=W.Shop}); return true,"Sold your fruit!"
end
function Game.Roll(player,automatic,free)
 local p=D.Get(player); local rt=Game.Runtime[player]; local now=workspace:GetServerTimeNow()
 if now<rt.RollAt then return false,"Roll is cooling down." end
 if #p.Parts>=C.Runtime.MaxInventory then return false,"Sell some spare parts first."end
 local count,cost=1,0
 if not free then count,cost=Batch.Choose(p.Rolls,p.Coins,p.Upgrades.Batch,C.Upgrades.Discount.Values[p.Upgrades.Discount],C.Runtime.MaxInventory-#p.Parts)end
 if count==0 then return false,"Collect and sell fruit for more coins."end
 rt.RollAt=now+C.Runtime.RollCooldown; p.Coins-=cost
 local results={}
 for _=1,count do local rolled=R.Roll(Game.Rng,p,Game.Luck(p,os.time(),player),Game.Id(p),Game.MutationLuck(p)); table.insert(p.Parts,rolled); table.insert(results,rolled);Journal.Discover(p,rolled)
  if C.Rarities[rolled.Tier].Announce then Game.Network.Feedback:FireAllClients("Announcement",player.DisplayName.." rolled "..C.Rarities[rolled.Tier].Name.." "..rolled.Name.."!") end
 end
 Journal.Add(p,"Rolls",count,os.time());if p.Onboarding==1 then p.Onboarding=2 end
 if p.Tutorial==1 then p.Tutorial=2 end
 Game.Feedback(player,"Roll",results); return true
end
function Game.Buy(player,kind)
 local p=D.Get(player); local up=C.Upgrades[kind]
 if up then
  local level=p.Upgrades[kind] or 1; if level>=#up.Values or (kind=="Plots" and Game.MaxPlots(p)>=C.Growth.TotalPlots) then return false,"Already at maximum." end
  level=level or 1
  local price=up.Prices and up.Prices[level] or math.floor(up.BasePrice*up.PriceGrowth^(level-1)); if p.Coins<price then return false,"Not enough coins." end
  p.Coins-=price; p.Upgrades[kind]+=1
 elseif kind=="Water" then
  if p.Defenses.Water then return false,"Already owned." end
  if p.Coins<C.Growth.WaterPrice then return false,"Not enough coins." end
  p.Coins-=C.Growth.WaterPrice; p.Defenses.Water=true
 elseif C.Defenses[kind] then
  if p.Coins<C.Defenses[kind] then return false,"Not enough coins." end
  if kind=="Scarecrow" or kind=="Fence" then if p.Defenses[kind] then return false,"Already owned." end end
  Game.Settle(player,os.time()); p.Coins-=C.Defenses[kind]
  if kind=="Shield" then p.Boosts.ShieldUntil=os.time()+C.Sabotage.ShieldDuration
  elseif kind=="BugSpray" then p.Boosts.PestUntil=0; p.Boosts.SprayUntil=os.time()+C.Sabotage.ShieldDuration
  else p.Defenses[kind]=true end
 else return false,"Unknown upgrade." end
 if kind=="LeafPower"and p.Onboarding==7 then p.Onboarding=8 elseif kind=="Plots"and p.Onboarding==8 then p.Onboarding=9 end
 if p.Tutorial==5 then p.Tutorial=6 end
 return true,"Purchased "..kind
end
function Game.Egg(player,tier)
 local p=D.Get(player)
 if tier%1~=0 or not C.Pets.EggPrices[tier] then return false,"Unknown egg." end
 if #p.Pets>=C.Runtime.MaxPets then return false,"Fuse pets to make room." end
 local price=C.Pets.EggPrices[tier]; if p.Coins<price then return false,"Not enough coins." end
 p.Coins-=price
 local total=0; for _,w in C.Pets.Weights do total+=w end
 local rarity=R.Choose(Game.Rng,C.Pets.Weights,total)
 local pet={Id=Game.Id(p),Tier=tier,Rarity=rarity,Name=C.Pets.Names[rarity].." "..C.Pets.Themes[tier],Shiny=false}
 table.insert(p.Pets,pet); return true,"Hatched "..pet.Name
end
function Game.EquipPet(player,id,fuse)
 local p=D.Get(player); Game.Settle(player,os.time())
 local pet; for _,v in p.Pets do if v.Id==id then pet=v end end
 if not pet then return false,"Unknown pet." end
 if fuse then
  if pet.Shiny then return false,"Already Shiny." end
  local matches={}; for i,v in p.Pets do if v.Tier==pet.Tier and v.Rarity==pet.Rarity and not v.Shiny then table.insert(matches,i) end end
  if #matches<3 then return false,"You need three matching pets." end
  for i=3,1,-1 do local removed=table.remove(p.Pets,matches[i]); local e=table.find(p.EquippedPets,removed.Id); if e then table.remove(p.EquippedPets,e) end end
  pet=P.Copy(pet); pet.Id=Game.Id(p); pet.Shiny=true; table.insert(p.Pets,pet); return true,"Fused a Shiny "..pet.Name
 end
 local existing=table.find(p.EquippedPets,id)
 if existing then table.remove(p.EquippedPets,existing); return true,"Pet unequipped." end
 if #p.EquippedPets>=C.Upgrades.PetSlots.Values[p.Upgrades.PetSlots] then return false,"Pet slots full." end
 table.insert(p.EquippedPets,id); return true,"Pet equipped."
end
function Game.RebirthProfile(p,skip)
 if not skip and p.Coins<C.Rebirth.Threshold then return false end
 local saplings=math.max(1,math.floor((p.Coins/C.Rebirth.SaplingDivisor)^C.Rebirth.Exponent))
 local fresh=P.New(os.time()); fresh.Saplings=p.Saplings+saplings; fresh.Rebirths=p.Rebirths+1
 for _,key in {"Receipts","Settings","Passes","Pets","EquippedPets","ProductSpent","PurchaseLog","GrowCredits","AdminControls","HeightRecord","Journal","EarlyRareClaimed","Onboarding","PolicyRestricted"} do fresh[key]=p[key] end
 fresh.TotalCoins=p.TotalCoins; fresh.Tutorial=6; fresh.Joined=p.Joined; fresh.Playtime=p.Playtime; fresh.NextId=p.NextId
 fresh.Growth=Growth.New(fresh.Equipped,os.time(),true)
 table.clear(p); for k,v in fresh do p[k]=v end; return true
end
function Game.Sabotage(player,targetId,kind)
 local p=D.Get(player); local target=Players:GetPlayerByUserId(targetId); local victim=target and D.Get(target); local now=os.time(); local rt=Game.Runtime[player]
 if Game.Private or not victim or target==player or not D.Available(target) or p.Settings.Chill or victim.Settings.Chill then return false,"Sabotage is off for this garden." end
 local a=player.Character and player.Character:FindFirstChild("HumanoidRootPart"); local b=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
 if not a or not b or (a.Position-b.Position).Magnitude>C.Runtime.SabotageRange then return false,"Move closer to that player." end
 if p.Playtime<C.Sabotage.Protection or victim.Playtime<C.Sabotage.Protection then return false,"New gardeners are protected for five minutes." end
 if (p.Boosts.StunUntil or 0)>now or (victim.Boosts.ShieldUntil or 0)>now then return false,"That action is blocked by a defense." end
 if (rt.Sabotage[targetId] or 0)>now then return false,"That garden is on cooldown." end
 if not table.find({"Shake","Pest","Trap","Prune"},kind) then return false,"Unknown action." end
 rt.Sabotage[targetId]=now+C.Sabotage.Cooldown
 Game.Settle(target,now)
 if kind=="Shake" then
  if victim.Defenses.Fence then p.Boosts.StunUntil=now+C.Sabotage.Stun; return false,"The fence stunned you!" end
  if victim.Defenses.Scarecrow then return false,"A scarecrow protects these fruits." end
  local fruits,total={},0; for fruit,r in W.Fruit do if r.Owner==target then table.insert(fruits,fruit); total+=r.Value end end
  local vrt=Game.Runtime[target]; local bucket=vrt.Steal
  if not bucket.Until or now>=bucket.Until then bucket.Until=now+60; bucket.Value=0; bucket.Cap=total*C.Sabotage.MinuteCap end
  local budget=math.min(total*C.Sabotage.ShakeFraction,math.max(0,bucket.Cap-bucket.Value))
  for _,fruit in fruits do local r=W.Fruit[fruit]; if r and r.Value<=budget and Game.AddBag(p,r.Value,1,r.Metadata) then budget-=r.Value; bucket.Value+=r.Value; W.Recycle(fruit) end end
 elseif kind=="Pest" then if (victim.Boosts.SprayUntil or 0)>now then return false,"Bug spray prevented the pests." end victim.Boosts.PestUntil=now+C.Sabotage.PestDuration
 elseif kind=="Prune" then victim.Boosts.PruneUntil=now+C.Sabotage.PruneDuration; victim.Boosts.Pruned=C.Slots[Game.Rng:NextInteger(1,#C.Slots)]
 elseif kind=="Trap" then
  local zone=W.Part(W.Root,"WeatherTrap",Vector3.new(12,1,12),a.Position-Vector3.new(0,2,0),Color3.fromRGB(155,113,213)); zone.Transparency=.5; zone.CanCollide=false
  zone:SetAttribute("Target",targetId); zone:SetAttribute("Expires",now+C.Sabotage.TrapDuration)
 end
 Game.Feedback(target,"Revenge",{Text=player.DisplayName.." used "..kind..". Growth progress is safe.",Target=player.UserId}); return true,"Sabotage applied."
end
function Game.BeginPlacement(player,pad)
 if not D.Available(player)then return false,"Please try again in a moment."end
 local p=D.Get(player);local g=W.Gardens[player];local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 pad=pad or 1;local tree=p and Growth.Get(p,pad)
 if not p or pad<1 or pad>Growth.MaxPads(p)or not tree or tree.State~="Ready"or not g or not root then return false,"Your tree is not ready yet."end
 if(root.Position-g.Pads[6+pad].Position).Magnitude>C.Placement.PromptRange then return false,"Stand near your grown tree."end
 local plots,targets=Placement.Choices(p,Game.MaxPlots(p))
 local selection={GrowthId=tree.Id,GrowthPad=pad,Plots=plots,Targets=targets,Expires=workspace:GetServerTimeNow()+C.Placement.SelectionSeconds}
 local occupied={};for _,i in plots do occupied[i]=targets[i]~=false end
 Game.Runtime[player].Placement=selection
 Game.Feedback(player,"SelectPlot",{GrowthId=selection.GrowthId,Plots=plots,Occupied=occupied,Expires=selection.Expires});return true
end
function Game.PlaceTree(player,index,growthId,token)
 if not D.Available(player)then return false,"Please try again in a moment."end
 local p=D.Get(player);local rt=Game.Runtime[player];local g=W.Gardens[player];local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not p or not rt or not g or not root or(root.Position-g.Origin).Magnitude>C.Placement.GardenRange then return false,"Return to your garden to plant."end
 local selection=rt.Placement;local occupied=p.Plots[index]~=nil
 local confirmation=selection and selection.Confirmation
 local confirmed=token~=nil and confirmation and confirmation.Token==token and confirmation.Plot==index
 local ok,message=Placement.Validate(p,selection,index,growthId,Game.MaxPlots(p),workspace:GetServerTimeNow(),occupied)
 if not ok then return false,message end
 if token and not confirmed then return false,"That confirmation expired. Hold E again."end
 if occupied and not confirmed then
  local returned=Growth.ReturnParts(p,index)
  if #p.Parts+#returned>C.Runtime.MaxInventory then return false,"Need "..#returned.." free part slots. Sell unequipped spares, then hold E again. Your trees are unchanged."end
  selection.Confirmation={Token=Http:GenerateGUID(false),Plot=index}
  Game.Feedback(player,"ConfirmReplacement",{Plot=index,GrowthId=growthId,Token=selection.Confirmation.Token,Expires=selection.Expires,Returned=#returned})
  return false,"Confirm Replace to change plot "..index.."."
 end
 local success,msg=Growth.Swap(p,index,Game.MaxPlots(p),workspace:GetServerTimeNow(),confirmed,selection.GrowthPad)
 if success then
  Journal.Add(p,"Plants",1,os.time());if p.Onboarding==4 then p.Onboarding=5 end
  rt.Placement=nil;W.ClearPlotFruit(player,index);W.Invalidate(player,index);W.Invalidate(player,6+(selection.GrowthPad or 1));Game.Feedback(player,"PlacementDone",{})
 end
 return success,msg
end
function Game.Intent(player,action,args)
 local p=D.Get(player); if not p then return end
 if Admin.Handles(action) then
  local success,message=Admin.Execute(player,p,action,args,function() return Game.Id(p) end)
  if success then Journal.Scan(p)end
  Game.Feedback(player,"AdminResult",{Success=success,Message=message});Game.State(player);return success
 end
 local ok,message=false,nil; local now=os.time()
 if action=="Teleport" then ok,message=Game.Teleport(player,args.Destination)
 elseif action=="Roll" then ok,message=Game.Roll(player,false)
 elseif action=="Sell" then ok,message=Game.Sell(player)
 elseif action=="Buy" then ok,message=Game.Buy(player,args.Kind)
 elseif action=="Plant"then ok,message=Growth.Plant(p,now);if ok then if p.Tutorial==2 then p.Tutorial=3 end;if p.Onboarding==3 then p.Onboarding=4 end end
 elseif action=="ClaimJournal"then ok,message=Journal.Claim(p,args.Key,now)
 elseif action=="DailyRoll"then
  local j=Journal.Touch(p,now)
  if not j.Daily.Claims.FreeRoll then ok,message=Game.Roll(player,false,true);if ok then j.Daily.Claims.FreeRoll=true;j.Version+=1 end else message="Today's free roll is already claimed. Come back any day for another."end
 elseif action=="VisitGarden"or action=="LikeGarden"then
  if args.Target%1~=0 or args.Target<=0 then return false,"Choose an online gardener."end
  local target=Players:GetPlayerByUserId(args.Target);local garden=target and W.Gardens[target];local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local tp=target and D.Get(target)
  if target and target~=player and garden and tp and D.Available(target)then
   if action=="VisitGarden"and root and workspace:GetServerTimeNow()>=(Game.Runtime[player].TeleportAt or 0)then
    Game.Runtime[player].TeleportAt=workspace:GetServerTimeNow()+C.Inventory.TeleportCooldown;player.Character:PivotTo(CFrame.new(garden.Origin+Vector3.new(0,5,31)));ok=true
   elseif action=="LikeGarden"and root and(root.Position-garden.Origin).Magnitude<C.Placement.GardenRange then
    local j=Journal.Touch(p,now);local key=tostring(target.UserId)
    if not j.Liked[key]then j.Liked[key]=true;j.Version+=1;local tj=Journal.Ensure(tp);tj.LikesReceived=(tj.LikesReceived or 0)+1;tj.Version+=1;ok=true;message="Garden liked!"else message="You already liked this garden today."end
   else message="Visit this garden first."end
  else message="Choose another online gardener."end
 elseif action=="QueueTree"then ok,message=Growth.Queue(p,now)
 elseif action=="CancelQueuedTree"then ok,message=Growth.CancelQueue(p,args.QueueId)
 elseif action=="PlaceTree"then ok,message=Game.PlaceTree(player,args.Plot,args.GrowthId)
 elseif action=="ReplaceTree"then ok,message=Game.PlaceTree(player,args.Plot,args.GrowthId,args.Token)
 elseif action=="CancelPlacement"then Game.Runtime[player].Placement=nil;ok=true
 elseif action=="Equip" or action=="SellPart" then
  if action=="Equip" then for _,slot in C.Slots do if args.Id=="starter_"..slot then p.Equipped[slot]=P.Starter()[slot]; Game.State(player); return true end end end
  for i,part in p.Parts do if part.Id==args.Id then
   if action=="Equip" then p.Equipped[part.Slot]=P.Copy(part);if p.Onboarding==2 then p.Onboarding=3 end; ok=true; message="Equipped "..part.Name
   elseif p.Equipped[part.Slot].Id==part.Id then message="Equip another "..part.Slot.." before selling this one."
   else p.Coins+=math.floor(C.Roll.BaseCost*C.Roll.PartSellFraction*part.Stat); table.remove(p.Parts,i); ok=true; message="Part sold." end break
  end end
 elseif action=="Water" then
  if not p.Defenses.Water then message="Buy a Watering Can at the market."
  elseif p.WaterAt>now then message="Watering Can is cooling down."
  else local tree=Growth.Active(p);if tree then Game.Settle(player,now);tree.Progress=math.min(tree.Duration,tree.Progress+C.Growth.WaterReduction);p.WaterAt=now+C.Growth.WaterCooldown;ok=true;message="Watered!"end end
 elseif action=="Egg" then ok,message=Game.Egg(player,args.Tier)
 elseif action=="EquipPet" or action=="Fuse" then ok,message=Game.EquipPet(player,args.Id,action=="Fuse")
 elseif action=="Sabotage" then ok,message=Game.Sabotage(player,args.Target,args.Kind)
 elseif action=="Rebirth" and args.Confirm then ok=Game.RebirthProfile(p,false); message=ok and "Ascended! Your Golden Saplings are permanent." or "More coins needed."; if ok then for i=1,8 do W.Invalidate(player,i) end end
 elseif action=="Tutorial" and args.Skip then p.Tutorial=6;p.Onboarding=9; ok=true
 elseif action=="AutoRoll" then if Entitlements.Has(p,"AutoRoll") then p.AutoRoll=not p.AutoRoll; ok=true else message="Auto-Roll requires the pass." end
 elseif action=="Setting" then
  if args.Key=="SpendingLimit" then if type(args.Value)=="number" and args.Value%1==0 and args.Value>=0 then p.Settings.SpendingLimit=args.Value; ok=true end
  elseif (args.Key=="MusicVolume"or args.Key=="SFXVolume")and type(args.Value)=="number"and args.Value>=0 and args.Value<=1 then p.Settings[args.Key]=args.Value;ok=true
  elseif type(args.Value)=="boolean" and type(p.Settings[args.Key])=="boolean" then p.Settings[args.Key]=args.Value; ok=true end
 elseif action=="Raid" then
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if Event.Current=="Giant Pest Raid" and Event.Health>0 and root and (root.Position-W.Shop).Magnitude<C.Runtime.ShopRange*2 and workspace:GetServerTimeNow()-Game.Runtime[player].LastRaid>=C.Events.RaidHitCooldown then
   Game.Runtime[player].LastRaid=workspace:GetServerTimeNow();Event.Participants[player.UserId]=(Event.Participants[player.UserId]or 0)+1; Event.Health-=1; ok=true
   if Event.Health<=0 then for _,other in Players:GetPlayers() do local op=D.Get(other); if op and D.Available(other)and (Event.Participants[other.UserId]or 0)>0 then op.Coins=math.min(C.Runtime.MaxCoins,op.Coins+C.Events.RaidReward*math.max(1,Game.Income(op,now)));Journal.Event(op,"Giant Pest Raid",Event.Starts);Game.Toast(other,"Pest raid defeated! Participation reward and keepsake earned.")end end end
  end
 elseif Game.Purchase then ok,message=Game.Purchase.Intent(player,action,args) end
 if message then Game.Toast(player,message) end
 Game.State(player); return ok
end
function Game.Tick()
 local now=os.time()
 -- Settle under the OLD event rate, then transition; rates never apply retroactively.
 for player in Game.Runtime do if D.Available(player) then Game.Settle(player,now) end end
 Event.Tick(now,function(name)
  Game.Network.Feedback:FireAllClients("Announcement",name.." has begun!")
  if name=="Windstorm" then
   for player in Game.Runtime do local p=D.Get(player); if p and D.Available(player) then if p.Growth or p.Growth2 then Journal.Event(p,"Windstorm",Event.Starts)end;Growth.FinishAll(p); for fruit,r in W.Fruit do if r.Owner==player and Game.AddBag(p,r.Value,1,r.Metadata) then W.Recycle(fruit) end end end end
  elseif name=="Giant Pest Raid" then
   local bug=W.Part(W.Root,"RaidBug",Vector3.new(8,5,7),W.Shop+Vector3.new(0,3,12),Color3.fromRGB(92,50,115),Enum.PartType.Ball)
   local click=Instance.new("ClickDetector"); click.MaxActivationDistance=C.Runtime.ShopRange*2; click.Parent=bug
   click.MouseClick:Connect(function(player) if D.Available(player) then Game.Intent(player,"Raid",{}) end end)
  end
 end,function() local bug=W.Root:FindFirstChild("RaidBug"); if bug then bug:Destroy() end end)
 for player,rt in Game.Runtime do
  local p=D.Get(player)
  if p and D.Available(player) then
   p.Playtime+=math.max(0,now-p.LastSeen); p.LastSeen=now
   local ready=Growth.Step(p,now,Game.Rate(p,now)); if ready or rt.NotifyReady then rt.NotifyReady=nil; Game.Feedback(player,"Ready",{}); Game.Toast(player,"Your tree is ready! Hold E near it to plant or replace a tree.") end
   for i,plot in p.Plots do
    W.Tree(player,i,plot.Build,"Producing",1,plot.HeightScale)
   end
   for pad=1,2 do
    local g=Growth.Get(p,pad);local index=6+pad
    if g then
     local model=W.Tree(player,index,g.Build,g.State,g.Progress/g.Duration,g.HeightScale)
     if model then local billboard=model.PrimaryPart.Progress;billboard.Label.Text=g.State=="Ready"and string.format("READY! %.1f studs • Choose a plot",G.Height(g.Build,g.HeightScale))or string.format("Pad %d • Growing • %ds",pad,math.ceil(G.Remaining(g)));billboard.Bar.Visible=g.State~="Ready";billboard.Bar.Size=UDim2.fromScale(g.Progress/g.Duration,.12)end
     if g.State=="Ready"then W.GrowthPrompt(player,"Ready",function(actor)if actor==player then local ok,msg=Game.BeginPlacement(actor,pad);if not ok then Game.Toast(actor,msg)end end end,index)
     elseif p.Defenses.Water then W.GrowthPrompt(player,"Water",function(actor)if actor==player then Game.Intent(actor,"Water",{})end end,index)end
    else W.Invalidate(player,index)end
   end
   local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   W.Status(player,p,now)
   player:SetAttribute("GardenVIP",Entitlements.Has(p,"VIP")==true)
   local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if root and (root.Position-W.VIPPosition).Magnitude<12 and not Entitlements.Has(p,"VIP") then player.Character:PivotTo(CFrame.new(0,5,45)) end
   if humanoid then humanoid.WalkSpeed=(16+Game.PetStats(p).Speed)*(Entitlements.Has(p,"Speed") and 2 or 1)*((p.Boosts.StunUntil or 0)>now and 0 or 1) end
   if player:FindFirstChild("leaderstats") then player.leaderstats.Coins.Value=p.Coins; local height=0; for _,plot in p.Plots do height=math.max(height,G.Height(plot.Build,plot.HeightScale)) end player.leaderstats["Tallest Tree"].Value=height;p.HeightRecord=math.max(p.HeightRecord or 0,height,p.Growth and p.Growth.State=="Ready" and G.Height(p.Growth.Build,p.Growth.HeightScale) or 0,p.Growth2 and p.Growth2.State=="Ready"and G.Height(p.Growth2.Build,p.Growth2.HeightScale)or 0) end
   if p.AutoRoll and Entitlements.Has(p,"AutoRoll") and workspace:GetServerTimeNow()>=rt.RollAt then Game.Roll(player,true) end
   Game.State(player)
  end
 end
 for _,zone in W.Root:GetChildren() do if zone.Name=="WeatherTrap" then
  if now>=zone:GetAttribute("Expires") then zone:Destroy() else
   local target=Players:GetPlayerByUserId(zone:GetAttribute("Target")); local p=target and D.Get(target); local root=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
   if p and D.Available(target) and root and not p.Settings.Chill and (p.Boosts.ShieldUntil or 0)<=now and (root.Position-zone.Position).Magnitude<8 then p.Boosts.TrapUntil=now+C.Sabotage.TrapDuration end
  end
 end end
end
function Game.Pickup()
 local now=workspace:GetServerTimeNow()
 for player,rt in Game.Runtime do
  local p=D.Get(player)
  if p and D.Available(player) then
   local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if root then
    if p.Settings.AutoSell and Entitlements.Has(p,"AutoSell")and p.Bag.Count>0 and(p.Bag.Count>=Game.Capacity(p)or now>=(rt.NextAutoSell or 0))then Game.Sell(player);rt.NextAutoSell=now+C.Runtime.AutoSellSeconds end
    local sell=W.Zones.Sell; local shop=W.Zones.Shop
    if sell and (root.Position-sell.Position).Magnitude<sell.Radius and p.Bag.Count>0 then Game.Sell(player); Game.State(player) end
    local inside=shop and (root.Position-shop.Position).Magnitude<shop.Radius
    if inside and not rt.InShop then Game.Feedback(player,"Shop",{}); rt.InShop=true elseif not inside then rt.InShop=false end
   end
   for i,plot in p.Plots do if now>=plot.NextDrop then
    local mutation=R.Mutation(Game.Rng,Game.MutationLuck(p))
    W.SpawnFruit(player,i,Game.Value(p,plot.Build,mutation.Mult,now),mutation,now,{Name=plot.Build.Fruit.Name,Tier=plot.Build.Fruit.Tier,Mutation=mutation.Name})
    local slow=(p.Boosts.PestUntil or 0)>now and C.Sabotage.PestRate or 1
    plot.NextDrop=now+V.DropInterval({plot.Build.Roots.Stat})/slow
   end end
  end
 end
 for fruit,r in W.Fruit do
  local player=r.Owner; local p=D.Get(player); local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not p or now-r.Born>=C.Runtime.FruitLifetime then W.Recycle(fruit)
  elseif root and D.Available(player) and now>=(r.ReadyAt or 0) and (root.Position-fruit.Position).Magnitude<=Game.Radius(p) then
   if Game.AddBag(p,r.Value,1,r.Metadata) then
    if p.Tutorial==3 then p.Tutorial=4 end
    if p.Onboarding==5 then p.Onboarding=6 end
    if Event.Current=="Golden Rain"and Journal.Event(p,Event.Current,Event.Starts)then Game.Toast(player,"Golden Rain keepsake earned! View Journal → Goals.")end
    Game.Feedback(player,"Collect",{Value=r.Value,Position=fruit.Position}); W.Recycle(fruit)
   elseif now>=(Game.Runtime[player].BagWarnAt or 0) then
    Game.Runtime[player].BagWarnAt=now+C.Inventory.FullWarningCooldown; Game.Feedback(player,"BagFull",{})
   end
  end
 end
end
function Game.Leave(player)
 local p=D.Get(player); if p then Game.Settle(player,os.time()); p.LastSeen=os.time(); D.Save(player,true) end
 W.Remove(player); Game.Runtime[player]=nil
end
return Game
