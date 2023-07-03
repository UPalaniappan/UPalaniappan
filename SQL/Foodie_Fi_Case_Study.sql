--Features Joins, Aggregations, Date Functions, CASE statements, Window Functions RANK, WIDTH_BUCKET
--This is a solution for Danny mas's SQL case study foodie-fi questions
--LINK--> https://8weeksqlchallenge.com/case-study-3/
--Case Study #3 - Foodie-Fi

--Part 1
--Customer Journey
/*Based off the 8 sample customers provided in the sample from the subscriptions table, #write a brief description about each customer’s onboarding journey.
SELECT
customer_id, start_date, 
plan_name, price 
FROM foodie_fi.subscriptions as s
JOIN foodie_fi.plans as p
on s.plan_id = p.plan_id
WHERE customer_id<=8
ORDER BY 1, start_date;
Customer 1 - After the trial period the customer is in the basic plan.
Customer 2 - After the trial period the customer opted for the pro annual plan.
Customer 3 - After the trial period the customer is in the basic plan.
Customer 4 - After the trial period the customer is in the basic plan and canceled the subscription after 3 months.
Customer 5 - After the trial period the customer is in the basic plan.
Customer 6 - After the trial period the customer is in the basic plan and canceled the subscription after 2 months.
Customer 7 - After the trial period the customer was on a basic plan and upgraded to pro monthly after 3 months.
Customer 8 - After the trial period the customer is in the basic plan and upgraded to pro monthly after 2 months.*/

-- Data analysis Questions
-- 1. How many customers has Foodie-Fi ever had?

SELECT 
		COUNT (DISTINCT customer_id) as total_customers
FROM foodie_fi.subscriptions

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT 
	EXTRACT(MONTH FROM start_date) as month, COUNT(Customer_id) as total_customers
FROM foodie_fi.subscriptions as s
JOIN foodie_fi.plans as p
ON s.plan_id=p.plan_id
WHERE plan_name='trial'
GROUP BY EXTRACT(MONTH FROM start_date)
ORDER BY 1

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the #breakdown by count of events for each plan_name

SELECT 
	plan_name, COUNT(customer_id)
FROM foodie_fi.subscriptions as s
JOIN foodie_fi.plans as p
ON s.plan_id=p.plan_id
WHERE EXTRACT(YEAR FROM start_date)>2020
GROUP BY 1

-- 4.What is the customer count and percentage of customers who have churned rounded to 1 #decimal place?

SELECT 
	COUNT(DISTINCT customer_id),
    SUM(CASE WHEN plan_name='churn' THEN 1 END) as churn_customers,
	ROUND(CAST(100*SUM(CASE WHEN plan_name='churn' THEN 1 END)as decimal)/
    CAST(COUNT(DISTINCT customer_id) as decimal),1) as percentage_of_churn          
FROM foodie_fi.subscriptions as s        
JOIN foodie_fi.plans as p
ON s.plan_id=p.plan_id


--5.	How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
  
WITH rankings as
(SELECT 
	customer_id, p.plan_id, p.plan_name,
	RANK()OVER(PARTITION BY CUSTOMER_id ORDER BY start_date) as ranking
FROM foodie_fi.plans as p
JOIN foodie_fi.subscriptions as s
ON s.plan_id = p.plan_id
)
SELECT 
	COUNT(CASE WHEN ranking=2 AND plan_name='churn' THEN 1 END) as total_churn,
    ROUND(CAST(COUNT(CASE WHEN ranking=2 AND plan_name='churn' THEN 1 END) as DECIMAL)/ CAST(count(distinct customer_id) as DECIMAL)*100,1) as percentage_churn_trail
FROM rankings


-- 6.	What is the number and percentage of customer plans after their initial free trial?
  
# give ranks in the order of plans start date
# With the ranks find count of plans after trial grouped by plan_id alse ranking should be 2.
#find percentage using total plan_id count

WITH rankings as
(SELECT 
	customer_id, p.plan_id, p.plan_name,
	RANK()OVER(PARTITION BY CUSTOMER_id ORDER BY start_date) as ranking
FROM foodie_fi.plans as p
JOIN foodie_fi.subscriptions as s
ON s.plan_id = p.plan_id
)
SELECT 
	plan_name,
	COUNT(customer_id) as count_of_conversion,
    ROUND(CAST(COUNT(customer_id) as DECIMAL)/CAST((SELECT COUNT(plan_id) from rankings WHERE ranking = 2) as DECIMAL)*100,1)
FROM rankings
WHERE ranking=2
GROUP BY plan_name

-- 7.	What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31
-- rank customers with descending start date where start date is less than or equal to 2020-12-31
-- Then find the count of customers at rank 1 that is currently on the plan
-- Then find the percentage

WITH rankings as
(SELECT 
	customer_id, p.plan_id, p.plan_name,
	RANK()OVER(PARTITION BY CUSTOMER_id ORDER BY start_date DESC) as ranking
FROM foodie_fi.plans as p
JOIN foodie_fi.subscriptions as s
ON s.plan_id = p.plan_id
WHERE start_date<='2020-12-31' 
)
SELECT 
	plan_name,
	COUNT(customer_id) as customers,
    ROUND(CAST(COUNT(customer_id) as DECIMAL)/CAST((SELECT COUNT(plan_id) from rankings WHERE ranking = 1) as DECIMAL)*100,1)
FROM rankings
WHERE ranking=1
GROUP BY plan_name

-- 8.	How many customers have upgraded to an annual plan in 2020?

SELECT 
	count(*)
FROM foodie_fi.plans as p
JOIN foodie_fi.subscriptions as s
ON s.plan_id = p.plan_id
WHERE EXTRACT(YEAR FROM start_date)='2020' and plan_name='pro annual'

9.	How many days on average does it take for a customer to an annual plan from the day #they join Foodie-Fi?
-- self join subscriptions
-- filter only where the trail plan is equal to pro annual (s1.plan_id+3=s2.plan_id) and plan is proannual in s2
-- find average
SELECT CONCAT(ROUND(AVG(s2.start_date-s1.start_date), 0),' days') as avg_days
FROM foodie_fi.subscriptions as s1
JOIN foodie_fi.subscriptions as s2
ON s1.customer_id=s2.customer_id
WHERE s1.plan_id+3=s2.plan_id and s2.plan_id=3

10.	Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 #days etc)
-- use WIDTH_BUCKET function to allocate bins. We are alotting the datediff into 1-360 into 12 bins. 
-- use the bin to find the days with CONCAT
-- find the count and avg
WITH bins as
(SELECT s2.start_date-s1.start_date as daysDiff,
WIDTH_BUCKET(s2.start_date-s1.start_date,1,360,12) as bins
FROM foodie_fi.subscriptions as s1
JOIN foodie_fi.subscriptions as s2
ON s1.customer_id=s2.customer_id
WHERE s1.plan_id+3=s2.plan_id and s2.plan_id=3)

SELECT 
	CONCAT(((bins-1)*30)+1,'-', bins*30, ' days') as bin, 
    COUNT(bins), ROUND(AVG(daysdiff),0) as avg_days
FROM bins
GROUP BY bins

11.	How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
--self join subscriptions
-- filter when plan is basic to pro monthly using ‘s1.plan_id-1=s2.plan_id and 
--s2.plan_id=1’ and s2 start date is lesser than s1 start date and year is 2020
 
SELECT COUNT(s1.customer_id)
FROM foodie_fi.subscriptions as s1
JOIN foodie_fi.subscriptions as s2
ON s1.customer_id=s2.customer_id
WHERE s1.plan_id-1=s2.plan_id and 
	s2.plan_id=1 and 
	EXTRACT(YEAR FROM s2.start_date)='2020'
    AND (s2.start_date - s1.start_date) > 0


