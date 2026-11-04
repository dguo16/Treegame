-- Supplied Rare/Epic assembly contracts and preservation of schema-9 fruit ownership.
local S=game.ReplicatedStorage.BuildATree
local C=require(S.Config)
local P=require(S.Util.Profile)
local A=require(S.Util.ImportedModels)
local M=require(S.Util.PreviewModels)
local Catalog=require(S.Util.PartCatalog)
local Aliases=require(S.Util.NameAliases)
local F=require(S.Util.FruitCollection)
local J=require(S.Util.Journal)
local G=require(S.Util.GrowthCalculator)
local Tests={}
local function item(slot,index,mutation)
 local tier=math.ceil(index/3);local variant=(index-1)%3+1
 return {Id=slot..index,Slot=slot,Tier=tier,Variant=variant,Name=C.PartVariants[slot][tier][variant],Stat=slot=="Roots"and .25 or 1.5,Mutation=mutation or "None"}
end
function Tests.Run()
 local checks=0;local function check(v,m)assert(v,m);checks+=1 end
 check(C.Schema==11 and Catalog.Count()==84,"One schema bump; catalog remains 84 names")
 check(C.PartVariants.Fruit[3][1]=="Crystalberry"and C.PartVariants.Fruit[3][2]=="Hazelfruit","Replacement names retain positions one and two")
 for _,old in {"Blueberry","Blackberry"}do
  local part={Slot="Fruit",Tier=3,Name=old,Mutation="Cosmic"};local newer=table.clone(part);newer.Name=Aliases.Name(part)
  check(Catalog.Variant(part)==Catalog.Variant(newer),"Old part keeps its stable variant")
  check(J.Key(part)==J.Key(newer)and F.Key(part)==F.Key(newer),"Both collection indexes retain identity")
  check(A.Definition(part,"Fruit").Asset==A.Definition(newer,"Fruit").Asset,"Legacy name resolves to replacement mesh")
 end
 check(Aliases.Name({Slot="Trunk",Tier=3,Name="Blackberry"})=="Blackberry","Alias only applies to fruit")
 check(Aliases.Name({Slot="Fruit",Tier=4,Name="Blueberry"})=="Blueberry","Alias does not change another rarity")
 local p=P.New(100);p.Schema=9;p.Coins=123456;p.Saplings=7;p.Rebirths=3
 local blue={Id="owned-blue",Name="Blueberry",Slot="Fruit",Tier=3,Variant=1,Mutation="Cosmic",Stat=1.537}
 local black={Id="owned-black",Name="Blackberry",Slot="Fruit",Tier=3,Variant=2,Mutation="Golden",Stat=1.579}
 p.Parts={P.Copy(blue),P.Copy(black)};p.Equipped.Fruit=P.Copy(black)
 local function build(part)local b=P.Starter();b.Fruit=P.Copy(part);return b end
 p.Plots={{Build=build(blue),NextDrop=900,HeightScale=1.27,State="Producing"}}
 for i,key in C.Growth.Fields do p[key]={Id="pad"..i,Build=build(i==2 and black or blue),Duration=987,Progress=.23,Settled=100,HeightScale=1.21,State="Growing"}end
 p.GrowthQueue={{Id="queue",Build=build(black)}};p.ProductQuotes.Test={Build=build(blue)}
 p.Bag={Revision=8,Items={{Id="bag",Name="Blueberry",Tier=3,Mutation="Rainbow",Size="Small",Count=5,Value=123,TotalValue=615}},Count=5,Value=615}
 p.Vault={Revision=9,Items={{Id="vault",Name="Blackberry",Tier=3,Mutation="Cosmic",Size="Giant",Count=2,Value=999,TotalValue=1998,Locked=true,ObtainedAt=42}}}
 p.FruitIndex={Version=8,Found={["3:1:Rainbow"]={Name="Blueberry",Tier=3,Mutation="Rainbow",Sizes={Small=true}}},Biggest={Name="Blackberry",Tier=3,Mutation="Cosmic",Size="Giant",Scale=1.6,At=42}}
 p.Journal.Found["Fruit:3:2:Golden"]=true;p.Journal.Collection.Names["Fruit:3:2"]=true;p.Journal.Collection.Claims.Names3=true;p.Journal.Collection.Paid.Names3=321
 p=P.Migrate(p,100)
 check(p.Schema==11 and p.Coins==123456 and p.Saplings==7,"Migration preserves economy")
 check(p.Parts[1].Name=="Crystalberry"and p.Parts[2].Name=="Hazelfruit","Owned names migrated")
 check(p.Parts[1].Id=="owned-blue"and p.Parts[1].Stat==1.537 and p.Parts[1].Mutation=="Cosmic","Owned ID, stat and mutation preserved")
 check(p.Parts[2].Variant==2 and p.Equipped.Fruit.Name=="Hazelfruit","Equipped variant preserved")
 check(p.Plots[1].Build.Fruit.Name=="Crystalberry"and p.Plots[1].NextDrop==900 and p.Plots[1].HeightScale==1.27,"Producing snapshot migrated without timing change")
 for i,key in C.Growth.Fields do check(p[key].Build.Fruit.Name==(i==2 and "Hazelfruit"or "Crystalberry")and p[key].Duration==987 and p[key].Progress==.23 and p[key].Id=="pad"..i,"Every growth pad preserves progress and identity")end
 check(p.GrowthQueue[1].Build.Fruit.Name=="Hazelfruit"and p.ProductQuotes.Test.Build.Fruit.Name=="Crystalberry","Queued and pending purchase snapshots migrated")
 check(p.Bag.Items[1].Name=="Crystalberry"and p.Bag.Items[1].Id=="bag"and p.Bag.Items[1].TotalValue==615 and p.Bag.Items[1].ObtainedAt==nil,"Bag values, ID and unknown time retained")
 check(p.Vault.Items[1].Name=="Hazelfruit"and p.Vault.Items[1].TotalValue==1998 and p.Vault.Items[1].ObtainedAt==42 and p.Vault.Revision==9,"Vault value, time and revision retained")
 check(p.FruitIndex.Found["3:1:Rainbow"].Name=="Crystalberry"and p.FruitIndex.Found["3:1:Rainbow"].Sizes.Small,"Fruit discovery name and sizes retained")
 check(p.FruitIndex.Biggest.Name=="Hazelfruit"and p.FruitIndex.Biggest.At==42,"Biggest record retained")
 check(p.Journal.Found["Fruit:3:2:Golden"]and p.Journal.Collection.Claims.Names3 and p.Journal.Collection.Paid.Names3==321,"Part discoveries, claims and recorded rewards retained")
 local version=p.FruitIndex.Version;check(Aliases.Migrate(p)==0 and p.FruitIndex.Version==version,"Alias migration is idempotent")
 p=P.Migrate(p,100);check(p.Parts[2].Variant==2 and p.Bag.Value==615,"Repeated full migration cannot lose the second name or fruit value")
 for _,slot in C.Slots do for index=7,12 do
  local part=item(slot,index);local definition=A.Definition(part,slot)
  check(definition~=nil and definition.Tier==part.Tier,"Every Rare/Epic named part has an authored definition")
  local plain=M.Part(part);local count=0;local palette={}
  for _,mesh in plain:GetDescendants()do if mesh:IsA("MeshPart")then count+=1;palette[mesh.Name]=mesh.Color;check(mesh.MeshId:match("^rbxassetid://%d+$")~=nil,"Published mesh content ID retained")end end
  check(count>=2,"Authored material groups are preserved")
  plain:Destroy()
  for _,mutation in C.Mutations do if mutation.Name~="None"then
   local clone=item(slot,index,mutation.Name);local model=M.Part(clone)
   for _,mesh in model:GetDescendants()do if mesh:IsA("MeshPart")then
    local preserve=slot=="Fruit"and(mesh.Name:find("Stem")or mesh.Name:find("Leaf"))
    local expected=preserve and palette[mesh.Name]or mutation.Color
    check((Vector3.new(mesh.Color.R,mesh.Color.G,mesh.Color.B)-Vector3.new(expected.R,expected.G,expected.B)).Magnitude<.001,"Mutation preserves botanical accents and recolors eligible surfaces")
   end end
   model:Destroy()
  end end
 end end
 -- All 1,728 completed-tier root/trunk/crown assemblies use the shared joins.
 for root=1,12 do for trunk=1,12 do for leaves=1,12 do
  local b={Roots=item("Roots",root),Trunk=item("Trunk",trunk),Leaves=item("Leaves",leaves),Fruit=item("Fruit",(root+trunk+leaves-1)%12+1)}
  local height=G.Height(b,1.25);local scale=height/6.4;local model=M.Tree(b,1.25,true)
  check(math.abs(model[A.Definition(b.Roots,"Roots").Asset]:GetPivot().Position.Y)<.003,"Root origin remains ground")
  check(math.abs(model[A.Definition(b.Trunk,"Trunk").Asset]:GetPivot().Position.Y-.6*scale)<.003,"Every trunk meets root join")
  check(math.abs(model[A.Definition(b.Leaves,"Leaves").Asset]:GetPivot().Position.Y-3.6*scale)<.003,"Every canopy meets trunk join")
  for j=1,3 do local fruit=model["Fruit"..j];local actual=fruit:GetPivot().Position+A.Attach(b.Fruit)*scale*.65;local expected=(Vector3.new(0,3.6,0)+A.Socket(b,j))*scale;check((actual-expected).Magnitude<.003,"Mixed fruit meets the selected canopy socket")end
  model:Destroy()
 end end;task.wait()end
 for i=7,12 do local leaf=item("Leaves",i);for socket=1,3 do check(A.Socket({Leaves=leaf},socket).Y<=.40001,"Opaque new crowns keep fruit on the visible lower attachments")end end
 for i=7,12 do local normal=item("Fruit",i);normal.Size="Normal";local giant=P.Copy(normal);giant.Size="Giant";local a=M.Harvest(normal);local b=M.Harvest(giant);local _,sa=a:GetBoundingBox();local _,sb=b:GetBoundingBox();check((sb-sa*1.6).Magnitude<.001,"All new harvest meshes retain uniform Giant scaling");a:Destroy();b:Destroy()end
 print("Build a Tree authored Rare/Epic: "..checks.." checks passed");return checks
end
return Tests
