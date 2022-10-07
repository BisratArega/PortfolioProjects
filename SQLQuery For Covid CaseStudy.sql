
-- Checking to make sure all the data was imported Properly 

Select * From [dbo].[CovidDeaths] 
	Order by 3,4

	/* 
-- This Query Is'nt being used, Just kept around incase it's needed to copy for Later 

Select * From [dbo].[CovidVaccinations]
	Order by 3,4
	*/

-- Had to Alter Table columns into INT becasue couldn't run query for calculation with Varchar datatype. 
-- Data came in from FlatFile Import so data Type isn't on cosistant fromat, Used the Alter function to fix!!


ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN Continent Nvarchar(50)


/* 
-- This Query Had had Failed Because **Error converting data type varchar to numeric** 

ALTER TABLE [dbo].[CovidDeaths]
ALTER COLUMN [new_cases_smoothed] DECIMAL(22, 0)

-- *** The Solution for this issue is CASTING OR CONVERTING the Varchar(Column) into a Decimal(12,2) in Query!!*****
--- Be mindful that When CASTING OR CONVERTING will require to Use SUBQUERY OR CTE becasue it can't reference on the same query. 				
*/



-- Useing to Select Data that I want to use for the anylisis & view them!!  

Select Location, Date, total_cases, new_cases, total_deaths, population
	From[dbo].[CovidDeaths]
	Order by 1,2

-- Looking at the Total Cases vs Total Deathes

/*
-- When running the Calculation to find the Percentage It kept throwing up Errors 
-- **** SQL divide by Zero error Message ****

SET ARITHABORT OFF --> The batch will terminate and returns a null value 
SET ANSI_WARNINGS OFF -->  Helps to avoid the error message

This was the Solution I found for the Error 

I also Figured out That YOU CAN USE CAST & CONVERT WITHIN SUBQURIES TO CREATE THE CALCULATION ***WORKS VERY WELL***

*/ 

SET ARITHABORT OFF
SET ANSI_WARNINGS OFF


-- The Calculation to see the what's the Percentage of Dying if Infected 

Select sub.Location, sub.Date, sub.total_cases, sub.total_deaths, (sub.total_deaths/sub.total_cases)*100 as DeathPercentage   
	From(Select Location, Date , total_cases, cast(total_deaths as decimal(12,2)) as Total_deaths     
	From [dbo].[CovidDeaths] 
		) SUB




-- Showing countries with the Highest Death Count in Population 

Select Continent, Location, Max(Total_deaths) as HighestDeathCount
	From [dbo].[CovidDeaths]
-- Where Location Like '%states% <- Refers to the column 
Where Continent is not null 
Group by Continent, Location
Order by HighestDeathCount desc

*****-------------------------------------------------------------******
--*****Tring to remove all the Columns that don't have Values!!*****

Select Continent, Location, max(Total_deaths) as HighestDeathCount
	From [dbo].[CovidDeaths]
-- Where Location Like '%states% <- Refers to the column 
Where Continent is null OR Continent = ' ' 
Group by Continent, Location  
Order by HighestDeathCount desc



-- Looking at the total Cases vs Population 
-- Shows what percentage of population got covid 

Select sub.Location, sub.date, sub.Population,(sub.total_cases/sub.population)*100 as PercentPopulationInfected
	From (Select Location, date, Population ,
	   cast(total_cases as decimal(12,2)) as Total_cases
	   From PortfolioProject..CovidDeaths) Sub
-- Where location like '%states%'
-- order by 1,2



-- Looking at Countries with highest infection rate comapred to population ******* 

Select sub.Location, sub.Population, Max(sub.Total_cases) as HighestInfectionCount,
	   Max((sub.total_cases/sub.population))*100 as PercentPopulationInfected
			From (select Location, Population, cast(Total_cases as decimal(12,2)) as total_cases
			From [dbo].[CovidDeaths]) Sub
Group by location, Population 
Order by percentpopulationinfected desc


-- Countries with the Highest Death Count Per Population

Select Location, Max(Total_Deaths) as TotalDeathCount
	From [dbo].[CovidDeaths]
	Where Continent is not null
Group by location
Order by TotalDeathCount desc

--* The "Where" CONTINENT IS NOT NULL statment removes any rows from the location that were givin CONTINET Names 
-- because they locations that were compiled togther 



-- Showing the Contenent With the Highest Death Count Per Population Continents 

Select Continent, Max(Total_Deaths) as TotalDeathCount
	From [dbo].[CovidDeaths]
	Where Continent is not null
Group by Continent
Order by TotalDeathCount desc





-- **Visualizing a Data like this would be done on a MAP** 
-- So always keep that inmind! When wokring on Queries because 
/*
-- When we take the Data set we create for the extraction Continent Colummn Is very Important to Look at Globel numbers!!
-- WE CAN DO AS MUCH AS WE WANT BY JUST ADDING THE CONTINENT Column ON THE GROUP BY CLAUSE!!
-- THIS IS VERY IMPORTANT IF WE WANT THE DRILL DOWN EFFECT ON OUR Visual!!
*/

Select Continent, Max(Total_Deaths) as TotalDeathCount
	From [dbo].[CovidDeaths]
	Where Continent is not null
Group by Continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS 
-- Calculating Everyting accross from the Entire world!!

Select sub.date, sub.total_cases, sub.population, (sub.total_cases/sub.population)*100 as PercentPopulationInfected
 from (Select date, Population,
	   cast(total_cases as decimal(12,2)) as Total_cases
	   From PortfolioProject..CovidDeaths) Sub


-- Showing us the SUM of New Cases across the World Each Day!!

Select date, Sum(new_cases) NewCases
	From [dbo].[CovidDeaths]
	where Continent is not null
	Group by date
	order by 1,2

--*******************************************************


SET ARITHABORT OFF
SET ANSI_WARNINGS OFF

Select sub.date, Sum(sub.new_cases) TotalNewCases, Sum(sub.new_deaths) TotalNewDeaths,
		(sum(sub.new_deaths)/Sum(sub.New_cases))*100 as DeathPercentage
	From ( Select date, new_cases, cast(new_deaths as decimal(12,2)) as new_deaths 
			From [dbo].[CovidDeaths] where Continent is not null) Sub 
	Group by date 
	order by Deathpercentage desc


-- ***JOING TWO TABLES!!***************************************************************
-- WE'RE GOING TO START USING OUT COVIDVACCINATION TABLE ALONG WITH OUR COVIDEATHS TABLE 
-- ************************************************************************************

-- Just to View our table to start picking the columns that we'll be using

Select * From  [dbo].[CovidVaccinations]


-- For this CaseStudy we decieded to Join the entire tables together ON Two things (LOCATION, DATE) 

Select * 
	from [dbo].[CovidDeaths] CD
	Join [dbo].[CovidVaccinations] CVC
		on CD.Location = CVC.Location
		and CD.date = CVC.date


-- Looking at Total Population that are Vaccinated by Location by date

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
	from [dbo].[CovidDeaths] CD
	Join [dbo].[CovidVaccinations] CV
		on CD.Location = CV.Location
		and CD.date = CV.date
	where cd.continent is not null
	order by cv.new_vaccinations desc
	--Order by 2,3

-- ****DOing a ROLLING COUNT On a New COLUMN**** Using Partition******************************************************** 

-- ***AS the column CV.Vaccinations keeps increasing the ROLLING COUNT Will Have a row thats ADDED UP ON a New COLUMN*** 
-- **The Total Amount that'll desplay Is Determind by what we Partision On** 
-- **For this case it was the Location so It showed the total amount for that Location on every single row!!**  
-- ** SO WHAT IT DID WAS IT CREATED THE SUM OF ALL THE NEW_VACCINATIONS By That Location and created new Column!!**  
-- *

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
		,Sum(cast(cv.new_vaccinations as int)) over -- You can also use Convert(INT, CV.New_vac)
		(Partition by cd.Location order by cd.location, cd.date) as RollingVaccinatedCount 
	from [dbo].[CovidDeaths] CD
	Join [dbo].[CovidVaccinations] CV
		on CD.Location = CV.Location
		and CD.date = CV.date
	where cd.continent is not null
	--order by cv.new_vaccinations desc
	Order by 2,3


-- Looking at Total Population vs Vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
		,Sum(cast(cv.new_vaccinations as bigint)) over 
		(Partition by cd.Location order by cd.location, cd.date) as RollingVaccinatedCount
		--(RollingVaccinatedCount/Population) 
	from [dbo].[CovidDeaths] CD
	Join [dbo].[CovidVaccinations] CV
		on CD.Location = CV.Location
		and CD.date = CV.date
	where cd.continent is not null
	--order by cv.new_vaccinations desc
	Order by 2,3




-- ***** Using a CTE ******
-- Kinda like Subqureies for the Calculation to take place


--Shows Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (continent, Location, date, Population,New_vaccinations, RollingVaccinatedCount)
	as 
	(
Select  cd.continent, cd.location, cd.date, cast(cd.population as decimal(18,2)) as Population, cv.new_vaccinations
		,Sum(cast(cv.new_vaccinations as bigint)) over 
		(Partition by cd.Location order by cd.location, cd.date) as RollingVaccinatedCount
		--(RollingVaccinatedCount/Population) 
	from [dbo].[CovidDeaths] CD
	Join [dbo].[CovidVaccinations] CV
		on CD.Location = CV.Location
		and CD.date = CV.date
	where cd.continent is not null
	--order by cv.new_vaccinations desc
	)
Select *, (RollingVaccinatedCount/population)*100 as VaccinatedPopulationPercentage 
From PopvsVac

-- ***** Using a Temprary Table*******************************************

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
	(	
	Continent nvarchar(60),
	Location nvarchar(60),
	Date Datetime, 
	Population Numeric,
	New_vaccinations numeric,
	RollingVaccinatedCount Nvarchar(60)
	)


Insert Into #PercentPopulationVaccinated
	Select  cd.continent, cd.location, cd.date, cast(cd.population as decimal(18,2)) as Population, 
			cast(cv.new_vaccinations as int) as New_vaccinations
		,Sum(cast(cv.new_vaccinations as int)) over 
		(Partition by cd.Location order by cd.location, cd.date) as RollingVaccinatedCount
		--(RollingVaccinatedCount/Population) 
	from [dbo].[CovidDeaths] CD
	Join [dbo].[CovidVaccinations] CV
		on CD.Location = CV.Location
		and CD.date = CV.date
	where cd.continent is not null
	--order by PercentPopulationVaccinated desc

Select *, (RollingVaccinatedCount/population)*100 as PercentPopulationVaccinated 
From #PercentPopulationVaccinated
--order by Continent desc




-- ***** Using Sub Query *****
-- This was my very own atempt at doing this. Figure out where the query is bad. 
Select * from CovidVaccinations
/*
Select Sub.cd.Continent, Sub.cd.Location, Sub.cd.Date, Sub.cd.Population, Sub.cv.new_vaccinations, 
		(sub.RollingVaccinatedCount/sub.cd.Population)*100 as TotalPeopleVaccinated 
	From (cd.continent , cd.location , cd.date , cv.new_vaccinations
			cast(cd.population as decimal(18,2)) as cd.population, 
		,Sum(cast(cv.new_vaccinations as int)) over 
		(Partition by cd.Location order by cd.location, cd.date) as RollingVaccinatedCount
	from [dbo].[CovidDeaths] CD
	Join [dbo].[CovidVaccinations] CV
		on CD.Location = CV.Location
		and CD.date = CV.date
	where continent is not null) Sub
	--order by cv.new_vaccinations desc
	Order by 2,3
*/



--********************CREATING VIEWS TO STOr

Select * from CovidDeaths

--********************CREATING VIEWS TO STORE DATA SET FOR VISUALIZATIONS************************ 
--********************CREATING VIEWS TO STORE DATA SET FOR VISUALIZATIONS************************
--********************CREATING VIEWS TO STORE DATA SET FOR VISUALIZATIONS************************

-- Creating a View of a data set to store 

-- GLOBAL NUMBERS 
-- Calculating Everyting accross from the Entire world!!

SET ARITHABORT OFF
SET ANSI_WARNINGS OFF
-- Use incase Error About Divide by Zero is encounterd

Select sub.date as MonthDate, max(sub.total_cases) as Total_cases,Sum(sub.population) as Population, 
		(sub.total_cases/sub.population)*100 as PercentPopulationInfected
  from (Select date, Population,
	     cast(total_cases as decimal(12,2)) as Total_cases
	      From PortfolioProject..CovidDeaths) Sub
	where Year(Date) = '2021'
	Group by Date, Population, Total_cases
	order by date asc


Select sub.date as MonthDate, sum(sub.total_cases) as Total_cases,Sum(sub.population) as Population, 
		(sub.total_cases/sub.population)*100 as PercentPopulationInfected
  from (Select date, Population,
	     cast(total_cases as decimal(12,2)) as Total_cases
	      From PortfolioProject..CovidDeaths) Sub
	Where year(Date) = '2022'  --and date = '2021'
	Group by Date, Population,Total_cases
	order by date asc

--*******------********-------
--Creating View  
-- Looking at Countries with highest infection rate comapred to population ******* 

Select sub.Location, sub.Population, Max(sub.Total_cases) as HighestInfectionCount,
	   Max((sub.total_cases/sub.population))*100 as PercentPopulationInfected
  From (select Location, Population, cast(Total_cases as decimal(12,2)) as total_cases
		From [dbo].[CovidDeaths]) Sub
	Group by location, Population 
	 Order by percentpopulationinfected desc

--*******------********-------
-- The Calculation to see the what's the Percentage of Dying if Infected 

Select sub.Location as Location, sub.Date as Date, sub.total_cases, sub.total_deaths, 
	   (sub.total_deaths/sub.total_cases)*100 as DeathPercentage   
	 From(Select Location, Date , total_cases, cast(total_deaths as decimal(12,2)) as Total_deaths     
		  From [dbo].[CovidDeaths] 
		) SUB
	     Order by Date asc

--*******------********-------

-- Looking at the total Cases vs Population 
-- Shows what percentage of population got covid 

--**** FOr year 2020

Select sub.Location as Location, sub.date as Date, sum(sub.Population) as Population,
		(sub.total_cases/sub.population)*100 as PercentPopulationInfected
      From (Select Location, date, Population,
		     cast(total_cases as decimal(12,2)) as Total_cases
		       From [dbo].[CovidDeaths]) Sub
		Where Year(date)  = '2020'
		 Group by Location, Date, population, Sub.total_cases 
		  order by date asc

--*** FOr YEAR 2021

Select sub.Location as Location, sub.date as Date, sum(sub.Population) as Population,
		(sub.total_cases/sub.population)*100 as PercentPopulationInfected
      From (Select Location, date, Population,
		     cast(total_cases as decimal(12,2)) as Total_cases
		       From [dbo].[CovidDeaths]) Sub
		Where Year(date)  = '2021'
		 Group by Location, Date, population, Sub.total_cases 
		  order by date asc

--*******------********------- 

-- Showing the Contenent With the Highest Death Count Per Population Continents 

Select Sub.Continent, Max(Sub.Total_Deaths) as TotalDeathCount
	From (Select nullif(Continent,'') Continent, Total_Deaths
		 From [dbo].[CovidDeaths]) SUB
		Where Continent is not null
		 Group by Continent
		  Order by TotalDeathCount desc

-- Showing the Countries With the Highest Death Count Per Population Continents 

Select Sub.Location, Max(Sub.Total_Deaths) as TotalDeathCount
	From (Select nullif(Continent,'') Continent, Location, Total_Deaths
		 From [dbo].[CovidDeaths]) SUB
	   Where Continent is not null
	    Group by Continent, Location
		 Order by TotalDeathCount desc


--********------*******------

-- Looking at Total Population that are Vaccinated by date & Location 


Select Sub.Continent, Sub.Location, Sub.Date, Sub.Population, Sub.NewVaccinations 
	From (Select nullif(cd.continent, '') as continent, cd.location as Location, 
		  cd.date as Date, cd.population as Population, cv.new_vaccinations as NewVaccinations
		From [dbo].[CovidDeaths] CD
			Join [dbo].[CovidVaccinations] CV
			 on CD.Location = CV.Location
			  and CD.date = CV.date) SUB
		where sub.continent is not null
		 order by date Asc
		 
	--Order by 2,3

--********------*******------

--Shows Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (continent, Location, date, Population,New_vaccinations, RollingVaccinatedCount)
	as 
	(
Select  cd.continent, cd.location, cd.date, cast(cd.population as decimal(18,2)) as Population, cv.new_vaccinations
		,Sum(cast(cv.new_vaccinations as bigint)) over 
		(Partition by cd.Location order by cd.location, cd.date) as RollingVaccinatedCount
		--(RollingVaccinatedCount/Population) 
	from [dbo].[CovidDeaths] CD
	Join [dbo].[CovidVaccinations] CV
		on CD.Location = CV.Location
		and CD.date = CV.date
	where cd.continent is not null
	--order by cv.new_vaccinations desc
	)
Select *, (RollingVaccinatedCount/population)*100 as VaccinatedPopulationPercentage 
From PopvsVac


--********------*******------

----Using the View To Dispaly VACCINACTION COUNT FOR YEAR 2021/2022 

Drop View RollingPopulationVaccinated

Create View RollingPopulationVaccinated as 
	Select CD.continent, CD.location, CD.date, cast(CD.population as decimal(18,2)) as Population, CV.new_vaccinations,
			Sum(cast(CV.new_vaccinations as bigint)) over 
			(Partition by CD.Location order by CD.location, CD.date) as RollingVaccinatedCount
		from [dbo].[CovidDeaths] CD
		  Join [dbo].[CovidVaccinations] CV
			on CD.Location = CV.Location
			 and CD.date = CV.date
			  where cd.continent is not null
		--order by cv.new_vaccinations desc

--- Using the View To Dispaly VACCINACTION COUNT FOR YEAR 2021/2022 

--**For Year 2021**
Select Nullif([continent], '') Continent,Location ,Year(date) as Date, 
		Sum([Population]) as SumPopulation,Max([RollingVaccinatedCount]) as RollingVacc
	From RollingPopulationVaccinated 
	 Where Year(Date) = '2021'   
	  group by Continent,Location, [Population], Date
	   Order By RollingVacc Desc

--**For Year 2022**
Select Nullif([continent], '') Continent,Location ,Year(date) as Date, 
		Sum([Population]) as SumPopulation,Max([RollingVaccinatedCount]) as RollingVacc
	From RollingPopulationVaccinated 
	 Where Year(Date) = '2022'   
	  group by Continent,Location, [Population], Date
	   Order By RollingVacc Desc


-- Create a View For This 





-- Create a View For This 



-- Create a View For This 

-- Create a View For This 

-- Create a View For This 

















































