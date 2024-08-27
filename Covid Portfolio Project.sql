Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null  and location  not like '%world%'
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--Select data we are using
Select Location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2

--Looking at the total cases vs total deaths
--shows the likelihood of dying from covid 
Select Location,date,total_cases,total_deaths,(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%India%'
and continent is not null
order by 1,2

--Looking at the total cases vs population
Select Location,date,population ,total_cases,(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
--WHERE location like '%India%'
order by 1,2

--Looking at Countries with highest infection rate compared to population
Select Location,population ,MAX(total_cases) as HighestInfectionCount ,Max(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
--WHERE location like '%India%'
Group by Location,Population
order by PercentPopulationInfected desc





--Showing the country's with highest death count per population 
Select Location ,Max(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null and location  not like '%world%'
Group By Location
Order by TotalDeathCount desc


--Lets break things by continent

Select continent ,sum(cast( new_deaths as bigint))
From PortfolioProject.dbo.CovidDeaths
Where continent !=''
Group By continent

--Showing the continents with highest death count
Select Continent,Max(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
Group By Continent
Order by TotalDeathCount desc


---Vaccinations data extraction
--Looking at total people vs vaccination

Select dea.continent,dea.location,dea.date,CONVERT(BIGINT, dea.population) AS population, CONVERT(BIGINT, vac.new_vaccinations) AS new_vaccinations,SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by  dea.location Order by dea.location,dea.date ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations  vac
           On dea.location=vac.location
           and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE to perform Calculation on Partition By in previous query
;With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, CONVERT(BIGINT, dea.population) AS population, CAST(vac.new_vaccinations AS bigint)
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, CASE 
           WHEN Population > 0 THEN (CAST(RollingPeopleVaccinated AS bigint) * 100.0 / CAST(Population AS bigint))
           ELSE NULL
       END AS VaccinationPercentage
From PopvsVac;





--TEMP TABLE 
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, TRY_CONVERT(DATETIME, dea.date) , CONVERT(BIGINT, dea.population) AS population, CAST(vac.new_vaccinations AS bigint)
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE TRY_CONVERT(DATETIME, dea.date) IS NOT NULL;  -- Filter out invalid dates
--where dea.continent is not null 
--order by 2,3

Select *, CASE 
           WHEN Population > 0 THEN (CAST(RollingPeopleVaccinated AS bigint) * 100.0 / CAST(Population AS bigint))
           ELSE NULL
       END AS VaccinationPercentage
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated;
GO
CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, TRY_CONVERT(DATETIME, dea.date) AS ConvertedDate , CONVERT(BIGINT, dea.population) AS population, CAST(vac.new_vaccinations AS bigint) AS new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE TRY_CONVERT(DATETIME, dea.date) IS NOT NULL 
and dea.continent is not null
--order by 2,3;


Go
Select *
From PercentPopulationVaccinated;