# AMAZON E-COMMERCE | SQL BUSINESS ANALYTICS PROJECT
## Project Overview
This project is an end-to-end Amazon E-Commerce SQL Business Analytics Project developed using MySQL 8.0+.
The project is designed to simulate a real-world Amazon e-commerce environment by analyzing customers, orders, products, payments, shipping, inventory, sellers, and return operations.
The main objective of this project is to solve real business problems using SQL and generate meaningful business insights through advanced analytical queries.
## Project Objectives
* Build a relational e-commerce database using MySQL
* Perform business analytics using SQL
* Analyze sales, profit, customers, returns, shipping, and inventory
* Solve real-world business problems using data
* Practice advanced SQL concepts in a practical environment
* Develop business decision-making insights from raw data
## Entity Relationship Diagram (ERD)
![Amazon ERD](https://raw.githubusercontent.com/madhusudhan-analytics/amazon-ecommerce-data-analysis/457a16d251f419482ad1a034c155983cc05e42c9/Amazon%20ERD.png)
## SQL Concepts Used
This project demonstrates practical implementation of: Joins, Common Table Expressions (CTEs), Aggregate Functions, CASE Statements, GROUP BY & HAVING, Subqueries, Date Functions, Business KPI Calculations, Data Validation Queries, Profit & Revenue Analysis.
## Database Setup & Design
### DATABASE
```sql
CREATE DATABASE IF NOT EXISTS amazon_db;
USE amazon_db;
```
#### customers
```sql
create table customers (
CustomerID int primary key,
first_name varchar(100),
last_name varchar(100),
state varchar(100)
);
```
#### category
```sql
create table category (
category_id int primary key,
category_name varchar(100)
);
```
#### products
```sql
create table products (
product_id int primary key,
product_name varchar(100),
price decimal(10,2),
COGS decimal(10,2),
category_id int,
foreign key (category_id) references  category (category_id)
);
```
#### inventory
```sql
create table inventory (
inventory_id int primary key,
product_id int,
stock int,
warehouse_id int,
last_stock_date date,
foreign key (product_id) references products (product_id) 
);
```
#### sellers
```sql
create table sellers (
seller_id int primary key,
seller_name varchar(100),
origin varchar(10)
);
```
#### orders
```sql
create table orders (
order_id int primary key,
order_date date,
customer_id int,
seller_id int,
order_status varchar(200),
foreign key (customer_id) references customers (CustomerID),
foreign key (seller_id) references sellers (seller_id)
);
```
#### order_items
```sql
create table order_items (
order_item_id int primary key,
order_id int,
product_id int,
quantity int,
price_per_unit decimal(10,2),
foreign key (order_id) references orders (order_id)
);
ALTER TABLE order_items
ADD FOREIGN KEY (product_id)
REFERENCES products(product_id);
```
#### payments
```sql
create table payments (
payment_id int primary key,
order_id int,
payment_date date,
payment_status varchar(200),
foreign key (order_id) references orders (order_id)
);
```
#### shipping
```sql
create table shipping (
shipping_id int primary key,
order_id int,
shipping_date date,
shipping_providers varchar(100),
delivery_status varchar(100),
foreign key (order_id) references orders (order_id)
);
```
#### Data Validation
```sql
-- Customer Table Validation
-- Check for NULL values in customer details
SELECT *
FROM customers
WHERE first_name IS NULL
   OR last_name IS NULL
   OR state IS NULL;

-- Check for duplicate customers
SELECT CustomerID, COUNT(*) AS duplicate_count
FROM customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- Products Table Validation
-- Identify products with missing prices or negative values
SELECT *
FROM products
WHERE price IS NULL
   OR price <= 0
   OR cogs <= 0;

-- Check for products without categories
SELECT *
FROM products
WHERE category_id IS NULL;

-- Orders Table Validation
-- Identify orders with missing customer IDs
SELECT *
FROM orders
WHERE customer_id IS NULL;

-- Check for invalid order dates
SELECT *
FROM orders
WHERE order_date > CURDATE();

-- Order Items Table Validation
-- Identify invalid quantities or prices
SELECT *
FROM order_items
WHERE quantity <= 0
   OR price_per_unit <= 0;

-- Payments Table Validation
-- Identify payments without orders
SELECT *
FROM payments
WHERE order_id IS NULL;
```


