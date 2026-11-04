-- Production RNG/pity cross-check of the independent coupon expectation report.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local R=require(S.Util.RollEngine)
local J=require(S.Util.Journal)
local K=require(S.Util.Collection)
local A={}
function A.Run(luck,seeds)
 local finishes,mutations={},{};local reached=0
 for seed=1,seeds or C.Collection.AnalysisSeeds do
  local p=P.New(0);J.Scan(p);local rng=Random.new(seed);local finished
  for n=1,C.Collection.AnalysisRollLimit do
   local part=R.Roll(rng,p,luck,tostring(n));J.Discover(p,part)
   if not finished and K.Progress(p,K.Find("CoreNames48"))==48 then finished=n;table.insert(finishes,n);reached+=1 end
   if n==1000 then local sets=0;for _,g in K.Goals()do if g.Kind=="Mutation"and K.Progress(p,g)==g.Need then sets+=1 end end;table.insert(mutations,sets)end
   if n>=1000 and finished then break end
   if n%200==0 then task.wait()end
  end
 end
 table.sort(finishes);table.sort(mutations);local total=0;for _,n in finishes do total+=n end
 return {Luck=luck,Seeds=seeds or C.Collection.AnalysisSeeds,Reached=reached,MeanReached=total/math.max(1,#finishes),MedianReached=finishes[math.ceil(#finishes/2)],P90Reached=finishes[math.ceil(#finishes*.9)],MedianMutationSetsAt1000=mutations[math.ceil(#mutations/2)],RollLimit=C.Collection.AnalysisRollLimit,FreeStarters=true,Pity=true,FixedLuck=true}
end
return A
