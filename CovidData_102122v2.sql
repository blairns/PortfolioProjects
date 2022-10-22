Select *
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--FROM PortfolioProject..CovidDeaths
--Where location like '%canada%'
--Order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

--Select the data that is going to be used

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


--Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

--Looking at the Total Cases vs Population
-- Shows what % of population got COVID
Select location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

--Looking at Country with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by PercentofPopulationInfected desc

-- Showing countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Looking at the data by continent
-- Showing the contintents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- Global Breakdown
-- Shows Total World Cases, World Deaths, and Death Percentage for the World
Select date, SUM(new_cases) as TotalWorldCases, SUM(cast(new_deaths as int)) as TotalWorldDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

--Shows the Total World Cases,Deaths,and Death Percentage thru 10/18/22
Select SUM(new_cases) as TotalWorldCases, SUM(cast(new_deaths as int)) as TotalWorldDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2



--Take a look at Covid Vaccinations
Select *
FROM PortfolioProject..CovidVaccinations

--Join Covid Deaths and Covid Vaccinations Tables
Select *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date

-- Look at Total Vaccinations vs Population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Rolling count for daily vaccinations; count starts over when it reaches a new location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use a CTE
With PopluationvsVaccination (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
FROM PopluationvsVaccination



--Temp Table
DROP Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not null
ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100 
FROM  #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinatedv2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null

-- Query the View
Select *
FROM PercentPopulationVaccinatedv2