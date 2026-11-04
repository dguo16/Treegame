from pathlib import Path
import numpy as np
from scipy.spatial import ConvexHull
import json, struct, math
OUT=Path(__file__).resolve().parent
PALETTE={}
ASSETS={}
def mat(n,c):
 PALETTE[n]=c;return n

def mesh(v,f):
 v=np.array(v,float);f=np.array(f,int)
 vol=np.einsum('ij,ij->i',v[f[:,0]],np.cross(v[f[:,1]],v[f[:,2]])).sum()
 if vol<0:f=f[:,::-1]
 return v,f

def combine(ms):
 vs=[];fs=[];off=0
 for v,f in ms:vs.append(v);fs.append(f+off);off+=len(v)
 return np.vstack(vs),np.vstack(fs)

def move(m,p):return m[0]+p,m[1]

def blob(p,scale,sub=1):
 t=(1+5**.5)/2
 v=np.array([[-1,t,0],[1,t,0],[-1,-t,0],[1,-t,0],[0,-1,t],[0,1,t],[0,-1,-t],[0,1,-t],[t,0,-1],[t,0,1],[-t,0,-1],[-t,0,1]],float)
 v/=np.linalg.norm(v,axis=1)[:,None]
 for _ in range(sub):
  hull=ConvexHull(v);edges=set()
  for a,b,c in hull.simplices:edges.update([tuple(sorted(e)) for e in [(a,b),(b,c),(c,a)]])
  new=np.array([(v[a]+v[b])/np.linalg.norm(v[a]+v[b]) for a,b in sorted(edges)])
  v=np.vstack([v,new])
 f=ConvexHull(v).simplices
 for i,(a,b,c) in enumerate(f):
  if np.dot(np.cross(v[b]-v[a],v[c]-v[a]),v[[a,b,c]].mean(0))<0:f[i]=[a,c,b]
 return np.array(p)+v*np.array(scale),f

def tube(points,radii,n=8,horizontal=False):
 ps=np.array(points,float);v=[];f=[]
 for k,(p,r) in enumerate(zip(ps,radii)):
  if horizontal:u=np.array([1.,0,0]);w=np.array([0.,0,-1])
  else:
   d=ps[min(k+1,len(ps)-1)]-ps[max(0,k-1)];d/=np.linalg.norm(d)
   ref=np.array([0.,0,1]) if abs(d[2])<.9 else np.array([1.,0,0])
   u=np.cross(d,ref);u/=np.linalg.norm(u);w=np.cross(d,u)
  for j in range(n):
   a=j*2*np.pi/n;v.append(p+r*(u*np.cos(a)+w*np.sin(a)))
 for k in range(len(ps)-1):
  for j in range(n):
   a=k*n+j;b=k*n+(j+1)%n;c=b+n;d=a+n;f.extend([[a,b,c],[a,c,d]])
 v.extend([ps[0],ps[-1]]);b=len(v)-2;t=b+1
 for j in range(n):f.extend([[b,(j+1)%n,j],[t,(len(ps)-1)*n+j,(len(ps)-1)*n+(j+1)%n]])
 return mesh(v,f)

def leaf(p,q,width,kind='oval',thick=.06,normal_hint=None):
 p=np.array(p,float);q=np.array(q,float);d=q-p;L=np.linalg.norm(d);d/=L
 side=np.cross(d,[0,0,1.] if normal_hint is None else normal_hint);
 if np.linalg.norm(side)<.1:side=np.cross(d,[0,1.,0])
 side/=np.linalg.norm(side);normal=np.cross(side,d);normal/=np.linalg.norm(normal)
 # perimeter goes base -> right -> tip -> left, with a raised center ridge
 if kind=='ivy':poly=[(0,0),(.23,-.52),(.43,-.38),(.52,-1),(.72,-.61),(1,0),(.72,.61),(.52,1),(.43,.38),(.23,.52)]
 else:poly=[(0,0),(.18,-.6),(.46,-1),(.73,-.7),(1,0),(.73,.7),(.46,1),(.18,.6)]
 v=[p+d*(a*L)+side*(b*width) for a,b in poly]
 v.extend([p+d*(L*.47)+normal*thick,p+d*(L*.47)-normal*thick*.65]);N=len(poly);f=[]
 for i in range(N):f.extend([[N,i,(i+1)%N],[N+1,(i+1)%N,i]])
 return mesh(v,f)

def export(name,groups):
 folder=OUT/ASSETS[name]['category'];folder.mkdir(exist_ok=True)
 obj=[f'# Y up; 1 unit = 1 stud; pivot at origin\nmtllib {name}.mtl'];mtl=[];off=1;ni=1
 gltf={'asset':{'version':'2.0','generator':'Build a Tree Uncommon procedural pack'},'scene':0,'scenes':[{'nodes':[]}],'nodes':[],'meshes':[],'materials':[],'buffers':[],'bufferViews':[],'accessors':[]};buf=bytearray()
 def acc(a,typ,component):
  a=np.ascontiguousarray(a);pad=(-len(buf))%4;buf.extend(b'\0'*pad);start=len(buf);buf.extend(a.tobytes());vi=len(gltf['bufferViews']);gltf['bufferViews'].append({'buffer':0,'byteOffset':start,'byteLength':a.nbytes});ai=len(gltf['accessors']);entry={'bufferView':vi,'componentType':component,'count':len(a),'type':typ}
  if typ=='VEC3':entry.update(min=a.min(0).tolist(),max=a.max(0).tolist())
  gltf['accessors'].append(entry);return ai
 for i,(m,(v,f)) in enumerate(groups.items()):
  rgb=PALETTE[m];obj.extend([f'o {name}_{m}',f'usemtl {m}']);obj.extend('v %.6f %.6f %.6f'%tuple(p) for p in v)
  n=np.cross(v[f[:,1]]-v[f[:,0]],v[f[:,2]]-v[f[:,0]]);n/=np.linalg.norm(n,axis=1)[:,None]
  obj.extend('vn %.6f %.6f %.6f'%tuple(p) for p in n)
  obj.extend('f '+' '.join(f'{a+off}//{j+ni}' for a in face) for j,face in enumerate(f));off+=len(v);ni+=len(f)
  mtl.append(f'newmtl {m}\nKd {rgb[0]} {rgb[1]} {rgb[2]}\nKa 0 0 0\nKs 0 0 0\nNs 1\nd 1\nillum 1\n')
  vv=v[f].reshape(-1,3).astype('<f4');nn=np.repeat(n,3,axis=0).astype('<f4');ix=np.arange(len(vv),dtype='<u4')
  pi=acc(vv,'VEC3',5126);na=acc(nn,'VEC3',5126);ia=acc(ix,'SCALAR',5125)
  # glTF baseColorFactor is linear; source palette is sRGB.
  linear=[c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4 for c in rgb]
  gltf['materials'].append({'name':m,'pbrMetallicRoughness':{'baseColorFactor':linear+[1],'metallicFactor':0,'roughnessFactor':1},'alphaMode':'OPAQUE','doubleSided':False})
  gltf['meshes'].append({'name':name+'_'+m,'primitives':[{'attributes':{'POSITION':pi,'NORMAL':na},'indices':ia,'material':i}]})
  gltf['nodes'].append({'name':name+'_'+m,'mesh':i});gltf['scenes'][0]['nodes'].append(i)
 (folder/(name+'.obj')).write_text('\n'.join(obj)+'\n');(folder/(name+'.mtl')).write_text('\n'.join(mtl))
 gltf['buffers']=[{'byteLength':len(buf)}];js=json.dumps(gltf,separators=(',',':')).encode();js+=b' '*((-len(js))%4);buf+=b'\0'*((-len(buf))%4)
 glb=struct.pack('<III',0x46546c67,2,12+8+len(js)+8+len(buf))+struct.pack('<II',len(js),0x4e4f534a)+js+struct.pack('<II',len(buf),0x004e4942)+buf
 (folder/(name+'.glb')).write_bytes(glb)

def plot(ax,groups):
 from mpl_toolkits.mplot3d.art3d import Poly3DCollection
 pts=np.vstack([v for v,f in groups.values()]);light=np.array([-.35,.85,.45]);light/=np.linalg.norm(light)
 polys=[];colors=[]
 for m,(v,f) in groups.items():
  n=np.cross(v[f[:,1]]-v[f[:,0]],v[f[:,2]]-v[f[:,0]]);n/=np.linalg.norm(n,axis=1)[:,None];shade=.72+.28*np.maximum(0,n@light)
  cols=np.clip(np.array(PALETTE[m])[None,:]*shade[:,None],0,1)
  polys.extend(v[f][:,:,[0,2,1]]);colors.extend(cols)
 ax.add_collection3d(Poly3DCollection(polys,facecolors=colors,edgecolors='none',linewidth=0,zsort='average'))
 lo=pts.min(0);hi=pts.max(0);c=(lo+hi)/2;rad=max(hi-lo)*.55
 ax.set_xlim(c[0]-rad,c[0]+rad);ax.set_ylim(c[2]-rad,c[2]+rad);ax.set_zlim(c[1]-rad,c[1]+rad);ax.set_box_aspect((1,1,1));ax.view_init(elev=20,azim=-58);ax.set_proj_type('ortho');ax.axis('off')
