-- Discovery sets and earned cosmetics. Pure server-owned state; no random rewards.
local C=require(script.Parent.Parent.Config)
local Catalog=require(script.Parent.PartCatalog)
local Collection={}
local GoalsCache
function Collection.NameKey(part)return part.Slot..":"..part.Tier..":"..Catalog.Variant(part)end
function Collection.Parse(key)
 if type(key)~="string"then return nil end
 local slot,tier,variant,mutation=key:match("^([^:]+):(%d+):(%d+):([^:]+)$")
 tier=tonumber(tier);variant=tonumber(variant)
 if not tier or not table.find(C.Slots,slot)or not C.PartVariants[slot][tier]or not C.PartVariants[slot][tier][variant]then return nil end
 local valid=false;for _,m in C.Mutations do if m.Name==mutation then valid=true end end
 if not valid then return nil end
 return {Slot=slot,Tier=tier,Variant=variant,Mutation=mutation,Name=C.PartVariants[slot][tier][variant]}
end
function Collection.Ensure(p)
 local j=p.Journal;assert(j,"Journal must exist before collection")
 j.Collection=j.Collection or {Names={},Claims={},Paid={},LegacyClaims={}}
 local c=j.Collection;c.Names=c.Names or {};c.Claims=c.Claims or {};c.Paid=c.Paid or {};c.LegacyClaims=c.LegacyClaims or {}
 j.Cosmetics=j.Cosmetics or {Owned={},Equipped={Aura="",Decoration="",Title=""},Purchases={},LikesClaims={}}
 local cosmetics=j.Cosmetics;cosmetics.Owned=cosmetics.Owned or {};cosmetics.Equipped=cosmetics.Equipped or {Aura="",Decoration="",Title=""};cosmetics.Purchases=cosmetics.Purchases or {};cosmetics.LikesClaims=cosmetics.LikesClaims or {}
 j.MedalSpent=j.MedalSpent or 0
 return c
end
function Collection.Migrate(p)
 local c=Collection.Ensure(p)
 for key,found in p.Journal.Found do if found then local part=Collection.Parse(key);if part then c.Names[Collection.NameKey(part)]=true end end end
 -- Old count goals have no one-to-one set equivalent. Preserve their claimed
 -- keys and historical payouts, never invent discoveries or replay old coins.
 for key,claimed in p.Journal.Claims do if claimed and key:match("^Index%d+$")then c.LegacyClaims[key]={Claimed=true,Paid=p.Journal.Paid[key]}end end
end
function Collection.Discover(p,part)
 local c=Collection.Ensure(p);c.Names[Collection.NameKey(part)]=true
end
function Collection.Goals()
 if GoalsCache then return GoalsCache end
 local goals={}
 local function add(key,title,kind,need,tier,slot,mutation,optional,cosmetic,stat)
  table.insert(goals,{Key=key,Title=title,Kind=kind,Need=need,Tier=tier,Slot=slot,Mutation=mutation,Optional=optional==true,Cosmetic=cosmetic,Stat=stat==true})
 end
 for tier,r in C.Rarities do
  local cosmetic=({"GreenGlow","BlueGlow","VioletGlow","StarPlanter","LegendaryCollector","MythicCollector","GodlyCollector"})[tier]
  add("Names"..tier,r.Name.." names","Names",12,tier,nil,nil,tier>C.Collection.CoreMaxTier,cosmetic,tier<=C.Collection.CoreMaxTier)
 end
 for _,slot in C.Slots do
  add("Slot"..slot,slot.." names • Common–Epic","CoreSlot",C.Collection.CoreMaxTier*3,nil,slot,nil,false,slot.."Collector")
  add("LegendSlot"..slot,slot.." • all rarities","FullSlot",#C.Rarities*3,nil,slot,nil,true,"Legend"..slot.."Collector")
 end
 for _,mutation in C.Collection.MutationOrder do
  add("Any"..mutation,"Find any "..mutation.." part","AnyMutation",1,nil,nil,mutation,false,mutation.."Finder")
 end
 for tier=1,C.Collection.CoreMaxTier do for _,mutation in C.Collection.MutationOrder do
  local cosmetic=({Golden="GoldGlow",Rainbow="RainbowGlow",Void="VoidGlow",Cosmic="CosmicGlow"})[mutation]
  add("Mutation"..tier..mutation,C.Rarities[tier].Name.." "..mutation.." names","Mutation",C.Collection.MutationNeeds[mutation],tier,nil,mutation,false,"Mutation"..tier..mutation)
  if tier==1 then goals[#goals].ExtraCosmetic=cosmetic end
 end end
 add("CoreNames48","Common–Epic name collection","CoreNames",C.Collection.CoreMaxTier*12,nil,nil,nil,false,"CoreCollector")
 add("AllNames84","All 84 names","AllNames",#C.Rarities*12,nil,nil,nil,true,"AllNames")
 for tier=C.Collection.CoreMaxTier+1,#C.Rarities do add("Legend"..tier,C.Rarities[tier].Name.." • all mutations","LegendTier",12*#C.Mutations,tier,nil,nil,true,"Legend"..tier)end
 add("Legend420","All 420 combinations","Legend",Catalog.Count()*#C.Mutations,nil,nil,nil,true,"LegendAll")
 GoalsCache=goals;return goals
end
function Collection.Find(key)for _,g in Collection.Goals()do if g.Key==key then return g end end end
function Collection.Progress(p,g)
 local c=Collection.Ensure(p);local count=0
 if g.Kind=="Names"or g.Kind=="CoreSlot"or g.Kind=="FullSlot"or g.Kind=="CoreNames"or g.Kind=="AllNames"then
  for key,found in c.Names do if found then
   local part=Collection.Parse(key..":None")
   if part and(not g.Tier or part.Tier==g.Tier)and(not g.Slot or part.Slot==g.Slot)and((g.Kind~="CoreSlot"and g.Kind~="CoreNames")or part.Tier<=C.Collection.CoreMaxTier)then count+=1 end
  end end
 else
  for key,found in p.Journal.Found do if found then local part=Collection.Parse(key)
   if part and(not g.Tier or part.Tier==g.Tier)and(not g.Mutation or part.Mutation==g.Mutation)then count+=1 end
  end end
 end
 return math.min(count,g.Need)
end
function Collection.Factors(p)
 local c=Collection.Ensure(p);local sets=0
 for tier=1,C.Collection.CoreMaxTier do if c.Claims["Names"..tier]then sets+=1 end end
 return 1+math.min(C.Collection.CoinCap,sets*C.Collection.CoinPerSet),1+math.min(C.Collection.LuckCap,sets*C.Collection.LuckPerSet)
end
function Collection.PetSlots(p)return Collection.Ensure(p).Claims.CoreNames48 and C.Collection.ExtraPetSlots or 0 end
function Collection.Next(p)
 local c=Collection.Ensure(p);local best,ratio
 for _,g in Collection.Goals()do if not g.Optional and not c.Claims[g.Key]then
  local progress=Collection.Progress(p,g);local score=progress/g.Need
  if not best or score>ratio or(score==ratio and g.Need-progress<best.Remaining)then best={Key=g.Key,Title=g.Title,Progress=progress,Need=g.Need,Remaining=g.Need-progress};ratio=score end
 end end
 return best
end
function Collection.GrantCosmetic(p,key)
 if not C.Cosmetics.Items[key]then return end
 Collection.Ensure(p);p.Journal.Cosmetics.Owned[key]=true
end
function Collection.Quote(p,key,reference)
 local g=Collection.Find(key);if not g then return nil end
 if g.Optional then return 0 end
 return math.floor(math.min(C.Collection.CoinCapReward,C.Rewards.MaxRewardCoins,math.max(C.Collection.CoinFloor,math.clamp(reference or 0,0,C.Rewards.MaxReferenceIncome)*C.Collection.CoinSeconds)))
end
function Collection.Claim(p,key,reference,now)
 local c=Collection.Ensure(p);local g=Collection.Find(key)
 if not g or c.Claims[key]or Collection.Progress(p,g)<g.Need then return false,"Set unavailable, incomplete or already claimed."end
 local amount=Collection.Quote(p,key,reference);local before=p.Coins
 p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+amount);local paid=p.Coins-before
 c.Claims[key]=true;c.Paid[key]=paid;Collection.GrantCosmetic(p,g.Cosmetic);if g.ExtraCosmetic then Collection.GrantCosmetic(p,g.ExtraCosmetic)end
 table.insert(p.Journal.RewardLog,{Key="Collection:"..key,At=now,Reference=reference,Quoted=amount,Paid=paid})
 while #p.Journal.RewardLog>C.Rewards.AuditLimit do table.remove(p.Journal.RewardLog,1)end
 p.Journal.Version+=1
 return true,"Set completed! "..C.Cosmetics.Items[g.Cosmetic].Name.." unlocked"..(paid>0 and (" • +"..paid.." coins")or "")
end
function Collection.MedalBalance(p)Collection.Ensure(p);return math.max(0,(p.Journal.EventTokens or 0)-p.Journal.MedalSpent)end
function Collection.BuyMedal(p,key)
 Collection.Ensure(p);local j=p.Journal;local price
 for _,item in C.Cosmetics.MedalShop do if item.Key==key then price=item.Cost;break end end
 if not price or j.Cosmetics.Owned[key]then return false,"Item unavailable or already owned."end
 if Collection.MedalBalance(p)<price then return false,"More participation medals needed."end
 j.MedalSpent+=price;j.Cosmetics.Purchases[key]=price;Collection.GrantCosmetic(p,key);j.Version+=1
 return true,"Cosmetic unlocked. Equip it in Journal → Style."
end
function Collection.Equip(p,slot,key)
 Collection.Ensure(p)
 if slot~="Aura"and slot~="Decoration"and slot~="Title"then return false,"Unknown cosmetic slot."end
 local item=C.Cosmetics.Items[key]
 if key~=""and(not item or item.Slot~=slot or not p.Journal.Cosmetics.Owned[key])then return false,"That cosmetic is not owned in this slot."end
 p.Journal.Cosmetics.Equipped[slot]=key;p.Journal.Version+=1;return true,"Style updated."
end
function Collection.ClaimLikes(p,key)
 Collection.Ensure(p);local j=p.Journal
 for i,need in C.Collection.Likes do if key=="Likes"..need then
  if (j.LikesReceived or 0)<need or j.Cosmetics.LikesClaims[key]then return false,"Like milestone unavailable."end
  j.Cosmetics.LikesClaims[key]=true;Collection.GrantCosmetic(p,C.Collection.LikeRewards[i]);j.Version+=1
  return true,"Like milestone cosmetic unlocked!"
 end end
 return false,"Unknown like milestone."
end
return Collection
