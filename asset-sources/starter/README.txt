BUILD A TREE - starter assets (OakTrunk, CloverLeaves, Taproot, Apple)
Formats: .obj + .mtl (Roblox Studio 3D Importer) and .glb. Units: 1 unit = 1 stud, Y up.

PIVOTS (place all at the same origin; no offsets needed except canopy):
  Taproot      top-center at (0,0,0), grows down to y=-2.2. Top ring r=0.8 matches trunk base.
  OakTrunk     bottom-center at (0,0,0), top at y=3.0.
  CloverLeaves bottom-center at (0,0,0). Position at (0, 3.0, 0) on top of the trunk.
  Apple        centered on body at (0,0,0). Body r~0.5, stem+leaf on top.

RECOLORING: each asset is split into one object per material so each becomes its own
MeshPart on import:
  OakTrunk: Bark | Taproot: Root | CloverLeaves: Foliage, FoliageLight
  Apple: AppleBody, AppleStem, AppleLeaf
Flat colors only, no textures. Set MeshPart.Color / Material in Luau for mutations
(Golden, Rainbow, Void, Cosmic). If Roblox ignores the .mtl colors on import, that is
expected: set Color in code. In Studio: untick "Import only as model" if you want separate parts.

Triangle counts: trunk 136, leaves 720, roots 176, apple 424.
