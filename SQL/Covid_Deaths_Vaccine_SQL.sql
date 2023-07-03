--Select data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths`
ORDER BY 1,2;

 --Looking into total cases vs population every day
 SELECT Location, date, total_cases, total_deaths, (total_deaths/population)*100 as percent__population_infected
 FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths`
 WHERE Location LIKE '%States%' AND continent IS NOT NULL
ORDER BY date DESC;

--Looking at countries with highest infection rates compared to polpulation rates
SELECT Location, population, MAX(total_cases) as highest_infection, MAX((total_cases/population)*100) as highest_percent_infected
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY 1,2
ORDER BY highest_percent_infected DESC;


--showing highest death count in each country
SELECT Location, MAX(total_deaths) as highest_deaths,
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY highest_deaths DESC; 

--showing highest death count by continent(Using location is null to get datat we already have for the continents)
SELECT location, MAX(total_deaths) as highest_deaths,
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths`
WHERE continent IS NULL
GROUP BY 1
ORDER BY highest_deaths DESC;

--showing continents with highest death count per population
SELECT location as continents, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths`
--Where location like '%states%'
WHERE continent IS NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;

--GLOBAL FIGURES
--getting new cases every day
SELECT date, SUM(new_cases) as total_new_cases, SUM(new_deaths) as total_new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as percent_deaths_everyday
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths`
where continent is not null 
GROUP BY 1;

--Joining both tables
SELECT * 
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths` as deaths
JOIN `my-project-course-4-377418.Alex_project_1.Vaccinations` as vaccine
ON deaths.location = vaccine.location AND deaths.date=vaccine.date;

--population vs vaccinations
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, vaccine.total_vaccinations,
SUM(vaccine.new_vaccinations) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as rolling_total_vaccinated
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths` as deaths
JOIN `my-project-course-4-377418.Alex_project_1.Vaccinations` as vaccine
ON deaths.location = vaccine.location AND deaths.date=vaccine.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3;

--with CTE
WITH joined as(
  SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, vaccine.total_vaccinations,
SUM(vaccine.new_vaccinations) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as rolling_total_vaccinated
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths` as deaths
JOIN `my-project-course-4-377418.Alex_project_1.Vaccinations` as vaccine
ON deaths.location = vaccine.location AND deaths.date=vaccine.date
WHERE deaths.continent IS NOT NULL)
SELECT  continent,location, date, population, new_vaccinations,(rolling_total_vaccinated/population)*100 as percent_population_vacinated
FROM joined;

--TEMP TABLE
DROP TABLE if exists Alex_project_1.percent_vaccinated;
CREATE TABLE Alex_project_1.percent_vaccinated(
  continent STRING,
  location STRING,
  date DATE,
  population INT64,
  new_vaccinations INT64,
  percent_population_vaccinated FLOAT64
);
INSERT INTO Alex_project_1.percent_vaccinated
WITH joined as(
  SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, vaccine.total_vaccinations,
SUM(vaccine.new_vaccinations) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as rolling_total_vaccinated
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths` as deaths
JOIN `my-project-course-4-377418.Alex_project_1.Vaccinations` as vaccine
ON deaths.location = vaccine.location AND deaths.date=vaccine.date
WHERE deaths.continent IS NOT NULL)
SELECT  continent,location, date, population, new_vaccinations,(rolling_total_vaccinated/population)*100 as percent_population_vacinated
FROM joined;

--VIEW
--create view for later
CREATE VIEW Alex_project_1.percent_population_vaccinated as
WITH joined as(
  SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations, vaccine.total_vaccinations,
SUM(vaccine.new_vaccinations) OVER(PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as rolling_total_vaccinated
FROM `my-project-course-4-377418.Alex_project_1.CovidDeaths` as deaths
JOIN `my-project-course-4-377418.Alex_project_1.Vaccinations` as vaccine
ON deaths.location = vaccine.location AND deaths.date=vaccine.date
WHERE deaths.continent IS NOT NULL)
SELECT  continent,location, date, population, new_vaccinations,(rolling_total_vaccinated/population)*100 as percent_population_vacinated
FROM joined;

