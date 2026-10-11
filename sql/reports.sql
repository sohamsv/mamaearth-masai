-- Capstone Project: Mamaearth Returns & Growth Intelligence Pipeline
-- Task 3: SQL Analytical Reports (sql/reports.sql)

-- ============================================================================
-- Report (a): Order totals (COUNT, total revenue, average order value)
-- ============================================================================
/*
Output:
total_orders | total_revenue | avg_order_value
180          | 99860.20      | 554.78
*/
SELECT 
    COUNT(*) AS total_orders, 
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_revenue,
    ROUND(AVG(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id;


-- ============================================================================
-- Report (b): COUNT(*) vs COUNT(column) on orders
-- ============================================================================
/*
Output:
total_rows | rated_rows | unrated_rows
180        | 165        | 15
*/
SELECT 
    COUNT(*) AS total_rows, 
    COUNT(rating) AS rated_rows, 
    COUNT(*) - COUNT(rating) AS unrated_rows 
FROM orders;


-- ============================================================================
-- Report (c): LEFT JOIN with a genuine zero-match row & NOT IN confirmation
-- ============================================================================
/*
Output (both queries return exactly 1 row):
customer_id | name
C045        | Vihaan
*/
-- Query 1: LEFT JOIN with HAVING count = 0
SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) = 0;

-- Query 2: Independent check with NOT IN
SELECT customer_id, name
FROM customers
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM orders);


-- ============================================================================
-- Report (d): GROUP BY + HAVING (City return rate > 20%)
-- ============================================================================
/*
Output:
city      | total_orders | returned_orders | return_rate_pct
Jaipur    | 19           | 8               | 42.1
Lucknow   | 49           | 15              | 30.6
Bangalore | 33           | 8               | 24.2
*/
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.returned) AS returned_orders,
    ROUND(SUM(o.returned) * 100.0 / COUNT(o.order_id), 1) AS return_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.city
HAVING return_rate_pct > 20
ORDER BY return_rate_pct DESC;


-- ============================================================================
-- Report (e): Ranking with ORDER BY + LIMIT/OFFSET
-- ============================================================================
/*
Tie-break note: c.customer_id ASC ensures a deterministic and reproducible ranking order when two customers have identical total_spend.

Top 5 Customers Output:
customer_id | name    | total_spend
C043        | Reyansh | 12920.00
C026        | Isha    | 8371.60
C008        | Meera   | 4564.60
C011        | Arjun   | 4111.00
C042        | Sanya   | 3785.00

LIMIT 3 OFFSET 2 Output (Ranks 3–5):
customer_id | name    | total_spend
C008        | Meera   | 4564.60
C011        | Arjun   | 4111.00
C042        | Sanya   | 3785.00
*/
-- Top 5 customers by total spend
SELECT 
    c.customer_id,
    c.name,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 5;

-- Ranks 3 to 5 using LIMIT 3 OFFSET 2
SELECT 
    c.customer_id,
    c.name,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 3 OFFSET 2;


-- ============================================================================
-- Report (f): Three-table JOIN with GROUP BY category
-- ============================================================================
/*
Output:
category     | order_count | category_revenue
Haircare     | 54          | 44956.10
Skincare     | 60          | 27346.00
Babycare     | 30          | 16805.00
PersonalCare | 36          | 10753.10
*/
SELECT 
    p.category,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.quantity * p.price * (1 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS category_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- ============================================================================
-- Report (g): LIKE pattern match (Customers whose name starts with 'A')
-- ============================================================================
/*
Output (10 rows):
customer_id | name
C001        | Aarav
C003        | Aditi
C004        | Ananya
C011        | Arjun
C021        | Aryan
C030        | Anika
C031        | Aditya
C036        | Aisha
C041        | Ayaan
C044        | Aria
*/
SELECT customer_id, name 
FROM customers 
WHERE name LIKE 'A%'
ORDER BY customer_id;


-- ============================================================================
-- Report (h): DISTINCT acquisition_source values
-- ============================================================================
/*
Output (4 rows):
acquisition_source
Ad
Organic
Referral
Social
*/
SELECT DISTINCT acquisition_source 
FROM customers 
ORDER BY acquisition_source;


-- ============================================================================
-- Report (i): ALTER TABLE + UPDATE with CASE for loyalty_tier
-- ============================================================================
/*
Output:
loyalty_tier | customer_count
Gold         | 28
Silver       | 17
*/
ALTER TABLE customers ADD COLUMN loyalty_tier VARCHAR(10);

UPDATE customers 
SET loyalty_tier = CASE WHEN city_tier = 1 THEN 'Gold' ELSE 'Silver' END;

SELECT loyalty_tier, COUNT(*) AS customer_count 
FROM customers 
GROUP BY loyalty_tier 
ORDER BY loyalty_tier;
