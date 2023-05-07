Select*
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4



--Select data that we are going to be using

Select location, date, total_cases, new_cases , total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


--Looking at Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
and continent is not null
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%States%'
and continent is not null
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc


--Looking at Countries with Highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Lets break things down by continent
---Showing continents with highest death count per population



Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by continent
order by TotalDeathCount desc






--Global numbers

--Total death percentage for whole world grouped by date

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
where continent is not null
Group by date 
order by 1,2


--Total death percentage for whole world

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
where continent is not null
--Group by date 
order by 1,2


--Looking at total population vs vaccination (JOIN)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
--Where dea.location like '%canada%'
where dea.continent is not null
Order by 2,3



--------------- Partion By

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast (vac.new_vaccinations as int)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
--Where dea.location like '%canada%'
where dea.continent is not null
Order by 2,3


------------- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast (vac.new_vaccinations as int)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
--Where dea.location like '%canada%'
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated /Population)*100
From PopvsVac


------Use Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast (vac.new_vaccinations as int)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
--Where dea.location like '%canada%'
where dea.continent is not null
--Order by 2,3


Select *, (RollingPeopleVaccinated /Population)*100
From #PercentPopulationVaccinated


---Crearting view to store data for later visualizations

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast (vac.new_vaccinations as int)) OVER (Partition by  dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject ..CovidDeaths dea
Join PortfolioProject ..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
--Where dea.location like '%canada%'
where dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated
