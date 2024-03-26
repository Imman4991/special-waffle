USE PortfolioProject

SELECT *
FROM CovidDeaths
WHERE continent is not null
Order by 3,4

SELECT*
FROM CovidVaccinations
WHERE continent is not null
Order by 3,4

-- Select Data that we are going to be using


SELECT location, date, total_cases, new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT CONVERT(int, total_deaths) AS total_death
FROM CovidDeaths;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths INT;

SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       CAST((total_deaths * 100.0 / total_cases) AS DECIMAL(10, 2)) AS Deathpercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1, 2;

SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       CAST((total_deaths * 100.0 / total_cases) AS DECIMAL(10, 2)) AS Deathpercentage
FROM CovidDeaths
WHERE continent is not null
AND location LIKE '%verde'
ORDER BY 1, 2;

SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       CAST((total_deaths * 100.0 / total_cases) AS DECIMAL(10, 2)) AS Deathpercentage
FROM CovidDeaths
WHERE continent is not null
AND location LIKE '%and%'
ORDER BY 1, 2;

SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       CAST((total_deaths * 100.0 / total_cases) AS DECIMAL(10, 2)) AS Deathpercentage
FROM CovidDeaths
WHERE continent is not null
AND location = 'Canada'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases INT;

SELECT location, 
       date,
	   population,
       total_cases,  	
       CAST((total_cases   * 100.0 / population ) AS DECIMAL(10, 2)) AS Casepercentage
FROM CovidDeaths
WHERE continent is not null
AND location = 'Canada'
ORDER BY 1, 2;

-- Looking at Countries with Higjest Infection rate compared to Population

SELECT location, 
	   population,
       MAX(total_cases) as HighestInfectionCount,  	
       CAST (Max(total_cases   * 100.0 / population ) AS DECIMAL(10, 2)) AS PercentagePopulationInfected
FROM CovidDeaths
--WHERE location = 'Canada'
WHERE continent is not null
GROUP BY location, Population
ORDER BY PercentagePopulationInfected;

--Showing Countries with Highest Death Count per Population

SELECT location,
       MAX(Cast(total_deaths as int)) as TotalDeathCount
	   FROM CovidDeaths
	   WHERE continent is not null
	   GROUP BY location
	   ORDER BY TotalDeathCount desc

SELECT location, 
	   population,
       MAX(total_deaths) as TotalDeathCount,  	
       CAST (Max(total_deaths  * 100.0 / population ) AS DECIMAL(10, 2)) AS PercentagePopulationDeaths
FROM CovidDeaths
--WHERE location = 'Canada'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationDeaths;

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent,
       MAX(Cast(total_deaths as int)) as TotalDeathCount
	   FROM CovidDeaths
	   WHERE continent is not null
	   GROUP BY continent	
	   ORDER BY TotalDeathCount desc

SELECT location,
       MAX(Cast(total_deaths as int)) as TotalDeathCount
	   FROM CovidDeaths
	   WHERE continent is null
	   GROUP BY location	
	   ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT   
       SUM(new_cases) as total_cases, 
	   SUM(CAST(new_deaths as int)) as total_deaths, 
	   SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2;
-- The above encountered an error as there were cases where the divider was Zero

-- To avoid the divide by zero error in your query, 
-- You can use the NULLIF() function to handle cases where the divisor (SUM(new_cases)) is zero. 
-- Here's how you can adjust your query:

SELECT date,
    SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths as int)) as total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths as int)) * 100.0 / SUM(new_cases)
    END AS DeathPercentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    date
ORDER BY 
    1, 2;

SELECT
    SUM(new_cases) as total_cases, 
    SUM(CAST(new_deaths as int)) as total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(CAST(new_deaths as int)) * 100.0 / SUM(new_cases)
    END AS DeathPercentage
FROM 
    CovidDeaths
WHERE 
    continent IS NOT NULL
--GROUP BY 
--    date
ORDER BY 
    1, 2;


-- Looking at Total Population vs Vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  2, 3

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS CummulatedNewVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  2, 3

-- OR 

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  2, 3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
as(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac


-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3

SELECT *
FROM PercentPopulationVaccinated