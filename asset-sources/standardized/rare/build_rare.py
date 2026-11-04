"""Build a Tree Rare: Y-up, 1 unit = 1 stud. Python + NumPy + SciPy + Matplotlib."""
from pathlib import Path
import json, math
import numpy as np
import mesh_tools as B
from mesh_tools import tube,blob,leaf,combine,mesh
OUT=Path(__file__).resolve().parent
A={}
def color(name,rgb):B.PALETTE[name]=rgb;return name
def add(n,c,g):A[n]={'category':c,'groups':g}
def points(g):return np.vstack([v for v,f in g.values()])
def crown(g):
 # Keep the actual connection at X=Z=0; do not recenter asymmetric bounding boxes.
 p=points(g);scale=np.array([1.7/abs(p[:,0]).max(),2.8/p[:,1].max(),1.7/abs(p[:,2]).max()])
 return {m:(v*scale,f) for m,(v,f) in g.items()}
def join():return tube([(0,0,0),(0,.28,0),(0,.70,0)],[.46,.73,.79],12,True)
def crystal(base,direction,length=.25,width=.10,n=5):
 d=np.array(direction,float);d/=np.linalg.norm(d);p=np.array(base,float)
 ref=np.array([0.,1,0]) if abs(d[1])<.85 else np.array([0.,0,1]);u=np.cross(d,ref);u/=np.linalg.norm(u);w=np.cross(d,u)
 verts=[];faces=[]
 for distance,r in [(-.08,width*.65),(length*.55,width)]:
  for j in range(n):
   a=2*np.pi*j/n;verts.append(p+d*distance+r*(np.cos(a)*u+np.sin(a)*w))
 verts.extend([p+d*length,p-d*.08]);tip=2*n;bottom=tip+1
 for j in range(n):
  k=(j+1)%n;faces.extend([[j,k,k+n],[j,k+n,j+n],[j+n,k+n,tip],[bottom,k,j]])
 return mesh(verts,faces)
def marks(ps,rs,rows,sides=14):
 result=[];ys=[p[1] for p in ps];step=2*np.pi/sides
 for y,a,span,h in rows:
  angles=[a-span/2]+[i*step for i in range(-20,60) if a-span/2<i*step<a+span/2]+[a+span/2];v=[];f=[]
  for yy in [y-h/2,y+h/2]:
   rr=np.interp(yy,ys,rs)+.006;cx=np.interp(yy,ys,[p[0] for p in ps]);cz=np.interp(yy,ys,[p[2] for p in ps])
   for aa in angles:
    sector=(aa%(2*np.pi))/step;i=int(sector);t=sector%1;v.append([cx+rr*((1-t)*np.cos(i*step)+t*np.cos((i+1)*step)),yy,cz-rr*((1-t)*np.sin(i*step)+t*np.sin((i+1)*step))])
  N=len(angles)
  for j in range(N-1):f.extend([[j,j+1,j+1+N],[j,j+1+N,j+N]])
  v=np.array(v);f=np.array(f)
  for i,face in enumerate(f):
   q=v[face];center=q.mean(0);cx=np.interp(center[1],ys,[p[0] for p in ps]);cz=np.interp(center[1],ys,[p[2] for p in ps])
   if np.dot(np.cross(q[1]-q[0],q[2]-q[0]),center-[cx,center[1],cz])<0:f[i]=face[::-1]
  result.append((v,f))
 return combine(result)
# RARE SHAPE REVISION: unique structure before color or ornament.
def ring_body(centers,radii,n=16,turns=None):
 v=[];f=[]
 for k,(c,r) in enumerate(zip(centers,radii)):
  turn=0 if turns is None else turns[k]
  for j in range(n):
   a=2*np.pi*j/n+turn;v.append(np.array(c)+[r*np.cos(a),0,-r*np.sin(a)])
 for k in range(len(centers)-1):
  for j in range(n):
   a=k*n+j;b=k*n+(j+1)%n;f.extend([[a,b,b+n],[a,b+n,a+n]])
 v.extend([centers[0],centers[-1]])
 for j in range(n):f.extend([[len(v)-2,(j+1)%n,j],[len(v)-1,(len(centers)-1)*n+j,(len(centers)-1)*n+(j+1)%n]])
 return mesh(v,f)
# Sapphire Birch: a solid twisted bole framed by two swept, inward-hooked arms.
bark=color('SapphireBirchBark',(.64,.79,.87));band=color('SapphireBarkBands',(.19,.34,.52));gem=color('SapphireCrystals',(.17,.49,.85))
ps=[(0,0,0),(-.06,.35,0),(-.12,.95,.02),(.03,1.55,0),(.12,2.13,0),(0,2.65,0),(0,3,0)];rs=[.75,.63,.44,.35,.38,.34,.32]
main=[ring_body(ps,rs,12,[0,.06,.14,.22,.29,.34,.34])]
for sign in [-1,1]:
 main.append(tube([(sign*.25,.65,0),(sign*.73,1.16,.02),(sign*1.12,1.82,.04),(sign*1.09,2.38,.02),(sign*.79,2.75,0)],[.30,.24,.20,.15,.095],8))
# Thick curling strips anchored into the lower swept arms.
peels=[];gems=[]
for sign in [-1,1]:
 peels.append(tube([(sign*.40,.84,-.13),(sign*.69,1.25,-.19),(sign*.61,1.54,-.18)],[.12,.10,.045],6))
 gems.append(crystal((sign*.88,1.61,-.10),(sign*.6,.4,-.4),.23,.10))
 gems.append(crystal((sign*.49,.83,-.25),(sign*.4,.4,-.7),.16,.07))
add('SapphireBirchTrunk','Trunk',{bark:combine(main),band:combine(peels),gem:combine(gems)})
# Azure Cedar: six flattened stepped boughs, widest low down, tapering upward.
bark=color('AzureCedarBark',(.24,.39,.48));edge=color('CedarBranchShelves',(.36,.53,.60));ridge=color('CedarBarkRidges',(.18,.31,.40))
ps=[(0,0,0),(0,.26,0),(0,.76,0),(0,1.45,0),(0,2.25,0),(0,3,0)];rs=[.75,.66,.50,.43,.36,.32]
main=ring_body(ps,rs,12,[0,0,.04,.04,.04,.04]);limbs=[]
for row,(y,reach) in enumerate([(.93,1.37),(1.63,1.13),(2.31,.84)]):
 for sign in [-1,1]:
  z=(row-1)*.13
  v,f=tube([(sign*.25,y,z),(sign*(reach-.25),y+.04,z),(sign*reach,y+.27,z)],[.25-.03*row,.20-.03*row,.095],8)
  # A broad shelf section with a blunt, lifted end is visible in silhouette.
  limbs.append((v,f))
buttresses=[]
for a in [.5,2.6,4.6]:
 d=np.array([np.cos(a),0,np.sin(a)]);buttresses.append(tube([d*.64+[0,.15,0],d*.44+[0,.78,0],d*.35+[0,1.42,0]],[.13,.095,.025],6))
add('AzureCedarTrunk','Trunk',{bark:main,edge:combine(limbs),ridge:combine(buttresses)})
# Cobalt Palm: pronounced S-bend and a flared upper collar; no generic side stubs.
bark=color('CobaltPalmBark',(.23,.36,.64));ring=color('PalmGrowthRings',(.39,.57,.80))
ps=[(0,0,0),(-.12,.22,0),(-.41,.62,0),(-.57,1.05,0),(-.43,1.47,0),(-.13,1.88,0),(.18,2.19,0),(.23,2.42,0),(.10,2.68,0),(0,3,0)]
rs=[.75,.67,.46,.34,.30,.31,.39,.59,.49,.32]
main=ring_body(ps,rs,12);bands=[]
for y in [.36,.71,1.12,1.56,1.96,2.43,2.66]:
 x=np.interp(y,[p[1] for p in ps],[p[0] for p in ps]);r=np.interp(y,[p[1] for p in ps],rs)
 bands.append(tube([(x,y-.025,0),(x,y,0),(x,y+.025,0)],[r,r+.025,r],8,True))
add('CobaltPalmTrunk','Trunk',{bark:main,ring:combine(bands)})
# Blue Maple: one sculpted five-lobed crown with pointed shoulders and a central dome.
base=color('BlueMapleFoliage',(.18,.40,.67));light=color('BlueMapleCrown',(.30,.59,.83));edge=color('BlueMapleLeafTips',(.24,.50,.76))
v=[];f=[];N=30
profile=[(0,.46,0),(.30,.76,.04),(.72,1.15,.28),(1.20,1.32,.38),(1.62,1.29,.36),(2.04,1.11,.25),(2.48,.72,.13),(2.67,.35,.04)]
for y,r,amplitude in profile:
 for j in range(N):
  a=2*np.pi*j/N;rr=r+amplitude*np.cos(5*a);v.append([rr*np.cos(a),y,rr*np.sin(a)])
for k in range(len(profile)-1):
 for j in range(N):
  a=k*N+j;b=k*N+(j+1)%N;f.extend([[a,b,b+N],[a,b+N,a+N]])
v.extend([[0,0,0],[0,2.67,0]])
for j in range(N):f.extend([[len(v)-2,(j+1)%N,j],[len(v)-1,(len(profile)-1)*N+j,(len(profile)-1)*N+(j+1)%N]])
v,f=mesh(v,f);centers=v[f].mean(1);mask=centers[:,1]>1.58;tips=[]
for k in range(5):
 a=k*2*np.pi/5;d=np.array([np.cos(a),0,np.sin(a)])
 tips.append(leaf(d*.78+[0,1.65,0],d*1.80+[0,.88,0],.51,'ivy',.18,normal_hint=d+[0,.6,0]))
add('BlueMapleLeaves','Leaves',crown({base:(v,f[~mask]),light:(v,f[mask]),edge:combine(tips)}))
# Frost Fern: broad serrated fronds cascade in three visibly separate tiers.
base=color('FrostFernFoliage',(.29,.57,.65));light=color('FrostFernNewGrowth',(.48,.76,.81));frost=color('FernFrostTips',(.77,.91,.93))
def fern_frond(p,q,width):
 p=np.array(p,float);q=np.array(q,float);axis=q-p;L=np.linalg.norm(axis);axis/=L
 side=np.cross(axis,[0,1,0]);side/=np.linalg.norm(side);normal=np.cross(side,axis)
 if normal[1]<0:normal=-normal
 outline=[(0,0),(.15,-.50),(.30,-.35),(.39,-.95),(.52,-.62),(.62,-1),(.72,-.55),(.83,-.72),(1,0),(.83,.72),(.72,.55),(.62,1),(.52,.62),(.39,.95),(.30,.35),(.15,.50)]
 v=[p+axis*(a*L)+side*b*width for a,b in outline];v.extend([p+axis*(L*.53)+normal*.18,p+axis*(L*.53)-normal*.10]);N=len(outline);f=[]
 for i in range(N):f.extend([[N,i,(i+1)%N],[N+1,(i+1)%N,i]])
 return mesh(v,f)
core=tube([(0,0,0),(0,.42,0),(0,1.2,0),(0,1.95,0),(0,2.57,0)],[.46,.88,.72,.43,.09],12,True)
lower=[];upper=[];ice=[]
for level,(count,y,reach,width) in enumerate([(7,1.10,1.73,.63),(6,1.85,1.25,.54),(4,2.55,.72,.40)]):
 for k in range(count):
  a=k*2*np.pi/count+level*.35;d=np.array([np.cos(a),0,np.sin(a)])
  p=d*.25+[0,y,0];q=d*reach+[0,y-.35,0]
  (lower if level==0 else upper).append(fern_frond(p,q,width))
  if k%2==0:ice.append(leaf(d*(reach*.70)+[0,y-.25,0],q+[0,.02,0],width*.24,thick=.04,normal_hint=d+[0,1,0]))
add('FrostFernLeaves','Leaves',crown({base:combine([core]+lower),light:combine(upper),frost:combine(ice)}))
# Azure Blossom: the crown is formed by large three-dimensional rosettes.
base=color('AzureBlossomFoliage',(.17,.44,.51));petal=color('AzurePetals',(.43,.64,.85));petal2=color('AzurePetalEdges',(.56,.73,.91));heart=color('BlossomCenters',(.76,.85,.97))
core=[join(),blob((0,.72,0),(.85,.65,.85),1),blob((0,1.24,0),(.66,.60,.66),1)];petals=[];outer=[];hearts=[]
for idx,(a,y,r) in enumerate([(0,.98,.74),(2*np.pi/3,.98,.74),(4*np.pi/3,.98,.74),(0,2.02,0)]):
 normal=np.array([np.cos(a)*.75,.75,np.sin(a)*.75]) if r else np.array([0.,1,0]);normal/=np.linalg.norm(normal)
 side=np.array([-np.sin(a),0,np.cos(a)]);up=np.cross(normal,side);c=np.array([r*np.cos(a),y,r*np.sin(a)])
 for k in range(5):
  t=k*2*np.pi/5;axis=side*np.cos(t)+up*np.sin(t);tangent=np.cross(normal,axis)
  v,f=blob((0,0,0),(1,1,1),1 if idx==3 else 0)
  v=c+axis*.37+v[:,0,None]*axis*.61+v[:,1,None]*tangent*.39+v[:,2,None]*normal*.34
  (petals if k%2 else outer).append((v,f))
 hearts.append(blob(c+normal*.22,(.28,.25,.28),0))
add('AzureBlossomLeaves','Leaves',crown({base:combine(core),petal:combine(petals),petal2:combine(outer),heart:combine(hearts)}))
# Roots: coral fans, angular ice fins, and an open loop network.
def root_join():return tube([(0,0,0),(0,.25,0),(0,.60,0)],[.60,.88,.75],12,True)
def fit_roots(g):
 p=points(g);low=p[:,1].min();sy=.6/(p[:,1].max()-low);scale=3.7/max(np.ptp(p,axis=0)[[0,2]])
 for m,(v,f) in g.items():
  r=np.linalg.norm(v[:,[0,2]],axis=1);blend=np.clip((r-.75)/.8,0,1);v[:,[0,2]]*=(1+(scale-1)*blend)[:,None];v[:,1]=(v[:,1]-low)*sy
 return g
main=color('CoralRootBody',(.71,.39,.38));tip=color('CoralRootTips',(.88,.58,.52));roots=[root_join()];ends=[]
for k in range(3):
 a=k*2*np.pi/3+.35;d=np.array([np.cos(a),0,np.sin(a)]);side=np.array([-np.sin(a),0,np.cos(a)])
 roots.append(tube([d*.5+[0,.29,0],d*.95+[0,.35,0],d*1.30+[0,.24,0]],[.24,.22,.17],7))
 for sign in [-1,1]:
  q=d*1.72+side*sign*.49+[0,.10,0]
  roots.append(tube([d*1.03+[0,.30,0],d*1.43+side*sign*.29+[0,.28,0],q],[.17,.14,.08],6))
  ends.append(blob(q,(.105,.09,.105),0))
add('CoralRoot','Roots',fit_roots({main:combine(roots),tip:combine(ends)}))
main=color('FrostRootBody',(.45,.65,.74));ice=color('FrostRootIce',(.74,.89,.94));gem=color('RootIceCrystals',(.39,.75,.90));roots=[root_join()];caps=[];gems=[]
for k in range(4):
 a=k*np.pi/2+.3;d=np.array([np.cos(a),0,np.sin(a)]);side=np.array([-np.sin(a),0,np.cos(a)])
 # Closed slab with angular shoulders, a shallow top ridge, and a blunt ground tip.
 outline=[(.45,-.22),(1.02,-.38),(1.28,-.23),(1.79,-.12),(1.94,0),(1.79,.12),(1.28,.23),(1.02,.38),(.45,.22)]
 v=[d*x+side*z+[0,.025,0] for x,z in outline];v +=[d*x+side*z+[0,.46-.20*(x-.45),0] for x,z in outline];N=len(outline);v.extend([d*1.04+[0,.02,0],d*1.04+[0,.44,0]]);f=[]
 for j in range(N):
  b=(j+1)%N;f.extend([[2*N,b,j],[2*N+1,N+j,N+b],[j,b,N+b],[j,N+b,N+j]])
 roots.append(mesh(v,f));gems.append(crystal(d*1.03+[0,.35,0],d*.3+[0,1,0],.19,.085))
 caps.append(tube([d*.77+[0,.43,0],d*1.47+[0,.28,0]],[.07,.025],5))
add('FrostRoot','Roots',fit_roots({main:combine(roots),ice:combine(caps),gem:combine(gems)}))
main=color('AzureTangleBody',(.22,.42,.59));light=color('AzureTangleStrands',(.36,.62,.74));roots=[root_join()];loops=[]
for k in range(3):
 a=k*2*np.pi/3+.2;d=np.array([np.cos(a),0,np.sin(a)]);side=np.array([-np.sin(a),0,np.cos(a)])
 ps=[]
 for j in range(13):
  t=j*2*np.pi/12;ps.append(d*(1.10+.68*np.cos(t))+side*(.46*np.sin(t))+[0,.17+.06*np.cos(2*t),0])
 loops.append(tube(ps,[.13]*len(ps),6))
add('AzureTangleRoots','Roots',fit_roots({main:combine(roots),light:combine(loops)}))
# FRUIT: body pivots centered; all stems short, all embellishments embedded.
body=color('CrystalberryBody',(.35,.36,.72));gems=color('CrystalberryCrystals',(.35,.71,.93));stem=color('CrystalberryStem',(.24,.36,.40));leaves=color('CrystalberryLeaf',(.21,.55,.56))
main=blob((0,0,0),(.50,.48,.50),2);cr=[]
for a,y in [(.3,.12),(1.8,-.05),(3.4,.18),(4.8,-.15),(5.6,.25)]:
 d=np.array([np.cos(a),y*1.4,np.sin(a)]);d/=np.linalg.norm(d);cr.append(crystal(d*.46,d,.14,.07))
add('CrystalberryFruit','Fruit',{body:main,gems:combine(cr),stem:tube([(0,.41,0),(.04,.64,0)],[.045,.03],7),leaves:leaf((.03,.54,0),(.30,.63,.05),.10,thick=.035)})
body=color('HazelfruitShell',(.66,.40,.23));husk=color('HazelfruitHusk',(.36,.52,.31));lip=color('HazelHuskEdges',(.55,.66,.38));stem=color('HazelfruitStem',(.40,.29,.18))
v,f=blob((0,0,0),(.50,.53,.50),2);v[:,0]*=1-.15*np.maximum(v[:,1],0);v[:,2]*=1-.15*np.maximum(v[:,1],0)
ls=[]
for k in range(6):
 a=k*2*np.pi/6;d=np.array([np.cos(a),0,np.sin(a)]);ls.append(leaf(d*.26+[0,-.42,0],d*.56+[0,.12,0],.21,'ivy',.19,normal_hint=d))
add('Hazelfruit','Fruit',{body:(v,f),husk:combine(ls),lip:blob((0,-.41,0),(.34,.13,.34),0),stem:tube([(0,.46,0),(.04,.65,0)],[.045,.028],7)})
body=color('FrostberryBody',(.33,.62,.80));cap=color('FrostberryBloom',(.78,.91,.96));stem=color('FrostberryStem',(.29,.43,.47));leafmat=color('FrostberryLeaf',(.46,.72,.76))
berries=[];caps=[]
for k in range(3):
 a=k*2*np.pi/3;d=np.array([np.cos(a),0,np.sin(a)]);c=d*.19
 berries.append(blob(c,(.34,.39,.34),1));caps.append(blob(c+[0,.285,0],(.23,.13,.23),0))
g={body:combine(berries),cap:combine(caps),stem:tube([(0,.27,0),(0,.54,0)],[.05,.03],7),leafmat:leaf((0,.46,0),(.27,.55,.04),.09,thick=.03)}
# center and size the grouped berry body, preserving attachment of all details
p=g[body][0];center=(p.min(0)+p.max(0))/2;scale=1/max(np.ptp(p,axis=0)[[0,2]])
g={m:((v-center)*scale,f) for m,(v,f) in g.items()};add('FrostberryFruit','Fruit',g)

def main():
 B.OUT=OUT;B.ASSETS=A;rows=[]
 for n,d in A.items():
  B.export(n,d['groups']);p=points(d['groups']);tri=sum(len(f) for v,f in d['groups'].values());rows.append({'name':n,'rarity':'Rare','category':d['category'],'triangles':tri,'pivot':[0,0,0],'bounds_min':p.min(0).round(6).tolist(),'bounds_max':p.max(0).round(6).tolist(),'dimensions':np.ptp(p,axis=0).round(6).tolist(),'materials':list(d['groups'])});print(n,tri,np.ptp(p,axis=0).round(3))
 (OUT/'asset_manifest.json').write_text(json.dumps({'up_axis':'Y','units':'stud','assets':rows},indent=2))
 previews()
def previews():
 import matplotlib;matplotlib.use('Agg')
 import matplotlib.pyplot as plt
 fig=plt.figure(figsize=(15,17),facecolor='#eef3f8');fig.suptitle('BUILD A TREE / RARE',fontsize=24,fontweight='bold',y=.976,color='#243a57');fig.text(.5,.95,'12 modular assets · embedded crystals · flat-color materials',ha='center',fontsize=12,color='#61738b')
 import re
 for i,(n,d) in enumerate(A.items()):
  ax=fig.add_subplot(4,3,i+1,projection='3d');ax.set_facecolor('#eef3f8');B.plot(ax,d['groups']);ax.set_title(re.sub(r'(?<=[a-z])(?=[A-Z])',' ',n),fontsize=14,fontweight='bold',color='#243a57',pad=-3)
  ax.text2D(.5,.01,str(sum(len(f) for v,f in d['groups'].values()))+' triangles',ha='center',transform=ax.transAxes,fontsize=10,color='#61738b')
 fig.subplots_adjust(top=.92,bottom=.02,left=.02,right=.98,hspace=.10,wspace=.01);fig.savefig(OUT/'preview.png',dpi=140);plt.close(fig)
 fig=plt.figure(figsize=(15,7),facecolor='#eef3f8');fig.suptitle('RARE / MIX & MATCH',fontsize=22,y=.97,color='#243a57')
 for i,(r,t,c) in enumerate([('FrostRoot','SapphireBirchTrunk','BlueMapleLeaves'),('CoralRoot','AzureCedarTrunk','AzureBlossomLeaves'),('AzureTangleRoots','CobaltPalmTrunk','FrostFernLeaves')]):
  g={}
  for n,offset in [(r,[0,0,0]),(t,[0,.6,0]),(c,[0,3.6,0])]:
   for m,(v,f) in A[n]['groups'].items():g[m]=(v+offset,f)
  ax=fig.add_subplot(1,3,i+1,projection='3d');ax.set_facecolor('#eef3f8');B.plot(ax,g);ax.set_title(t.replace('Trunk','')+' + '+c.replace('Leaves',''),fontsize=12,color='#243a57')
 fig.subplots_adjust(top=.87,bottom=0,left=0,right=1,wspace=0);fig.savefig(OUT/'assembled_preview.png',dpi=140);plt.close(fig)
if __name__=='__main__':main()
