SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


--SELECT *
--FROM PortfolioProject..CovidVaccination$
--ORDER BY 3, 4

SELECT 
	location
	,Date
	,total_cases
	,new_cases
	,total_deaths
	,[ population ]
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


--Total cases vs Total Deaths
--Percentage column indicates likilihood of dying if you contracted covid in your country

SELECT 
	location
	,Date
	,Total_cases
	,Total_deaths
	,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases Vs Population
--Shows what percentage of population got percentage 
SELECT 
	location
	,Date
	,[ population ]
	,total_cases
	,total_deaths
	,(Total_cases/[ population ])*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--WHERE location Like '%States%'
ORDER BY 1, 2


--Countries with highest infection rate compared to population

SELECT 
	location
	,[ population ]
	,MAX(total_cases) AS HighestInfectionCount
	,MAX((Total_cases/[ population ]))*100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [Location], [ population ]
ORDER BY PercentOfPopulationInfected Desc


--Showing Countries with highest Death count per population

SELECT 
	location
	,MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [Location], [ population ]
ORDER BY  TotalDeathCount DESC

--Showing continents with the highest death count per population
SELECT 
	continent
	,MAX(CAST(Total_Deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  TotalDeathCount DESC


--Covid19 Global Numbers 

SELECT 
	 --Date
	SUM(New_cases) AS GlobalNewCases
	,SUM(CAST(New_deaths AS INT)) AS GlobalDeathCases
	,SUM(CAST(New_deaths AS INT))/SUM(new_cases)*100 AS GlobalNewDeathPercentages
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


---Total population vs vaccination
SELECT 
	cd.continent
	,cd.location
	,cd.date
	,cd.[ population ]
	,cv.new_vaccinations
	,SUM(CAST(cv.new_vaccinations AS INT)) OVER (PARTITION BY cd.Location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
	JOIN PortfolioProject..CovidVaccination$ cv ON cd.Location = cv.location
	AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3

--CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) --Columns here have to match columns in the SELECT STATEMENT
AS
(
SELECT 
	cd.continent
	,cd.location
	,cd.date
	,cd.[ population ]
	,cv.new_vaccinations
	,SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.Location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
	JOIN PortfolioProject..CovidVaccination$ cv ON cd.Location = cv.location
	AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *
	,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
	(
	continent NVARCHAR(255)
	,location NVARCHAR(255)
	,Date DATETIME
	,Population NUMERIC
	,New_vaccinations NUMERIC
	,RollingPeopleVaccinated NUMERIC
	)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	cd.continent
	,cd.location
	,cd.date
	,cd.[ population ]
	,cv.new_vaccinations
	,SUM(CONVERT(INT,cv.new_vaccinations)) 
	OVER (PARTITION BY 
		cd.Location 
		ORDER BY 
		cd.Location
		,cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
	JOIN PortfolioProject..CovidVaccination$ cv 
	ON  cd.Location = cv.location
	AND cd.date     = cv.date
--WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
	,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



---Creating view to store data for later visualization

Create View  PercentPopulationVaccinated AS
SELECT 
	cd.continent
	,cd.location
	,cd.date
	,cd.[ population ]
	,cv.new_vaccinations
	,SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.Location ORDER BY cd.Location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths cd
	JOIN PortfolioProject..CovidVaccination$ cv ON cd.Location = cv.location
	AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2, 3