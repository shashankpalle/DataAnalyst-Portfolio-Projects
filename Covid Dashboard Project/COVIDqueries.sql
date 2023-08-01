Select *
From PorfolioProject1 ..CovidDeaths
order by 3,4

--COUNTRY NUMBERS

-- Looking at Total Cases vs Deaths 
-- Shows likelihood of dying if you contract covid in each country

Select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) As DeathPercentage
From PorfolioProject1..CovidDeaths
Where continent is not null 
Order By 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population infected by covid

Select location, date, total_cases, population, ((total_cases/population)*100) As InfectedPercentage
From PorfolioProject1..CovidDeaths
Where continent is not null 
Order By 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) As PercentagePopulationInfected
From PorfolioProject1..CovidDeaths
Where continent is not null 
Group By location,population 
Order By PercentagePopulationInfected desc

--Looking at countries with highest infection rate compared to population

Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) As PercentagePopulationInfected
From PorfolioProject1..CovidDeaths
Where continent is not null 
Group By location,population,date
Order By PercentagePopulationInfected desc

--Looking at highest death count for countries

Select location, MAX(CAST(total_deaths as int)) As TotalDeathCount
From PorfolioProject1..CovidDeaths
Where continent is not null 
Group By location 
Order By TotalDeathCount desc

--Looking at death count per population for countries
--Shows countries which have tackled covid situation effectively

Select location, population, MAX(total_deaths) as HighestdeathCount, MAX((total_deaths/population)*100) As PercentagePopulationDeaths
From PorfolioProject1..CovidDeaths
Where total_deaths is not null AND continent is not null AND population is not null
Group By location,population 
Order By PercentagePopulationDeaths asc

--CONTINENT NUMBERS

--Looking at highest death count for continents
Select continent, MAX(CAST(total_deaths as int)) As TotalDeathCount
From PorfolioProject1..CovidDeaths
Where continent is not null 
Group By continent 
Order By TotalDeathCount desc

--GLOBAL NUMBERS

-- Looking at Total Cases vs Deaths 
-- Show Total Number of Deaths, Cases and Percentage of Deaths globally.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PorfolioProject1..CovidDeaths
Where continent is not null


-- Using CTE to perform Calculation on Partition By in previous query
-- Shows Rolling Rate of Vaccination for each Country at each Date

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProject1..CovidDeaths dea
Join PorfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProject1..CovidDeaths dea
Join PorfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PorfolioProject1..CovidDeaths dea
Join PorfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null



Select *
From PercentPopulationVaccinated