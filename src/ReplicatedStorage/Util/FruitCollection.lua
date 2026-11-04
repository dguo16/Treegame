-- Collected harvest identities and cosmetic records; no rewards or paid modifiers.
local C=require(script.Parent.Parent.Config)
local Sizes=require(script.Parent.FruitSizes)
local F={}
local Aliases=require(script.Parent.NameAliases)
function F.Ensure(p)p.FruitIndex=p.FruitIndex or {Found={},Version=0};p.FruitIndex.Found=p.FruitIndex.Found or {};p.FruitIndex.Version=p.FruitIndex.Version or 0;return p.FruitIndex end
function F.Key(item)
 local names=C.PartVariants.Fruit[item.Tier or 1];local variant=names and table.find(names,Aliases.Name(item))
 local mutation=false;for _,m in C.Mutations do if m.Name==item.Mutation then mutation=true end end
 if not variant or not mutation then return nil end
 return (item.Tier or 1)..":"..variant..":"..item.Mutation
end
function F.Discover(p,item,now)
 local key=F.Key(item);if not key then return end
 local index=F.Ensure(p);local size,rank=Sizes.Get(item.Size);local entry=index.Found[key]
 if not entry then entry={Sizes={},Name=Aliases.Name(item),Tier=item.Tier,Mutation=item.Mutation};index.Found[key]=entry;index.Version+=1 end
 if not entry.Sizes[size.Name]then entry.Sizes[size.Name]=true;index.Version+=1 end
 local record=index.Biggest
 if not record or rank>select(2,Sizes.Get(record.Size))then index.Biggest={Name=Aliases.Name(item),Tier=item.Tier,Mutation=item.Mutation,Size=size.Name,Scale=size.Scale,At=now};index.Version+=1 end
end
function F.Scan(p)
 F.Ensure(p);for _,container in {p.Bag,p.Vault}do for _,item in container.Items do F.Discover(p,item,item.ObtainedAt)end end
end
function F.Count(p)local n=0;for _ in F.Ensure(p).Found do n+=1 end;return n end
return F
