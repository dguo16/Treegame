-- Inventory contracts: values, IDs, revisions, vault moves, size odds and migration.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local B=require(S.Util.BagInventory)
local F=require(S.Util.FruitCollection)
local Sizes=require(S.Util.FruitSizes)
local V=require(S.Util.ValueCalculator)
local Validate=require(S.Util.IntentValidator)
local Game=require(game.ServerScriptService.BuildATree.Services.GameService)
local Tests={}
function Tests.Run()
 local n=0;local function check(v,m)assert(v,m);n+=1 end
 local function near(a,b)return math.abs(a-b)<1e-7 end
 local function metadata(name,mutation,size,tier)return {Name=name or "Apple",Tier=tier or 1,Mutation=mutation or "None",Size=size or "Normal"}end
 local function fresh()return {Count=0,Value=0,Items={}}end
 check(C.Schema==11 and C.FruitInventory.VaultStacks==30 and C.FruitInventory.ShelfSlots==6,"One schema bump and bounded Vault/shelf")
 check(C.Economy.MutationCeiling==2 and Sizes.Expected()==1,"Existing mutation ceiling unchanged; expected size value exactly neutral")
 local thresholds={{0,"Small"},{.299999,"Small"},{.3,"Normal"},{.899999,"Normal"},{.9,"Large"},{.989999,"Large"},{.99,"Giant"},{.999999,"Giant"}}
 for _,row in thresholds do check(Sizes.Roll({NextNumber=function()return row[1]end}).Name==row[2],"Exact size sampling boundary: "..row[1])end
 local counts={};local rng=Random.new(2701);local sample=100000
 for i=1,sample do local size=Sizes.Roll(rng);counts[size.Name]=(counts[size.Name]or 0)+1;if i%1000==0 then task.wait()end end
 for _,size in C.FruitSizes do
  local expected=sample*size.Weight/100;local tolerance=6*math.sqrt(expected*(1-size.Weight/100))
  check(math.abs(counts[size.Name]-expected)<=tolerance,"Size sample matches disclosed odds: "..size.Name)
  check(size.Scale<=1.6,"Size visual is bounded: "..size.Name)
 end
 local build=P.Starter();local normal=V.Build(build,1,1,1,1,nil,1,false)
 for _,size in C.FruitSizes do
  check(near(V.Build(build,1,1,1,1,nil,1,false,size.Name),normal*size.Value),"Size value applies once: "..size.Name)
  check(near(V.Build(build,50,1,1,1,nil,1,true,size.Name),normal*2*size.Value*2),"Mutation cap then size then one Double Coins: "..size.Name)
 end
 local bag=fresh();B.Add(bag,10,2,metadata(),120,nil);local id=bag.Items[1].Id
 B.Add(bag,20,1,metadata(),180,nil)
 check(#bag.Items==1 and bag.Count==3 and near(bag.Value,40),"Exact value and acquisition minute no longer fragment new stacks")
 check(bag.Items[1].Id==id and near(bag.Items[1].Value,40/3)and bag.Items[1].ObtainedAt==120 and bag.Items[1].LastObtainedAt==180,"Stack keeps identity and timestamp range while blending unit value")
 local oldRevision=bag.Revision
 local ok,result=B.Sell(bag,bag.Revision,{{Id=id,Quantity=1}})
 check(ok and result.Count==1 and near(result.Coins,40/3)and bag.Count==2,"Partial stack sells exactly requested quantity at snapshot average")
 B.Add(bag,5,1,metadata(),240)
 local _,last=B.Sell(bag,bag.Revision,B.All(bag))
 check(near(result.Coins+last.Coins,45)and bag.Count==0 and bag.Value==0,"Partial sales and value blending conserve every coin")
 B.Add(bag,5,2,metadata(),250);id=bag.Items[1].Id;oldRevision=bag.Revision
 B.Add(bag,10,1,metadata(),251)
 ok,result=B.Sell(bag,oldRevision,{{Id=id,Quantity=2}})
 check(ok and result.Stale and result.Count==2 and near(result.Coins,40/3)and bag.Count==1,"New arrivals during an open panel sell only selected valid quantities")
 local revision=bag.Revision;local value=bag.Value
 check(not B.Sell(bag,revision,{{Id=id,Quantity=2}})and bag.Value==value,"Current-revision oversell rejects atomically")
 check(not B.Sell(bag,revision+1,{{Id=id,Quantity=1}})and bag.Value==value,"Future revision cannot authorize a sale")
 check(not B.Sell(bag,revision,{{Id=id,Quantity=1},{Id=id,Quantity=1}})and bag.Value==value,"Duplicate IDs cannot sell a stack twice")
 ok,result=B.Sell(bag,revision-1,{{Id=id,Quantity=100},{Id="missing",Quantity=1}})
 check(ok and result.Count==1 and result.Adjusted==1 and result.Missing==1 and bag.Count==0,"Stale partial availability is clamped and reported")
 for _,size in C.FruitSizes do B.Add(bag,4,1,metadata("Apple","None",size.Name),300)end
 check(#bag.Items==4,"Size classes make distinct stacks")
 B.Add(bag,4,1,metadata("Apple","Golden","Normal"),300)
 check(#bag.Items==5 and #B.All(bag,"Plain")==4,"Mutation identity remains distinct and plain filter preserves mutated fruit")
 check(#B.All(bag,"Below",4)==0 and #B.All(bag,"Below",5)==5,"Below-value filter uses strict averaged unit value")
 local p=P.New(0);p.Bag=bag;local first=bag.Items[1];local total=bag.Value
 check(B.Move(p,first.Id,p.Bag.Revision,true,10)and #p.Vault.Items==1 and p.Vault.Items[1].Id==first.Id,"Lock moves whole stack with stable identity into Vault")
 check(p.Bag.Count==4 and near(p.Bag.Value+p.Vault.Items[1].TotalValue,total),"Locked fruit no longer uses bag capacity; value conserved")
 for _,kind in {"All","Plain","Below"}do
  local rows=B.All(p.Bag,kind,1e30);local found=false;for _,row in rows do if row.Id==first.Id then found=true end end
  check(not found,"Sale filter never includes Vault: "..kind)
 end
 local before=p.Vault.Items[1].TotalValue;B.Sell(p.Bag,p.Bag.Revision,B.All(p.Bag))
 check(#p.Vault.Items==1 and p.Vault.Items[1].TotalValue==before,"Sell All cannot touch locked value")
 B.Add(p.Bag,7,10,metadata("Pear","None","Normal",2),300)
 check(not B.Move(p,first.Id,p.Bag.Revision,false,10)and #p.Vault.Items==1,"Unlock with a full bag refuses without loss")
 check(B.Move(p,first.Id,p.Bag.Revision,false,20)and #p.Vault.Items==0 and B.Find(p.Bag,first.Id),"Unlock succeeds with sufficient room and original ID")
 check(not B.Move(p,first.Id,p.Bag.Revision-1,true,20),"Stale lock/unlock snapshot rejects")
 p=P.New(0)
 for i=1,31 do B.Add(p.Bag,i,1,metadata("Fruit"..i),i)end
 for i=1,30 do local item=p.Bag.Items[1];check(B.Move(p,item.Id,p.Bag.Revision,true,math.huge),"Vault capacity accepts stack "..i)end
 local remaining=p.Bag.Items[1].Id
 check(not B.Move(p,remaining,p.Bag.Revision,true,math.huge)and #p.Vault.Items==30 and p.Bag.Count==1,"Thirty-first Vault stack cannot bypass capacity")
 local legacy=P.New(0);legacy.Schema=8;legacy.FruitIndex=nil;legacy.Vault=nil;legacy.Bag={Count=3,Value=18.75,Items={{Name="Apple",Tier=1,Mutation="Golden",Value=6.25,Count=3}}}
 P.Migrate(legacy,1000);local legacyId=legacy.Bag.Items[1].Id
 check(type(legacyId)=="string"and #legacyId>0 and legacy.Bag.Items[1].Size=="Normal","Schema-8 stack with nil ID receives stable ID and Normal size")
 check(legacy.Bag.Value==18.75 and legacy.Bag.Items[1].Value==6.25 and legacy.Bag.Items[1].ObtainedAt==nil and legacy.Bag.Items[1].LastObtainedAt==nil,"Migration preserves saved values and unknown timestamps")
 check(F.Count(legacy)==1 and legacy.FruitIndex.Biggest.Size=="Normal"and legacy.FruitIndex.Biggest.At==nil,"Migration derives known fruit discovery/record without inventing time")
 P.Migrate(legacy,2000);local restored=P.Migrate(game.HttpService:JSONDecode(game.HttpService:JSONEncode(legacy)),3000)
 check(restored.Bag.Items[1].Id==legacyId and restored.Bag.Value==18.75,"Idempotent migration and save/load retain fruit identity/value")
 legacy=P.New(0);legacy.Schema=8;legacy.Bag={Count=2,Value=6};P.Migrate(legacy,100)
 check(legacy.Bag.Items[1].Name=="Saved Harvest"and legacy.Bag.Items[1].Size=="Normal"and legacy.Bag.Items[1].Value==3,"Summary-only legacy bag retains every coin as Normal Saved Harvest")
 check(F.Count(legacy)==0 and legacy.Bag.Items[1].ObtainedAt==nil,"Unknown legacy fruit name does not invent Index discovery or time")
 p=P.New(0);B.Add(p.Bag,8,1,metadata(),0,"duplicate");p.Vault.Items={{Id="duplicate",Name="Pear",Tier=2,Mutation="None",Value=9,Count=1}}
 B.EnsureProfile(p);check(p.Bag.Items[1].Id~=p.Vault.Items[1].Id,"Duplicate IDs across Bag/Vault are repaired")
 F.Discover(p,metadata("Apple","Golden","Small"),10);F.Discover(p,metadata("Apple","Golden","Giant"),20)
 check(F.Count(p)==1 and p.FruitIndex.Found["1:1:Golden"].Sizes.Small and p.FruitIndex.Found["1:1:Golden"].Sizes.Giant,"Fruit Index deduplicates name/mutation while showing discovered size classes")
 F.Discover(p,metadata("Pear","None","Large",2),30)
 check(p.FruitIndex.Biggest.Size=="Giant"and p.FruitIndex.Biggest.At==20,"Biggest record never shrinks to a lower size class")
 B.Move(p,p.Bag.Items[1].Id,p.Bag.Revision,true,10);local kept=p.Vault.Items[1].Id;local revision=p.Bag.Revision;p.Coins=Game.AscensionThreshold(p)
 check(Game.RebirthProfile(p)and p.Bag.Count==0 and p.Vault.Items[1].Id==kept and p.Bag.Revision>revision,"Ascension clears bag and retains Vault with advanced bag revision")
 check(p.FruitIndex.Biggest.Size=="Giant"and F.Count(p)==2,"Fruit Index and biggest record survive Ascension")
 local rt={};check(Game.SaleAllowed(rt,10)and not Game.SaleAllowed(rt,10.1)and Game.SaleAllowed(rt,10.4),"Sales have an independent server cooldown")
 check(Validate("Sell",{Revision=0,Stacks={{Id="s",Quantity=2}}})and not Validate("Sell",{}),"Sell accepts only revision and stack quantities")
 local forged={{Revision=0,Stacks={{Id="s",Quantity=2,Value=1e9}}},{Revision=0,Stacks={{Id="s",Quantity=0}}},{Revision=0,Stacks={{Id="s",Quantity=0/0}}},{Revision=0,Stacks={{Id="s",Quantity=1},{Id="s",Quantity=1}}},{Revision=0,Stacks={{Id="s",Quantity=1}},Total=10},{Revision=-1,Stacks={{Id="s",Quantity=1}}},{Revision=0,Stacks={bad={Id="s",Quantity=1}}}}
 for _,payload in forged do check(not Validate("Sell",payload),"Forged nested sale payload rejected")end
 local rows={};for i=1,C.FruitInventory.MaxSaleStacks do rows[i]={Id="stack"..i,Quantity=1}end
 check(Validate("Sell",{Revision=0,Stacks=rows}),"Bounded maximum-length sale payload is accepted")
 table.insert(rows,{Id="overflow",Quantity=1});check(not Validate("Sell",{Revision=0,Stacks=rows}),"Unbounded sale arrays are rejected before work")
 check(not Validate("Sell",{Revision=0,Stacks={{Id="s",Quantity=1.5}}}),"Fractional fruit quantities cannot be sold")
 check(Validate("LockFruit",{StackId="s",Revision=0})and not Validate("LockFruit",{StackId="s",Revision=0,Locked=true}),"Lock cannot forge ownership or lock flags")
 check(Validate("UnlockFruit",{StackId="s",Revision=0})and not Validate("UnlockFruit",{StackId="s",Revision=0,Capacity=1000}),"Unlock cannot forge capacity")
 check(P.New(0).Settings.QuickSellOnEntry==false,"New players default to the Sell panel")
 print("Build a Tree fruit inventory: "..n.." checks passed");return n
end
return Tests
