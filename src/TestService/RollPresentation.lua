-- Exact presentation odds and complete batch history without changing seeded awards.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local R=require(S.Util.RollEngine)
local D=require(S.Util.RollDisplay)
local Tests={}
function Tests.Run()
 local n=0;local function check(v,m)assert(v,m);n+=1 end
 local p=P.New(0);local part={Id="a",Slot="Fruit",Tier=1,Name="Apple",Stat=1,Mutation="None"}
 local shown=D.Result(part,D.Context(p,1,1))
 check(math.abs(shown.RollOdds.Chance-.04)<1e-12,"Apple None is 60% / 12 names times 80%")
 check(part.RollOdds==nil and shown~=part,"Feedback odds never pollute saved part")
 local golden=table.clone(part);golden.Mutation="Golden"
 check(math.abs(D.Result(golden,D.Context(p,1,1)).RollOdds.Chance-.006)<1e-12,"Named Golden includes independent mutation probability")
 p.Rolls=2;local context=D.Context(p,1,1);check(context.Minimum==3,"Third-roll Rare guarantee captured before roll")
 part.Tier=3;part.Name="Crystalberry";local rare=D.Result(part,context)
 check(math.abs(rare.RollOdds.Chance-(10/15)/12*.8)<1e-12,"Guaranteed roll displays conditional exact odds")
 p.Rolls=100;p.EpicPity=49;check(D.Context(p,1,1).Minimum==4,"Epic pity captured")
 p.LegendaryPity=299;check(D.Context(p,1,1).Minimum==5,"Strongest pity captured")
 local a,b=P.New(0),P.New(0);local ra,rb=Random.new(917),Random.new(917)
 for i=1,310 do
  local snapshot=D.Context(a,2.72,1);local first=R.Roll(ra,a,2.72,tostring(i),1);local display=D.Result(first,snapshot);local second=R.Roll(rb,b,2.72,tostring(i),1)
  check(first.Name==second.Name and first.Stat==second.Stat and first.Mutation==second.Mutation and first.Tier==second.Tier,"Presentation consumes no award randomness")
  check(display.RollOdds.Chance>0 and display.RollOdds.Chance<=1 and display.RollOdds.Minimum==snapshot.Minimum,"Every batch award has its own eligible snapshot")
 end
 check(a.Rolls==b.Rolls and a.EpicPity==b.EpicPity and a.LegendaryPity==b.LegendaryPity,"Presentation leaves progression and pity unchanged")
 check(D.OddsText(rare):find("Name + mutation",1,true)~=nil,"Odds scope is disclosed")
 check(D.OddsText(part)=="Odds unavailable for this earlier roll","Missing historical odds are not invented")
 local batch={};for i=1,10 do local x=table.clone(part);x.Id=tostring(i);x.Tier=i==8 and 7 or 1;table.insert(batch,x)end
 local history={};D.Remember(history,batch);check(#history==10 and history[8].Id=="8","All ten awards retained in order")
 check(D.Best(batch).Id=="8","Best display does not hide batch awards")
 local x=table.clone(part);x.Mutation="Cosmic";check(D.Best({part,x})==x,"Mutation breaks equal-rarity highlight tie")
 for i=11,110 do local q=table.clone(part);q.Id=tostring(i);D.Remember(history,{q})end
 check(#history==100 and history[1].Id=="11"and history[100].Id=="110","Recent history bounded at 100, oldest evicted")
 check(C.Schema==11 and C.Runtime.RollCooldown==2.5,"Current schema and unchanged server cooldown")
 print("Build a Tree roll presentation: "..n.." checks passed");return n
end
return Tests
