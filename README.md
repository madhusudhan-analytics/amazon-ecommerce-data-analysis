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
Data validation was performed to ensure the accuracy, consistency, and reliability of the e-commerce dataset before conducting business analysis. The validation process helped identify missing values, duplicate records, incorrect calculations, invalid transactions, and relationship inconsistencies across tables.
## Identifying Business Problems
The project focuses on solving major e-commerce business challenges such as:

* Identifying top-selling and low-performing products
* Analyzing customer purchasing behavior
* Detecting inventory shortages and overstocking
* Measuring shipping and delivery performance
* Tracking payment failures and return rates
* Evaluating product profitability and revenue trends

These insights help improve operational efficiency and business performance.
## Solving Business Problems
### Solutions Implemented:
#### SALES & REVENUE ANALYTICS
1. Which products generate the highest revenue but lowest profit margins?
```sql
WITH profit_margins AS (
    SELECT 
        product_id,
        product_name,
        ROUND(((price - COGS) / price) * 100, 0) AS margins_in_Percentage
    FROM products
)

SELECT 
    p.product_id,
    p.product_name,
    ROUND(SUM(o.quantity * o.price_per_unit), 2) AS TotalRevenue,
    p.margins_in_Percentage
FROM profit_margins p
JOIN order_items o
    ON p.product_id = o.product_id
GROUP BY 
    p.product_id,
    p.product_name,
    p.margins_in_Percentage
ORDER BY 
    TotalRevenue DESC,
    p.margins_in_Percentage ASC;
```
2. Which product categories contribute the most to total company profit?
``` sql
WITH profit_per_unit AS (
    SELECT 
        category_id,
        product_id,
        ROUND(price - COGS, 2) AS Profit
    FROM products
),

TotalProfit AS (
    SELECT 
        pp.product_id,
        pp.category_id,
        ROUND(SUM(o.quantity * pp.Profit), 2) AS TotalProfit01
    FROM profit_per_unit pp
    JOIN order_items o
        ON pp.product_id = o.product_id
    GROUP BY 
       pp.category_id, 
       pp.product_id
)

SELECT 
    c.category_id,
    c.category_name,
    ROUND(SUM(t.TotalProfit01), 2) AS TotalProfit,
    ROUND(
        SUM(t.TotalProfit01) /
        (SELECT SUM(TotalProfit01) FROM TotalProfit) * 100,
    2) AS profit_percentage
FROM category c
JOIN TotalProfit t
    ON c.category_id = t.category_id
GROUP BY 
    c.category_id, 
	c.category_name
ORDER BY 
    TotalProfit DESC;
```
3.What are the monthly sales trends across 2022–2024?
``` sql
select 
    year(o.order_date) as _Year,
    month(o.order_date) as _Month,
    round(sum(oi.quantity * oi.price_per_unit), 2) as Sales
from orders o
join order_items oi
    on o.order_id = oi.order_id
where
    year(o.order_date) > 2021
group by 
    _year,
    _month
order by 
    _year, 
    _month;
```
4. Which states generate the highest average order value (AOV)?
``` sql
select 
    c.state,
    round((sum(oi.quantity * oi.price_per_unit)/count(oi.order_id)), 2) as AOV
from customers c 
join orders o
    on c.CustomerID = o.customer_id
join order_items oi
    on oi.order_id = o.order_id
group by 
    c.state
order by 
    AOV desc;
```
5. Who are the top 10 customers by lifetime spending?
``` sql
select 
    c.CustomerID,
    concat(c.first_name,' ',c.last_name) as FullName,
    round(sum(oi.quantity * oi.price_per_unit), 2) as lifetime_spending
from customers c
join orders o
    on c.CustomerID = o.customer_id
join order_items oi
    on oi.order_id = o.order_id
group by 
    c.CustomerID, 
	FullName
order by 
    lifetime_spending desc
limit 10;
```
#### CUSTOMER ANALYTICS
6. What percentage of customers are repeat customers?
``` sql
WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)

SELECT 
    COUNT(
        CASE 
            WHEN total_orders > 1 THEN customer_id
        END
    ) AS repeat_customers,

    COUNT(customer_id) AS total_customers,

    ROUND(
        (
            COUNT(
                CASE 
                    WHEN total_orders > 1 THEN customer_id
                END
            ) * 100.0
        ) / COUNT(customer_id),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;
```
7. Which customers have not placed any orders in the last 6 months?
``` sql
WITH customer_last_order AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date
    FROM orders
    GROUP BY customer_id
)

SELECT 
    cl.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS FullName,
    cl.last_order_date

FROM customer_last_order cl

JOIN customers c
    ON cl.customer_id = c.CustomerID

WHERE cl.last_order_date < '2024-01-01';
```
8. Which customers return products most frequently?
``` sql
SELECT 
    c.CustomerID,
    CONCAT(c.first_name, ' ', c.last_name) AS FullName,
	COUNT(r.delivery_status) AS Number_of_return
FROM _Return r
JOIN orders o
    ON o.order_id = r.order_id
JOIN customers c
    ON c.CustomerID = o.customer_id
GROUP BY 
    c.CustomerID,
    FullName;
```
9. Which states have the highest customer return rates?
``` sql
SELECT 
    c.state,
    COUNT(DISTINCT o.order_id) AS TotalOrders,
    COUNT(DISTINCT r.order_id) AS TotalReturns,
    ROUND(
        COUNT(DISTINCT r.order_id) * 100.0 
        / COUNT(DISTINCT o.order_id),
        2
    ) AS ReturnRatePercentage
FROM customers c
JOIN orders o
    ON c.CustomerID = o.customer_id
LEFT JOIN _Return r
    ON o.order_id = r.order_id
GROUP BY 
    c.state
ORDER BY 
    ReturnRatePercentage DESC;
```
10. What is the customer lifetime value (CLV) by customer?
``` sql
WITH customer_order_revenue AS (
    SELECT 
        c.CustomerID,
        CONCAT(c.first_name, ' ', c.last_name) AS FullName,
        o.order_id,
        o.order_date,
        SUM(oi.quantity * oi.price_per_unit) AS order_revenue
    FROM customers c
    JOIN orders o
        ON c.CustomerID = o.customer_id
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY 
        c.CustomerID,
        FullName,
        o.order_id,
        o.order_date
)

SELECT 
    CustomerID,
    FullName,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT YEAR(order_date)) AS total_years,
    ROUND(SUM(order_revenue), 2) AS customer_lifetime_value
FROM customer_order_revenue
GROUP BY 
    CustomerID,
    FullName
ORDER BY customer_lifetime_value DESC;   
```
#### PRODUCT & INVENTORY ANALYTICS
11. Which products have high inventory but low sales?
``` sql
WITH ProductSales AS (
    SELECT 
        p.product_id,
        p.product_name,
        i.stock,
        COALESCE(SUM(oi.quantity), 0) AS TotalSales
    FROM products p
    LEFT JOIN inventory i
        ON p.product_id = i.product_id
    LEFT JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY 
        p.product_id,
        p.product_name,
        i.stock
)
SELECT *
FROM ProductSales
ORDER BY stock DESC, TotalSales ASC;
```
12.Which products are close to stockout?
``` sql
SELECT 
    p.product_id,
    p.product_name,
    i.stock,

    CASE
        WHEN i.stock <= 25 THEN 'Critical Stock'
        WHEN i.stock <= 50 THEN 'Low Stock'
        WHEN i.stock <= 75 THEN 'Moderate Stock'
        ELSE 'High Stock'
    END AS stock_category

FROM products p
LEFT JOIN inventory i
    ON p.product_id = i.product_id

ORDER BY i.stock;
```
13. Which categories have the highest return rates?
``` sql
WITH TotalOrders AS (
    SELECT 
        p.category_id,
        SUM(oi.quantity) AS total_quantity
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.category_id
),

TotalReturns AS (
    SELECT 
        p.category_id,
        SUM(oi.quantity) AS returned_quantity
    FROM order_items oi
    JOIN _Return r
        ON oi.order_id = r.order_id
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.category_id
),

category_return_summary as (
SELECT 
    t.category_id,
    t.total_quantity,
    COALESCE(tr.returned_quantity,0) AS returned_quantity

FROM TotalOrders t
LEFT JOIN TotalReturns tr
    ON t.category_id = tr.category_id

ORDER BY returned_quantity DESC)

select 
    cr.category_id,
	c.category_name, 
    round((cr.returned_quantity/cr.total_quantity) * 100,2) as ReturnRates
from category_return_summary cr
join category c
    on cr.category_id = c.category_id;
```
14. Which products generate the highest profit per unit sold?
``` sql
select 
    product_id,
    product_name,
    round(price-COGS,2) as ProfitPerUnit
from products
group by 
    product_id,
    product_name
order by 
    ProfitPerUnit desc
limit 1;
```
#### SHIPPING & OPERATIONS ANALYTICS
15. how long the provider takes to ship the order after the order was placed?
``` sql
select 
    s.shipping_providers,
    count(s.order_id) as TotalOrders,
	round(avg(DATEDIFF(s.shipping_date,o.order_date)
        ),2) AS avg_shipping_date
from shipping s
join orders o 
	on s.order_id = o.order_id
group by 
    s.shipping_providers
order by 
    avg_shipping_date desc;
```
16. Which sellers experience the highest product return rates?
``` sql
with OrderReturned as (
select 
   seller_id,
   case
       when order_status = 'Returned' then 1
       else 0
  end as Returned
  from orders )
  
  select 
     o.seller_id,
     s.seller_name,
     sum(o.Returned) as TotalReturn
from OrderReturned o
left join sellers s 
    on o.seller_id = s.seller_id
group by 
    o.seller_id,
    s.seller_name
order by    
    TotalReturn desc
limit 5;
```
#### FINANCIAL & BUSINESS PERFORMANCE
17. What is the monthly gross profit trend of the company?
``` sql
with detailed_raw as (
select 
   o.order_id,
   month(o.order_date) as order_month,
   year(o.order_date) as order_year,
   oi.product_id,
   oi.quantity,
   p.price,
   p.COGS
from orders o
left join order_items oi
   on o.order_id = oi.order_id
left join products p
   on p.product_id = oi.product_id)

select 
   order_month,
   order_year,
   round(sum(quantity * price),2) as Revenue,
   round(sum(quantity * COGS),2) as Cost,
   round(sum(quantity * price) - sum(quantity * COGS), 2) as gross_profit
from detailed_raw
group by 
   order_month,
   order_year  
order by 
   order_year asc,
   order_month asc;
```
18. Which sellers contribute the highest revenue and profit?
``` sql
with detailed_raw02 as (
 select 
     s.seller_id,
	 s.seller_name,
     o.order_id,
     oi.product_id,
     oi.quantity,
     p.price,
     p.COGS
from sellers s
left join orders o 
    on s.seller_id = o.seller_id
left join order_items oi
	on o.order_id = oi.order_id
left join products p
    on oi.product_id = p.product_id)

select 
    seller_id,
    seller_name,
    round(sum(quantity * price),2) as Revenue,
    round(sum(quantity * COGS), 2) as Cost,
    round(sum(quantity * price) - sum(quantity * COGS), 2) as gross_profit
from detailed_raw02
group by 
    seller_id,
    seller_name
order by
    gross_profit desc;
```
## Learning Outcomes
* Improved SQL querying and analytical skills
* Learned advanced concepts like CTEs, JOINS, and Window Functions
* Gained practical experience in business analytics
* Improved problem-solving and data interpretation abilities
* Developed real-world database management knowledge

## Conclusion
The project successfully demonstrates how SQL can be used to solve real-world e-commerce business problems through data analysis. By analyzing sales, customers, inventory, payments, and shipping operations, the project provides meaningful business insights that support strategic decision-making and operational improvement.
