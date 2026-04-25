-- CSCE 520  Project 5  Luis Kligman
-- Point of Sale System Database Structural Script
DROP SCHEMA IF EXISTS project5;
CREATE SCHEMA project5;
USE project5;

-- Drop tables in reverse order 
-- Redundant as dropping SCHEMA will implicitly drop all tables
DROP TABLE IF EXISTS refund_payments;
DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS purchase_order_items;
DROP TABLE IF EXISTS purchase_orders;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS transaction_items;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS employee_credentials;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS vendors;
DROP TABLE IF EXISTS stores;

-- STORES
-- One store in this implementation, but schema supports many.
-- Stores the tax rate applied to all transactions at that location.
CREATE TABLE stores (
    store_id       INT              AUTO_INCREMENT PRIMARY KEY
    ,store_name    VARCHAR(100)     NOT NULL
    ,address       VARCHAR(200)     NOT NULL
    ,city          VARCHAR(100)     NOT NULL
    ,state         CHAR(2)          NOT NULL
    ,zip           VARCHAR(10)      NOT NULL
    ,phone         VARCHAR(20)
    ,tax_rate      DECIMAL(5, 4)    NOT NULL  -- .0800 = 8.00%
);

-- CATEGORIES
-- Product groupings (Accessories, Apparel).
-- Stand-alone table with no FK dependencies
CREATE TABLE categories (
    category_id       INT             AUTO_INCREMENT PRIMARY KEY
    ,category_name    VARCHAR(100)    NOT NULL
    ,description      VARCHAR(255)
);

-- VENDORS
-- Suppliers which products are sourced
-- Stand-alone table with no FK dependencies
CREATE TABLE vendors (
    vendor_id        INT             AUTO_INCREMENT PRIMARY KEY
    ,vendor_name     VARCHAR(100)    NOT NULL
    ,contact_name    VARCHAR(100)
    ,email           VARCHAR(150)
    ,phone           VARCHAR(20)
    ,address         VARCHAR(200)
);

-- PRODUCTS
-- Merchandise sold in the store(s).
-- FK to categories (1:many) and vendors (1:many).
-- quantity_on_hand is incremented by PO receipts and decremented by sales
CREATE TABLE products (
    product_id           INT               AUTO_INCREMENT PRIMARY KEY
    ,category_id         INT               NOT NULL
    ,vendor_id           INT               NOT NULL
    ,sku                 VARCHAR(50)       NOT NULL UNIQUE
    ,product_name        VARCHAR(150)      NOT NULL
    ,description         VARCHAR(500)
    ,unit_price          DECIMAL(10, 2)    NOT NULL
    ,cost                DECIMAL(10, 2)    NOT NULL
    ,quantity_on_hand    INT               NOT NULL DEFAULT 0
    ,CONSTRAINT fk_product_category FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
    ,CONSTRAINT fk_product_vendor FOREIGN KEY (vendor_id)
        REFERENCES vendors(vendor_id)
);

-- EMPLOYEES 
-- Staff who process transactions.
-- FK to stores (1:many)
CREATE TABLE employees (
    employee_id    INT             AUTO_INCREMENT PRIMARY KEY
    ,store_id      INT             NOT NULL
    ,first_name    VARCHAR(50)     NOT NULL
    ,last_name     VARCHAR(50)     NOT NULL
    ,email         VARCHAR(150)    NOT NULL UNIQUE
    ,phone         VARCHAR(20)
    ,role          VARCHAR(50)     NOT NULL  -- ex 'cashier'
    ,hire_date     DATE            NOT NULL
    ,is_active     BOOLEAN         NOT NULL DEFAULT TRUE
    ,CONSTRAINT fk_employee_store FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
);

-- EMPLOYEE_CREDENTIALS
-- One login record per employee.
-- 1:1 relationship with employees
CREATE TABLE employee_credentials (
    credential_id     INT             AUTO_INCREMENT PRIMARY KEY
    ,employee_id      INT             NOT NULL UNIQUE  -- unique enforces 1:1
    ,username         VARCHAR(50)     NOT NULL UNIQUE
    ,password_hash    VARCHAR(255)    NOT NULL  -- realistically sha256 or something similar
    ,last_login       DATETIME
    ,CONSTRAINT fk_credential_employee FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id) 
);

-- CUSTOMERS 
-- Customer profiles for transaction history tracking
-- Transactions may or may not be linked to a customer
-- (guest checkout = NULL FK on transactions)
CREATE TABLE customers (
    customer_id    INT             AUTO_INCREMENT PRIMARY KEY
    ,first_name    VARCHAR(50)     NOT NULL
    ,last_name     VARCHAR(50)     NOT NULL
    ,email         VARCHAR(150)    UNIQUE
    ,phone         VARCHAR(20)
    ,created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- TRANSACTIONS
-- The sale header record
-- employee_id is NOT NULL (every sale must have a cashier)
-- customer_id IS NULL allowed (guest checkout = 0:many).
-- stored_id is NOT NULL (every sale takes place at a store).
CREATE TABLE transactions (
    transaction_id       INT               AUTO_INCREMENT PRIMARY KEY
    ,store_id            INT               NOT NULL
    ,employee_id         INT               NOT NULL
    ,customer_id         INT  -- NULL = guest checkout
    ,transaction_date    DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
    ,subtotal            DECIMAL(10, 2)    NOT NULL DEFAULT 0.00
    ,tax_amount          DECIMAL(10, 2)    NOT NULL DEFAULT 0.00
    ,total_amount        DECIMAL(10, 2)    NOT NULL DEFAULT 0.00
    ,status              ENUM('completed', 'voided', 'returned') NOT NULL DEFAULT 'completed'
    ,notes               VARCHAR(500)
    ,CONSTRAINT fk_transaction_store FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
    ,CONSTRAINT fk_transaction_employee FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
    ,CONSTRAINT fk_transaction_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- TRANSACTION_ITEMS
-- Line items for a transaction
-- Junction table implementing many:many between transacations and products
-- Quantity here decrements products.quantity_on_hand at sale time
CREATE TABLE transaction_items (
    item_id            INT               AUTO_INCREMENT PRIMARY KEY
    ,transaction_id    INT               NOT NULL
    ,product_id        INT               NOT NULL
    ,quantity          INT               NOT NULL
    ,unit_price        DECIMAL(10, 2)    NOT NULL
    ,line_total        DECIMAL(10, 2)    NOT NULL
    ,CONSTRAINT fk_txitem_transaction FOREIGN KEY (transaction_id)
        REFERENCES transactions(transaction_id)
    ,CONSTRAINT fk_txitem_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- PAYMENTS
-- One payment record per transaction (1:1 with transactions).
-- tender_type limited to cash, credit, debit, check
CREATE TABLE payments (
    payment_id          INT               AUTO_INCREMENT PRIMARY KEY
    ,transaction_id     INT               NOT NULL UNIQUE  -- UNIQUE enforces 1:1
    ,tender_type        ENUM('cash', 'credit', 'debit', 'check') NOT NULL
    ,amount_tendered    DECIMAL(10, 2)    NOT NULL
    ,change_given       DECIMAL(10, 2)    NOT NULL DEFAULT 0.00
    ,payment_date       DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
    ,CONSTRAINT fk_payment_transaction FOREIGN KEY (transaction_id)
        REFERENCES transactions(transaction_id)
);

-- PURCHASE_ORDERS
-- PO header for receiving inventory from a vendor
-- FK to vendors (1:many) and stores (1:many)
CREATE TABLE purchase_orders (
    po_id             INT      AUTO_INCREMENT PRIMARY KEY
    ,vendor_id        INT      NOT NULL
    ,store_id         INT      NOT NULL
    ,order_date       DATE     NOT NULL
    ,received_date    DATE
    ,status           ENUM('pending', 'received', 'cancelled') NOT NULL DEFAULT 'pending'
    ,notes            VARCHAR(500)
    ,CONSTRAINT fk_po_vendor FOREIGN KEY (vendor_id)
        REFERENCES vendors(vendor_id)
    ,CONSTRAINT fk_po_store FOREIGN KEY (store_id)
        REFERENCES stores(store_id)
);

-- PURCHASE_ORDER_ITEMS
-- Line itmes for a PO.
-- quantity_received increments products.quantity_on_hand
CREATE TABLE purchase_order_items (
    po_item_id            INT               AUTO_INCREMENT PRIMARY KEY
    ,po_id                INT               NOT NULL
    ,product_id           INT               NOT NULL
    ,quantity_ordered     INT               NOT NULL
    ,quantity_received    INT               NOT NULL DEFAULT 0
    ,unit_cost            DECIMAL(10, 2)    NOT NULL
    ,CONSTRAINT fk_poitem_po FOREIGN KEY (po_id)
        REFERENCES purchase_orders(po_id)
    ,CONSTRAINT fk_poitem_product FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- RETURNS 
-- Records a returned line item from a transaction.
-- FK to transaction_items (1:many).
CREATE TABLE returns (
    return_id             INT         AUTO_INCREMENT PRIMARY KEY
    ,item_id              INT         NOT NULL
    ,return_date          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
    ,quantity_returned    INT         NOT NULL
    ,reason               VARCHAR(255)
    ,processed_by         INT         NOT NULL  -- employee id
    ,CONSTRAINT fk_return_item FOREIGN KEY (item_id)
        REFERENCES transaction_items(item_id)
    ,CONSTRAINT fk_return_employee FOREIGN KEY (processed_by)
        REFERENCES employees(employee_id)
);

-- REFUND_PAYMENTS
-- One refund payment record per return (1:1 with returns).
-- Mirrors the payments table structure
CREATE TABLE refund_payments (
    refund_id         INT               AUTO_INCREMENT PRIMARY KEY
    ,return_id        INT               NOT NULL UNIQUE  -- UNIQUE enforces 1:1
    ,tender_type      ENUM('cash', 'credit', 'debit', 'check') NOT NULL
    ,refund_amount    DECIMAL(10, 2)    NOT NULL
    ,refund_date      DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
    ,CONSTRAINT fk_refundpayment_return FOREIGN KEY (return_id)
        REFERENCES returns(return_id)
);
