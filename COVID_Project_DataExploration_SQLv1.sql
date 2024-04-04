SELECT * 
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT * 
--FROM COVIDPortfolioProject..CovidVaccinations$
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at total cases vs. total deaths in United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM COVIDPortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY location, date

-- Looking at total cases vs. population in United States
-- Shows what percentage of United States population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM COVIDPortfolioProject..CovidDeaths
WHERE location = 'United States'
AND continent IS NOT NULL
ORDER BY location, date

-- Looking at infected population percentage of any country that has 'Stan' in the name
SELECT location,date, total_cases, total_deaths, population, (total_cases/population)*100 AS InfectedPopulationPercentage
FROM COVIDPortfolioProject..CovidDeaths
WHERE location LIKE '%stan%'
AND continent IS NOT NULL

-- Looking at large countries (<1M population) with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM COVIDPortfolioProject..CovidDeaths
WHERE population > 1000000
AND continent IS NOT NULL
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC

-- Looking at Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount 
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Looking at total death count broken down by continent 
SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount 
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 
SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount 
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS per day
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM COVIDPortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- JOIN CovidDeaths and CovidVaccinations
SELECT *
FROM COVIDPortfolioProject..CovidVaccinations AS dea
JOIN COVIDPortfolioProject..CovidDeaths AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date

--- Looking at total population vs. vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM COVIDPortfolioProject..CovidDeaths AS dea
JOIN COVIDPortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 

-- USING CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM COVIDPortfolioProject..CovidDeaths AS dea
JOIN COVIDPortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)* 100 AS PercentageVaccinated
FROM PopvsVac

-- USING TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM COVIDPortfolioProject..CovidDeaths AS dea
JOIN COVIDPortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/Population)* 100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated

-- Create view to store data for later data viz
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM COVIDPortfolioProject..CovidDeaths AS dea
JOIN COVIDPortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Can query off of new view
SELECT * 
FROM PercentPopulationVaccinated