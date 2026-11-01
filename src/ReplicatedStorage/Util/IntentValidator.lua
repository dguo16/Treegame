-- Exact payload schemas reject forged state, NaN, unbounded strings and extra keys.
local schemas={AdminCoins={Mode="string",Amount="string"},AdminPart={Slot="string",Tier="number",Equip="boolean"},AdminCatalogPart={Slot="string",Tier="number",Choice="string"},AdminAllParts={},AdminLuck={Multiplier="string"},AdminResetLuck={},Teleport={Destination="string"},Roll={},Sell={},Equip={Id="string"},SellPart={Id="string"},Plant={},DailyRoll={},ClaimJournal={Key="string"},VisitGarden={Target="number"},LikeGarden={Target="number"},QueueTree={},CancelQueuedTree={QueueId="string"},PlaceTree={Plot="number",GrowthId="string"},ReplaceTree={Plot="number",GrowthId="string",Token="string"},CancelPlacement={},Water={},Buy={Kind="string"},Egg={Tier="number"},EquipPet={Id="string"},Fuse={Id="string"},Sabotage={Target="number",Kind="string"},Setting={Key="string",Value="any"},Rebirth={Confirm="boolean"},GrowNow={},Product={Key="string"},Pass={Key="string"},AutoRoll={},Tutorial={Skip="boolean"},Raid={},RedeemGrow={}}
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
 return count<=3
end
