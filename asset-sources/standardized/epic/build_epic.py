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

def root_join():return tube([(0,0,0),(0,.25,0),(0,.60,0)],[.60,.88,.75],12,True)

def fit_roots(g):
 p=points(g);low=p[:,1].min();sy=.6/(p[:,1].max()-low);scale=3.7/max(np.ptp(p,axis=0)[[0,2]])
 for m,(v,f) in g.items():
  r=np.linalg.norm(v[:,[0,2]],axis=1);blend=np.clip((r-.75)/.8,0,1);v[:,[0,2]]*=(1+(scale-1)*blend)[:,None];v[:,1]=(v[:,1]-low)*sy
 return g
# AMETHYST SPIRAL: a continuous crystalline helical ridge around a solid bole.
bark=color('AmethystBark',(.36,.24,.49));spiral=color('SpiralRidge',(.61,.40,.77));gems=color('EmbeddedAmethyst',(.77,.57,.91));wood=color('BranchCut',(.47,.32,.58))
ps=[(0,0,0),(0,.28,0),(0,.85,0),(0,1.55,0),(0,2.3,0),(0,3,0)];rs=[.75,.64,.52,.44,.36,.32];main=[ring_body(ps,rs,12)]
helix=[]
for j in range(21):
 y=.23+j*2.52/20;a=j*3.6*np.pi/20;r=np.interp(y,[p[1] for p in ps],rs)+.045;helix.append([r*np.cos(a),y,r*np.sin(a)])
ridge=tube(helix,[.15]*len(helix),6);gs=[]
for j in [3,8,13,18]:
 p=np.array(helix[j]);d=np.array([p[0],.4,p[2]]);gs.append(crystal(p,d,.22,.09))
for sign in [-1,1]:main.append(tube([(sign*.25,1.55,0),(sign*.72,1.85,.10*sign),(sign*1.08,2.31,.23*sign),(sign*.95,2.65,.27*sign)],[.23,.19,.14,.08],7))
add('AmethystSpiralTrunk','Trunk',{bark:combine(main),spiral:ridge,gems:combine(gs)})
# VIOLET WILLOW: high shoulder boughs arc outward and hang in sturdy curved hooks.
bark=color('VioletWillowBark',(.36,.29,.49));branches=color('WillowBoughs',(.48,.37,.62));vein=color('WillowRaisedGrain',(.64,.51,.73))
ps=[(0,0,0),(-.09,.32,0),(-.17,.95,.02),(-.12,1.62,0),(.04,2.30,0),(0,3,0)];rs=[.75,.62,.50,.41,.35,.32];boughs=[];ribs=[]
for k,a in enumerate([.10,np.pi+.10,1.65,4.75]):
 d=np.array([np.cos(a),0,np.sin(a)]);reach=1.35 if k<2 else 1.02
 boughs.append(tube([d*.13+[0,2.24,0],d*.56+[0,2.68,0],d*(reach*.87)+[0,2.55,0],d*reach+[0,2.08,0],d*(reach*.96)+[0,1.46,0]],[.26,.23,.18,.13,.075],7))
 ribs.append(tube([d*.35+[0,.4,0],d*.47+[0,.91,0],d*.35+[0,1.58,0],d*.28+[0,2.18,0]],[.07,.085,.06,.025],5))
add('VioletWillowTrunk','Trunk',{bark:ring_body(ps,rs,12),branches:combine(boughs),vein:combine(ribs)})
# ROSEWOOD TWIST: two broad interwoven stems frame a solid inner trunk and swept arms.
bark=color('RosewoodCore',(.38,.20,.30));rose=color('RosewoodBraid',(.64,.34,.45));light=color('RosewoodSecondBraid',(.76,.45,.54));cut=color('RosewoodKnots',(.81,.59,.60))
main=ring_body([(0,0,0),(0,.28,0),(0,1.0,0),(0,1.9,0),(0,2.67,0),(0,3,0)],[.75,.63,.31,.29,.33,.32],12)
braids=[]
for phase in [0,np.pi]:
 ps=[];rs=[]
 for j in range(12):
  y=.25+j*2.48/11;a=phase+j*2.4*np.pi/11;radius=.27*np.sin(np.pi*(.12+.76*j/11));ps.append([radius*np.cos(a),y,radius*np.sin(a)]);rs.append(.27 if j<9 else .23)
 braids.append(tube(ps,rs,7))
limbs=[]
for sign in [-1,1]:limbs.append(tube([(sign*.23,1.37,0),(sign*.82,1.67,-.09*sign),(sign*1.13,2.15,-.13*sign),(sign*.92,2.45,-.10*sign)],[.25,.21,.16,.085],7))
add('RosewoodTwistTrunk','Trunk',{bark:main,rose:combine([braids[0]]+limbs),light:braids[1],cut:combine([blob((.34,.72,-.28),(.16,.21,.11),0),blob((-.34,1.94,.15),(.15,.19,.12),0)])})
# LAVENDER FAN: broad shell-like pleated ginkgo fans overlap into a full crown.
base=color('LavenderUndergrowth',(.38,.31,.57));fan=color('LavenderFans',(.61,.50,.81));rim=color('LavenderFanEdges',(.77,.68,.91))
def fan_mesh(angle,y,reach,width,height):
 rad=np.array([np.cos(angle),0,np.sin(angle)]);side=np.array([-np.sin(angle),0,np.cos(angle)]);v=[];f=[];N=9
 for bottom in [False,True]:
  for row,t in enumerate([0,.42,.76,1]):
   for j in range(N):
    u=(j-4)/4;notch=(.10 if j%2 else 0)*t*t
    r=.12+reach*t*(1-.19*u*u);yy=y+height*np.sin(t*np.pi*.95)-.22*u*u-notch-(.13 if bottom else 0)
    v.append(rad*r+side*(u*width*np.sin(t*np.pi*.5)*(.93 if row==3 else 1))+[0,yy,0])
 # bottom row width must be nonzero to avoid degenerate triangles
 for offset in [0,4*N]:
  for j in range(N):v[offset+j]+=side*((j-4)*.015)
 M=4*N
 for row in range(3):
  for j in range(N-1):
   a=row*N+j;b=a+1;c=b+N;d=a+N;f.extend([[a,b,c],[a,c,d],[M+a,M+c,M+b],[M+a,M+d,M+c]])
 edge=list(range(N))+[i*N+N-1 for i in range(1,4)]+list(range(M-2,M-N-1,-1))+[i*N for i in range(2,0,-1)]
 for a,b in zip(edge,edge[1:]+edge[:1]):f.extend([[a,M+a,M+b],[a,M+b,b]])
 return mesh(v,f)
lo=[join(),blob((0,.65,0),(1.0,.63,1.0),1),blob((0,1.50,0),(.65,.65,.65),1)];fans=[];upper=[]
# Four large outer fans and two upper fans make six substantial sheets.
for k in range(4):fans.append(fan_mesh(k*np.pi/2+.3,.52,1.42,1.0,1.42))
for k in range(2):upper.append(fan_mesh(k*np.pi+1.1,1.32,.80,.80,1.13))
add('LavenderFanLeaves','Leaves',crown({base:combine(lo),fan:combine(fans),rim:combine(upper)}))
# ORCHID CLOUD: three overlapping soft scalloped shelves with draping petal tips.
base=color('OrchidCloudShade',(.50,.32,.60));cloud=color('OrchidCloudPetals',(.76,.54,.78));edge=color('OrchidCloudRims',(.91,.74,.88));heart=color('OrchidCenters',(.93,.76,.49))
def cloud_shelf(y,r,h,phase,lobes=5,N=20):
 v=[];f=[]
 for k,(t,rr) in enumerate([(0,.38),(.24,.80),(.52,1),(.79,.85),(1,.38)]):
  for j in range(N):
   a=2*np.pi*j/N;radius=r*rr*(1+.22*np.cos(lobes*a+phase));v.append([radius*np.cos(a),y+h*t+.04*np.sin(lobes*a+phase)*rr,radius*np.sin(a)])
 for k in range(4):
  for j in range(N):
   a=k*N+j;b=k*N+(j+1)%N;f.extend([[a,b,b+N],[a,b+N,a+N]])
 v.extend([[0,y,0],[0,y+h,0]])
 for j in range(N):f.extend([[len(v)-2,(j+1)%N,j],[len(v)-1,4*N+j,4*N+(j+1)%N]])
 return mesh(v,f)
shelves=[cloud_shelf(.16,1.50,1.13,.2),cloud_shelf(.89,1.22,1.06,1.4),cloud_shelf(1.62,.83,1.02,2.8)]
drapes=[];dots=[]
for k in range(5):
 a=k*2*np.pi/5+.4;d=np.array([np.cos(a),0,np.sin(a)]);drapes.append(leaf(d*1.24+[0,.83,0],d*1.37+[0,.25,0],.23,'ivy',.12,normal_hint=d));dots.append(blob(d*1.42+[0,.78,0],(.09,.09,.09),0))
add('OrchidCloudLeaves','Leaves',crown({base:join(),cloud:combine(shelves),edge:combine(drapes),heart:combine(dots)}))
# VIOLET WINGS: four broad swept and scalloped blades meet in a dense central crown.
base=color('VioletWingCore',(.33,.22,.53));wing=color('VioletWings',(.50,.35,.72));wing2=color('VioletWingEdges',(.71,.51,.86));vein=color('VioletWingVeins',(.83,.66,.91))
def wing_mesh(angle,scale=1):
 d=np.array([np.cos(angle),0,np.sin(angle)]);side=np.array([-np.sin(angle),0,np.cos(angle)]);v=[];f=[];N=7
 profile=[(.10,.48,.17),(.43,1.22,.63),(.92,2.03,.77),(1.39,1.60,.72),(1.70,.85,.20)]
 for bottom in [False,True]:
  for k,(r,y,w) in enumerate(profile):
   for j in range(N):
    u=(j-3)/3;drop=.25*u*u+(.12 if j%2==0 and k in [2,3] else 0);v.append(d*(r*scale)+side*(u*w)+[0,y-drop-(.16 if bottom else 0),0])
 M=len(profile)*N
 for k in range(4):
  for j in range(N-1):
   a=k*N+j;b=a+1;c=b+N;dd=a+N;f.extend([[a,b,c],[a,c,dd],[M+a,M+c,M+b],[M+a,M+dd,M+c]])
 e=list(range(N))+[k*N+N-1 for k in range(1,5)]+list(range(M-2,M-N-1,-1))+[k*N for k in range(3,0,-1)]
 for a,b in zip(e,e[1:]+e[:1]):f.extend([[a,M+a,M+b],[a,M+b,b]])
 return mesh(v,f)
wa=[];wb=[];veins=[]
for k in range(4):
 a=k*np.pi/2+.22;d=np.array([np.cos(a),0,np.sin(a)]);(wa if k%2 else wb).append(wing_mesh(a))
 veins.append(tube([d*.43+[0,1.22,0],d*.92+[0,2.03,0],d*1.39+[0,1.60,0]],[.055,.045,.015],5))
add('VioletWingsLeaves','Leaves',crown({base:combine([join(),blob((0,.70,0),(.90,.65,.90),1)]),wing:combine(wa),wing2:combine(wb),vein:combine(veins)}))
# CRYSTAL ROOT: three branching crystalline fans with embedded prismatic tips.
base=color('CrystalRootBark',(.45,.35,.58));prism=color('CrystalRootPrisms',(.72,.64,.88));tip=color('CrystalRootFacets',(.90,.82,.97));arms=[root_join()];gems=[];sm=[]
for k in range(3):
 a=k*2*np.pi/3+.2;d=np.array([np.cos(a),0,np.sin(a)]);side=np.array([-np.sin(a),0,np.cos(a)])
 arms.append(tube([d*.48+[0,.28,0],d*1.04+[0,.22,0],d*1.55+[0,.10,0]],[.26,.26,.16],7))
 for j in [-1,0,1]:
  p=d*(1.20 if j else 1.47)+side*j*.24+[0,.17,0];direction=d*.80+side*j*.40+[0,.45,0]
  gems.append(crystal(p,direction,.40 if j==0 else .32,.14,5));sm.append(crystal(p-d*.18+[0,.03,0],d*.2+[0,1,0],.18,.075,4))
add('CrystalRoot','Roots',fit_roots({base:combine(arms),prism:combine(gems),tip:combine(sm)}))
# AMETHYST ROOT: a low geode collar with attached inward gems and three ground spurs.
base=color('AmethystRootCore',(.38,.25,.52));outer=color('AmethystGeodeRim',(.57,.37,.72));gem=color('AmethystRootCrystals',(.78,.56,.90));v=[];f=[];N=12
for y,r in [(.055,1.58),(.35,1.60),(.30,1.18),(.055,1.15)]:
 for j in range(N):
  a=j*2*np.pi/N;v.append([r*np.cos(a),y+(.035*(j%2) if y>.1 else 0),r*np.sin(a)])
for k in range(4):
 for j in range(N):
  a=k*N+j;b=k*N+(j+1)%N;c=((k+1)%4)*N+(j+1)%N;d=((k+1)%4)*N+j;f.extend([[a,b,c],[a,c,d]])
connectors=[];gems=[]
for k in range(3):
 a=k*2*np.pi/3;d=np.array([np.cos(a),0,np.sin(a)]);connectors.append(tube([d*.55+[0,.23,0],d*1.20+[0,.18,0],d*1.84+[0,.06,0]],[.20,.18,.045],6))
for k in range(6):
 a=k*np.pi/3+.3;d=np.array([np.cos(a),0,np.sin(a)]);gems.append(crystal(d*1.32+[0,.28,0],-d*.35+[0,1,0],.20,.09))
add('AmethystRoot','Roots',fit_roots({base:combine([root_join()]+connectors),outer:mesh(v,f),gem:combine(gems)}))
# ORCHID TETHER: four paired, gently braided tethers terminate in petal-shaped pads.
base=color('OrchidTetherCrown',(.53,.31,.50));strand=color('OrchidTethers',(.75,.47,.68));light=color('OrchidTetherTwists',(.88,.65,.80));pad=color('OrchidRootPads',(.70,.42,.60));one=[];two=[];pads=[]
for k in range(4):
 a=k*np.pi/2+.35;d=np.array([np.cos(a),0,np.sin(a)]);side=np.array([-np.sin(a),0,np.cos(a)])
 for sign in [-1,1]:
  ps=[]
  for j,(r,y) in enumerate([(.52,.29),(.94,.28),(1.38,.19),(1.66,.105)]):ps.append(d*r+side*(.15*np.sin(j*np.pi*.8+sign*np.pi/2)) +[0,y+sign*.045*np.sin(j*2),0])
  (one if sign==1 else two).append(tube(ps,[.14,.125,.10,.07],5))
 v,f=blob((0,0,0),(.33,.09,.20),0);v=v[:,0,None]*d+v[:,2,None]*side+np.array([0,1,0])*v[:,1,None]+d*1.65+[0,.09,0];pads.append((v,f))
add('OrchidTetherRoots','Roots',fit_roots({base:root_join(),strand:combine(one),light:combine(two),pad:combine(pads)}))
# FRUIT: recognizable food shapes, with a modest epic level of sculptural detail.
body=color('RoyalPlumSkin',(.32,.18,.48));blush=color('RoyalPlumBlush',(.51,.26,.60));stem=color('RoyalPlumStem',(.39,.27,.29));leafmat=color('RoyalPlumSepals',(.53,.44,.64))
v,f=blob((0,0,0),(.49,.63,.49),2)
# Broad shallow seam on both sides rather than a painted stripe.
for p in v:
 p[0]*=1-.08*np.exp(-(p[2]/.09)**2)
mask=v[f].mean(1)[:,0]>.06;sepals=[]
for k in range(3):
 a=k*2*np.pi/3;d=np.array([np.cos(a),0,np.sin(a)]);sepals.append(leaf([0,.52,0],d*.26+[0,.64,0],.10,thick=.035))
add('RoyalPlumFruit','Fruit',{body:(v,f[~mask]),blush:(v,f[mask]),stem:tube([(0,.55,0),(.04,.80,0)],[.045,.03],7),leafmat:combine(sepals)})
body=color('PomegranateRind',(.70,.22,.35));crownmat=color('PomegranateCalyx',(.82,.42,.42));inner=color('PomegranateCrownInside',(.47,.18,.28))
v,f=blob((0,0,0),(.50,.50,.50),2)
for p in v:
 a=np.arctan2(p[2],p[0]);p[[0,2]]*=1+.035*np.cos(6*a)
calyx=[tube([(0,.41,0),(0,.61,0)],[.13,.17],8)];teeth=[]
for k in range(6):
 a=k*np.pi/3;d=np.array([np.cos(a),0,np.sin(a)]);teeth.append(leaf(d*.10+[0,.51,0],d*.23+[0,.76,0],.085,thick=.055,normal_hint=d))
add('PomegranateFruit','Fruit',{body:(v,f),crownmat:combine(calyx+teeth),inner:blob((0,.61,0),(.11,.045,.11),0)})
# Passionfruit is one cut-open fruit: purple rind, attached pulp and embedded seeds.
body=color('PassionfruitRind',(.37,.20,.50));pith=color('PassionfruitPith',(.93,.80,.57));pulp=color('PassionfruitPulp',(.95,.65,.22));seed=color('PassionfruitSeeds',(.24,.17,.25));stem=color('PassionfruitStem',(.37,.29,.31))
v0,f0=blob((0,0,0),(.50,.60,.45),1);verts=[];faces=[];boundary=[];plane=-.22
for face in f0:
 poly=[v0[i] for i in face];out=[]
 for a,b in zip(poly,poly[1:]+poly[:1]):
  ina=a[2]>=plane;inb=b[2]>=plane
  if ina:out.append(a)
  if ina!=inb:
   q=a+(b-a)*(plane-a[2])/(b[2]-a[2]);out.append(q);boundary.append(q)
 if len(out)>=3:
  start=len(verts);verts.extend(out)
  for j in range(1,len(out)-1):faces.append([start,start+j,start+j+1])
q=np.unique(np.round(boundary,9),axis=0);q=q[np.argsort(np.arctan2(q[:,1],q[:,0]))];start=len(verts);verts.extend(q);verts.append([0,0,plane]);c=len(verts)-1
for j in range(len(q)):faces.append([c,start+(j+1)%len(q),start+j])
rind=mesh(verts,faces)
# Pulp is slightly raised above the cut plane, wholly attached to the rind.
seeds=[]
for k in range(8):
 a=k*np.pi/4+.15;x=.23*np.cos(a);y=.32*np.sin(a);seeds.append(blob((x,y,-.265),(.045,.065,.025),0))
g={body:rind,pith:blob((0,0,-.224),(.414,.495,.025),1),pulp:blob((0,0,-.245),(.358,.443,.022),1),seed:combine(seeds),stem:tube([(0,.52,.03),(.03,.69,.02)],[.04,.027],6)}
p=g[body][0];offset=(p.min(0)+p.max(0))/2;g={m:(v-offset,f) for m,(v,f) in g.items()};add('Passionfruit','Fruit',g)

def main():
 B.OUT=OUT;B.ASSETS=A;rows=[]
 for n,d in A.items():
  B.export(n,d['groups']);p=points(d['groups']);tri=sum(len(f) for v,f in d['groups'].values());rows.append({'name':n,'rarity':'Epic','category':d['category'],'triangles':tri,'pivot':[0,0,0],'bounds_min':p.min(0).round(6).tolist(),'bounds_max':p.max(0).round(6).tolist(),'dimensions':np.ptp(p,axis=0).round(6).tolist(),'materials':list(d['groups'])});print(n,tri,np.ptp(p,axis=0).round(3))
 (OUT/'asset_manifest.json').write_text(json.dumps({'up_axis':'Y','units':'stud','assets':rows},indent=2));previews()
def previews():
 import matplotlib;matplotlib.use('Agg')
 import matplotlib.pyplot as plt
 import re
 fig=plt.figure(figsize=(15,17),facecolor='#f4f0f8');fig.suptitle('BUILD A TREE / EPIC',fontsize=24,fontweight='bold',y=.976,color='#49375f');fig.text(.5,.95,'Distinct sculpted forms · embedded details · shared modular connections',ha='center',fontsize=12,color='#7c6a91')
 for i,(n,d) in enumerate(A.items()):
  ax=fig.add_subplot(4,3,i+1);ax.set_facecolor('#f4f0f8');B.plot(ax,d['groups']);ax.set_title(re.sub(r'(?<=[a-z])(?=[A-Z])',' ',n),fontsize=14,fontweight='bold',color='#49375f',pad=5);ax.text(.5,.01,str(sum(len(f) for v,f in d['groups'].values()))+' triangles',ha='center',transform=ax.transAxes,fontsize=10,color='#7c6a91')
 fig.subplots_adjust(top=.92,bottom=.02,left=.02,right=.98,hspace=.1,wspace=.01);fig.savefig(OUT/'preview.png',dpi=140);plt.close(fig)
 fig=plt.figure(figsize=(15,7),facecolor='#f4f0f8');fig.suptitle('EPIC / MIX & MATCH',fontsize=22,y=.97,color='#49375f')
 for i,(r,t,c) in enumerate([('AmethystRoot','AmethystSpiralTrunk','LavenderFanLeaves'),('CrystalRoot','VioletWillowTrunk','OrchidCloudLeaves'),('OrchidTetherRoots','RosewoodTwistTrunk','VioletWingsLeaves')]):
  g={}
  for n,offset in [(r,[0,0,0]),(t,[0,.6,0]),(c,[0,3.6,0])]:
   for m,(v,f) in A[n]['groups'].items():g[m]=(v+offset,f)
  ax=fig.add_subplot(1,3,i+1);ax.set_facecolor('#f4f0f8');B.plot(ax,g);ax.set_title(t.replace('Trunk','')+' + '+c.replace('Leaves',''),fontsize=12,color='#49375f')
 fig.subplots_adjust(top=.87,bottom=0,left=0,right=1,wspace=0);fig.savefig(OUT/'assembled_preview.png',dpi=140);plt.close(fig)
if __name__=='__main__':main()
