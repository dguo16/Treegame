-- Server-owned fruit stacks. New arrivals blend unit values; totals are conserved.
local H=game:GetService("HttpService")
local C=require(script.Parent.Parent.Config)
local Sizes=require(script.Parent.FruitSizes)
local Bag={}
local function newId()return "harvest_"..H:GenerateGUID(false)end
local function validId(id)return type(id)=="string"and #id>0 and #id<=80 end
function Bag.Recount(bag)
 local count,value=0,0
 for _,item in bag.Items do count+=item.Count;value+=item.TotalValue end
 bag.Count=count;bag.Value=value
end
function Bag.Ensure(bag,used)
 bag.Count=bag.Count or 0;bag.Value=bag.Value or 0;bag.Items=bag.Items or {};bag.Revision=bag.Revision or 0
 if bag.Count>0 and #bag.Items==0 then
  table.insert(bag.Items,{Id=newId(),Name="Saved Harvest",Tier=1,Mutation="None",Size="Normal",Value=bag.Value/bag.Count,TotalValue=bag.Value,Count=bag.Count})
 end
 used=used or {}
 for _,item in bag.Items do
  if not validId(item.Id)or used[item.Id]then item.Id=newId()end;used[item.Id]=true
  item.Size=Sizes.Get(item.Size).Name;item.TotalValue=item.TotalValue or item.Value*item.Count
 end
 Bag.Recount(bag);return bag
end
function Bag.EnsureProfile(p)
 local used={};Bag.Ensure(p.Bag,used)
 p.Vault=p.Vault or {Items={},Revision=0};p.Vault.Items=p.Vault.Items or {};p.Vault.Revision=p.Vault.Revision or 0
 local vault={Items=p.Vault.Items,Count=0,Value=0};Bag.Ensure(vault,used)
 for _,item in p.Vault.Items do item.Locked=true end
 return p
end
function Bag.Key(item)return item.Name..":"..item.Tier..":"..item.Mutation..":"..Sizes.Get(item.Size).Name end
function Bag.Add(bag,value,count,metadata,now,id)
 Bag.Ensure(bag);metadata=metadata or {Name="Harvest Fruit",Tier=1,Mutation="None"}
 local size=Sizes.Get(metadata.Size).Name
 local identity={Name=metadata.Name,Tier=metadata.Tier,Mutation=metadata.Mutation,Size=size}
 local found
 for _,item in bag.Items do if not item.Locked and Bag.Key(item)==Bag.Key(identity)then found=item;break end end
 if found then
  found.TotalValue+=value*count;found.Count+=count;found.Value=found.TotalValue/found.Count
  -- A legacy unknown first timestamp stays unknown; do not invent it.
  if now then found.LastObtainedAt=now end
 else
  local unique=validId(id)and id or newId();for _,item in bag.Items do if item.Id==unique then unique=newId();break end end
  table.insert(bag.Items,{Id=unique,Name=metadata.Name,Tier=metadata.Tier,Mutation=metadata.Mutation,Size=size,Value=value,TotalValue=value*count,Count=count,ObtainedAt=now,LastObtainedAt=now})
 end
 bag.Revision+=1;Bag.Recount(bag);return bag
end
function Bag.Find(container,id)
 for i,item in container.Items do if item.Id==id then return item,i end end
end
function Bag.All(bag,kind,below)
 Bag.Ensure(bag);local rows={}
 for _,item in bag.Items do if not item.Locked and(kind~="Plain"or item.Mutation=="None")and(kind~="Below"or item.Value<below)then table.insert(rows,{Id=item.Id,Quantity=item.Count})end end
 return rows
end
-- Correlates UI responses only; never used as sale authority or a client-supplied field.
function Bag.SaleKey(revision,rows)
 local out={tostring(revision)};for _,row in rows or {}do table.insert(out,row.Id.."@"..row.Quantity)end;return table.concat(out,"|")
end
function Bag.Sell(bag,revision,rows,internal)
 Bag.Ensure(bag)
 if type(revision)~="number"or revision%1~=0 or revision<0 or revision>bag.Revision then return false,{Message="Invalid or future bag revision. Refresh your bag."}end
 if type(rows)~="table"or #rows==0 or(not internal and #rows>C.FruitInventory.MaxSaleStacks)then return false,{Message="Choose fruit stacks to sell."}end
 local stale=revision~=bag.Revision;local seen,plan={},{};local missing,adjusted=0,0
 for _,row in rows do
  if type(row)~="table"or not validId(row.Id)or type(row.Quantity)~="number"or row.Quantity%1~=0 or row.Quantity<1 or row.Quantity>1e12 or seen[row.Id]then return false,{Message="Invalid fruit quantities."}end
  seen[row.Id]=true;local item=Bag.Find(bag,row.Id)
  if not item or item.Locked then
   if not stale then return false,{Message="That stack is unavailable. Refresh your bag."}end
   missing+=1
  elseif row.Quantity>item.Count and not stale then return false,{Message="That stack does not hold that many fruit."}
  else
   local quantity=math.min(row.Quantity,item.Count);if quantity~=row.Quantity then adjusted+=1 end
   table.insert(plan,{Item=item,Quantity=quantity})
  end
 end
 local result={Coins=0,Count=0,Stale=stale,Missing=missing,Adjusted=adjusted,Sold={}}
 -- All validation finishes before any fruit or value is removed.
 for _,entry in plan do
  local item=entry.Item;local q=entry.Quantity;local value=q==item.Count and item.TotalValue or item.TotalValue*q/item.Count
  result.Coins+=value;result.Count+=q;table.insert(result.Sold,{Id=item.Id,Quantity=q})
  item.Count-=q;item.TotalValue-=value
  if item.Count>0 then item.Value=item.TotalValue/item.Count end
 end
 for i=#bag.Items,1,-1 do if bag.Items[i].Count==0 then table.remove(bag.Items,i)end end
 if result.Count>0 then bag.Revision+=1 end;Bag.Recount(bag);result.Revision=bag.Revision
 result.Message=result.Count>0 and(stale and "Bag changed; sold the valid available quantities."or "Fruit sold!")or "No unlocked selected fruit remains."
 return result.Count>0,result
end
function Bag.Move(p,id,revision,lock,capacity)
 Bag.EnsureProfile(p)
 if revision~=p.Bag.Revision then return false,"Your fruit changed. Refresh and try again."end
 local from,to=lock and p.Bag or p.Vault,lock and p.Vault or p.Bag
 local item,index=Bag.Find(from,id)
 if not item then return false,"That stack is no longer here."end
 if lock and #p.Vault.Items>=C.FruitInventory.VaultStacks then return false,"Vault full: "..C.FruitInventory.VaultStacks.." stacks maximum."end
 if not lock and p.Bag.Count+item.Count>capacity then return false,"Your bag needs room for all "..item.Count.." fruit. Sell some unlocked fruit or upgrade your bag first."end
 table.remove(from.Items,index);item.Locked=lock and true or nil;table.insert(to.Items,item)
 p.Bag.Revision+=1;p.Vault.Revision+=1;Bag.Recount(p.Bag)
 return true,lock and "Stack locked in your Vault. It no longer uses bag space."or "Stack unlocked and returned to your bag."
end
return Bag
