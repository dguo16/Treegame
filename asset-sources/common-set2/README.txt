BUILD A TREE - Common set 2: PineTrunk, MapleTrunk, OakleafLeaves, SproutLeaves
Formats: .obj + .mtl and .glb. 1 unit = 1 stud, Y up. Flat colors, no textures.

TRUNKS  base-center (0,0,0), canopy connection (0,3,0). Place leaves at (0,3,0).
LEAVES  bottom-center pivot (0,0,0), flat solid underside that overlaps the trunk tip.

MATERIAL / RECOLOR GROUPS (each imports as its own MeshPart)
  PineTrunk      PineBark, PineStubs
  MapleTrunk     MapleBark, MapleLimbs, MaplePlates, MapleStubs
  OakleafLeaves  OakLobes, OakScallops, OakCrown, OakBase
  SproutLeaves   SproutLeaf, SproutVein, SproutHub
Mutations (Golden/Rainbow/Void/Cosmic): set Color/Material per group in Luau.
If Studio ignores .mtl colors on import, that is expected; colors are applied in code.

TRIANGLES  Pine 448 | Maple 492 | Oakleaf 520 | Sprout 1100
