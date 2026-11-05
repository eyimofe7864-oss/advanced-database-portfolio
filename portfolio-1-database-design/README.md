# Portfolio 1 – Database Design and Modelling (Wakawell)

## Files in this folder
| File | Contents |
|---|---|
| `case-study.md` | Description of Wakawell, its users, data and key operations |
| `schema.sql` | Script that creates the database and all 7 tables with keys and constraints |
| `sample-data.sql` | Sample Abuja dataset (approximate values, not production data) |
| `er-diagram.png` | Entity-relationship diagram, reverse-engineered from the live database in MySQL Workbench |

## How to run
1. Run `schema.sql` in MySQL 8 (creates the `wakawell_portfolio` database and tables).
2. Run `sample-data.sql` (loads sample data; safe to re-run).
3. The final query in `sample-data.sql` prints row counts to confirm the load.

## Tables
| Table | Purpose | Key relationships |
|---|---|---|
| corridors | Major roads shared by several routes | One corridor has many routes |
| stops | Pick-up and drop-off points with coordinates | One stop has many landmarks |
| landmarks | Recognisable places that help riders identify a stop | Each landmark belongs to one stop |
| routes | A taxi, bus or keke route, with its main corridor | Belongs to one corridor |
| route_stops | Ordered list of stops on each route | Links routes and stops (many-to-many) |
| fares | Price between two stops on a route | Depends on route + from stop + to stop |
| transfers | Walking transfers between nearby stops on different routes | Links two routes and two stops |

## Design decisions
- **Fares vary by drop-off point**, so each fare is stored per route and per pair of stops,
  not once per route.
- **Riders sometimes walk to a nearby stop to change routes**, so transfers record two
  stops and a walking note. Transfers at the same stop are not stored, because they can
  be found by querying route_stops.
- **Each route has one main corridor**, to keep the design simple.
- Rider accounts, rider reports and driver data are left out of this version to keep
  the design focused.

## Keys and constraints
- **Primary keys** give every row a unique ID. `route_stops` uses a **composite key**
  (route_id, stop_order), so each position on a route holds only one stop.
- **Foreign keys** link tables, so a landmark cannot point to a stop that does not exist.
- **UNIQUE** on stop names prevents the same stop being saved twice.
- **UNIQUE (route_id, from_stop_id, to_stop_id)** on fares prevents conflicting prices
  for the same trip.
- **CHECK (amount > 0)** blocks zero or negative fares; **CHECK (from_stop_id <> to_stop_id)**
  blocks a fare that starts and ends at the same stop.
- **ENUM** restricts vehicle type to 'shared taxi', 'bus' or 'keke'.

## Normalisation
If Wakawell stored everything in one spreadsheet (route, vehicle, corridor, all stops,
fare, landmark on each row), three problems would appear:

1. **Several values in one cell.** A "stops" cell listing every stop on a route cannot be
   searched or ordered properly. Each stop should have its own cell. **(1NF)**
   → Fixed by `route_stops`, where each stop on a route is its own row with its position.

2. **Update anomaly.** The vehicle type would be repeated on every fare row for a route.
   Changing Kubwa – Berger from taxi to bus would mean editing every one of those rows,
   and missing one would leave the data contradicting itself. **(2NF / 3NF)**
   → Fixed by storing vehicle type once, in `routes`. Each fact lives in the table it
   describes: route facts in routes, stop facts in stops, and the fare (which depends on
   the route and both stops together) in fares.

3. **Insertion and deletion anomalies.** A new stop that no route uses yet could not be
   added, because every row needs a route and a fare. Deleting the last route through a
   stop would also delete the stop.
   → Fixed by the separate `stops` table, so stops exist independently of routes.

The final design is in **Third Normal Form (3NF)**: every non-key column depends on the
key, the whole key, and nothing but the key.
