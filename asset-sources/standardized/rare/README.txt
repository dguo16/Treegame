BUILD A TREE / RARE COLLECTION
12 modular catalog assets. GLB + OBJ/MTL, Y-up, 1 unit = 1 stud.

Trunks: SapphireBirchTrunk, AzureCedarTrunk, CobaltPalmTrunk
Leaves: BlueMapleLeaves, FrostFernLeaves, AzureBlossomLeaves
Roots: CoralRoot, FrostRoot, AzureTangleRoots
Fruit: CrystalberryFruit, Hazelfruit, FrostberryFruit

DESIGN / SHAPE REVISION 2
Rare is the third tier in the seven-tier sequence:
Common, Uncommon, Rare, Epic, Legendary, Mythic, Godly.
This revision distinguishes rare through structural silhouettes and
restrained attached accents, leaving room for stronger fantasy forms later.

Sapphire Birch: a twisted solid bole framed by two inward-hooked arms.
Azure Cedar: three pairs of stepped, lifted boughs tapering up the trunk.
Cobalt Palm: pronounced S-bend, narrow waist and expanded upper collar.
Blue Maple: a sculpted five-lobed crown with large pointed leaf shoulders.
Frost Fern: three tiers of broad serrated fronds cascading from a solid core.
Azure Blossom: large volumetric flower rosettes form the canopy itself.
Coral Root: three branching fans, each splitting into rounded fingers.
Frost Root: four angular flattened fins with embedded small ice crystals.
Azure Tangle: three open root loops visibly joined to the central crown.

All nine trunks/crowns/roots have been rebuilt in geometry. Colors are
supporting details, not the basis of their rarity. Fruit exports remain
byte-for-byte unchanged from the previous rare revision.
Opaque flat materials; no particles, transparency, lights, textures,
baked lighting, or mutation effects. All decorations stay attached.

UNIVERSAL CONNECTIONS
At ground Y=0: root origin (0,0,0), trunk origin (0,0.60,0),
canopy origin (0,3.60,0). Root crown at local Y=.60, 1.5-wide join.
Trunks: base at (0,0,0), centered canopy join at (0,3,0).
All branch tips remain below the canopy connection.
Canopies: flat solid underside at local Y=0, centered over X=Z=0;
roughly 3.4-wide footprint by 2.8 tall. Source origins are preserved,
including for slightly asymmetric silhouettes. Tiny seam overlaps may
be applied in game if desired. Fruit pivots are centered on their bodies.

assembly_contract.json extends the previous contract to all 36 assets:
nine roots, nine trunks, nine crowns, nine fruits. Older assets are listed
as metadata only; their models remain in their original updated packs.
The JSON includes four surface-based fruit sockets per crown and each
fruit's attachment offset. Upright fruit origin = canopy origin + socket
minus fruit_attach. These are starting attachment locations; check fruit
clearance against nearby foliage and branches in your game.

IMPORT
Keep MTL beside matching OBJ. Preserve mesh origins, orientation, scale,
and material groups during import or conversion. Each named group can be
recolored independently. Do not recenter individual material submeshes.
GLB color factors are linear equivalents of the OBJ sRGB palette.
Rendering appearance will vary with the game's lighting and renderer.
Mutation colors and effects should be applied in game code.

VALIDATION
All 12 assets meet the prompt's triangle budgets. Coordinates, triangle
areas, normals' source geometry, GLB indices/buffers, OBJ face counts and
opaque materials were checked. The 729 root/trunk/crown combinations across
all three tiers pass vertical connection checks. All 45 new trunk/crown
pairings were rendered. Root footprint and join conventions match the
previous updated packs. Roblox Studio import, runtime performance, and
collision clearance have not been tested here.
Geometry components intentionally intersect; meshes are not boolean-unioned
3D-printing solids. Bark marks are thin attached surface polygons.

PREVIEWS
silhouette_preview.png: nine redesigned parts without rarity colors.
preview.png: all 12 rare assets.
assembled_preview.png: three rare trees.
cross_tier_preview.png: six mixed-rarity examples.
rare_crown_compatibility.png: rare crowns on all nine trunks.
rare_trunk_compatibility.png: rare trunks with six earlier crowns.

REBUILD
Python 3 with NumPy, SciPy, Matplotlib:
  python build_rare.py
  python validate_rare.py
Rebuild regenerates rare models, manifests, and rare-only previews.
Cross-tier preview images were produced using the earlier model packs.
