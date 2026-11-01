-- Standardized mesh joins, recoloring and hanging-fruit attachment regression checks.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local Models=require(S.Util.PreviewModels)
local Imported=require(S.Util.ImportedModels)
local Growth=require(S.Util.GrowthCalculator)
local Tests={}
local function item(slot,index,mutation)
 local tier=index<=3 and 1 or 2
 return {Id=slot..index,Slot=slot,Tier=tier,Name=C.PartVariants[slot][tier][(index-1)%3+1],Stat=1,Mutation=mutation or 'None'}
end
-- Whole-tree workbench edits intentionally override standardized Clover geometry.
local function canopyHeight(build,height)
 local editor=S:FindFirstChild("StarterTreeEditor")or workspace:FindFirstChild("StarterTreeEditor")
 if build.Leaves.Name~="Clover"or build.Leaves.Tier~=1 or not editor then return height end
 local origin=editor.EditorOrigin.CFrame;local top=-math.huge
 for _,part in editor.Leaves:GetDescendants()do if part:IsA("BasePart")then
  for _,x in {-1,1}do for _,y in {-1,1}do for _,z in {-1,1}do
   local point=origin:PointToObjectSpace(part.CFrame:PointToWorldSpace(part.Size*Vector3.new(x,y,z)/2));top=math.max(top,point.Y)
  end end end
 end end
 return top*height/editor.ReferenceHeight.Value
end
function Tests.Run()
 local checks=0
 local function check(v,message)assert(v,message);checks+=1 end
 for _,slot in C.Slots do for i=1,6 do for _,mutation in C.Mutations do
  local part=item(slot,i,mutation.Name);local model=Models.Part(part)
  check(model:FindFirstChildWhichIsA('MeshPart',true)~=nil,'Missing imported '..part.Name)
  for _,mesh in model:GetDescendants() do if mesh:IsA('MeshPart') and mutation.Name~='None' and (slot~='Fruit' or not(mesh.Name:find('Leaf') or mesh.Name:find('Stem'))) then
   check(math.abs(mesh.Color.R-mutation.Color.R)+math.abs(mesh.Color.G-mutation.Color.G)+math.abs(mesh.Color.B-mutation.Color.B)<.001,'Mutation recolor '..mesh.Name)
  end end
  model:Destroy()
 end end end
 for r=1,6 do for t=1,6 do for l=1,6 do
  local build={Roots=item('Roots',r),Trunk=item('Trunk',t),Leaves=item('Leaves',l),Fruit=item('Fruit',(r+t+l)%6+1)}
  for _,variation in {.75,1.5} do
   local h=Growth.Height(build,variation);local scale=h/6.4;local tree=Models.Tree(build,variation,true)
   local cf,size=tree:GetBoundingBox()
   check(math.abs(cf.Position.Y+size.Y/2-canopyHeight(build,h))<.003,'Canopy follows standardized or editable reference height')
   local trunk=tree[Imported.Definition(build.Trunk,'Trunk').Asset]
   local leaves=tree[Imported.Definition(build.Leaves,'Leaves').Asset]
   check(math.abs(trunk:GetPivot().Position.Y-.6*scale)<.003,'Root/trunk join')
   check(math.abs(leaves:GetPivot().Position.Y-3.6*scale)<.003,'Trunk/canopy join')
   tree:Destroy()
  end
 end end;task.wait()end
 for l=1,6 do for f=1,6 do
  local build={Roots=item('Roots',1),Trunk=item('Trunk',1),Leaves=item('Leaves',l),Fruit=item('Fruit',f)}
  local h=Growth.Height(build,1);local scale=h/6.4;local tree=Models.Tree(build,1,true)
  for j=1,3 do
   local fruit=tree['Fruit'..j]
   local actual=fruit:GetPivot().Position+Imported.Attach(build.Fruit)*scale*.65
   local expected=(Vector3.new(0,3.6,0)+Imported.Socket(build,j))*scale
   check((actual-expected).Magnitude<.003,'Fruit socket '..build.Leaves.Name..' / '..build.Fruit.Name)
  end
  tree:Destroy()
 end end
 print('Build a Tree standardized assets: '..checks..' checks passed')
 return checks
end
return Tests
