-- Catalog replacements keep their original tier and variant identities.
local Aliases={}
local fruit={Blueberry="Crystalberry",Blackberry="Hazelfruit"}
function Aliases.Name(item)
 if item.Tier==3 and(item.Slot==nil or item.Slot=="Fruit")then return fruit[item.Name]or item.Name end
 return item.Name
end
function Aliases.Migrate(profile)
 local visited={};local changed=0
 local function walk(record)
  if type(record)~="table"or visited[record]then return end;visited[record]=true
  if type(record.Name)=="string"then local name=Aliases.Name(record);if name~=record.Name then record.Name=name;changed+=1 end end
  for _,value in record do if type(value)=="table"then walk(value)end end
 end
 walk(profile)
 if changed>0 then
  if profile.Journal then profile.Journal.Version=(profile.Journal.Version or 0)+1 end
  if profile.FruitIndex then profile.FruitIndex.Version=(profile.FruitIndex.Version or 0)+1 end
 end
 return changed
end
return Aliases
