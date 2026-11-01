-- Compact deterministic number formatting shared by HUD and simulations.
local suffix={"","K","M","B","T","Qa","Qi","Sx","Sp","Oc","No"}
return function(n)
 local sign=n<0 and "-" or ""; n=math.abs(n)
 if n>0 and n<1 then return sign..string.format("%.1f",n) end
 local i=1; while n>=1000 and i<#suffix do n/=1000; i+=1 end
 return sign..(i==1 and tostring(math.floor(n)) or string.format("%.2f%s",n,suffix[i]))
end
