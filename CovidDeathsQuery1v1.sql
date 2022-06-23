
SELECT * FROM PortfolioProject..CovidVaccinations$
order by 3,4

SELECT * FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
order by 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likliehood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount  desc

-- LETS BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount  desc

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths$
-- WHERE location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount  desc

-- Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
WHERE continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
,-- (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as

(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data later visualizations
Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT * 
FROM PercentPopulationVaccinated


