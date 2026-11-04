-- Self-only admin commands: immutable account authorization, bounded input and profile audit log.
local S=game:GetService("ReplicatedStorage").BuildATree
local C=require(S.Config)
local Config=require(script.Parent.AdminConfig)
local Parse=require(S.Util.ParseNumber)
local Validate=require(S.Util.IntentValidator)
local Catalog=require(S.Util.PartCatalog)
local P=require(S.Util.Profile)
local A={}
local actions={AdminCoins=true,AdminPart=true,AdminCatalogPart=true,AdminAllParts=true,AdminLuck=true,AdminResetLuck=true}
function A.IsAdmin(player) return player~=nil and player.UserId==Config.UserId end
function A.Handles(action) return actions[action]==true end
function A.Override(profile)
 local setting=profile.AdminControls
 if not setting or type(setting.LuckOverride)~="number" then return nil end
 local value=setting.LuckOverride
 if value~=value or value<Config.MinLuck or value>Config.MaxLuck then return nil end
 return value
end
local function audit(p,action,value)
 p.AdminControls=p.AdminControls or {};p.AdminControls.Audit=p.AdminControls.Audit or {}
 table.insert(p.AdminControls.Audit,{Action=action,Value=value,At=os.time()})
 while #p.AdminControls.Audit>Config.AuditLimit do table.remove(p.AdminControls.Audit,1) end
end
local function makePart(slot,tier,id,variant)
 local rarity=C.Rarities[tier];local scale=slot=="Roots" and C.Math.RootBase or slot=="Leaves" and C.Math.LeafBase or 1
 return {Id=id,Slot=slot,Tier=tier,Stat=rarity.Max*scale,Name=Catalog.Variants(slot,tier)[variant or 1],Variant=variant or 1,Mutation="None"}
end
function A.Execute(player,p,action,args,nextId)
 -- Never authorize via a display name, a replicated flag or a client-supplied target.
 if not A.IsAdmin(player) then return false,"Admin access denied." end
 if not A.Handles(action) or not Validate(action,args) then return false,"Invalid admin request." end
 if action=="AdminCoins" then
  local amount=Parse(args.Amount,0,C.Runtime.MaxCoins)
  if not amount then return false,"Enter a valid coin amount between 0 and 1No (1e30)." end
  if args.Mode=="Set" then p.Coins=amount
  elseif args.Mode=="Add" then p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+amount)
  elseif args.Mode=="Remove" then p.Coins=math.max(0,p.Coins-amount)
  else return false,"Unknown coin operation." end
  audit(p,action,args.Mode.." "..tostring(amount));return true,"Your coin balance was updated."
 elseif action=="AdminPart" or action=="AdminCatalogPart" then
  if not table.find(C.Slots,args.Slot) or args.Tier%1~=0 or not C.Rarities[args.Tier] then return false,"Choose a valid slot and rarity." end
  if require(S.Util.PartOwnership).Count(p)>=C.Runtime.MaxInventory then return false,"Your part inventory is full." end
  local variant=1;local equip=args.Equip
  if action=="AdminCatalogPart" then
   local raw,mode=args.Choice:match("^(%d+):(%a+)$");variant=tonumber(raw)
   if not variant or not Catalog.Variants(args.Slot,args.Tier)[variant] or (mode~="Give" and mode~="Equip") then return false,"Choose a valid catalog part." end
   equip=mode=="Equip"
  end
  local part=makePart(args.Slot,args.Tier,nextId(),variant);if require(S.Util.PartOwnership).Part(p,part.Id)then return false,"That identity is already owned. Nothing changed."end;table.insert(p.Parts,part)
  if equip then p.Equipped[part.Slot]=P.Copy(part) end
  audit(p,action,part.Name);return true,"Granted "..C.Rarities[part.Tier].Name.." "..part.Name..(equip and " and equipped it." or ".")
 elseif action=="AdminAllParts" then
  local total=Catalog.Count()
  if require(S.Util.PartOwnership).Count(p)+total>C.Runtime.MaxInventory then return false,"Make room for "..total.." parts first." end
  for _,slot in C.Slots do for tier=1,#C.Rarities do for variant=1,#Catalog.Variants(slot,tier) do table.insert(p.Parts,makePart(slot,tier,nextId(),variant)) end end end
  audit(p,action,total);return true,"Added all "..total.." catalog parts to your inventory."
 elseif action=="AdminLuck" then
  local multiplier=Parse(args.Multiplier,Config.MinLuck,Config.MaxLuck)
  if not multiplier then return false,"Luck must be between "..Config.MinLuck.."× and "..Config.MaxLuck.."×." end
  p.AdminControls=p.AdminControls or {};p.AdminControls.LuckOverride=multiplier
  audit(p,action,multiplier);return true,"Your roll luck override is now "..multiplier.."×."
 elseif action=="AdminResetLuck" then
  p.AdminControls=p.AdminControls or {};p.AdminControls.LuckOverride=nil
  audit(p,action,"Normal");return true,"Your normal roll luck is restored."
 end
 return false,"Unknown admin command."
end
return A
