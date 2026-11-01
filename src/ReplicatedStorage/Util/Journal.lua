-- Pure server-owned discoveries, gentle return rewards and deterministic goals.
local C=require(script.Parent.Parent.Config)
local Catalog=require(script.Parent.PartCatalog)
local J={}
function J.Key(part)return part.Slot..":"..part.Tier..":"..Catalog.Variant(part)..":"..Catalog.Mutation(part).Name end
function J.Ensure(p)
 p.Journal=p.Journal or {Found={},Claims={},LoginDays=0,LastLoginDay=-1,Daily={Day=-1,Rolls=0,Sold=0,Plants=0,Claims={}},Totals={Rolls=p.Rolls or 0,Sold=0,Plants=0},Liked={},Keepsakes={},EventRewards={},Version=0}
 return p.Journal
end
function J.Touch(p,now)
 local j=J.Ensure(p);local day=math.floor(now/86400)
 if j.Daily.Day~=day then j.Daily={Day=day,Rolls=0,Sold=0,Plants=0,Claims={}};j.Liked={};j.Version+=1 end
 return j
end
function J.Login(p,now)
 local j=J.Touch(p,now);local day=math.floor(now/86400)
 if j.LastLoginDay<day then j.LoginDays+=1;j.LastLoginDay=day;j.Version+=1 end
end
function J.Discover(p,part)
 local j=J.Ensure(p);local key=J.Key(part)
 if not j.Found[key]then j.Found[key]=true;j.Version+=1;return true end
 return false
end
function J.Scan(p)
 J.Ensure(p)
 local function build(b)for _,slot in C.Slots do J.Discover(p,b[slot])end end
 for _,part in p.Parts do J.Discover(p,part)end;build(p.Equipped)
 for _,plot in p.Plots do build(plot.Build)end
 for _,key in {"Growth","Growth2"}do if p[key]then build(p[key].Build)end end
 for _,q in p.GrowthQueue or {}do build(q.Build)end
end
function J.Count(p)local n=0;for _ in J.Ensure(p).Found do n+=1 end;return n end
function J.Add(p,key,amount,now)
 local j=J.Touch(p,now);j.Totals[key]=(j.Totals[key]or 0)+amount
 if j.Daily[key]~=nil then j.Daily[key]+=amount end;j.Version+=1
end
function J.Goals()
 local goals={}
 for _,v in {{12,100},{42,1000},{84,10000},{168,100000},{336,500000},{420,1000000}}do
  table.insert(goals,{Key="Index"..v[1],Metric="Found",Need=v[1],Coins=v[2],Title="Discover "..v[1].." part/mutation combinations"})
 end
 for _,v in {{"Rolls",10,100},{"Rolls",50,1000},{"Rolls",300,10000},{"Plants",1,50},{"Plants",6,500},{"Plants",25,5000},{"Sold",25,100},{"Sold",100,1000},{"Sold",1000,10000},{"TotalCoins",10000,1000},{"TotalCoins",1000000,10000},{"TotalCoins",100000000,100000}}do
  table.insert(goals,{Key=v[1]..v[2],Metric=v[1],Need=v[2],Coins=v[3],Title=v[1]..": "..v[2]})
 end;return goals
end
function J.DailyGoals()
 return {{Key="DailyRolls",Metric="Rolls",Need=5,Coins=100,Title="Roll 5 parts"},{Key="DailySold",Metric="Sold",Need=25,Coins=150,Title="Sell 25 fruit"},{Key="DailyPlants",Metric="Plants",Need=1,Coins=200,Title="Plant 1 tree"}}
end
function J.Progress(p,goal,daily)
 local j=J.Ensure(p)
 if goal.Metric=="Found"then return J.Count(p)end
 if goal.Metric=="TotalCoins"then return p.TotalCoins end
 return (daily and j.Daily or j.Totals)[goal.Metric]or 0
end
function J.Claim(p,key,now)
 J.Login(p,now);local j=p.Journal;local reward,claims
 if key=="DailyLogin"then reward=100+25*math.min(j.LoginDays,7);claims=j.Daily.Claims
 else
  for _,goal in J.Goals()do if goal.Key==key then if J.Progress(p,goal,false)<goal.Need then return false,"Keep growing toward this goal."end;reward=goal.Coins;claims=j.Claims;break end end
  if not reward then for _,goal in J.DailyGoals()do if goal.Key==key then if J.Progress(p,goal,true)<goal.Need then return false,"This daily goal is still in progress."end;reward=goal.Coins;claims=j.Daily.Claims;break end end end
 end
 if not reward or claims[key]then return false,"Reward unavailable or already claimed."end
 claims[key]=true;p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+reward);j.Version+=1
 return true,"Goal reward: +"..reward.." coins!"
end
function J.Event(p,name,id)
 local j=J.Ensure(p);if j.EventRewards[name]==id then return false end
 j.EventRewards[name]=id;j.Keepsakes[name]=true;j.EventTokens=(j.EventTokens or 0)+1;j.Version+=1;return true
end
return J
