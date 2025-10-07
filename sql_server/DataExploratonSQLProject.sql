--select *
--From SQLPortfolioProject..CovidDeathsCopy


--select *
--From SQLPortfolioProject..CovidVaccination
--order by 3,4


select *
From SQLPortfolioProject..CovidDeaths
order by 3,4

-- for some continent is Null
select *
From SQLPortfolioProject..CovidDeaths
where continent is not null
order by 3,4





-- Select Data that we are going to be using 

select *
From SQLPortfolioProject..CovidDeaths
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From SQLPortfolioProject..CovidDeaths
order by 1,2

-- looking for total deaths vs total cases
-- shows likelihood if you contract covid in your country


select Location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
From SQLPortfolioProject..CovidDeaths
order by 1,2


select Location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
From SQLPortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- looking at Total Cases vs Population
-- Shows what percentage of population got covid
select Location, date, Population, total_cases, (total_cases/population)*100 as CasePercentage
From SQLPortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

select Location, date, Population, total_cases, (total_cases/population)*100 as CasePercentage
From SQLPortfolioProject..CovidDeaths
Where location = 'Philippines'
order by 1,2


-- Looking for Countries with Highest Infection rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From SQLPortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- Showing Countries with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount --something wront with the result total deaths should be int and not varchar
From SQLPortfolioProject..CovidDeaths
Group by Location
order by TotalDeathCount desc

--this is the accurate result need to cast the total deaths into integer
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc




-- Let's break things down by continent

-- Showing Continents with Highest Death Count per Population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount--this wrong count
From SQLPortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc --just for the purpose of showing  hierarchy (data amount is not accurate)

--this is accurate
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLPortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc 

--GLOBAL NUMBERS

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
From SQLPortfolioProject..CovidDeaths
Where continent is not null
Group By Date
order by 1,2


--Total cases and total deaths
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
From SQLPortfolioProject..CovidDeaths
Where continent is not null
--Group By Date
order by 1,2


--------------------------------------------------------------

Select *
From SQLPortfolioProject..CovidVaccination

Select *
From SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinatios

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3 --------------

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3--------------------

-- Looking at Total Population vs Vaccinatios

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population) *100
From SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE 
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population) *100
From SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
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
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population) *100
From SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) *100
From  #PercentPopulationVaccinated

-- Creating view to store data for later visualizations 


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population) *100
From SQLPortfolioProject..CovidDeaths dea
Join SQLPortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * 
From PercentPopulationVaccinated