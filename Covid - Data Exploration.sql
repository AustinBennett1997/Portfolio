/*********************************************************************************************************************

Name: Austin Bennett
Raw Data: owid-covid-data
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
Description: The following code represents the ETL of the raw data separated
			 into the two tables CovidDeaths and CovidVaccinations. Will show
			 various data comparisions to show analysis of data. Will create
			 queries for data visualizations in a dashboard in Power BI.

*********************************************************************************************************************/

-- Selecting all from both tables to see raw data
SELECT *
FROM Covid..CovidDeaths
ORDER BY 3,4

SELECT *
FROM Covid..CovidVaccinations
ORDER BY 3,4


-- Select Data we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM Covid..CovidDeaths
WHERE Location like '%states%'
AND continent is not null
ORDER BY 1,2


-- Looking at new cases per location
SELECT continent, location, date, CAST(new_cases AS int) AS NewCases
FROM Covid..CovidDeaths
WHERE continent is not null
ORDER BY 2,3


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count compared to Population
SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Showing Continents with Highest Death Count
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM Covid..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global numbers
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
	   (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM Covid..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Joining both tables
SELECT *
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- Looking at Total Vaccinations vs Population / Partitioning
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVac) AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
	FROM Covid..CovidDeaths dea
	JOIN Covid..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent is not null
	--ORDER BY 2,3
)
SELECT *, (RollingPeopleVac/Population)*100 AS RPVvsPopulation
FROM PopvsVac


-- Creating a Temp Table for the Query above
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVac numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVac/Population)*100 AS RPVvsPopulation
FROM #PercentPopulationVaccinated


-- Creating View for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
FROM Covid..CovidDeaths dea
JOIN Covid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


/*----------------------------------------------------------------------------------------------------------------------------------------

Queries used for Power BI

*/----------------------------------------------------------------------------------------------------------------------------------------

-- 1. Total Cases, Deaths, and Percent Deaths
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
	(SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM Covid..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- 2. Total death count by Continent
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM Covid..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3. Infection Count and Percent Infected per Location
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4. -- 3. Infection Count and Percent Infected per Location by Date
SELECT Location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC


