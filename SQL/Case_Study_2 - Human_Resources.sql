
--This is a solution for data in motion case study questions
--LINK--> https://d-i-motion.com/lessons/kedeishas-banking-services/
-- Human Resources case study

/*Skills demonstrated:
Basic aggregations
CASE WHEN statements
Window Functions - rank and lag
Joins
Text function Concat
CTEs
*/

--1. Find the longest ongoing project for each department.
--find the difference between start and end dates. Use concate to include days for the returned values. Join with departments to get department names 
SELECT departments.name as department,projects.name as project_name, CONCAT(end_date-start_date, ' ','days') as total_days
FROM projects
JOIN departments
ON projects.department_id=departments.id;

--2. Find all employees who are not managers.
-- As job title of managers have manager in it use NOT LIKE in WHERE condition to exclude managers.
SELECT departments.name, employees.name, job_title 
FROM departments 
JOIN employees
ON departments.id=employees.department_id
WHERE job_title NOT LIKE '%Manager';

--3. Find all employees who have been hired after the start of a project in their department.
--Join all three tables. 
--Filter only the employees joined after the start_date of the project using '>='
SELECT 	employees.name as employee, departments.name as department, 
		projects.name as project, hire_date, start_date
FROM employees
JOIN projects
	ON employees.department_id=projects.department_id
JOIN departments
	ON departments.id=employees.department_id
WHERE hire_date>=start_date;

--4. Rank employees within each department based on their hire date (earliest hire gets the highest rank).
--Use rank window function partition by department and order by hire date
SELECT employees.name, hire_date, departments.name as department, RANK()OVER(PARTITION BY department_id ORDER BY hire_date)
FROM employees
JOIN departments
ON employees.department_id=departments.id;


--5. Find the duration between the hire date of each employee and the hire date of the next employee hired in the same department.
  -- First in a CTE rank the employees based on hired date.
  --In second CTE use lag function to create a column of the hiring date of previous employee
  --the LAG() function can access data of the previous row, or the row before the previous row, and so on.
  --Using the CTE, find the difference between hiring date of the two employees
  --Use case statement to display if lag-by column is null 

WITH rankings as
(SELECT *, RANK()OVER(PARTITION BY department_id ORDER BY hire_date)
FROM employees),
lagging as(SELECT *,
lag(hire_date , 1) 
OVER (
    PARTITION BY department_id
    ORDER BY rank) as lag_by
FROM rankings)
SELECT name, 
CASE 
	WHEN lag_by ISNULL THEN 'N/A'
    ELSE CONCAT(hire_date-lag_by, ' ', 'days') END as duration
FROM lagging
    



