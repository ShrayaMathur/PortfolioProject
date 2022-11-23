
Select * From PortfolioProject..CovidDeaths$
where continent is not null
Order By 3,4

--Select * From PortfolioProject..CovidVaccinations$
--Order By Location, Date

-- select data to use

Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
From PortfolioProject..CovidDeaths$
where continent is not null
Order By Location,Date

--total cases vs total deaths
--showing chances of dying if you get covid in your country
Select Location, Date, Total_Cases, Total_Deaths,
(Total_Deaths/Total_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where Location like '%state%'
and continent is not null
Order By Location,Date

--total cases vs population
--how much % population got covid
Select Location, Date,Population, Total_Cases,
(Total_Cases/Population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Where Location like '%state%'
and continent is not null
Order By Location,Date

--countries with highest infection rate compared to population
Select Location,Population,max(Total_Cases) as MaxInfectedCount,
max((Total_Cases/Population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where Location like '%state%'
where continent is not null
Group By Location, Population
Order By PercentagePopulationInfected desc

--countries with highest death count per population
Select Location,max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%state%'
where continent is not null
Group By Location
Order By TotalDeathCount desc

--breaking down by continent
Select continent,max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%state%'
where continent is not null
Group By continent
Order By TotalDeathCount desc

--continents with highest death count per population
Select continent,max(cast(Total_Deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where Location like '%state%'
where continent is not null
Group By continent
Order By TotalDeathCount desc

--global numbers
Select date, sum(new_cases) as GlobalCaseCount,
sum(cast(new_deaths as int)) as GlobaDeathCount,
sum(cast(new_deaths as int))/sum(new_cases)*100 as GDeathCasePer
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2


Select  sum(new_cases) as GlobalCaseCount,
sum(cast(new_deaths as int)) as GlobaDeathCount,
sum(cast(new_deaths as int))/sum(new_cases)*100 as GDeathCasePer
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- use cte
with PopvsVac(Continent,Location, Date,Population,
New_Vaccinations,RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)select *,(RollingPeopleVaccinated/Population)/100
from PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)/100
from #PercentPopulationVaccinated

-- view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from
PercentPopulationVaccinated
