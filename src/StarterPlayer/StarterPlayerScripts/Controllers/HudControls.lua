-- Small topbar gear and asset-free two-arrow auto-roll control beside the roll button.
local GuiService=game:GetService("GuiService")
local Players=game:GetService("Players")
local Input=game:GetService("UserInputService")
local S=game:GetService("ReplicatedStorage").BuildATree
local T=require(S.Theme)
local Hud={};Hud.__index=Hud
local function circle(parent,name,color,callback)
 local b=Instance.new("TextButton");b.Name=name;b.Text="";b.Size=UDim2.fromOffset(44,44);b.BackgroundColor3=color;b.BorderSizePixel=0;b.Parent=parent
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(1,0);corner.Parent=b
 local stroke=Instance.new("UIStroke");stroke.Color=T.Ink;stroke.Thickness=2;stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;stroke.Parent=b;b.Activated:Connect(callback);return b
end
function Hud.new(gui,roll,onSettings,onAuto,onReady)
 local self=setmetatable({Gui=gui,Roll=roll,Arcs={}},Hud)
 local top=Instance.new("ScreenGui");top.Name="GardenTopbar";top.ResetOnSpawn=false;top.ScreenInsets=Enum.ScreenInsets.None;top.DisplayOrder=10;top.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;top.Parent=Players.LocalPlayer.PlayerGui
 local gear=circle(top,"SettingsGear",T.Cream,onSettings);gear.Text="⚙";gear.Font=Enum.Font.GothamBold;gear.TextSize=30;gear.TextColor3=T.Ink;self.Gear=gear
 local auto=circle(gui,"AutoRoll",T.Paper,onAuto);auto.ZIndex=4;self.Auto=auto
 for _,start in {20,200}do
  for i=0,11 do local angle=math.rad(start+i*12);local segment=Instance.new("Frame");segment.Name="ArrowArc";segment.AnchorPoint=Vector2.new(.5,.5);segment.Position=UDim2.fromScale(.5+math.cos(angle)*.31,.5+math.sin(angle)*.31);segment.Size=UDim2.fromScale(.13,.07);segment.Rotation=math.deg(angle)+90;segment.BackgroundColor3=T.Ink;segment.BorderSizePixel=0;segment.ZIndex=5;segment.Parent=auto;table.insert(self.Arcs,segment)
   local r=Instance.new("UICorner");r.CornerRadius=UDim.new(1,0);r.Parent=segment
  end
  local angle=math.rad(start+144);local arrow=Instance.new("TextLabel");arrow.Name="ArrowHead";arrow.AnchorPoint=Vector2.new(.5,.5);arrow.Position=UDim2.fromScale(.5+math.cos(angle)*.31,.5+math.sin(angle)*.31);arrow.Size=UDim2.fromScale(.3,.3);arrow.Rotation=math.deg(angle)+90;arrow.Text="▶";arrow.Font=Enum.Font.GothamBold;arrow.TextScaled=true;arrow.TextColor3=T.Ink;arrow.BackgroundTransparency=1;arrow.ZIndex=6;arrow.Parent=auto;table.insert(self.Arcs,arrow)
 end
 local state=Instance.new("TextLabel");state.Name="State";state.Size=UDim2.fromOffset(48,18);state.Position=UDim2.new(.5,-24,1,2);state.Text="OFF";state.Font=Enum.Font.FredokaOne;state.TextSize=13;state.TextColor3=T.Cream;state.TextStrokeColor3=T.Ink;state.TextStrokeTransparency=0;state.BackgroundTransparency=1;state.Parent=auto;self.Label=state
 local ready=Instance.new("TextButton");ready.Name="TreeReady";ready.Size=UDim2.fromOffset(210,44);ready.AnchorPoint=Vector2.new(.5,1);ready.Position=UDim2.new(.5,0,1,-148);ready.BackgroundColor3=T.Green;ready.TextColor3=T.Ink;ready.Font=Enum.Font.FredokaOne;ready.TextSize=18;ready.Visible=false;ready.Parent=gui;ready.Activated:Connect(onReady);self.Ready=ready
 local readyCorner=Instance.new("UICorner");readyCorner.CornerRadius=UDim.new(0,16);readyCorner.Parent=ready
 local readyStroke=Instance.new("UIStroke");readyStroke.Color=T.Ink;readyStroke.Thickness=2;readyStroke.Parent=ready
 local function resize()
  local rect=GuiService.TopbarInset;local h=rect.Max.Y-rect.Min.Y
  gear.Position=UDim2.fromOffset(rect.Min.X+6,rect.Min.Y+math.max(0,(h-44)/2))
  local mobile=Input.TouchEnabled or workspace.CurrentCamera.ViewportSize.X<650
  auto.Position=UDim2.fromOffset(roll.AbsolutePosition.X+(mobile and 2 or -52),roll.AbsolutePosition.Y+(mobile and -60 or roll.AbsoluteSize.Y-44))
 end
 GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(resize);roll:GetPropertyChangedSignal("AbsolutePosition"):Connect(resize);roll:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize);resize()
 return self
end
function Hud:Update(state)
 local count=(state.Growth and state.Growth.State=="Ready"and 1 or 0)+(state.Growth2 and state.Growth2.State=="Ready"and 1 or 0)
 self.Ready.Visible=count>0;self.Ready.Text=count..(count==1 and " TREE READY"or " TREES READY").." • GARDEN"
 self.Auto.BackgroundColor3=state.AutoRoll and T.Green or T.Paper;self.Label.Text=state.AutoRoll and "ON"or "OFF"
 for _,piece in self.Arcs do if piece:IsA("TextLabel")then piece.TextColor3=state.AutoRoll and T.Cream or T.Ink else piece.BackgroundColor3=state.AutoRoll and T.Cream or T.Ink end end
end
return Hud
