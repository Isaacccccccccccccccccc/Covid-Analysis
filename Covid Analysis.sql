-- Trim Table

Set SQL_SAFE_UPDATES = 0;

Update PortfolioProject.coviddeaths
Set date = DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%Y'), '%Y-%m-%d')
Where date like '%/%';

Alter table PortfolioProject.coviddeaths
Modify column date DATE;

Update PortfolioProject.covidvaccinations
Set date = DATE_FORMAT(STR_TO_DATE(date, '%m/%d/%Y'), '%Y-%m-%d')
Where date like '%/%';

Alter table PortfolioProject.covidvaccinations
Modify column date DATE;

Set SQL_SAFE_UPDATES = 1;

Select * from PortfolioProject.coviddeaths 
Where Trim(continent) <> ''
Order by 3, 4;

Select location, date, total_cases, new_cases, total_deaths, population from PortfolioProject.coviddeaths
Where Trim(continent) <> ''
Order by 1, 2;


-- Looking at Total Cases vs Total Deaths

Select 
location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage 
from PortfolioProject.coviddeaths 
Where location like '%States%'
Order by 1, 2; 


-- Looking at Total Cases vs Population

Select 
location, date, total_cases, population, (total_cases/population)*100 death_percentage 
from PortfolioProject.coviddeaths 
Where location like '%States%'
Order by 1, 2;


-- Looking at Countries with Highest Infection Rate Compared to Population

Select 
location, population, Max(total_cases) highest_infection_count, Max((total_cases/population)*100) percentage_population_infected 
from PortfolioProject.coviddeaths 
-- Where location like '%States%'
Where Trim(continent) <> ''
Group by location, population
Order by 4 desc;


-- showing Countries with Highest Death Rate Count per Population

Select 
location, Max(Cast(total_deaths as unsigned)) highest_death_count 
from PortfolioProject.coviddeaths 
-- Where location like '%States%'
Where Trim(continent) <> ''
Group by location
Order by 2 desc;


-- By Continent

Select 
location, Max(Cast(total_deaths as unsigned)) highest_death_count 
from PortfolioProject.coviddeaths 
-- Where location like '%States%'
Where Trim(continent) = ''
Group by location
Order by 2 desc;


-- Global Numbers

Select 
date, Sum(new_cases) as global_cases, Sum(Cast(new_deaths as unsigned)) as global_deaths, Sum(Cast(new_deaths as unsigned))/Sum(new_cases)*100 as global_death_percentage
from PortfolioProject.coviddeaths 
Where Trim(continent) <> ''
Group by date
Order by 1;

Select * from PortfolioProject.covidvaccinations;


-- Looking at Total Population vs Vaccinations
-- Use CTE

With PopvsVac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations as unsigned)) over (Partition by dea.location Order by dea.date) as rolling_people_vaccinated 
-- (rolling_people_vaccinated/population)*100 
from PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent <> ''
)
Select *, (rolling_people_vaccinated/population)*100 as rolling_vaccinated_percentage from PopvsVac;


-- Different Way by Using Temp Table

Drop table if exists PercentPeopleVaccinated;
Create Temporary Table PercentPeopleVaccinated
(
continent varchar(225),
location varchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

Insert into PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, Cast(Nullif(Trim(vac.new_vaccinations), '') as unsigned), 
Sum(Cast(Nullif(Trim(vac.new_vaccinations), '') as unsigned))  over (Partition by dea.location Order by dea.date) as rolling_people_vaccinated 
-- (rolling_people_vaccinated/population)*100 
from PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location and dea.date = vac.date
-- Where dea.continent <> ''
;

Select *, (rolling_people_vaccinated/population)*100 as rolling_vaccinated_percentage from PercentPeopleVaccinated;


-- Create View for Visualization

Create View PortfolioProject.PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, Cast(Nullif(Trim(vac.new_vaccinations), '') as unsigned), 
Sum(Cast(Nullif(Trim(vac.new_vaccinations), '') as unsigned))  over (Partition by dea.location Order by dea.date) as rolling_people_vaccinated 
-- (rolling_people_vaccinated/population)*100 
from PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	on dea.location = vac.location and dea.date = vac.date
Where dea.continent <> '';

Select * from PortfolioProject.percentpeoplevaccinated;

