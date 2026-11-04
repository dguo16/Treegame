-- Shared profile contract. Persisted fields are JSON-compatible only.
export type Part = {InUse: string?, Variant: number?, Mutation: string?, Id: string, Slot: string, Tier: number, Stat: number, Name: string}
export type Growth = {PartIds: {[string]: string}?, LegacyParts: {[string]: any}?, HeightScale: number?, Build: {[string]: Part}, Progress: number, Rate: number, Settled: number, Duration: number, State: string, Tutorial: boolean?, Id: string}
export type Profile = {OwnershipVersion: number?, PartVersion: number?, Growth2: Growth?, Growth3: Growth?, GrowthQueue: {any}, Schema: number, Coins: number, Rolls: number, EpicPity: number, LegendaryPity: number, Parts: {Part}, Equipped: {[string]: Part}, Plots: {any}, Growth: Growth?, LastSeen: number, Receipts: {[string]: boolean}}
return {}
