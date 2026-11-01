-- Authorization and mutation tests; synthetic actors cannot alter any live player profile.
local S=game:GetService("ReplicatedStorage").BuildATree
local P=require(S.Util.Profile)
local C=require(S.Config)
local Parse=require(S.Util.ParseNumber)
local Validate=require(S.Util.IntentValidator)
local A=require(game.ServerScriptService.BuildATree.Services.AdminService)
local Config=require(game.ServerScriptService.BuildATree.Services.AdminConfig)
local Catalog=require(S.Util.PartCatalog)
local Tests={}
function Tests.Run()
 local checks=0
 local function check(value,message)assert(value,message);checks+=1 end
 local owner={UserId=Config.UserId,Name="chikinnugggets"}
 local impostor={UserId=Config.UserId+1,Name="chikinnugggets",DisplayName="chikinnugggets"}
 check(A.IsAdmin(owner),"Owner recognized by immutable UserId")
 check(not A.IsAdmin(impostor),"Matching display name cannot grant access")
 check(A.IsAdmin({UserId=Config.UserId,Name="RenamedAccount"}),"Account rename does not remove owner's access")
 local p=P.New(0);local initial=p.Coins
 local function nextId()p.NextId+=1;return tostring(p.NextId)end
 local requests={
  {"AdminCoins",{Mode="Set",Amount="1B"}},
  {"AdminPart",{Slot="Trunk",Tier=7,Equip=true}},
  {"AdminAllParts",{}},
  {"AdminLuck",{Multiplier="100"}},
  {"AdminResetLuck",{}},
 }
 for _,request in requests do check(not A.Execute(impostor,p,request[1],request[2],nextId),"Unauthorized command rejected: "..request[1]) end
 check(p.Coins==initial and #p.Parts==0 and p.AdminControls==nil,"Unauthorized commands leave profile untouched")
 check(not Validate("AdminCoins",{Mode="Set",Amount="1M",Target=Config.UserId}),"Client-supplied target rejected")
 check(not Validate("AdminPart",{Slot="Fruit",Tier=7,Equip=true,Stat=999999}),"Forged part stats rejected")
 check(Parse("1B",0,1e30)==1e9 and Parse("1,500",0,1e30)==1500,"Convenient numeric formats")
 check(Parse("1e25",0,1e30)==1e25,"Scientific notation")
 for _,value in {"-1","nan","inf","1e309","1e31",""} do check(Parse(value,0,1e30)==nil,"Invalid or out-of-range amount rejected: "..value) end
 check(A.Execute(owner,p,"AdminCoins",{Mode="Set",Amount="1M"},nextId)and p.Coins==1e6,"Owner sets own coins")
 check(A.Execute(owner,p,"AdminCoins",{Mode="Add",Amount="250"},nextId)and p.Coins==1000250,"Owner adds coins")
 check(A.Execute(owner,p,"AdminCoins",{Mode="Remove",Amount="2M"},nextId)and p.Coins==0,"Removal floors at zero")
 check(A.Execute(owner,p,"AdminCoins",{Mode="Set",Amount="1e30"},nextId),"Configured coin maximum accepted")
 check(A.Execute(owner,p,"AdminCoins",{Mode="Add",Amount="1M"},nextId)and p.Coins==C.Runtime.MaxCoins,"Addition stays bounded")
 check(not A.Execute(owner,p,"AdminCoins",{Mode="Multiply",Amount="1"},nextId),"Unknown coin operations rejected")
 check(A.Execute(owner,p,"AdminPart",{Slot="Trunk",Tier=7,Equip=true},nextId),"Owner grants a chosen part")
 check(p.Equipped.Trunk.Tier==7 and p.Equipped.Trunk.Stat==C.Rarities[7].Max,"Granted part uses server catalog stats")
 check(not A.Execute(owner,p,"AdminPart",{Slot="Unknown",Tier=7,Equip=false},nextId),"Unknown slot rejected")
 check(not A.Execute(owner,p,"AdminPart",{Slot="Roots",Tier=3.5,Equip=false},nextId),"Fractional rarity rejected")
 local before=#p.Parts
 check(A.Execute(owner,p,"AdminAllParts",{},nextId)and #p.Parts==before+Catalog.Count(),"All catalog entries granted")
 for _,slot in C.Slots do for tier=1,#C.Rarities do for _,name in Catalog.Variants(slot,tier) do
  local found=false;for _,part in p.Parts do if part.Slot==slot and part.Tier==tier and part.Name==name then found=true end end;check(found,"Missing catalog part "..name)
 end end end
 check(not A.Execute(impostor,p,"AdminCatalogPart",{Slot="Trunk",Tier=1,Choice="2:Equip"},nextId),"New variant grant remains owner-only")
 check(not A.Execute(owner,p,"AdminCatalogPart",{Slot="Trunk",Tier=1,Choice="99:Give"},nextId),"Invalid catalog index rejected")
 check(not Validate("AdminCatalogPart",{Slot="Trunk",Tier=1,Choice="2:Give",Mutation="Cosmic"}),"Forged mutation rejected")
 check(A.Execute(owner,p,"AdminCatalogPart",{Slot="Trunk",Tier=1,Choice="2:Equip"},nextId) and p.Equipped.Trunk.Name=="Pine","Owner can grant and equip new catalog variants")
 check(A.Execute(owner,p,"AdminLuck",{Multiplier="1000"},nextId)and A.Override(p)==1000,"Luck override set")
 check(not A.Execute(owner,p,"AdminLuck",{Multiplier="0"},nextId),"Zero-weight luck rejected")
 check(not A.Execute(owner,p,"AdminLuck",{Multiplier="1e309"},nextId),"Infinite luck rejected")
 check(A.Execute(owner,p,"AdminResetLuck",{},nextId)and A.Override(p)==nil,"Normal luck restored")
 for _=1,Config.AuditLimit+2 do A.Execute(owner,p,"AdminCoins",{Mode="Set",Amount="1"},nextId)end
 check(#p.AdminControls.Audit==Config.AuditLimit,"Audit log is bounded")
 while #p.Parts<C.Runtime.MaxInventory do table.insert(p.Parts,{Id="filled"})end
 local idBefore=p.NextId
 check(not A.Execute(owner,p,"AdminAllParts",{},nextId)and p.NextId==idBefore,"Full-inventory grant is atomic")
 check(not A.Execute(owner,p,"AdminPart",{Slot="Leaves",Tier=7,Equip=false},nextId),"Single grant respects inventory cap")
 print("Build a Tree admin security: "..checks.." assertions passed");return checks
end
return Tests
