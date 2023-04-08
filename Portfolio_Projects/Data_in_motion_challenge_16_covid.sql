#Did cleaning in EXCEL
#removed commas, changed data types to integers
#filled fillable fields(China population, if recovered and active cases can be calculated)
#removed 2 ships that were included
#Replaced N/A with null

SELECT * FROM covid;


#no. of countries participated
SELECT count(country) as no. of countries participated
FROM covid;


#death percentage
SELECT *, ROUND((deaths/population)*100,2) as death_percentage
FROM covid;

#top 5 countries with highest active cases
SELECT * , ROUND((active/cases)*100,2) as active_percent
FROM covid
ORDER BY active_percent DESC
LIMIT 5;


#top 5 countries with highest recoveries
SELECT * , (recovered/cases)*100 as recovered_percent
FROM covid
ORDER BY recovered_percent DESC
LIMIT 5;


#bottom 5 test percentage
SELECT * , (tests/population)*100 as test_percent
FROM covid
WHERE tests!='null'
ORDER BY test_percent
LIMIT 5;


select *, (tests/population)*100 as test_percent, (recovered/cases)*100 as recovered_percent,
			 ROUND((active/cases)*100,2) as active_percent,
FROM covid;
