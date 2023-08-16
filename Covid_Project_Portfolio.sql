
-- DATA ANALYST PROJECT PORFOLIO ON COVID19 CASES AROUND CONTINENT 
SELECT *
FROM [Covid Project Portfolio]..CovidDeaths
	WHERE continent is NOT NULL
		ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Project Portfolio]..CovidDeaths
	WHERE continent is NOT NULL
		ORDER BY 1,2

-- Looking at Total Cases Vs Total Deaths
-- Show Likelihood of Dying if contact Covid in your Country

SELECT location, date, total_cases, total_deaths, 
       (CONVERT(float, total_deaths) / CONVERT(float, total_cases))* 100 AS DeathPercentage
FROM [Covid Project Portfolio]..CovidDeaths
		WHERE location LIKE '%China%'
			AND continent is NOT NULL
				ORDER BY 1,2

-- Looking at Total Cases Vs Population
-- Show What percentage of Population got Covid

SELECT location, date, population,  total_cases, 
       (CONVERT(float, total_cases) / CONVERT(float, population))* 100 AS CovidPercentage
FROM [Covid Project Portfolio]..CovidDeaths
	--WHERE location LIKE '%China%'
		WHERE continent is NOT NULL
			ORDER BY 1,2

-- Looking at the Highest Infected Rate Compared to population 

SELECT location, population,  MAX(total_cases) AS HighestInfectionCount, 
       MAX((CONVERT(float, total_cases) / CONVERT(float, population)))* 100 AS InfectedPercentagepopulation
			FROM [Covid Project Portfolio]..CovidDeaths
				--WHERE location LIKE '%China%'
				WHERE continent is NOT NULL
					GROUP BY location, population
						ORDER BY InfectedPercentagepopulation DESC

--Creating view for Highest Infected Rate Compared to population to store Data for later Visualization

DROP VIEW IF EXISTS HighestInfectionCount
CREATE VIEW HighestInfectionCount AS
SELECT location, population,  MAX(total_cases) AS HighestInfectionCount, 
       MAX((CONVERT(float, total_cases) / CONVERT(float, population)))* 100 AS InfectedPercentagepopulation
			FROM [Covid Project Portfolio]..CovidDeaths
				--WHERE location LIKE '%China%'
				WHERE continent is NOT NULL
					GROUP BY location, population
SELECT *
FROM HighestInfectionCount

-- Showing the Countries with the Hihest DeathCount Population

SELECT  location,  MAX(CAST(total_deaths AS Int)) AS TotalDeathCount
			FROM [Covid Project Portfolio]..CovidDeaths
				--WHERE location LIKE '%China%'
			WHERE continent is NOT NULL	
				GROUP BY  location
						ORDER BY TotalDeathCount DESC

-- Breaking Donw By Continent

SELECT  continent,  MAX(CAST(total_deaths AS Int)) AS TotalDeathCount
			FROM [Covid Project Portfolio]..CovidDeaths
				--WHERE location LIKE '%China%'
			WHERE continent is NOT NULL
				GROUP BY  continent
						ORDER BY TotalDeathCount DESC

-- Creating view to storing Data for Highest Death Count by continent

CREATE VIEW ContinentTotalDeathCount AS
SELECT  continent,  MAX(CAST(total_deaths AS Int)) AS TotalDeathCount
			FROM [Covid Project Portfolio]..CovidDeaths
				--WHERE location LIKE '%China%'
			WHERE continent is NOT NULL
				GROUP BY  continent
	SELECT *
	FROM ContinentTotalDeathCount

-- Global Number NewCases Death and Percentage

SELECT  date,  SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
	CASE
		WHEN  SUM(new_cases) = 0 THEN NULL	
			ELSE SUM(CAST(new_deaths AS Int)) / NULLIF  (SUM(new_cases),0)*100 
	END AS DeathPercentage
			FROM [Covid Project Portfolio]..CovidDeaths
				--WHERE location LIKE '%China%'
					WHERE continent is NOT NULL
						GROUP BY  date
							ORDER BY DeathPercentage DESC

-- Total Global NewCases Death and Overal DeathPercentage

SELECT  SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
	CASE
		WHEN  SUM(new_cases) = 0 THEN NULL	
			ELSE SUM(CAST(new_deaths AS Int)) / NULLIF  (SUM(new_cases),0)*100 
	END AS DeathPercentage
			FROM [Covid Project Portfolio]..CovidDeaths
				--WHERE location LIKE '%China%'
					WHERE continent is NOT NULL
						ORDER BY DeathPercentage DESC

-- Looking at Total Population Vs Vaccination

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
FROM [Covid Project Portfolio]..CovidDeaths Dea
	JOIN [Covid Project Portfolio]..CovidVaccinations Vac
		ON Dea.location = Vac.location
			AND Dea.date = Vac.date	
				WHERE Dea.continent IS NOT NULL
					ORDER BY 1,2,3

-- Creating view for Total Population Vs Vaccination

DROP VIEW IF EXISTS PopulationVsVaccination
CREATE VIEW PopulationVsVaccination AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
FROM [Covid Project Portfolio]..CovidDeaths Dea
	JOIN [Covid Project Portfolio]..CovidVaccinations Vac
		ON Dea.location = Vac.location
			AND Dea.date = Vac.date	
				WHERE Dea.continent IS NOT NULL
					
SELECT *
FROM PopulationVsVaccination

-- Looking at Total Population Vs Vaccination on Rolling People Vaccination

--- Using CTE

WITH PopulationVsVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
		AS(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(FLOAT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM [Covid Project Portfolio]..CovidDeaths Dea
	JOIN [Covid Project Portfolio]..CovidVaccinations Vac
		ON Dea.location = Vac.location
			AND Dea.date = Vac.date	
				WHERE Dea.continent IS NOT NULL
					--ORDER BY 2,3
	)
SELECT *, (RollingPeopleVaccinated/population)*100
	FROM PopulationVsVaccination

--Temp Table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated(
	Continent Nvarchar(255),
	Location Nvarchar(255),
	Date datetime,
	Population Numeric,
	New_vaccinations Numeric,
	RollingPeopleVaccinated Numeric )

INSERT INTO #PercentagePopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(FLOAT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM [Covid Project Portfolio]..CovidDeaths Dea
	JOIN [Covid Project Portfolio]..CovidVaccinations Vac
		ON Dea.location = Vac.location
			AND Dea.date = Vac.date	
				--WHERE Dea.continent IS NOT NULL
					--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
	FROM #PercentagePopulationVaccinated

--Creating View to Store Data for Visualization

DROP VIEW IF EXISTS PercentagePopulationVaccinated
CREATE VIEW PercentagePopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations,
	SUM(CONVERT(FLOAT, Vac.new_vaccinations)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated
FROM [Covid Project Portfolio]..CovidDeaths Dea
	JOIN [Covid Project Portfolio]..CovidVaccinations Vac
		ON Dea.location = Vac.location
			AND Dea.date = Vac.date	
				WHERE Dea.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated

