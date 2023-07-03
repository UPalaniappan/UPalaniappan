#Is there any missing data? If so, visualize it in a plot.
#Remove any columns that you may find not useful for your analysis.
#Plot the top 10 cities with the most accidents.
#Plot the distribution of the start time.
#Is the distribution of accidents by hour the same on weekends as on weekdays?
#What is the distribution of start time on Sundays?
#Create a geographical plot to show accidents across a map of the United States.
#Among the top 100 cities in number of accidents, which states do they belong to most frequently?
#Which months have the most accidents?
#What is the trend of accidents year over year (decreasing/increasing?)
#Great job! Create a dashboard to showcase your insights!

#select everything
select * from work_file
LIMIT 10;

# the top 10 cities with the most accidents
SELECT City, count(ID)
FROM work_file
Group by 1
Order by 2 DESC
LIMIT 10;

#Plot the distribution of the start time.
select starts, count(starts) 
FROM (SELECT RIGHT(Start_Time,8) as starts FROM work_file) as subquery
GROUP BY starts;


#Is the distribution of accidents by hour the same on weekends as on weekdays?
SELECT start_date, hours, count(*)
FROM
(SELECT DAYNAME(SUBSTRING_INDEX(start_time,' ',1)) as start_date,
	LEFT(SUBSTRING_INDEX(start_time,' ',-1),2) as hours
FROM work_file	) as subquery
GROUP BY 1,2
ORDER BY 1,2;

#What is the distribution of start time on Sundays?
SELECT hours, count(*) as count
FROM
	(SELECT DAYNAME(SUBSTRING_INDEX(start_time,' ',1)) as start_date,
		SUBSTRING_INDEX(start_time,' ',-1) as hours
	FROM work_file	) as subquery
WHERE start_date ='Sunday'
GROUP BY 1
ORDER BY 1;


#Create a geographical plot to show accidents across a map of the United States.
SELECT  state, count(ID) as total_accidents
FROM work_file
GROUP BY state
ORDER by total_accidents DESC;

#Among the top 100 cities in number of accidents, which states do they belong to most frequently?
SELECT city, state, count(ID)as acc_count
FROM work_file
GROUP BY state,city
ORDER by acc_count DESC
LIMIT 100;

#Which months have the most accidents?
SELECT month_name, count(*) as no_of_acc
FROM
(SELECT MONTHNAME(SUBSTRING_INDEX(start_time,' ',1)) as month_name
FROM work_file	) as subquery
GROUP BY 1
ORDER BY 2 DESC;

#What is the trend of accidents year over year (decreasing/increasing?)
SELECT yearName, count(*) as no_of_acc
FROM
(SELECT YEAR(SUBSTRING_INDEX(start_time,' ',1)) as yearName
FROM work_file	) as subquery
GROUP BY 1
ORDER BY 1;

# year, month, state, city
SELECT year_name, state, city, count(*) as Total
FROM
(SELECT MONTHNAME(SUBSTRING_INDEX(start_time,' ',1)) as month_name,
	DATE(SUBSTRING_INDEX(start_time,' ',1)) as date_name,
	YEAR(SUBSTRING_INDEX(start_time,' ',1)) as year_name, state,city
FROM work_file	) as subquery
GROUP BY 1,2,3
ORDER BY total DESC;

# States where top 100 cities are
SELECT  state, count(city) as no_of_cities
FROM(SELECT state,city, count(*) as acc_count
FROM work_file
GROUP BY state, City
ORDER BY acc_count DESC
LIMIT 100) as subquery
GROUP BY 1
ORDER BY 2 DESC;
