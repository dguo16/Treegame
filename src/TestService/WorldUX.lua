-- Pure automatic-batch, empty-plot capability and persistent-ranking codec checks.
local S=game.ReplicatedStorage.BuildATree
local Batch=require(S.Util.BatchCalculator)
local P=require(S.Util.Profile)
local Placement=require(S.Util.PlacementRules)
local Scores=require(S.Util.LeaderboardScores)
local Validate=require(S.Util.IntentValidator)
local Tests={}
function Tests.Run()
 local checks=0;local function check(v,msg)assert(v,msg);checks+=1 end
 local n,cost=Batch.Choose(0,1000,1,1);check(n==1 and cost==10,"Starter roll maximum")
 n,cost=Batch.Choose(0,1000,2,1);check(n==5 and cost==66,"Five-roll maximum includes escalating prices")
 n,cost=Batch.Choose(0,65,2,1);check(n==4 and cost==49,"Partial affordable batch")
 n,cost=Batch.Choose(0,9,3,1);check(n==0 and cost==0,"Cannot afford first roll")
 n,cost=Batch.Choose(0,1000,3,1);check(n==10,"Highest unlocked batch")
 n,cost=Batch.Choose(0,1000,3,1,2);check(n==2 and cost==21,"Inventory space also bounds batch")
 check(not Validate("Roll",{Count=10}),"Client cannot choose roll count")
 check(not Validate("Swap",{Plot=1}),"Legacy swap remote is unavailable")
 check(Validate("PlaceTree",{Plot=2,GrowthId="ready"}),"Placement intent schema")
 check(not Validate("PlaceTree",{Plot=2,GrowthId="ready",Owner=123}),"Foreign target injection rejected")
 local p=P.New(0);p.Plots={{State="Producing"}};p.Growth={State="Ready",Id="ready"}
 local selection={GrowthId="ready",Expires=100,Plots={2,3}}
 check(#Placement.EmptyPlots(p,3)==2,"Only empty unlocked plots are offered")
 check(Placement.Validate(p,selection,2,"ready",3,50),"Empty plot accepted")
 check(not Placement.Validate(p,selection,1,"ready",3,50),"Occupied plot rejected")
 check(not Placement.Validate(p,selection,4,"ready",3,50),"Locked plot rejected")
 check(not Placement.Validate(p,selection,2,"foreign-tree",3,50),"Foreign/stale build rejected")
 check(not Placement.Validate(p,selection,2,"ready",3,101),"Expired capability rejected")
 check(not Placement.Validate(p,nil,2,"ready",3,50),"Cannot place without interaction")
 p.Growth.State="Growing";check(not Placement.Validate(p,selection,2,"ready",3,50),"Growing tree cannot be placed")
 local last=-1
 for _,value in {0,1,50,1000,1e6,1e9,1e15,1e30}do
  local encoded=Scores.Encode(value,"Coins");check(encoded%1==0 and encoded>last,"Ranking score is a monotonic integer");last=encoded
  local decoded=Scores.Decode(encoded,"Coins");check(math.abs(decoded-value)<=math.max(1e-6,value*1e-7),"Large coin score round-trip")
 end
 check(Scores.Decode(Scores.Encode(18.5,"Height"),"Height")==18.5,"Height precision preserved")
 local sorted=Scores.Sort({{UserId=2,Value=5},{UserId=1,Value=5},{UserId=3,Value=9}})
 check(sorted[1].UserId==3 and sorted[2].UserId==1,"Deterministic rank order")
 print("Build a Tree world UX: "..checks.." assertions passed");return checks
end
return Tests
