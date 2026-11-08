-- =====================================================================
-- Wakawell portfolio – PORTFOLIO 3: TRANSACTIONS AND CONCURRENCY
-- This file is "Admin A". Run ONE PART AT A TIME (highlight, then plain ⚡).
-- Part 3 also uses the second file, portfolio-3-admin-b.sql, in a
-- SECOND connection window ("Admin B").
-- =====================================================================

USE wakawell_portfolio;
SET SQL_SAFE_UPDATES = 0;   -- allow the clean-up deletes below

-- Clean-up so this script can be re-run safely
DELETE FROM fares       WHERE route_id IN (SELECT route_id FROM routes WHERE name LIKE 'Kubwa - Area 1%');
DELETE FROM route_stops WHERE route_id IN (SELECT route_id FROM routes WHERE name LIKE 'Kubwa - Area 1%');
DELETE FROM routes      WHERE name LIKE 'Kubwa - Area 1%';
UPDATE fares SET amount = 1200.00 WHERE route_id = 1 AND from_stop_id = 1 AND to_stop_id = 6;


-- ---------------------------------------------------------------------
-- PART 1: COMMIT – add a whole new route as ONE unit of work
-- A route is only useful if its stops AND fares exist too, so all
-- inserts succeed together or not at all.
-- ---------------------------------------------------------------------
START TRANSACTION;

INSERT INTO routes (name, vehicle_type, corridor_id)
VALUES ('Kubwa - Area 1 Express', 'bus', 1);

SET @new_route = LAST_INSERT_ID();

INSERT INTO route_stops (route_id, stop_id, stop_order) VALUES
  (@new_route, 1, 1),    -- Kubwa Village
  (@new_route, 6, 2),    -- Berger Junction
  (@new_route, 9, 3);    -- Area 1 Junction

INSERT INTO fares (route_id, from_stop_id, to_stop_id, amount) VALUES
  (@new_route, 1, 6, 1000.00),
  (@new_route, 6, 9,  400.00),
  (@new_route, 1, 9, 1400.00);

COMMIT;

-- Check: the route, its 3 stops and 3 fares are all saved
SELECT r.name AS route, rs.stop_order, s.name AS stop
FROM routes r
JOIN route_stops rs ON rs.route_id = r.route_id
JOIN stops s        ON s.stop_id   = rs.stop_id
WHERE r.name = 'Kubwa - Area 1 Express'
ORDER BY rs.stop_order;


-- ---------------------------------------------------------------------
-- PART 2: ROLLBACK – an admin starts adding a route, then finds a
-- mistake (wrong vehicle type) and cancels. Nothing must be saved.
-- ---------------------------------------------------------------------
START TRANSACTION;

INSERT INTO routes (name, vehicle_type, corridor_id)
VALUES ('Kubwa - Area 1 Keke', 'keke', 1);

SET @bad_route = LAST_INSERT_ID();

INSERT INTO route_stops (route_id, stop_id, stop_order) VALUES
  (@bad_route, 1, 1),
  (@bad_route, 9, 2);

-- Inside the transaction the new route is visible...
SELECT name, vehicle_type FROM routes WHERE name LIKE 'Kubwa - Area 1%';

ROLLBACK;

-- ...after ROLLBACK it is gone, and so are its stops
SELECT name, vehicle_type FROM routes WHERE name LIKE 'Kubwa - Area 1%';
SELECT COUNT(*) AS keke_route_stops_left FROM route_stops WHERE route_id = @bad_route;


-- ---------------------------------------------------------------------
-- PART 2b: CONSTRAINTS PROTECT THE DATA EVEN INSIDE A TRANSACTION
-- This statement is meant to FAIL (a fare of 0 breaks CHECK amount > 0).
-- Run it on its own; a red error is the expected result.
-- ---------------------------------------------------------------------
INSERT INTO fares (route_id, from_stop_id, to_stop_id, amount) VALUES (1, 6, 1, 0);


-- ---------------------------------------------------------------------
-- PART 3: CONCURRENCY – two admins update the same fare
-- Follow the step table in the chat. Steps marked A run here;
-- steps marked B run in the Admin B window.
-- ---------------------------------------------------------------------

-- A0: check the isolation level (default in MySQL is REPEATABLE-READ)
SELECT @@transaction_isolation AS isolation_level;

-- A1: Admin A starts editing the Kubwa Village -> Berger Junction fare
--     and LOCKS that row with FOR UPDATE
START TRANSACTION;
SELECT fare_id, amount FROM fares
WHERE route_id = 1 AND from_stop_id = 1 AND to_stop_id = 6
FOR UPDATE;

-- A2: Admin A changes the fare (still not committed)
UPDATE fares SET amount = 1300.00
WHERE route_id = 1 AND from_stop_id = 1 AND to_stop_id = 6;

-- A3: Admin A saves the change (this releases the lock)
COMMIT;

-- A4: final value check
SELECT fare_id, amount FROM fares
WHERE route_id = 1 AND from_stop_id = 1 AND to_stop_id = 6;
