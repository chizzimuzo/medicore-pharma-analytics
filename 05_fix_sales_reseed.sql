-- =========================================================
-- MediCore Analytics — FIX: Reseed sales table correctly
-- The original sales generation had a bug where the JOIN-based
-- random product selection failed to vary per row, causing every
-- sale to be assigned product_id 19. This script wipes sales and
-- rebuilds it with product_id assigned directly per row instead
-- of through a join, which is more reliable.
-- =========================================================

SELECT setseed(0.42);

-- Wipe the sales table completely and restart the sale_id counter
TRUNCATE TABLE sales RESTART IDENTITY;

-- Rebuild ~15,000 sales rows with a properly randomized product_id
INSERT INTO sales (sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost)
SELECT
    CASE WHEN random() < 0.01
        THEN (sale_date + INTERVAL '9 years')::date
        ELSE sale_date
    END,
    customer_id,
    product_id,
    employee_id,
    warehouse_id,
    CASE WHEN random() < 0.02
        THEN 500 + floor(random() * 500)::int
        ELSE quantity
    END,
    CASE WHEN random() < 0.05
        THEN ROUND((unit_price * (0.5 + random()))::numeric, 2)
        ELSE unit_price
    END,
    unit_cost
FROM (
    SELECT
        (DATE '2023-01-01' + (random() * (DATE '2025-12-31' - DATE '2023-01-01'))::int)::date AS sale_date,
        (SELECT customer_id FROM customers ORDER BY random() LIMIT 1) AS customer_id,
        pid AS product_id,
        (1 + floor(random() * 10))::int AS employee_id,
        (1 + floor(random() * 6))::int AS warehouse_id,
        (1 + floor(random() * 40))::int AS quantity,
        p.unit_price,
        p.unit_cost
    FROM (
        SELECT (1 + floor(random() * 30))::int AS pid
        FROM generate_series(1, 15000)
    ) picks
    JOIN products p ON p.product_id = picks.pid
) sub;

-- Re-add the ~150 duplicate rows (same double-entry simulation as before)
INSERT INTO sales (sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost)
SELECT sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost
FROM sales
ORDER BY random()
LIMIT 150;

-- -------------------------------
-- Verification: confirm sales are now spread across products
-- -------------------------------
SELECT product_id, COUNT(*) AS num_sales
FROM sales
GROUP BY product_id
ORDER BY product_id;
