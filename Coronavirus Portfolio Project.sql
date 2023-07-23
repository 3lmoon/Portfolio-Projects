
-- Covid_Death_Table:
Select*from [Portfolio Project #1]..['Covid Deaths']
where continent is not null
order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population_density
from [Portfolio Project #1]..['Covid Deaths']
order by 1,2


--looking at total cases vs total deaths
-- Showing the likelihood of dying from Corona
Select location, date, total_cases, total_deaths, ( (select convert (decimal, total_deaths))/(select convert (decimal, total_cases)))*100 as DeathsPercentage
from [Portfolio Project #1]..['Covid Deaths']
where location like '%states%'
order by 1,2

-- Countries with the highest Total Deaths:

Select location, Max(cast(total_deaths as int)) as Total_Death_Count
from [Portfolio Project #1]..['Covid Deaths']
--The where line to remove the locations which are not countries such as continets and econmic classess
where continent is not null
Group by location
order by Total_Death_Count Desc

-- Now By Continent, Region and Global:
Select location, Max(cast(total_deaths as int)) as Total_Death_Count
from [Portfolio Project #1]..['Covid Deaths']
--The where line to remove the locations which are econmic classess
where continent is null and location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location 
order by Total_Death_Count Desc




-- By Economic Class:

Select location as Class, Max(cast(total_deaths as int)) as Total_Death_Count
from [Portfolio Project #1]..['Covid Deaths']
--The where line to remove all the locations but econmic classess
where continent is null AND location NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe', 'Oceania', 'World', 'European Union')
Group by location
order by Total_Death_Count Desc


-- Global Numbers:
-- By Date:
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathsPercentage
from [Portfolio Project #1]..['Covid Deaths']
where continent is not null
group by date
order by 1,2


-- Cummulative global DeathPercentage:
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathsPercentage
-- nullif() function is used to avoid the division by 0
from [Portfolio Project #1]..['Covid Deaths']
where continent is not null
order by 1,2




-- Covid_Vaccinations_Table:

-- Vaccinations Vs Population:

Select v.continent, v.location, v.date, v.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) 
over (Partition by v.location order by d.location, d.date) as cummulative_vaccinations
-- bigint is used instead of int to solve the "Arithmetic overflow error converting expression to data type int"
From [Portfolio Project #1]..['Covid Vaccinations'] v
join [Portfolio Project #1]..['Covid Deaths'] d
  on v.location=d.location
   and v.date=d.date
   where d.continent is not null
   order by 2,3
  
  
-- Percenatege of vaccinated population:

-- Using CTE:
 with  Percenatege_of_vaccinated_population (contitnent, location, date, population, new_vaccinations, cummulative_vaccinations)
 as
 (
  Select v.continent, v.location, v.date, v.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) 
over (Partition by v.location order by d.location, d.date) as cummulative_vaccinations
-- bigint is used instead of int to solve the "Arithmetic overflow error converting expression to data type int"
From [Portfolio Project #1]..['Covid Vaccinations'] v
join [Portfolio Project #1]..['Covid Deaths'] d
  on v.location=d.location
   and v.date=d.date
   where d.continent is not null
   --order by 2,3
   )
   select *, (cummulative_vaccinations/population)*100 as vaccination_percentage
   From Percenatege_of_vaccinated_population



   --  Temp Table:
Drop table #PercentPopulationVaccinated 


Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
nv numeric,
cummulative_vaccinations numeric
)
--new_vaccinations name kept giving me error, so that I had to change to nv to solve it--

Insert into #PercentPopulationVaccinated (continent, location, date, population, nv, cummulative_vaccinations)
    Select v.continent, v.location, v.date, v.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) 
over (Partition by v.location order by d.location, d.date) as cummulative_vaccinations
-- bigint is used instead of int to solve the "Arithmetic overflow error converting expression to data type int"
From [Portfolio Project #1]..['Covid Vaccinations'] v
join [Portfolio Project #1]..['Covid Deaths'] d
  on v.location=d.location
   and v.date=d.date
   where v.continent is not null
   --order by 2,3
   
   select *, (cummulative_vaccinations/population)*100 as vaccination_percnatage
   From #PercentPopulationVaccinated




-- Creating Views for Visuals:
USE [Portfolio Project #1]
GO
create view PercentPopulationVaccinated as
Select v.continent, v.location, v.date, v.population, v.new_vaccinations, sum(cast(v.new_vaccinations as bigint)) 
over (Partition by v.location order by d.location, d.date) as cummulative_vaccinations
-- bigint is used instead of int to solve the "Arithmetic overflow error converting expression to data type int"
From [Portfolio Project #1]..['Covid Vaccinations'] v
join [Portfolio Project #1]..['Covid Deaths'] d
  on v.location=d.location
   and v.date=d.date
   where d.continent is not null
   --order by 2,3


   select* 
   from PercentPopulationVaccinated