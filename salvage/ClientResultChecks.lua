local UI=require(script.Parent.BuildATree.Controllers.UIController)
for _=1,30 do if UI.State and not UI.State.Plots[1]then break end;task.wait(.1)end
UI.Open("Tree Parts");UI.Inventory.Selected="visual_plot_Trunk";UI.Inventory:Refresh(true);task.wait(.2)
local inv=UI.Inventory;local n=0;local function check(v,msg)assert(v,msg);n+=1 end
check(UI.State.PartCount==12 and #UI.State.Parts==12,"UI custody count is unchanged after actual salvage click")
check(inv.Details:FindFirstChild("Equip").Active,"Recovered part becomes selectable")
check(inv.Details:FindFirstChild("SellPart")~=nil,"Recovered unequipped part can offer normal sale")
check(inv.Grid:FindFirstChild("Item_visual_plot_Trunk"):GetAttribute("InUse")=="","Recovered part loses its in-use tag")
script:SetAttribute("Checks",n);script:SetAttribute("Done",true)