assert(game:GetService("RunService"):IsStudio())
local root=game.ServerScriptService.BuildATree;local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config);local P=require(S.Util.Profile);local G=require(root.Services.GrowthService)
local D=require(root.Services.DataService);local Game=require(root.Services.GameService);local W=require(root.Services.WorldService)
local player=game.Players:GetPlayers()[1];assert(not D.Persistent(player),"Visual fixture requires isolated memory-only session")
local session=D.Sessions[player];local saved=session.Profile
local p=P.New(os.time());p.Rebirths=3;p.Upgrades.Plots=3;p.Onboarding=9;p.Tutorial=6;p.Coins=123456;p.Settings.SFX=false;p.Settings.Music=false;session.Profile=p
local function build(prefix,tier)
 local b=P.Starter();for i,slot in C.Slots do b[slot]={Id=prefix..slot,Slot=slot,Tier=tier,Name=C.PartNames[slot][tier],Variant=1,Stat=1.5*(slot=="Roots"and .15 or 1),Mutation=i==4 and "Golden"or "None"};table.insert(p.Parts,P.Copy(b[slot]))end
 p.Equipped=P.Copy(b);assert(G.Plant(p,os.time()))
end
build("visual_plot_",3);G.Finish(p);assert(G.Swap(p,1,3,os.time(),false))
build("visual_ready_",4);G.Finish(p);build("visual_growing_",3)
p.Growth2.Duration=3600;p.Equipped=P.Copy(p.Growth2.Build)
local garden=W.Gardens[player];player.Character:PivotTo(CFrame.new(garden.Origin+Vector3.new(0,4,20)))
local rt=Game.Runtime[player];rt.SalvageAt=0;rt.SalvageRequestAt=0;Game.Tick();Game.State(player)
local f=Instance.new("BindableFunction");f.Name="Command";f.Parent=script
f.OnInvoke=function(command)
 if command=="Confirm"then rt.SalvageRequestAt=0;rt.SalvageAt=0;return Game.RequestSalvage(player,p.Plots[1].Id)
 elseif command=="Result"then local locked=0;for _,part in p.Parts do if part.InUse then locked+=1 end end;return {Parts=#p.Parts,Locked=locked,Plot1=p.Plots[1]~=nil}
 elseif command=="Restore"then session.Profile=saved;for i=1,9 do W.Invalidate(player,i)end;Game.State(player)end
end
script:SetAttribute("Ready",true)