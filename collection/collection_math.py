"""Coupon collector expectations under disclosed base rarity/mutation weights.
No game assets are executed. IID odds omit pity and free starters; time is a roll-rate scenario.
"""
from pathlib import Path
import math,json
BASE=Path(__file__).parent
rarities=['Common','Uncommon','Rare','Epic','Legendary','Mythic','Godly']
weights=[60,25,10,4,.9,.09,.01]
mutations={'None':.8,'Golden':.12,'Rainbow':.05,'Void':.025,'Cosmic':.005}
lucks={'Base':1,'Pets':1.36,'LuckPass':2,'PetsAndLuckPass':2.72}
def expected(groups):
 # Poissonization: expected draws = integral of 1 - P(all coupons seen).
 # Integrating over log(time) avoids losing the 24-million-roll tail.
 maxmean=max(1/p for n,p in groups)
 lo=-25;hi=math.log(maxmean*100);steps=6000;dx=(hi-lo)/steps
 def f(x):
  t=math.exp(x);logcdf=0
  for n,p in groups:
   seen=-math.expm1(-p*t)
   if seen==0:return t
   logcdf+=n*math.log(seen)
  return -math.expm1(logcdf)*t
 return dx*(.5*f(lo)+math.fsum(f(lo+i*dx)for i in range(1,steps))+.5*f(hi))
rows=[]
def add(key,title,kind,tier=None,mutation=None,need=12,optional=False,groups=None):
 row={'Key':key,'Title':title,'Kind':kind,'Tier':tier,'Mutation':mutation,'Need':need,'Optional':optional,'ExpectedRolls':{}}
 for label,luck in lucks.items():
  total=weights[0]+sum(weights[1:])*luck;probs=[w*(1 if i==0 else luck)/total for i,w in enumerate(weights)]
  if groups=='CoreSlot':g=[(3,probs[i]/12)for i in range(4)];value=expected(g)
  elif groups=='FullSlot':g=[(3,p/12)for p in probs];value=expected(g)
  elif groups=='CoreNames':value=expected([(12,probs[i]/12)for i in range(4)])
  elif groups=='AllNames':value=expected([(12,p/12)for p in probs])
  elif groups=='LegendTier':value=expected([(12,probs[tier-1]*m/12)for m in mutations.values()])
  elif groups=='Legend':value=expected([(12,p*m/12)for p in probs for m in mutations.values()])
  elif kind=='AnyMutation':value=1/mutations[mutation]
  else:
   probability=probs[tier-1]*(mutations[mutation]if mutation else 1)
   value=sum(12/(12-i)for i in range(need))/probability
  row['ExpectedRolls'][label]=value
 row['MinimumHoursBase']=row['ExpectedRolls']['Base']*2.5/3600
 row['IllustrativeHoursAt15Seconds']=row['ExpectedRolls']['Base']*15/3600
 rows.append(row)
for i,name in enumerate(rarities,1):add('Names'+str(i),name+' names (12)','Names',tier=i,optional=i>4)
for slot in ['Trunk','Leaves','Roots','Fruit']:
 add('Slot'+slot,slot+' names Common–Epic (12)','CoreSlot',groups='CoreSlot')
 add('LegendSlot'+slot,slot+' all names (21)','FullSlot',need=21,optional=True,groups='FullSlot')
for mutation in ['Golden','Rainbow','Void','Cosmic']:add('Any'+mutation,'Any '+mutation,'AnyMutation',mutation=mutation,need=1)
for i,name in enumerate(rarities[:4],1):
 for mutation,need in [('Golden',6),('Rainbow',4),('Void',3),('Cosmic',1)]:add('Mutation'+str(i)+mutation,f'{name} {mutation} distinct names ({need}/12)','Mutation',tier=i,mutation=mutation,need=need)
add('CoreNames48','Common–Epic all names (48)','CoreNames',need=48,groups='CoreNames')
add('AllNames84','All names (84)','AllNames',need=84,optional=True,groups='AllNames')
for tier in range(5,8):add('Legend'+str(tier),rarities[tier-1]+' all mutation combinations (60)','LegendTier',tier=tier,need=60,optional=True,groups='LegendTier')
add('Legend420','All combinations (420)','Legend',need=420,optional=True,groups='Legend')
result={'Assumptions':{'RarityWeights':weights,'MutationProbabilities':mutations,'Luck':lucks,'Pets':'Three tier-1 Epic pets: 1+3*4*.03 = 1.36 rarity luck. Pets unchanged.','IID':True,'PityIncluded':False,'FreeStartersIncluded':False,'CooldownSeconds':2.5,'IllustrativeSecondsPerRoll':15},'Sets':rows}
(BASE/'collection-math.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
lines=['# Collection expectations','', 'IID expectations from empty sets; pity and starters excluded. Time at 2.5s/roll is a minimum; 15s/roll is illustrative, not a retention prediction.','', '| Set | Base rolls | Pets 1.36× | Pass 2× | Pets + pass 2.72× | Base min hours | Base hours at 15s/roll |','|---|---:|---:|---:|---:|---:|---:|']
for row in rows:lines.append('| '+row['Title']+(' · optional'if row['Optional']else'')+' | '+' | '.join(f"{row['ExpectedRolls'][k]:,.1f}"for k in lucks)+f" | {row['MinimumHoursBase']:,.2f} | {row['IllustrativeHoursAt15Seconds']:,.2f} |")
(BASE/'collection-expectations.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
print('\n'.join(lines[:12]+lines[-4:]))
assert abs(next(x for x in rows if x['Key']=='Names1')['ExpectedRolls']['Base']-sum(1/i for i in range(1,13))*20)<1e-10
