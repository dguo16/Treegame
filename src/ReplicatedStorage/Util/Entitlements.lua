-- Restricted accounts retain earned/free progression; paid gameplay perks stay inactive.
local E={}
function E.Has(p,key)return p.Passes[key]==true and(not p.PolicyRestricted or key=="Cosmetics")end
return E
