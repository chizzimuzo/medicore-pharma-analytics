-- =========================================================
-- MediCore Analytics — Seed Data Part 1: Reference Tables
-- Run this AFTER medicore_schema.sql
-- Populates: suppliers, warehouses, employees, customers, products
-- =========================================================

-- -------------------------------
-- SUPPLIERS
-- -------------------------------
INSERT INTO suppliers (supplier_name, contact_person, phone, email, country) VALUES
('Pfizer Nigeria Ltd', 'Adaeze Okonkwo', '+2348012345001', 'contact@pfizer-ng.com', 'Nigeria'),
('GSK Nigeria', 'Emeka Nwosu', '+2348012345002', 'sales@gsk-ng.com', 'Nigeria'),
('Emzor Pharmaceuticals', 'Funke Ajayi', '+2348012345003', 'info@emzorpharma.com', 'Nigeria'),
('Fidson Healthcare', 'Ibrahim Musa', '+2348012345004', 'sales@fidson.com', 'Nigeria'),
('May & Baker Nigeria', 'Chiamaka Eze', '+2348012345005', 'contact@may-baker.com', 'Nigeria'),
('Swiss Pharma Nigeria', 'Tunde Bakare', '+2348012345006', 'info@swisspharma-ng.com', 'Nigeria'),
('Juhel Pharmaceuticals', 'Ngozi Obi', '+2348012345007', 'sales@juhel.com', 'Nigeria'),
('Neimeth International', 'Segun Adeyemi', '+2348012345008', 'contact@neimeth.com', 'Nigeria');

-- -------------------------------
-- WAREHOUSES
-- -------------------------------
INSERT INTO warehouses (warehouse_name, city, region) VALUES
('Lagos Central Warehouse', 'Lagos', 'South West'),
('Abuja Distribution Hub', 'Abuja', 'North Central'),
('Port Harcourt Depot', 'Port Harcourt', 'South South'),
('Kano Regional Store', 'Kano', 'North West'),
('Enugu Warehouse', 'Enugu', 'South East'),
('Maiduguri Depot', 'Maiduguri', 'North East');

-- -------------------------------
-- EMPLOYEES
-- -------------------------------
INSERT INTO employees (full_name, department, role, warehouse_id, hire_date) VALUES
('Chinedu Okafor', 'Sales', 'Sales Representative', 1, '2022-03-14'),
('Amina Yusuf', 'Sales', 'Sales Representative', 2, '2022-06-01'),
('Blessing Eze', 'Sales', 'Sales Representative', 1, '2023-01-10'),
('Oluwaseun Bello', 'Sales', 'Senior Sales Rep', 3, '2021-09-05'),
('Fatima Abdullahi', 'Sales', 'Sales Representative', 4, '2023-04-20'),
('Emmanuel Chukwu', 'Sales', 'Sales Representative', 5, '2022-11-15'),
('Grace Udo', 'Sales', 'Sales Representative', 1, '2023-07-01'),
('Musa Ibrahim', 'Sales', 'Sales Representative', 6, '2022-02-18'),
('Ifeoma Nwachukwu', 'Sales', 'Sales Representative', 2, '2023-03-09'),
('Tobi Ogunleye', 'Sales', 'Senior Sales Rep', 3, '2021-05-22'),
('Halima Sani', 'Warehouse', 'Warehouse Manager', 4, '2020-08-12'),
('Chukwuemeka Obi', 'Procurement', 'Procurement Officer', 1, '2021-01-30'),
('Zainab Lawal', 'Finance', 'Finance Officer', 2, '2022-04-11'),
('Damilola Adeyinka', 'Logistics', 'Logistics Coordinator', 1, '2022-09-25'),
('Peter Nnamdi', 'Sales', 'Sales Representative', 5, '2023-02-14');

-- -------------------------------
-- CUSTOMERS
-- -------------------------------
INSERT INTO customers (customer_name, customer_type, state, region, phone) VALUES
('Goodhealth Pharmacy', 'Community Pharmacy', 'Lagos', 'South West', '+2348023456001'),
('Lagos University Teaching Hospital', 'Hospital', 'Lagos', 'South West', '+2348023456002'),
('Wellness Plus Pharmacy', 'Community Pharmacy', 'Ogun', 'South West', '+2348023456003'),
('Abuja General Hospital', 'Hospital', 'FCT', 'North Central', '+2348023456004'),
('Capital Health Clinic', 'Clinic', 'FCT', 'North Central', '+2348023456005'),
('Northern Pharma Wholesalers', 'Pharmaceutical Wholesaler', 'Kano', 'North West', '+2348023456006'),
('Kano State Hospital', 'Hospital', 'Kano', 'North West', '+2348023456007'),
('Rivers Community Clinic', 'Clinic', 'Rivers', 'South South', '+2348023456008'),
('Port Harcourt Medical Centre', 'Hospital', 'Rivers', 'South South', '+2348023456009'),
('Eastern Wholesale Pharma', 'Pharmaceutical Wholesaler', 'Enugu', 'South East', '+2348023456010'),
('Enugu City Pharmacy', 'Community Pharmacy', 'Enugu', 'South East', '+2348023456011'),
('Maiduguri Central Hospital', 'Hospital', 'Borno', 'North East', '+2348023456012'),
('Trust Care Pharmacy', 'Community Pharmacy', 'Kaduna', 'North West', '+2348023456013'),
('Sunrise Medical Clinic', 'Clinic', 'Oyo', 'South West', '+2348023456014'),
('Ibadan Pharma Hub', 'Community Pharmacy', 'Oyo', 'South West', '+2348023456015'),
('Benin General Hospital', 'Hospital', 'Edo', 'South South', '+2348023456016'),
('Delta Pharmacy Chain', 'Community Pharmacy', 'Delta', 'South South', '+2348023456017'),
('Jos Health Centre', 'Clinic', 'Plateau', 'North Central', '+2348023456018'),
('Sokoto Regional Hospital', 'Hospital', 'Sokoto', 'North West', '+2348023456019'),
('Owerri Wholesale Meds', 'Pharmaceutical Wholesaler', 'Imo', 'South East', '+2348023456020');

-- -------------------------------
-- MESSY DATA (intentional, for data cleaning practice)
-- Issues: extra whitespace, inconsistent casing, near-duplicate
-- entries, blank/missing phone numbers.
-- -------------------------------
INSERT INTO customers (customer_name, customer_type, state, region, phone) VALUES
('  Goodhealth Pharmacy  ', 'Community Pharmacy', 'Lagos', 'South West', '+2348023456001'),
('GOODHEALTH PHARMACY', 'Community Pharmacy', 'Lagos', 'South West', NULL),
('wellness plus pharmacy', 'Community Pharmacy', 'Ogun', 'South West', ''),
('Enugu City  Pharmacy', 'Community Pharmacy', 'Enugu', 'South East', '   '),
('trust care pharmacy ', 'Community Pharmacy', 'Kaduna', 'North West', '+2348023456013');

INSERT INTO suppliers (supplier_name, contact_person, phone, email, country) VALUES
('emzor pharmaceuticals', 'Funke Ajayi', '+2348012345003', 'INFO@EMZORPHARMA.COM', 'Nigeria'),
(' Fidson Healthcare', NULL, '', 'sales@fidson.com', 'nigeria');

-- -------------------------------
-- PRODUCTS
-- -------------------------------
INSERT INTO products (product_name, category, supplier_id, unit, unit_cost, unit_price) VALUES
('Amoxicillin 500mg', 'Antibiotics', 1, 'pack', 450.00, 650.00),
('Ciprofloxacin 500mg', 'Antibiotics', 2, 'pack', 520.00, 750.00),
('Artemether/Lumefantrine 20/120mg', 'Antimalarials', 3, 'pack', 380.00, 550.00),
('Chloroquine 250mg', 'Antimalarials', 4, 'pack', 220.00, 350.00),
('Paracetamol 500mg', 'Analgesics', 3, 'pack', 150.00, 250.00),
('Ibuprofen 400mg', 'Analgesics', 5, 'pack', 200.00, 320.00),
('Diclofenac 50mg', 'Analgesics', 2, 'pack', 180.00, 290.00),
('Amlodipine 10mg', 'Antihypertensives', 1, 'pack', 400.00, 600.00),
('Lisinopril 10mg', 'Antihypertensives', 6, 'pack', 420.00, 630.00),
('Metformin 500mg', 'Antidiabetics', 3, 'pack', 300.00, 450.00),
('Glibenclamide 5mg', 'Antidiabetics', 7, 'pack', 280.00, 420.00),
('Vitamin C 1000mg', 'Vitamins & Supplements', 4, 'bottle', 350.00, 550.00),
('Multivitamin Syrup', 'Vitamins & Supplements', 3, 'bottle', 500.00, 780.00),
('Folic Acid 5mg', 'Vitamins & Supplements', 5, 'pack', 150.00, 240.00),
('Omeprazole 20mg', 'Gastrointestinal Drugs', 2, 'pack', 380.00, 580.00),
('ORS Sachets', 'Gastrointestinal Drugs', 3, 'box', 100.00, 180.00),
('Antacid Suspension', 'Gastrointestinal Drugs', 4, 'bottle', 320.00, 500.00),
('Salbutamol Inhaler', 'Respiratory Drugs', 1, 'unit', 900.00, 1350.00),
('Cough Syrup', 'Respiratory Drugs', 6, 'bottle', 280.00, 450.00),
('Antihistamine Tablets', 'Respiratory Drugs', 7, 'pack', 200.00, 320.00),
('Antifungal Cream', 'Dermatological Products', 8, 'tube', 350.00, 550.00),
('Antiseptic Ointment', 'Dermatological Products', 3, 'tube', 250.00, 400.00),
('Hydrocortisone Cream', 'Dermatological Products', 2, 'tube', 300.00, 480.00),
('Disposable Syringes 5ml', 'Medical Consumables', 5, 'box', 1500.00, 2200.00),
('Surgical Gloves (100pk)', 'Medical Consumables', 6, 'box', 2000.00, 2900.00),
('Face Masks (50pk)', 'Medical Consumables', 7, 'box', 1200.00, 1800.00),
('Cotton Wool Roll', 'Medical Consumables', 8, 'unit', 300.00, 480.00),
('Wound Dressing Pack', 'Medical Consumables', 4, 'pack', 600.00, 900.00),
('Azithromycin 250mg', 'Antibiotics', 1, 'pack', 600.00, 850.00),
('Doxycycline 100mg', 'Antibiotics', 2, 'pack', 350.00, 520.00);
