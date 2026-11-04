BUILD A TREE / EPIC COLLECTION
12 modular models. GLB + OBJ/MTL. Y-up. 1 unit = 1 intended game stud.

TRUNKS
AmethystSpiralTrunk: solid bole, continuous raised helical ridge, attached
amethyst chips, and turning branch arms.
VioletWillowTrunk: four high arched boughs with sturdy hanging ends and
raised grain strips; a full central trunk maintains the top connection.
RosewoodTwistTrunk: broad paired braided stems around a solid central bole,
swept side arms, and small wood knots.

CANOPIES
LavenderFanLeaves: six substantial pleated fans overlap into a full crown.
OrchidCloudLeaves: three scalloped cloud-like shelves with draping petal
tips and small golden flower centers.
VioletWingsLeaves: four broad swept, scalloped leaves with raised veins,
arching over a dense central crown.

ROOTS
CrystalRoot: three crystalline root fans with embedded prismatic clusters.
AmethystRoot: a low geode collar, three connecting spurs and inward gems.
OrchidTetherRoots: four pairs of braided roots ending in petal-shaped pads.

FRUIT
RoyalPlumFruit: elongated two-tone plum with a shallow seam and leaf sepals.
PomegranateFruit: ribbed red rind and a six-point natural calyx crown.
Passionfruit: one cut-open fruit with purple rind, pale pith, golden pulp,
and eight embedded dark seeds. All parts belong to the same fruit asset.

RARITY DIRECTION
Epic is tier four: Common, Uncommon, Rare, Epic, Legendary, Mythic, Godly.
The increased detail is structural: helices, braids, pleated crowns,
branching and open root forms. Colored flat materials support those shapes.
No textures, particles, transparent or floating effects, baked lighting,
lights, scenery, or pre-applied Golden/Rainbow/Void/Cosmic mutations.
Crystal decorations are embedded geometry in separate recolorable groups.

SHARED ASSEMBLY
At ground Y=0, use these origins for every rarity:
  Roots:  (0,0,0)
  Trunk:  (0,0.60,0)
  Leaves: (0,3.60,0)
Roots have a centered 1.5-stud crown join at local Y=.60.
Trunks have a centered 1.5-stud base and canopy join at local (0,3,0).
Branches stay below the trunk's top. All canopies have a solid flat bottom
connection at local Y=0. They are approximately 3.4 wide and 2.8 tall.
Fruit pivots are at the body center, excluding stems and other details.

assembly_contract.json lists all 48 assets across the four completed tiers.
Earlier models are metadata only; use meshes from their previously updated
packs. Four fruit sockets are provided on each canopy, with per-fruit
attachment offsets. Upright fruit origin = canopy origin + chosen socket
minus fruit_attach. These surface-based sockets are initial placement
points; check fruit clearance from adjacent foliage and branches in game.

IMPORT AND VALIDATION
Preserve Y-up, unit scale, complete-asset origins and named material groups.
Do not independently recenter a material submesh. Keep each MTL beside its
OBJ. GLB factors encode linear equivalents of the OBJ's sRGB palette.
Colors and shading depend on the game renderer and lighting.

All 12 exports pass the prompt's triangle budgets and checks of finite
coordinates, nonzero triangles, GLB indices/buffers and OBJ face counts.
The shared vertical join checks pass for all 1,728 root/trunk/crown choices
across four tiers. All 63 newly introduced trunk/crown pairings were rendered.
Roblox Studio import, runtime performance and collision clearance have not
been tested. Intentional intersecting components are used for game assets;
these are not boolean-unioned, print-ready solids.

PREVIEWS
preview.png: the full-color set of 12 assets.
assembled_preview.png: three epic-only example trees.
cross_tier_preview.png: six mixed-rarity trees.
epic_crown_compatibility.png: epic crowns on all twelve trunks.
epic_trunk_compatibility.png: epic trunks with all nine earlier crowns.
Previews use a depth-buffered software renderer to show actual overlapping
surfaces rather than painter-sorted approximations. Lighting is preview-only.

REBUILD
Python 3 with NumPy, SciPy and Matplotlib:
  python build_epic.py
  python validate_epic.py
This regenerates the epic exports and epic-only previews. Cross-tier preview
images were made using the earlier asset packs and are included separately.
