// Independent tier-focused Monte Carlo: same weights, pity and uniform slots as RollEngine.
const fs=require('fs');const rows=[];const seeds=256;const weights=[60,25,10,4,.9,.09,.01];
for(let seed=1;seed<=seeds;seed++){
 let state=(seed*2654435761)>>>0;function rand(){state^=state<<13;state^=state>>>17;state^=state<<5;return(state>>>0)/4294967296}
 let epic=0,legend=0;const top=Array.from({length:4},()=>[1,1,1,1,1,1]);const a=[0],b=[0];let rolls=0;
 while(!b[6]&&rolls<5000000){
  let min=legend+1>=300?5:epic+1>=50?4:1;if(rolls===2)min=Math.max(min,3);
  let total=0;for(let t=min;t<=7;t++)total+=weights[t-1];let target=rand()*total,tier=7;
  for(let t=min;t<=7;t++){target-=weights[t-1];if(target<0){tier=t;break}}
  epic=tier>=4?0:epic+1;legend=tier>=5?0:legend+1;rolls++;
  let slot=Math.floor(rand()*4);if(tier>top[slot][5]){top[slot][5]=tier;top[slot].sort((x,y)=>y-x)}
  let one=Math.floor(top.reduce((s,x)=>s+x[0],0)/4),six=Math.floor(top.reduce((s,x)=>s+x[5],0)/4);
  for(let t=2;t<=one;t++)if(a[t-1]===undefined)a[t-1]=rolls;for(let t=2;t<=six;t++)if(b[t-1]===undefined)b[t-1]=rolls;
 }
 rows.push({Seed:seed,RepeatedBest:a,UniqueSix:b});
}
function metrics(a){a.sort((x,y)=>x-y);return{Reached:a.length,Mean:a.reduce((s,x)=>s+x,0)/a.length,Median:a[Math.ceil(a.length*.5)-1],P90:a[Math.ceil(a.length*.9)-1]}}
const table=weights.map((_,i)=>({Tier:i+1,RepeatedBest:metrics(rows.map(x=>x.RepeatedBest[i]).filter(Number.isFinite)),UniqueSix:metrics(rows.map(x=>x.UniqueSix[i]).filter(Number.isFinite))}));
fs.writeFileSync(__dirname+'/fill-audit.json',JSON.stringify({Seeds:seeds,MaxRolls:5000000,Method:'Tier-focused greedy best remaining; each of six plots must reach the stated floor-average tier; starters unlimited at Common. No time/currency or growth model in this roll-count audit.',Table:table,Rows:rows},null,2));console.log(JSON.stringify(table));
