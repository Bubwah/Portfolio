SELECT *
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
Where continent is not null
ORDER BY 3,4

-- Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%Netherlands%'
and continent is not null
Order by 1,2

-- total cases vs population

SELECT location, date, total_cases, population, (CAST(total_cases as float)/CAST(population as float)) * 100 as PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%Netherlands%'
and continent is not null
Order by 1,2

-- countries with highest infection rates compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases as float)/CAST(population as float))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- regions with highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where location not like '%income%'
and continent is null
group by location
order by TotalDeathCount desc

-- global numbers

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
and new_deaths not like '0'
and new_cases not like '0'
group by date
Order by 1,2 desc



-- total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as Float)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
and new_vaccinations is not null
order by 2

-- cte, percentage vaccinations of total population

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, Total_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) over (Partition by dea.location Order by dea.location,
dea.date) as Total_vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and new_vaccinations is not null
)
Select *,(cast(Total_vaccinations as float)/cast(population as float)) * 100 as VaccinationPercentage
From PopvsVac

-- temptable

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vaccinations numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) over (Partition by dea.location Order by dea.location,
dea.date) as Total_vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and new_vaccinations is not null

Select *,(cast(Total_vaccinations as float)/cast(population as float)) * 100 as VaccinationPercentage
From #PercentPopulationVaccinated

-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) over (Partition by dea.location Order by dea.location,
dea.date) as Total_vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and new_vaccinations is not null

Create View TotalVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as float)) over (Partition by dea.location Order by dea.location,
dea.date) as Total_vaccinations
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and new_vaccinations is not null