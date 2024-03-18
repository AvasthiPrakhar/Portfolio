--SELECT * FROM CovidDeaths$
--ORDER BY 3,4

--SELECT * FROM CovidVaccinations$
--ORDER BY 3,4

---- just taking a quick glance the database tables


---- usa death rate vs population, infection rate vs population
SELECT location,date,population , (total_deaths/population)*100 'deathPercentage'
,(total_cases/population)*100 'casePercentage'
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2
---- '%states%' is used to  obtain any <location> row which has 'states' somewhere in its name


---- total deaths and new deaths wrt location and date
select location,date,new_deaths,total_deaths from CovidDeaths$
order by 1,2


---- display max death and max infected wrt countires:
SELECT location,MAX(total_deaths/population)*100 'deathPercentage'
,MAX(total_cases/population)*100 'casePercentage'
FROM CovidDeaths$
GROUP BY location
ORDER BY 3 DESC
----first groups of locations are created using GROUP BY
---- then, max(...) functions are applied, and displayed for each group

----highest death count per country
SELECT location,MAX(cast(total_deaths AS int)) 'total deaths'
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC
---- "WHERE continent is not null" is a specific "fix" for this database
---- it was needed so that contries (and not continents which are also present in the 'location' column) are displayed


----//highest death count in world entities 
--CREATE TABLE t2_worlddeath
--(t2loaction varchar(250),
--t2deathrate int)
----// creating a temp table


--insert into t2_worlddeath
--SELECT location,MAX(cast(total_deaths AS int)) 'total deaths'
--FROM CovidDeaths$
--WHERE continent is null 
--GROUP BY location
--ORDER BY 2 DESC

----// creating another temp table
--CREATE TABLE t1_continentdeath
--(temploaction varchar(250),
--tempdeathrate int)

----highest death count per continent 
--INSERT INTO t1_continentdeath 
--SELECT continent,MAX(cast(total_deaths AS int)) 'total deaths'
--FROM CovidDeaths$
--WHERE continent is not null
--GROUP BY continent
--ORDER BY 2 DESC

select * from t1_continentdeath
select * from t2_worlddeath


----  corrected continent deaths 
----select *
select t2loaction,t2deathrate
from t1_continentdeath inner join t2_worlddeath 
on temploaction=t2loaction
---- this is again a fix applied for this database
---- if this is not performed, the incorrect no. of deaths is displayed when displaying deaths for each continent
---- two temp tables have been INNER joined so that correct number of deaths in t2 can be displayed against continents in t1


-- all global cases and deaths wrt date
select date,SUM(new_cases) "total cases" ,
SUM(cast(new_deaths as int)) "total deaths", 
(SUM(cast(new_deaths as float))/SUM(new_cases))*100 "death percent wrt cases"
from CovidDeaths$
where continent is not null
group by date
order by 1;



WITH CTE_globalCases AS (
select date,SUM(new_cases) "total cases" ,													---1
SUM(cast(new_deaths as int))"total deaths", 
(SUM(cast(new_deaths as float))/SUM(new_cases))*100  "death percent wrt cases"
from CovidDeaths$
where continent is not null
group by date
) 
SELECT SUM([total cases]) as "total global cases",											---2
	   SUM([total deaths]) as "total global deaths",
       (SUM([total deaths])/SUM([total cases]))*100 as "total death percent wrt cases "
FROM CTE_globalCases

---- we can either run the lines tagged with "---1" to obtain death percent on each day
----or run the CTE to obtain global deaths.
----alternatively, the Golbal death rate can also be obtained using the following query:

select  SUM(new_cases) "total cases" ,													
SUM(cast(new_deaths as int))"total deaths", 
(SUM(cast(new_deaths as float))/SUM(new_cases))*100  "death percent wrt cases"
from CovidDeaths$
where continent is not null




-- Query to obtain new vaccinations against location and date.
-- a 'cumulative frequency column of new vaccinations' is also derived

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location ) as 'cumulative freq'
from [Project 1 SQL DATA EXPLORATION]..CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.date = vac.date and dea.location=vac.location
where dea.continent is not null

and vac.new_vaccinations is not null
---- the above statement can be executed in order to see if cumulative freq column works as we desire 
----(that is, freq must be added as date increases per location) 

order by 2,3;

--in the "over" clause :
---- first the subclause "partition by" creates partitions,
---- the "order by" orders the elements inside each partition by the parameters "dea.date" and "dea.location"
---- the window function Sum(...) written before the "over" clause is then applied 
---- thus, the sum(...) is calculated for each partition i.e loacation 
---- and such that the condition imposed by order by is fulfilled.
---- the "order by dea.date" shouts  "sum(.) OVER this partiton AND OVER every date that is above me " at each row
---- thus all rows of "new_vaccinations" above a particular row are summed as we windows function moves forward row by row
---- this gives the 'cumulative frequency column of new vaccinations' in which freq increases with each date per locaiton



----a CTE using the above query
with CTE_popANDvac
AS (
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location ) as 'cumulative freq'
from [Project 1 SQL DATA EXPLORATION]..CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.date = vac.date and dea.location=vac.location
where dea.continent is not null
)
SELECT *,([cumulative freq]/population )*100 "cumulative vaccinations percentage"
FROM CTE_popANDvac
order by 2,3;
---- a new column  "cumulative vaccinations percentage" is derived and displayed in using the above CTE 



