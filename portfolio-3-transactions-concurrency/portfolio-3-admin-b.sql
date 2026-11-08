-- =====================================================================
-- Wakawell portfolio – PORTFOLIO 3: "Admin B" (second connection window)
-- Run each step ONLY when the step table in the chat says so.
-- =====================================================================

USE wakawell_portfolio;

-- B1: Admin B tries to edit the SAME fare at the same time.
--     Because Admin A holds a lock, this query WAITS (spinner) until
--     Admin A commits. When it finishes, it shows A's new value (1300).
START TRANSACTION;
SELECT fare_id, amount FROM fares
WHERE route_id = 1 AND from_stop_id = 1 AND to_stop_id = 6
FOR UPDATE;

-- B2: Admin B now makes their change based on the CORRECT current value
UPDATE fares SET amount = amount + 50
WHERE route_id = 1 AND from_stop_id = 1 AND to_stop_id = 6;
COMMIT;

-- B3: check: 1300 + 50 = 1350, so neither admin's change was lost
SELECT fare_id, amount FROM fares
WHERE route_id = 1 AND from_stop_id = 1 AND to_stop_id = 6;
