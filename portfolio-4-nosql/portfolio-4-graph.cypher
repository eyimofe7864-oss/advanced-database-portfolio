// =====================================================================
// Wakawell portfolio – PORTFOLIO 4: NoSQL GRAPH MODEL (Neo4j / Cypher)
// Same Abuja sample data as Portfolio 1, modelled as a graph.
// Run ONE STEP AT A TIME: paste a step into the query box and run it.
// =====================================================================

// STEP 1: clear the database (safe to re-run)
MATCH (n) DETACH DELETE n;

// STEP 2: corridors and stops
UNWIND ['Kubwa Expressway', 'Central Area', 'Airport Road', 'Abuja-Keffi Expressway'] AS c
CREATE (:Corridor {name: c});

UNWIND [
  {name: 'Kubwa Village', lat: 9.16, lon: 7.322},
  {name: 'Phase 4 Kubwa', lat: 9.147, lon: 7.338},
  {name: 'Dutse Junction', lat: 9.121, lon: 7.379},
  {name: 'Gwarinpa Junction', lat: 9.098, lon: 7.401},
  {name: 'Mabushi', lat: 9.08, lon: 7.443},
  {name: 'Berger Junction', lat: 9.074, lon: 7.463},
  {name: 'Wuse Market', lat: 9.069, lon: 7.472},
  {name: 'Federal Secretariat', lat: 9.048, lon: 7.5},
  {name: 'Area 1 Junction', lat: 9.031, lon: 7.48},
  {name: 'Area 1 Shopping Plaza', lat: 9.0295, lon: 7.4815},
  {name: 'Kuchigoro', lat: 8.995, lon: 7.43},
  {name: 'Lugbe', lat: 8.98, lon: 7.38},
  {name: 'Airport Junction', lat: 9.006, lon: 7.263},
  {name: 'AYA', lat: 9.045, lon: 7.525},
  {name: 'Kugbo', lat: 9.035, lon: 7.56},
  {name: 'Nyanya Bridge', lat: 9.026, lon: 7.578},
  {name: 'Nyanya Market', lat: 9.0245, lon: 7.5805},
  {name: 'Mararaba', lat: 9.01, lon: 7.595}
] AS s
CREATE (:Stop {name: s.name, location: point({latitude: s.lat, longitude: s.lon})});

// STEP 3: landmarks, each NEAR a stop
UNWIND [
  {name: 'Kubwa Village Market', type: 'market', stop: 'Kubwa Village'},
  {name: 'NNPC Filling Station, Phase 4', type: 'filling station', stop: 'Phase 4 Kubwa'},
  {name: 'Dutse Alhaji Junction', type: 'junction', stop: 'Dutse Junction'},
  {name: 'Gwarinpa 1st Avenue Gate', type: 'junction', stop: 'Gwarinpa Junction'},
  {name: 'Mabushi Bus Stop', type: 'bus stop', stop: 'Mabushi'},
  {name: 'Berger Roundabout', type: 'roundabout', stop: 'Berger Junction'},
  {name: 'Wuse Market Main Gate', type: 'market', stop: 'Wuse Market'},
  {name: 'Federal Secretariat Complex', type: 'government building', stop: 'Federal Secretariat'},
  {name: 'Area 1 Roundabout', type: 'roundabout', stop: 'Area 1 Junction'},
  {name: 'Area 1 Shopping Plaza', type: 'shopping centre', stop: 'Area 1 Shopping Plaza'},
  {name: 'Kuchigoro Junction', type: 'junction', stop: 'Kuchigoro'},
  {name: 'Lugbe FHA Junction', type: 'junction', stop: 'Lugbe'},
  {name: 'Airport Road Toll Gate', type: 'toll gate', stop: 'Airport Junction'},
  {name: 'AYA Junction', type: 'junction', stop: 'AYA'},
  {name: 'Kugbo Furniture Market', type: 'market', stop: 'Kugbo'},
  {name: 'Nyanya Pedestrian Bridge', type: 'bridge', stop: 'Nyanya Bridge'},
  {name: 'Nyanya Market', type: 'market', stop: 'Nyanya Market'},
  {name: 'Mararaba Market', type: 'market', stop: 'Mararaba'}
] AS l
MATCH (s:Stop {name: l.stop})
CREATE (:Landmark {name: l.name, type: l.type})-[:NEAR]->(s);

// STEP 4: routes, the corridor they run along, and the stops they serve
UNWIND [
  {name: 'Kubwa - Berger', vehicle: 'shared taxi', corridor: 'Kubwa Expressway', stops: ['Kubwa Village', 'Phase 4 Kubwa', 'Dutse Junction', 'Gwarinpa Junction', 'Mabushi', 'Berger Junction']},
  {name: 'Kubwa - Wuse Market', vehicle: 'bus', corridor: 'Kubwa Expressway', stops: ['Kubwa Village', 'Dutse Junction', 'Mabushi', 'Berger Junction', 'Wuse Market']},
  {name: 'Berger - Area 1', vehicle: 'shared taxi', corridor: 'Central Area', stops: ['Berger Junction', 'Wuse Market', 'Federal Secretariat', 'Area 1 Junction']},
  {name: 'Area 1 - Airport Junction', vehicle: 'shared taxi', corridor: 'Airport Road', stops: ['Area 1 Shopping Plaza', 'Kuchigoro', 'Lugbe', 'Airport Junction']},
  {name: 'Federal Secretariat - Nyanya', vehicle: 'bus', corridor: 'Abuja-Keffi Expressway', stops: ['Federal Secretariat', 'AYA', 'Kugbo', 'Nyanya Bridge']},
  {name: 'Nyanya - Mararaba', vehicle: 'keke', corridor: 'Abuja-Keffi Expressway', stops: ['Nyanya Market', 'Mararaba']}
] AS r
MATCH (c:Corridor {name: r.corridor})
CREATE (rt:Route {name: r.name, vehicle_type: r.vehicle})-[:RUNS_ALONG]->(c)
WITH rt, r
UNWIND range(0, size(r.stops) - 1) AS i
MATCH (s:Stop {name: r.stops[i]})
CREATE (rt)-[:SERVES {stop_order: i + 1}]->(s);

// STEP 5: RIDE links between consecutive stops (direction of travel, with fare)
UNWIND [
  {route: 'Kubwa - Berger', from: 'Kubwa Village', to: 'Phase 4 Kubwa', fare: 200},
  {route: 'Kubwa - Berger', from: 'Phase 4 Kubwa', to: 'Dutse Junction', fare: 300},
  {route: 'Kubwa - Berger', from: 'Dutse Junction', to: 'Gwarinpa Junction', fare: 200},
  {route: 'Kubwa - Berger', from: 'Gwarinpa Junction', to: 'Mabushi', fare: 300},
  {route: 'Kubwa - Berger', from: 'Mabushi', to: 'Berger Junction', fare: 200},
  {route: 'Kubwa - Wuse Market', from: 'Kubwa Village', to: 'Dutse Junction', fare: 300},
  {route: 'Kubwa - Wuse Market', from: 'Dutse Junction', to: 'Mabushi', fare: 300},
  {route: 'Kubwa - Wuse Market', from: 'Mabushi', to: 'Berger Junction', fare: 150},
  {route: 'Kubwa - Wuse Market', from: 'Berger Junction', to: 'Wuse Market', fare: 100},
  {route: 'Berger - Area 1', from: 'Berger Junction', to: 'Wuse Market', fare: 200},
  {route: 'Berger - Area 1', from: 'Wuse Market', to: 'Federal Secretariat', fare: 200},
  {route: 'Berger - Area 1', from: 'Federal Secretariat', to: 'Area 1 Junction', fare: 200},
  {route: 'Area 1 - Airport Junction', from: 'Area 1 Shopping Plaza', to: 'Kuchigoro', fare: 300},
  {route: 'Area 1 - Airport Junction', from: 'Kuchigoro', to: 'Lugbe', fare: 300},
  {route: 'Area 1 - Airport Junction', from: 'Lugbe', to: 'Airport Junction', fare: 400},
  {route: 'Federal Secretariat - Nyanya', from: 'Federal Secretariat', to: 'AYA', fare: 150},
  {route: 'Federal Secretariat - Nyanya', from: 'AYA', to: 'Kugbo', fare: 200},
  {route: 'Federal Secretariat - Nyanya', from: 'Kugbo', to: 'Nyanya Bridge', fare: 150},
  {route: 'Nyanya - Mararaba', from: 'Nyanya Market', to: 'Mararaba', fare: 200}
] AS seg
MATCH (a:Stop {name: seg.from}), (b:Stop {name: seg.to})
CREATE (a)-[:RIDE {route: seg.route, fare: seg.fare}]->(b);

// STEP 6: walking transfers between nearby stops (fare 0)
UNWIND [
  {from: 'Area 1 Junction', to: 'Area 1 Shopping Plaza', minutes: 3, note: 'Walk about 3 minutes from the roundabout to the taxi rank at the shopping plaza.'},
  {from: 'Nyanya Bridge', to: 'Nyanya Market', minutes: 5, note: 'Cross the pedestrian bridge; keke rank is beside the market entrance.'}
] AS w
MATCH (a:Stop {name: w.from}), (b:Stop {name: w.to})
CREATE (a)-[:WALK {minutes: w.minutes, note: w.note, fare: 0}]->(b);

// STEP 7: check counts (expect 4 Corridor, 18 Stop, 18 Landmark, 6 Route)
MATCH (n) RETURN labels(n)[0] AS type, count(*) AS how_many ORDER BY type;

// STEP 8: see the whole network as a picture
MATCH p = (:Stop)-[:RIDE|WALK]->(:Stop) RETURN p;

// ---------------------------------------------------------------------
// QUERIES
// ---------------------------------------------------------------------

// Q1: journey planner – fewest hops from Kubwa Village to Airport Junction
//     (needs two routes and a walking transfer at Area 1)
MATCH p = shortestPath((a:Stop {name: 'Kubwa Village'})-[:RIDE|WALK*]->(b:Stop {name: 'Airport Junction'}))
RETURN p;

// Q2: same journey as a readable list, with total fare
MATCH p = shortestPath((a:Stop {name: 'Kubwa Village'})-[:RIDE|WALK*]->(b:Stop {name: 'Airport Junction'}))
RETURN [n IN nodes(p) | n.name] AS stops_in_order,
       [r IN relationships(p) | coalesce(r.route, 'WALK')] AS how,
       reduce(total = 0, r IN relationships(p) | total + r.fare) AS total_fare_naira;

// Q3: cheapest journey – compare all possible paths and sort by fare
MATCH p = (a:Stop {name: 'Kubwa Village'})-[:RIDE|WALK*..12]->(b:Stop {name: 'Area 1 Junction'})
WITH p, reduce(total = 0, r IN relationships(p) | total + r.fare) AS total_fare
RETURN [n IN nodes(p) | n.name] AS stops_in_order,
       [r IN relationships(p) | coalesce(r.route, 'WALK')] AS how,
       total_fare
ORDER BY total_fare ASC
LIMIT 3;

// Q4: transfer points – stops served by more than one route
MATCH (r:Route)-[:SERVES]->(s:Stop)
WITH s, collect(r.name) AS routes
WHERE size(routes) > 1
RETURN s.name AS stop, routes
ORDER BY size(routes) DESC;

// Q5: nearest stops to a rider near Berger (9.0730, 7.4650), within 1 km
WITH point({latitude: 9.0730, longitude: 7.4650}) AS rider
MATCH (s:Stop)
WITH s, round(point.distance(s.location, rider)) AS metres
WHERE metres < 1000
OPTIONAL MATCH (l:Landmark)-[:NEAR]->(s)
RETURN s.name AS stop, metres, collect(l.name) AS landmarks
ORDER BY metres;
