-- Entry point: install remotes, validate traffic, start bounded schedulers and shut down safely.
local Players=game:GetService("Players")
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("BuildATree")
local C=require(Shared.Config)
local Validate=require(Shared.Util.IntentValidator)
local D=require(script.Parent.Services.DataService)
local W=require(script.Parent.Services.WorldService)
local Game=require(script.Parent.Services.GameService)
local Purchase=require(script.Parent.Services.PurchaseService)
local Leaderboards=require(script.Parent.Services.LeaderboardService)
local folder=Instance.new("Folder"); folder.Name="Network"; folder.Parent=Shared
local network={}
for _,name in {"Intent","State","Feedback"} do local r=Instance.new("RemoteEvent"); r.Name=name; r.Parent=folder; network[name]=r end
-- Preserve the editable reference for positioning without displaying it as a second garden.
local treeEditor=workspace:FindFirstChild("StarterTreeEditor")
if treeEditor then treeEditor.Parent=Shared end
W.Init(); Game.Init(network); Purchase.Init(Game)
Leaderboards.Init(W)
if game:GetService("RunService"):IsStudio() then
 local harness=Instance.new("BindableFunction"); harness.Name="StudioChecks"; harness.Parent=script.Parent
 harness.OnInvoke=function(player,mode)
  if mode=="Snapshot" then local p=D.Get(player); return p and require(Shared.Util.Profile).Copy(p) end
  return require(game:GetService("TestService").BuildATreeTests.Integration).Run(Game,D,W,player)
 end
end
network.Intent.OnServerEvent:Connect(function(player,action,args)
 local rt=Game.Runtime[player]
 if not rt or not D.Available(player) then return end
 local now=workspace:GetServerTimeNow()
 rt.Tokens=math.min(C.Runtime.RemoteBurst,rt.Tokens+(now-rt.LastToken)*C.Runtime.RemotePerSecond); rt.LastToken=now
 if rt.Tokens<1 then return end; rt.Tokens-=1
 if not Validate(action,args) then Game.Toast(player,"Invalid request rejected."); return end
 local ok,err=pcall(Game.Intent,player,action,args)
 if not ok then warn("BuildATree intent",action,err); Game.Toast(player,"That action could not complete. Please try again.") end
end)
W.Prompt.Triggered:Connect(function(player) if D.Available(player) then Game.Sell(player); Game.State(player) end end)
W.ShopPrompt.Triggered:Connect(function(player)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if D.Available(player) and root and (root.Position-W.ShopPrompt.Parent.Position).Magnitude<=C.Runtime.ShopRange then Game.Feedback(player,"Shop",{}) end
end)
local function joined(player) Game.Join(player); if D.Get(player) then Purchase.LoadPasses(player) end end
Players.PlayerAdded:Connect(joined)
Players.PlayerRemoving:Connect(function(player)local scores=Leaderboards.Snapshot(player);Game.Leave(player);Leaderboards.WriteScores(scores)end)
for _,player in Players:GetPlayers() do task.spawn(joined,player) end
local closing=false
task.spawn(function() while not closing do task.wait(C.Runtime.Tick); local ok,err=pcall(Game.Tick); if not ok then warn("Garden scheduler",err) end;Leaderboards.Tick() end end)
task.spawn(function() while not closing do task.wait(C.Runtime.PickupTick); local ok,err=pcall(Game.Pickup); if not ok then warn("Fruit scheduler",err) end end end)
task.spawn(function() while not closing do task.wait(C.Data.Autosave); for player in D.Sessions do task.spawn(D.Save,player) end end end)
game:BindToClose(function()
 closing=true; local pending=0
 Leaderboards.Close()
 for player in D.Sessions do local scores=Leaderboards.Snapshot(player);pending+=1;task.spawn(function()Game.Leave(player);Leaderboards.WriteScores(scores);pending-=1 end)end
 local deadline=workspace:GetServerTimeNow()+C.Data.CloseTimeout
 while pending>0 and workspace:GetServerTimeNow()<deadline do task.wait(.1) end
end)
