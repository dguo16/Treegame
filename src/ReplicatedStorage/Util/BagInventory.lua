-- Authoritative fruit stacks retain identity, exact value and server acquisition timestamps.
local Bag={}
function Bag.Ensure(bag)
 bag.Items=bag.Items or {}
 if bag.Count>0 and #bag.Items==0 then
  table.insert(bag.Items,{Id="legacy",Name="Saved Harvest",Tier=1,Mutation="None",Value=bag.Value/bag.Count,Count=bag.Count})
 end
 return bag
end
function Bag.Add(bag,value,count,metadata,now,id)
 Bag.Ensure(bag)
 metadata=metadata or {Name="Harvest Fruit",Tier=1,Mutation="None"}
 -- A stack covers one acquisition minute; exact first/last timestamps remain visible.
 local minute=math.floor(now/60)
 local found
 for _,item in bag.Items do
  if item.Name==metadata.Name and item.Tier==metadata.Tier and item.Mutation==metadata.Mutation and item.Value==value and item.Minute==minute then found=item; break end
 end
 if found then found.Count+=count; found.LastObtainedAt=now else
  table.insert(bag.Items,{Id=id,Name=metadata.Name,Tier=metadata.Tier,Mutation=metadata.Mutation,Value=value,Count=count,ObtainedAt=now,LastObtainedAt=now,Minute=minute})
 end
 bag.Count+=count; bag.Value+=value*count
 return bag
end
return Bag
