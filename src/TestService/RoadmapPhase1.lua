-- Replacement regressions derive from the confirmed, no-loss placement contract.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local Growth=require(game.ServerScriptService.BuildATree.Services.GrowthService)
local Rules=require(S.Util.PlacementRules)
local Validate=require(S.Util.IntentValidator)
local R=require(S.Util.RollEngine)
local Tests={}
function Tests.Run()
 local checks=0;local function check(v,msg)assert(v,msg);checks+=1 end
 local function fixture()
  local p=P.New(0);local b=P.Starter()
  for _,slot in C.Slots do b[slot].Id="old_"..slot;b[slot].Mutation="Golden";b[slot].Stat+=.01 end
  p.Plots[1]={Build=b,State="Producing",NextDrop=10,HeightScale=1.25}
  p.Growth=Growth.New(p.Equipped,0,false);Growth.Finish(p)
  return p
 end
 local function selection(p)
  local plots,targets=Rules.Choices(p,2)
  return {GrowthId=p.Growth.Id,Plots=plots,Targets=targets,Expires=100}
 end
 local p=fixture();local s=selection(p);local old=p.Plots[1];local ready=p.Growth
 check(#s.Plots==2 and s.Targets[1]==old and s.Targets[2]==false,"Offer occupied and empty unlocked plots")
 check(not Rules.Validate(p,s,1,ready.Id,2,1),"Occupied plot needs confirmation")
 check(Rules.Validate(p,s,1,ready.Id,2,1,true),"Explicit confirmation accepts unchanged target")
 check(not Rules.Validate(p,s,1,ready.Id,2,100,true),"Capability expires exactly at deadline")
 check(not Rules.Validate(p,s,3,ready.Id,2,1,true),"Confirmation cannot unlock plots")
 check(not Growth.Swap(p,1,2,1),"Unconfirmed service call is rejected")
 check(p.Plots[1]==old and p.Growth==ready and #p.Parts==0,"Failed replacement changes nothing")
 check(Growth.Swap(p,1,2,1,true),"Confirmed replacement succeeds")
 check(p.Growth==nil and p.Plots[1].Build.Trunk.Id==ready.Build.Trunk.Id,"Ready tree replaces selected plot")
 check(p.Plots[1].HeightScale==ready.HeightScale,"Replacement preserves sampled height")
 check(#p.Parts==4 and p.Parts[1].Mutation=="Golden" and p.Parts[1].Stat==old.Build.Trunk.Stat,"Four missing parts return without rerolling")
 check(not Growth.Swap(p,1,2,1,true) and #p.Parts==4,"Concurrent duplicate request grants no extra parts")
 p=fixture();p.Parts={P.Copy(p.Plots[1].Build.Trunk)};p.Equipped.Trunk=P.Copy(p.Parts[1])
 check(#Growth.ReturnParts(p,1)==3,"Existing/equipped inventory part is not duplicated")
 check(Growth.Swap(p,1,2,1,true) and #p.Parts==4 and p.Equipped.Trunk.Id=="old_Trunk","Equipped part remains equipped exactly once")
 p=fixture();for i=1,497 do p.Parts[i]={Id="filler"..i}end;old=p.Plots[1];ready=p.Growth
 check(not Growth.Swap(p,1,2,1,true),"497 plus four rejects inventory overflow")
 check(p.Plots[1]==old and p.Growth==ready and #p.Parts==497,"Inventory-full refusal is atomic")
 p.Parts[497]=nil;check(Growth.Swap(p,1,2,1,true) and #p.Parts==500,"Exactly 500 inventory parts is allowed")
 p=fixture();for i=1,500 do p.Parts[i]={Id="filler"..i}end
 for i,slot in C.Slots do p.Parts[i]=P.Copy(p.Plots[1].Build[slot])end
 check(Growth.Swap(p,1,2,1,true) and #p.Parts==500,"Full inventory succeeds when old identities already exist")
 p=fixture();p.Plots[1].Build=P.Starter();check(#Growth.ReturnParts(p,1)==0,"Starter parts remain free rather than sellable copies")
 p=fixture();s=selection(p);local id=p.Growth.Id;p.Plots[1]=P.Copy(p.Plots[1])
 check(not Rules.Validate(p,s,1,id,2,1,true),"Target replacement since selection invalidates capability")
 p=fixture();s=selection(p);p.Growth.Id="new"
 check(not Rules.Validate(p,s,1,s.GrowthId,2,1,true),"Stale ready-tree ID invalidates confirmation")
 check(Validate("ReplaceTree",{Plot=1,GrowthId="g",Token="t"}),"Replacement exact schema accepted")
 check(not Validate("ReplaceTree",{Plot=1,GrowthId="g",Token="t",Confirm=true}),"Client cannot add authoritative confirmation flag")
 check(not Validate("ReplaceTree",{Plot=1,GrowthId="g"}),"Token is required")
 check(not Validate("ReplaceTree",{Plot=0/0,GrowthId="g",Token="t"}),"NaN target rejected")
 local cost=R.Cost(299,1)
 check(cost<=C.Roll.HardCap and R.Cost(100000,1)==C.Roll.HardCap,"Late roll cost has a hard cap")
 local total=0;for n=0,299 do total+=R.Cost(n,1)end
 check(total>=C.Rebirth.Threshold*.05 and total<=C.Rebirth.Threshold*.1,"300-roll cost is five to ten percent of first Ascension")
 check(R.Cost(299,.7)<=cost*.7+1,"Discount still applies at price cap")
 -- Both growth pads share settlement, validation and receipt identity rules.
 p=P.New(0);check(Growth.MaxPads(p)==1,"New free players start with one pad")
 p.Rebirths=1;check(Growth.MaxPads(p)==2,"First Ascension unlocks second pad")
 p.Rebirths=0;p.Schema=7;p.Passes.ExtraPlots=true;P.Migrate(p,0);check(Growth.MaxPads(p)==3 and p.LegacySecondPad,"Old entitlement migrates to third pad without losing old pad access")
 p.Passes.ThirdPad=false;p.LegacySecondPad=nil;p.Rebirths=1
 check(Growth.Plant(p,0) and Growth.Plant(p,0),"Both free unlocked pads can grow simultaneously")
 check(p.Growth and p.Growth2 and p.Growth.Id~=p.Growth2.Id,"Growth pads have independent immutable IDs")
 local first=p.Growth.Id;local second=p.Growth2.Id
 check(not Growth.Plant(p,0),"Plant never overwrites occupied pads")
 check(Growth.Queue(p,0) and Growth.Queue(p,0),"Two equipped-build snapshots can be queued")
 local queuedId=p.GrowthQueue[1].Id;local queuedStat=p.GrowthQueue[1].Build.Trunk.Stat
 p.Equipped.Trunk.Stat=99
 check(p.GrowthQueue[1].Build.Trunk.Stat==queuedStat,"Queued build is independent of subsequent equipment changes")
 check(not Growth.Queue(p,0) and #p.GrowthQueue==2,"Queue has a strict two-build bound")
 check(not Growth.CancelQueue(p,"foreign"),"Cannot cancel by forged queue identity")
 check(Growth.CancelQueue(p,p.GrowthQueue[2].Id) and #p.GrowthQueue==1,"Cancel removes exactly the selected queued identity")
 check(not Growth.CancelQueue(p,p.GrowthQueue[1].Id.."old"),"Stale cancellation leaves remaining build intact")
 Growth.Step(p,10000,1)
 check(p.Growth.State=="Ready" and p.Growth2.State=="Ready","Offline-style settlement completes both pads")
 check(#p.GrowthQueue==1,"Ready trees keep their pads until explicit placement")
 local two={GrowthId=second,GrowthPad=2,Expires=20000,Plots={1},Targets={[1]=false}}
 check(Rules.Validate(p,two,1,second,1,10001),"Second-pad capability targets the second ready tree")
 check(not Rules.Validate(p,two,1,first,1,10001),"Capability cannot substitute first-pad ID")
 check(Growth.Swap(p,1,1,10001,false,2),"Second-pad ready tree can be planted")
 check(p.Growth.Id==first and p.Growth2.State=="Growing" and p.Growth2.Build.Trunk.Stat==queuedStat,"Placement starts FIFO snapshot on vacated pad, preserving other pad")
 check(#p.GrowthQueue==0 and p.Growth2.Settled==10001,"Queue starts at placement time without retroactive growth")
 p.Growth2.HeightScale=1.37
 local migrated=P.Migrate(game.HttpService:JSONDecode(game.HttpService:JSONEncode(p)),10001)
 check(migrated.Schema==C.Schema and migrated.Growth2.HeightScale==1.37,"Schema 4 round-trip preserves second-pad height and state")
 local legacy=P.New(0);legacy.Schema=3;legacy.GrowthQueue=nil;legacy.Growth=Growth.New(legacy.Equipped,0,false)
 local oldId=legacy.Growth.Id;P.Migrate(legacy,10)
 check(legacy.Schema==C.Schema and #legacy.GrowthQueue==0 and legacy.Growth.Id==oldId,"Schema 3 saves migrate without rerolling or losing existing growth")
 local Purchase=require(game.ServerScriptService.BuildATree.Services.PurchaseService)
 check(not Purchase.GrantGrow(p,first,10001,180),"Already-ready first pad does not consume a skip")
 check(Purchase.GrantGrow(p,p.Growth2.Id,10001,180) and p.Growth2.State=="Ready","Receipt binds to second pad by tree ID")
 check(p.Growth.Id==first,"Second-pad skip does not mutate first-pad identity")
 check(Validate("QueueTree",{}) and not Validate("QueueTree",{Build={}}),"Queue accepts intent only, never a client-owned build")
 check(Validate("CancelQueuedTree",{QueueId=queuedId}) and not Validate("CancelQueuedTree",{Index=1}),"Queue cancellation binds immutable identity")
 local Models=require(S.Util.PreviewModels)
 for tier=3,7 do for _,slot in C.Slots do
  local model=Models.Part({Id="visual",Slot=slot,Tier=tier,Name=C.PartVariants[slot][tier][1],Mutation="None"})
  local count=0;for _,part in model:GetDescendants()do if part.Name=="RarityAccent"then count+=1 end end
  if tier<=4 then
   check(count==0 and model:FindFirstChildWhichIsA("MeshPart",true)~=nil,"Authored Rare/Epic silhouettes replace procedural accents")
  else check(count==tier-2 and count<=C.RarityEffects.MaxAccentParts,"Procedural accents scale with rarity within fixed budget")end
  model:Destroy()
 end end
 local fancy=P.Starter();fancy.Trunk.Tier=7;fancy.Trunk.Name=C.PartNames.Trunk[7]
 local tree=Models.Tree(fancy,1,true)
 check(tree.PrimaryPart.RarityAura.Rate<=C.RarityEffects.MaxAuraRate,"At most one bounded rarity aura per world tree")
 check(tree:FindFirstChild("RarityGlow")~=nil,"Legendary-plus builds have a readable rarity outline")
 tree:Destroy()
 check(P.New(0).Settings.ReducedEffects==false,"Reduce-effects preference migrates with safe default")
 print("Build a Tree roadmap phase 1: "..checks.." assertions passed");return checks
end
return Tests
