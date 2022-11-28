Select*
From [Portfolio Project]..['Covid Deaths$']
Where continent is not null
Order by 3,4



--Select*
--From [Portfolio Project]..['covid vaccinations$']
--Order by 3,4



Select location,date,total_cases,new_cases,total_deaths,population
From [Portfolio Project]..['Covid Deaths$']
order by 3,4


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From [Portfolio Project]..['Covid Deaths$']
--where location like '%canada%'or location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


-- looking at Total Cases vs Total Deaths
-- The percentage shows the likelihood of dying if you contact covid in your country

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
From [Portfolio Project]..['Covid Deaths$']
where location like '%canada%'or location like '%states%'
order by 1,2

--looking at the Total cases vs Population
-- shows the percentage of population that contacted covid

Select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentagepopulationinfected
From [Portfolio Project]..['Covid Deaths$']
--where location like '%canada%'or location like '%states%'
group by location,population
order by percentagepopulationinfected desc

 
 -- showing the countries with the highest death count per population

 Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From [Portfolio Project]..['Covid Deaths$']
--where location like '%canada%'or location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--Breaking things down per continent

--showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From [Portfolio Project]..['Covid Deaths$']
--where location like '%canada%'or location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..['Covid Deaths$']
--where location like '%canada%'or location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date)
as PeopleVaccinated, (PeopleVaccinated/population)* 100
From  [Portfolio Project]..['Covid Deaths$'] dea
Join [Portfolio Project]..['covid vaccinations$'] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USING CTE

With Popvsvac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date)
as PeopleVaccinated--, (PeopleVaccinated/population)* 100 as AVGPeopleVaccinated
From  [Portfolio Project]..['Covid Deaths$'] dea
Join [Portfolio Project]..['covid vaccinations$'] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (PeopleVaccinated/Population) * 100 as AVGPeopleVaccinated
From Popvsvac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,dea.date)
as PeopleVaccinated--, (PeopleVaccinated/population)* 100
From  [Portfolio Project]..['Covid Deaths$'] dea
Join [Portfolio Project]..['covid vaccinations$'] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (PeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations )) OVER (partition by dea.location order by dea.location,dea.date)
as PeopleVaccinated--, (PeopleVaccinated/population)* 100
From  [Portfolio Project]..['Covid Deaths$'] dea
Join [Portfolio Project]..['covid vaccinations$'] vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,


Select*
From PercentPopulationVaccinated


CREATE VIEW TotalDeathCount as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From [Portfolio Project]..['Covid Deaths$']
--where location like '%canada%'or location like '%states%'
where continent is not null
group by continent
--order by TotalDeathCount desc

Select*
From TotalDeathCount 
