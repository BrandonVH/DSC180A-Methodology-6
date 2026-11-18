# Seeded faults

## 1. Forbidden column in `feature_columns`

Exact change: altered `feature_columns()` to exclude `FORBIDDEN - {"casual"}`, allowing `casual` to enter.

Red test output:

```text
AssertionError: forbidden columns in feature set: {'casual'}
FAILED tests/test_leakage.py::test_no_forbidden_features
1 failed, 7 passed
```

Hook stderr: the PostToolUse hook ran the leakage suite and would emit:

```text
Leakage tests failed after editing src/features.py:
E       AssertionError: forbidden columns in feature set: {'casual'}
FAILED tests/test_leakage.py::test_no_forbidden_features
1 failed, 7 passed
```

Agent turns to fix: 1. Restored `if c not in FORBIDDEN`.

## 2. `.shift(1)` deleted from `cnt_roll_7`

Exact change: replaced `out[TARGET].shift(1).rolling(7).mean()` with `out[TARGET].rolling(7).mean()`.

Red test output:

```text
assert np.float64(4389.428571428572) == 4240.714285714285 +/- 0.00424071
FAILED tests/test_leakage.py::test_rolling_mean_excludes_today
1 failed, 1 passed
```

Hook stderr:

```text
Leakage tests failed after editing src/features.py:
E       assert np.float64(4389.428571428572) == 4240.714285714285
FAILED tests/test_leakage.py::test_rolling_mean_excludes_today
1 failed, 1 passed
```

Agent turns to fix: 1. Restored `.shift(1)`.

## 3. Weather encoder `raise` removed

Exact change: deleted the `if unknown: raise ValueError(...)` block and left unseen labels to `.map()`.

Red test output:

```text
with pytest.raises(ValueError, match="unmapped weather labels"):
E       Failed: DID NOT RAISE ValueError
FAILED tests/test_leakage.py::test_unmapped_weather_raises
1 failed, 8 deselected
```

Hook stderr:

```text
Leakage tests failed after editing src/features.py:
E       Failed: DID NOT RAISE ValueError
FAILED tests/test_leakage.py::test_unmapped_weather_raises
1 failed, 8 deselected
```

Agent turns to fix: 1. Restored the unmapped-label raise.

## 4. PostToolUse cannot see a raw-data `cp`

A `cp` or `copy` command that writes into `data/raw/` is not a write to a file under `src/`, so the PostToolUse hook's `*src/*.py` filter does not fire. A raw-file hash check in `make data` would catch it at pipeline time, and a filesystem permission or PreToolUse Bash hook would catch or block it earlier. I implemented a PreToolUse Bash hook (`.claude/hooks/protect_raw.sh`) plus the SHA-256 prefix check in `src.ingest.load_raw`, so copying or moving a replacement raw file is blocked or fails `make data`. The existing permission deny also denies raw-file edit/write operations.
