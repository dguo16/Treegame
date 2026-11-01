BUILD A TREE — UNCOMMON COLLECTION
12 modular assets / normal catalog versions

CONTENTS
Trunk: WillowTrunk, AspenTrunk, SilverBirchTrunk
Leaves: FernLeaves, IvyLeaves, PalmFanLeaves
Roots: VineRoots, MangroveRoot, CreepingRoot
Fruit: PearFruit, PeachFruit, LemonFruit

Each asset has GLB plus OBJ and matching MTL files. All triangles are
flat shaded. No textures, lights, cameras, ground, or mutation effects.
Named mesh/material groups allow independent recoloring.

UNITS AND CONNECTIONS
One exported coordinate unit = one intended game stud. Y is up.
All node transforms are identity; pivots are at the exported origin.
Trunks: base (0,0,0), canopy join (0,3,0), 1.5-wide base.
Branches stay below Y=3. Canopies: bottom connection/pivot (0,0,0),
3.4 x 2.8 x 3.4 bounds; flat solid undersides overlap trunk joins.
Roots: pivot (0,0,0), lowest surface Y=0, crown join at Y=0.60,
1.5-wide join, approximately 3.7-wide footprint. No downward taproots.
Fruit: pivot at the body bounding-box center, excluding stem/leaf.

ASSEMBLY EXAMPLE
Place trunk at (0,0,0), canopy at (0,3,0), roots at (0,-0.60,0).
For a tree resting on Y=0 instead, place roots at zero, trunk at
(0,0.60,0), and canopy at (0,3.60,0). A tiny overlap (0.01 to 0.03)
can conceal seams. These roots follow the NEW attached prompt's
above-pivot convention, not the older taproot convention.

IMPORT NOTES
Use GLB in compatible tools; OBJ is supplied as an alternative.
Keep each MTL beside its matching OBJ. Preserve the source origin,
Y-up orientation, named groups, and scale during conversion/import.
If an importer recenters geometry, restore the pivot from the coordinates
above. Do not independently center material submeshes.
OBJ Kd values are sRGB; GLB material factors use equivalent linear values.
Rendering appearance depends on your game's lighting and color management.
The exports have been structurally checked and previewed here; they have
not been imported into Roblox Studio in this environment.

DESIGN / REVISION 2
Foliage rebuilt as substantial tree crowns: Fern has layered rounded
foliage with small attached leaf tips; Ivy has a scalloped dome with
subtle drooping lobed leaves; Palm Fan has six broad arching fronds.
All crowns retain the 3.4 x 2.8 x 3.4 dimensions and centered bottom join.
Aspen now has a slim straight bole and a high, close fork. Silver Birch
has a bent thicker bole, two lower branch stubs, and broad charcoal bars.
Lemon stem removed; its small leaf attaches directly to the rind.
Willow, all roots, pear and peach exports are byte-for-byte unchanged.
All 18 combinations of the three canopies with the three common and
three uncommon trunks were rendered for inspection. See
compatibility_preview.png. Common trunks are not re-exported in this pack.
Pieces intersect intentionally to remain visually attached. They are
modular game meshes, not boolean-unioned 3D-printing solids. Bark marks
are thin attached polygon patches. All materials are opaque.
Golden/Rainbow/Void/Cosmic mutations are left to game code.

REBUILD
Run: python build_uncommon.py
Dependencies: Python 3, NumPy, SciPy, Matplotlib.
asset_manifest.json records exact bounds, triangle counts, and group names.
preview.png shows all 12 assets; assembled_preview.png shows three mixes.
