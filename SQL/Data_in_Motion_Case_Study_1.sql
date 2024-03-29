-- Case Study Questions
--This is the solution for Data in Motion LLC case study 1 
--LINK--> https://d-i-motion.com/lessons/customer-orders-analysis/
/*I have utilized the following functions:
Basic aggregations
CASE WHEN statements
Window Functions
Joins
CTEs*/


--1) Which product has the highest price? Only return a single row.
--use order by Desc to sort the products from highes to lowest price and limit 1
  SELECT * 
  FROM products
  ORDER BY price DESC
  LIMIT 1


--2) Which customer has made the most orders?
--join customers and orders table to get the customers related to orders
--use window function DENSE_RANK() to rank the customer with most orders(count orders) in CTE
--select only the the customers with rank 1 (This will get all the customers with same no. of maximum orders)
WITH total_order_ranking as(
SELECT customers.customer_id, 
		   first_name, 
       last_name, 
       COUNT(order_id) as total,
  		 DENSE_RANK() OVER (ORDER BY COUNT(orders.order_id) DESC) AS ranking
FROM customers
JOIN orders
  ON customers.customer_id=orders.customer_id
GROUP BY 1,2,3)
    SELECT customer_id, first_name,last_name
    FROM total_order_ranking
    WHERE ranking=1
    

--3) What’s the total revenue per product?
-- join products and order_items table
-- calculate total revenue by multiplying price and quantity and add using SUM function. GROUP BY product to calculate for each product
SELECT product_name, SUM(price*quantity) as total_revenue
FROM order_items as oi
JOIN products as p
  ON oi.product_id=p.product_id
GROUP BY 1
ORDER BY 2 DESC


--4) Find the day with the highest revenue.
--join order_items, products and orders 
--find total revenue per day by grouping by date. 
--cast order_date to integer to display only the date
SELECT (order_date::varchar), SUM(price*quantity) as total_revenue
FROM order_items as oi
JOIN products as p
  ON oi.product_id=p.product_id
JOIN orders as o
  ON oi.order_id=o.order_id
GROUP BY 1
ORDER BY 2  DESC


--5) Find the first order (by date) for each customer.
--use CTE to give row number for each order from earliest for each customer
--join CTE table and customers table where row number=1 (That is the first order)
WITH first_order as
(SELECT order_id, 
        customer_id, 
        order_date, 
        ROW_NUMBER()OVER(PARTITION BY customer_id ORDER BY orders.order_date) as row_num
FROM orders
)
  SELECT c.customer_id, CONCAT(first_name,' ' ,last_name) as full_name, fo.order_date
  FROM first_order as fo
  JOIN customers as c
    ON fo.customer_id=c.customer_id 
  WHERE fo.row_num=1


--6) Find the top 3 customers who have ordered the most distinct products
--use DISTINCT to get only the unique product
  SELECT customer_id, COUNT(DISTINCT p.product_id)
  FROM order_items as oi
  JOIN products p
    ON p.product_id=oi.product_id
  JOIN orders as o
    ON o.order_id=oi.order_id
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 3


--7) Which product has been bought the least in terms of quantity?
-- IN CTE use dense_RANK window function to rank the products from lowest orders to highest orders
-- Select only the product with ranking 1(that is lowest orders)
WITH rankings as(
 SELECT p.product_id, 
        product_name, 
        sum(oi.quantity)as total_orders,
        DENSE_RANK() OVER (ORDER BY SUM(oi.quantity)) AS ranking
 FROM order_items as oi
 JOIN products p
 ON p.product_id=oi.product_id
 JOIN orders as o
 ON o.order_id=oi.order_id
 GROUP BY p.product_id)
     SELECT product_id,product_name, total_orders 
     FROM rankings
     WHERE ranking=1

  

--8) What is the median order total?
--median is the value in the middle of sorted data set 
--In first CTE find total revenue
--In second CTE give row number from highest to lowest amount
--divide the row number by 2 and get the revenue in that row(it is approximate)
WITH revenue_per_order as
  (SELECT o.order_id,  
          SUM(price*quantity) as total_revenue
  FROM order_items as oi
  JOIN products as p
  ON oi.product_id=p.product_id
  JOIN orders as o
  ON oi.order_id=o.order_id
  GROUP BY 1
  ),
sorting_order as
  (SELECT *,
        ROW_NUMBER()OVER (ORDER BY total_revenue DESC) as sorting,
        count(*)OVER() as total
  FROM revenue_per_order) 
SELECT order_id, total_revenue as median_amount
FROM sorting_order
WHERE sorting=total/2 or sorting=ROUND(total/2,1)


--9) For each order, determine if it was ‘Expensive’ (total over 300), 
--‘Affordable’ (total over 100), or ‘Cheap’.
--In CTE join the requered tables
--use CASE statements to give the condition provided 
WITH revenue_per_order as
  (SELECT o.order_id,  
          SUM(price*quantity) as total_revenue
  FROM order_items as oi
  JOIN products as p
   ON oi.product_id=p.product_id
  JOIN orders as o
    ON oi.order_id=o.order_id
  GROUP BY 1
  )
  SELECT *,
  CASE 
    WHEN total_revenue>=300 THEN 'Expensive'
    WHEN total_revenue>=100 THEN 'Affordable'
    ELSE 'Cheap' END as affordability
  FROM revenue_per_order


--10) Find customers who have ordered the product with the highest price.
--in the where statement filter only the product that has the highest price
--find the customers ho have bought it by joining the required tables
SELECT c.customer_id, CONCAT(first_name,' ', last_name) as full_name, oi.product_id, quantity
FROM orders as o
JOIN customers as c
  ON c.customer_id=o.customer_id
JOIN order_items as oi
ON o.order_id=oi.order_id
WHERE oi.product_id=  (SELECT product_id 
                       FROM products
                       ORDER BY price DESC
                       LIMIT 1)
