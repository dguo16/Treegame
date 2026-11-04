-- Exact payload schemas reject forged state, NaN, unbounded strings and extra keys.
local C=require(script.Parent.Parent.Config)
local schemas={RequestSalvage={TreeId="string"},SalvageTree={TreeId="string",Token="string"},LockFruit={StackId="string",Revision="number"},UnlockFruit={StackId="string",Revision="number"},ClaimCollection={Key="string"},BuyMedalCosmetic={Key="string"},EquipCosmetic={Slot="string",Key="string"},ClaimLikes={Key="string"},AdminCoins={Mode="string",Amount="string"},AdminPart={Slot="string",Tier="number",Equip="boolean"},AdminCatalogPart={Slot="string",Tier="number",Choice="string"},AdminAllParts={},AdminLuck={Multiplier="string"},AdminResetLuck={},Teleport={Destination="string"},Roll={},Sell={Revision="number",Stacks="table"},Equip={Id="string"},SellPart={Id="string"},Plant={},DailyRoll={},ClaimJournal={Key="string"},VisitGarden={Target="number"},LikeGarden={Target="number"},QueueTree={},CancelQueuedTree={QueueId="string"},PlaceTree={Plot="number",GrowthId="string"},ReplaceTree={Plot="number",GrowthId="string",Token="string"},CancelPlacement={},Water={},Buy={Kind="string"},Egg={Tier="number"},EquipPet={Id="string"},Fuse={Id="string"},Sabotage={Target="number",Kind="string"},Setting={Key="string",Value="any"},Rebirth={Confirm="boolean"},GrowNow={},Product={Key="string"},Pass={Key="string"},AutoRoll={},Tutorial={Skip="boolean"},Raid={},RedeemGrow={}}
return function(action,payload)
 if type(action)~="string" or type(payload)~="table" or not schemas[action] then return false end
 local schema=schemas[action]; local count=0
 for key,value in payload do
  count+=1; local kind=schema[key]
  if not kind or (kind~="any" and type(value)~=kind) then return false end
  if type(value)=="number" and (value~=value or math.abs(value)>1e12) then return false end
  if type(value)=="string" and #value>80 then return false end
  if kind=="any" and type(value)~="boolean" and type(value)~="number" then return false end
 end
 for key in schema do if payload[key]==nil then return false end end
 if action=="Sell"then
  if payload.Revision%1~=0 or payload.Revision<0 then return false end
  local rows=payload.Stacks;if #rows<1 or #rows>C.FruitInventory.MaxSaleStacks then return false end
  local seen,n={},0
  for k,row in rows do
   n+=1;if type(k)~="number"or k%1~=0 or k<1 or k>#rows or type(row)~="table"then return false end
   local fields=0;for name in row do if name~="Id"and name~="Quantity"then return false end;fields+=1 end
   if fields~=2 or type(row.Id)~="string"or #row.Id<1 or #row.Id>80 or seen[row.Id]or type(row.Quantity)~="number"or row.Quantity~=row.Quantity or row.Quantity%1~=0 or row.Quantity<1 or row.Quantity>1e12 then return false end
   seen[row.Id]=true
  end
  if n~=#rows then return false end
 elseif action=="LockFruit"or action=="UnlockFruit"then
  if payload.Revision%1~=0 or payload.Revision<0 or #payload.StackId==0 then return false end
 end
 return count<=3
end
