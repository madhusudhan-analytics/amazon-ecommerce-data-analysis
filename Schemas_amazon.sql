
--  AMAZON E-COMMERCE  |  SQL BUSINESS ANALYTICS PROJECT

-- DATABASE & SCHEMA SETUP

CREATE DATABASE IF NOT EXISTS amazon_db;
USE amazon_db;

-- customers
create table customers (
CustomerID int primary key,
first_name varchar(100),
last_name varchar(100),
state varchar(100)
);

-- category
create table category (
category_id int primary key,
category_name varchar(100)
);

-- products
create table products (
product_id int primary key,
product_name varchar(100),
price decimal(10,2),
COGS decimal(10,2),
category_id int,
foreign key (category_id) references  category (category_id)
);

-- inventory
create table inventory (
inventory_id int primary key,
product_id int,
stock int,
warehouse_id int,
last_stock_date date,
foreign key (product_id) references products (product_id) 
);

-- sellers
create table sellers (
seller_id int primary key,
seller_name varchar(100),
origin varchar(10)
);

-- orders
create table orders (
order_id int primary key,
order_date date,
customer_id int,
seller_id int,
order_status varchar(200),
foreign key (customer_id) references customers (CustomerID),
foreign key (seller_id) references sellers (seller_id)
);

-- order_items
create table order_items (
order_item_id int primary key,
order_id int,
product_id int,
quantity int,
price_per_unit decimal(10,2),
foreign key (order_id) references orders (order_id)
);

-- payments
create table payments (
payment_id int primary key,
order_id int,
payment_date date,
payment_status varchar(200),
foreign key (order_id) references orders (order_id)
);

-- shipping
create table shipping (
shipping_id int primary key,
order_id int,
shipping_date date,
shipping_providers varchar(100),
delivery_status varchar(100),
foreign key (order_id) references orders (order_id)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/Users/Madhusudhan/OneDrive/Desktop/PROJECT/Raw/Amazon_Dataset/shipping.csv'
INTO TABLE shipping
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Return
create table _Return (
shipping_id int,
order_id int,
shipping_date date,
return_date date,
shipping_providers varchar(100),
delivery_status varchar(100),
foreign key (shipping_id) references shipping (shipping_id),
foreign key (order_id) references orders (order_id)
);


ALTER TABLE order_items
ADD FOREIGN KEY (product_id)
REFERENCES products(product_id);

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

