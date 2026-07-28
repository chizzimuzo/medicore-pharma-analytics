-- =========================================================
-- MediCore Analytics — FIX #2: Reseed sales with correct
-- randomization for BOTH product_id and customer_id.
--
-- Same root cause as the product_id bug: putting random() inside
-- a JOIN condition or a correlated-looking subquery doesn't
-- reliably re-evaluate per row in PostgreSQL. This version avoids
-- that entirely by picking a random ARRAY INDEX directly in the
-- SELECT list, which is always evaluated fresh per row.
-- =========================================================

SELECT setseed(0.42);

TRUNCATE TABLE sales RESTART IDENTITY;

-- Build the arrays of valid IDs once, then use them for every row
WITH id_lists AS (
    SELECT
        (SELECT array_agg(customer_id) FROM customers) AS customer_ids,
        (SELECT array_agg(product_id) FROM products) AS product_ids
)
INSERT INTO sales (sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost)
SELECT
    CASE WHEN random() < 0.01
        THEN (sale_date + INTERVAL '9 years')::date
        ELSE sale_date
    END,
    picked_customer_id,
    picked_product_id,
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
        il.customer_ids[1 + floor(random() * array_length(il.customer_ids, 1))::int] AS picked_customer_id,
        il.product_ids[1 + floor(random() * array_length(il.product_ids, 1))::int] AS picked_product_id,
        (1 + floor(random() * 10))::int AS employee_id,
        (1 + floor(random() * 6))::int AS warehouse_id,
        (1 + floor(random() * 40))::int AS quantity
    FROM generate_series(1, 15000)
    CROSS JOIN id_lists il
) picks
JOIN products p ON p.product_id = picks.picked_product_id;

-- Re-add the ~150 duplicate rows (same double-entry simulation as before)
INSERT INTO sales (sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost)
SELECT sale_date, customer_id, product_id, employee_id, warehouse_id, quantity, unit_price, unit_cost
FROM sales
ORDER BY random()
LIMIT 150;

-- -------------------------------
-- Verification: confirm BOTH product_id and customer_id are spread out
-- -------------------------------
SELECT product_id, COUNT(*) AS num_sales
FROM sales
GROUP BY product_id
ORDER BY product_id;

SELECT customer_id, COUNT(*) AS num_sales
FROM sales
GROUP BY customer_id
ORDER BY customer_id;
