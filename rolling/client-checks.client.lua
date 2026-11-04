local UI=require(game.Players.LocalPlayer.PlayerScripts.BuildATree.Controllers.UIController)
local D=require(game.ReplicatedStorage.BuildATree.Util.RollDisplay)
local P=require(game.ReplicatedStorage.BuildATree.Util.Profile)
local r=UI.RollDisplay;local count=0
local function check(v,m)assert(v,m);count+=1 end
local function idle()local start=os.clock();while r.Busy do assert(os.clock()-start<10,"Reel did not drain");task.wait(.05)end end
idle();UI.Inventory:Close();UI.SellPanel:Close();UI.Tab=nil;game.Players.LocalPlayer.PlayerGui.BuildATreeHUD.Menu.Visible=false
r.History={};r.Hidden=true;r.Summary.Visible=false
local function batch(n,offset)local rows={};for i=1,n do local part={Id="ui_"..(offset+i),Slot=i%2==0 and "Fruit"or "Trunk",Tier=1,Name=i%2==0 and "Apple"or "Oak",Mutation="None",Stat=1.1};table.insert(rows,D.Result(part,D.Context(P.New(0),1,1)))end;return rows end
r:Push(batch(5,0));r:Push(batch(10,5));idle()
check(#r.History==15,"Hidden reel retains every award from queued batches")
check(not r.Root.Visible,"Hidden reel never reveals an overlay")
check(not UI.Inventory.Root.Visible,"Finishing rolls does not force inventory open")
r:ShowSummary();task.wait(.1)
local awards=0;for _,v in r.List:GetChildren()do if v.Name:find("Award_",1,true)then awards+=1;check(v:FindFirstChildWhichIsA("ViewportFrame")~=nil,"Each award has a model preview");check(v.Details.Text:find("Name + mutation",1,true)~=nil,"Each award shows its own odds")end end
check(awards==10,"A ten-part batch displays all ten awards on one page")
r.Page=2;r:ShowSummary(true);local older=0;for _,v in r.List:GetChildren()do if v.Name:find("Award_",1,true)then older+=1 end end
check(older==5,"Earlier five-part batch remains accessible")
r.Summary.Visible=false;r.Hidden=false
r.State=P.Copy(UI.State);r.State.Settings.SkipRolls=true;r:Push(batch(1,15));idle()
check(#r.History==16,"Skip-animation retains the award")
r.State=P.Copy(UI.State);r.State.Settings.ReducedEffects=true;r:Push(batch(1,16));idle()
check(#r.History==17,"Reduced-effects retains the award")
check(#r.Belt:GetChildren()==3,"Reel has only three model rows")
r.State=UI.State;r.Hidden=false;r.Toggle.Text="HIDE REEL";r:ShowSummary()
script:SetAttribute("Checks",count);script:SetAttribute("Pass",true)
