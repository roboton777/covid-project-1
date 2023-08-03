select *
from covidProj..CovidDeaths
order by 3,4

--select *
--from covidProj..CovidVaccinations
--order by 3,4

--select data that we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from covidProj..CovidDeaths
order by 1,2

-- total cases vs total deaths
--show likelihood of dying in us
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from covidProj..CovidDeaths
where location like '%states%'
order by 1,2

-- total cases vs total population
--show population infected percentage
select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from covidProj..CovidDeaths
order by 1,2

--highest infected rate country
select Location, population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
from covidProj..CovidDeaths
group by Location, population
order by InfectedPercentage desc

--country with highest death rate
select Location,MAX(cast(total_deaths as bigint)) as TotalDeathCount
from covidProj..CovidDeaths
where continent is not null
group by Location, population
order by TotalDeathCount desc

--sort by continent
select Location,MAX(cast(total_deaths as bigint)) as TotalDeathCount
from covidProj..CovidDeaths
where continent is null
group by Location
order by TotalDeathCount desc

--continent with highest death rate
select continent,MAX(cast(total_deaths as bigint)) as TotalDeathCount
from covidProj..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths,SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
from covidProj..CovidDeaths
where continent is not null
order by 1,2

--population vs vaccination
with popvsvac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from covidProj..CovidDeaths dea
join covidProj..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select*, (rollingPeopleVaccinated/population)/100
from popvsvac


--temp table
drop table if exists #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric
)



insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from covidProj..CovidDeaths dea
join covidProj..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Select*, (rollingPeopleVaccinated/population)/100
from #percentPopulationVaccinated

--create view data for visualization
create view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from covidProj..CovidDeaths dea
join covidProj..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select*
from percentPopulationVaccinated