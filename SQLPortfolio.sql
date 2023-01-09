
SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

--Select Data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Comparing Total Cases with Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_rate
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Switzerland'
ORDER BY 2

--Comparing Total Cases with the Population of a Country

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationInfected_rate
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Switzerland'
ORDER BY 2

--Comparing the Infection count peak with the Population of a Country

SELECT location, population, MAX(total_cases) AS HighestInfection_count, (MAX(total_cases)/population)*100 AS PopulationInfected_rate
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Switzerland'
GROUP BY location, population
ORDER BY 4 DESC

--Comparing the Total Death count with the Population of a Country

SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeath_count, (MAX(total_deaths)/population)*100 AS Death_rate
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Switzerland'
GROUP BY location, population
ORDER BY 4 DESC

--Comparing the Total Death count with the Population of a Continent

SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeath_count, (MAX(total_deaths)/population)*100 AS Death_rate
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location, population
ORDER BY 4 DESC

-- Global numbers 

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeath, (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Death_rate
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null

-- Looking at Total Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalVaccinatedPeople
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- In order to use the last created column we can do either a CTE or a Temp Table

--CTE

with CTE (continent, location, date, population, new_vaccinations, TotalVaccinatedPeople)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalVaccinatedPeople
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (TotalVaccinatedPeople/population)*100 AS PercentageVaccinatedPeople
FROM CTE

-- Temp Table

DROP TABLE IF exists #Vaccinatedrate
CREATE TABLE #Vaccinatedrate
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinatedPeople numeric
)
INSERT INTO #Vaccinatedrate
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalVaccinatedPeople
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (TotalVaccinatedPeople/population)*100 AS PercentageVaccinatedPeople
FROM #Vaccinatedrate

--Creating view to store data for visualization in Tableau

CREATE VIEW Vaccinatedrate AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS TotalVaccinatedPeople
FROM PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
