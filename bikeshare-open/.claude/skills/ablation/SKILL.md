---
name: ablation
description: Run a held-out validation ablation for one feature and decide whether to keep it.
allowed-tools: Read, Edit, Bash(python -m pytest*), Bash(python -m src.*), Bash(make*)
---

# Ablation: $ARGUMENTS

1. Confirm `$ARGUMENTS` exists in `feature_columns()` and identify every
   code path that creates or consumes it.
2. Remove it only by changing the local feature list or a temporary branch;
   do not edit the temporal split or baselines.
3. Run `python -m src.features && python -m src.train` for the candidate
   feature set and compare validation R2 and MAE against the committed
   metrics. Do not touch or report test results during the iteration.
4. Keep the feature only if the validation result and availability argument
   justify it. Record the chosen feature, availability argument, validation
   delta, and keep/drop decision in `docs/DECISIONS.md`.
5. Do not change `reports/metrics.json` to hide a negative result.
