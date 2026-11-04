local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local J=require(S.Util.Journal)
local K=require(S.Util.Collection)
local R=require(S.Util.RollEngine)
local V=require(S.Util.ValueCalculator)
local Growth=require(game.ServerScriptService.BuildATree.Services.GrowthService)
local Event=require(game.ServerScriptService.BuildATree.Services.EventService).CreateForTests()
local Game=require(game.ServerScriptService.BuildATree.Services.GameService)
local Validate=require(S.Util.IntentValidator)
local Checks={}
function Checks.Run()
 local count=0;local function check(v,msg)assert(v,msg);count+=1 end
 local function near(a,b)return math.abs(a-b)<1e-6 end
 local function discover(p,tier,slot,variant,mutation)
  J.Discover(p,{Slot=slot,Tier=tier,Name=C.PartVariants[slot][tier][variant],Variant=variant,Mutation=mutation or "None"})
 end
 local function rarity(p,tier,mutation)for _,slot in C.Slots do for v=1,3 do discover(p,tier,slot,v,mutation)end end end
 local p=P.New(0);J.Scan(p)
 check(K.Progress(p,K.Find("Names1"))==4,"Free starter names count once")
 discover(p,1,"Trunk",1,"Golden");discover(p,1,"Trunk",1,"Cosmic")
 check(K.Progress(p,K.Find("Names1"))==4 and J.Count(p)==6,"Name dedupes mutations while combinations remain distinct")
 check(not K.Parse("Trunk:8:1:Cosmic")and not K.Parse("Trunk:1:99:Cosmic")and not K.Parse("Bad:1:1:None")and not K.Parse("Trunk:1:1:Forged"),"Invalid saved discovery keys never manufacture catalog progress")
 for schema=3,7 do
  local old=P.New(10);old.Schema=schema;old.Journal.Collection=nil;old.Journal.Cosmetics=nil;old.Journal.MedalSpent=nil
  old.Journal.Found={["Fruit:7:2:Cosmic"]=true};old.Journal.Claims.Index420=true;old.Journal.Paid.Index420=1000000
  old.Journal.EventTokens=9;old.Journal.LikesReceived=12;old.Saplings=7;old.Upgrades.LeafPower=5
  local migrated=P.Migrate(game.HttpService:JSONDecode(game.HttpService:JSONEncode(old)),20)
  check(migrated.Schema==C.Schema and migrated.Saplings==7 and migrated.Upgrades.LeafPower==5,"Migration preserves schema-6 balance progression")
  check(migrated.Journal.Found["Fruit:7:2:Cosmic"]and migrated.Journal.Collection.Names["Fruit:7:2"],"Old combinations derive any-mutation names without loss")
  check(migrated.Journal.Claims.Index420 and migrated.Journal.Collection.LegacyClaims.Index420.Claimed and migrated.Journal.Collection.LegacyClaims.Index420.Paid==1000000,"Old claims/payouts stay archived and consumed")
  local coins=migrated.Coins;check(not J.Claim(migrated,"Index420",20)and migrated.Coins==coins,"Legacy count rewards cannot replay")
  check(K.MedalBalance(migrated)==9 and migrated.Journal.LikesReceived==12,"Old medals and garden likes retain value")
  P.Migrate(migrated,21);check(K.MedalBalance(migrated)==9,"Migration is idempotent")
 end
 p=P.New(0)
 check(not K.Claim(p,"Names1",100,1),"Incomplete set rejects a claim")
 for tier=1,4 do
  rarity(p,tier);local before=p.Coins
  check(K.Claim(p,"Names"..tier,100,1),"Completed core rarity set claims")
  check(p.Coins-before==C.Collection.CoinSeconds*100,"Set coins use a small reference-income reward")
  local c,l=K.Factors(p);check(near(c,1+tier*.01)and near(l,1+tier*.01),"Earned bonuses accrue only from core rarity sets")
  check(not K.Claim(p,"Names"..tier,100000,1)and p.Coins-before==12000,"Repeated set cannot grant coins or bonuses twice")
 end
 check(K.PetSlots(p)==0 and K.Claim(p,"CoreNames48",100,1)and K.PetSlots(p)==1,"Major core completion grants exactly one extra equipped slot")
 check(Game.MaxPetSlots(p)==4,"Extra pet slot adds to current coin-upgrade capacity")
 p.Upgrades.PetSlots=4;check(Game.MaxPetSlots(p)==7,"Maximum capacity becomes seven through the one earned slot")
 local coins,luck=K.Factors(p);check(coins==1.04 and luck==1.04,"Hard total stat caps hold")
 local plain=P.New(0);local player={UserId=12345}
 check(near(Game.Luck(p,0,player)/Game.Luck(plain,0,player),1.04),"Earned luck enters the real rarity calculator")
 check(near(Game.Value(p,P.Starter(),1,0)/Game.Value(plain,P.Starter(),1,0),1.04),"Earned coin bonus enters the real value equation once")
 local w,total=R.MutationWeights(1);check(total==100 and w[5]==.5 and C.Pets.Weights[1]==60,"Collection bonuses never change mutation or egg odds")
 local quote=K.Quote(p,"Names1",1e30);check(quote==C.Collection.CoinCapReward,"Collection coin payout has its own small hard cap")
 p.Coins=1e9;check(Game.RebirthProfile(p,false),"Claimed collector can Ascend")
 check(p.Journal.Collection.Claims.Names4 and K.Factors(p)==1.04 and K.PetSlots(p)==1,"Set claims, stat bonuses and pet slot survive Ascension")
 check(p.Journal.Collection.Names["Fruit:4:3"]and p.Journal.Cosmetics.Owned.CoreCollector,"Discoveries and cosmetics survive Ascension")
 p=P.New(0)
 for tier=1,7 do for _,m in C.Mutations do rarity(p,tier,m.Name)end end
 check(J.Count(p)==420 and K.Progress(p,K.Find("AllNames84"))==84,"Both complete tracks represent the entire catalog")
 for _,goal in K.Goals()do
  check(K.Progress(p,goal)==goal.Need,"All configured set progress reaches its exact target")
  if goal.Optional then local before=p.Coins
   check(K.Claim(p,goal.Key,100000,1)and p.Coins==before,"Legend challenge grants cosmetics only")
  end
 end
 local c,l=K.Factors(p);check(c==1 and l==1 and K.PetSlots(p)==0,"Optional rarity/mutation tail never gates gameplay stats or slots")
 check(K.Next(p)~=nil and not K.Find(K.Next(p).Key).Optional,"Closest-set hint only selects achievable core sets")
 for _,goal in K.Goals()do if not goal.Optional then K.Claim(p,goal.Key,100,1)end end
 check(K.Next(p)==nil,"Hint finishes gracefully when all core sets are claimed")
 p=P.New(0);p.Journal.EventTokens=20;local before=p.Coins;local initialCoins,initialLuck=K.Factors(p)
 check(K.BuyMedal(p,"FlowerPlanter")and K.MedalBalance(p)==18,"Medal shop charges the exact server catalog price")
 check(not K.BuyMedal(p,"FlowerPlanter")and K.MedalBalance(p)==18,"Duplicate cosmetic purchase never spends again")
 check(not K.BuyMedal(p,"Forged"),"Unknown medal item rejected")
 check(p.Coins==before and K.Factors(p)==initialCoins and select(2,K.Factors(p))==initialLuck,"Medal purchases have no coins or stats")
 p.Journal.EventTokens=2;p.Journal.MedalSpent=2;check(not K.BuyMedal(p,"Lantern"),"Insufficient medals cannot buy")
 check(K.Equip(p,"Decoration","FlowerPlanter"),"Owned item equips in its exact slot")
 check(not K.Equip(p,"Aura","FlowerPlanter")and not K.Equip(p,"Aura","CosmicGlow")and not K.Equip(p,"Bad",""),"Wrong-slot and unowned cosmetics rejected")
 check(K.Equip(p,"Decoration","")and p.Journal.Cosmetics.Equipped.Decoration=="","Owned cosmetic can be cleared")
 for i,need in C.Collection.Likes do
  local key="Likes"..need;p.Journal.LikesReceived=need-1;check(not K.ClaimLikes(p,key),"Incomplete like milestone rejects")
  p.Journal.LikesReceived=need;check(K.ClaimLikes(p,key)and p.Journal.Cosmetics.Owned[C.Collection.LikeRewards[i]],"Like milestone grants its configured cosmetic")
  check(not K.ClaimLikes(p,key),"Like milestone is claimed once")
 end
 check(p.Coins==before and K.Factors(p)==1 and select(2,K.Factors(p))==1,"Likes award no coins or stat bonuses")
 for _,action in {"ClaimCollection","BuyMedalCosmetic","ClaimLikes"}do
  check(Validate(action,{Key="Names1"})and not Validate(action,{Key="Names1",Amount=1000})and not Validate(action,{Key="Names1",Time=1}),"Reward/shop intent has an exact key-only schema")
 end
 check(Validate("EquipCosmetic",{Slot="Aura",Key="GreenGlow"})and not Validate("EquipCosmetic",{Slot="Aura",Key="GreenGlow",Owned=true}),"Cosmetic equip cannot forge ownership")
 check(C.Products.Shield==nil and C.Defenses.Shield==1000 and P.New(0).Settings.Chill,"Shield product removed while coin defenses and Chill defaults remain")
 local sender,owner=P.New(0),P.New(0);local coinBalance=owner.Coins
 check(not J.Like(sender,owner,10,10,0),"Self-like rejected")
 check(J.Like(sender,owner,10,20,86399)and owner.Journal.LikesReceived==1,"Valid like credits the owner")
 check(not J.Like(sender,owner,10,20,86399)and owner.Journal.LikesReceived==1,"Same target is limited to one like per UTC day")
 check(J.Like(sender,owner,10,20,86400)and owner.Journal.LikesReceived==2,"UTC boundary permits the next daily like")
 check(owner.Coins==coinBalance and not J.Like(sender,owner,10,0/0,86400),"Likes never pay coins or accept invalid identities")
 for _,name in C.Events.Order do
  local fixture=require(game.ServerScriptService.BuildATree.Services.EventService).CreateForTests();fixture.Queue={name};fixture.Next=100000
  fixture.Tick(100,function()end,function()end)
  check(fixture.Current==name and fixture.Ends==100+C.Events.Duration[name],"Every named event resolves its configured duration")
 end
 local saved=P.Copy(Event);Event.Current=nil;Event.Queue={"Windstorm"};Event.Next=100000
 local active=P.New(0);active.Rebirths=1
 for pad=1,2 do local g=Growth.New(P.Starter(),100,false);g.Duration=3600;Growth.Set(active,pad,g)end
 local starts=0;Event.Tick(100,function(name)starts+=1;check(name=="Windstorm","Queued event starts normally")end,function()end)
 check(Event.GrowthFactor(100)==5 and Event.GrowthFactor(159)==5 and Event.GrowthFactor(160)==1,"Windstorm has a bounded five-times one-minute rate")
 Growth.Step(active,100,Event.GrowthFactor(100));Growth.Step(active,130,Event.GrowthFactor(130))
 check(active.Growth.Progress==150 and active.Growth2.Progress==150 and active.Growth.State=="Growing","Windstorm speeds both pads without instant completion")
 Growth.Step(active,160,1);Event.Tick(160,function()end,function()end);Growth.Step(active,200,1)
 check(active.Growth.Progress==340 and active.Growth2.Progress==340,"Windstorm end preserves progress and restores ordinary rate")
 local offline=P.New(0);offline.Rebirths=1
 for pad=1,2 do local g=Growth.New(P.Starter(),100,false);g.Duration=3600;g.Progress=12;g.Rate=5;Growth.Set(offline,pad,g)end
 Game.OfflineGrowth(offline,1100)
 check(near(offline.Growth.Progress,12+1000*Game.StandingGrowthRate(offline)) and near(offline.Growth2.Progress,12+1000*Game.StandingGrowthRate(offline)),"Standing offline rates do not replay saved temporary Windstorm bonuses")
 table.clear(Event);for k,v in saved do Event[k]=v end
 print("Build a Tree collection: "..count.." checks passed");return count
end
return Checks
