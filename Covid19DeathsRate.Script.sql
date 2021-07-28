SELECT *
FROM PorfolioProject..CovidDeaths
WHERE continent iS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PorfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Validate Data first and Select the Colums to used in dbo.CovidDeaths Table

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
ORDER BY 1,2


-- Difference between Total cases and Total Deaths
-- This query ilight the effect to Covid Contraction rate in Nigeria.


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2


-- Covid Total cases Vs Population
-- number of Covid rate among population


SELECT Location, date, population, total_cases, (total_cases/population)*100 AS CovidRate
FROM PorfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
ORDER BY 1,2


-- Countries with hight Rate of Covid cases compared to there population


SELECT Location, population, MAX(total_cases) AS HighestInfectionCount , MAX(total_cases/population)*100 AS PopulationInfectedRate
FROM PorfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
GROUP BY Location, Population
ORDER BY PopulationInfectedRate DESC


-- Highest death Count Per Population for  every countries

SELECT Location, MAX(Cast(Total_deaths as int)) AS ToTalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent iS NOT NULL
GROUP BY Location, Population
ORDER BY ToTalDeathCount DESC


-- Continent Covid Count


SELECT continent, MAX(Cast(Total_deaths as int)) AS ToTalDeathCount
FROM PorfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT  NULL
GROUP BY continent
ORDER BY ToTalDeathCount DESC



--Global Covid Numbers


SELECT  date, SUM(new_cases) AS Total_cases, SUM(Cast(new_deaths as int)) AS Total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentageRate
FROM PorfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- world Total_cases and Total_deaths

SELECT  SUM(new_cases) AS Total_cases, SUM(Cast(new_deaths as int)) AS Total_deaths, 
SUM(Cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentageRate
FROM PorfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Total Population Vs Vaccinations



SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.location order by a.location, a.date)
AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths a
JOIN PorfolioProject..CovidVaccinations b
    ON  a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
	ORDER BY 2,3


-- Creating CTE 

WITH PopvsVac (Continent, Location , Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.location order by a.location, a.date)
AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths a
JOIN PorfolioProject..CovidVaccinations b
    ON  a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
	--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE 
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
   Continenr nvarchar(255),
   Location nvarchar(255),
   Date datetime,
   Population numeric,
   New_vaccinations numeric,
   RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated

SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.location order by a.location, a.date)
AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths a
JOIN PorfolioProject..CovidVaccinations b
    ON  a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
	--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated



-- Creating View to Store Data for Visualizations 


Create View  PercentagePopulationVaccinated as
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations
, SUM(CONVERT(int,b.new_vaccinations)) OVER (Partition by a.location order by a.location, a.date)
AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeaths a
JOIN PorfolioProject..CovidVaccinations b
    ON  a.location = b.location
	AND a.date = b.date
WHERE a.continent IS NOT NULL
--ORDER BY 2,3