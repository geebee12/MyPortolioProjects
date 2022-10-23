SELECT*
FROM
	PortfolioProject..CovidDeaths
ORDER BY 3,4 

--SELECT*
--FROM
--	PortfolioProject..CovidVaccinations
--ORDER BY 3,4

--SELECT DATA TO USE

SELECT Location, date, total_cases, total_deaths, population
FROM
	PortfolioProject..CovidDeaths
ORDER BY 1,2 




--*TOTAL CASES VS TOTAL DEATHS

SELECT 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths
--WHERE location = 'Philippines'
WHERE location like '%states%'
ORDER BY 1,2 



--*TOTAL CASES VS POPULATION

SELECT 
	Location, 
	date, 
	total_cases, 
	population, 
	(total_cases/population)*100 AS PopulationPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE location = 'Philippines'
--WHERE location like '%states%'
ORDER BY 1,2 



--*COUNTRIES WITH HIGHEST INFECTION RATE AS PER POPULATION

SELECT 
	Location, 
	MAX(total_cases) AS HighestInfectionCount, 
	population, 
	(MAX(total_cases)/population)*100 AS PopulationPercentage
FROM
	PortfolioProject..CovidDeaths
--WHERE location = 'Philippines'
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY PopulationPercentage desc


--*COUNTRIES WITH HIGHEST DEAT COUNT AS PER POPULATION

SELECT 
	Location, 
	MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
	--(MAX(total_deaths)/population)*100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Philippines'
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount desc


--*CHECKING DATA BY CONTINENT

SELECT 
	continent, 
	MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
	--(MAX(total_deaths)/population)*100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE continent IS NULL
--WHERE location = 'Philippines'
--WHERE location like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount desc


--CONTINENTS WITH HIGHEST DEATH COUNT

SELECT 
	continent, 
	MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
	--(MAX(total_deaths)/population)*100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location = 'Philippines'
--WHERE location like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount desc



--*GLOBAL NUMBERS

SELECT 
	--date, 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
	--total_deaths, 
	--(total_deaths/total_cases)*100 AS DeathPercentage
FROM
	PortfolioProject..CovidDeaths
--WHERE location = 'Philippines'
--WHERE location like '%states%'
WHERE 
	continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 



--*TOTAL POPULATION VS VACCINATIONS

SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
		vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER (Partition by vac.location
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN
	PortfolioProject..CovidVaccinations vac

	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY 2,3


--*USING CTE----------------------------------------------------------------------------------------



WITH PopsVac 
	(
	Continent, 
	Location, 
	Date, 
	Population, 
	New_vaccinations, 
	RollingPeopleVaccinated
	)
AS
(
SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER (Partition by vac.location
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN
	PortfolioProject..CovidVaccinations vac

	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,
	(RollingPeopleVaccinated/Population)*100
FROM
	PopsVac


--* CREATING TEMP TABLE----------------------------------------------------------------------------------------
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
	SELECT 
		dea.continent, 
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) 
			OVER (Partition by vac.location
			ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM
		PortfolioProject..CovidDeaths dea
	JOIN
		PortfolioProject..CovidVaccinations vac

		ON dea.location = vac.location
		AND dea.date = vac.date
	--WHERE	dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *,
	(RollingPeopleVaccinated/Population)*100
FROM
	#PercentPopulationVaccinated


--*CREATING VIEW TO STORE DATA FOR VISUALIZATION-------------------------------------

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) 
		OVER (Partition by vac.location
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
JOIN
	PortfolioProject..CovidVaccinations vac

	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE	dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated