-- Physical part custody. Inventory rows stay present and count while their tree owns them.
local C=require(script.Parent.Parent.Config)
local O={}
local function copy(v)if type(v)~="table"then return v end;local t={};for k,x in v do t[k]=copy(x)end;return t end
function O.Starter(part)
 return part and part.Id=="starter_"..tostring(part.Slot)and part.Tier==1 and part.Name==C.PartNames[part.Slot][1]and part.Stat==(part.Slot=="Roots"and C.Math.RootBase or 1)and(part.Mutation or "None")=="None"and(part.Variant or 1)==1
end
function O.Same(a,b)
 if not a or not b then return false end
 for _,k in {"Slot","Tier","Stat","Name"}do if a[k]~=b[k]then return false end end
 return(a.Mutation or "None")== (b.Mutation or "None")and(a.Variant or 1)==(b.Variant or 1)
end
function O.Part(p,id)
 local found;for _,part in p.Parts do if part.Id==id then if found then return nil end;found=part end end;return found
end
function O.Trees(p)
 local rows={};for i=1,C.Growth.TotalPlots do if p.Plots[i]then table.insert(rows,{Tree=p.Plots[i],Kind="Plot",Index=i,Label="Plot "..i})end end
 for i,key in C.Growth.Fields do if p[key]then table.insert(rows,{Tree=p[key],Kind="Growth",Index=i,Label="Growth Pad "..i})end end
 for i,q in p.GrowthQueue or {}do table.insert(rows,{Tree=q,Kind="Queue",Index=i,Label="Queue "..i})end
 return rows
end
function O.Find(p,id)for _,row in O.Trees(p)do if row.Tree.Id==id then return row.Tree,row end end end
function O.Label(p,part)
 if not part then return nil end;local owned=O.Part(p,part.Id);local id=owned and owned.InUse
 if id then local _,row=O.Find(p,id);return "In use: "..(row and row.Label or "Tree")end
end
-- Missing legacy copies occupy reserved capacity until salvage materializes them.
-- Ambiguous copies are snapshots only: their already-held identities are never duplicated.
function O.Count(p)
 local n=#p.Parts;for _,row in O.Trees(p)do for _,legacy in row.Tree.LegacyParts or {}do if legacy.Recover then n+=1 end end end;return n
end
function O.Available(p,part)
 if O.Starter(part)then return true end
 local owned=O.Part(p,part.Id)
 if not owned or not O.Same(owned,part)then return false,"Choose an owned part for each slot."end
 if owned.InUse then return false,O.Label(p,owned)..". Salvage that tree or choose another part."end
 return true
end
function O.Equip(p,id)
 for _,slot in C.Slots do if id=="starter_"..slot then p.Equipped[slot]={Id=id,Slot=slot,Tier=1,Stat=slot=="Roots"and C.Math.RootBase or 1,Name=C.PartNames[slot][1],Variant=1,Mutation="None"};return true end end
 local part=O.Part(p,id);if not part then return false,"Choose an owned part."end
 local ok,msg=O.Available(p,part);if not ok then return false,msg end
 p.Equipped[part.Slot]=copy(part);return true,"Part equipped."
end
function O.Sell(p,id)
 local part=O.Part(p,id);if not part then return false,"That part is not in your inventory."end
 if part.InUse then return false,O.Label(p,part)..". Salvage the tree before selling."end
 if p.Equipped[part.Slot].Id==id then return false,"Equip another "..part.Slot.." before selling this one."end
 for i,item in p.Parts do if item==part then table.remove(p.Parts,i);break end end
 p.Coins+=math.floor(C.Roll.BaseCost*C.Roll.PartSellFraction*part.Stat);p.PartVersion=(p.PartVersion or 0)+1;return true,"Part sold."
end
function O.Bind(p,tree)
 local ids={};local seen={}
 for _,slot in C.Slots do local part=tree.Build[slot];if not part or part.Slot~=slot then return false,"Build needs all four slots."end
  local ok,msg=O.Available(p,part);if not ok then return false,msg end
  if not O.Starter(part)then if seen[part.Id]then return false,"A part cannot fill two slots."end;seen[part.Id]=true;ids[slot]=part.Id end
 end
 tree.PartIds=ids
 for _,id in ids do O.Part(p,id).InUse=tree.Id end
 return true
end
function O.Verify(p,tree)
 for slot,id in tree.PartIds or {}do local part=O.Part(p,id)
  if not part or part.InUse~=tree.Id or not O.Same(part,tree.Build[slot])then return false,"Tree ownership changed. Rejoin before changing this tree."end
 end;return true
end
function O.Returns(p,tree)
 local items={};local known={};for _,part in p.Parts do known[part.Id]=true end
 if tree.LegacyParts then
  for _,legacy in tree.LegacyParts do if legacy.Recover and not known[legacy.Part.Id]then local part=copy(legacy.Part);part.InUse=nil;known[part.Id]=true;table.insert(items,part)end end
 elseif not tree.PartIds then -- old, un-migrated server fixture compatibility
  for _,slot in C.Slots do local part=tree.Build[slot];if not O.Starter(part)and not known[part.Id]then local item=copy(part);item.InUse=nil;known[part.Id]=true;table.insert(items,item)end end
 end
 return items
end
function O.CanRelease(p,tree)
 local ok,msg=O.Verify(p,tree);if not ok then return false,msg end
 local items=O.Returns(p,tree)
 -- Existing rows + this recovery cannot exceed total pre-existing custody.
 if #p.Parts+#items>math.max(C.Runtime.MaxInventory,O.Count(p))then return false,"Make room for legacy recovered parts first. Your trees are unchanged."end
 return true,items
end
function O.Release(p,tree,items)
 for _,id in tree.PartIds or {}do local part=O.Part(p,id);if part and part.InUse==tree.Id then part.InUse=nil end end
 for _,part in items do table.insert(p.Parts,part)end
end
function O.Next(p,prefix,used)
 repeat p.NextId=(p.NextId or 0)+1 until not used[prefix..p.NextId];local id=prefix..p.NextId;used[id]=true;return id
end
function O.Migrate(p)
 if p.OwnershipVersion==1 then return p.OwnershipMigration end
 local report={Matched=0,Ambiguous=0,Missing=0,Starter=0,Trees=0,Reserved=0,RepairedIds=0}
 local used,duplicates={},{}
 for _,part in p.Parts do if part.Id then if used[part.Id]then duplicates[part.Id]=true end;used[part.Id]=true;local n=tonumber(part.Id);if n then p.NextId=math.max(p.NextId or 0,n)end end end
 for _,part in p.Parts do
  part.InUse=nil
  if type(part.Id)~="string"or duplicates[part.Id]or part.Id:match("^starter_")then part.Id=O.Next(p,"part_",used);report.RepairedIds+=1 end
 end
 for _,row in O.Trees(p)do if type(row.Tree.Id)=="string"then used[row.Tree.Id]=true end end
 local treeIds={};local reserved={}
 for _,row in O.Trees(p)do local tree=row.Tree;report.Trees+=1
  if type(tree.Id)~="string"or treeIds[tree.Id]then tree.Id=O.Next(p,"tree_",used)end;treeIds[tree.Id]=true
  tree.PartIds={};tree.LegacyParts={}
  for _,slot in C.Slots do local snapshot=tree.Build[slot]
   if O.Starter(snapshot)then report.Starter+=1 else
    local candidates={};local identityExists=false
    for _,part in p.Parts do
     if part.Id==snapshot.Id then identityExists=true end
     if O.Same(part,snapshot)and(not snapshot.Id or part.Id==snapshot.Id or duplicates[snapshot.Id])then table.insert(candidates,part)end
    end
    local match=#candidates==1 and not candidates[1].InUse and not duplicates[snapshot.Id]and candidates[1]or nil
    if match then tree.PartIds[slot]=match.Id;match.InUse=tree.Id;tree.Build[slot]=copy(match);tree.Build[slot].InUse=nil;report.Matched+=1
    else
     local ambiguous=#candidates>0 or identityExists or duplicates[snapshot.Id]
     local part=copy(snapshot);part.InUse=nil
     local recover=not ambiguous and not reserved[snapshot.Id]
     if recover then
      local original=part.Id;if type(original)~="string"or used[original]then part.Id=O.Next(p,"part_",used)else used[original]=true end
      if original then reserved[original]=true;local n=tonumber(original);if n then p.NextId=math.max(p.NextId or 0,n)end end;report.Reserved+=1
     end
     tree.LegacyParts[slot]={Part=part,Recover=recover,Reason=ambiguous and "Ambiguous"or "Missing"}
     if ambiguous then report.Ambiguous+=1 else report.Missing+=1 end
    end
   end
  end
 end
 p.OwnershipVersion=1;p.OwnershipMigration=report;p.PartVersion=(p.PartVersion or 0)+1
 return report
end
return O
