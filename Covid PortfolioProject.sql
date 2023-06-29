select * from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

select location, date, population, total_cases,new_cases, total_deaths from PortfolioProject..CovidDeaths
order by 1,2

--total cases vs total deaths in this country
--shows the death percentage 

select location, date, total_cases, total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2

--looking at total cases vs the population
--shows what percenatge of the population got covid

select location, date,population, total_cases ,(total_cases/population)*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%States%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location,population, MAX(total_cases) as HighestInfectionCount ,MAX((total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not NULL
group by population, location
order by PercentofPopulationInfected desc

--showing Countries with Highest death count per population

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not NULL
group by location
order by TotalDeathCount desc

--LETS BREAK IT DOWN BY CONTINENT

--showing the continent with highest death count per population

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not NULL
group by continent
order by TotalDeathCount desc


select  SUM (new_cases) as total_cases, SUM (CAST(new_deaths as int)) as total_deaths, SUM (CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not NULL
--group by date
order by 1,2


--Looking at total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
order by 2,3

--Use CTE

With PopvcVac (continent, Location, date, population,new_vaccinations,RollingPeopleVaccinated )
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvcVac


--Temp TABLE

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated

(
Continent nvarchar(255),
location nvarchar(255),
date Datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


insert into #PercentPopulationVaccinated  
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not NULL
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from  #PercentPopulationVaccinated



--Creating a VIEW to use for vizualization

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3

Select * from  PercentPopulationVaccinated
