# Decisions

One line per methodological decision: what you chose, why, and what it changed.
Agents append here via the `/new-feature` skill; you append here by hand.

- Exclude `casual`, `registered`: they sum to `cnt` exactly. Leaky model R^2 1.000 -> honest ridge 0.583.
- Exclude `cnt_2d_bfr`: a shipped 2-day lag we cannot test the alignment of. Build our own lags instead.
- Exclude `instant`, `yr`, `days_since_2011`: time indexes let a tree predict a flat constant past 2011 and a linear model extrapolate a trend we have no grounds for.
- Split 2011 / H1 2012 / H2 2012 by date. Test set touched once, after all feature work.
- Report mean and persistence baselines with every score. Persistence (test R^2 0.510, MAE 840) is within 0.07 R^2 of ridge and beats it on MAE; that caveat goes in the report.
- 2026-11-17: Added `cnt_roll_14`, a 14-day target rolling mean built on `reindex_to_calendar` and `.shift(1)`; ridge validation R2 changed from 0.6434 to 0.6919 (+0.0485), hgb changed from 0.1713 to 0.1643 (-0.0070), and I kept the feature for its meaningful ridge gain.
- 2026-11-17: Tested target transformations for hgb on validation only: log R2 0.0758, square root 0.1076, power 1.5 R2 0.1926. I rejected power 1.5 because it lacked domain justification and touched test only after the validation decision.
- 2026-11-17: Added a raw-column classification test and SHA-256 prefix guard; they prevent a new unclassified column or replacement raw file from entering silently.
- 2026-11-17: Added a PreToolUse Bash guard for raw-data copy/move commands and a Stop hook that does not let tests remain red.
