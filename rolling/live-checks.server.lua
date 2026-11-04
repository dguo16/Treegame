local G=require(game.ServerScriptService.BuildATree.Services.GameService)
local D=require(game.ServerScriptService.BuildATree.Services.DataService)
local P=require(game.ReplicatedStorage.BuildATree.Util.Profile)
local player=game.Players:GetPlayers()[1];assert(not D.Persistent(player))
local session=D.Sessions[player];local previous=session.Profile;local rt=P.Copy(G.Runtime[player]);local rng=G.Rng;local feedback=G.Feedback;local events={};local n=0
local function check(v,m)assert(v,m);n+=1 end
local ok,err=pcall(function()
 local p=P.New(os.time());p.Coins=10000;p.Upgrades.Batch=3;p.Rolls=0;session.Profile=p;G.Runtime[player].RollAt=0;G.Rng=Random.new(73)
 G.Feedback=function(actor,kind,data)if actor==player and kind=="Roll"then events=data else feedback(actor,kind,data)end end
 check(G.Roll(player,false,false),"Server accepts legal ten-part batch")
 check(#events==10 and #p.Parts==10,"Feedback includes every granted part")
 for i,item in events do check(item.Id==p.Parts[i].Id and item.RollOdds~=nil,"Feedback item corresponds to saved reward");check(p.Parts[i].RollOdds==nil,"Display metadata not saved into owned inventory")end
 check(events[3].RollOdds.Minimum>=3,"Actual third-roll feedback reflects guarantee before pity advances")
 check(p.Rolls==10,"Display does not reroll or grant extras")
 check(not G.Roll(player,false,false),"Original server cooldown remains enforced")
end)
session.Profile=previous;G.Runtime[player]=rt;G.Rng=rng;G.Feedback=feedback;G.State(player)
assert(ok,err);script:SetAttribute("Checks",n);script:SetAttribute("Pass",true)
