SELECT *
FROM PortfolioProject..CovidDeaths
Order by 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations
Order by 3, 4

-- Selecting the needed data

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Total cases vs Total deaths
Select location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Order by 1, 2

-- Show likelihood of dying if you contract Covid Virus

Select location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

-- Total Cases VS Population (shows the percentage of the total population that got covid)

Select location, date, population, total_cases, (CONVERT(float,total_cases)/population)*100 as PercentPoplationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1, 2

-- Countries with highest infection rate compared to their population

Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CONVERT(float,total_cases)/population)*100 as PercentPoplationInfected
From PortfolioProject..CovidDeaths
Group by population, location
Order by PercentPoplationInfected

-- Countries with highest death count per population

Select location, MAX(CONVERT(float,total_cases)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Group by location
Order by TotalDeathCount desc

-- To remove the null continent

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Total Death Count by Continent

Select location, MAX(CONVERT(float,total_cases)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Joining CovidDeaths and CovidVaccinations table

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3


-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE (Common Table Expressions) to know how many people in the country got vaccinated
With PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVacinated)
as
(

/*
*/

-- Temp Tables

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for visualizations later

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated

CREATE VIEW DeathCount AS
Select location, MAX(CONVERT(float,total_cases)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location

SELECT *
FROM DeathCount

