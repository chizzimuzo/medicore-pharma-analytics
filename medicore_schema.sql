-- =========================================================
-- MediCore Pharmaceuticals Ltd. — Analytics Database Schema
-- Step 3: Database Schema Creation
-- Database engine: PostgreSQL
-- =========================================================

-- Run this first if the database doesn't exist yet:
-- CREATE DATABASE medicore_analytics;
-- Then connect to it (\c medicore_analytics in psql) before running the rest.

-- -------------------------------
-- 1. SUPPLIERS
-- -------------------------------
CREATE TABLE suppliers (
    supplier_id     SERIAL PRIMARY KEY,
    supplier_name   VARCHAR(100) NOT NULL,
    contact_person  VARCHAR(100),
    phone           VARCHAR(20),
    email           VARCHAR(100),
    country         VARCHAR(50) DEFAULT 'Nigeria',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------
-- 2. WAREHOUSES
-- -------------------------------
CREATE TABLE warehouses (
    warehouse_id    SERIAL PRIMARY KEY,
    warehouse_name  VARCHAR(100) NOT NULL,
    city            VARCHAR(50) NOT NULL,
    region          VARCHAR(50) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------
-- 3. PRODUCTS
-- Every product belongs to one category and comes from one supplier.
-- -------------------------------
CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(150) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    supplier_id     INT NOT NULL REFERENCES suppliers(supplier_id),
    unit            VARCHAR(20),          -- e.g. 'pack', 'bottle', 'box'
    unit_cost       NUMERIC(10,2) NOT NULL CHECK (unit_cost >= 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_category CHECK (category IN (
        'Antibiotics','Antimalarials','Analgesics','Antihypertensives',
        'Antidiabetics','Vitamins & Supplements','Gastrointestinal Drugs',
        'Respiratory Drugs','Dermatological Products','Medical Consumables'
    ))
);

-- -------------------------------
-- 4. CUSTOMERS
-- Every customer belongs to one state (and by extension one region).
-- -------------------------------
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    customer_name   VARCHAR(150) NOT NULL,
    customer_type   VARCHAR(50) NOT NULL CHECK (customer_type IN (
        'Community Pharmacy','Hospital','Clinic','Pharmaceutical Wholesaler'
    )),
    state           VARCHAR(50) NOT NULL,
    region          VARCHAR(50) NOT NULL CHECK (region IN (
        'South West','South East','South South',
        'North Central','North East','North West'
    )),
    phone           VARCHAR(20),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------
-- 5. EMPLOYEES
-- Sales reps and other staff, tied to a department and warehouse.
-- -------------------------------
CREATE TABLE employees (
    employee_id     SERIAL PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    department      VARCHAR(50) NOT NULL CHECK (department IN (
        'Sales','Procurement','Warehouse','Finance','Logistics','Customer Service'
    )),
    role            VARCHAR(50),
    warehouse_id    INT REFERENCES warehouses(warehouse_id),
    hire_date       DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------
-- 6. INVENTORY
-- Batch-level stock: every product has a batch number and expiry date,
-- and is stored in one warehouse.
-- -------------------------------
CREATE TABLE inventory (
    inventory_id       SERIAL PRIMARY KEY,
    product_id         INT NOT NULL REFERENCES products(product_id),
    warehouse_id       INT NOT NULL REFERENCES warehouses(warehouse_id),
    batch_number       VARCHAR(50) NOT NULL,
    expiry_date        DATE NOT NULL,
    quantity_on_hand   INT NOT NULL CHECK (quantity_on_hand >= 0),
    date_received      DATE DEFAULT CURRENT_DATE,
    UNIQUE (product_id, warehouse_id, batch_number)
);

-- -------------------------------
-- 7. SALES
-- Every sale: one customer, one product, one sales rep, one warehouse.
-- Profit = Sales Amount − Cost Amount, calculated at analysis time
-- (kept out of the table so it never goes stale vs. unit_cost/unit_price).
-- -------------------------------
CREATE TABLE sales (
    sale_id         SERIAL PRIMARY KEY,
    sale_date       DATE NOT NULL,
    customer_id     INT NOT NULL REFERENCES customers(customer_id),
    product_id      INT NOT NULL REFERENCES products(product_id),
    employee_id     INT NOT NULL REFERENCES employees(employee_id),
    warehouse_id    INT NOT NULL REFERENCES warehouses(warehouse_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    unit_cost       NUMERIC(10,2) NOT NULL CHECK (unit_cost >= 0),
    sales_amount    NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    cost_amount     NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------
-- Helpful indexes for the KPIs you'll be querying later
-- (top products, top customers, regional trends, expiry risk)
-- -------------------------------
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_product ON sales(product_id);
CREATE INDEX idx_sales_customer ON sales(customer_id);
CREATE INDEX idx_inventory_expiry ON inventory(expiry_date);
CREATE INDEX idx_products_category ON products(category);
