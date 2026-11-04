-- One shared capacity contract for services, placement and the intent-only UI.
local C=require(script.Parent.Parent.Config)
local E=require(script.Parent.Entitlements)
local Pads={}
function Pads.Key(pad)return C.Growth.Fields[pad]end
function Pads.Maximum(p)
 local second=(p.Rebirths or 0)>=1 or p.LegacySecondPad==true
 if not second then return 1 end
 return ((p.Rebirths or 0)>=C.Growth.ThirdFreeAscensions or E.Has(p,"ThirdPad"))and 3 or 2
end
function Pads.QueueLimit(p)return C.Growth.QueueLimit+(Pads.Maximum(p)==3 and 1 or 0)end
return Pads
