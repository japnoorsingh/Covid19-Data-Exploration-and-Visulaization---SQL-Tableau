/*
COVID-19 DATA EXPLORATION
*/


Select *
From data_analysis..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data

Select Location, date, total_cases, new_cases, total_deaths, population
From data_analysis..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths (Likelihood of dying if you contract covid in your country)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From data_analysis..CovidDeaths
-- Where location like '%india%'
order by 1,2


-- Total Cases vs Population (Percentage of population infected with Covid)

Select Location, date, Population, total_cases,  (total_cases/population)*100 as Population_infected_percentage
From data_analysis..CovidDeaths
--Where location like '%india%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From data_analysis..CovidDeaths
-- Where location like '%india%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From data_analysis..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From data_analysis..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Global cases and deaths

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From data_analysis..CovidDeaths
where continent is not null 
order by 1,2


-- Vaccinations Table

Select *
From data_analysis..CovidVaccinations
-- where continent is not null


-- Joining tables

--Select *
--From data_analysis..CovidDeaths dea
--Join data_analysis..CovidVaccinations vac
--on dea.location = vac.location
--and dea.date = vac.date


-- Total Population vs Vaccinations (Population that has recieved at least one Covid Vaccine)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From data_analysis..CovidDeaths dea
Join data_analysis..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
-- and dea.location like '%india%'
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From data_analysis..CovidDeaths dea
Join data_analysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
From data_analysis..CovidDeaths dea
Join data_analysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated