select * from Covid_project..Covid_Deaths


--==================selecting the data only Cases and Deaths==================

select location,DATE,total_cases,new_cases,total_deaths,population from Covid_project..Covid_Deaths
order by 1,2

--========================Looking at Total case vs total Deaths===================

select location,date,total_cases,total_deaths,(total_cases/total_deaths)*100 as Death_Percentage  from Covid_project..Covid_Deaths
order by 1,2

---=======================Total cases VS Population====================================
---================looking the what percentage of covid got  population in the Location-" India"====

select location,date,total_cases,total_deaths,population,(total_cases/population)*100 as Death_Percentage  from Covid_project..Covid_Deaths
where location in ('india')
order by 1,2


------Looking at the countries with highest infection rate compared to population=====

select location,population,MAX(total_cases)as HighestInfected,max((total_cases/population))*100 as 'Percentage_Population_infected' from covid_project..covid_deaths
group by location,population
order by Percentage_Population_infected desc


--===========How many people died in their country=========
--========Based on their countries total no of deaths and population in their respective countries============

select location,population,sum(total_deaths) as Total_No_of_Deaths_Countries from Covid_project..Covid_Deaths
group by location,population
having SUM(total_deaths) is not null
order by Total_No_of_Deaths_Countries desc



--Look into Country wise how many deaths======
select continent,population,SUM(total_deaths) as No_Of_TotalDeaths from Covid_project..Covid_Deaths
where continent is not null
group by continent,population
order by continent


select * from Covid_project..Covid_Deaths

---================showing continents with the highest death count per population=============

 select continent,MAX(total_deaths) as Highest_Deaths from Covid_project..Covid_Deaths
 where continent is not null
 group by continent
 having MAX(total_deaths) is not null
 order by continent,Highest_Deaths desc


 --============Global Numbers===============

 select date,SUM(cast(new_cases as int)) as Total_Cases,SUM(new_deaths) as Total_Deaths,(sum(total_deaths)/sum(total_cases))*100 as Per
 from Covid_project..Covid_Deaths
 where continent is not null or new_cases is not null or new_deaths is not null
 group by date
 order by 1,2 

 --==============Total Population VS Vaccinations===================

 select Deaths.continent,Deaths.location,Deaths.date,deaths.population,Vaccination.new_vaccinations from covid_project..Covid_Vaccination Vaccination join Covid_project..Covid_Deaths Deaths
  on Vaccination.location = Deaths.location and Vaccination.date = Deaths.date
where Deaths.continent	 = 'Asia' and new_vaccinations is not null
order by 1,2,3

--==============looking total population and total New vaccination of respective location on corona_Deaths dates====================

 select Deaths.continent,Deaths.location,Deaths.date,sum(cast(deaths.population as int))as Total_Population ,sum(cast(Vaccination.new_vaccinations AS int)) as Total_New_Vaccination from covid_project..Covid_Vaccination Vaccination join Covid_project..Covid_Deaths Deaths
  on Vaccination.location = Deaths.location and Vaccination.date = Deaths.date
where Deaths.continent	in ('Asia','europe') and new_vaccinations is not null
group by Deaths.continent,Deaths.location,Deaths.date
order by 1,2,5 

--============ Use CTE 

with popuVSVac (continet,location,date,population,new_vaccinations,rolling_people_vaccinationed)
as (
select dea.continent,dea.location,dea.date,dea.population,Vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as Rolling_People_vaccinationed -- use partition by and based on death location did orderby location & date 
from covid_project..Covid_Vaccination as Vac  join Covid_project..Covid_Deaths as dea
  on Vac.location = dea.location and Vac.date = dea.date
where vac.new_vaccinations is not null
--order by 1,2,3========= in the CTE we can't excute the order by function=====

)

select *,(rolling_people_vaccinationed/population)*100
from popuVSVac



--==========Use the Temp table

Drop table if exists #population_Vaccinated
create table #population_Vaccinated
( Continent varchar(255),Location varchar(255),Date datetime,Population int,New_Vaccinations int , Rolling_People_vaccinationed int)

insert into #population_vaccinated

select dea.continent,dea.location,dea.date,dea.population,Vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint )) over(partition by dea.location order by dea.location,dea.date) as Rolling_People_vaccinationed -- use partition by and based on death location did orderby location & date 
from covid_project..Covid_Vaccination as Vac  join Covid_project..Covid_Deaths as dea
  on Vac.location = dea.location and Vac.date = dea.date
where vac.new_vaccinations is not null
--order by 1,2,3========= in the CTE we can't excute the order by function=====

select *,(rolling_people_vaccinationed/population)*100
from #population_vaccinated

--====Create an view table 

create view PopulationVaccinated as

select dea.continent,dea.location,dea.date,dea.population,Vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS bigint )) over(partition by dea.location order by dea.location,dea.date) as Rolling_People_vaccinationed -- use partition by and based on death location did orderby location & date 
from covid_project..Covid_Vaccination as Vac  join Covid_project..Covid_Deaths as dea
  on Vac.location = dea.location and Vac.date = dea.date
where vac.new_vaccinations is not null

