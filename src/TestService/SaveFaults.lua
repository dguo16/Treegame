-- Deterministic fake backend exercises the production persistence module's factory.
local S=game.ReplicatedStorage.BuildATree
local P=require(S.Util.Profile)
local Service=require(game.ServerScriptService.BuildATree.Services.DataService)
local Tests={}
function Tests.Run()
 local checks=0;local function check(v,msg)assert(v,msg);checks+=1 end
 local function fixture()
  local backend={Calls=0,Actions={}}
  function backend:UpdateAsync(_,transform)
   self.Calls+=1;local action=self.Actions[self.Calls]
   if action=="errorBefore"then error("Simulated network failure before callback")end
   if action=="lose"then self.Record.Lock.Token="another-session"end
   if action=="repeatLose"then transform(P.Copy(self.Record));self.Record.Lock.Token="another-session"end
   local result=transform(P.Copy(self.Record))
   if result then self.Record=P.Copy(result)end
   if action=="errorAfter"then error("Simulated ambiguous write failure after callback")end
   return P.Copy(result)
  end
  local d=Service.CreateForTests({Store=backend,Token="test-session",Now=function()return 100 end,Wait=function()end})
  local player={UserId=123,Kicks=0,Kick=function(self)self.Kicks+=1 end}
  local profile=d.Load(player);check(profile~=nil and d.Persistent(player),"Fake durable session loads without network access")
  backend.Calls=0;return d,backend,player,profile
 end
 local d,b,player,p=fixture();p.Coins=100;b.Actions={"errorBefore","ok"}
 check(d.Save(player) and b.Record.Data.Coins==100 and b.Calls==2,"Transient failure retries and saves owned session")
 d,b,player,p=fixture();p.Coins=200;b.Actions={"errorAfter","lose"}
 check(not d.Save(player),"Earlier failed callback cannot prove ownership for later retry")
 check(player.Kicks==1 and not d.Available(player)and not d.Sessions[player].Busy,"Lost save ownership closes gameplay access and clears busy flag")
 d,b,player,p=fixture();local original=p.Coins;b.Actions={"errorAfter","lose"}
 local ok=d.Transaction(player,function(draft)draft.Coins+=100;return true end)
 check(not ok and not d.Get(player) and p.Coins==original,"Failed receipt transaction exposes no speculative reward")
 check(not d.Sessions[player].Busy,"Failed transaction clears busy flag")
 d,b,player,p=fixture();b.Actions={"errorBefore","ok"}
 check(d.Transaction(player,function(draft)draft.Receipts.receipt=true;draft.Coins+=50;return true end),"Receipt transaction retries safely")
 check(d.Get(player).Coins==p.Coins+50 and b.Record.Data.Receipts.receipt,"Receipt and reward commit together")
 local calls=b.Calls
 check(d.Transaction(player,function(draft)if draft.Receipts.receipt then return false,"duplicate"end;return true end),"Duplicate receipt is acknowledged")
 check(b.Calls==calls,"Duplicate receipt does not perform another write")
 d,b,player,p=fixture()
 check(d.Save(player,true) and d.Get(player)==nil and b.Record.Lock==nil,"Release saves once and clears session lock")
 d,b,player,p=fixture();b.Actions={"repeatLose"}
 check(not d.Save(player) and not d.Available(player),"Every UpdateAsync callback must independently prove current ownership")
 d,b,player,p=fixture();b.Actions={"repeatLose"}
 check(not d.Transaction(player,function(draft)draft.Coins+=100;return true end)and p.Coins==35,"Callback reentry cannot expose a reward after lock loss")
 d,b,player,p=fixture()
 check(not d.Transaction(player,function(draft)draft.Coins=999;error("Simulated grant failure")end),"Grant exception fails closed")
 check(not d.Sessions[player].Busy and d.Get(player).Coins==35,"Grant exception preserves profile and releases transaction busy flag")
 print("Build a Tree save faults: "..checks.." checks passed");return checks
end
return Tests
