-- Session-owned UpdateAsync persistence; receipts mutate a copy and commit before exposure.
local DS=game:GetService("DataStoreService")
local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("BuildATree")
local C=require(Shared.Config)
local Profile=require(Shared.Util.Profile)
local function create(deps)
 deps=deps or {}
 local clock=deps.Now or os.time
 local waitStep=deps.Wait or task.wait
local D={Sessions={}}
local storeOK,store=pcall(function() return deps.Store or DS:GetDataStore(C.Data.Store) end)
if not storeOK then store=nil end
if not deps.Store and Run:IsStudio()and script:GetAttribute("TestMemoryOnly")==true then store=nil end
local token=deps.Token or(game.JobId..Http:GenerateGUID(false))
local function retry(fn)
 local last
 for attempt=1,C.Data.Retries do
  local ok,result=pcall(fn); if ok then return true,result end
  last=result; waitStep(C.Data.Backoff*2^(attempt-1))
 end
 return false,last
end
function D.Load(player)
 local now=clock(); local locked=false
 local ok,record=false,nil
 if store then ok,record=retry(function()
  if not store then error("Publish a test place to enable DataStore") end
  return store:UpdateAsync(tostring(player.UserId),function(old)
   old=old or {Data=Profile.New(now)}
   if old.Lock and old.Lock.Token~=token and old.Lock.Expires>clock() then locked=true; return nil end
   old.Lock={Token=token,Expires=clock()+C.Data.LockSeconds}; return old
  end)
 end) end
 if locked then return nil,"Profile is open on another server. Please rejoin shortly." end
 local ephemeral=false
 if not ok or not record then
  if not Run:IsStudio() then return nil,"Your save could not be loaded. Please rejoin." end
  ephemeral=true; record={Data=Profile.New(now)}
  warn("Build a Tree: Studio memory-only preview. Enable API access on a TEST place to test saves; purchases disabled.")
 end
 local s={Profile=Profile.Migrate(record.Data,now),Ephemeral=ephemeral,Busy=false,Closed=false}
 D.Sessions[player]=s; return s.Profile
end
function D.Save(player,release)
 local s=D.Sessions[player]; if not s then return false end
 while s.Busy do waitStep() end
 if s.Closed then if release then D.Sessions[player]=nil end;return false end
 s.Busy=true
 -- Schema 6 includes server reward reference, paid claims and bounded audit history.
 local data=Profile.Copy(s.Profile)
 local ok=true
 if not s.Ephemeral then
  local owns=false
  ok=retry(function() owns=false;return store:UpdateAsync(tostring(player.UserId),function(old)
   owns=false
   if not old or not old.Lock or old.Lock.Token~=token then return nil end
   owns=true
   return {Data=data,Lock=not release and {Token=token,Expires=clock()+C.Data.LockSeconds} or nil}
  end) end)
  ok=ok and owns
 end
 s.Busy=false
 if release then s.Closed=true; D.Sessions[player]=nil end
 if not ok and not release then s.Closed=true;player:Kick("Save session lost; please rejoin to protect your progress.") end
 return ok
end
local function transaction(player,mutate,treeEdit)
 local s=D.Sessions[player]
 if not s or (s.Ephemeral and not treeEdit)or s.Closed then return false end
 while s.Busy do waitStep() end
 if s.Closed then return false end
 s.Busy=true
 local draft=Profile.Copy(s.Profile)
 local mutationOK,changed,reason=pcall(mutate,draft)
 if not mutationOK then s.Busy=false;return false,"Reward could not be applied."end
 if not changed then s.Busy=false; return reason=="duplicate",reason end
 if s.Ephemeral then table.clear(s.Profile);for k,v in draft do s.Profile[k]=v end;s.Busy=false;return true,reason end
 local owns=false
 local ok=retry(function() owns=false;return store:UpdateAsync(tostring(player.UserId),function(old)
  owns=false
  if not old or not old.Lock or old.Lock.Token~=token then return nil end
  owns=true; return {Data=draft,Lock={Token=token,Expires=clock()+C.Data.LockSeconds}}
 end) end)
 if ok and owns then if treeEdit then table.clear(s.Profile);for k,v in draft do s.Profile[k]=v end else s.Profile=draft end else
  if treeEdit or (ok and not owns)then s.Closed=true;player:Kick("Save session lost; please rejoin to protect your progress.")end
  ok=false
 end
 s.Busy=false; return ok,reason
end
function D.Transaction(player,mutate)return transaction(player,mutate,false)end
function D.Atomic(player,mutate)return transaction(player,mutate,true)end
function D.Get(player) local s=D.Sessions[player]; return s and not s.Closed and s.Profile end
function D.Available(player) local s=D.Sessions[player]; return s and not s.Busy and not s.Closed end
function D.Persistent(player) local s=D.Sessions[player]; return s and not s.Ephemeral end
return D

end
local service=create()
function service.CreateForTests(deps)
 assert(Run:IsStudio(),"Test backend injection is Studio-only")
 return create(deps)
end
return service
