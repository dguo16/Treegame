-- Custody contracts: no duplicate use, exact recovery, safe migration and durable atomic edits.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local O=require(S.Util.PartOwnership)
local Growth=require(game.ServerScriptService.BuildATree.Services.GrowthService)
local Data=require(game.ServerScriptService.BuildATree.Services.DataService)
local Admin=require(game.ServerScriptService.BuildATree.Services.AdminService)
local Validate=require(S.Util.IntentValidator)
local Batch=require(S.Util.BatchCalculator)
local Game=require(game.ServerScriptService.BuildATree.Services.GameService)
local T={}
function T.Run()
 local n=0;local migrationReports={};local function check(v,msg)assert(v,msg);n+=1 end
 local function add(p,prefix)
  local b=P.Starter()
  for i,slot in C.Slots do local part=b[slot];part.Id=prefix..slot;part.Tier=2;part.Name=C.PartNames[slot][2];part.Stat=(1.21+i*.013)*(slot=="Roots"and C.Math.RootBase or 1);part.Mutation=C.Mutations[i+1].Name;table.insert(p.Parts,P.Copy(part))end
  p.Equipped=P.Copy(b);return b
 end
 local function fixture()local p=P.New(0);p.Rebirths=3;add(p,"a_");return p end
 check(C.Schema==11 and C.Rebirth.Threshold==1e9,"Single schema bump and unchanged first threshold")
 local p=fixture();local original=P.Copy(p.Parts)
 check(Growth.Plant(p,0),"Available parts plant")
 local id=p.Growth.Id
 for i,part in p.Parts do check(part.InUse==id and p.Growth.PartIds[part.Slot]==part.Id,"Every non-starter part is bound to the tree");check(O.Same(part,original[i])and part.Id==original[i].Id,"Plant preserves exact identity and stats")end
 check(O.Count(p)==4 and #p.Parts==4,"Locked parts remain in the counted inventory")
 check(not Growth.Plant(p,0)and not p.Growth2,"Double planting is rejected before another tree appears")
 check(not Growth.Queue(p,0)and #p.GrowthQueue==0,"Queue cannot reuse a locked build")
 for _,part in p.Parts do
  check(not O.Equip(p,part.Id),"Locked parts cannot be equipped again")
  O.Equip(p,"starter_"..part.Slot);local coins=p.Coins
  check(not O.Sell(p,part.Id)and p.Coins==coins,"Unequipping does not permit sale of an in-use part")
 end
 check(O.Label(p,p.Parts[1])=="In use: Growth Pad 1","Location hint names growth pad")
 check(Growth.Salvage(p,id,1)and p.Growth==nil and O.Count(p)==4,"Growing salvage removes tree and unlocks without adding rows")
 for i,part in p.Parts do check(not part.InUse and O.Same(part,original[i])and part.Id==original[i].Id,"Salvage preserves all mutations/stats/identities")end
 check(not Growth.Salvage(p,id,2)and #p.Parts==4,"Salvage replay cannot return parts twice")
 for pad=1,3 do for _,ready in {false,true}do
  p=fixture();for i=1,pad-1 do Growth.Set(p,i,Growth.New(P.Starter(),0,false))end
  check(Growth.Plant(p,0),"Each unlocked pad accepts a distinct build")
  id=Growth.Get(p,pad).Id;if ready then Growth.Finish(p,pad)end
  check(Growth.Salvage(p,id,10)and Growth.Get(p,pad)==nil,"Growing and ready salvage work on every pad")
  for _,part in p.Parts do check(not part.InUse,"Pad salvage clears all four locks")end
 end end
 p=fixture();Growth.Plant(p,0);Growth.Finish(p);id=p.Growth.Id
 check(Growth.Swap(p,1,6,1,false)and p.Plots[1].Id==id,"Placement retains the tree ID")
 check(O.Label(p,p.Parts[1])=="In use: Plot 1","Placed location hint names plot")
 check(not Growth.Plant(p,2),"Placed parts remain unavailable")
 check(Growth.Salvage(p,id,3)and not p.Plots[1],"Planted salvage removes the producer")
 for _,part in p.Parts do check(not part.InUse,"Producer salvage unlocks every held part")end
 -- Starter copies are unlimited; a mixed build only claims its real inventory part.
 p=P.New(0);p.Rebirths=3
 for _=1,3 do check(Growth.Plant(p,0),"All pads can use starter copies")end
 for _=1,3 do check(Growth.Queue(p,0),"All queue entries can use starter copies")end
 check(O.Count(p)==0,"Starter trees create no counted parts or locks")
 local qid=p.GrowthQueue[1].Id;Growth.Finish(p,2);Growth.Swap(p,1,6,1,false,2)
 check(p.Growth2.Id==qid,"FIFO start preserves the queued tree ID")
 check(Growth.CancelQueue(p,p.GrowthQueue[1].Id),"Starter queue cancel works")
 p=fixture();local one=P.Copy(p.Parts[1]);p.Equipped=P.Starter();p.Equipped.Trunk=one;Growth.Plant(p,0)
 check(p.Parts[1].InUse and not p.Parts[2].InUse and not p.Growth.PartIds.Leaves,"Mixed build locks only its non-starter part")
 -- Queue custody, offline settlement and skip identity cover all three pads.
 p=fixture();for pad=1,3 do Growth.Set(p,pad,Growth.New(P.Starter(),0,false))end
 check(Growth.Queue(p,0),"Queue binds an available build immediately")
 qid=p.GrowthQueue[1].Id
 for _,part in p.Parts do check(part.InUse==qid,"Queue entry owns its parts before growing")end
 check(O.Label(p,p.Parts[1])=="In use: Queue 1","Queued hint is explicit")
 check(Growth.CancelQueue(p,qid)and #p.GrowthQueue==0,"Queue cancel removes selected tree")
 for _,part in p.Parts do check(not part.InUse,"Queue cancel unlocks all parts")end
 Growth.Queue(p,0);qid=p.GrowthQueue[1].Id;Growth.Salvage(p,p.Growth3.Id,10)
 check(p.Growth3.Id==qid and p.Growth3.State=="Growing","Freed third pad starts the same queued record")
 Growth.Step(p,10000,1)
 check(p.Growth3.Id==qid and p.Growth3.State=="Ready","Offline settlement preserves custody and ID")
 check(not require(game.ServerScriptService.BuildATree.Services.PurchaseService).GrantGrow(p,qid,10000,180),"Ready tree keeps unused skip behavior")
 -- Replacement releases the old custody and transfers the ready record in one mutation.
 p=fixture();Growth.Plant(p,0);Growth.Finish(p);Growth.Swap(p,1,6,1,false);local oldId=p.Plots[1].Id
 add(p,"b_");Growth.Plant(p,2);Growth.Finish(p);local newId=p.Growth.Id
 local before=P.Copy(p)
 check(not Growth.Swap(p,1,6,3,false)and p.Plots[1].Id==oldId and p.Growth.Id==newId,"Unconfirmed replacement changes neither tree")
 check(Growth.Swap(p,1,6,3,true)and p.Plots[1].Id==newId,"Confirmed replacement transfers the same ready tree")
 for i=1,4 do check(not p.Parts[i].InUse and p.Parts[i+4].InUse==newId,"Only old tree locks release");check(O.Same(p.Parts[i],before.Parts[i]),"Replacement does not reroll recovered stats")end
 check(#p.Parts==8,"Replacement never duplicates inventory rows")
 -- Full inventory includes parts already deployed in trees.
 p=fixture();Growth.Plant(p,0)
 for i=5,500 do local part=P.Copy(p.Parts[1]);part.Id="filler_"..i;part.InUse=nil;table.insert(p.Parts,part)end
 local count=Batch.Choose(p.Rolls,1e20,3,1,C.Runtime.MaxInventory-O.Count(p))
 check(O.Count(p)==500 and count==0,"Batch sizing has zero space when deployed parts fill the inventory")
 check(Growth.Salvage(p,p.Growth.Id,2)and #p.Parts==500,"Salvage cannot overflow a full inventory")
 -- Legacy data: one matching tree, a repeated old copy, a missing copy and a starter tree.
 p=fixture();p.Schema=10;p.OwnershipVersion=nil
 p.Plots[1]={Build=P.Copy(p.Equipped),State="Producing",NextDrop=5}
 p.Plots[2]={Build=P.Copy(p.Equipped),State="Producing",NextDrop=6}
 local missing=P.Copy(p.Equipped);for _,slot in C.Slots do missing[slot].Id="missing_"..slot;missing[slot].Stat+=.001 end
 p.Plots[3]={Build=missing,State="Producing",NextDrop=7}
 p.Plots[4]={Build=P.Starter(),State="Producing",NextDrop=8}
 local preserved=P.Copy(p);P.Migrate(p,10);local report=p.OwnershipMigration;table.insert(migrationReports,P.Copy(report))
 check(report.Matched==4 and report.Ambiguous==4 and report.Missing==4 and report.Starter==4,"Migration reports matched, repeated ambiguous, missing and starter counts")
 check(report.Reserved==4 and #p.Parts==4 and O.Count(p)==8,"Missing tree copies reserve capacity without creating inventory rows")
 check(#O.Trees(p)==4 and p.Plots[3].NextDrop==7,"Migration never removes a tree or changes its timing")
 for i,part in p.Parts do check(part.Id==preserved.Parts[i].Id and O.Same(part,preserved.Parts[i]),"Migration preserves owned identity/stat/mutation")end
 local nextId=p.NextId;local firstId=p.Plots[1].Id
 P.Migrate(p,11);check(p.NextId==nextId and p.Plots[1].Id==firstId and p.OwnershipMigration.Matched==4,"Migration is idempotent")
 local reloaded=P.Migrate(game.HttpService:JSONDecode(game.HttpService:JSONEncode(p)),12)
 check(reloaded.Parts[1].InUse==firstId and O.Count(reloaded)==8,"Locks and legacy capacity survive save/load")
 check(Growth.Salvage(p,p.Plots[2].Id,20)and #p.Parts==4 and p.Parts[1].InUse==firstId,"Ambiguous repeated tree never duplicates or unlocks another tree's part")
 check(Growth.Salvage(p,p.Plots[3].Id,20)and #p.Parts==8 and O.Count(p)==8,"Missing legacy copies materialize only on salvage within reserved capacity")
 for _,part in p.Parts do if part.Id:match("^missing_")then check(part.Mutation==missing[part.Slot].Mutation and part.Stat==missing[part.Slot].Stat,"Missing legacy recovery preserves its data")end end
 p=fixture();p.OwnershipVersion=nil;p.Schema=1
 local ambiguous=P.Copy(p.Equipped);ambiguous.Trunk.Id=nil
 local duplicate=P.Copy(p.Parts[1]);duplicate.Id="second_trunk";table.insert(p.Parts,duplicate)
 p.Plots[1]={Build=ambiguous,State="Producing"};P.Migrate(p,1)
 check(p.OwnershipMigration.Ambiguous==1 and p.OwnershipMigration.Matched==3 and #p.Parts==5,"Ambiguous equal-stat candidates are not guessed or removed")
 table.insert(migrationReports,P.Copy(p.OwnershipMigration))
 -- New plot IDs must not displace an existing growth ID (including receipt targets).
 local collision=P.New(0);collision.Schema=10;collision.OwnershipVersion=nil
 collision.Plots[1]={Build=P.Starter(),State="Producing"}
 collision.Growth=Growth.New(P.Starter(),0,false,nil,"tree_1");P.Migrate(collision,1)
 check(collision.Growth.Id=="tree_1","Migration preserves pre-existing growth/receipt identity")
 check(collision.Plots[1].Id~="tree_1","Assigned plot ID cannot collide with a later growth record")
 local counter=collision.NextId;P.Migrate(collision,2);check(collision.NextId==counter,"Collision repair remains idempotent")
 -- Preserving a legacy save can reveal custody already above the modern cap.
 local full=fixture();for i=5,500 do local part=P.Copy(full.Parts[1]);part.Id="legacy_filler_"..i;table.insert(full.Parts,part)end
 local legacy=P.Starter();legacy.Trunk=P.Copy(full.Parts[1]);legacy.Trunk.Id="legacy_missing_trunk";legacy.Trunk.Stat+=.01
 full.Plots[1]={Build=legacy,State="Producing"};full.Schema=10;full.OwnershipVersion=nil;P.Migrate(full,1)
 check(#full.Parts==500 and O.Count(full)==501,"Legacy missing custody is reserved without stripping a full inventory")
 check(Batch.Choose(0,1e20,3,1,C.Runtime.MaxInventory-O.Count(full))==0,"Grandfathered excess blocks further rolls")
 check(Growth.Salvage(full,full.Plots[1].Id,2)and #full.Parts==501 and O.Count(full)==501,"Legacy recovery moves reserved custody without increasing counted ownership")
 check(full.Parts[501].Id==legacy.Trunk.Id and O.Same(full.Parts[501],legacy.Trunk),"Over-cap legacy recovery preserves the missing original")
 p.Coins=Game.AscensionThreshold(p);check(Game.RebirthProfile(p),"Ascension succeeds with custody data")
 check(#p.Parts==0 and #p.GrowthQueue==0 and next(p.Plots)==nil and p.Growth.Tutorial and p.OwnershipVersion==1,"Ascension clears parts, trees, queue and all old locks together")
 -- Admin gives new identities; it cannot overwrite one already in custody.
 p=fixture();Growth.Plant(p,0);local locked=P.Copy(p.Parts[1]);local owner={UserId=515156085}
 check(not Admin.Execute(owner,p,"AdminPart",{Slot="Trunk",Tier=7,Equip=true},function()return locked.Id end),"Admin collision cannot overwrite a deployed part")
 check(O.Same(p.Parts[1],locked)and p.Parts[1].InUse==locked.InUse and #p.Parts==4,"Rejected admin grant preserves locked ownership")
 -- Exact requests never accept client amounts, locations, part lists or ownership markers.
 for _,action in {"RequestSalvage","SalvageTree"}do local args=action=="RequestSalvage"and {TreeId="tree"}or {TreeId="tree",Token="server-token"}
  check(Validate(action,args),"Exact salvage request accepted")
  for _,key in {"Parts","Amount","Plot","InUse","Confirm","Refund"}do local forged=P.Copy(args);forged[key]=true;check(not Validate(action,forged),"Forged salvage field rejected")end
 end
 check(not Validate("SalvageTree",{TreeId="tree"})and not Validate("SalvageTree",{TreeId="tree",Token=0/0}),"Missing/invalid token rejected")
 -- Fake durable backend exercises callback retries, ambiguous failures and disconnect boundaries.
 local function durable(mode)
  local backend={Calls=0,Mode=mode}
  function backend:UpdateAsync(_,fn)
   self.Calls+=1
   if self.Armed and self.Mode=="before"then error("disconnect before write")end
   local result=fn(P.Copy(self.Record));if result then self.Record=P.Copy(result)end
   if self.Armed and self.Mode=="after"then error("disconnect after commit")end
   if self.Armed and self.Mode=="disconnect"then self.Player.Parent=nil end
   return P.Copy(result)
  end
  local d=Data.CreateForTests({Store=backend,Token="salvage-session",Now=function()return 100 end,Wait=function()end})
  local player={UserId=177,Parent=true,Kicks=0,Kick=function(self)self.Kicks+=1 end};backend.Player=player
  local profile=d.Load(player);local filled=fixture();for k,v in filled do profile[k]=v end;Growth.Plant(profile,0);d.Save(player);backend.Armed=true
  return d,backend,player,profile,profile.Growth.Id
 end
 for _,mode in {"ok","before","after","disconnect"}do
  local d,b,player,profile,treeId=durable(mode)
  local ok=d.Atomic(player,function(draft)return Growth.Salvage(draft,treeId,110)end)
  local stored=b.Record.Data
  if mode=="before"then check(not ok and stored.Growth and stored.Parts[1].InUse==treeId,"Pre-write disconnect retains both tree and locks")
  elseif mode=="after"then check(not ok and not stored.Growth and not stored.Parts[1].InUse,"Ambiguous committed disconnect stores both removal and unlock")
  else check(ok and not stored.Growth and not stored.Parts[1].InUse,"Successful or disconnected commit stores the entire salvage")end
  if mode=="before"or mode=="after"then check(not d.Available(player)and player.Kicks==1 and not d.Save(player),"Uncertain tree write closes session and cannot overwrite durable result")end
  check(#stored.Parts==4 and O.Same(stored.Parts[1],profile.Parts[1]),"No write boundary duplicates or rerolls a part")
  check(not d.Sessions[player].Busy,"Every save outcome releases the busy flag")
 end
 local d,b,player,profile,treeId=durable("ok");local coins=profile.Coins
 check(not d.Atomic(player,function(draft)Growth.Salvage(draft,treeId,110);error("interrupt midway")end),"Mid-mutation exception discards the draft")
 check(profile.Growth and profile.Parts[1].InUse==treeId and profile.Coins==coins,"Interrupted mutation exposes no partial salvage")
 local old=profile.Growth.Id
 check(not d.Atomic(player,function(draft)Growth.Salvage(draft,old,110);return false,"cancel"end)and profile.Growth.Id==old,"Cancelled transaction discards its staged changes")
 T.MigrationReports=migrationReports
 print("Build a Tree salvage: "..n.." checks passed");return n
end
return T
