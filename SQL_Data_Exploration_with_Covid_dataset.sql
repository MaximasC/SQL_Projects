SELECT *
FROM covid_data.covid_death
WHERE continent IS NOT null
ORDER BY 3,4


--SELECT *
--FROM covid_data.covid_vacination
--ORDER BY 3,4


--Data that we use in this project

SELECT location, date, population,total_cases, new_cases, total_deaths
FROM covid_data.covid_death
WHERE continent IS NOT null
ORDER BY 1,2


--Looking at Total cases vs Total deaths
--Shows the likelihood of dying due to covid-19 in India

SELECT location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM covid_data.covid_death
WHERE location = 'India' AND continent IS NOT null
ORDER BY 1,2


--Looking at the total cases vs population
--Shows what percent of population got covid

SELECT location,date,total_cases, population,(total_deaths/population)*100 AS percentage_of_population_infected
FROM covid_data.covid_death
WHERE location = 'India' AND continent IS NOT null
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population,MAX(total_cases) AS highest_infection_count,MAX((total_cases/population))*100 AS percent_of_population_infected
FROM covid_data.covid_death
GROUP BY population,location
ORDER BY percent_of_population_infected DESC





--Showing the countries with highest death count

SELECT location,MAX(total_deaths) AS total_death_count
FROM covid_data.covid_death
WHERE continent IS NOT null
GROUP BY location
ORDER BY total_death_count DESC

-- Lets break down by continent

--Continents with highest death count

SELECT location,MAX(total_deaths) AS total_death_count
FROM covid_data.covid_death
WHERE continent IS NOT null
GROUP BY location
ORDER BY total_death_count DESC


--Global numbers

SELECT   date, SUM(new_cases), SUM(new_deaths),SUM(new_deaths)/SUM(new_cases) * 100 AS death_percent
FROM covid_data.covid_death
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2


--Lookinng at total population vs vacination

SELECT death.continent,death.location, death.date, death.population,vac.new_vaccinations, SUM (vac.new_vaccinations) OVER(PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_people_vaccinated, 
FROM covid_data.covid_death AS death
JOIN covid_data.covid_vacination AS vac
ON death.date = vac.date
WHERE death.continent IS NOT null
ORDER BY 2,3



--Using cte

WITH populationVSvaccination --(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT death.continent,death.location, death.date, death.population,vac.new_vaccinations, SUM (vac.new_vaccinations) OVER(PARTITION BY death.location, death.date) AS rolling_people_vaccinated
FROM covid_data.covid_death AS death
JOIN covid_data.covid_vacination AS vac
ON death.date = vac.date
WHERE death.continent IS NOT null


)

SELECT *, (rolling_people_vaccinated/population) * 100
FROM populationVSvaccination



--Temp table

DROP TABLE IF EXISTS #percentpopulationvaccinated 

CREATE TABLE #percentpopulationvaccinated (

  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rolling_people_vaccinated numeric
)

INSERT INTO
SELECT death.continent,death.location, death.date, death.population,vac.new_vaccinations, SUM (vac.new_vaccinations) OVER(PARTITION BY death.location, death.date) AS rolling_people_vaccinated
FROM covid_data.covid_death AS death
JOIN covid_data.covid_vacination AS vac
ON death.date = vac.date
WHERE death.continent IS NOT null

SELECT *,(rolling_people_vaccinated/population) * 100
FROM #percentpopulationvaccinated




--Creating view to store data for later visualizations

CREATE VIEW percentpopulationvaccinated AS
SELECT death.continent,death.location, death.date, death.population,vac.new_vaccinations, SUM (vac.new_vaccinations) OVER(PARTITION BY death.location, death.date) AS rolling_people_vaccinated
FROM covid_data.covid_death AS death
JOIN covid_data.covid_vacination AS vac
ON death.date = vac.date
WHERE death.continent IS NOT null