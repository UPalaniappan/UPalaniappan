# created temp table
# used case, joins, count and other window functions

#temp table DROP TABLE IF EXISTS thoughts_cleaned;

CREATE TABLE thoughts_cleaned (
	ID int,
	AI_Knowledge text,
	Feeling text,
	Rulling_society text,
	Economic_crisis text,
	Economic_growth text,
	Job_loss text
);

#cleaning thoughts table. using CASE sstatement
INSERT INTO thoughts_cleaned (
	SELECT
		ID,
		AI_Knowledge,
		Feeling,
		Rulling_society,
		Economic_crisis,
		CASE WHEN Economic_growth = 1
			OR Economic_growth = 2 THEN
			'Disagree'
		WHEN Economic_growth = 3 THEN
			'Neutral'
		ELSE
			'Agree'
		END AS Economic_growth,
		CASE WHEN Job_loss = 1
			OR Job_loss = 2 THEN
			'Disagree'
		WHEN Job_loss = 3 THEN
			'Neutral'
		ELSE
			'Agree'
		END AS Job_loss
	FROM
		thoughts)
	# No. of males and females participated in the survey
	SELECT
		Gender,
		COUNT(Gender) AS gender_count
FROM
	student
GROUP BY
	Gender;

#No. of males and females feels about AI using JOIN
SELECT
	feeling,
	gender,
	COUNT(feeling)
FROM
	thoughts_cleaned
	JOIN student ON thoughts_cleaned.ID = student.ID
GROUP BY
	feeling,
	gender
ORDER BY
	feeling,
	gender;

#feelings and gender by percentage
SELECT DISTINCT
	gender,
	feeling,
	ROUND((COUNT(feeling) OVER (PARTITION BY gender, feeling) / COUNT(feeling) OVER (PARTITION BY gender)) * 100, 2) AS percentage
FROM
	thoughts_cleaned
	JOIN student ON thoughts_cleaned.ID = student.ID;

#knowledge vs gender
SELECT DISTINCT
	gender,
	AI_Knowledge,
	ROUND((COUNT(AI_Knowledge) OVER (PARTITION BY gender, AI_Knowledge) / COUNT(AI_Knowledge) OVER (PARTITION BY gender)) * 100, 2) AS percentage
FROM
	thoughts_cleaned
	JOIN student ON thoughts_cleaned.ID = student.ID;

# feeling in percentage
SELECT DISTINCT
	feeling,
	ROUND(COUNT(feeling) OVER (PARTITION BY feeling) / COUNT(*) OVER () * 100, 2) AS percent_of_students
FROM
	thoughts_cleaned;

# counting feelings vs knowledge level
SELECT DISTINCT
	feeling,
	CASE WHEN ai_knowledge = 'High' THEN
		COUNT(feeling) OVER (PARTITION BY ai_knowledge,
			feeling)
	END AS high,
	CASE WHEN ai_knowledge = 'Little' THEN
		COUNT(feeling) OVER (PARTITION BY AI_Knowledge,
			feeling)
	END AS little,
	CASE WHEN ai_knowledge = 'Somewhat' THEN
		COUNT(feeling) OVER (PARTITION BY AI_Knowledge,
			feeling)
	END AS somewhat
FROM
	thoughts_cleaned;

#how many percentage think ai is useful in education uning WINDOW functions
SELECT DISTINCT
	Edu_useful,
	ROUND((COUNT(Edu_useful) OVER (PARTITION BY edu_useful) / count(*) OVER () * 100), 2) AS edu_useful_percentage
FROM
	education;

#students prediction about educational impacts
#Using CTE
WITH learning AS (
	SELECT
		advantage_learning AS impacts,
		ROUND(COUNT(Advantage_learning) OVER (PARTITION BY Advantage_learning) / COUNT(*) OVER () * 100,
		2) AS learn_adv
	FROM
		education ORDER BY
			learn_adv DESC
		LIMIT 1
),
teaching AS (
SELECT
	advantage_teaching AS impacts,
	ROUND(COUNT(Advantage_teaching) OVER (PARTITION BY Advantage_teaching) / COUNT(*) OVER () * 100,
2) AS teach_adv
FROM
	education ORDER BY
		teach_adv DESC
	LIMIT 1
),
disadv AS (
SELECT
	disadvantage AS impacts,
	ROUND(COUNT(disadvantage) OVER (PARTITION BY disadvantage) / COUNT(*) OVER () * 100,
2) AS disadv
FROM
	education ORDER BY
		disadv DESC
	LIMIT 1
)
SELECT
	*
FROM
	learning
UNION
SELECT
	*
FROM
	teaching
UNION
SELECT
	*
FROM
	disadv;

#Joining education and thoughts to find out what is the top opinion
WITH crisis AS (
	SELECT
		Economic_crisis AS impacts,
		'No Economic crisis' AS col,
		CASE WHEN Economic_crisis = 'Agree' THEN
			'YES'
		ELSE
			'NO'
		END AS y,
		ROUND(COUNT(Economic_crisis) OVER (PARTITION BY Economic_crisis) / COUNT(*) OVER () * 100,
		2) AS percent_feeling
	FROM
		thoughts_cleaned ORDER BY
			percent_feeling DESC
		LIMIT 1
),
growth AS (
SELECT
	Economic_growth AS impacts,
	'Economic growth' AS col,
	CASE WHEN Economic_growth = 'Agree' THEN
		'YES'
	ELSE
		'NO'
	END AS y,
	ROUND(COUNT(Economic_growth) OVER (PARTITION BY Economic_growth) / COUNT(*) OVER () * 100,
2) AS percent_feeling
FROM
	thoughts_cleaned ORDER BY
		percent_feeling DESC
	LIMIT 1
),
job AS (
SELECT
	Job_loss AS impacts,
	'Job loss' AS col,
	CASE WHEN Job_loss = 'Agree' THEN
		'YES'
	ELSE
		'NO'
	END AS y,
	ROUND(COUNT(Job_loss) OVER (PARTITION BY Job_loss) / COUNT(*) OVER () * 100,
2) AS percent_feeling
FROM
	thoughts_cleaned ORDER BY
		percent_feeling DESC
	LIMIT 1
),
education AS (
SELECT
	CASE WHEN Edu_useful = 'Extremely useful' THEN
		'Agree'
	END AS impacts,
	'Assists Education' AS col,
	CASE WHEN Edu_useful = 'Extremely useful' THEN
		'YES'
	ELSE
		'NO'
	END AS y,
	ROUND((COUNT(Edu_useful) OVER (PARTITION BY edu_useful) / count(*) OVER () * 100),
2) AS edu_useful_percentage
FROM
	education ORDER BY
		edu_useful_percentage DESC
	LIMIT 1
)
SELECT
	*
FROM
	crisis
UNION
SELECT
	*
FROM
	growth
UNION
SELECT
	*
FROM
	job
UNION
SELECT
	*
FROM
	education;

SELECT
	CASE WHEN Edu_useful = 'Extremely useful' THEN
		'Agree'
	WHEN Edu_useful = 'Somewhat useful' THEN
		'Neutral'
	ELSE
		'Disagree'
	END AS opinion,
	'education' AS question
FROM
	education
UNION ALL
SELECT
	Economic_crisis,
	'economic_crisis' AS question
FROM
	thoughts_cleaned
UNION ALL
SELECT
	Economic_growth,
	'economic_growth' AS question
FROM
	thoughts_cleaned
UNION ALL
SELECT
	Job_loss,
	'Job_loss' AS question
FROM
	thoughts_cleaned
