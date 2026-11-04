-- One timed event queue; gameplay supplies harvest, wind, raid and broadcast effects.
local C=require(game:GetService("ReplicatedStorage").BuildATree.Config)
local function create()
local E={Current=nil,Ends=0,Next=os.time()+C.Events.Every,Index=0,Queue={},Health=0}
function E.GrowthFactor(now)
 if now>=E.Ends then return 1 end
 if E.Current=="Golden Rain"then return C.Events.RainGrowth end
 if E.Current=="Windstorm"then return C.Events.WindGrowth end
 return 1
end
function E.Tick(now,onStart,onEnd)
 if E.Current and now>=E.Ends then local old=E.Current; E.Current=nil; onEnd(old) end
 if not E.Current and (#E.Queue>0 or now>=E.Next) then
  E.Index=E.Index%#C.Events.Order+1
  E.Current=#E.Queue>0 and table.remove(E.Queue,1) or C.Events.Order[E.Index]
  E.Ends=now+C.Events.Duration[E.Current]; E.Next=now+C.Events.Every
  E.Starts=now;E.Participants={};E.Health=C.Events.RaidHealth; onStart(E.Current)
 end
end
return E
end
local service=create()
function service.CreateForTests()
 assert(game:GetService("RunService"):IsStudio(),"Event fixtures are Studio-only")
 return create()
end
return service
