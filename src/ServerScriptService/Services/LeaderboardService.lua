-- Physical server/global rankings with cached platform avatars and persistent ordered scores.
local Players=game:GetService("Players")
local DS=game:GetService("DataStoreService")
local S=game:GetService("ReplicatedStorage").BuildATree
local C=require(S.Config)
local T=require(S.Theme)
local Format=require(S.Util.FormatNumber)
local Scores=require(S.Util.LeaderboardScores)
local D=require(script.Parent.DataService)
local B={Boards={},Avatars={},AvatarOrder={},Names={},Queued={},Queue={},Closed=false,NextGlobal=0,NextServer=0}
local function text(parent,value,size,pos,color)
 local t=Instance.new("TextLabel");t.Size=size;t.Position=pos;t.Text=value;t.TextScaled=true;t.Font=Enum.Font.FredokaOne;t.TextColor3=color or T.Cream;t.BackgroundTransparency=1;t.Parent=parent;return t
end
local function face(part)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Back;gui.CanvasSize=Vector2.new(650,760);gui.ZOffset=2;gui.Parent=part;return gui
end
function B.Init(world)
 B.World=world;local ok,stores=pcall(function()return {Coins=DS:GetOrderedDataStore(C.Leaderboards.CoinsStore),Height=DS:GetOrderedDataStore(C.Leaderboards.HeightStore)}end)
 B.Stores=ok and stores or nil
 local specs={{"GlobalCoins","GLOBAL COINS","Coins on hand • all players",-104,-73,"Coins",true},{"GlobalHeight","GLOBAL HEIGHT","Tallest tree ever grown",-52,-136,"Height",true},{"ServerCoins","SERVER COINS","Coins on hand",52,-136,"Coins",false},{"ServerHeight","SERVER HEIGHT","Currently producing trees",104,-73,"Height",false}}
 for _,spec in specs do
  local model=Instance.new("Model");model.Name=spec[1];model.Parent=world.Root
  local x,z=spec[4],spec[5]
  world.Part(model,"Platform",Vector3.new(42,.5,22),Vector3.new(x,.9,z+7),T.Path)
  local board=world.Part(model,"RankingBoard",Vector3.new(22,17,1),Vector3.new(x-9,10,z),T.DarkWood)
  local gui=face(board);text(gui,spec[2],UDim2.fromScale(.94,.09),UDim2.fromScale(.03,.02),T.Gold)
  text(gui,spec[3],UDim2.fromScale(.94,.05),UDim2.fromScale(.03,.12),T.Cream)
  local rows={};for i=1,C.Leaderboards.Rows do rows[i]=text(gui,i..". —",UDim2.fromScale(.92,.062),UDim2.fromScale(.04,.19+(i-1)*.067))end
  local status=text(gui,"Loading rankings…",UDim2.fromScale(.92,.05),UDim2.fromScale(.04,.9),T.Gold)
  local podiums={}
  for rank=1,3 do
   local px=x+7+(rank-1)*5;local h=rank==1 and 3 or rank==2 and 2 or 1
   local base=world.Part(model,"Podium"..rank,Vector3.new(4,h,5),Vector3.new(px,.9+h/2,z+8),({T.Gold,T.Blue,T.Pink})[rank])
   local tag=world.Billboard(base,"#"..rank,T.Cream);tag.StudsOffset=Vector3.new(0,-.3,3);tag.MaxDistance=80
   podiums[rank]={Base=base,Model=nil,UserId=nil,Label=tag.Label}
  end
  B.Boards[spec[1]]={Model=model,Rows=rows,Status=status,Podiums=podiums,Kind=spec[6],Global=spec[7]}
 end
 if game:GetService("RunService"):IsRunning()then task.spawn(function()while not B.Closed do
  local job=table.remove(B.Queue,1)
  if job then B.LoadAvatar(job.Board,job.Rank,job.UserId);B.Queued[job.Key]=nil else task.wait(.3)end
 end end)end
end
function B.Username(id)
 if B.Names[id]then return B.Names[id]end
 local online=Players:GetPlayerByUserId(id);if online then B.Names[id]=online.DisplayName;return online.DisplayName end
 local ok,name=pcall(Players.GetNameFromUserIdAsync,Players,id);B.Names[id]=ok and name or "User "..id;return B.Names[id]
end
function B.LoadAvatar(board,rank,id)
 local podium=board.Podiums[rank];if podium.UserId~=id or not board.Model.Parent then return end
 local cached=B.Avatars[id];local model
 if cached then model=cached:Clone()else
  local ok,result=pcall(Players.CreateHumanoidModelFromUserIdAsync,Players,id)
  if ok then model=result else
   local player=Players:GetPlayerByUserId(id);local character=player and player.Character
   if character then local old=character.Archivable;character.Archivable=true;model=character:Clone();character.Archivable=old end
  end
  if model then
   for _,accessory in model:GetChildren()do if accessory:IsA("Accessory")then local handle=accessory:FindFirstChild("Handle");local weld=handle and handle:FindFirstChildOfClass("Weld")
    if weld and weld.Part0==handle and weld.Part1 then handle.CFrame=weld.Part1.CFrame*weld.C1*weld.C0:Inverse()
    elseif weld and weld.Part1==handle and weld.Part0 then handle.CFrame=weld.Part0.CFrame*weld.C0*weld.C1:Inverse()end
   end end
   for _,item in model:GetDescendants()do if item:IsA("LuaSourceContainer")or item:IsA("Tool")then item:Destroy()elseif item:IsA("BasePart")then item.Anchored=true;item.CanCollide=false;item.CanTouch=false;item.CanQuery=false end end
   local humanoid=model:FindFirstChildOfClass("Humanoid");if humanoid then humanoid.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None end
   model.Name="RankAvatar";model.Archivable=true;B.Avatars[id]=model:Clone();table.insert(B.AvatarOrder,id)
   if #B.AvatarOrder>24 then local old=table.remove(B.AvatarOrder,1);if B.Avatars[old]then B.Avatars[old]:Destroy();B.Avatars[old]=nil end end
  end
 end
 if not model then podium.RetryAt=os.time()+C.Leaderboards.AvatarRetry;return end
 if podium.UserId~=id or not board.Model.Parent then model:Destroy();return end
 if podium.Model then podium.Model:Destroy()end
 model:ScaleTo(.8)
 local pivot=model:GetPivot();local bottom=math.huge
 for _,part in model:GetChildren()do if part:IsA("BasePart")then bottom=math.min(bottom,part.Position.Y-part.Size.Y/2)end end
 if bottom==math.huge then model:Destroy();return end
 local target=podium.Base.Position+Vector3.new(0,podium.Base.Size.Y/2+(pivot.Position.Y-bottom),0)
 model:SetAttribute("UserId",id);model:SetAttribute("Rank",rank);model:PivotTo(CFrame.new(target)*CFrame.Angles(0,math.pi,0));model.Parent=board.Model;podium.Model=model;podium.RetryAt=nil
end
function B.Show(key,rows,status)
 local board=B.Boards[key];if not board then return end
 Scores.Sort(rows)
 for i,label in board.Rows do local row=rows[i];label.Text=row and (i..". "..row.Name.."   "..(board.Kind=="Coins"and Format(row.Value)or string.format("%.1f studs",row.Value)))or(i..". —")end
 board.Status.Text=status
 for rank,podium in board.Podiums do local row=rows[rank]
  if not row then if podium.Model then podium.Model:Destroy();podium.Model=nil end;podium.UserId=nil;podium.Label.Text="#"..rank
  else
   if podium.UserId~=row.UserId then if podium.Model then podium.Model:Destroy();podium.Model=nil end;podium.UserId=row.UserId;podium.RetryAt=nil end
   podium.Label.Text="#"..rank
   if not podium.Model and(not podium.RetryAt or os.time()>=podium.RetryAt)then local key=board.Model.Name..rank..row.UserId
    if not B.Queued[key]then B.Queued[key]=true;table.insert(B.Queue,{Board=board,Rank=rank,UserId=row.UserId,Key=key})end
   end
  end
 end
end
function B.Server()
 local coins,height={},{}
 for _,player in Players:GetPlayers()do local p=D.Get(player);if p then
  local h=player:FindFirstChild("leaderstats")and player.leaderstats["Tallest Tree"].Value or 0
  table.insert(coins,{UserId=player.UserId,Name=player.DisplayName,Value=p.Coins});table.insert(height,{UserId=player.UserId,Name=player.DisplayName,Value=h})
 end end
 B.Show("ServerCoins",coins,"This server • updates every "..C.Leaderboards.ServerRefresh.."s")
 B.Show("ServerHeight",height,"This server • updates every "..C.Leaderboards.ServerRefresh.."s")
end
function B.Snapshot(player)
 local p=D.Get(player);if player.UserId<=0 or not p or not D.Persistent(player)or not B.Stores then return end
 return {UserId=player.UserId,Coins=p.Coins,Height=p.HeightRecord or 0}
end
function B.WriteScores(snapshot)
 if not snapshot or not B.Stores then return end
 for kind,value in {Coins=snapshot.Coins,Height=snapshot.Height}do if value>=0 then
  local score=Scores.Encode(value,kind)
  pcall(function()if kind=="Coins"then B.Stores[kind]:SetAsync(tostring(snapshot.UserId),score)else B.Stores[kind]:UpdateAsync(tostring(snapshot.UserId),function(old)return math.max(old or 0,score)end)end end)
 end end
end
function B.Write(player)B.WriteScores(B.Snapshot(player))end
function B.Global()
 if not B.Stores then
  B.Show("GlobalCoins",{},"Global saves unavailable • publish a test place")
  B.Show("GlobalHeight",{},"Global saves unavailable • publish a test place");return
 end
 for _,player in Players:GetPlayers()do B.Write(player)end
 for kind in {Coins=true,Height=true}do
  local ok,result=pcall(function()return B.Stores[kind]:GetSortedAsync(false,C.Leaderboards.Rows,1):GetCurrentPage()end)
  if ok then local rows={};for _,entry in result do local id=tonumber(entry.key);if id and id>0 then table.insert(rows,{UserId=id,Name=B.Username(id),Value=Scores.Decode(entry.value,kind)})end end
   B.Show("Global"..kind,rows,"Global • refreshes every "..C.Leaderboards.GlobalRefresh.."s")
  else B.Boards["Global"..kind].Status.Text="Global rankings temporarily unavailable"end
 end
end
function B.Tick()
 local now=os.time()
 if now>=B.NextServer then B.NextServer=now+C.Leaderboards.ServerRefresh;B.Server()end
 if now>=B.NextGlobal and not B.Fetching then B.NextGlobal=now+C.Leaderboards.GlobalRefresh;B.Fetching=true;task.spawn(function()local ok,err=pcall(B.Global);B.Fetching=false;if not ok then warn("Leaderboard refresh",err)end end)end
end
function B.Close()B.Closed=true;for _,model in B.Avatars do model:Destroy()end end
return B
