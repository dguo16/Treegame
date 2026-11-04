local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local V=require(S.Util.ValueCalculator)
local G=require(S.Util.GrowthCalculator)
local R=require(S.Util.RollEngine)
local J=require(S.Util.Journal)
local A=require(S.Util.AscensionRules)
local Catalog=require(S.Util.PartCatalog)
local Growth=require(game.ServerScriptService.BuildATree.Services.GrowthService)
local Game=require(game.ServerScriptService.BuildATree.Services.GameService)
local Validate=require(S.Util.IntentValidator)
local T={}
function T.Run()
 local count=0;local function check(v,m)assert(v,m);count+=1 end
 local function near(a,b)return math.abs(a-b)<math.max(1,math.abs(b))*1e-8 end
 local function build(tier)
  local b=P.Starter();local r=C.Rarities[tier]
  for _,slot in C.Slots do b[slot].Tier=tier;b[slot].Stat=(r.Min+r.Max)/2*(slot=="Roots"and C.Math.RootBase or 1);b[slot].Name=C.PartNames[slot][tier]end
  return b
 end
 local previous=nil;local commonIncome=nil
 for tier=1,7 do local b=build(tier);local rate=V.Build(b,1)/V.Interval(b)
  check(near(Catalog.Power(b.Trunk),C.Economy.RarityFactor^(tier-1)),"Rarity power comes from Config")
  check(G.Tier(b)==tier and G.BuildTime(b,1)==G.GrowTime(tier,1),"Uniform build time retains rarity duration")
  if previous then check(rate/previous>=2 and rate/previous<=3,"Each full-tier upgrade yields 2-3x baseline income")else commonIncome=rate end
  previous=rate
  for _,slot in C.Slots do
   local weak=build(1);local strong=P.Copy(weak);strong[slot]=P.Copy(b[slot])
   check(V.Build(strong,1)/V.Interval(strong)>=V.Build(weak,1)/V.Interval(weak),"Every higher slot is useful: "..slot)
  end
 end
 check(previous/commonIncome>=100 and previous/commonIncome<=300,"Godly/Common whole-build income ratio is 100-300")
 check(V.Interval(build(7))==C.Math.MinInterval,"Godly Roots reach cadence floor")
 local b=P.Starter();local plain=V.Build(b,1)
 check(V.Build(b,1,1,1,1,nil,2)==plain*2 and C.Upgrades.LeafPower.Prices[1]==25,"First Leaf Power is an affordable doubling")
 for level,m in C.Upgrades.LeafPower.Values do check(V.Build(b,1,1,1,1,nil,m)==plain*m,"Leaf Power multiplies total value at every level")end
 check(C.Upgrades.LeafPower.Prices[#C.Upgrades.LeafPower.Prices]<C.Rebirth.Threshold,"Final Leaf Power costs less than first Ascension")
 for _,slot in C.Slots do
  b=P.Starter();b[slot].Mutation="Cosmic"
  for _,m in C.Mutations do check(V.Mutation(b,m.Mult)<=C.Economy.MutationCeiling,"Combined mutation is bounded for every slot and harvest")end
 end
 b=build(1);for _,slot in C.Slots do b[slot].Mutation="Cosmic"end
 check(V.Mutation(b,50)==2 and V.Build(b,50)/V.Interval(b)<V.Build(build(2),1)/V.Interval(build(2)),"Maximum mutations cannot beat the next full rarity tier")
 b=P.Starter();b.Trunk=build(7).Trunk
 check(G.Tier(b)==2 and G.Height(b,1)==15,"Mixed build height/label retain floor-average tier")
 check(G.BuildTime(b,1)==600 and Growth.New(b,0,false).Duration==600,"Godly trunk no longer grows in ten seconds")
 check(Growth.New(b,0,true).Duration==5,"Tutorial keeps five-second duration")
 local price=0;local total=0
 for n=0,299 do local cost=R.Cost(n,1);check(cost>=price and cost<=C.Roll.HardCap,"Roll curve rises without overflow");price=cost;total+=cost end
 check(total>=5e7 and total<=1e8,"First 300 rolls cost five to ten percent of 1B")
 check(R.Cost(49,1)==9423 and R.Cost(50,1)==10836 and R.Cost(51,1)>R.Cost(50,1),"Early prices preserved and slow growth continues past fifty")
 check(R.Cost(1e30,1)==C.Roll.HardCap and R.Cost(1e30,.7)==math.floor(C.Roll.HardCap*.7),"Huge counters safely hit discounted cap")
 for schema=3,5 do
  local p=P.New(10);p.Schema=schema;p.Saplings=9;p.Rebirths=3;p.Upgrades.LeafPower=6
  local part=build(7).Fruit;part.Id="preserved";part.Mutation="Cosmic";p.Parts={P.Copy(part)};p.Equipped.Fruit=P.Copy(part)
  p.Growth=Growth.New(p.Equipped,0,false);p.Growth.Duration=123;p.Growth.HeightScale=1.37
  p.Growth2=Growth.New(p.Equipped,0,false);p.GrowthQueue={{Id="q",Build=P.Copy(p.Equipped)}}
  J.Discover(p,part);p.Journal.Claims.Rolls10=true;p.Journal.Daily.Claims.DailyRolls=true
  p.Journal.Reference=nil;p.Journal.Paid=nil;p.Journal.RewardLog=nil
  local migrated=P.Migrate(game.HttpService:JSONDecode(game.HttpService:JSONEncode(p)),20)
  check(migrated.Schema==C.Schema and migrated.Saplings==9 and migrated.Rebirths==3,"Schema migration preserves permanent progression")
  check(migrated.Parts[1].Id=="preserved"and migrated.Parts[1].Mutation=="Cosmic"and migrated.Parts[1].Stat==part.Stat,"Schema migration never rerolls parts")
  check(migrated.Upgrades.LeafPower==6,"Bought Leaf Power levels remain owned")
  check(migrated.Journal.Claims.Rolls10 and migrated.Journal.Daily.Claims.DailyRolls,"Old lifetime and daily claims stay consumed")
  check(migrated.Journal.Paid.Rolls10==nil and #migrated.Journal.RewardLog==0,"Historical payout amounts are not invented")
  check(migrated.Growth.Duration==123 and migrated.Growth.HeightScale==1.37 and migrated.Growth2 and migrated.GrowthQueue[1].Id=="q","In-flight tree duration, heights, pads and queue survive")
 end
 local p=P.New(0);J.Login(p,0)
 check(J.Quote(p,"DailyLogin")==125 and J.Quote(p,"DailyRolls")==100,"Static floors keep empty gardens rewarded")
 p.Plots={{Build=build(4),State="Producing",NextDrop=0}};p.Upgrades.LeafPower=4
 local ref=J.ObserveIncome(p,1);local expected=V.Build(p.Plots[1].Build,1,1,1,1,nil,8)/V.Interval(p.Plots[1].Build)
 check(near(ref,expected),"Reference uses baseline producing garden")
 p.Passes.Coins=true;p.Passes.VIP=true;p.Pets={{Id="pet",Tier=3,Rarity=5,Shiny=true}};p.EquippedPets={"pet"};p.Boosts.TrapUntil=10000
 check(J.BaseIncome(p)==ref,"Paid, pet and temporary effects do not raise reference")
 local oldBuild=p.Plots[1].Build;p.Plots[1].Build=P.Starter()
 check(J.ObserveIncome(p,2)==ref,"Weak build swap cannot reduce recent reference")
 check(J.ObserveIncome(p,C.Rewards.ReferenceSeconds+2)<ref,"Reference expires only after configured recent window")
 p.Plots[1].Build=oldBuild;ref=J.ObserveIncome(p,C.Rewards.ReferenceSeconds+3)
 for _,days in {1,4,7,20}do
  p.Journal.LoginDays=days
  local seconds=300+300*math.clamp((days-1)/6,0,1)
  check(J.Quote(p,"DailyLogin")==math.floor(math.max(J.LoginCoins(p),ref*seconds)),"Login scales from five to ten minutes without streak punishment")
 end
 for _,goal in J.DailyGoals()do check(J.Quote(p,goal.Key)==math.floor(math.max(goal.Coins,ref*C.Rewards.DailySeconds[goal.Key])),"Each daily quest scales by configured minutes")end
 for _,metric in {"Rolls","Sold","Plants","TotalCoins"}do
  check(#C.Rewards.Milestones[metric]==4,"Each lifetime family has four configured steps")
  for i,v in C.Rewards.Milestones[metric]do check(J.Quote(p,metric..v[1])==math.floor(math.min(C.Rewards.MaxRewardCoins,math.max(v[2],ref*C.Rewards.MilestoneSeconds[i]))),"Each milestone amount uses claim-time reference")end
 end
 check(J.Quote(p,"Index12")==nil and J.Quote(p,"Index420")==nil,"Legacy count rewards are replaced by collection sets")
 check(J.Quote(p,"forged")==nil and not Validate("ClaimJournal",{Key="DailyLogin",Income=1e30}),"Unknown reward and forged income rejected")
 p=P.New(0);p.Saplings=1e10;p.Upgrades.LeafPower=6;p.Plots={{Build=build(7)}}
 check(J.ObserveIncome(p,1)==C.Rewards.MaxReferenceIncome,"Reference has an absolute income cap")
 J.Login(p,1);p.Journal.Totals.Rolls=1000
 check(J.Quote(p,"Rolls1000")==C.Rewards.MaxRewardCoins,"Reward has an absolute coin cap")
 local before=p.Coins;local ok=J.Claim(p,"Rolls1000",2)
 check(ok and p.Coins-before==C.Rewards.MaxRewardCoins,"Capped reward is computed on server at claim")
 check(p.Journal.Paid.Rolls1000==p.Coins-before and p.Journal.RewardLog[1].Paid==p.Coins-before,"Actual paid amount persists with bounded audit record")
 check(not J.Claim(p,"Rolls1000",2)and #p.Journal.RewardLog==1,"Claim replay grants and logs nothing")
 p.Coins=C.Runtime.MaxCoins;J.Claim(p,"DailyLogin",2)
 check(p.Journal.Daily.Paid.DailyLogin==0 and p.Journal.RewardLog[2].Paid==0,"Audit records actual wallet delta at coin ceiling")
 for day=1,C.Rewards.AuditLimit+3 do J.Claim(p,"DailyLogin",day*86400)end
 check(#p.Journal.RewardLog==C.Rewards.AuditLimit,"Audit storage remains bounded")
 local encoded=game.HttpService:JSONDecode(game.HttpService:JSONEncode(p));P.Migrate(encoded,200*86400)
 check(encoded.Journal.Paid.Rolls1000==C.Rewards.MaxRewardCoins and #encoded.Journal.RewardLog==C.Rewards.AuditLimit,"Reward audit survives save roundtrip")
 local days=p.Journal.LoginDays;J.Login(p,1000*86400);check(p.Journal.LoginDays==days+1,"Long absence never resets return count")
 p=P.New(0);check(A.Threshold(p)==1e9,"First Ascension threshold remains exactly 1B")
 for n=0,4 do p.Rebirths=n;check(near(A.Threshold(p),1e9*1.3^n),"Later thresholds follow Config")end
 p.Rebirths=1e30;check(near(A.Threshold(p),C.Runtime.MaxCoins),"Enormous Ascension counts stay finite at the coin limit")
 local factor=C.Rebirth.ThresholdGrowth;C.Rebirth.ThresholdGrowth=1;local flat=A.Threshold(p);C.Rebirth.ThresholdGrowth=factor
 check(flat==C.Rebirth.Threshold,"Threshold growth can be retuned to one without division by zero")
 p=P.New(0);p.Coins=1e9;p.Journal.Reference={Income=1000,At=os.time()};p.Journal.Claims.Rolls10=true;p.Journal.Paid.Rolls10=300000
 check(Game.RebirthProfile(p,false)and p.Saplings==1 and p.Rebirths==1,"Ascension still grants earned Saplings")
 check(p.Journal.Reference.Income==1000 and p.Journal.Claims.Rolls10 and p.Journal.Paid.Rolls10==300000,"Reward reference and paid lifetime claims retain across reset")
 check(p.Upgrades.LeafPower==1 and p.Coins==C.Roll.FirstCoins and #p.Parts==0,"Reset/retention contract remains")
 check(1+p.Saplings*C.Math.RebirthPerSapling==3.5,"First Sapling restores the unique-parts second-run target")
 print("Build a Tree balance: "..count.." checks passed");return count
end
return T
