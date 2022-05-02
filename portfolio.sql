SELECT * FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4 

--SELECT * FROM covid_vac
--ORDER BY 3,4 

-- Select Data that we are going to be using 

SELECT location,date,total_case,new_cases,total_deaths,population
FROM covid_deaths
ORDER BY 1,2 

--Looking at Total Cases vs Total Deaths


-- Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage 
FROM covid_deaths
WHERE location LIKE '%Turkey%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location,date,population,total_cases,(total_cases/population)*100 AS Percent_population_infection
FROM covid_deaths
--WHERE location LIKE '%Turkey%'
WHERE continent IS NOT NULL
ORDER BY 1,2 DESC


-- Looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) AS Highest_infection_count,MAX((total_cases/population))*100 AS Percent_population_infected 
FROM covid_deaths
--WHERE location LIKE '%Turkey%'
WHERE continent IS NOT NULL
GROUP BY population,location
ORDER BY Percent_population_infected DESC


--Showing countries with highest death count per population
SELECT location,MAX(cast(total_deaths as int)) AS Total_death_count
FROM covid_deaths
--WHERE location LIKE '%Turkey%'
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY Total_death_count DESC

-- Let's break things down by continent

SELECT continent,MAX(cast(total_deaths as int)) AS Total_death_count
FROM covid_deaths
--WHERE location LIKE '%Turkey%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY Total_death_count DESC

-- Showing the continents with the highest count per population

SELECT continent,MAX(cast(total_deaths as int)) AS Total_death_count
FROM covid_deaths
--WHERE location LIKE '%Turkey%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY Total_death_count DESC


-- Global numbers

SELECT SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage 
FROM covid_deaths
--WHERE location LIKE '%Turkey%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs Vaccination


SELECT dea.continent, dea.location,dea.date,population,vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM covid_deaths dea
JOIN covid_vac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 


-- USE CTE

WITH PopvsVac (Continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
AS 
(
SELECT dea.continent, dea.location,dea.date,population,vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM covid_deaths dea
JOIN covid_vac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT * ,(rolling_people_vaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS percent_population_vaccinated
CREATE TABLE percent_population_vaccinated
(
	Continent varchar(255),
	location varchar (255),
	Date date,
	Population numeric,
	New_vaccinations numeric,
	rolling_people_vaccinated numeric
)
INSERT INTO percent_population_vaccinated
SELECT dea.continent, dea.location,dea.date,population,vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM covid_deaths dea
JOIN covid_vac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT * ,(rolling_people_vaccinated/population)*100
FROM percent_population_vaccinated


--Creating View to store data for later visualzations

CREATE VIEW percent_population_vaccinated AS
SELECT dea.continent, dea.location,dea.date,population,vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM covid_deaths dea
JOIN covid_vac vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT* 
FROM percent_population_vaccinated


