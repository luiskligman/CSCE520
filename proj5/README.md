# CSCE 520 — Project 5
**Luis Kligman**
**Point of Sale System Database**

---

## System Description

This database models a retail Point of Sale (POS) system inspired by Retail Pro Prism, a professional POS platform used in specialty retail environments. The system is implemented for Klig's Kites, a kite retail store located in Myrtle Beach, South Carolina that my family has owned for over 45 years. `My reason for choosing this, is I have implemented this point of sale software and feel as though it provides enough complexity to be a good choice.`

The database manages the full lifecycle of a retail operation: product catalog and inventory, vendor relationships and purchase orders, employee management and authentication, customer profiles, sales transactions, payments, and merchandise returns with refunds. While this implementation contains a single store, the schema is designed to support multiple store locations without structural changes.

---

## Table Descriptions

### stores
Represents a physical retail location. Stores the store name, address, contact information, and the tax rate applied to all transactions at that location. Every transaction, employee, and purchase order is tied to a store via foreign key, making multi-location expansion straightforward.

### categories
Represents product groupings used to organize merchandise (e.g. Kites, Accessories, Apparel, Toys). This is a stand-alone table with no foreign key dependencies. One category can be assigned to many products.

### vendors
Represents suppliers from whom the store sources its products. Stores vendor contact information and address. This is a stand-alone table with no foreign key dependencies. One vendor can supply many products and be referenced on many purchase orders.

### products
Represents individual merchandise items available for sale. Each product belongs to one category and one vendor. The `quantity_on_hand` field tracks live inventory — it is decremented when a sale is recorded and incremented when a purchase order is received.

### employees
Represents staff members who work at the store. Each employee belongs to one store. The `role` field identifies their position (Manager, Cashier). The `is_active` flag allows inactive employees to be retained in the system for historical record purposes without granting active access.

### employee_credentials
Stores login credentials for each employee. This table has a strict **1:1 relationship** with employees — the `UNIQUE` constraint on `employee_id` ensures no employee can have more than one credential record. The `password_hash` field stores a hashed representation of the password rather than plaintext.

### customers
Represents registered customer profiles used for transaction history tracking and loyalty purposes. Customers are optional on transactions — a transaction with a null `customer_id` represents a guest checkout.

### transactions
The central record of a sale. Each transaction records which store and employee processed it, an optional customer, and the financial totals (subtotal, tax, and total). The `status` ENUM field tracks whether the transaction is completed, voided, or returned. `employee_id` and `store_id` are required; `customer_id` is nullable to support guest checkouts.

### transaction_items
Line item records for each transaction. This table serves as the **many:many junction table** between transactions and products — a single transaction can contain many products, and a single product can appear across many transactions. Each row captures the product, quantity, unit price at time of sale, and line total.

### payments
Records the payment for a transaction. This table has a strict **1:1 relationship** with transactions — the `UNIQUE` constraint on `transaction_id` ensures exactly one payment record per transaction. The `tender_type` ENUM field accepts cash, credit, debit, or check. For cash transactions, `change_given` records the amount returned to the customer.

### purchase_orders
Represents a purchase order issued to a vendor for inventory replenishment. Each PO is linked to one vendor and one store. The `status` ENUM field tracks whether the order is pending, received, or cancelled. `received_date` is nullable — it is populated only when the order is marked received.

### purchase_order_items
Line items for a purchase order. Each row records a product, the quantity ordered, the quantity actually received, and the unit cost at time of order. When a PO is received, `quantity_received` values are used to increment `products.quantity_on_hand`.

### returns
Records a merchandise return tied to a specific transaction line item. Captures the quantity returned, the reason, and which employee processed the return. A single transaction item can be the subject of multiple return records (e.g. partial returns across multiple visits).

### refund_payments
Records the refund issued for a return. This table has a strict **1:1 relationship** with returns — the `UNIQUE` constraint on `return_id` ensures exactly one refund record per return. The tender type mirrors the original payment where applicable.

---

## Primary Keys

| Table | Primary Key |
|---|---|
| stores | store_id |
| categories | category_id |
| vendors | vendor_id |
| products | product_id |
| employees | employee_id |
| employee_credentials | credential_id |
| customers | customer_id |
| transactions | transaction_id |
| transaction_items | item_id |
| payments | payment_id |
| purchase_orders | po_id |
| purchase_order_items | po_item_id |
| returns | return_id |
| refund_payments | refund_id |

All primary keys are integer types with AUTO_INCREMENT.

---

## Foreign Keys

| Constraint Name | Table | Column | References |
|---|---|---|---|
| fk_product_category | products | category_id | categories(category_id) |
| fk_product_vendor | products | vendor_id | vendors(vendor_id) |
| fk_employee_store | employees | store_id | stores(store_id) |
| fk_credential_employee | employee_credentials | employee_id | employees(employee_id) |
| fk_transaction_store | transactions | store_id | stores(store_id) |
| fk_transaction_employee | transactions | employee_id | employees(employee_id) |
| fk_transaction_customer | transactions | customer_id | customers(customer_id) |
| fk_txitem_transaction | transaction_items | transaction_id | transactions(transaction_id) |
| fk_txitem_product | transaction_items | product_id | products(product_id) |
| fk_payment_transaction | payments | transaction_id | transactions(transaction_id) |
| fk_po_vendor | purchase_orders | vendor_id | vendors(vendor_id) |
| fk_po_store | purchase_orders | store_id | stores(store_id) |
| fk_poitem_po | purchase_order_items | po_id | purchase_orders(po_id) |
| fk_poitem_product | purchase_order_items | product_id | products(product_id) |
| fk_return_item | returns | item_id | transaction_items(item_id) |
| fk_return_employee | returns | processed_by | employees(employee_id) |
| fk_refundpayment_return | refund_payments | return_id | returns(return_id) |

---

## Relationships

### 1:1 — employees to employee_credentials
Each employee has exactly one credential record. The `UNIQUE` constraint on `employee_credentials.employee_id` enforces this at the database level. This separation keeps authentication data isolated from personnel data.

### 1:1 — transactions to payments
Each transaction has exactly one payment record. The `UNIQUE` constraint on `payments.transaction_id` enforces this. A sale is not complete without a corresponding payment.

### 1:1 — returns to refund_payments
Each return has exactly one refund payment record. The `UNIQUE` constraint on `refund_payments.return_id` enforces this. Every accepted return generates exactly one refund.

### 0:many — customers to transactions (nullable FK)
A customer can have zero or many transactions. Transactions do not require a customer — a null `customer_id` represents a guest checkout. This is demonstrated in the data by transactions 5 and 6, which have no associated customer.

### 1:many — stores to employees
One store employs many employees. Every employee must belong to a store (`store_id NOT NULL`).

### 1:many — stores to transactions
One store processes many transactions. Every transaction must be associated with a store (`store_id NOT NULL`).

### 1:many — employees to transactions
One employee processes many transactions. Every transaction must have an assigned cashier (`employee_id NOT NULL`).

### 1:many — categories to products
One category groups many products. Every product must belong to a category (`category_id NOT NULL`).

### 1:many — vendors to products
One vendor supplies many products. Every product must have an assigned vendor (`vendor_id NOT NULL`).

### 1:many — vendors to purchase_orders
One vendor can be the source of many purchase orders over time.

### 1:many — purchase_orders to purchase_order_items
One purchase order contains many line items, each representing a product being ordered.

### 1:many — transaction_items to returns
One transaction line item can be the subject of many return records, supporting partial returns across multiple visits.

### many:many — transactions to products (via transaction_items)
A single transaction can contain many products, and a single product can appear across many transactions. The `transaction_items` table is the junction table that resolves this relationship. This is demonstrated in the data — product 1 (HQ Hyper Kite) appears in both transactions 1 and 3, and products 7 and 8 appear in both transactions 4 and 8.

---

## Views

### vw_transaction_summary
A simple view joining `transactions`, `employees`, and `customers`. Returns a readable summary of every transaction including the cashier name, customer name (or "GUEST" for null `customer_id` using `COALESCE`), and all financial totals. Uses a `LEFT JOIN` on customers so guest checkout transactions are not excluded.

### vw_low_stock
A subquery view that returns all products where `quantity_on_hand` is below the average `quantity_on_hand` across all products. The subquery `SELECT AVG(quantity_on_hand) FROM products` is evaluated inline in the `WHERE` clause. Useful for identifying products that need reordering.

### vw_sales_by_employee
An aggregation view that groups transactions by employee and calculates total transaction count, total revenue, and average transaction value using `COUNT`, `SUM`, and `AVG`. Uses a `LEFT JOIN` so employees with no transactions still appear in the results.

---

## Stored Procedures
 
### sp_add_customer
Accepts `first_name`, `last_name`, `email`, and `phone` as input parameters and inserts a new customer record into the `customers` table. Returns the new `customer_id` via `LAST_INSERT_ID()`.
 
**Demo call:**
```sql
CALL sp_add_customer('Alexander', 'Kligman', 'akligman@email.com', '843-448-7881');
```
 
### sp_customer_transaction_history
Accepts a `customer_id` as an input parameter and returns the full transaction history for that customer. Each row includes the transaction ID, date, cashier name, subtotal, tax amount, total, and status. Results are ordered by transaction date ascending. Useful for customer service lookups and purchase history review.
 
**Demo calls:**
```sql
-- Transaction history for James Whitfield (customer_id = 1)
CALL sp_customer_transaction_history(1);
 
-- Transaction history for Patricia Owens (customer_id = 2)
CALL sp_customer_transaction_history(2);
```