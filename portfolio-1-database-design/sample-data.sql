-- Wakawell portfolio: SAMPLE DATA
-- Simplified, illustrative data for selected Abuja corridors.
-- Coordinates and fares are approximate sample values, NOT Wakawell production data.
-- Safe to re-run: tables are emptied first, then refilled.

USE wakawell_portfolio;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE transfers;
TRUNCATE TABLE fares;
TRUNCATE TABLE route_stops;
TRUNCATE TABLE routes;
TRUNCATE TABLE landmarks;
TRUNCATE TABLE stops;
TRUNCATE TABLE corridors;
SET FOREIGN_KEY_CHECKS = 1;

-- Corridors
INSERT INTO corridors (corridor_id, name) VALUES
  (1, 'Kubwa Expressway'),
  (2, 'Central Area'),
  (3, 'Airport Road'),
  (4, 'Abuja-Keffi Expressway');

-- Stops (approximate coordinates)
INSERT INTO stops (stop_id, name, latitude, longitude) VALUES
  (1, 'Kubwa Village', 9.160000, 7.322000),
  (2, 'Phase 4 Kubwa', 9.147000, 7.338000),
  (3, 'Dutse Junction', 9.121000, 7.379000),
  (4, 'Gwarinpa Junction', 9.098000, 7.401000),
  (5, 'Mabushi', 9.080000, 7.443000),
  (6, 'Berger Junction', 9.074000, 7.463000),
  (7, 'Wuse Market', 9.069000, 7.472000),
  (8, 'Federal Secretariat', 9.048000, 7.500000),
  (9, 'Area 1 Junction', 9.031000, 7.480000),
  (10, 'Area 1 Shopping Plaza', 9.029500, 7.481500),
  (11, 'Kuchigoro', 8.995000, 7.430000),
  (12, 'Lugbe', 8.980000, 7.380000),
  (13, 'Airport Junction', 9.006000, 7.263000),
  (14, 'AYA', 9.045000, 7.525000),
  (15, 'Kugbo', 9.035000, 7.560000),
  (16, 'Nyanya Bridge', 9.026000, 7.578000),
  (17, 'Nyanya Market', 9.024500, 7.580500),
  (18, 'Mararaba', 9.010000, 7.595000);

-- Landmarks
INSERT INTO landmarks (landmark_id, name, type, stop_id) VALUES
  (1, 'Kubwa Village Market', 'market', 1),
  (2, 'NNPC Filling Station, Phase 4', 'filling station', 2),
  (3, 'Dutse Alhaji Junction', 'junction', 3),
  (4, 'Gwarinpa 1st Avenue Gate', 'junction', 4),
  (5, 'Mabushi Bus Stop', 'bus stop', 5),
  (6, 'Berger Roundabout', 'roundabout', 6),
  (7, 'Wuse Market Main Gate', 'market', 7),
  (8, 'Federal Secretariat Complex', 'government building', 8),
  (9, 'Area 1 Roundabout', 'roundabout', 9),
  (10, 'Area 1 Shopping Plaza', 'shopping centre', 10),
  (11, 'Kuchigoro Junction', 'junction', 11),
  (12, 'Lugbe FHA Junction', 'junction', 12),
  (13, 'Airport Road Toll Gate', 'toll gate', 13),
  (14, 'AYA Junction', 'junction', 14),
  (15, 'Kugbo Furniture Market', 'market', 15),
  (16, 'Nyanya Pedestrian Bridge', 'bridge', 16),
  (17, 'Nyanya Market', 'market', 17),
  (18, 'Mararaba Market', 'market', 18);

-- Routes
INSERT INTO routes (route_id, name, vehicle_type, corridor_id) VALUES
  (1, 'Kubwa - Berger', 'shared taxi', 1),
  (2, 'Kubwa - Wuse Market', 'bus', 1),
  (3, 'Berger - Area 1', 'shared taxi', 2),
  (4, 'Area 1 - Airport Junction', 'shared taxi', 3),
  (5, 'Federal Secretariat - Nyanya', 'bus', 4),
  (6, 'Nyanya - Mararaba', 'keke', 4);

-- Route stops (stop_order = position along the route)
INSERT INTO route_stops (route_id, stop_id, stop_order) VALUES
  (1, 1, 1),
  (1, 2, 2),
  (1, 3, 3),
  (1, 4, 4),
  (1, 5, 5),
  (1, 6, 6),
  (2, 1, 1),
  (2, 3, 2),
  (2, 5, 3),
  (2, 6, 4),
  (2, 7, 5),
  (3, 6, 1),
  (3, 7, 2),
  (3, 8, 3),
  (3, 9, 4),
  (4, 10, 1),
  (4, 11, 2),
  (4, 12, 3),
  (4, 13, 4),
  (5, 8, 1),
  (5, 14, 2),
  (5, 15, 3),
  (5, 16, 4),
  (6, 17, 1),
  (6, 18, 2);

-- Fares (in naira) between any two stops on the same route, in direction of travel
INSERT INTO fares (fare_id, route_id, from_stop_id, to_stop_id, amount) VALUES
  (1, 1, 1, 2, 200.00),  -- Kubwa - Berger: Kubwa Village to Phase 4 Kubwa
  (2, 1, 1, 3, 500.00),  -- Kubwa - Berger: Kubwa Village to Dutse Junction
  (3, 1, 1, 4, 700.00),  -- Kubwa - Berger: Kubwa Village to Gwarinpa Junction
  (4, 1, 1, 5, 1000.00),  -- Kubwa - Berger: Kubwa Village to Mabushi
  (5, 1, 1, 6, 1200.00),  -- Kubwa - Berger: Kubwa Village to Berger Junction
  (6, 1, 2, 3, 300.00),  -- Kubwa - Berger: Phase 4 Kubwa to Dutse Junction
  (7, 1, 2, 4, 500.00),  -- Kubwa - Berger: Phase 4 Kubwa to Gwarinpa Junction
  (8, 1, 2, 5, 800.00),  -- Kubwa - Berger: Phase 4 Kubwa to Mabushi
  (9, 1, 2, 6, 1000.00),  -- Kubwa - Berger: Phase 4 Kubwa to Berger Junction
  (10, 1, 3, 4, 200.00),  -- Kubwa - Berger: Dutse Junction to Gwarinpa Junction
  (11, 1, 3, 5, 500.00),  -- Kubwa - Berger: Dutse Junction to Mabushi
  (12, 1, 3, 6, 700.00),  -- Kubwa - Berger: Dutse Junction to Berger Junction
  (13, 1, 4, 5, 300.00),  -- Kubwa - Berger: Gwarinpa Junction to Mabushi
  (14, 1, 4, 6, 500.00),  -- Kubwa - Berger: Gwarinpa Junction to Berger Junction
  (15, 1, 5, 6, 200.00),  -- Kubwa - Berger: Mabushi to Berger Junction
  (16, 2, 1, 3, 300.00),  -- Kubwa - Wuse Market: Kubwa Village to Dutse Junction
  (17, 2, 1, 5, 600.00),  -- Kubwa - Wuse Market: Kubwa Village to Mabushi
  (18, 2, 1, 6, 750.00),  -- Kubwa - Wuse Market: Kubwa Village to Berger Junction
  (19, 2, 1, 7, 850.00),  -- Kubwa - Wuse Market: Kubwa Village to Wuse Market
  (20, 2, 3, 5, 300.00),  -- Kubwa - Wuse Market: Dutse Junction to Mabushi
  (21, 2, 3, 6, 450.00),  -- Kubwa - Wuse Market: Dutse Junction to Berger Junction
  (22, 2, 3, 7, 550.00),  -- Kubwa - Wuse Market: Dutse Junction to Wuse Market
  (23, 2, 5, 6, 150.00),  -- Kubwa - Wuse Market: Mabushi to Berger Junction
  (24, 2, 5, 7, 250.00),  -- Kubwa - Wuse Market: Mabushi to Wuse Market
  (25, 2, 6, 7, 100.00),  -- Kubwa - Wuse Market: Berger Junction to Wuse Market
  (26, 3, 6, 7, 200.00),  -- Berger - Area 1: Berger Junction to Wuse Market
  (27, 3, 6, 8, 400.00),  -- Berger - Area 1: Berger Junction to Federal Secretariat
  (28, 3, 6, 9, 600.00),  -- Berger - Area 1: Berger Junction to Area 1 Junction
  (29, 3, 7, 8, 200.00),  -- Berger - Area 1: Wuse Market to Federal Secretariat
  (30, 3, 7, 9, 400.00),  -- Berger - Area 1: Wuse Market to Area 1 Junction
  (31, 3, 8, 9, 200.00),  -- Berger - Area 1: Federal Secretariat to Area 1 Junction
  (32, 4, 10, 11, 300.00),  -- Area 1 - Airport Junction: Area 1 Shopping Plaza to Kuchigoro
  (33, 4, 10, 12, 600.00),  -- Area 1 - Airport Junction: Area 1 Shopping Plaza to Lugbe
  (34, 4, 10, 13, 1000.00),  -- Area 1 - Airport Junction: Area 1 Shopping Plaza to Airport Junction
  (35, 4, 11, 12, 300.00),  -- Area 1 - Airport Junction: Kuchigoro to Lugbe
  (36, 4, 11, 13, 700.00),  -- Area 1 - Airport Junction: Kuchigoro to Airport Junction
  (37, 4, 12, 13, 400.00),  -- Area 1 - Airport Junction: Lugbe to Airport Junction
  (38, 5, 8, 14, 150.00),  -- Federal Secretariat - Nyanya: Federal Secretariat to AYA
  (39, 5, 8, 15, 350.00),  -- Federal Secretariat - Nyanya: Federal Secretariat to Kugbo
  (40, 5, 8, 16, 500.00),  -- Federal Secretariat - Nyanya: Federal Secretariat to Nyanya Bridge
  (41, 5, 14, 15, 200.00),  -- Federal Secretariat - Nyanya: AYA to Kugbo
  (42, 5, 14, 16, 350.00),  -- Federal Secretariat - Nyanya: AYA to Nyanya Bridge
  (43, 5, 15, 16, 150.00),  -- Federal Secretariat - Nyanya: Kugbo to Nyanya Bridge
  (44, 6, 17, 18, 200.00);  -- Nyanya - Mararaba: Nyanya Market to Mararaba

-- Walking transfers (same-stop transfers are found by query, not stored)
INSERT INTO transfers (transfer_id, from_route_id, to_route_id, from_stop_id, to_stop_id, walking_note) VALUES
  (1, 3, 4, 9, 10, 'Walk about 3 minutes from the roundabout to the taxi rank at the shopping plaza.'),
  (2, 5, 6, 16, 17, 'Cross the pedestrian bridge; keke rank is beside the market entrance.');

-- Quick check: row counts per table
SELECT 'corridors' AS table_name, COUNT(*) AS row_count FROM corridors
UNION ALL SELECT 'stops', COUNT(*) FROM stops
UNION ALL SELECT 'landmarks', COUNT(*) FROM landmarks
UNION ALL SELECT 'routes', COUNT(*) FROM routes
UNION ALL SELECT 'route_stops', COUNT(*) FROM route_stops
UNION ALL SELECT 'fares', COUNT(*) FROM fares
UNION ALL SELECT 'transfers', COUNT(*) FROM transfers;
