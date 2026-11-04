# Build a Tree — current roll catalog

84 parts; three choices per slot in every rarity. Names remain independent of mutations.

| Rarity | Trunk | Leaves | Roots | Fruit |
|---|---|---|---|---|
| Common | Oak, Pine, Maple | Clover, Oakleaf, Sprout | Taproot, Fibrous Root, Knotted Root | Apple, Cherry, Orange |
| Uncommon | Willow, Aspen, Silver Birch | Fern, Ivy, Palm Fan | Vine, Mangrove Root, Creeping Root | Pear, Peach, Lemon |
| Rare | Sapphire Birch, Azure Cedar, Cobalt Palm | Blue Maple, Frost Fern, Azure Blossom | Coral Root, Frost Root, Azure Tangle | Crystalberry, Hazelfruit, Frostberry |
| Epic | Amethyst Spiral, Violet Willow, Rosewood Twist | Lavender Fan, Orchid Cloud, Violet Wings | Crystal Root, Amethyst Root, Orchid Tether | Plum, Pomegranate, Passionfruit |
| Legendary | Sunwood, Amber Redwood, Royal Mahogany | Solar Crown, Golden Halo, Amber Bloom | Gilded Root, Royal Root, Sunstone Root | Starfruit, Golden Mango, Sunmelon |
| Mythic | Dragon Bark, Phoenix Timber, Ancient Wyrmwood | Phoenix Frond, Dragon Wings, Eternal Blossom | Ember Tendril, Phoenix Root, Ancient Coil | Dragonfruit, Phoenix Berry, Ember Peach |
| Godly | Celestial Pillar, Infinity Spire, Worldtree Heart | Starlight Canopy, Nebula Veil, Infinity Crown | Astral Anchor, Eternity Root, Galaxy Tether | Moonfruit, Galaxy Grape, Infinity Fig |

Base rarity odds: 60%, 25%, 10%, 4%, 0.9%, 0.09%, 0.01%. Each specific catalog part has one twelfth of its rarity probability before luck and pity. Mutation odds independently apply to every part: ×1 80%, ×2 12%, ×5 5%, ×15 2.5%, ×50 0.5%.


## Schema 6 value and growth rules

Catalog names, raw stat ranges, mutation identities, rarity/slot/name probabilities and the 420-entry Index remain unchanged. No saved part is rerolled. Each Fruit/Leaves contribution and Trunk factor derives rarity power as `1.17^(part tier - 1)`. Leaf Power multiplies the whole value by 1/2/4/8/16/32 rather than adding a flat stat.

Combined part-average × harvest mutation is capped at **2×**; the values above are raw factors before that cap. Height still uses floor-average build tier. New growth time uses `ceil((floor-average tier + highest part tier)/2)`; the Godly-trunk/three-Common case takes 600 seconds, with height tier 2. Existing growing records retain their saved durations.

| Rarity | Derived part power | Root reference interval | Midpoint full-build base coins/sec |
|---|---:|---:|---:|
| Common | 1.00000× | 5s | 13.310 |
| Uncommon | 1.17000× | 3.5s | 35.803 |
| Rare | 1.36890× | 2.5s | 90.348 |
| Epic | 1.60161× | 1.75s | 225.047 |
| Legendary | 1.87389× | 1.2s | 557.524 |
| Mythic | 2.19245× | 0.8s | 1391.126 |
| Godly | 2.56516× | 0.5s | 3480.856 |

Root interval is `max(0.5, reference interval * rarity.Min * 0.15 / saved Root.Stat)`. Midpoint income assumes no mutations, upgrades, Saplings or bonuses; actual Common midpoint drops take 4.545 seconds, while the free starter takes 5 seconds. Adjacent full-tier jumps are about 2.48–2.69× and Godly/Common income is 261.52×. See ECONOMY_REPORT.md for before/after values and the mutation-cap tradeoff.


## Schema 7 collection tracks

The 84 names and five mutation identities remain. Names deduplicate mutations; the core completion goal is the 48 Common–Epic names. Mutation sets use 6 Golden / 4 Rainbow / 3 Void / 1 Cosmic distinct names per core rarity, plus first-find tiers. Full Legendary–Godly combinations and the old 420-combination view are optional Legend titles/cosmetics, not required progression. Four core rarity-name claims grant at most +4% coin value and +4% rarity luck. No mutation or egg probabilities changed. See COLLECTION_REPORT.md for every set’s expected rolls/time and reward.
