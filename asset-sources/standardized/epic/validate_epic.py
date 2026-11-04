"""Validate epic exports. Cross-tier checks additionally use earlier packs in the workspace."""
from pathlib import Path
import json,struct,sys,importlib.util
import numpy as np
import build_epic as R
ROOT=Path(__file__).resolve().parent
report=[]
for n,d in R.A.items():
 g=d['groups'];p=R.points(g);cat=d['category'];count=0
 for m,(v,f) in g.items():
  assert np.isfinite(v).all() and f.min()>=0 and f.max()<len(v)
  assert np.linalg.norm(np.cross(v[f[:,1]]-v[f[:,0]],v[f[:,2]]-v[f[:,0]]),axis=1).min()>1e-9
  count+=len(f)
 low,high={'Trunk':(300,800),'Leaves':(500,1200),'Roots':(200,600),'Fruit':(200,600)}[cat];assert low<=count<=high
 if cat=='Trunk':assert abs(p[:,1].min())<1e-8 and abs(p[:,1].max()-3)<1e-8
 if cat=='Roots':assert abs(p[:,1].min())<1e-8 and abs(p[:,1].max()-.6)<1e-8
 if cat=='Leaves':assert abs(p[:,1].min())<1e-8 and abs(p[:,1].max()-2.8)<1e-8
 if cat=='Fruit':
  m=next(m for m in g if 'Body' in m or 'Shell' in m or 'Skin' in m or 'Rind' in m);v,f=g[m];assert np.allclose(v.min(0)+v.max(0),0,atol=1e-6)
 raw=(ROOT/cat/(n+'.glb')).read_bytes();magic,version,size=struct.unpack_from('<III',raw);assert magic==0x46546c67 and version==2 and size==len(raw)
 sizej=struct.unpack_from('<I',raw,12)[0];gltf=json.loads(raw[20:20+sizej]);binary=raw[28+sizej:];total=0
 for mes in gltf['meshes']:
  for primitive in mes['primitives']:
   a=gltf['accessors'][primitive['indices']];view=gltf['bufferViews'][a['bufferView']];ix=np.frombuffer(binary,dtype='<u4',count=a['count'],offset=view['byteOffset']);assert ix.max()<gltf['accessors'][primitive['attributes']['POSITION']]['count'];total+=len(ix)//3
 assert total==count and 'textures' not in gltf
 assert all(m['alphaMode']=='OPAQUE' for m in gltf['materials'])
 obj=(ROOT/cat/(n+'.obj')).read_text();assert sum(l.startswith('f ') for l in obj.splitlines())==count
 report.append(f'{n}: {count} triangles; GLB/OBJ, bounds, finite vertices, and nonzero faces verified.')
# Add new definitions to the prior assembly contract, retaining prior asset identities.
prior=ROOT.parent/'build_a_tree_rare/assembly_contract.json'
basepath=prior if prior.exists() else ROOT/'assembly_contract.json'
contract=json.loads(basepath.read_text()) if basepath.exists() else {'version':1,'up':'Y','unit':'stud','assets':[]}
contract['assets']=[d for d in contract['assets'] if d['name'] not in R.A]
for n,d in R.A.items():
 p=R.points(d['groups']);cat=d['category'];joins={}
 if cat=='Roots':joins['root_to_trunk']=[0,.6,0]
 if cat=='Trunk':joins['trunk_to_canopy']=[0,3,0]
 if cat=='Fruit':
  candidates=[(v,f) for m,(v,f) in d['groups'].items() if 'Stem' in m or 'Calyx' in m];v,f=candidates[0];joins['fruit_attach']=v[v[:,1]>=v[:,1].max()-.015].mean(0).round(6).tolist()
 if cat=='Leaves':
  tri=np.vstack([v[f] for v,f in d['groups'].values()]);sockets=[]
  for k in range(4):
   a=k*np.pi/2+.6
   for radius in [1.20,1.05,.90]:
    x,z=radius*np.cos(a),radius*np.sin(a);hits=[]
    for t in tri:
     q=t[:,[0,2]];M=np.column_stack([q[1]-q[0],q[2]-q[0]])
     if abs(np.linalg.det(M))<1e-10:continue
     u,v=np.linalg.solve(M,[x-q[0,0],z-q[0,1]])
     if u>=-1e-7 and v>=-1e-7 and u+v<=1+1e-7:hits.append(t[0,1]+u*(t[1,1]-t[0,1])+v*(t[2,1]-t[0,1]))
    if hits:break
   assert hits;sockets.append([round(x,6),round(min(hits),6),round(z,6)])
  joins['fruit_sockets']=sockets
 contract['assets'].append({'name':n,'rarity':'Epic','category':cat,'pivot':[0,0,0],'bounds_min':p.min(0).round(6).tolist(),'bounds_max':p.max(0).round(6).tolist(),'dimensions':np.ptp(p,axis=0).round(6).tolist(),'joins':joins,'materials':list(d['groups'])})
contract['version']=3;(ROOT/'assembly_contract.json').write_text(json.dumps(contract,indent=2))
# Structural join checks for all tiers (metadata from the verified previous packs).
roots=[d for d in contract['assets'] if d['category']=='Roots'];trunks=[d for d in contract['assets'] if d['category']=='Trunk'];leaves=[d for d in contract['assets'] if d['category']=='Leaves'];total=0
for r in roots:
 for t in trunks:
  for l in leaves:
   assert abs(r['bounds_max'][1]-.6)<1e-5 and abs(t['bounds_min'][1])<1e-5 and abs(t['bounds_max'][1]-3)<1e-5 and abs(l['bounds_min'][1])<1e-5;total+=1
report.append(f'{total} cross-tier root/trunk/crown combinations pass vertical join checks.')
report.append('Fruit sockets are ray-cast to canopy surfaces; collision and Roblox Studio import tests were not run.')
(ROOT/'validation.txt').write_text('\n'.join(report)+'\n');print('\n'.join(report))
