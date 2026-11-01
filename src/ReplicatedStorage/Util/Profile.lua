-- JSON-safe profile defaults, deep copy, migration hook and receipt transaction helper.
local C=require(script.Parent.Parent.Config)
local BagInventory=require(script.Parent.BagInventory)
local Catalog=require(script.Parent.PartCatalog)
local Journal=require(script.Parent.Journal)
local P={}
function P.Copy(t) if type(t)~="table" then return t end local out={}; for k,v in t do out[k]=P.Copy(v) end return out end
function P.Starter()
 local b={}; for _,slot in C.Slots do b[slot]={Id="starter_"..slot,Slot=slot,Tier=1,Stat=slot=="Roots" and C.Math.RootBase or 1,Name=C.PartNames[slot][1],Variant=1,Mutation="None"} end return b
end
function P.New(now)
 local starter=P.Starter()
 local profile={Schema=C.Schema,Coins=C.Roll.FirstCoins,TotalCoins=0,Rolls=0,EpicPity=0,LegendaryPity=0,Parts={},Equipped=starter,Plots={},Growth=nil,GrowthQueue={},Onboarding=1,EarlyRareClaimed=false,Upgrades={LeafPower=1,Bag=1,Radius=1,Discount=1,Plots=1,PetSlots=1,Batch=1},Bag={Count=0,Value=0,Items={}},Pets={},EquippedPets={},Defenses={},Settings={Chill=true,Music=true,SFX=true,ReducedShake=false,ReducedEffects=false,SkipRolls=false,AutoSell=false,MusicVolume=.4,SFXVolume=.4,SpendingLimit=0},Saplings=0,Rebirths=0,Tutorial=1,Joined=now,LastSeen=now,Playtime=0,Receipts={},Boosts={},Passes={},WaterAt=0,AutoRoll=false,PendingGrow=nil,ProductSpent=0,PurchaseLog={},NextId=0}
 Journal.Ensure(profile);return profile
end
function P.Migrate(data,now)
 -- Future migrations go here, before merging newly introduced defaults.
 local previousSchema=data.Schema or 1
 if not data.Journal then Journal.Ensure(data)end
 local defaults=P.New(now)
 local function merge(t,d) for k,v in d do if t[k]==nil then t[k]=P.Copy(v) elseif type(v)=="table" and type(t[k])=="table" then merge(t[k],v) end end end
 merge(data,defaults)
 local function normalizePart(item)
  item.Variant=Catalog.Variant(item);item.Mutation=Catalog.Mutation(item).Name
 end
 local function normalizeBuild(build) for _,slot in C.Slots do normalizePart(build[slot]) end end
 for _,item in data.Parts do normalizePart(item) end
 normalizeBuild(data.Equipped)
 for _,plot in data.Plots do normalizeBuild(plot.Build);plot.HeightScale=plot.HeightScale or 1 end
 for _,key in {"Growth","Growth2"}do if data[key]then normalizeBuild(data[key].Build);data[key].HeightScale=data[key].HeightScale or 1 end end
 for _,queued in data.GrowthQueue do normalizeBuild(queued.Build)end
 if data.EarlyRareClaimed==nil or data.Rolls>=3 then data.EarlyRareClaimed=data.Rolls>=3 end
 if previousSchema<5 and data.Tutorial>=6 then data.Onboarding=9 end
 Journal.Scan(data)
 BagInventory.Ensure(data.Bag); data.Upgrades.LeafPower=data.Upgrades.LeafPower or 1; data.Schema=C.Schema; return data
end
function P.GrantOnce(profile,id,grant)
 if profile.Receipts[id] then return false end
 grant(profile); profile.Receipts[id]=true; return true
end
return P
