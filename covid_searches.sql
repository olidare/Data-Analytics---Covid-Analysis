Use Covid;

SELECT location, date, continent, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent is not null
order by 1,2
;



-- looking at total cases vs total_deaths

SELECT location, date, total_cases, total_deaths,
 (total_deaths/total_cases)*100 as death_perc 
FROM covid_deaths
WHERE location like '%states%' 
order by 1,2
;

-- looking at total cases vs population

SELECT location, date, population, total_cases,
 (total_cases/population)*100 as population_perc 
FROM covid_deaths
WHERE location like '%states%' 
order by 1,2
;

-- looking at highest infection rate compared to country 

SELECT location, date, population, MAX(total_cases) as total_cases,
 MAX((total_cases/population)*100) as highest_infection_perc 
FROM covid_deaths
GROUP BY location, population
order by highest_infection_perc DESC
LIMIT 10
;


-- looking at highest death count per population

SELECT location, continent, date, population, MAX(total_deaths) as total_deaths
FROM covid_deaths
WHERE continent != ""
GROUP BY location
order by total_deaths DESC
LIMIT 10;



-- lets split by continent

-- shwowing continents with highest death count 

SELECT continent, date, population, MAX(total_deaths) as total_deaths
FROM covid_deaths 
WHERE continent != ""
GROUP BY continent
order by total_deaths DESC;


-- global numbers

SELECT SUM(new_cases), SUM(total_cases), SUM(total_deaths),
 (SUM(new_deaths)/SUM(new_cases)) as death_perc 
FROM covid_deaths
WHERE continent != ""
;


INSERT INTO Percent_Population_Vaccinated
SELECT cd.continent, cd.location, cd.date, cd.population,
cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition BY cd.location ORDER BY cd.location, cd.date)
AS rolling_people_vaccinated
FROM covid_deaths as cd
JOIN covid_vaccinations as cv
	on cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent != ""
order BY 2,3;

-- using CTE 


WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population,
cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition BY cd.location ORDER BY cd.location, cd.date)
AS rolling_people_vaccinated
FROM covid_deaths as cd
JOIN covid_vaccinations as cv
	on cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent != "" 
) 
SELECT *, (pv.rolling_people_vaccinated/pv.population)*100
FROM PopvsVac as pv
;



DROP TABLE if exists Percent_Population_Vaccinated;
CREATE TABLE Percent_Population_Vaccinated (
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    population BIGINT,
    new_vaccinations BIGINT,
    rolling_people_vaccinated BIGINT
);


SELECT *, (pv.rolling_people_vaccinated/pv.population)*100
FROM Percent_Population_Vaccinated as pv; 

CREATE VIEW Percent_Population_Vaccinated_View as 
SELECT cd.continent, cd.location, cd.date, cd.population,
cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (Partition BY cd.location ORDER BY cd.location, cd.date)
AS rolling_people_vaccinated
FROM covid_deaths as cd
JOIN covid_vaccinations as cv
	on cd.location = cv.location
    AND cd.date = cv.date
WHERE cd.continent != "" 



