-- Idempotent durable receipts. No rewards are exposed before the saved transaction commits.
local Marketplace=game:GetService("MarketplaceService")
local Players=game:GetService("Players")
local S=game:GetService("ReplicatedStorage").BuildATree
local C=require(S.Config)
local G=require(S.Util.GrowthCalculator)
local Growth=require(script.Parent.GrowthService)
local D=require(script.Parent.DataService)
local Purchase={}
local Game
local randomized={CoinsS=true,CoinsM=true,CoinsL=true,SuperLucky=true,UltraLucky=true,Maxer=true}
function Purchase.CanSpend(p,price)
 return p.Settings.SpendingLimit==0 or p.ProductSpent+price<=p.Settings.SpendingLimit
end
function Purchase.GrowKey(remaining)
 for _,key in C.GrowProducts do if remaining<=C.Products[key].Limit then return key end end
end
function Purchase.GrantGrow(p,context,now,limit)
 local g,pad=Growth.Find(p,context)
 if not g or g.Tutorial or g.Id~=context or g.State=="Ready" then return false end
 G.Settle(g,now)
 if G.Remaining(g)<=0 or G.Remaining(g)>limit then return false end
 return Growth.Finish(p,pad)
end
function Purchase.Grant(p,key,now,context)
 local gameService=Game or require(script.Parent.GameService)
 local product=C.Products[key]
 if key=="StarterPack"then p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+math.max(1,gameService.Income(p,now))*product.Seconds);p.GrowCredits=p.GrowCredits or {};table.insert(p.GrowCredits,"Grow10")
 elseif product.Limit then
  if not Purchase.GrantGrow(p,context,now,product.Limit) then
   -- Changed/finished tree: preserve the purchase as an explicit reusable skip credit.
   p.GrowCredits=p.GrowCredits or {}; table.insert(p.GrowCredits,key)
  end
 elseif product.Seconds then p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+math.max(1,gameService.Income(p,now))*product.Seconds)
 elseif product.Factor then p.Boosts.LuckUntil=math.max(now,p.Boosts.LuckUntil or now)+product.Duration; p.Boosts.LuckFactor=product.Factor
 elseif key=="Shield" then p.Boosts.ShieldUntil=now+C.Sabotage.ShieldDuration
 elseif key=="RebirthSkip" then gameService.RebirthProfile(p,true)
 elseif key=="Maxer" then
  -- Deterministic upgrade, not a secret random roll.
  for _,slot in C.Slots do local part=p.Equipped[slot]; part.Tier=#C.Rarities; part.Stat=C.Rarities[#C.Rarities].Max*(slot=="Roots" and C.Math.RootBase or 1); part.Name=C.PartNames[slot][#C.Rarities];part.Variant=1 end
 end
end
function Purchase.Intent(player,action,args)
 local p=D.Get(player); local now=os.time()
 if action=="RedeemGrow" then
  Game.Settle(player,now)
  for pad=1,2 do local tree=Growth.Get(p,pad);if tree and not tree.Tutorial and tree.State=="Growing"then
   for i,key in p.GrowCredits or {}do if G.Remaining(tree)<=C.Products[key].Limit then Growth.Finish(p,pad);table.remove(p.GrowCredits,i);return true,"Growth credit redeemed on pad "..pad.."."end end
  end end
  return false,"No credit covers this remaining grow time."
 elseif action=="Pass" then
  local pass=C.Passes[args.Key]; if not pass then return false,"Unknown pass." end
  if args.Key=="GrowthPad"and Growth.MaxPads(p)>=2 then return false,"Growth pad 2 is already unlocked."end
  if args.Key=="ExtraPlots"and Game.MaxPlots(p)>=C.Growth.TotalPlots and Growth.MaxPads(p)>=2 then return false,"All benefits of this pass are already unlocked."end
  if not D.Persistent(player) then return false,"Purchases are disabled in memory-only Studio preview." end
  if args.Key~="Cosmetics"and not Game.Runtime[player].PaidRandom then return false,"Paid gameplay boosts are unavailable for this account. Earned progression remains available."end
  if pass.New and not C.Monetization.EnableNewPurchases then return false,"This new pass is a disabled draft; no charge can occur."end
  if not Purchase.CanSpend(p,pass.Price) then return false,"Your optional spending limit blocks this purchase." end
  if pass.Id==0 then return false,"This pass is not configured yet." end
  if p.Passes[args.Key] then return false,"Already owned." end
  Marketplace:PromptGamePassPurchase(player,pass.Id); return true
 elseif action=="Product" or action=="GrowNow" then
  local key=args.Key;local growTree
  if action=="GrowNow"then
   Game.Settle(player,now);growTree=Growth.Active(p)
   if not growTree then return false,"Plant a non-tutorial tree first. Ready trees do not need a skip."end
   key=Purchase.GrowKey(G.Remaining(growTree))
  end
  local product=key and C.Products[key]; if not product then return false,"Unknown product." end
  if product.Limit and action~="GrowNow" then return false,"Use Grow Now so the correct bracket is selected." end
  if not D.Persistent(player) then return false,"Purchases are disabled in memory-only Studio preview." end
  if product.New and not C.Monetization.EnableNewPurchases then return false,"This product is a disabled draft; no charge can occur."end
  if not Game.Runtime[player].PaidRandom then return false,"Paid random-item purchases are unavailable for this account." end
  if not Purchase.CanSpend(p,product.Price) then return false,"Your optional spending limit blocks this purchase." end
  if product.Id==0 then return false,"This product is not configured yet. The free path is fully playable." end
  if p.PurchasePending then return false,"Please finish or cancel the current purchase first." end
  local context=product.Limit and growTree.Id or false
  local ok=D.Transaction(player,function(draft)
   draft.PurchasePending={Key=key,Tree=context,At=now}; return true
  end)
  if not ok then return false,"Could not safely save the purchase request. Try again shortly." end
  Marketplace:PromptProductPurchase(player,product.Id); return true
 end
 return false
end
function Purchase.LoadPasses(player)
 local p=D.Get(player); if not p then return end
 for key,pass in C.Passes do if pass.Id~=0 then
  local ok,owns=pcall(Marketplace.UserOwnsGamePassAsync,Marketplace,player.UserId,pass.Id)
  if ok and D.Get(player)then Game.Settle(player,os.time());D.Get(player).Passes[key]=owns end
 end end
end
function Purchase.Init(gameService)
 Game=gameService; Game.Purchase=Purchase
 Marketplace.ProcessReceipt=function(receipt)
  local player=Players:GetPlayerByUserId(receipt.PlayerId)
  if not player or not D.Get(player) then return Enum.ProductPurchaseDecision.NotProcessedYet end
  local key
  for name,product in C.Products do if product.Id~=0 and product.Id==receipt.ProductId then key=name; break end end
  if not key then warn("Unmapped developer product",receipt.ProductId); return Enum.ProductPurchaseDecision.NotProcessedYet end
  local ok=D.Transaction(player,function(draft)
   local id=tostring(receipt.PurchaseId)
   if draft.Receipts[id] then return false,"duplicate" end
   local context=draft.PurchasePending
   Purchase.Grant(draft,key,os.time(),context and context.Key==key and context.Tree or nil)
   draft.ProductSpent+=C.Products[key].Price
   draft.Receipts[id]=true; draft.PurchaseLog[id]={Key=key,At=os.time()}; draft.PurchasePending=nil
   return true
  end)
  if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
  Game.Toast(player,"Purchase received. Thank you! Any unused growth skip is saved as a credit."); Game.State(player)
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end
 Marketplace.PromptProductPurchaseFinished:Connect(function(userId,_,purchased)
  local player=Players:GetPlayerByUserId(userId)
  if player and not purchased and D.Get(player) then D.Transaction(player,function(p) p.PurchasePending=nil; return true end); Game.Toast(player,"Purchase cancelled; no reward granted.") end
 end)
 Marketplace.PromptGamePassPurchaseFinished:Connect(function(player,id,purchased)
  if not purchased then return end
  Purchase.LoadPasses(player)
  local p=D.Get(player); if p then for _,pass in C.Passes do if pass.Id==id then p.ProductSpent+=pass.Price end end; D.Save(player); Game.State(player) end
 end)
end
return Purchase
