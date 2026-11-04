-- Live, memory-only authority and world cleanup. Called through the normal Studio harness.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local O=require(S.Util.PartOwnership)
local Growth=require(game.ServerScriptService.BuildATree.Services.GrowthService)
local T={}
function T.Run(Game,D,W,player)
 assert(not D.Persistent(player),"Salvage live checks require an isolated memory-only profile")
 local session=D.Sessions[player];local saved=session.Profile;local runtime=P.Copy(Game.Runtime[player]);local position=player.Character:GetPivot()
 local n=0;local function check(v,msg)assert(v,msg);n+=1 end
 local ok,err=pcall(function()
  local p=P.New(os.time());p.Rebirths=3;p.Upgrades.Plots=6
  for i,slot in C.Slots do local part=P.Copy(p.Equipped[slot]);part.Id="live_"..slot;part.Stat+=.001*i;part.Mutation=C.Mutations[i+1].Name;table.insert(p.Parts,part);p.Equipped[slot]=P.Copy(part)end
  session.Profile=p;local rt=Game.Runtime[player];rt.Salvage=nil;rt.SalvageAt=0;rt.SalvageRequestAt=0
  local garden=W.Gardens[player];player.Character:PivotTo(CFrame.new(garden.Origin+Vector3.new(0,4,20)))
  check(Game.Intent(player,"Plant",{}),"Live plant saves custody")
  local treeId=p.Growth.Id;local coins=p.Coins;local before=P.Copy(p.Parts)
  check(not Game.Intent(player,"Plant",{})and not p.Growth2,"Live double plant refused")
  for _,part in p.Parts do check(not Game.Intent(player,"Equip",{Id=part.Id}),"Live locked equip refused");O.Equip(p,"starter_"..part.Slot);check(not Game.Intent(player,"SellPart",{Id=part.Id}),"Live locked sale refused after unequip")end
  check(not Game.Intent(player,"SalvageTree",{TreeId=treeId,Token="forged"}),"Forged confirmation refused")
  check(not Game.Intent(player,"RequestSalvage",{TreeId=treeId,Amount=999}),"Forged extra field refused at service boundary")
  player.Character:PivotTo(CFrame.new(garden.Origin+Vector3.new(200,4,0)))
  check(not Game.RequestSalvage(player,treeId),"Salvage request requires own-garden proximity")
  player.Character:PivotTo(CFrame.new(garden.Origin+Vector3.new(0,4,20)))
  check(Game.RequestSalvage(player,treeId),"Server issues confirmation for an owned growing tree")
  local token=rt.Salvage.Token
  check(not Game.RequestSalvage(player,treeId)and rt.Salvage.Token==token,"Repeated request respects semantic rate limit")
  check(not Game.Salvage(player,treeId,"forged")and p.Growth.Id==treeId,"Wrong token preserves growing tree")
  rt.Salvage.Expires=0;check(not Game.Salvage(player,treeId,token),"Expired token cannot salvage")
  rt.SalvageRequestAt=0;Game.RequestSalvage(player,treeId);token=rt.Salvage.Token
  player.Character:PivotTo(CFrame.new(garden.Origin+Vector3.new(200,4,0)))
  check(not Game.Salvage(player,treeId,token),"Confirmation rechecks garden proximity")
  player.Character:PivotTo(CFrame.new(garden.Origin+Vector3.new(0,4,20)))
  check(Game.Intent(player,"SalvageTree",{TreeId=treeId,Token=token})and not p.Growth,"Growing salvage commits through live exact intent")
  check(p.Coins==coins and #p.Parts==4,"Live salvage pays no refund and creates no duplicate rows")
  for i,part in p.Parts do check(not part.InUse and part.Id==before[i].Id and O.Same(part,before[i]),"Live salvage preserves every part")end
  check(not Game.Salvage(player,treeId,token),"Consumed token cannot replay")
  check(not Game.RequestSalvage(player,treeId),"Committed salvage starts its cooldown")
  for _,part in p.Parts do O.Equip(p,part.Id)end;Game.Intent(player,"Plant",{});Growth.Finish(p);treeId=p.Growth.Id
  Game.Tick();check(garden.Models[7].PrimaryPart.TreeInfo:GetAttribute("OwnerUserId")==player.UserId,"Growth info prompt is owner-bound")
  rt.SalvageAt=0;rt.SalvageRequestAt=0;check(Game.RequestSalvage(player,treeId),"Ready tree can be salvaged")
  Game.Intent(player,"CancelPlacement",{});check(rt.Salvage==nil,"Cancel invalidates salvage capability")
  rt.SalvageRequestAt=0;Game.RequestSalvage(player,treeId);token=rt.Salvage.Token
  Growth.Swap(p,1,6,os.time(),false);check(not Game.Salvage(player,treeId,token),"A tree moved after confirmation must be inspected again")
  p.Plots[2]={Id="other-live-tree",Build=P.Starter(),State="Producing",NextDrop=os.time()+100};p.Plots[1].NextDrop=os.time()+100
  Game.Tick();check(garden.Models[1].PrimaryPart.TreeInfo.ActionText=="Tree info / Salvage","Production tree exposes info and salvage")
  local first=W.SpawnFruit(player,1,7,C.Mutations[1],os.time());local other=W.SpawnFruit(player,2,9,C.Mutations[1],os.time())
  rt.SalvageRequestAt=0;check(Game.RequestSalvage(player,treeId),"Production tree has confirmation")
  token=rt.Salvage.Token;check(Game.Salvage(player,treeId,token),"Production salvage commits")
  check(not p.Plots[1]and p.Plots[2]and not W.Fruit[first]and W.Fruit[other],"Salvage clears only the removed producer and its outstanding fruit")
  check(not garden.Models[1],"Removed producer world model is invalidated")
  if W.Fruit[other]then W.Recycle(other)end
  -- Ready salvage itself (without placing) and full-inventory rolls are separate contracts.
  for _,part in p.Parts do O.Equip(p,part.Id)end;Game.Intent(player,"Plant",{});Growth.Finish(p);treeId=p.Growth.Id
  rt.SalvageAt=0;rt.SalvageRequestAt=0;Game.RequestSalvage(player,treeId)
  check(Game.Salvage(player,treeId,rt.Salvage.Token)and not p.Growth,"Ready salvage removes its pad tree")
  for i=5,500 do local part=P.Copy(p.Parts[1]);part.Id="live-filler-"..i;part.InUse=nil;table.insert(p.Parts,part)end
  for _,part in p.Parts do if part.Id=="live_Trunk"then p.Equipped.Trunk=P.Copy(part)end end
  check(Game.Intent(player,"Plant",{}),"A full inventory can plant a held part")
  p.Coins=1e9;rt.RollAt=0;check(not Game.Roll(player,false)and #p.Parts==500,"Live rolls include all deployed parts in the 500 limit")
  rt.SalvageAt=0;rt.SalvageRequestAt=0;treeId=p.Growth.Id;Game.RequestSalvage(player,treeId)
  check(Game.Salvage(player,treeId,rt.Salvage.Token)and #p.Parts==500,"Live full-inventory salvage stays within counted capacity")
 end)
 session.Profile=saved;Game.Runtime[player]=runtime;player.Character:PivotTo(position)
 for i=1,9 do W.Invalidate(player,i)end;W.ClearPlotFruit(player,1)
 if not ok then error(err)end
 print("Build a Tree salvage live: "..n.." checks passed");return n
end
return T
