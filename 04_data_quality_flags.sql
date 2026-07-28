-- =========================================================
-- MediCore Analytics — Data Quality Flagging
-- Run this AFTER 03_data_cleaning.sql
-- Adds a flag column to sales instead of deleting suspicious rows,
-- so the raw data is preserved but easy to include/exclude in
-- analysis queries later.
-- =========================================================

-- -------------------------------
-- 1. Add the flag column
-- -------------------------------
ALTER TABLE sales ADD COLUMN data_quality_flag VARCHAR(30);

-- -------------------------------
-- 2. Flag extreme quantity outliers
-- Quantities of 500+ are implausible for these transaction types
-- (wholesale-scale volume showing up in retail-style sales).
-- -------------------------------
UPDATE sales
SET data_quality_flag = 'quantity_outlier'
WHERE quantity > 100;

-- -------------------------------
-- 3. Flag price mismatches
-- Sale price differs from the product's current listed price.
-- Not necessarily wrong (could be a historical price, a discount,
-- or a negotiated rate) — flagged for visibility, not corrected.
-- -------------------------------
UPDATE sales s
SET data_quality_flag = CASE
    WHEN data_quality_flag IS NULL THEN 'price_mismatch'
    ELSE data_quality_flag || ',price_mismatch'
END
FROM products p
WHERE s.product_id = p.product_id
  AND s.unit_price <> p.unit_price;

-- -------------------------------
-- 4. Quick verification
-- -------------------------------
SELECT data_quality_flag, COUNT(*)
FROM sales
GROUP BY data_quality_flag
ORDER BY data_quality_flag NULLS FIRST;
