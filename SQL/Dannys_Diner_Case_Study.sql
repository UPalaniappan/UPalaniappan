

-- 1. What is the total amount each customer spent at the restaurant?
        SELECT
            customer_id, sum(price) 
        FROM dannys_diner.sales JOIN dannys_diner.menu
        ON sales. product_id=menu.product_id
        GROUP BY customer_id
        ORDER BY customer_id
	
-- 2. How many days has each customer visited the restaurant?
        SELECT
            customer_id, count(DISTINCT order_date) as num_days_visited
        FROM dannys_diner.sales 
        GROUP By customer_id
        ORDER BY customer_id
	
-- 3. What was the first item from the menu purchased by each customer?
        SELECT 
            sub.customer_id, sub.order_date,sub.product_name
        FROM
             (SELECT
              sales.customer_id, sales.order_date, menu.product_name,
              ROW_NUMBER() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date)
              FROM dannys_diner.sales AS sales
              JOIN dannys_diner.menu AS menu
              ON sales.product_id=menu.product_id) sub
        WHERE row_number=1
	
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
        SELECT 
            menu.product_name,
            sales.product_id,
            count(sales.product_id) as times_purchased
        FROM dannys_diner.sales AS sales
        JOIN dannys_diner.menu AS menu
        ON sales.product_id=menu.product_id
        GROUP BY sales.product_id,menu.product_name 
        ORDER BY times_purchased
        LIMIT 1
	
-- 5. Which item was the most popular for each customer?
        SELECT sub.customer_id,
            sub.product_name as most_ordered
        FROM
            (SELECT 
              sales.customer_id,
              menu.product_name,
              RANK() OVER (PARTITION BY sales.customer_id order By COUNT(sales.product_id))	 				
            FROM dannys_diner.sales AS sales
            JOIN dannys_diner.menu AS menu
            ON sales.product_id=menu.product_id
            GROUP BY 1,2)As sub
        WHERE RANK=1 
	
-- 6. Which item was purchased first by the customer after they became a member?
        SELECT sub.customer_id, sub.product_name, sub.order_date
        FROM(
            SELECT  sales.customer_id, menu.product_name, sales.order_date,
              RANK() OVER(PARTITION BY sales.customer_id ORDER BY MIN(sales.order_date))AS ranking
            FROM dannys_diner.sales as sales
            JOIN dannys_diner.members as members
            ON members.customer_id=sales.customer_id
            JOIN dannys_diner.menu as menu
            ON menu.product_id=sales.product_id
            WHERE sales.order_date>=members.join_date
            GROUP BY 1,2,3) as sub
        WHERE sub.ranking=1

-- 7. Which item was purchased just before the customer became a member?
        SELECT sub.customer_id, sub.product_name, sub.order_date
        FROM(
            SELECT  sales.customer_id, menu.product_name, sales.order_date,
              RANK() OVER(PARTITION BY sales.customer_id ORDER BY MAX(sales.order_date))AS ranking
            FROM dannys_diner.sales as sales
            JOIN dannys_diner.members as members
            ON members.customer_id=sales.customer_id
            JOIN dannys_diner.menu as menu
            ON menu.product_id=sales.product_id
            WHERE sales.order_date<members.join_date
            GROUP BY 1,2,3) as sub
        WHERE sub.ranking=1
	
-- 8. What is the total items and amount spent for each member before they became a member?
    SELECT  
        sales.customer_id, SUM(sales.product_id), SUM(menu.price)
    FROM dannys_diner.sales as sales
    JOIN dannys_diner.menu as menu
    ON menu.product_id=sales.product_id
    JOIN dannys_diner.members as members
    ON sales.customer_id=members.customer_id
    WHERE sales.order_date<members.join_date
    GROUP BY 1

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
    SELECT 
        sub.customer_id, sum(sub.points) as total_points
    FROM    
        (SELECT
          sales.customer_id, menu.product_name, menu.price,
        CASE
        WHEN menu.product_name='sushi' THEN price*20
        ELSE price*10 END as points
        FROM dannys_diner.sales as sales
        JOIN dannys_diner.menu as menu
        ON menu.product_id=sales.product_id) sub
    GROUP BY customer_id 
    ORDER BY customer_id
	
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
    SELECT 
      sub.customer_id, sum(sub.points) as total_points
    FROM    
        (SELECT 
          sales.customer_id, menu.product_name, menu.price,members.join_date,sales.order_date,
                CASE
                WHEN menu.product_name='sushi' THEN price*20
                WHEN (sales.order_date BETWEEN members.join_date AND sales.order_date + INTERVAL'6 days') AND menu.product_name IN('curry', 'ramen') THEN menu.price*20
                ELSE price*10 END as points
        FROM dannys_diner.sales as sales
        JOIN dannys_diner.members as members
        ON members.customer_id=sales.customer_id
        JOIN dannys_diner.menu as menu
        ON menu.product_id=sales.product_id
        WHERE sales.order_date<='2021-01-31') sub
    GROUP BY customer_id 
    ORDER BY customer_id


EXTRA CHALLENGES-RECREATING TABLES:
--See if a customer is a member
  SELECT 
    sales.customer_id, LEFT(sales.order_date::VARCHAR,10) As order_date,
    menu.product_name, menu.price,
      CASE
      WHEN members.join_date<=sales.order_date THEN 'Y'
      ELSE 'N' END AS membership
  FROM dannys_diner.sales as sales
  LEFT JOIN dannys_diner.members as members
  ON members.customer_id=sales.customer_id
  JOIN dannys_diner.menu as menu
  ON menu.product_id=sales.product_id
  ORDER BY customer_id,order_date

--Give ranks after a customer became a member according order_date
  SELECT sub.*,
    CASE 
      WHEN sub.membership='Y' THEN
    RANK() OVER(PARTITION BY sub.customer_id,sub.membership ORDER BY sub.order_date)
      ELSE null END AS ranking
  FROM(
    SELECT 
    sales.customer_id, LEFT(sales.order_date::VARCHAR,10) As order_date
  , menu.product_name, menu.price,
      CASE
      WHEN members.join_date<=sales.order_date THEN 'Y'
      ELSE 'N' END AS membership
    FROM dannys_diner.sales as sales
    LEFT JOIN dannys_diner.members as members
    ON members.customer_id=sales.customer_id
    JOIN dannys_diner.menu as menu
    ON menu.product_id=sales.product_id
    ORDER BY customer_id,order_date)sub

	


