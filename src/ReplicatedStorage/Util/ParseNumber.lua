-- Bounded numeric input, including scientific notation and standard large-number suffixes.
local suffixes={k=1e3,m=1e6,b=1e9,t=1e12,qa=1e15,qi=1e18,sx=1e21,sp=1e24,oc=1e27,no=1e30}
return function(raw,minimum,maximum)
 if type(raw)~="string" or #raw>40 then return nil end
 local value=raw:lower():gsub(",",""):match("^%s*(.-)%s*$")
 local number=tonumber(value)
 if not number then
  local base,suffix=value:match("^([%+%-]?[%d%.]+)(%a+)$")
  if base and suffixes[suffix] then number=tonumber(base);if number then number*=suffixes[suffix] end end
 end
 if not number or number~=number or number==math.huge or number==-math.huge or number<minimum or number>maximum then return nil end
 return number
end
