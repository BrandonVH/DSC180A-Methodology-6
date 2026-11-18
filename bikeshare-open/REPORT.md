# Results

| Model | Feature set | Valid R2 | Valid MAE | Test R2 | Test MAE |
|---|---|---:|---:|---:|---:|
| baseline_mean | Before feature | -0.8583 | 1965.6 | -2.0333 | 2793.1 |
| baseline_mean | After feature | -0.8583 | 1965.6 | -2.0333 | 2793.1 |
| baseline_persistence | Before feature | 0.4507 | 900.6 | 0.5099 | 840.1 |
| baseline_persistence | After feature | 0.4507 | 900.6 | 0.5099 | 840.1 |
| ridge | Before feature | 0.6434 | 839.2 | 0.5771 | 956.2 |
| ridge | After feature | 0.6919 | 763.2 | 0.6268 | 870.9 |
| hgb | Before feature | 0.1713 | 1340.5 | -0.6087 | 2060.6 |
| hgb | After feature | 0.1643 | 1341.2 | -0.6534 | 2087.9 |

Every row is reproduced from `reports/metrics.json`.

# Headline finding

The naive split would conceal the distribution shift, but the temporal split shows that ridge reaches test R2 0.6268 and MAE 870.9, while persistence reaches test R2 0.5099 and MAE 840.1. Mean is strongly negative at test R2 -2.0333, and hgb is also negative at -0.6534 while still comfortably beating mean; hgb's negative score means it is worse than test-period mean, not that it trails mean. The 14-day rolling target mean improved ridge validation R2 by 0.0485 (0.6434 to 0.6919) and I kept it. It is mechanically available for a date because it uses only 14 prior calendar days and `.shift(1)`; it did not improve hgb validation R2, which fell slightly from 0.1713 to 0.1643.

# Exercise 4: target transformation

I used validation only to compare transformations of the target for HGB. A log transform gave validation R2 0.0758 and MAE 1421.2. Square root gave 0.1076 and 1394.6. Raising target values to power 1.5 and inverse-transforming predictions gave the best candidate, validation R2 0.1926 and MAE 1313.5, versus HGB's committed untransformed validation R2 0.1643. It is not a defensible deployment transformation: the power has no separate physical or statistical justification for ridership and mainly manufactures curvature, so I did not commit it. I touched test only after this validation decision; the 1.5-power variant scored test R2 -0.5840 and MAE 2041.9, still worse than persistence and the committed ridge model.

# Exercise 5: ridge vs persistence

Ridge is worth deploying if R2 is the primary decision criterion: on test it reaches R2 0.6268 versus persistence 0.5099, a 0.1169 improvement, but persistence has lower MAE (840.1 versus 870.9). Because MAE penalizes absolute missed rides directly and persistence wins it, persistence is the safer fleet-default under an operations cost measured in rides; ridge is preferable for ranking or variance explained. The difference is not large enough to use R2 alone as an argument for replacing a robust baseline.

# Attribution

I used `qwen3.5:9b` through local Ollama, with a 64k context and the `bikeshare-coder` named build. I did not switch models.

Agent-generated files or functions:
- `src/features.py`: 14-day rolling feature and calendar feature plumbing.
- `tests/test_leakage.py` and `tests/test_contract.py`: feature and raw-column checks.
- `.claude/hooks/check_leakage.sh`, `.claude/hooks/protect_raw.sh`, `.claude/hooks/check_leakage_stop.sh`: verification enforcement.
- `.claude/skills/ablation/SKILL.md`: repeated feature-ablation workflow.
- `REPORT.md`, `docs/SEEDED_FAULTS.md`, `docs/AUDIT.md`, `docs/DECISIONS.md`, and `reports/audit.jsonl`: evidence and write-up.

Decisions that were mine:
- Forecast `cnt` and exclude `casual`, `registered`, time indexes, and the unverified shipped lag.
- Use a 2011 / H1 2012 / H2 2012 temporal split and keep test untouched until final comparison.
- Require mean and persistence baselines beside every model.
- Add the 14-day rolling mean and keep it from its positive validation delta.
- Decline the power-1.5 HGB transformation as not domain-defensible.
- Decide that ridge's R2 gain does not outweigh persistence's MAE advantage enough to make one deployment answer unqualified.
