
  --PIZZA METRICS  
--1.How many pizzas were ordered?

	  SELECT count(*)
	  FROM pizza_runner.customer_orders

--2.How many unique customer orders were made?
	SELECT COUNT(DISTINCT order_id)
	FROM pizza_runner.customer_orders
	
--3.How many successful orders were delivered by each runner?
--counting no. of successful orders using CASE.
	SELECT runner_id,
		SUM(CASE WHEN cancellation='' or cancellation is NULL or cancellation='null'then 1
      		ELSE 0 end) as count_of_success
	FROM pizza_runner.runner_orders
	GROUP BY 1
	ORDER BY 1
--OPTION 2
--USE temp table to calculate cancellation then use it in query
  WITH cleaned_runners AS
  (SELECT order_id, runner_id, pickup_time, distance, duration,
      CASE WHEN cancellation='' THEN 0
      WHEN cancellation IS NULL THEN 0
      WHEN cancellation='null' THEN 0             
      ELSE 1 END AS cancellation
  FROM pizza_runner.runner_orders)
        SELECT runner_id,count(cancellation) 
        FROM cleaned_runners 
        WHERE cancellation=0
        GROUP BY 1
    
--4.How many of each type of pizza was delivered?
	WITH cleaned_runners AS
    (SELECT order_id, runner_id, pickup_time, distance, duration,
        CASE WHEN cancellation='' THEN 0
        WHEN cancellation IS NULL THEN 0
        WHEN cancellation='null' THEN 0             
        ELSE 1 END AS cancellation
    FROM pizza_runner.runner_orders)
        SELECT pizza_id, COUNT(pizza_id)
        FROM cleaned_runners
        JOIN pizza_runner.customer_orders AS customers
        On cleaned_runners.order_id=customers.order_id and cancellation=0
        GROUP BY 1

--5.How many Vegetarian and Meatlovers were ordered by each customer?
	SELECT customer_id,
    SUM(CASE WHEN pizza_name='Meatlovers' THEN 1 END ) AS meatlovers,
    SUM(CASE WHEN pizza_name='Vegetarian' THEN 1 END ) AS vegrtarian
    FROM pizza_runner.customer_orders as orders
    LEFT JOIN pizza_runner.pizza_names as pizzas
    ON pizzas.pizza_id=orders.pizza_id
    GROUP BY 1
    ORDER BY 1

--6.What was the maximum number of pizzas delivered in a single order?
	WITH cleaned_runners AS
    (SELECT order_id, runner_id, pickup_time, distance, duration,
    CASE WHEN cancellation='' THEN 0
            WHEN cancellation IS NULL THEN 0
            WHEN cancellation='null' THEN 0             
            ELSE 1 END AS cancellation
    FROM pizza_runner.runner_orders)
    SELECT cleaned_runners.order_id,count(customers.pizza_id) as pizza_count
    FROM cleaned_runners
    JOIN pizza_runner.customer_orders AS customers
    On cleaned_runners.order_id=customers.order_id and cancellation=0
    GROUP By 1
    ORDER BY 2 DESC
    LIMIT 1

--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
	WITH cleaned_customers AS(
    SELECT order_id, customer_id,pizza_id, order_time,
        CASE  WHEN exclusions='' Then null
                WHEN exclusions='null' Then null
                WHEN exclusions=NULL Then null
                ELSE exclusions END as exclusions,
        CASE  WHEN extras='' Then null
                WHEN extras='null' Then null
                WHEN extras=NULL Then null
                ELSE extras END as extras
    FROM pizza_runner.customer_orders),
  
     cleaned_runners AS
    (SELECT order_id, runner_id, pickup_time, distance, duration,
        CASE WHEN cancellation='' THEN 0
             WHEN cancellation IS NULL THEN 0
             WHEN cancellation='null' THEN 0             
             ELSE 1 END AS cancellation
    FROM pizza_runner.runner_orders)

        SELECT customer_id,
        SUM(CASE WHEN exclusions IS NULL and extras IS NULL THEN 1 
            ELSE 0 END) as no_changes,
        SUM(CASE WHEN exclusions IS NOT NULL OR EXTRAS IS NOT NULL THEN 1
            ELSE 0 END) as at_least_one_change
        FROM cleaned_customers as customers 
        JOIN cleaned_runners as orders
        ON customers.order_id=orders.order_id and cancellation=0
        GROUP BY customer_id
        ORDER BY customer_id

--8.How many pizzas were delivered that had both exclusions and extras?
--created two temp tables.
	WITH cleaned_customers AS(
    SELECT order_id, customer_id,pizza_id, order_time,
        CASE WHEN exclusions='' Then null
             WHEN exclusions='null' Then null
             WHEN exclusions=NULL Then null
             ELSE exclusions END as exclusions,
        CASE  WHEN extras='' Then null
            WHEN extras='null' Then null
            WHEN extras=NULL Then null
            ELSE extras END as extras
    FROM pizza_runner.customer_orders),
  
        cleaned_runners AS(
    SELECT order_id, runner_id, pickup_time, distance, duration,
        CASE WHEN cancellation='' THEN 0
             WHEN cancellation IS NULL THEN 0
             WHEN cancellation='null' THEN 0             
             ELSE 1 END AS cancellation
    FROM pizza_runner.runner_orders)

        SELECT 
        SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 
            ELSE 0 END) as pizzas_with_exclusions_and_extras
        FROM cleaned_customers as customers 
        JOIN cleaned_runners as orders
        ON customers.order_id=orders.order_id and cancellation=0

--9.What was the total volume of pizzas ordered for each hour of the day?
  SELECT 
  	EXTRACT(hour from order_time) as hour,
    COUNT(order_id) as total_orders
  
  FROM pizza_runner.customer_orders
 	GROUP BY 1
  ORDER BY 1

--10.What was the volume of orders for each day of the week? 
  SELECT 
  	to_char(order_time, 'DAY') day_of_week,
    COUNT(order_id) as total_orders
  FROM pizza_runner.customer_orders
 	GROUP BY 1
    ORDER BY 1

--B. Runner and Customer Experience

-- 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--use datepart function to get the week number	

  SELECT DATE_PART('week', registration_date) AS week_value,
    COUNT(*)
  FROM pizza_runner.runners
  GROUP BY 1
  
--(option 2) week number from 1   
   
   SELECT 
      to_char(registration_date, 'WW') as week,
      count(*)
   FROM pizza_runner.runners
   GROUP BY 1
   ORDER BY 1

-- 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--subquery - first join both tables where pickup time was not null(As it can cause problem while subracting). cast the pickup_time to timestamp to get the interval. Use epoch to get the difference in seconds. 
--use outerquery to get the differnce of timings in minutes and average. round it to two decimals. group by runner_id
    SELECT runner_id, ROUND(AVG((sub.time_in_sec)/60.0),2) as average_time_in_min
    FROM(
      SELECT *,
      EXTRACT(EPOCH FROM runners.pickup_time::timestamp-customers.order_time) as time_in_sec
      FROM pizza_runner.runner_orders as runners 
      INNER JOIN pizza_runner.customer_orders as customers
      ON runners.order_id=customers.order_id AND pickup_time != 'null')sub
    GROUP BY 1
    ORDER BY 1

--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
--using subquery as previous question. using count get how many pizzas per order(group By order_id is same)
    SELECT count(order_id)as num_of_pizzas, ROUND((sub.time_in_sec/60.0),2) as average_time_prepare
    FROM(
    SELECT customers.order_id,
          EXTRACT(EPOCH FROM runners.pickup_time::timestamp-customers.order_time) as time_in_sec
          FROM pizza_runner.runner_orders as runners 
          INNER JOIN pizza_runner.customer_orders as customers
          ON runners.order_id=customers.order_id AND pickup_time != 'null')sub
    GROUP BY order_id ,2
    ORDER BY 1 desc

--4.What was the average distance travelled for each customer?
--Used SUBSTRING(runners.distance,1, LENGTH(runners.distance)-2) to get the km outof the string. it created trouble when there was no 'km' measure.
--Used trim function to remove km and once again to remove blank space. changed it to float and found average and rounded it.
-- before joining filtered null values
    SELECT customers.customer_id, ROUND(AVG(TRIM(TRIM('km' FROM distance))::FLOAT)) AS distance_in_km
    FROM pizza_runner.runner_orders as runners 
    INNER JOIN pizza_runner.customer_orders as customers
    ON runners.order_id=customers.order_id and distance NOT IN('null','') 
    GROUP BY 1  
    ORDER BY 1

--5.What was the difference between the longest and shortest delivery times for all orders?
-- cleaned the duration in subquery. Found the difference in duration in second query.
	SELECT MAX(sub.cleaned_duration)-MIN(sub.cleaned_duration) as 		differnce_in_delivery_times
	FROM
	  (SELECT *,
		  TRIM(split_part(duration, 'min', 1))::INTEGER as cleaned_duration
    FROM pizza_runner.runner_orders as runners 
    INNER JOIN pizza_runner.customer_orders as customers
    ON runners.order_id=customers.order_id AND duration NOT IN('null',''))sub 


-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- combined Q.4, Q.5 queries, changed the duration to hours
	SELECT sub.runner_id, sub.order_id,
	  sub.distance_in_km/(sub.cleaned_duration/60.0) as average_speed
  FROM(
    SELECT runners.runner_id, runners.order_id,
            (TRIM(TRIM('km' FROM distance))::FLOAT) AS distance_in_km,
            (TRIM(split_part(duration, 'min', 1))::FLOAT) as cleaned_duration
          FROM pizza_runner.runner_orders as runners 
          INNER JOIN pizza_runner.customer_orders as customers
          ON runners.order_id=customers.order_id AND (duration NOT IN('null','') or distance NOT IN('null','')))sub


--7.What is the successful delivery percentage for each runner?
--count orders that are not canceled using CASE. Then Total orders grouped by each runner. IN outer query change count, and sucess deliveries to type float
  --and calculate the percentage

  SELECT sub.runner_id, (sub.count_of_success::FLOAT/sub.total_orders::FLOAT)*100 AS percentage_of_success
  FROM(
    SELECT runner_id,
        SUM(CASE WHEN cancellation='' or cancellation is NULL or cancellation='null'then 1
        ELSE 0 end) as count_of_success,
        count(*) as total_orders
    FROM pizza_runner.runner_orders
    GROUP BY 1
    ORDER BY 1)sub

   -- 3.
   -- C. Ingredient Optimisation
--1.What are the standard ingredients for each pizza?
--temp table for unnesting the toppings

    WITH toppings_unnest AS(SELECT pizza_id,UNNEST(STRING_TO_ARRAY(toppings,','))::INTEGER AS toppings_id
    FROM pizza_runner.pizza_recipes),
--temp table to join toppings names
        toppings_joined AS(
    SELECT pizza_id,topping_name FROM toppings_unnest
    JOIN pizza_runner.pizza_toppings AS topping_names
    ON topping_names.topping_id=toppings_unnest.toppings_id)
-- grouping toppings for each pizza
    SELECT pizza_id, STRING_AGG(topping_name,', ')
    FROM toppings_joined
    GROUP BY 1
    ORDER BY 1
    
--2. What was the most commonly added extra?
-- temp table to unnest the extras where there is no null

	WITH extras AS
    (SELECT order_id, extras, 
    UNNEST(STRING_TO_ARRAY(extras,','))::INTEGER AS extras_unnest
    FROM pizza_runner.customer_orders
    WHERE extras NOT IN ('','null'))
    -- joining temp table and toppings names and grouping by topping_id
    SELECT  topping_id, topping_name ,Count(order_id) AS num_of_times_added
    FROM extras
    JOIN pizza_runner.pizza_toppings as toppings
    ON extras_unnest = toppings. topping_id
    GROUP BY 1,2
    ORDER BY 3 DESC
    LIMIT 1
--3. What was the most common exclusion?
-- temp table to unnest the extras where there is no null

		WITH exclusions AS
    (SELECT order_id, exclusions, 
    UNNEST(STRING_TO_ARRAY(exclusions,','))::INTEGER AS exclusions_unnest
    FROM pizza_runner.customer_orders
    WHERE exclusions NOT IN ('','null'))
    -- joining temp table and toppings names and grouping by topping_id
    SELECT  topping_id, topping_name ,Count(order_id) AS num_of_times_excluded
    FROM exclusions
    JOIN pizza_runner.pizza_toppings as toppings
    ON exclusions_unnest = toppings. topping_id
    GROUP BY 1,2
    ORDER BY 3 DESC
    LIMIT 1

--4. Generate an order item for each record in the customers_orders table in the format of one of the following:
 -- Meat Lovers
 -- Meat Lovers - Exclude Beef
 -- Meat Lovers - Extra Bacon
 -- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
 
 WITH roll AS(
 SELECT *, ROW_NUMBER() OVER () AS row_index
 FROM pizza_runner.customer_orders),
 
    extras_unnest AS(
    SELECT sub.order_id, sub.row_index, sub.pizza_id, sub.extras, toppings.topping_name as extras_unnest
    FROM (SELECT *, 
    UNNEST(STRING_TO_ARRAY(extras,','))::INTEGER AS extras_unnest
    FROM roll
    WHERE extras NOT IN ('','null'))sub
    JOIN pizza_runner.pizza_toppings as toppings
    ON extras_unnest = toppings.topping_id),
    
    extras_nested as(
    SELECT row_index, STRING_AGG(extras_unnest,', ') as extras
    FROM extras_unnest
    GROUP BY 1),
      
    exclusions_unnest AS(
    SELECT sub.order_id, sub.row_index, sub.pizza_id, sub.exclusions, toppings.topping_name as exclusions_unnest
    FROM (SELECT *, 
    UNNEST(STRING_TO_ARRAY(exclusions,','))::INTEGER AS exclusions_unnest
    FROM roll
    WHERE exclusions NOT IN ('','null'))sub
    JOIN pizza_runner.pizza_toppings as toppings
    ON exclusions_unnest = toppings. topping_id),
      
    exclusions_nested as(
    SELECT row_index, STRING_AGG(exclusions_unnest,', ') as exclusions
    FROM exclusions_unnest
    GROUP BY 1)

    SELECT 
    CONCAT(pizza_name, 
           CASE WHEN exclusions.exclusions IS NULL THEN ' ' 
           ELSE ' - Exclude ' END,
           exclusions.exclusions,
           CASE WHEN extras.extras IS NULL THEN ' ' 
           ELSE ' - Add ' END,
           extras.extras) as orders
    FROM roll
    LEFT JOIN exclusions_nested as exclusions
    On roll.row_index=exclusions.row_index
    LEFT JOIN extras_nested as extras
    On roll.row_index=extras.row_index
    JOIN pizza_runner.pizza_names as pizza
    On pizza.pizza_id=roll.pizza_id

    
 
    
 
   
 

