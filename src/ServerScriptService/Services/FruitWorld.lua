-- Six miniature vaulted-fruit displays. Cosmetic only; never enters the harvest pool.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local Sizes=require(S.Util.FruitSizes)
local Models=require(S.Util.PreviewModels)
local FruitWorld={}
function FruitWorld.Apply(W,player,p)
 local g=W.Gardens[player];if not g then return end
 local revision=p.Vault and p.Vault.Revision or 0
 if g.VaultShelfRevision==revision then return end;g.VaultShelfRevision=revision
 local old=g.Folder:FindFirstChild("VaultShelf");if old then old:Destroy()end
 local shelf=Instance.new("Model");shelf.Name="VaultShelf";local origin=g.Origin+Vector3.new(-15,0,34)
 local function wood(name,size,offset)
  local part=W.Part(shelf,name,size,origin+offset,Color3.fromRGB(171,116,69));part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;return part
 end
 for _,x in {-7,7}do wood("Post",Vector3.new(.4,6.2,.4),Vector3.new(x,3.1,0))end
 for _,y in {1,3.5}do wood("Shelf",Vector3.new(15,.3,2.8),Vector3.new(0,y,0))end
 local board=wood("VaultLabel",Vector3.new(7,.8,.2),Vector3.new(0,5.9,0));local label=W.Billboard(board,"VAULT - "..#(p.Vault and p.Vault.Items or {}).." / "..C.FruitInventory.VaultStacks.." stacks",Color3.fromRGB(255,220,100));label.Bar.Visible=false;label.MaxDistance=65
 for index=1,math.min(C.FruitInventory.ShelfSlots,#(p.Vault and p.Vault.Items or {}))do
  local item=p.Vault.Items[index];local model=Models.Fruit(item);local _,bounds=model:GetBoundingBox();local longest=math.max(bounds.X,bounds.Y,bounds.Z)
  model:ScaleTo(model:GetScale()*C.FruitInventory.ShelfFruitSize*Sizes.Get(item.Size).Scale/longest)
  local x=((index-1)%3-1)*4.6;local shelfY=index<=3 and 1 or 3.5
  local cf,bounds=model:GetBoundingBox();local pivot=model:GetPivot();local y=shelfY+.16+pivot.Position.Y-cf.Position.Y+bounds.Y/2
  model.Name="VaultFruit_"..index;model:SetAttribute("SizeClass",Sizes.Get(item.Size).Name);model:SetAttribute("StackId",item.Id);model:PivotTo(CFrame.new(origin+Vector3.new(x+pivot.Position.X-cf.Position.X,y,pivot.Position.Z-cf.Position.Z)))
  for _,part in model:GetDescendants()do if part:IsA("BasePart")then part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false end end
  model.Parent=shelf
 end
 shelf.Parent=g.Folder
end
return FruitWorld
