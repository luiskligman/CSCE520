-- CSCE 520  Project 5  Luis Kligman
-- Point of Sale System Database Data Script
USE project5;

-- STORES
INSERT INTO stores (store_name, address, city, state, zip, phone, tax_rate) VALUES
     ('Klig''s Kites Myrtle Beach', '1000 Ocean Blvd', 'Myrtle Beach', 'SC', '29577', '843-555-0101', 0.0800);

-- CATEGORIES
INSERT INTO categories (category_name, description) VALUES
     ('Kites',       'Single line, dual line, and power kites')
    ,('Accessories', 'Lines, winders, handles, and hardware')
    ,('Apparel',     'Branded clothing and hats')
    ,('Toys',        'Beach toys and novelty items');

-- VENDORS
INSERT INTO vendors (vendor_name, contact_name, email, phone, address) VALUES
     ('HQ Kites & Designs',   'Mark Stevens',  'mark@hqkites.com',     '800-555-0201', '123 Kite Ln, Boulder, CO 80301')
    ,('Prism Kite Technology', 'Laura Chen',    'laura@prismkites.com', '800-555-0202', '456 Wind Ave, Seattle, WA 98101')
    ,('Premier Kites',         'Tom Nguyen',    'tom@premierkites.com', '800-555-0203', '789 Sky Rd, Richmond, BC V6Y 1A1');

-- PRODUCTS
-- category_id: 1=Kites, 2=Accessories, 3=Apparel, 4=Toys
-- vendor_id:   1=HQ, 2=Prism, 3=Premier
INSERT INTO products (category_id, vendor_id, sku, product_name, description, unit_price, cost, quantity_on_hand) VALUES
     (1, 1, 'HQ-HYPER-M',   'HQ Hyper Kite Medium',       'High performance dual line kite, medium size',   89.99,  45.00, 12)
    ,(1, 1, 'HQ-BEAMER-6',  'HQ Beamer 6 Power Kite',     '6 sqm foil power kite for land boarding',       249.99, 130.00,  6)
    ,(1, 2, 'PR-QUANTUM2',  'Prism Quantum 2.0',           'Precision dual line sport kite',                119.99,  60.00, 10)
    ,(1, 2, 'PR-NEXUS2',    'Prism Nexus 2.0',             'Beginner friendly dual line kite',               79.99,  38.00, 15)
    ,(1, 3, 'PM-STOWAWAY',  'Premier Stowaway Diamond',    'Compact single line travel kite',                29.99,  12.00, 20)
    ,(2, 1, 'HQ-LINE-100',  '100ft Dyneema Flying Line',   '100ft 90lb dyneema line set with winder',        24.99,  10.00, 30)
    ,(2, 2, 'PR-HANDLE-PR', 'Prism Padded Handles',        'Foam padded dual line handles, pair',            19.99,   8.00, 25)
    ,(2, 3, 'PM-WINDER-LG', 'Large Line Winder',           'Heavy duty plastic line winder, large',           9.99,   3.50, 40)
    ,(3, 1, 'AP-HAT-KK',    'Klig''s Kites Logo Hat',      'Embroidered logo baseball cap, one size',        24.99,   8.00, 50)
    ,(3, 1, 'AP-TEE-KK-M',  'Klig''s Kites T-Shirt Medium','Screen printed logo tee, medium',                19.99,   6.00, 35)
    ,(4, 3, 'TY-SPINR-AST', 'Spinning Beach Toy Assorted', 'Colorful spinning wind toy, colors vary',         7.99,   2.50, 60);

-- EMPLOYEES
-- All employees belong to store_id = 1
INSERT INTO employees (store_id, first_name, last_name, email, phone, role, hire_date, is_active) VALUES
     (1, 'Bruce',  'Kligman', 'bruce@kligskites.com',  '843-555-0301', 'Manager',  '2010-03-15', TRUE)
    ,(1, 'Luis',   'Kligman', 'luis@kligskites.com',   '843-555-0302', 'Manager',  '2018-06-01', TRUE)
    ,(1, 'Sarah',  'Mullins', 'sarah@kligskites.com',  '843-555-0303', 'Cashier',  '2021-05-10', TRUE)
    ,(1, 'Derek',  'Hanna',   'derek@kligskites.com',  '843-555-0304', 'Cashier',  '2022-03-22', TRUE)
    ,(1, 'Monica', 'Tran',    'monica@kligskites.com', '843-555-0305', 'Cashier',  '2023-01-15', FALSE);

-- EMPLOYEE_CREDENTIALS
-- 1:1 with employees -- one credential record per employee
INSERT INTO employee_credentials (employee_id, username, password_hash, last_login) VALUES
     (1, 'bruce.kligman', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', '2024-11-01 08:30:00')
    ,(2, 'luis.kligman',  'b94d27b9934d3e08a52e52d7da7dabfac484efe04294e576e8e2c9f84e5c81f2', '2024-11-05 09:15:00')
    ,(3, 'sarah.mullins', 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', '2024-10-30 10:00:00')
    ,(4, 'derek.hanna',   '2c624232cdd221771294dfbb310acbc8a3f2e082e6f31df8636b77a45924520d', '2024-11-04 08:45:00')
    ,(5, 'monica.tran',   '19581e27de7ced00ff1ce50b2047e7a567c76b1cbaebabe5ef03f7c3017bb5b7', '2024-06-01 09:00:00');

-- CUSTOMERS
-- customer_id 1-4 will be used in transactions
-- demonstrates 1:many (customer has many transactions)
INSERT INTO customers (first_name, last_name, email, phone) VALUES
     ('James',   'Whitfield', 'james.whitfield@email.com', '843-555-0401')
    ,('Patricia','Owens',     'pat.owens@email.com',       '843-555-0402')
    ,('Carlos',  'Rivera',    'carlos.rivera@email.com',   '843-555-0403')
    ,('Angela',  'Kim',       'angela.kim@email.com',      '843-555-0404');

-- TRANSACTIONS
-- transaction 1,2,3: linked to a customer (1:many)
-- transaction 4,5:   customer_id NULL = guest checkout (demonstrates 0:many / nullable FK)
INSERT INTO transactions (store_id, employee_id, customer_id, transaction_date, subtotal, tax_amount, total_amount, status) VALUES
     (1, 3, 1, '2024-10-01 10:15:00', 209.98, 16.80, 226.78, 'completed')   -- James buys 2 items
    ,(1, 3, 2, '2024-10-02 11:30:00', 119.99,  9.60, 129.59, 'completed')   -- Patricia buys 1 item
    ,(1, 4, 1, '2024-10-05 14:00:00',  89.99,  7.20,  97.19, 'completed')   -- James returns, buys again (1:many demonstrated)
    ,(1, 4, 3, '2024-10-08 09:45:00',  54.97,  4.40,  59.37, 'completed')   -- Carlos buys 3 items
    ,(1, 3, NULL, '2024-10-10 13:00:00', 29.99,  2.40,  32.39, 'completed') -- guest checkout (NULL customer)
    ,(1, 4, NULL, '2024-10-11 15:30:00', 44.98,  3.60,  48.58, 'completed') -- guest checkout (NULL customer)
    ,(1, 3, 4, '2024-10-12 10:00:00', 249.99, 20.00, 269.99, 'returned')    -- Angela, full return
    ,(1, 2, 2, '2024-10-15 16:00:00',  34.98,  2.80,  37.78, 'completed');  -- Patricia buys again (1:many)

-- TRANSACTION_ITEMS
-- Many:many between transactions and products via this junction table
-- Same product appearing in multiple transactions demonstrates the many:many
-- transaction 1: HQ Hyper Kite + Dyneema Line
-- transaction 2: Prism Quantum 2.0
-- transaction 3: HQ Hyper Kite (same product, different transaction)
-- transaction 4: Stowaway + Handles + Winder
-- transaction 5: Stowaway (guest)
-- transaction 6: Logo Hat + T-Shirt (guest)
-- transaction 7: HQ Beamer 6 (returned)
-- transaction 8: Handles + Winder
INSERT INTO transaction_items (transaction_id, product_id, quantity, unit_price, line_total) VALUES
     (1, 1, 1,  89.99,  89.99)   -- tx1: HQ Hyper Kite
    ,(1, 6, 1,  24.99,  24.99)   -- tx1: Dyneema Line  (subtotal doesnt add up exactly, rounding for demo)
    ,(2, 3, 1, 119.99, 119.99)   -- tx2: Prism Quantum 2.0
    ,(3, 1, 1,  89.99,  89.99)   -- tx3: HQ Hyper Kite again (product 1 in tx1 AND tx3 = many:many)
    ,(4, 5, 1,  29.99,  29.99)   -- tx4: Premier Stowaway
    ,(4, 7, 1,  19.99,  19.99)   -- tx4: Prism Handles
    ,(4, 8, 1,   9.99,   9.99)   -- tx4: Large Winder
    ,(5, 5, 1,  29.99,  29.99)   -- tx5: Stowaway (guest checkout)
    ,(6, 9, 1,  24.99,  24.99)   -- tx6: Logo Hat (guest checkout)
    ,(6, 10,1,  19.99,  19.99)   -- tx6: T-Shirt (guest checkout)
    ,(7, 2, 1, 249.99, 249.99)   -- tx7: HQ Beamer 6 (will be returned)
    ,(8, 7, 1,  19.99,  19.99)   -- tx8: Prism Handles
    ,(8, 8, 1,   9.99,   9.99);  -- tx8: Large Winder (product 7,8 in tx4 AND tx8 = many:many)

-- PAYMENTS
-- 1:1 with transactions -- one payment per transaction
-- demonstrates all four tender types
INSERT INTO payments (transaction_id, tender_type, amount_tendered, change_given, payment_date) VALUES
     (1, 'credit', 226.78, 0.00, '2024-10-01 10:16:00')
    ,(2, 'cash',   130.00, 0.41, '2024-10-02 11:31:00')
    ,(3, 'debit',   97.19, 0.00, '2024-10-05 14:01:00')
    ,(4, 'cash',    60.00, 0.63, '2024-10-08 09:46:00')
    ,(5, 'cash',    35.00, 2.61, '2024-10-10 13:01:00')
    ,(6, 'check',   48.58, 0.00, '2024-10-11 15:31:00')
    ,(7, 'credit', 269.99, 0.00, '2024-10-12 10:01:00')
    ,(8, 'debit',   37.78, 0.00, '2024-10-15 16:01:00');

-- PURCHASE_ORDERS
-- FK to vendors (1:many) and stores (1:many)
-- po 1: received,  po 2: pending,  po 3: cancelled
INSERT INTO purchase_orders (vendor_id, store_id, order_date, received_date, status, notes) VALUES
     (1, 1, '2024-09-15', '2024-09-22', 'received',  'Fall restock order from HQ')
    ,(2, 1, '2024-10-20', NULL,         'pending',   'Prism winter order, awaiting shipment')
    ,(1, 1, '2024-10-01', NULL,         'cancelled', 'Duplicate order, cancelled by manager');

-- PURCHASE_ORDER_ITEMS
-- quantity_received increments products.quantity_on_hand
-- po 1 received: 20 HQ Hyper Kites, 10 HQ Beamer 6, 50 Dyneema Lines
-- po 2 pending:  10 Prism Quantum, 10 Prism Nexus
-- po 3 cancelled: 5 HQ Hyper Kites
INSERT INTO purchase_order_items (po_id, product_id, quantity_ordered, quantity_received, unit_cost) VALUES
     (1, 1, 20, 20, 45.00)
    ,(1, 2, 10, 10, 130.00)
    ,(1, 6, 50, 50, 10.00)
    ,(2, 3, 10,  0, 60.00)
    ,(2, 4, 10,  0, 38.00)
    ,(3, 1,  5,  0, 45.00);

-- RETURNS
-- FK to transaction_items (1:many)
-- return 1: Angela returns the HQ Beamer 6 from transaction 7 (item_id = 11)
INSERT INTO returns (item_id, return_date, quantity_returned, reason, processed_by) VALUES
     (11, '2024-10-14 11:00:00', 1, 'Customer changed mind, unused condition', 2);

-- REFUND_PAYMENTS
-- 1:1 with returns -- one refund payment per return
INSERT INTO refund_payments (return_id, tender_type, refund_amount, refund_date) VALUES
     (1, 'credit', 249.99, '2024-10-14 11:05:00');


-- VIEWS
-- VIEW 1: vw_transaction_summary
-- View joining transactions, employees, and customers
-- Displays a summary of every transaction
-- customer_id is nullable so COALESCE returns 'GUEST" for a null customer_id
CREATE VIEW vw_transaction_summary AS
    SELECT
        t.transaction_id
        ,t.transaction_date
        ,CONCAT(e.first_name, ' ', e.last_name) AS cashier
        ,COALESCE(CONCAT(c.first_name, ' ', c.last_name), 'GUEST') AS customer
        ,t.subtotal
        ,t.tax_amount
        ,t.total_amount
        ,t.status
    FROM transactions t
    JOIN employees e 
        ON t.employee_id = e.employee_id
    LEFT JOIN customers c
        ON t.customer_id = c.customer_id;

-- VIEW 2: vw_low_stock
-- Subquery view showing products with quantity_on_hand below the average
-- quantity_on_hand across all products
CREATE VIEW vw_low_stock AS
    SELECT  
        p.product_id
        ,p.sku
        ,p.product_name
        ,p.quantity_on_hand
        ,p.cost
        ,v.vendor_name
    FROM products p
    JOIN vendors v
        ON p.vendor_id = v.vendor_id
    WHERE p.quantity_on_hand < (
        SELECT AVG(quantity_on_hand)
        FROM products
    );

-- VIEW 3: vw_sales_by_employee
-- Aggregation view grouping transactions by employee
-- Shows total number of transactions and total revenue per cashier
CREATE VIEW vw_sales_by_employee AS
    SELECT 
        e.employee_id
        ,CONCAT(e.first_name, ' ', e.last_name) AS employee_name
        ,e.role
        ,COUNT(t.transaction_id) AS total_transactions
        ,SUM(t.total_amount) AS total_revenue
        ,AVG(t.total_amount) AS avg_transaction_value
    FROM employees e
    LEFT JOIN transactions t 
        ON e.employee_id = t.employee_id
    GROUP BY 
        e.employee_id
        ,e.first_name
        ,e.last_name
        ,e.role;


-- STORED PROCEDURES
-- SP 1: sp_add_customer
-- Accepts customer details as parameters and inserts a new customer record
DELIMITER $$
CREATE PROCEDURE sp_add_customer (
    IN p_first_name    VARCHAR(50)
    ,IN p_last_name    VARCHAR(50)
    ,IN p_email        VARCHAR(150)
    ,IN p_phone        VARCHAR(20)
)
BEGIN
    INSERT INTO customers (first_name, last_name, email, phone)
    VALUES (p_first_name, p_last_name, p_email, p_phone);

    SELECT LAST_INSERT_ID() AS new_customer_id;
END$$
DELIMITER ;

-- SP 2: sp_customer_transaction_history
-- Accepts a customer_id and returns all transactions for that customer
DELIMITER $$
CREATE PROCEDURE sp_customer_transaction_history (
    IN p_customer_id INT
)
BEGIN
    SELECT
        t.transaction_id
        ,t.transaction_date
        ,CONCAT(e.first_name, ' ', e.last_name) AS cashier
        ,t.subtotal
        ,t.tax_amount
        ,t.total_amount
        ,t.status
    FROM transactions t 
    JOIN employees e
        ON t.employee_id = e.employee_id
    WHERE t.customer_id = p_customer_id
    ORDER BY t.transaction_date ASC;
END$$
DELIMITER ;


-- DEMO QUERIES

-- VIEW 1: all transactions with cashier and customer name
SELECT * FROM vw_transaction_summary;

-- VIEW 2: products below average stock level
SELECT * FROM vw_low_stock;

-- VIEW 3: revenue and transaction count per employee
SELECT * FROM vw_sales_by_employee;

-- SP 1: insert a new customer
CALL sp_add_customer('Alexander', 'Kligman', 'akligman@email.com', '843-448-7881');

-- SP 2: pull full transaction history for customer 1
-- 'James Whitfield'
CALL sp_customer_transaction_history(1);

-- SP 2: pull full transaction history for customer 2
-- 'Patricia Owens'
CALL sp_customer_transaction_history(2);