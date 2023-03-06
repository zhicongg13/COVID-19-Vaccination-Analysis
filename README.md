# COVID-19-Mortality-Rate-Analysis
This project provides an analysis of COVID-19 mortality rate globally, with a focus on deaths per continent and country. The project includes interactive visualizations on Tableau, such as a map of death count per country and total deaths per continent. Additionally, the project provides insights on the estimated mortality rate for 2023-2024, allowing for future predictions on the impact of COVID-19 on mortality.

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


