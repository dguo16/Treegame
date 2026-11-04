-- Pure server-owned discoveries, gentle return rewards and deterministic goals.
local C=require(script.Parent.Parent.Config)
local Catalog=require(script.Parent.PartCatalog)
local V=require(script.Parent.ValueCalculator)
local Collection=require(script.Parent.Collection)
local J={}
function J.Key(part)return part.Slot..":"..part.Tier..":"..Catalog.Variant(part)..":"..Catalog.Mutation(part).Name end
function J.Ensure(p)
 p.Journal=p.Journal or {Found={},Claims={},LoginDays=0,LastLoginDay=-1,Daily={Day=-1,Rolls=0,Sold=0,Plants=0,Claims={}},Totals={Rolls=p.Rolls or 0,Sold=0,Plants=0},Liked={},Keepsakes={},EventRewards={},Version=0}
 local j=p.Journal
 j.Reference=j.Reference or {Income=0,At=0};j.Paid=j.Paid or {};j.RewardLog=j.RewardLog or {}
 j.Daily.Paid=j.Daily.Paid or {}
 Collection.Ensure(p)
 return j
end
function J.Touch(p,now)
 local j=J.Ensure(p);local day=math.floor(now/86400)
 if j.Daily.Day~=day then j.Daily={Day=day,Rolls=0,Sold=0,Plants=0,Claims={},Paid={}};j.Liked={};j.Version+=1 end
 return j
end
function J.Login(p,now)
 local j=J.Touch(p,now);local day=math.floor(now/86400)
 if j.LastLoginDay<day then j.LoginDays+=1;j.LastLoginDay=day;j.Version+=1 end
end
function J.Discover(p,part)
 local j=J.Ensure(p);local key=J.Key(part)
 if not j.Found[key]then j.Found[key]=true;Collection.Discover(p,part);j.Version+=1;return true end
 return false
end
function J.Scan(p)
 J.Ensure(p)
 local function build(b)for _,slot in C.Slots do J.Discover(p,b[slot])end end
 for _,part in p.Parts do J.Discover(p,part)end;build(p.Equipped)
 for _,plot in p.Plots do build(plot.Build)end
 for _,key in C.Growth.Fields do if p[key]then build(p[key].Build)end end
 for _,q in p.GrowthQueue or {}do build(q.Build)end
end
function J.Count(p)local n=0;for _ in J.Ensure(p).Found do n+=1 end;return n end
function J.Add(p,key,amount,now)
 local j=J.Touch(p,now);j.Totals[key]=(j.Totals[key]or 0)+amount
 if j.Daily[key]~=nil then j.Daily[key]+=amount end;j.Version+=1
end
function J.Goals()
 local goals={}
 for _,metric in {"Rolls","Plants","Sold","TotalCoins"}do
  for step,v in C.Rewards.Milestones[metric]do
   table.insert(goals,{Key=metric..v[1],Metric=metric,Need=v[1],Coins=v[2],Seconds=C.Rewards.MilestoneSeconds[step],Title=metric..": "..v[1]})
  end
 end;return goals
end
function J.DailyGoals()return C.Rewards.Daily end
-- Reference excludes events, pets, paid perks, temporary boosts and offline grants.
-- It only reads server-owned producing trees and earned permanent progression.
function J.BaseIncome(p)
 local total=0
 for _,plot in p.Plots do
  total+=V.Build(plot.Build,1,1+p.Saplings*C.Math.RebirthPerSapling,1,Collection.Factors(p),nil,C.Upgrades.LeafPower.Values[p.Upgrades.LeafPower])/V.Interval(plot.Build)
 end
 return math.clamp(total,0,C.Rewards.MaxReferenceIncome)
end
function J.ObserveIncome(p,now)
 local j=J.Ensure(p);local ref=j.Reference;local current=J.BaseIncome(p)
 if now-ref.At>=C.Rewards.ReferenceSeconds or now<ref.At then ref.Income=0;ref.At=now end
 if current>=ref.Income then
  if current>ref.Income then j.Version+=1 end
  ref.Income=current;ref.At=now
 end
 return ref.Income
end
function J.LoginCoins(p)
 return C.Rewards.LoginBase+C.Rewards.LoginStep*math.min(J.Ensure(p).LoginDays,C.Rewards.LoginDays)
end
function J.Quote(p,key,reference)
 local j=J.Ensure(p);local minimum,seconds
 if key=="DailyLogin"then
  minimum=J.LoginCoins(p)
  local progress=math.clamp((j.LoginDays-1)/(C.Rewards.LoginDays-1),0,1)
  seconds=C.Rewards.LoginMinSeconds+(C.Rewards.LoginMaxSeconds-C.Rewards.LoginMinSeconds)*progress
 else
  for _,goal in J.Goals()do if goal.Key==key then minimum=goal.Coins;seconds=goal.Seconds;break end end
  if not minimum then for _,goal in J.DailyGoals()do if goal.Key==key then minimum=goal.Coins;seconds=C.Rewards.DailySeconds[key];break end end end
 end
 if not minimum then return nil end
 -- Index rewards deliberately retain their exact existing fixed amounts.
 if not seconds then return minimum end
 reference=math.clamp(reference or j.Reference.Income,0,C.Rewards.MaxReferenceIncome)
 return math.floor(math.min(C.Rewards.MaxRewardCoins,math.max(minimum,reference*math.min(seconds,C.Rewards.MaxRewardSeconds))))
end
function J.RewardState(p,now)
 local reference=J.ObserveIncome(p,now);local quotes={DailyLogin=J.Quote(p,"DailyLogin",reference)}
 for _,g in J.DailyGoals()do quotes[g.Key]=J.Quote(p,g.Key,reference)end
 for _,g in J.Goals()do quotes[g.Key]=J.Quote(p,g.Key,reference)end
 return {Reference=reference,Quotes=quotes}
end
function J.Progress(p,goal,daily)
 local j=J.Ensure(p)
 if goal.Metric=="Found"then return J.Count(p)end
 if goal.Metric=="TotalCoins"then return p.TotalCoins end
 return (daily and j.Daily or j.Totals)[goal.Metric]or 0
end
function J.Claim(p,key,now)
 J.Login(p,now);local j=p.Journal;local reward,claims
 if key=="DailyLogin"then reward=J.LoginCoins(p);claims=j.Daily.Claims
 else
  for _,goal in J.Goals()do if goal.Key==key then if J.Progress(p,goal,false)<goal.Need then return false,"Keep growing toward this goal."end;reward=goal.Coins;claims=j.Claims;break end end
  if not reward then for _,goal in J.DailyGoals()do if goal.Key==key then if J.Progress(p,goal,true)<goal.Need then return false,"This daily goal is still in progress."end;reward=goal.Coins;claims=j.Daily.Claims;break end end end
 end
 if not reward or claims[key]then return false,"Reward unavailable or already claimed."end
 -- No client-provided income, amount or timestamp enters this computation.
 local reference=J.ObserveIncome(p,now);reward=J.Quote(p,key,reference)
 local before=p.Coins;p.Coins=math.min(C.Runtime.MaxCoins,p.Coins+reward);local paid=p.Coins-before
 claims[key]=true
 local paidMap=claims==j.Claims and j.Paid or j.Daily.Paid
 paidMap[key]=paid
 table.insert(j.RewardLog,{Key=key,At=now,Reference=reference,Quoted=reward,Paid=paid})
 while #j.RewardLog>C.Rewards.AuditLimit do table.remove(j.RewardLog,1)end
 j.Version+=1
 return true,"Goal reward: +"..paid.." coins!"
end
function J.Like(p,target,sourceId,targetId,now)
 if type(sourceId)~="number"or type(targetId)~="number"or sourceId%1~=0 or targetId%1~=0 or sourceId<=0 or targetId<=0 or sourceId==targetId then return false,"Choose another online gardener."end
 local j=J.Touch(p,now);local key=tostring(targetId)
 if j.Liked[key]then return false,"You already liked this garden today."end
 j.Liked[key]=true;j.Version+=1;local tj=J.Ensure(target);tj.LikesReceived=(tj.LikesReceived or 0)+1;tj.Version+=1
 return true,"Garden liked!"
end
function J.Event(p,name,id)
 local j=J.Ensure(p);if j.EventRewards[name]==id then return false end
 j.EventRewards[name]=id;j.Keepsakes[name]=true;j.EventTokens=(j.EventTokens or 0)+1;j.Version+=1;return true
end
return J
