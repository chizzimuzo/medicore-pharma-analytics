-- =========================================================
-- MediCore Analytics — Data Cleaning Script
-- Run this AFTER 02_seed_transactional_data.sql
-- Fixes: duplicate customers, inconsistent phone number formats,
--        inconsistent batch numbers, duplicate sales rows.
-- =========================================================

-- -------------------------------
-- 1. MERGE DUPLICATE CUSTOMERS
-- For each duplicate group: repoint their sales to the canonical
-- (lowest) customer_id, then delete the duplicate customer row.
-- -------------------------------

-- Wellness Plus Pharmacy: keep 3, remove 23
UPDATE sales SET customer_id = 3 WHERE customer_id = 23;
DELETE FROM customers WHERE customer_id = 23;

-- Goodhealth Pharmacy: keep 1, remove 21 and 22
UPDATE sales SET customer_id = 1 WHERE customer_id IN (21, 22);
DELETE FROM customers WHERE customer_id IN (21, 22);

-- Enugu City Pharmacy: keep 11, remove 24
UPDATE sales SET customer_id = 11 WHERE customer_id = 24;
DELETE FROM customers WHERE customer_id = 24;

-- Trust Care Pharmacy: keep 13, remove 25
UPDATE sales SET customer_id = 13 WHERE customer_id = 25;
DELETE FROM customers WHERE customer_id = 25;

-- Clean up any remaining whitespace/casing on the surviving customer names
UPDATE customers
SET customer_name = regexp_replace(TRIM(customer_name), '\s+', ' ', 'g');

-- -------------------------------
-- 2. STANDARDIZE PHONE NUMBERS
-- NULL, '', and whitespace-only all mean "no phone number" —
-- collapse them all to a single consistent representation: NULL.
-- -------------------------------
UPDATE customers
SET phone = NULL
WHERE phone IS NOT NULL AND TRIM(phone) = '';

UPDATE suppliers
SET phone = NULL
WHERE phone IS NOT NULL AND TRIM(phone) = '';

-- -------------------------------
-- 3. CLEAN UP SUPPLIERS TEXT FIELDS
-- Same whitespace/casing fix, plus lowercase emails and country names
-- standardized to proper case.
-- -------------------------------
UPDATE suppliers
SET supplier_name = regexp_replace(TRIM(supplier_name), '\s+', ' ', 'g'),
    email = LOWER(TRIM(email)),
    country = INITCAP(TRIM(country));

-- Remove the exact-duplicate supplier rows created by messy data
-- (same supplier_name after cleaning, keep the lowest supplier_id)
DELETE FROM suppliers a
USING suppliers b
WHERE a.supplier_id > b.supplier_id
  AND LOWER(a.supplier_name) = LOWER(b.supplier_name);

-- -------------------------------
-- 4. STANDARDIZE INVENTORY BATCH NUMBERS
-- Formats found: 'batch-0001', 'BATCH0001', 'B-0001', and blank ''.
-- Standardize all non-blank ones to the 'B-0001' format.
-- Blank batch numbers are left as NULL to flag them as missing data
-- (rather than pretending we know the batch number).
-- -------------------------------
UPDATE inventory
SET batch_number = NULL
WHERE TRIM(batch_number) = '';

UPDATE inventory
SET batch_number = 'B-' || regexp_replace(batch_number, '[^0-9]', '', 'g')
WHERE batch_number IS NOT NULL
  AND batch_number !~ '^B-[0-9]+$';

-- -------------------------------
-- 5. REMOVE DUPLICATE SALES ROWS
-- Exact duplicates (same customer, product, employee, warehouse,
-- date, quantity, price) are almost certainly double-entry errors.
-- Keep the lowest sale_id in each duplicate group, delete the rest.
-- -------------------------------
DELETE FROM sales a
USING sales b
WHERE a.sale_id > b.sale_id
  AND a.sale_date = b.sale_date
  AND a.customer_id = b.customer_id
  AND a.product_id = b.product_id
  AND a.employee_id = b.employee_id
  AND a.warehouse_id = b.warehouse_id
  AND a.quantity = b.quantity
  AND a.unit_price = b.unit_price
  AND a.unit_cost = b.unit_cost;

-- -------------------------------
-- 6. FLAG (DON'T DELETE) SUSPICIOUS SALES ROWS
-- Future-dated sales and extreme quantity outliers are flagged for
-- review rather than deleted outright — deleting real transactional
-- data is risky without knowing the true correct value.
-- Run these as SELECTs to review before deciding what to do.
-- -------------------------------

-- Sales dated in the future (the "typo year" rows)
SELECT * FROM sales WHERE sale_date > CURRENT_DATE ORDER BY sale_date DESC;

-- Extreme quantity outliers (order of magnitude above normal range)
SELECT * FROM sales WHERE quantity > 100 ORDER BY quantity DESC;

-- Sales where unit_price doesn't match the product's current listed price
SELECT s.sale_id, s.product_id, p.product_name, s.unit_price AS sale_price, p.unit_price AS listed_price
FROM sales s
JOIN products p ON p.product_id = s.product_id
WHERE s.unit_price <> p.unit_price
ORDER BY s.sale_id;
