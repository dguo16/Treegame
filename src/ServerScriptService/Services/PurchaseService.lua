-- Server-owned prompts and durable, session-safe receipts. Production IDs are all zero.
local S=game:GetService("ReplicatedStorage").BuildATree
local Config=require(S.Config)
local P=require(S.Util.Profile)
local G=require(S.Util.GrowthCalculator)
local Journal=require(S.Util.Journal)
local Collection=require(S.Util.Collection)
local Growth=require(script.Parent.GrowthService)
local function create(deps)
 deps=deps or {}
 local C=deps.Config or Config
 local Marketplace=deps.Marketplace or game:GetService("MarketplaceService")
 local Players=deps.Players or game:GetService("Players")
 local D=deps.Data or require(script.Parent.DataService)
 local clock=deps.Now or os.time
 local Game
 local Purchase={}
 function Purchase.Price(item)return item.ProposedPrice or item.Price end
 function Purchase.CanSpend(p,price)
  return type(price)=="number"and price>=0 and(p.Settings.SpendingLimit==0 or p.ProductSpent+price<=p.Settings.SpendingLimit)
 end
 function Purchase.Allowed(p,item,player)
  local rt=Game and Game.Runtime[player]
  return item and(not item.PaidRandom or(not p.PolicyRestricted and rt and rt.PaidRandom==true))
 end
 function Purchase.GrowKey(remaining)
  for _,key in C.GrowProducts do if remaining<=C.Products[key].Limit then return key end end
 end
 function Purchase.Quote(p,key,now)
  local product=C.Products[key];if not product or not product.Seconds then return nil end
  local reference=Journal.ObserveIncome(p,now)
  return {Coins=math.floor(math.min(product.Cap,C.Runtime.MaxCoins,reference*product.Seconds)),Reference=reference,At=now}
 end
 function Purchase.GrantGrow(p,context,now,limit)
  local g,pad=Growth.Find(p,context)
  if not g or g.Tutorial or g.Id~=context or g.State=="Ready"then return false end
  G.Settle(g,now)
  if G.Remaining(g)<=0 or G.Remaining(g)>limit then return false end
  return Growth.Finish(p,pad)
 end
 function Purchase.SyncCosmetics(p)
  if p.Passes.Cosmetics then for _,key in C.Cosmetics.Bundle do Collection.GrantCosmetic(p,key)end end
 end
 function Purchase.Grant(p,key,now,context,quote)
  local product=C.Products[key];if not product then return false,"Unknown product."end
  p.ProductsOwned=p.ProductsOwned or {};p.GrowCredits=p.GrowCredits or {}
  if product.Once and p.ProductsOwned[key]then return true,"already-owned"end
  if product.Limit then
   if not Purchase.GrantGrow(p,context,now,product.Limit)then table.insert(p.GrowCredits,key)end
  elseif product.Seconds then
   quote=quote or Purchase.Quote(p,key,now)
   if not quote or type(quote.Coins)~="number"or quote.Coins<0 then return false,"Missing server quote."end
   -- Persisted quotes are server-owned; cap again at delivery, never accept a client amount.
   p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+math.min(product.Cap,math.floor(quote.Coins)))
   if product.Once then
    for _=1,product.Credits do table.insert(p.GrowCredits,"Grow10")end
    for _,cosmetic in product.Cosmetics do Collection.GrantCosmetic(p,cosmetic)end
    p.ProductsOwned[key]=true
   end
  elseif product.Factor then
   p.Boosts.LuckUntil=math.max(now,p.Boosts.LuckUntil or now)+product.Duration
   p.Boosts.LuckFactor=product.Factor
  else return false,"Unknown grant."end
  return true
 end
 function Purchase.Intent(player,action,args)
  local p=D.Get(player);if not p then return false,"Profile unavailable."end
  local now=clock()
  if action=="RedeemGrow"then
   Game.Settle(player,now)
   for pad=1,C.Growth.MaxPads do local tree=Growth.Get(p,pad);if tree and not tree.Tutorial and tree.State=="Growing"then
    for i,key in p.GrowCredits or {}do local product=C.Products[key]
     if product and product.Limit and G.Remaining(tree)<=product.Limit then Growth.Finish(p,pad);table.remove(p.GrowCredits,i);return true,"Growth credit redeemed on pad "..pad.."."end
    end
   end end
   return false,"No credit covers this remaining grow time."
  elseif action=="Pass"then
   local pass=C.Passes[args.Key];if not pass then return false,"Unknown pass."end
   if p.Passes[args.Key]then return false,"Already owned."end
   if args.Key=="Cosmetics"then local all=true;for _,key in C.Cosmetics.Bundle do if not p.Journal.Cosmetics.Owned[key]then all=false end end;if all then return false,"All bundle cosmetics are already earned."end end
   if args.Key=="ThirdPad"and Growth.MaxPads(p)>=3 then return false,"Pad 3 and queue +1 are already earned."end
   if args.Key=="ThirdPad"and Growth.MaxPads(p)<2 then return false,"First Ascension unlocks pad 2. This pass never skips that milestone."end
   if not Purchase.Allowed(p,pass,player)then return false,"Paid gameplay boosts are unavailable for this account. Free progression stays available."end
   if not D.Persistent(player)then return false,"Purchases are disabled in memory-only Studio preview."end
   if not C.Monetization.EnableNewPurchases then return false,"Disabled draft; no charge can occur."end
   if pass.Id==0 then return false,"This pass is not configured."end
   if not Purchase.CanSpend(p,Purchase.Price(pass))then return false,"Your optional spending limit blocks this purchase."end
   Marketplace:PromptGamePassPurchase(player,pass.Id);return true
  elseif action=="Product"or action=="GrowNow"then
   local key=args.Key;local tree
   if action=="GrowNow"then
    Game.Settle(player,now);tree=Growth.Active(p)
    if not tree then return false,"Plant a non-tutorial tree first. Ready trees do not need a skip."end
    key=Purchase.GrowKey(G.Remaining(tree))
   end
   local product=key and C.Products[key];if not product then return false,"Unknown product."end
   if product.Once and p.ProductsOwned[key]then return false,"Starter Pack is already claimed for this account."end
   if product.Limit and action~="GrowNow"then return false,"Use Grow Now so the server selects the bracket."end
   if not Purchase.Allowed(p,product,player)then return false,"This paid gameplay item is unavailable for this account. Earned progression stays available."end
   if not D.Persistent(player)then return false,"Purchases are disabled in memory-only Studio preview."end
   if not C.Monetization.EnableNewPurchases then return false,"Disabled draft; no charge can occur."end
   if product.Id==0 then return false,"This product is not configured. Free progression stays available."end
   if not Purchase.CanSpend(p,Purchase.Price(product))then return false,"Your optional spending limit blocks this purchase."end
   if p.PurchasePending then return false,"Finish or cancel the current purchase first."end
   local treeId=tree and tree.Id or false
   local ok=D.Transaction(player,function(draft)
    local quote=Purchase.Quote(draft,key,now)
    if product.Seconds and(not quote or quote.Coins<=0)then return false,"no-income"end
    draft.ProductQuotes=draft.ProductQuotes or {};draft.ProductQuotes[key]=quote
    draft.PurchasePending={Key=key,Tree=treeId,At=now,Quote=quote,Price=Purchase.Price(product)}
    return true
   end)
   if not ok then return false,"Grow a producing tree first, or retry when your save is available."end
   Marketplace:PromptProductPurchase(player,product.Id);return true
  end
  return false
 end
 function Purchase.LoadPasses(player)
  for key,pass in C.Passes do if pass.Id~=0 then
   local ok,owns=pcall(Marketplace.UserOwnsGamePassAsync,Marketplace,player.UserId,pass.Id)
   if ok and D.Get(player)then
    Game.Settle(player,clock())
    D.Transaction(player,function(draft)draft.Passes[key]=owns;Purchase.SyncCosmetics(draft);return true end)
   end
  end end
 end
 function Purchase.ProcessReceipt(receipt)
  local player=Players:GetPlayerByUserId(receipt.PlayerId)
  if not player or not D.Get(player)then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local key
  for name,product in C.Products do if product.Id~=0 and product.Id==receipt.ProductId then key=name;break end end
  if not key then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local id=tostring(receipt.PurchaseId);local p=D.Get(player)
  -- A committed duplicate is acknowledged even if policy later changes.
  if p.Receipts[id]then return Enum.ProductPurchaseDecision.PurchaseGranted end
  if not Purchase.Allowed(p,C.Products[key],player)then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local ok=D.Transaction(player,function(draft)
   if draft.Receipts[id]then return false,"duplicate"end
   local pending=draft.PurchasePending
   local context=pending and pending.Key==key and pending.Tree or nil
   local quote=pending and pending.Key==key and pending.Quote or(draft.ProductQuotes or {})[key]
   if C.Products[key].Once and not draft.ProductsOwned[key]and not quote then return false,"missing-purchase-quote"end
   local before=draft.Coins
   local granted,reason=Purchase.Grant(draft,key,clock(),context,quote)
   if not granted then return false,reason end
   local spent=receipt.CurrencySpent
   if type(spent)~="number"or spent~=spent or spent<0 or spent%1~=0 or spent>1000000 then spent=Purchase.Price(C.Products[key])end
   draft.ProductSpent+=spent;draft.Receipts[id]=true
   draft.PurchaseLog[id]={Key=key,At=clock(),Coins=draft.Coins-before,Reference=quote and quote.Reference or nil,Spent=spent,AlreadyOwned=reason=="already-owned"or nil}
   if pending and pending.Key==key then draft.PurchasePending=nil end
   return true
  end)
  if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
  Game.Toast(player,"Purchase received. Unused growth skips stay as credits.");Game.State(player)
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end
 function Purchase.Cancel(player,productId)
  local p=D.Get(player);local pending=p and p.PurchasePending
  if not pending or not C.Products[pending.Key]or C.Products[pending.Key].Id~=productId then return false end
  -- Keep the server quote for a valid receipt delivered after the cancel callback.
  return D.Transaction(player,function(draft)draft.PurchasePending=nil;return true end)
 end
 function Purchase.PassFinished(player,id,purchased)
  if not purchased then return false end
  local key,pass
  for name,item in C.Passes do if item.Id~=0 and item.Id==id then key=name;pass=item;break end end
  if not key or not D.Get(player)then return false end
  local ok,owns=pcall(Marketplace.UserOwnsGamePassAsync,Marketplace,player.UserId,id)
  if not ok or not owns then return false end
  Game.Settle(player,clock())
  local saved=D.Transaction(player,function(draft)
   draft.Passes[key]=true;Purchase.SyncCosmetics(draft)
   if not draft.PassSpendRecorded[key]then draft.ProductSpent+=Purchase.Price(pass);draft.PassSpendRecorded[key]=true end
   return true
  end)
  if saved then Game.State(player)end;return saved
 end
 function Purchase.Init(gameService)
  Game=gameService;Game.Purchase=Purchase
  Marketplace.ProcessReceipt=Purchase.ProcessReceipt
  Marketplace.PromptProductPurchaseFinished:Connect(function(userId,id,purchased)
   local player=Players:GetPlayerByUserId(userId)
   if player and not purchased and Purchase.Cancel(player,id)then Game.Toast(player,"Purchase cancelled; no reward granted.")end
  end)
  Marketplace.PromptGamePassPurchaseFinished:Connect(Purchase.PassFinished)
 end
 return Purchase
end
local service=create()
function service.CreateForTests(deps)
 assert(game:GetService("RunService"):IsStudio(),"Test dependencies are Studio-only")
 return create(deps)
end
return service
