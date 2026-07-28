-- =========================================================
-- MediCore Analytics — Seed Data Part 2: Inventory & Sales
-- Run this AFTER 01_seed_reference_data.sql
-- Generates bulk inventory and sales records using random data.
-- Intentionally includes data quality issues for cleaning practice:
--   - inconsistent batch number formatting
--   - blank batch numbers
--   - some sale prices that don't match the product's listed price
--   - quantity outliers
--   - duplicate sales rows
--   - a handful of mistyped (future) sale dates
-- =========================================================

SELECT setseed(0.42); -- reproducible randomness

-- -------------------------------
-- INVENTORY
-- 3-5 batches per product per warehouse, with expiry dates spanning
-- already-expired to far-future (supports expiry-risk analysis).
-- Batch number formatting is deliberately inconsistent.
-- -------------------------------
INSERT INTO inventory (product_id, warehouse_id, batch_number, expiry_date, quantity_on_hand, date_received)
SELECT
    p.product_id,
    w.warehouse_id,
    CASE
        WHEN random() < 0.15 THEN ''                                            -- blank batch number
        WHEN random() < 0.35 THEN 'batch-' || LPAD((gs)::text, 4, '0')          -- lowercase, hyphen
        WHEN random() < 0.55 THEN 'BATCH' || LPAD((gs)::text, 4, '0')           -- uppercase, no separator
        ELSE 'B-' || LPAD((gs)::text, 4, '0')                                   -- standard format
    END AS batch_number,
    (DATE '2023-01-01' + (random() * (DATE '2027-12-31' - DATE '2023-01-01'))::int)::date AS expiry_date,
    (10 + floor(random() * 490))::int AS quantity_on_hand,
    (DATE '2022-06-01' + (random() * (DATE '2025-06-01' - DATE '2022-06-01'))::int)::date AS date_received
FROM products p
CROSS JOIN warehouses w
CROSS JOIN generate_series(1, 3) gs
WHERE random() < 0.7; -- not every product is in every warehouse

-- -------------------------------
-- SALES
-- ~15,000 transactions across 2023-01-01 to 2025-12-31.
-- -------------------------------
INSERT INTO sales (sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost)
SELECT
    CASE WHEN random() < 0.01
        THEN (sale_date + INTERVAL '9 years')::date  -- typo year, e.g. 2023 -> 2032
        ELSE sale_date
    END,
    customer_id,
    product_id,
    employee_id,
    warehouse_id,
    CASE WHEN random() < 0.02
        THEN 500 + floor(random() * 500)::int          -- outlier quantity
        ELSE quantity
    END,
    CASE WHEN random() < 0.05
        THEN ROUND((unit_price * (0.5 + random()))::numeric, 2)  -- mismatched/typo price
        ELSE unit_price
    END,
    unit_cost
FROM (
    SELECT
        (DATE '2023-01-01' + (random() * (DATE '2025-12-31' - DATE '2023-01-01'))::int)::date AS sale_date,
        (1 + floor(random() * 25))::int AS customer_id,   -- includes the messy duplicate customers
        p.product_id,
        (1 + floor(random() * 10))::int AS employee_id,   -- employee_ids 1-10 are the sales reps
        (1 + floor(random() * 6))::int AS warehouse_id,
        (1 + floor(random() * 40))::int AS quantity,
        p.unit_price,
        p.unit_cost
    FROM generate_series(1, 15000) gs
    JOIN products p ON p.product_id = (1 + floor(random() * 30))::int
) sub;

-- Inject ~150 exact duplicate sales rows (accidental double-entry scenario)
INSERT INTO sales (sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost)
SELECT sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost
FROM sales
ORDER BY random()
LIMIT 150;
