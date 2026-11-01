-- In-world confirmed replacement and plot selection, owner-only highlights, hover outline and tap support.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Input=game:GetService("UserInputService")
local Prompts=game:GetService("ProximityPromptService")
local GuiService=game:GetService("GuiService")
local S=game:GetService("ReplicatedStorage").BuildATree
local T=require(S.Theme)
local Plot={};Plot.__index=Plot
function Plot.new(gui,send)
 local self=setmetatable({Send=send,Player=Players.LocalPlayer,Highlights={},Parts={}},Plot)
 local hint=Instance.new("TextLabel");hint.Name="PlacementHint";hint.Size=UDim2.new(.8,0,0,60);hint.Position=UDim2.new(.1,0,1,-160);hint.BackgroundColor3=T.Cream;hint.TextColor3=T.Ink;hint.Font=Enum.Font.FredokaOne;hint.TextSize=21;hint.TextScaled=true;hint.TextWrapped=true;hint.Text="Green: plant • Gold: replace • Esc / right-click to cancel";hint.Visible=false;hint.ZIndex=20;hint.Parent=gui
 local limit=Instance.new("UITextSizeConstraint");limit.MinTextSize=12;limit.MaxTextSize=21;limit.Parent=hint
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,16);corner.Parent=hint;self.Hint=hint
 Prompts.PromptShown:Connect(function(prompt) local owner=prompt:GetAttribute("OwnerUserId");if owner and owner~=self.Player.UserId then prompt.Enabled=false end end)
 Run.RenderStepped:Connect(function()
  if self.Confirmation and workspace:GetServerTimeNow()>=self.Confirmation.Expires then self:Clear();send("CancelPlacement",{})end
  if self.Selection then
   if workspace:GetServerTimeNow()>self.Selection.Expires then self:Clear();return end
   if not Input:GetLastInputType().Name:find("Gamepad")then local mouse=Input:GetMouseLocation();self:Hover(mouse)end
  end
 end)
 Input.InputBegan:Connect(function(input,processed)
  if not self.Selection and not self.Confirmation then return end
  if input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB then self:Clear();send("CancelPlacement",{});return end
  if self.Selection and not self.Confirmation then
   if input.KeyCode==Enum.KeyCode.DPadLeft or input.KeyCode==Enum.KeyCode.DPadRight then
    self.Cursor=((self.Cursor or 1)+(input.KeyCode==Enum.KeyCode.DPadLeft and -2 or 0))%#self.Parts+1
    self.Hovered=self.Parts[self.Cursor];for part,h in self.Highlights do h.OutlineTransparency=part==self.Hovered and 0 or 1 end;return
   elseif input.KeyCode==Enum.KeyCode.ButtonA then
    local target=self.Hovered or self.Parts[self.Cursor or 1];if target then local id=self.Selection.GrowthId;local index=target:GetAttribute("PlotIndex");self:Clear();send("PlaceTree",{Plot=index,GrowthId=id})end;return
   end
  end
  if processed or self.Confirmation then return end
  if input.KeyCode==Enum.KeyCode.Escape or input.UserInputType==Enum.UserInputType.MouseButton2 then self:Clear();send("CancelPlacement",{});return end
  if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
   local pos=input.UserInputType==Enum.UserInputType.Touch and Vector2.new(input.Position.X,input.Position.Y)or Input:GetMouseLocation()
   self:Hover(pos)
   if self.Hovered then local index=self.Hovered:GetAttribute("PlotIndex");local id=self.Selection.GrowthId;self:Clear();send("PlaceTree",{Plot=index,GrowthId=id})end
  end
 end)
 return self
end
function Plot:Clear()
 if self.Dialog then self.Dialog:Destroy();self.Dialog=nil end;self.Confirmation=nil
 if self.HiddenPrompt and self.HiddenPrompt.Parent then self.HiddenPrompt.Enabled=true end;self.HiddenPrompt=nil
 if self.Touch then if self.Touch.Gui.Parent then self.Touch.Gui.Enabled=self.Touch.Enabled end;self.Touch=nil end
 for _,highlight in self.Highlights do highlight:Destroy()end
 self.Highlights={};self.Parts={};self.Selection=nil;self.Hovered=nil;self.Hint.Visible=false
end
function Plot:Begin(selection)
 self:Clear();local world=workspace:FindFirstChild("BuildATreeWorld");local garden=world and world:FindFirstChild("Garden_"..self.Player.UserId);if not garden then return end
 self.Selection=selection;self.Cursor=1;self.Hint.Visible=true
 self.Hint.Text=#Input:GetConnectedGamepads()>0 and "D-pad: choose plot • A: select • B: cancel"or "Green: plant • Gold: replace • Esc / right-click to cancel"
 local touch=self.Player.PlayerGui:FindFirstChild("TouchGui");if touch then self.Touch={Gui=touch,Enabled=touch.Enabled};touch.Enabled=false end
 for _,prompt in garden:GetDescendants()do if prompt:IsA("ProximityPrompt")and prompt:GetAttribute("Kind")=="Ready"and prompt:GetAttribute("OwnerUserId")==self.Player.UserId then self.HiddenPrompt=prompt;prompt.Enabled=false;break end end
 for _,index in selection.Plots do local pad=garden:FindFirstChild("Plot"..index)
  if pad then local h=Instance.new("Highlight");h.Name="AvailablePlot";h.Adornee=pad;h.FillColor=selection.Occupied and selection.Occupied[index] and T.Gold or T.Green;h.FillTransparency=.35;h.OutlineColor=T.Cream;h.OutlineTransparency=1;h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=pad;self.Highlights[pad]=h;table.insert(self.Parts,pad)end
 end
end
function Plot:Confirm(data)
 self:Clear();self.Confirmation=data
 local gui=self.Hint.Parent
 local touch=self.Player.PlayerGui:FindFirstChild("TouchGui");if touch then self.Touch={Gui=touch,Enabled=touch.Enabled};touch.Enabled=false end
 local shade=Instance.new("TextButton");shade.Name="ReplacementConfirmation";shade.Text="";shade.AutoButtonColor=false;shade.Size=UDim2.fromScale(1,1);shade.BackgroundColor3=T.Ink;shade.BackgroundTransparency=.35;shade.ZIndex=40;shade.Parent=gui;self.Dialog=shade
 local panel=Instance.new("Frame");panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.Size=UDim2.new(.9,0,.72,0);panel.BackgroundColor3=T.Cream;panel.ZIndex=41;panel.Parent=shade
 local size=Instance.new("UISizeConstraint");size.MaxSize=Vector2.new(500,320);size.Parent=panel
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,20);corner.Parent=panel
 local stroke=Instance.new("UIStroke");stroke.Color=T.Ink;stroke.Thickness=3;stroke.Parent=panel
 local label=Instance.new("TextLabel");label.BackgroundTransparency=1;label.Position=UDim2.fromScale(.05,.04);label.Size=UDim2.fromScale(.9,.62);label.Font=Enum.Font.FredokaOne;label.TextColor3=T.Ink;label.TextWrapped=true;label.TextScaled=true;label.Text="Replace tree in plot "..data.Plot.."?\n\n"..(data.Returned>0 and (data.Returned.." missing parts return to your inventory.")or "All its parts are already available in your inventory or starter set.").." Dropped fruit from this tree will be cleared.\nYour ready tree takes its place.";label.ZIndex=42;label.Parent=panel
 local textSize=Instance.new("UITextSizeConstraint");textSize.MaxTextSize=22;textSize.MinTextSize=12;textSize.Parent=label
 local function action(name,x,color,fn)
  local b=Instance.new("TextButton");b.Name=name;b.Text=name;b.Position=UDim2.fromScale(x,.73);b.Size=UDim2.new(.42,0,0,48);b.BackgroundColor3=color;b.TextColor3=T.Ink;b.Font=Enum.Font.FredokaOne;b.TextSize=22;b.ZIndex=42;b.Parent=panel
  local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,14);c.Parent=b;b.Activated:Connect(fn);if name=="Cancel"and #Input:GetConnectedGamepads()>0 then GuiService.SelectedObject=b end
 end
 action("Cancel",.05,T.Blue,function()self:Clear();self.Send("CancelPlacement",{})end)
 action("Replace",.53,T.Gold,function()local pending=self.Confirmation;if not pending then return end;self:Clear();self.Send("ReplaceTree",{Plot=pending.Plot,GrowthId=pending.GrowthId,Token=pending.Token})end)
end
function Plot:Hover(pos)
 local camera=workspace.CurrentCamera;local ray=camera:ViewportPointToRay(pos.X,pos.Y)
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances=self.Parts
 local hit=workspace:Raycast(ray.Origin,ray.Direction*1000,params);self.Hovered=hit and hit.Instance or nil
 for part,h in self.Highlights do h.OutlineTransparency=part==self.Hovered and 0 or 1 end
end
function Plot:Update(state)
 local function ready(id)return (state.Growth and state.Growth.Id==id and state.Growth.State=="Ready")or(state.Growth2 and state.Growth2.Id==id and state.Growth2.State=="Ready")end
 if self.Confirmation and(not ready(self.Confirmation.GrowthId))then self:Clear()end
 if self.Selection and(not ready(self.Selection.GrowthId))then self:Clear()end
end
return Plot
