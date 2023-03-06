-- COVID Mortality Rate 
-- 1. Total global cases and mortality rate
-- 2. Mortality Rate in each continent
-- 3. Total cases VS total deaths per day
-- 4. Global Cases and death percentage by each day
-- 5. Countries with the highest mortality rate

USE Portfolio_project_covid;
SELECT * FROM covid_deaths;
SELECT * FROM covid_vaccinations;

-- 1. Total global cases and mortality rate
SELECT SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM Covid_deaths
WHERE continent != '0';

-- 2. Mortality Rate in each continent
SELECT continent, SUM(new_deaths) AS TotalDeathCount
FROM Covid_Deaths
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 3. Total cases VS total deaths per day
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS Death_Rate_Percent
FROM Covid_Deaths
WHERE continent != '0';

-- 4. Global Cases and death percentage by each day
SELECT date, SUM(new_cases) as total_cases,
SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(New_Cases))*100 as DeathPercentage
FROM covid_deaths
WHERE continent != '0' 
GROUP BY date
HAVING total_cases > 0 AND total_deaths > 0
ORDER BY date DESC;

-- 5. Countries with the highest mortality rate 
SELECT location, population, MAX(total_deaths) AS total_deaths, 
MAX(total_deaths / population)*100 AS total_deaths_percentage
FROM covid_deaths
WHERE continent != '0'
GROUP BY location, population
ORDER BY total_deaths_percentage DESC;



-- Addtional exploratory queries

-- Countries with the Highest Infection Rate Percentage
SELECT location, population, MAX(total_cases) AS Covid_cases, 
MAX(total_cases / population)*100 AS Covid_Population_Percent
FROM Covid_Deaths
WHERE continent != '0' 
GROUP BY location, population
ORDER BY Covid_Population_Percent DESC;

-- Fully Vaccinated VS Partially Vaccination
SELECT location, date, 
MAX(people_vaccinated) AS Partially_Vaccinated,
MAX(people_fully_vaccinated) AS Fully_Vaccinated
FROM covid_vaccinations
WHERE continent != '0' 
GROUP BY location, date
ORDER BY location ASC;

-- Fully Vaccinated VS Partially Vaccination in Different Countries
SELECT vacc.location, death.population, 
MAX(vacc.people_vaccinated) AS Partially_Vaccinated,
MAX(vacc.people_fully_vaccinated) AS Fully_Vaccinated
FROM covid_vaccinations AS vacc
INNER JOIN covid_deaths AS death
ON death.location = vacc.location
WHERE vacc.continent != '0' AND vacc.location IN ('Singapore', 'United States')
GROUP BY vacc.location, death.population
ORDER BY vacc.location ASC; 

-- Using Temp Table to perform Percentage Calculation based on previous query
DROP TEMPORARY TABLE IF EXISTS Temp_Vaccinated_Population;
CREATE TEMPORARY TABLE Temp_Vaccinated_Population
(
location nvarchar(255), 
population BIGINT,
Partially_Vaccinated BIGINT, 
Fully_Vaccinated BIGINT
);

INSERT INTO Temp_Vaccinated_Population
SELECT vacc.location, death.population, 
MAX(vacc.people_vaccinated) AS Partially_Vaccinated,
MAX(vacc.people_fully_vaccinated) AS Fully_Vaccinated
FROM covid_vaccinations AS vacc
INNER JOIN covid_deaths AS death
ON death.location = vacc.location
WHERE vacc.continent != '0' AND vacc.location IN ('Singapore', 'United States')
GROUP BY vacc.location, death.population
ORDER BY vacc.location ASC;  

SELECT *, 
ROUND((Partially_Vaccinated / population)*100, 0) AS Partially_Vaccinated_Percent,
ROUND((Fully_Vaccinated / population)*100, 0) AS Fully_Vaccinated_Percent
FROM Temp_Vaccinated_Population;
