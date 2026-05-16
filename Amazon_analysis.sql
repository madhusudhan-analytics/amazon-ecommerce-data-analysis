-- SALES & REVENUE ANALYTICS
-- 1. Which products generate the highest revenue but lowest profit margins?
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
    
-- 2. Which product categories contribute the most to total company profit?
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

-- 3.What are the monthly sales trends across 2022–2024?
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

-- 4. Which states generate the highest average order value (AOV)?
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

-- 5. Who are the top 10 customers by lifetime spending?
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

-- CUSTOMER ANALYTICS
-- 6. What percentage of customers are repeat customers?
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
-- 7. Which customers have not placed any orders in the last 6 months?
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

-- 8. Which customers return products most frequently
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

-- 9. Which states have the highest customer return rates?
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

-- 10. What is the customer lifetime value (CLV) by customer?
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

-- PRODUCT & INVENTORY ANALYTICS
-- 11. Which products have high inventory but low sales?
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

-- 12.Which products are close to stockout?
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

-- 13. Which categories have the highest return rates?
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

-- 14. Which products generate the highest profit per unit sold?
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

-- SHIPPING & OPERATIONS ANALYTICS
-- 15. how long the provider takes to ship the order after the order was placed?
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

-- 16. Which sellers experience the highest product return rates?        
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

-- FINANCIAL & BUSINESS PERFORMANCE
-- 17. What is the monthly gross profit trend of the company?
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

-- 18. Which sellers contribute the highest revenue and profit?
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



