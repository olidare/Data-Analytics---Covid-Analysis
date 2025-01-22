SELECT * FROM CovidDeaths;


SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2;

-- looking at total cases vs total deaths.


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage  
FROM CovidDeaths
WHERE continent is not NULL
#where location like '%states%'
ORDER BY 1,2;


-- looking at total cases vs populatioon


SELECT Location, date, population, total_cases, (total_cases/Population)*100 as InfectedPercentage 
FROM CovidDeaths
where location like '%states%'
ORDER BY 1,2;


-- looking at countries with highest Infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage 
FROM CovidDeaths
GROUP BY Location, population
ORDER BY InfectedPercentage desc;

-- countries with highest death count per population
SELECT
	Location,
	MAX(total_deaths) AS TotalDeathCount
FROM
	CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	   Location
ORDER BY
	TotalDeathCount DESC;

-- CONTINENT

-- countries with highest death count per population
SELECT
	continent,
	MAX(total_deaths) AS TotalDeathCount
FROM
	CovidDeaths
WHERE
	continent IS NOT NULL
GROUP BY
	   continent
ORDER BY
	TotalDeathCount DESC;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
SUM(new_deaths)/ SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not NULL
;

-- looking at total population vs vaccinations


SELECT cd.continent, cd.location, cd.date, cd.population,
		cv.new_vaccinations, 
		SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.Date) as rollingVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date 
where cd.continent is not NULL
ORDER BY  2,3;


-- CTE 

WITH PopvsVac (Continent, Location, Date, population, new_vaccinations, rollingVaccinations )
 as 
 (
 SELECT cd.continent, cd.location, cd.date, cd.population,
		cv.new_vaccinations, 
		SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.Date) as rollingVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date 
where cd.continent is not NULL

)
SELECT *, (rollingVaccinations/Population)*100 as percVaccinated
FROM PopvsVac;



-- Create Temp Table

CREATE TABLE PercentPopulation (
    continent VARCHAR(255),
    location VARCHAR(256),
    date DATETIME,
    population INT,
    new_vaccinations INT,
    rollingVaccinations INT
);

INSERT INTO PercentPopulation 
SELECT cd.continent, cd.location, cd.date, cd.population,
		cv.new_vaccinations, 
		SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.Date) as rollingVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date 
where cd.continent is not NULL



SELECT *, (rollingVaccinations/Population)*100 as percVaccinated
FROM PercentPopulation;


-- Creating view to store for later

Create VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population,
		cv.new_vaccinations, 
		SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.Date) as rollingVaccinations
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date 
where cd.continent is not NULL
;



SELECT * FROM PercentPopulationVaccinated;