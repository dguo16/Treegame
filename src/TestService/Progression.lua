local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local J=require(S.Util.Journal)
local R=require(S.Util.RollEngine)
local V=require(S.Util.ValueCalculator)
local Entitlements=require(S.Util.Entitlements)
local Validate=require(S.Util.IntentValidator)
local Tests={}
function Tests.Run()
 local checks=0;local function check(v,msg)assert(v,msg);checks+=1 end
 local p=P.New(0);J.Login(p,0);J.Login(p,10)
 check(p.Journal.LoginDays==1,"Same-day login is idempotent")
 J.Login(p,86400*10);check(p.Journal.LoginDays==2,"Missing days never removes return progress")
 local before=p.Coins;check(J.Claim(p,"DailyLogin",86400*10),"Daily login reward claims once")
 check(p.Coins==before+150,"Login reward derives from server return-day count")
 check(not J.Claim(p,"DailyLogin",86400*10) and p.Coins==before+150,"Replayed login claim grants nothing")
 check(not J.Claim(p,"forged:1000000",86400*10),"Unknown goal key cannot grant coins")
 check(not J.Claim(p,"DailyRolls",86400*10),"Incomplete daily quest rejects claim")
 J.Add(p,"Rolls",5,86400*10)
 check(J.Claim(p,"DailyRolls",86400*10),"Completed daily quest claims configured reward")
 check(not J.Claim(p,"DailyRolls",86400*10),"Completed daily quest cannot grant twice")
 J.Touch(p,86400*11)
 check(p.Journal.Daily.Rolls==0 and p.Journal.Totals.Rolls==5,"New UTC day resets daily counters, preserving lifetime totals")
 check(not p.Journal.Daily.Claims.DailyLogin,"Next day permits a fresh login reward")
 local part=P.Starter().Trunk
 check(J.Discover(p,part) and not J.Discover(p,part),"Discovery identity is idempotent")
 part=P.Copy(part);part.Mutation="Golden";check(J.Discover(p,part) and J.Count(p)==2,"Mutation has a distinct collection entry")
 local all=P.New(0)
 for _,slot in C.Slots do for tier=1,#C.Rarities do for _,name in C.PartVariants[slot][tier]do for _,m in C.Mutations do
  J.Discover(all,{Slot=slot,Tier=tier,Name=name,Mutation=m.Name})
 end end end end
 check(J.Count(all)==420,"Exactly 84 by 5 catalog combinations are discoverable")
 check(J.Claim(all,"Index420",1),"Full collection milestone grants server-defined reward")
 check(not J.Claim(all,"Index420",1),"Collection milestone cannot be reclaimed")
 check(J.Event(p,"Golden Rain",100) and not J.Event(p,"Golden Rain",100),"One participation medal per event instance")
 check(J.Event(p,"Golden Rain",200) and p.Journal.EventTokens==2,"Another event can earn another medal")
 check(p.Journal.Keepsakes["Golden Rain"]==true,"Event keepsake persists separately from repeat medals")
 local old=P.New(0);old.Schema=3;old.Journal=nil;old.Rolls=80;old.Tutorial=6
 P.Migrate(old,100)
 check(old.Journal.Totals.Rolls==80 and old.Onboarding==9,"Legacy migration preserves roll progress and finished tutorial")
 check(old.EarlyRareClaimed==true,"Old accounts do not receive a retroactive third-roll guarantee")
 local current=P.New(0);current.Onboarding=8;current.Tutorial=6;P.Migrate(current,1)
 check(current.Onboarding==8,"Current saves retain partially completed new onboarding")
 local fresh=P.New(0);fresh.Rolls=2
 check(R.Minimum(fresh)==3,"Third lifetime roll discloses a Rare minimum")
 local rng=Random.new(100);check(R.Roll(rng,fresh,1,"third").Tier>=3 and fresh.EarlyRareClaimed,"Third roll satisfies guarantee")
 fresh.LegendaryPity=299;check(R.Minimum(fresh)==5,"Legendary pity takes precedence over early guarantee")
 local w,total=R.MutationWeights(2)
 check(math.abs(total-120)<1e-8 and math.abs(w[1]/total-2/3)<1e-8,"Mutation luck doubles non-default weights, then normalizes")
 local base=P.Starter();local normal=V.Build(base,1,2,3,4,nil,100,false)
 check(V.Build(base,1,2,3,4,nil,100,true)==normal*2,"Coin pass applies exactly once after other independent multipliers")
 p=P.New(0);p.Passes.Coins=true;p.Passes.Cosmetics=true
 check(Entitlements.Has(p,"Coins"),"Eligible ownership activates gameplay perk")
 p.PolicyRestricted=true
 check(not Entitlements.Has(p,"Coins") and Entitlements.Has(p,"Cosmetics"),"Restricted accounts retain cosmetics while paid gameplay perks stay inactive")
 for _,key in {"Coins","GrowthSpeed","GrowthPad","AutoSell","MutationLuck","Cosmetics"}do
  check(C.Passes[key].Id==0 and C.Passes[key].Price==0 and C.Passes[key].ProposedPrice>0,"New price remains a disabled proposal: "..key)
 end
 check(not C.Monetization.EnableNewPurchases and not C.Monetization.MutationLuckEnabled,"New purchasing and mutation luck are explicitly staged off")
 check(Validate("DailyRoll",{}) and not Validate("DailyRoll",{Reward=1000}),"Daily free roll intent cannot specify reward")
 check(Validate("ClaimJournal",{Key="DailyLogin"}) and not Validate("ClaimJournal",{Key="DailyLogin",Day=1}),"Claims do not accept client dates")
 check(Validate("VisitGarden",{Target=123}) and not Validate("VisitGarden",{Target=123,Position=1}),"Garden visit accepts identity rather than coordinates")
 check(not Validate("LikeGarden",{Target=0/0}),"Forged invalid garden identity rejected")
 print("Build a Tree progression: "..checks.." checks passed");return checks
end
return Tests
