local UI=require(script.Parent.BuildATree.Controllers.UIController)
local S=game.ReplicatedStorage.BuildATree;local P=require(S.Util.Profile);local C=require(S.Config)
local n=0;local function check(v,msg)assert(v,msg);n+=1 end
local function inView(b)
 local p,s=b.AbsolutePosition,b.AbsoluteSize;local a=UI.Inventory.Details.AbsolutePosition;local z=UI.Inventory.Details.AbsoluteSize
 return p.X>=a.X and p.Y>=a.Y and p.X+s.X<=a.X+z.X+1 and p.Y+s.Y<=a.Y+z.Y+1
end
local f=Instance.new("BindableFunction");f.Name="Command";f.Parent=script
f.OnInvoke=function(command)
 if command=="Parts"then
  UI.Open("Tree Parts");UI.Inventory.Selected="visual_plot_Trunk";UI.Inventory:Refresh(true)
 elseif command=="CheckParts"then
  local inv=UI.Inventory;local equip=inv.Details:FindFirstChild("Equip")
  check(inv.Root.Visible,"Parts window visible");check(equip and not equip.Active,"In-use equip is disabled")
  check(not inv.Details:FindFirstChild("SellPart"),"In-use part has no sale button")
  local cell=inv.Grid:FindFirstChild("Item_visual_plot_Trunk");check(cell and cell:GetAttribute("InUse")=="In use: Plot 1","Grid tag names owner location")
  local copy=P.Copy(UI.State);for _,key in C.Growth.Fields do if copy[key]then copy[key].State="Growing"end end
  inv:Update(copy);check(not inv.Primary.Active and inv.Primary.Text=="CHOOSE FREE PARTS","Locked equipped build cannot offer planting or queuing")
  inv:Update(UI.State)
 elseif command=="Garden"then
  UI.Open("Tree Parts");UI.Inventory.Category="Garden";UI.Inventory.SelectedTreeId=UI.State.Plots[1]and UI.State.Plots[1].Id;UI.Inventory:Refresh(true);UI.Inventory.Details.CanvasPosition=Vector2.zero
 elseif command=="CheckGarden"then
  local inv=UI.Inventory;local salvage=inv.Details:FindFirstChild("Salvage")
  check(salvage and salvage.Visible and salvage.Active,"Salvage action exists")
  check(salvage.AbsoluteSize.X>=44 and salvage.AbsoluteSize.Y>=44,"Salvage touch target is at least 44 pixels")
  check(inView(salvage),"Salvage visible without scrolling part details")
  local count=0;for _,x in inv.Details:GetChildren()do if x:IsA("TextLabel")and(x.Text:find("Trunk:")or x.Text:find("Leaves:")or x.Text:find("Roots:")or x.Text:find("Fruit:"))then count+=1 end end
  check(count==4,"All four original parts listed")
  check(inv.Grid:FindFirstChild("Tree_1")~=nil and inv.MainModel~=nil,"Tree list and preview are present")
 elseif command=="CheckConfirm"then
  local d=UI.Placement.Dialog;local b=d and d:FindFirstChild("Salvage",true)
  check(UI.Placement.Confirmation and UI.Placement.Confirmation.Salvage,"Server confirmation is identified as salvage")
  check(b and b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,"Confirmation touch target is usable")
  local vp=workspace.CurrentCamera.ViewportSize;local pos=b.AbsolutePosition;check(pos.X>=0 and pos.Y>=0 and pos.X+b.AbsoluteSize.X<=vp.X+1 and pos.Y+b.AbsoluteSize.Y<=vp.Y+1,"Confirmation lies within viewport")
 elseif command=="Journal"then UI.Open("Tree Parts");UI.Inventory.Category="Journal";UI.Inventory.Journal.IndexMode="Browse";UI.Inventory:Refresh(true)
 elseif command=="More"then UI.Open("More")
 elseif command=="Close"then UI.Inventory:Close();UI.Placement:Clear()
 end
 script:SetAttribute("Checks",n);return n
end
script:SetAttribute("Ready",true)