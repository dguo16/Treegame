BUILD A TREE / COMMON MODULAR REVISION

These models use the same assembly coordinates as the revised uncommon pack.
One coordinate unit = one stud. Y-up. Materials are opaque flat colors.
Each asset has GLB and OBJ + MTL; keep the MTL beside its OBJ.

ASSEMBLY AT GROUND Y=0
Any root: origin (0,0,0). Root crown join (0,0.60,0), 1.5 studs across.
Any trunk: origin (0,0.60,0). Base is 1.5 studs across; centered top
connection is 3 studs above its own origin (world Y=3.60).
Any foliage: origin (0,3.60,0). Flat underside centered at its origin;
roughly 3.4 wide by 2.8 tall. Any crown can use any trunk.
Geometry intersections are intentional. Keep source pivots when importing.
If your importer recenters meshes, restore the source origin for the entire
asset; do not recenter its individual material groups.

FRUIT
All fruit body centers are at local (0,0,0). Common fruit bodies are
normalized to one stud across their largest horizontal dimension.
assembly_contract.json includes the 24 common/uncommon asset definitions,
per-fruit attachment offsets, and four surface-tested sockets for each
canopy. For upright hanging fruit:
fruit origin = canopy origin + canopy socket - fruit attachment offset.
This lets any of the six fruit assets use any canopy. Sockets were ray-cast
against canopy surfaces; fruit/trunk collision testing has not been run.
The contract contains metadata for uncommon assets, not duplicate meshes.

CHANGES
Oak: central 3-stud top join, branches kept below it, 1.5-wide base.
Pine: same ridged silhouette and spiral stubs; standardized base/top widths.
Maple: original bark plates and side stubs; centered top above its fork.
Clover and Oakleaf: original crown forms, standardized size and flat join.
Sprout: rebuilt into a full three-lobed tree crown.
Taproot: reshaped as a shallow five-arm root base; no long downward spike.
Fibrous and Knotted: preserve designs; aligned ground/crown and footprint.
Apple, Cherry, Orange: body-center pivots and normalized size.
The existing uncommon models are unchanged by this revision.

VALIDATION
All 12 common exports checked for valid indices, finite vertices, nonzero
triangles, category bounds and GLB buffer integrity. All 216 combinations
of six roots, six trunks and six crowns pass vertical join checks.
All 36 trunk/crown pairings were rendered; see compatibility_preview.png.
Roblox Studio import and runtime performance have not been tested here.
A faint facet edge in a preview is a render artifact, not a texture.

SOURCE
source/ contains the shared rebuild source for all three common sets.
Run python source/rebuild_common.py with numpy, scipy and matplotlib.
It writes all three regenerated sets under source/. Preview images and
cross-pack assembly_contract.json are supplied separately.
No textures or baked lighting. Preserve named material groups for mutations.
