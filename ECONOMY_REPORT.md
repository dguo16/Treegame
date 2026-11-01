# Economy audit — November 1, 2026

## Price and upgrade changes

| Measure | Previous | Current |
|---|---:|---:|
| Maximum exponent | 200 | 50 |
| Roll 50, undiscounted | 9,423 | 9,423 |
| Roll 300, undiscounted | 13,790,120,804,955 | 10,836 |
| First 300 rolls total | 1,470,946,219,195,043 | 2,781,154 |
| Ascension threshold | 1,000,000,000 | 1,000,000,000 |
| Late Leaf Power values | 500,000 / 1,000,000 | 5,000 / 10,000 |

The old bounded price curve still made Legendary pity's worst-case 300-roll path economically impractical before Ascension. The current first-300 total is 0.278% of the threshold. Discounts remain multiplicative; the existing Ascension reset is preserved. The old 3M-price Leaf Power jump also made first Ascension occur in about six minutes under the updated simulator; it was reduced before final measurement.

## Final 21-seed free-player model

| Elapsed | Median coins on hand | Median rolls | Median producing plots |
|---|---:|---:|---:|
| 1 minute | 1,597 | 21 | 2 |
| 5 minutes | 1,052,299 | 105 | 4 |
| 15 minutes | 121,630,957 | 345 | 6 |
| 30 minutes | 457,463,129 | 705 | 6 |
| 60 minutes | 960,033,429 | 1,425 | 6 |

All 21 seeds reached 300 rolls; median time was 786.25 seconds (13.1 minutes). Nineteen of 21 reached the first Ascension threshold within an hour; median among those that reached it was 2,856.25 seconds (47.6 minutes). This is a conditional median, not a claim that all players Ascend within that time.

The older Config.Simulation targets of 10K at 15 minutes and 1M at 30 minutes are NOT met. The one-hour 1B target is within the original factor-of-two tolerance. Do not describe all historical pacing targets as passed. Early progression is now much more generous; real-player testing should decide whether those obsolete early targets or the current balance should change further.

Simulation.Run uses production roll/rarity/pity/mutation equations, the 500-part limit, equipped-part-safe selling, growth, unlocked plot limits, explicit validated replacement, fruit mutation rolls, bag capacity, fruit lifetime/pool bounds, and 12-second selling intervals. It assumes active collection from all owned plots and does not simulate actual walking/range coverage. It omits pets, events, private-server perks, paid perks, offline rewards, daily/goal claims and repeated Ascensions. It is a policy model, not retention validation. Height variation does not affect value. Call Simulation.Median(3600,{SaleEvery=12}) in an isolated Studio server Play session to reproduce.
