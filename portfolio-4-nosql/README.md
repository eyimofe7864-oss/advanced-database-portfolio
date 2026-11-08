# Portfolio 4 – NoSQL and Advanced Data Models (Wakawell)

## Files in this folder
| File | Contents |
|---|---|
| `portfolio-4-graph.cypher` | Cypher script: builds the graph and runs the five queries |
| `1-load-data-all-steps-green.png` | All loading steps completed successfully |
| `2-node-counts.png` | 4 corridors, 18 stops, 18 landmarks, 6 routes |
| `3-network-graph.png` | The whole stop network drawn as a graph |
| `4-journey-graph.png` / `5-journey-list-total-fare.png` | Journey planner: Kubwa Village to Airport Junction |
| `6-cheapest-journeys.png` | Cheapest journeys from Kubwa Village to Area 1 Junction |
| `7-transfer-points.png` | Stops where riders can change routes |
| `8-nearest-stops.png` | Stops within 1 km of a rider, with landmarks |

## Database used
**Neo4j AuraDB Free**, a cloud-hosted **graph database**, queried with **Cypher**.
The same Abuja sample data from Portfolio 1 is used.

## The graph model
| Element | Type | Meaning |
|---|---|---|
| `Stop` | Node | A pick-up or drop-off point, with a map location |
| `Landmark` | Node | A recognisable place, linked to a stop by `NEAR` |
| `Route` | Node | A taxi, bus or keke route, linked to stops by `SERVES {stop_order}` |
| `Corridor` | Node | A major road, linked to routes by `RUNS_ALONG` |
| `RIDE` | Relationship | Travel between two consecutive stops, with the route name and fare |
| `WALK` | Relationship | A walking transfer between nearby stops, with time and directions |

In the relational design, a stop's connections were spread across `route_stops`, `fares`
and `transfers`. In the graph, the network is stored the way it looks on a map:
**stops are points and rides are arrows between them.**

## Queries and results
| Query | Question | Result |
|---|---|---|
| Q1 / Q2 | Fewest stops from Kubwa Village to Airport Junction | 11 stops, 2 routes plus a walk at Area 1, total ₦2,300 |
| Q3 | Cheapest journey from Kubwa Village to Area 1 Junction | ₦1,250, ₦1,300 and ₦1,350 options, sorted by fare |
| Q4 | Where can riders change routes? | 6 transfer stops; Berger Junction is served by 3 routes |
| Q5 | Nearest stops to a rider near Berger | Berger Junction (246 m) and Wuse Market (889 m), with landmarks |

## Why a graph database suits Wakawell
- **Journey planning is path-finding.** "How do I get from A to B?" means following
  connections. Cypher does this in one line with `shortestPath`, and also handles
  journeys that need transfers.
- **The same question is hard in SQL.** A relational database must join the fares or
  route_stops table to itself once for every leg of the journey, and the number of legs
  is not known in advance. A graph database stores the connections directly, so it
  follows them instead of searching tables.
- **Walking transfers fit naturally.** A walk is just another kind of arrow, so the
  planner can combine rides and walks in a single search.
- **The model matches how riders think:** stops, the links between them, and where to change.

## A limitation found during testing
The fewest-stops journey (Q2) switches from the Kubwa – Wuse Market bus to the Kubwa –
Berger taxi for one stop at Mabushi, then back again. This is because `shortestPath`
counts stops only. It ignores fare and the inconvenience of changing vehicle.
Q3 addresses this by comparing the total fare of every possible path. A production
journey planner would also add a penalty for each change of vehicle.

Neo4j also showed a notice, *"Unbounded variable length pattern"*, for Q1 and Q2. This
warns that open-ended path searches can become slow on a large network. Q3 already sets
a limit (`*..12`), and the same limit would be applied to all queries at scale.

## Relational vs graph: the best of both
The graph does not replace MySQL. MySQL remains the **system of record** for fares and
admin updates, where transactions and constraints matter (Portfolio 3). The graph is
best used as a **routing layer** that is refreshed from MySQL and answers journey
questions quickly.
