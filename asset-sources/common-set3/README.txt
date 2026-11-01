BUILD A TREE - Common set 3: FibrousRoot, KnottedRoot, CherryFruit, OrangeFruit
Formats: .obj + .mtl and .glb. 1 unit = 1 stud, Y up. Flat colors, no textures.

ROOTS  pivot (0,0,0) beneath the crown. Root tips sit at y~0, crown top (flat trunk join,
       1.5 studs across) at y=0.6. Place the trunk base at (0, 0.6, 0).
FRUIT  body centered at (0,0,0). Stems/leaves extend upward.

RECOLOR GROUPS (each imports as its own MeshPart)
  FibrousRoot  FibrousCrown, FibrousRoots, FibrousTips
  KnottedRoot  KnottedBase, KnottedRoots, KnottedKnots
  CherryFruit  CherryBody, CherryStem, CherryLeaf
  OrangeFruit  OrangeBody, OrangeStem, OrangeLeaf
Mutations: set Color/Material per group in Luau. If Studio ignores .mtl colors, that is expected.

TRIANGLES  Fibrous 312 | Knotted 496 | Cherry 428 | Orange 272
