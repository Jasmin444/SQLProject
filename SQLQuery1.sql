 --Select * 
--From SQLProject..CovidDeaths
--Order By 3,4

--Select * 
--From SQLProject..CovidVaccinations
--Order By 3,4

-- Selecting used dataset

--Select location,date,total_cases,new_cases,total_deaths,population
--From SQLProject..CovidDeaths
--Order by 1,2

-- See total_cases vs total_deaths 
-- Shows likelihood of dying, if you contract Covid in your country

--Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From SQLProject..CovidDeaths
--Where location like '%states%'
--Order by 1,2

-- See total_cases vs population
-- Shows what percentage of the population has gotten covid

--Select location, date, population, total_cases, (total_cases/population)*100 as AffectedPercentage
--From SQLProject..CovidDeaths
--Where location like '%states%'
--Order by 1,2

-- Shows the highest infection rate according to population

--Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as AffectedPercentage
--From SQLProject..CovidDeaths
----Where location like '%states%'
--Group by location, population
--Order by AffectedPercentage desc

-- Select Countries where the death count is the highest

--Select location, Max(cast(total_deaths as int)) as HighestDeathCount
--From SQLProject..CovidDeaths
--Where continent is not null
--Group by location
--Order by HighestDeathCount desc

-- Select highest deaths by continent

--Select location, Max(cast(total_deaths as int)) as HighestDeathCount
--From SQLProject..CovidDeaths
--Where continent is null
--Group by location
--Order by HighestDeathCount desc

-- Not correct version

Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
From SQLProject..CovidDeaths
Where continent is not null
Group by continent
Order by HighestDeathCount desc


--Global count


Select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From SQLProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group By date
Order by 1,2

--Total count

Select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From SQLProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
Order by 1,2

-- select covid vaccination excel

select *
From SQLProject..CovidVaccinations

-- join deaths and vaccination excel together

select *
From SQLProject..CovidDeaths dt
Join SQLProject..CovidVaccinations vac
On dt.location = vac.location
and dt.date = vac.date

-- total population vs vaccination

select dt.continent, dt.location, dt.date, dt.population, vac.new_vaccinations, Sum(Convert(int, new_vaccinations)) over(Partition by dt.location Order by dt.location, dt.date) as TotalVaccinatedPeople 
From SQLProject..CovidDeaths dt
Join SQLProject..CovidVaccinations vac
On dt.location = vac.location
and dt.date = vac.date
Where dt.continent is not null
Order By 2,3

--CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccination, TotalVaccinatedPeople)
As(
Select dt.continent, dt.location, dt.date, dt.population, vac.new_vaccinations, Sum(Convert(int, new_vaccinations)) over(Partition by dt.location Order by dt.location, dt.date) as TotalVaccinatedPeople 
From SQLProject..CovidDeaths dt
Join SQLProject..CovidVaccinations vac
On dt.location = vac.location
and dt.date = vac.date
Where dt.continent is not null
--Order By 2,3
)

Select *, (TotalVaccinatedPeople/Population)*100 as VaccinationPercentage
From PopvsVac

-- Temp table
Drop Table if exists #PercentagePeopleVaccinated

Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinatedPeople numeric
)

Insert Into #PercentagePeopleVaccinated
Select dt.continent, dt.location, dt.date, dt.population, vac.new_vaccinations, Sum(Convert(int, new_vaccinations)) over(Partition by dt.location Order by dt.location, dt.date) as TotalVaccinatedPeople 
From SQLProject..CovidDeaths dt
Join SQLProject..CovidVaccinations vac
On dt.location = vac.location
and dt.date = vac.date
--Where dt.continent is not null
--Order By 2,3

Select *, (TotalVaccinatedPeople/Population)*100 as VaccinationPercentage
From #PercentagePeopleVaccinated

-- View



Create View  PercentagePopulationVaccinated as
Select dt.continent, dt.location, dt.date, dt.population, vac.new_vaccinations, Sum(Convert(int, new_vaccinations)) over(Partition by dt.location Order by dt.location, dt.date) as TotalVaccinatedPeople 
From SQLProject..CovidDeaths dt
Join SQLProject..CovidVaccinations vac
On dt.location = vac.location
and dt.date = vac.date
Where dt.continent is not null
--Order By 2,3

Drop View if exists PercentagePeopleVaccinated

Select *
From PercentagePopulationVaccinated





