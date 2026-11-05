-- =====================================================================
-- Wakawell portfolio – PORTFOLIO 2: QUERY OPTIMISATION
-- Run ONE PART AT A TIME: highlight the part, then click the plain lightning bolt.
-- Take a screenshot of the results after Part B, Part D and Part E.
-- =====================================================================

USE wakawell_portfolio;

-- ---------------------------------------------------------------------
-- PART A: SCALE UP THE DATA FOR TESTING  (run once)
-- 18 stops is too small to show any speed difference, so we add
-- 20,000 synthetic test stops (random points around Abuja) and one
-- test landmark per test stop. Real sample data is not changed.
-- ---------------------------------------------------------------------
SET SESSION cte_max_recursion_depth = 20001;

INSERT IGNORE INTO stops (name, latitude, longitude)
WITH RECURSIVE seq (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 20000
)
SELECT CONCAT('Test Stop ', n),
       8.950000 + RAND() * 0.25,
       7.250000 + RAND() * 0.40
FROM seq;

INSERT INTO landmarks (name, type, stop_id)
SELECT CONCAT('Test Landmark ', s.stop_id), 'test', s.stop_id
FROM stops s
WHERE s.name LIKE 'Test Stop %'
  AND NOT EXISTS (SELECT 1 FROM landmarks l WHERE l.stop_id = s.stop_id);

SELECT (SELECT COUNT(*) FROM stops) AS total_stops,
       (SELECT COUNT(*) FROM landmarks) AS total_landmarks;


-- ---------------------------------------------------------------------
-- PART B: THE THREE QUERIES, BEFORE ANY NEW INDEX
-- Q1  Which stop is a landmark at?        (rider searches "Wuse Market Main Gate")
-- Q2  Nearest stops to the rider          (rider standing near Berger, 9.0730, 7.4650)
-- Q3  Fare between two stops              (Kubwa Village -> Berger Junction)
-- ---------------------------------------------------------------------

-- Q1: answer, then the plan
SELECT s.name AS stop, l.name AS landmark
FROM landmarks l
JOIN stops s ON s.stop_id = l.stop_id
WHERE l.name = 'Wuse Market Main Gate';

EXPLAIN ANALYZE
SELECT s.name AS stop, l.name AS landmark
FROM landmarks l
JOIN stops s ON s.stop_id = l.stop_id
WHERE l.name = 'Wuse Market Main Gate';

-- Q2: answer, then the plan
-- (the BETWEEN box keeps the search to roughly 1 km around the rider)
SELECT name,
       ROUND(ST_Distance_Sphere(POINT(longitude, latitude), POINT(7.4650, 9.0730))) AS distance_m
FROM stops
WHERE latitude  BETWEEN 9.065 AND 9.081
  AND longitude BETWEEN 7.457 AND 7.473
ORDER BY distance_m
LIMIT 3;

EXPLAIN ANALYZE
SELECT name,
       ROUND(ST_Distance_Sphere(POINT(longitude, latitude), POINT(7.4650, 9.0730))) AS distance_m
FROM stops
WHERE latitude  BETWEEN 9.065 AND 9.081
  AND longitude BETWEEN 7.457 AND 7.473
ORDER BY distance_m
LIMIT 3;

-- Q3: answer, then the plan
SELECT r.name AS route, a.name AS from_stop, b.name AS to_stop, f.amount
FROM fares f
JOIN routes r ON r.route_id = f.route_id
JOIN stops  a ON a.stop_id  = f.from_stop_id
JOIN stops  b ON b.stop_id  = f.to_stop_id
WHERE a.name = 'Kubwa Village'
  AND b.name = 'Berger Junction';

EXPLAIN
SELECT r.name AS route, a.name AS from_stop, b.name AS to_stop, f.amount
FROM fares f
JOIN routes r ON r.route_id = f.route_id
JOIN stops  a ON a.stop_id  = f.from_stop_id
JOIN stops  b ON b.stop_id  = f.to_stop_id
WHERE a.name = 'Kubwa Village'
  AND b.name = 'Berger Junction';


-- ---------------------------------------------------------------------
-- PART C: ADD THE INDEXES  (run once)
-- ---------------------------------------------------------------------
CREATE INDEX idx_landmarks_name ON landmarks (name);
CREATE INDEX idx_stops_lat_lon  ON stops (latitude, longitude);


-- ---------------------------------------------------------------------
-- PART D: THE SAME QUERIES AGAIN, AFTER INDEXING
-- ---------------------------------------------------------------------
EXPLAIN ANALYZE
SELECT s.name AS stop, l.name AS landmark
FROM landmarks l
JOIN stops s ON s.stop_id = l.stop_id
WHERE l.name = 'Wuse Market Main Gate';

EXPLAIN ANALYZE
SELECT name,
       ROUND(ST_Distance_Sphere(POINT(longitude, latitude), POINT(7.4650, 9.0730))) AS distance_m
FROM stops
WHERE latitude  BETWEEN 9.065 AND 9.081
  AND longitude BETWEEN 7.457 AND 7.473
ORDER BY distance_m
LIMIT 3;


-- ---------------------------------------------------------------------
-- PART E: SIMPLE TABLE VIEW OF THE PLANS (easy to read in screenshots)
-- Look at the columns: type, key, rows
-- ---------------------------------------------------------------------
EXPLAIN SELECT s.name, l.name FROM landmarks l JOIN stops s ON s.stop_id = l.stop_id
WHERE l.name = 'Wuse Market Main Gate';

EXPLAIN SELECT name FROM stops
WHERE latitude BETWEEN 9.065 AND 9.081 AND longitude BETWEEN 7.457 AND 7.473;

SHOW INDEX FROM stops;
