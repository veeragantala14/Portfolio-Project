select *
from CovidDeaths
where continent is not null
order by 3,4


---select Data that we are going to be using 

select Location,date,total_cases, new_cases, total_deaths, population
population from CovidDeaths
order by 1,2


--- looking at total cases vs total deaths 
----- shows likehood of dying if you cntract covid in your country 
select Location,date,total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage from CovidDeaths
where location like '%Albania%'
order by 1,2

---looking at total cases vs population
------shows what percentage of population got covid

select Location,date,total_cases,population, (total_cases/population ) * 100 as Percentpopulationinfected  from CovidDeaths
order by 1,2



---looking at countries with highest infection rate compared to population 

select location, population, max (total_cases) as highestInfectioncount,  max((total_cases/population))*100 as Percentpopulationinfected
from CovidDeaths
where continent is not null
group by location,population 
order by Percentpopulationinfected desc


--- showing countries with highest death count per population 

select location, max (Total_deaths) as Totaldeathcount
from CovidDeaths
where continent is not null
group by location 
order by Totaldeathcount desc


--- lets brake things down by continent

---showing continents with the highest death count per population 

select continent, max (cast (Total_deaths as int ) )as Totaldeathcount
from CovidDeaths
where continent is not null
group by continent 
order by Totaldeathcount desc

---global numbers

select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum (new_cases) *100 as dearthpercentage---- total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
from CovidDeaths
----where location like '%Albania%'
where continent is not null
group by date
order by 1,2 


select rollingpeoplevaccinated from CovidVaccinations 

---Looking at total population vs vaccinations 

 with popvsvac  (continent,location,date,population, new_vaccinations,rollingpeoplevaccinated )
 as 
(select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 sum (cast (vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location,dea.date) as rollingpeoplevaccinated
 from CovidDeaths  dea
join CovidVaccinations  vac
     on dea.location = vac.location 
     and dea.date = vac.date 

where dea.continent is not null 

----order by 1,2,3

)

select * , (rollingpeoplevaccinated/ population)*100
from popvsvac 


---temp tabel 


DROP Table if exists percentpopulationvaccinated ;
Create Table percentpopulationvaccinated 
(
Continent VARCHAR (255),
Location VARCHAR (255),
Date Timestamp,
Population numeric,
new_vaccinations numeric,
RollingPeoplevaccinated numeric
);

insert into percentpopulationvaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 sum (cast (vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location,dea.date) as rollingpeoplevaccinated
 from CovidDeaths  dea
join CovidVaccinations  vac
     on dea.location = vac.location 
     and dea.date = vac.date;

-----where dea.continent is not null 

----order by 1,2,3

select * , (rollingpeoplevaccinated/nullif(population,0))*100.0
from percentpopulationvaccinated;

DROP Table if exists percentpopulationvaccinated;
CREATE VIEW percentpopulationvaccinated AS

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
 sum (cast (vac.new_vaccinations as int)) over (Partition by dea.Location order by dea.location,dea.date) as rollingpeoplevaccinated
 from CovidDeaths  dea
join CovidVaccinations  vac
     on dea.location = vac.location 
     and dea.date = vac.date
where dea.continent is not null ;
----order by 1,2,3

