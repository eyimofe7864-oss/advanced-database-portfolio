# Portfolio 2 – Query Processing and Optimisation (Wakawell)

## Files in this folder
| File | Contents |
|---|---|
| `portfolio-2-queries.sql` | Test data scale-up, the three queries, index creation, before/after plans |
| `1-q1-before.png` / `2-q1-after.png` | Landmark search plan, before and after indexing |
| `3-q2-before.png` / `4-q2-after.png` | Nearest-stop search plan, before and after indexing |
| `5-q3-plan.png` | Fare lookup plan (already indexed) |

## Test setup
The sample dataset has only 18 stops, too small to show any performance difference.
To make the test meaningful, 20,000 synthetic test stops (random points around Abuja)
and one test landmark per stop were added, giving 20,018 rows in each table.
The real sample data was not changed.

## The three rider queries
1. **Q1 – Landmark search:** which stop is "Wuse Market Main Gate" at?
2. **Q2 – Nearest stops:** the three closest stops to a rider standing near Berger.
3. **Q3 – Fare lookup:** the fare from Kubwa Village to Berger Junction.

## Results (EXPLAIN ANALYZE, MySQL 8)
| Query | Before | After | Improvement |
|---|---|---|---|
| Q1 | Table scan – 20,018 rows, ~5.13 ms, cost 2,739 | Index lookup on `idx_landmarks_name` – 1 row, ~0.039 ms, cost 0.7 | About 130× faster |
| Q2 | Table scan – 20,018 rows, ~7.47 ms, cost 1,993 | Index range scan on `idx_stops_lat_lon` – 71 rows, ~1.15 ms, cost 610 | About 6.5× faster |
| Q3 | Already used indexes – `const` lookups, 1 row per stop | No change needed | — |

## Indexes added
```sql
CREATE INDEX idx_landmarks_name ON landmarks (name);
CREATE INDEX idx_stops_lat_lon  ON stops (latitude, longitude);
```

## What the results show
- **An index works like the index at the back of a textbook.** Without one, MySQL had to
  read all 20,018 landmarks to find one name. With the index, it jumps straight to the
  matching record.
- **Q2 still reads 71 rows** because it is a range search. It draws a box about 1 km wide
  around the rider, and every stop inside that box is a possible answer. MySQL must check
  each one's distance before choosing the closest three. The index narrows the search from
  20,018 rows to 71, but cannot reduce it to one.
- **Q3 was already fast** because of design choices made in Portfolio 1. The UNIQUE
  constraint on stop names and the foreign keys on the fares table automatically create
  indexes, so the fare lookup was efficient before any tuning.

## Trade-off
Indexes speed up reading but slightly slow down inserts and updates, because each index
must also be updated. For Wakawell this is a good trade: riders search far more often
than administrators change stops or landmarks.
