-- Integer OrderedDataStore codec and deterministic server ranking helpers.
local Scores={}
function Scores.Encode(value,kind)
 value=math.max(0,value)
 return kind=="Coins"and math.floor(math.log10(value+1)*1e9+.5)or math.floor(value*100+.5)
end
function Scores.Decode(score,kind)return kind=="Coins"and math.max(0,10^(score/1e9)-1)or score/100 end
function Scores.Sort(rows)
 table.sort(rows,function(a,b)if a.Value==b.Value then return a.UserId<b.UserId end;return a.Value>b.Value end);return rows
end
return Scores
