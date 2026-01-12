-- 1.

Select 
Sum(new_cases) as global_cases, Sum(Cast(new_deaths as signed)) as global_deaths, Sum(Cast(new_deaths as signed))/Sum(new_cases)*100 as global_death_percentage
from PortfolioProject.coviddeaths 
Where Trim(continent) <> ''
Order by 1;


-- 2.

Select 
location, Sum(Cast(new_deaths as signed)) as total_deaths
from PortfolioProject.coviddeaths 
Where Trim(continent) = '' 
	and location not in ('World', 'International')
    and location not like 'European%'
    and location not like '%income%'
Group by location
Order by total_deaths desc;


-- 3.

Select 
location, population, Max(total_cases) highest_infection_count, Max((total_cases/population)*100) percentage_population_infected 
from PortfolioProject.coviddeaths 
Where Trim(continent) <> ''
Group by location, population
Order by 4 desc;


-- 4.

SELECT
  location, population, date,
  MAX(total_cases) AS highest_infection_count,
  MAX((total_cases/population)*100) AS percentage_population_infected
FROM PortfolioProject.coviddeaths
WHERE TRIM(continent) <> ''
GROUP BY location, population, date
Order by 1, 5 desc;
