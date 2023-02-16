SELECT *
FROM jeff_data..CovidD
Where continent is not null
Order by 3, 4

--SELECT *
--FROM PotfolioProject..CovidDeaths
--Order by 3, 4

--SELECT *
--FROM PotfolioProject..CovidVacinated
--Order by 3, 4
--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM jeff_data..CovidD
--Order by 1, 2

-- Death percentage in NIGERIA
-- Likelyhood of dying if you contacted covid in Nigeria
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM jeff_data..CovidD
Where location like '%nigeria%'
Order by 1, 2

-- Total cases Vs Population
-- Percentage of population that got Covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM jeff_data..CovidD
Where location like '%nigeria%'
Order by 1, 2

-- Countries with highest infection rate with respect to population
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM jeff_data..CovidD
Where continent is not null
Group by Location, Population
Order by PercentPopulationInfected desc

-- Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM jeff_data..CovidD
Where continent is not null
Group by Location, Population
Order by TotalDeathCount desc

-- Broken down by Continent


-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM jeff_data..CovidD
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- Global Numbers daily
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM jeff_data..CovidD
-- Where location like '%nigeria%'
where continent is not null
Group by date
Order by 1, 2

--Global Numbers Overall
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM jeff_data..CovidD
-- Where location like '%nigeria%'
where continent is not null
Order by 1, 2

-- Total Population Vs Vacinations from different Databases
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
FROM jeff_data..CovidD dea
JOIN jeff_data..CovidVacinated vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Use CTE

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
-- Total Population Vs Vacinations from different Databases
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
FROM jeff_data..CovidD dea
JOIN jeff_data..CovidVacinated vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac



-- TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
-- Total Population Vs Vacinations from different Databases
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
FROM jeff_data..CovidD dea
JOIN jeff_data..CovidVacinated vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated


-- Creating View To Store Data for Later Visualisation

Create View PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
FROM jeff_data..CovidD dea
JOIN jeff_data..CovidVacinated vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


SELECT *
FROM PercentagePopulationVaccinated