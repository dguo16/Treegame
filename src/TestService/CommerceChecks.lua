-- Deterministic contract tests against production purchase and persistence factories.
-- No Marketplace calls, live DataStore keys or client-trusted price/reward amounts.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local J=require(S.Util.Journal)
local K=require(S.Util.Collection)
local Rules=require(S.Util.PlacementRules)
local Validate=require(S.Util.IntentValidator)
local E=require(S.Util.Entitlements)
local Services=game.ServerScriptService.BuildATree.Services
local Growth=require(Services.GrowthService)
local Game=require(Services.GameService)
local Event=require(Services.EventService)
local Purchase=require(Services.PurchaseService)
local Data=require(Services.DataService)
local Tests={}
function Tests.Run()
 local checks=0;local function check(v,msg)assert(v,msg);checks+=1 end
 local function fixture()
  local config=P.Copy(C);config.Monetization.EnableNewPurchases=true
  local nextId=100;for _,tableValue in {config.Passes,config.Products}do for _,item in tableValue do nextId+=1;item.Id=nextId end end
  local backend={}
  function backend:UpdateAsync(_,transform)local result=transform(P.Copy(self.Record));if result then self.Record=P.Copy(result)end;return P.Copy(result)end
  local player={UserId=123,Kick=function()end}
  local d=Data.CreateForTests({Store=backend,Token="commerce-test",Now=function()return 1000 end,Wait=function()end})
  local p=d.Load(player);p.Plots[1]={Build=P.Starter(),State="Producing",NextDrop=1000};p.Rebirths=1
  local market={Prompts={},Owns={}}
  function market:PromptProductPurchase(_,id)table.insert(self.Prompts,{Kind="Product",Id=id})end
  function market:PromptGamePassPurchase(_,id)table.insert(self.Prompts,{Kind="Pass",Id=id})end
  function market:UserOwnsGamePassAsync(_,id)return self.Owns[id]or false end
  local function signal()return {Connect=function()end}end
  market.PromptProductPurchaseFinished=signal();market.PromptGamePassPurchaseFinished=signal()
  local fg={Runtime={[player]={PaidRandom=true}},Settle=function()end,Toast=function()end,State=function()end}
  local service=Purchase.CreateForTests({Config=config,Data=d,Marketplace=market,Players={GetPlayerByUserId=function(_,id)return id==123 and player or nil end},Now=function()return 1000 end})
  service.Init(fg)
  return service,d,player,market,config,fg,backend
 end
 local function receipt(config,key,id)return {PlayerId=123,ProductId=config.Products[key].Id,PurchaseId=id,CurrencySpent=config.Products[key].ProposedPrice}end
 local function growFor(p,limit)
  p.Growth=Growth.New(p.Equipped,1000,false);p.Growth.Duration=limit
 end
 check(C.Schema==11 and not C.Monetization.EnableNewPurchases,"Schema bumped; all purchasing remains disabled")
 check(not C.Products.Maxer and not C.Products.RebirthSkip and not C.Passes.MutationLuck and not C.Passes.ExtraPlots and not C.Passes.GrowthPad,"Retired sale definitions are absent")
 for _,items in {C.Passes,C.Products}do for key,item in items do
  check(item.Draft==true and item.Id==0 and item.Price==0 and item.ProposedPrice>0,"Only draft proposals and zero IDs: "..key)
 end end
 for key,item in C.Products do
  -- Every product uses real request saving, cancellation, receipt commit and duplicate detection.
  local service,d,player,market,config,fg=fixture();local p=d.Get(player)
  if item.Limit then growFor(p,item.Limit)end
  local before=p.Coins
  check(service.Intent(player,item.Limit and "GrowNow"or "Product",item.Limit and {}or{Key=key}),"Eligible request saves before prompt: "..key)
  p=d.Get(player);check(#market.Prompts==1 and p.PurchasePending.Key==key,"Server selects the product: "..key)
  local quoted=p.PurchasePending.Quote and p.PurchasePending.Quote.Coins
  p.Upgrades.LeafPower=6 -- Purchase-time quote must not follow later changes.
  local r=receipt(config,key,"first-"..key)
  check(service.ProcessReceipt(r)==Enum.ProductPurchaseDecision.PurchaseGranted,"Durable purchase grant: "..key)
  p=d.Get(player);local after=p.Coins;local credits=#(p.GrowCredits or {});local boost=p.Boosts.LuckUntil
  check(p.Receipts[r.PurchaseId]and p.PurchaseLog[r.PurchaseId].Key==key and not p.PurchasePending,"Receipt and effects commit together: "..key)
  if item.Seconds then check(after==before+quoted,"Uses locked server reference quote: "..key)end
  if item.Limit then check(p.Growth.State=="Ready","Grow bracket finishes bound tree: "..key)end
  if item.Factor then check(p.Boosts.LuckFactor==item.Factor and boost==1900,"Lucky boost uses exact duration/factor: "..key)end
  check(service.ProcessReceipt(r)==Enum.ProductPurchaseDecision.PurchaseGranted,"Duplicate is acknowledged: "..key)
  p=d.Get(player);check(p.Coins==after and #(p.GrowCredits or {})==credits and p.Boosts.LuckUntil==boost,"Duplicate never grants twice: "..key)
  fg.Runtime[player].PaidRandom=false;p.PolicyRestricted=true
  check(service.ProcessReceipt(r)==Enum.ProductPurchaseDecision.PurchaseGranted,"Committed duplicate still resolves after restriction: "..key)
  local other=receipt(config,key,"restricted-"..key)
  check(service.ProcessReceipt(other)==Enum.ProductPurchaseDecision.NotProcessedYet and not p.Receipts[other.PurchaseId],"Uncommitted restricted receipt stays pending: "..key)
  service,d,player,market,config,fg=fixture();p=d.Get(player);if item.Limit then growFor(p,item.Limit)end
  p.PolicyRestricted=true;fg.Runtime[player].PaidRandom=false
  check(not service.Intent(player,item.Limit and "GrowNow"or "Product",item.Limit and {}or{Key=key})and #market.Prompts==0,"Restricted account cannot prompt: "..key)
  service,d,player,market,config=fixture();p=d.Get(player);if item.Limit then growFor(p,item.Limit)end
  check(service.Intent(player,item.Limit and "GrowNow"or "Product",item.Limit and {}or{Key=key}),"Cancel fixture prompts: "..key)
  before=d.Get(player).Coins
  check(not service.Cancel(player,99999)and d.Get(player).PurchasePending~=nil,"Unrelated cancel does not erase request: "..key)
  check(service.Cancel(player,config.Products[key].Id)and not d.Get(player).PurchasePending and d.Get(player).Coins==before and next(d.Get(player).Receipts)==nil,"Cancel grants nothing: "..key)
  service,d,player,market,config=fixture();config.Monetization.EnableNewPurchases=false;p=d.Get(player);if item.Limit then growFor(p,item.Limit)end
  check(not service.Intent(player,item.Limit and "GrowNow"or "Product",item.Limit and {}or{Key=key})and #market.Prompts==0,"Draft kill switch blocks every product: "..key)
 end
 for key,item in C.Passes do
  -- Pass-finished callbacks require verified platform ownership and commit only once.
  local service,d,player,market,config,fg=fixture();local p=d.Get(player);local pass=config.Passes[key]
  check(service.Intent(player,"Pass",{Key=key})and #market.Prompts==1,"Eligible pass request: "..key)
  local before=p.ProductSpent
  check(not service.PassFinished(player,pass.Id,false)and not p.Passes[key],"Cancelled pass grants nothing: "..key)
  check(not service.PassFinished(player,pass.Id,true)and not p.Passes[key],"Finished callback cannot invent ownership: "..key)
  market.Owns[pass.Id]=true
  check(service.PassFinished(player,pass.Id,true)and d.Get(player).Passes[key],"Verified entitlement saved: "..key)
  check(service.PassFinished(player,pass.Id,true)and d.Get(player).ProductSpent==before+pass.ProposedPrice,"Repeated callback does not double spending: "..key)
  p=d.Get(player);p.Coins=Game.AscensionThreshold(p)
  check(Game.RebirthProfile(p)and p.Passes[key],"Entitlement persists through earned Ascension: "..key)
  service,d,player,market,config,fg=fixture();p=d.Get(player);p.PolicyRestricted=true;fg.Runtime[player].PaidRandom=false
  local prompted=service.Intent(player,"Pass",{Key=key})
  check(prompted==not item.PaidRandom and #market.Prompts==(item.PaidRandom and 0 or 1),"Restricted policy classification: "..key)
  service,d,player,market,config=fixture();config.Monetization.EnableNewPurchases=false
  check(not service.Intent(player,"Pass",{Key=key})and #market.Prompts==0,"Draft kill switch blocks every pass: "..key)
 end
 local service,d,player,market,config=fixture();local p=d.Get(player)
 service.Intent(player,"Product",{Key="StarterPack"});local quote=d.Get(player).PurchasePending.Quote
 check(quote.Coins==18000 and quote.Reference==10,"Starter bundle is 30 minutes of starter reference income")
 check(service.ProcessReceipt(receipt(config,"StarterPack","starter"))==Enum.ProductPurchaseDecision.PurchaseGranted,"Starter receipt grants bundle")
 p=d.Get(player);check(#p.GrowCredits==2 and p.GrowCredits[1]=="Grow10"and p.GrowCredits[2]=="Grow10"and p.ProductsOwned.StarterPack,"Exactly two reusable credits and once-only ownership")
 check(p.Journal.Cosmetics.Owned.SproutPlanter and p.Journal.Cosmetics.Owned.Bud,"Starter decoration and short title owned")
 check(not service.Intent(player,"Product",{Key="StarterPack"}),"One-per-account blocks another prompt")
 local coins=p.Coins;service.ProcessReceipt(receipt(config,"StarterPack","another-starter"));p=d.Get(player)
 check(p.Coins==coins and #p.GrowCredits==2,"Different receipt cannot repeat once-per-account bundle")
 p.Coins=Game.AscensionThreshold(p);Game.RebirthProfile(p)
 check(p.ProductsOwned.StarterPack and #p.GrowCredits==2 and p.Journal.Cosmetics.Owned.Bud,"Bundle ownership, credits and cosmetics survive Ascension")
 p= P.New(0);p.Journal.Reference={Income=C.Rewards.MaxReferenceIncome,At=1000};p.Passes.Coins=true;p.Boosts.LuckFactor=4
 check(Purchase.Quote(p,"StarterPack",1000).Coins==C.Monetization.StarterCoinCap,"Starter reward cap applies")
 check(Purchase.Quote(p,"CoinsL",1000).Coins==C.Monetization.CoinPackCap,"Large coin pack cap applies")
 p=P.New(0);p.Plots={{Build=P.Starter()}};local base=Purchase.Quote(p,"CoinsM",1000).Coins
 p.Passes.Coins=true;p.Passes.VIP=true;p.Pets={{Id="pet",Tier=3,Rarity=5,Shiny=true}};p.EquippedPets={"pet"}
 check(Purchase.Quote(p,"CoinsM",1000).Coins==base,"Coin pack reference excludes paid and pet multipliers")
 check(not Purchase.Grant(p,"Maxer",1000)and not Purchase.Grant(p,"RebirthSkip",1000),"Removed product keys have no grant code")
 check(not Game.RebirthProfile(P.New(0),true),"No boolean bypass can skip an earned Ascension")
 for _,key in {"ExtraPlots","GrowthPad"}do
  p=P.New(0);p.Schema=7;p.Passes[key]=true;p.Growth2=Growth.New(p.Equipped,0,false);p.Growth2.HeightScale=1.4;p.Growth2.Duration=175
  p.Plots[3]={Build=P.Starter(),State="Producing",NextDrop=0};local id=p.Growth2.Id
  P.Migrate(p,1)
  check(p.Passes.ThirdPad and p.LegacySecondPad and not p.Passes[key]and Growth.MaxPads(p)==3,"Retired entitlement migrates without losing pad access: "..key)
  check(p.Growth2.Id==id and p.Growth2.Duration==175 and p.Growth2.HeightScale==1.4 and p.Upgrades.Plots==3,"Existing occupied plot and saved tree preserved: "..key)
  P.Migrate(p,2);check(p.Growth2.Id==id and p.Upgrades.Plots==3,"Migration is idempotent: "..key)
 end
 p=P.New(0);p.Schema=7;p.PurchaseLog.old={Key="StarterPack"};P.Migrate(p,1000)
 check(p.ProductsOwned.StarterPack and p.Journal.Cosmetics.Owned.Bud and #(p.GrowCredits or {})==0,"Historical Starter purchase stays consumed without replaying coins/credits")
 p=P.New(0);p.Passes.ThirdPad=true
 check(Growth.MaxPads(p)==1 and Growth.QueueLimit(p)==2,"Third-pad pass never unlocks pad 2 or bypasses first Ascension")
 p.Rebirths=1;check(Growth.MaxPads(p)==3 and Growth.QueueLimit(p)==3,"Eligible pass adds pad 3 and one queued snapshot")
 p.Passes.ThirdPad=false;check(Growth.MaxPads(p)==2,"Second pad remains free")
 p.Rebirths=C.Growth.ThirdFreeAscensions;p.PolicyRestricted=true
 check(Growth.MaxPads(p)==3 and Growth.QueueLimit(p)==3,"Free third-pad milestone works for restricted accounts")
 for _=1,3 do check(Growth.Plant(p,1000),"Three independent builds can plant")end
 local first,second,third=p.Growth.Id,p.Growth2.Id,p.Growth3.Id
 check(first~=second and second~=third and first~=third,"All three pad identities differ")
 for _=1,3 do check(Growth.Queue(p,1000),"Three snapshots fit enhanced queue")end
 check(not Growth.Queue(p,1000)and #p.GrowthQueue==3,"Enhanced queue has a hard bound")
 Growth.Step(p,2000,1)
 local sel={GrowthPad=3,GrowthId=third,Expires=3000,Plots={1},Targets={[1]=false}}
 check(Rules.Validate(p,sel,1,third,1,2001),"Third ready pad validates immutable capability")
 check(not Rules.Validate(p,sel,1,second,1,2001),"Third-pad selection rejects other pad identity")
 local snapshot=p.GrowthQueue[1].Build.Trunk.Stat
 check(Growth.Swap(p,1,1,2001,false,3)and p.Growth.Id==first and p.Growth2.Id==second and p.Growth3.Id~=third and p.Growth3.Build.Trunk.Stat==snapshot,"Third placement pumps FIFO without touching other pads")
 local restored=P.Migrate(game.HttpService:JSONDecode(game.HttpService:JSONEncode(p)),2100)
 check(restored.Growth3.Id==p.Growth3.Id and #restored.GrowthQueue==2,"Third tree and queue round-trip without loss")
 service,d,player,market,config=fixture();p=d.Get(player);p.Passes.ThirdPad=true
 p.Growth3=Growth.New(p.Equipped,1000,false);p.Growth3.Duration=300
 check(service.Intent(player,"GrowNow",{})and d.Get(player).PurchasePending.Key=="Grow10","Grow Now reaches pad 3 and picks correct bracket")
 service.ProcessReceipt(receipt(config,"Grow10","third-skip"));p=d.Get(player)
 check(p.Growth3.State=="Ready","Receipt finishes the original third-pad tree")
 p.Growth3=Growth.New(p.Equipped,1000,false);p.Growth3.Duration=300
 check(Purchase.Grant(p,"Grow10",1000,"replaced-tree")and p.GrowCredits[1]=="Grow10","Changed pad-3 identity becomes a reusable credit")
 check(service.Intent(player,"RedeemGrow",{})and d.Get(player).Growth3.State=="Ready"and #d.Get(player).GrowCredits==0,"Credit redeems on third pad exactly once")
 -- Spending limits apply to every configured draft in the fake Marketplace only.
 for key,item in C.Passes do local q,d,actor,m=fixture();local profile=d.Get(actor);profile.Settings.SpendingLimit=item.ProposedPrice-1
  check(not q.Intent(actor,"Pass",{Key=key})and #m.Prompts==0,"Spending limit blocks pass: "..key)
 end
 for key,item in C.Products do local q,d,actor,m=fixture();local profile=d.Get(actor);profile.Settings.SpendingLimit=item.ProposedPrice-1
  if item.Limit then growFor(profile,item.Limit)end
  check(not q.Intent(actor,item.Limit and "GrowNow"or "Product",item.Limit and {}or{Key=key})and #m.Prompts==0,"Spending limit blocks product: "..key)
 end
 p=P.New(0);p.Boosts={LuckFactor=4,LuckUntil=2000};local previousLuck=Game.Luck(p,1000)
 check(Game.PurchaseLuck(p,1000,nil,"SuperLucky")==previousLuck/2 and Game.PurchaseLuck(p,1000,nil,"UltraLucky")==previousLuck,"Luck product preview respects factor replacement")
 check(Game.PurchaseLuck(p,1000,nil,"Luck")==previousLuck*2 and p.Boosts.LuckFactor==4 and not p.Passes.Luck,"Pass preview doubles once without mutating profile")
 p.PolicyRestricted=true;local restrictedLuck=Game.Luck(p,1000)
 check(Game.PurchaseLuck(p,1000,nil,"Luck")==restrictedLuck and Game.PurchaseLuck(p,1000,nil,"UltraLucky")==restrictedLuck,"Restricted previews never activate paid luck")
 local oldCurrent,oldEnds,oldPrivate=Event.Current,Event.Ends,Game.Private
 local ok,err=pcall(function()
  p=P.New(100);p.Passes.GrowthSpeed=true;Game.Private=true;p.Rebirths=3
  for pad=1,3 do local tree=Growth.New(p.Equipped,100,false);tree.Duration=3600;Growth.Set(p,pad,tree)end
  Event.Current="Golden Rain";Event.Ends=1000;check(Game.Rate(p,100)==2*1.25*3,"Double Growth multiplies private and Golden Rain")
  Event.Current="Windstorm";check(Game.Rate(p,100)==2*1.25*5,"Windstorm replaces Rain rather than stacking both events")
  Growth.Step(p,100,Game.Rate(p,100));Growth.Step(p,110,Game.Rate(p,110))
  check(p.Growth.Progress==125 and p.Growth2.Progress==125 and p.Growth3.Progress==125,"All three pads receive identical multiplicative rate")
  Game.OfflineGrowth(p,210)
  check(p.Growth.Progress==375 and p.Growth2.Progress==375 and p.Growth3.Progress==375,"Offline settlement strips saved weather rate on all pads")
 end)
 Event.Current=oldCurrent;Event.Ends=oldEnds;Game.Private=oldPrivate;assert(ok,err)
 p=P.New(0);p.Passes.Cosmetics=true;p.PolicyRestricted=true;Purchase.SyncCosmetics(p)
 check(E.Has(p,"Cosmetics")and p.Journal.Cosmetics.Owned.SunsetGlow and p.Journal.Cosmetics.Owned.Pinwheel,"Cosmetic bundle works without paid-random eligibility")
 check(K.Equip(p,"Aura","SunsetGlow")and K.Equip(p,"Decoration","Pinwheel"),"Bundle cosmetics use owned inventory/equip rules")
 check(K.Equip(p,"Aura","")and not K.Equip(p,"Title","Pinwheel"),"Unequip works; wrong cosmetic slot rejects")
 p=P.New(0);p.Journal.EventTokens=100
 for _,key in {"SunsetGlow","Pinwheel","SproutPlanter","Bud"}do check(K.BuyMedal(p,key),"New paid cosmetic has a deterministic free Medal path: "..key)end
 local q,d,actor,m=fixture();local profile=d.Get(actor);for _,key in C.Cosmetics.Bundle do K.GrantCosmetic(profile,key)end
 check(not q.Intent(actor,"Pass",{Key="Cosmetics"})and #m.Prompts==0,"Already earned bundle cannot prompt a redundant purchase")
 check(#C.Cosmetics.Featured==8 and Game.MutationLuck(p)==1,"Eight featured cosmetics; mutation-luck activation stays disabled")
 check(not Validate("Product",{Key="StarterPack",Coins=1e9})and not Validate("Pass",{Key="ThirdPad",Price=0})and not Validate("GrowNow",{Pad=3}),"Purchase intents reject client rewards, prices and pad authority")
 print("Build a Tree commerce: "..checks.." checks passed");return checks
end
return Tests
