/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
Order BY 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations$
--Order BY 3,4

--Select Data to be utilized

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
order by 1,2

--Observe total cases vs total deaths
--Likelihood of death from covid based on country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states'
order by 1,2

--Looking at total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 as PercentInfected 
FROM PortfolioProject..CovidDeaths$
order by 1,2

--Countries with Highest Infection Rate over population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
order by PercentPopInfected DESC

--Highest Death Count per Pop
Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCnt
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
Group by location
Order by TotalDeathCnt DESC

--Observe through continents
--continents with highest death cnt per pop
Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCnt
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
Group by continent
Order by TotalDeathCnt DESC

--Continent with Highest Infection Rate over population
Select continent, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
GROUP BY continent
order by PercentPopInfected DESC

--Global #s
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--GROUP BY date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY ded.location ORDER BY ded.location, ded.date) as PeopleVaccinatedRollingCnt
FROM PortfolioProject..CovidDeaths$ ded
Join PortfolioProject..CovidVaccinations$ vac
	ON ded.location = vac.location 
	and ded.date = vac.date
WHERE ded.continent is not null
ORDER BY 2,3

--Utilize CTE to perform calculations on Partition By from above 
WITH PopVSVac (continent, location, date, population, new_vaccinations, PeopleVaccinatedRollingCnt)
as
(
Select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY ded.location ORDER BY ded.location, ded.date) as PeopleVaccinatedRollingCnt
FROM PortfolioProject..CovidDeaths$ ded
Join PortfolioProject..CovidVaccinations$ vac
	ON ded.location = vac.location 
	and ded.date = vac.date
WHERE ded.continent is not null
)
Select *, (PeopleVaccinatedRollingCnt/population)*100 as PercentVaccinated
FROM PopVSVAC

--Use TempTable
DROP Table if exists #PercentpopVaccinated
Create Table #PercentpopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
PeopleVaccinatedRollingCnt numeric
)

Insert into #PercentpopVaccinated
Select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY ded.location ORDER BY ded.location, ded.date) as PeopleVaccinatedRollingCnt
FROM PortfolioProject..CovidDeaths$ ded
Join PortfolioProject..CovidVaccinations$ vac
	ON ded.location = vac.location 
	and ded.date = vac.date
WHERE ded.continent is not null
--ORDER BY 2,3

Select *, (PeopleVaccinatedRollingCnt/population)*100 as PercentVaccinated
FROM #PercentpopVaccinated

--Create view for ltr visualizations
Create View PercentpopVaccinated as 
Select ded.continent, ded.location, ded.date, ded.population, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY ded.location ORDER BY ded.location, ded.date) as PeopleVaccinatedRollingCnt
FROM PortfolioProject..CovidDeaths$ ded
Join PortfolioProject..CovidVaccinations$ vac
	ON ded.location = vac.location 
	and ded.date = vac.date
WHERE ded.continent is not null

Select *
FROM #PercentpopVaccinated 