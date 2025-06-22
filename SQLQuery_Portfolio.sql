--This is an example of querying data in SQL
--View the COVID death data
select * from ProjectPortfolio..CovidDeaths$
where continent is not null

--Select the data we will be using
select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeaths$
where continent is not null
order by 1,2

--Looking at total cases v. population, shows the Covid incidence rate by country
select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from ProjectPortfolio..CovidDeaths$
where continent is not null
order by 1,2

--Looking at total cases v. total deaths, shows the Covid death rate by country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from ProjectPortfolio..CovidDeaths$
where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 as InfectionRate
from ProjectPortfolio..CovidDeaths$
where continent is not null
group by location, population
order by InfectionRate desc

--Looking at countries with highest death rate compared to population
select location, MAX(cast(total_deaths as int)) as HighestDeathCount, population, MAX(total_deaths/population)*100 as DeathRate
from ProjectPortfolio..CovidDeaths$
where continent is not null
group by location, population
order by DeathRate desc

--Let's break things down by continent, showing continents with the highest death count  by population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate
from ProjectPortfolio..CovidDeaths$
where continent is not null
group by date
order by 1,2


--View the Covid vaccination data
select * 
from ProjectPortfolio..CovidVaccinations$

--Join Covid death and Covid vaccination data
select *
from ProjectPortfolio..CovidDeaths$ death
join ProjectPortfolio..CovidVaccinations$ vacc 
	on death.location = vacc.location
	and death.date = vacc.date

--Looking at total population v. vaccination
select death.continent, death.location, death.population, death.date, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location order by death.location, death.date) as RollingVaccinations, 
(RollingVaccinations/population)*100 
from ProjectPortfolio..CovidDeaths$ death
join ProjectPortfolio..CovidVaccinations$ vacc 
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 1,2,3

--Use a CTE
with vaccvpop (continent, location, date, population, new_vaccinations, RollingVaccinations)
as 
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingVaccinations
from ProjectPortfolio..CovidDeaths$ death
join ProjectPortfolio..CovidVaccinations$ vacc 
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
)

select *, (RollingVaccinations/population)*100 as VaccinationRate
from vaccvpop

--Temp table
DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar (255), 
location nvarchar (255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingVaccinations
from ProjectPortfolio..CovidDeaths$ death
join ProjectPortfolio..CovidVaccinations$ vacc 
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null

select *, (RollingVaccinations/population)*100 as VaccinationRate
from #PercentPopulationVaccinated

--Create view to store data for visulizations
Create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) as RollingVaccinations
from ProjectPortfolio..CovidDeaths$ death
join ProjectPortfolio..CovidVaccinations$ vacc 
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
