CREATE TABLE sales (
  order_id INT,
  order_date DATE,
  customer_id VARCHAR(10),
  region VARCHAR(20),
  product VARCHAR(50),
  quantity INT,
  price INT
);
 
INSERT INTO sales VALUES
  (1001, '2024-01-01', 'C001', 'East', 'Keyboard', 2, 1500),
  (1002, '2024-01-02', 'C002', 'West', 'Mouse', 5, 500),
  (1003, '2024-01-03', 'C001', 'East', 'Monitor', 1, 12000),
  (1004, '2024-01-04', 'C003', 'South', 'Keyboard', 1, 1500),
  (1005, '2024-01-05', 'C002', 'West', 'Monitor', 2, 12000),
  (1006, '2024-01-06', 'C001', 'East', 'Mouse', 3, 500),
  (1007, '2024-01-07', 'C004', 'North', 'Keyboard', 4, 1500),
  (1008, '2024-01-08', 'C003', 'South', 'Monitor', 1, 12000),
  (1009, '2024-01-09', 'C001', 'East', 'Keyboard', 2, 1500),
  (1010, '2024-01-10', 'C002', 'West', 'Mouse', 1, 500),
  (1011, '2024-01-11', 'C005', 'East', 'Monitor', 1, 12000),
  (1012, '2024-01-12', 'C002', 'West', 'Keyboard', 3, 1500),
  (1013, '2024-01-13', 'C001', 'East', 'Mouse', 2, 500),
  (1014, '2024-01-14', 'C003', 'South', 'Keyboard', 1, 1500);
  
  SELECT COUNT(*)
  FROM sales;

 -- Revenue per order. Top 3 products
WITH order_revenue AS (
  SELECT order_id,
  order_date,
  customer_id,
  region,
  product,
  quantity,                         
  price,                         
  SUM(quantity * price) as revenue
  FROM sales
  GROUP BY order_id)

SELECT
product,
revenue,
RANK() OVER(order BY revenue DESC)
FROM order_revenue
LIMIT 3;

 -- Total Revenue per product. Top 3 products
 
WITH product_revenue AS (
   SELECT product,
   SUM(quantity * price) as total_revenue
   FROM sales
   GROUP BY(product)
   )
SELECT product,
total_revenue,
RANK() OVER (ORDER BY total_revenue DESC)
FROM product_revenue;

-- Top Customer per Region

WITH customer_revenue AS (
   SELECT customer_id,
   region,
   SUM(quantity * price) as total_revenue_customer
   FROM sales
   GROUP BY customer_id, region
  ),
customer_revenue_region AS (
   SELECT customer_id,
   region,
   total_revenue_customer,
   RANK () OVER ( PARTITION BY region
                 ORDER BY total_revenue_customer DESC) AS rank
   FROM customer_revenue
 )
 SELECT 
 region,
 customer_id,
 total_revenue_customer,
 CASE
 	WHEN total_revenue_customer >= 20000 THEN 'HIGH_VALUE'
    WHEN total_revenue_customer >= 10000 THEN 'MEDIUM_VALUE'
    ELSE 'LOW_VALUE'
  END AS customer_category
 FROM customer_revenue_region
 WHERE rank = 1
 ORDER BY total_revenue_customer DESC;
 
 -- Rolling 7-Day Average Revenue
 
 WITH daily_revenue AS (
  SELECT
    order_date,
    SUM(quantity * price) AS daily_revenue
  FROM sales
  GROUP BY order_date
)
SELECT
  order_date,
  daily_revenue,
  AVG(daily_revenue) OVER (
    ORDER BY order_date
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS rolling_7day_avg
FROM daily_revenue
ORDER BY order_date;


-- Revenue Trend Comparison Day-over-Day

WITH day_revenue AS (
  SELECT
    order_date,
    SUM(quantity * price) AS daily_revenue
  FROM sales
  GROUP BY order_date
),
revenue_comparison AS (
  SELECT
  order_date,
  daily_revenue,
  LAG(daily_revenue) OVER (ORDER BY order_date) AS prev_daily_revenue,
  daily_revenue - LAG(daily_revenue) OVER (ORDER BY order_date) AS difference_daily_revenue
  FROM day_revenue
 )
SELECT 
order_date,
daily_revenue,
prev_daily_revenue,
difference_daily_revenue,
CASE
	WHEN difference_daily_revenue  < 0 THEN 'DECREASE'
    WHEN difference_daily_revenue  > 0 THEN 'INCREASE'
    WHEN difference_daily_revenue  = 0 THEN 'EQUAL'
    ELSE 'N/A'
END AS trend
FROM revenue_comparison;

