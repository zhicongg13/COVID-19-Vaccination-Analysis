-- 1. Partially vaccinated in Asia
-- 2. Fully vaccinated in Asia
-- 3. People not vaccinated in percentage (Asia)
-- 4. People not vaccinated in percentage (country)
-- 5. Population vs partially vaccinated (country)
-- 6. Population vs partially vaccinated (country)
-- 7. Population VS vaccinated in countries 
-- 8. Comparing vaccination with GDP, HDI and death rates
-- 9. Total cases VS death rate percentage by each day in Asia

USE Project_COVID;
SELECT * FROM covid_deaths;
SELECT * FROM covid_vaccinations;

-- 1. Partially vaccinated in Asia
SELECT SUM(partially_vacc) AS total_partially_vacc FROM (
  SELECT MAX(people_vaccinated) AS partially_vacc FROM covid_vaccinations
  GROUP BY location
) AS t;

-- 2. Fully vaccinated in Asia
SELECT SUM(fully_vacc) AS total_fully_vacc FROM (
  SELECT MAX(people_fully_vaccinated) AS fully_vacc FROM covid_vaccinations
  GROUP BY location
) AS t;

-- 3. People not vaccinated in percentage (Asia)
SELECT SUM(max_population) AS total_population
FROM (
    SELECT location, MAX(population) AS max_population
    FROM covid_deaths
    GROUP BY location
) AS t;

SELECT SUM(max_partially_vacc) AS total_partially_vacc
FROM (
	SELECT location, MAX(people_vaccinated) AS max_partially_vacc
	FROM covid_vaccinations
	GROUP BY location
) AS t;

SELECT total_population - total_partially_vacc AS total_not_vaccinated,
       ((total_population - total_partially_vacc) / total_population * 100) AS percent_not_vaccinated
FROM (
    SELECT SUM(max_population) AS total_population
    FROM (
        SELECT location, MAX(population) AS max_population
        FROM covid_deaths
        GROUP BY location
    ) AS t
) AS t1
CROSS JOIN (
    SELECT SUM(max_partially_vacc) AS total_partially_vacc
    FROM (
        SELECT location, MAX(people_vaccinated) AS max_partially_vacc
        FROM covid_vaccinations
        GROUP BY location
    ) AS t
) AS t2;

-- 4. People not vaccinated in percentage (Country)
SELECT location, MAX(population) AS population
FROM covid_deaths
GROUP BY location;

SELECT location, MAX(people_vaccinated) AS partially_vacc
FROM covid_vaccinations
GROUP BY location;

CREATE INDEX location_idx ON covid_deaths (location(255));
CREATE INDEX location_idx ON covid_vaccinations (location(255));

SELECT d.location, ((MAX(d.population) - MAX(v.people_vaccinated)) / MAX(d.population) * 100) AS percent_not_vaccinated
FROM covid_deaths AS d
LEFT JOIN covid_vaccinations AS v ON d.location = v.location
GROUP BY d.location;

-- 5. Population vs partially vaccinated (Country)
SELECT deaths.location, deaths.population, vaccinations.partially_vaccinated, 
(vaccinations.partially_vaccinated / deaths.population * 100) AS percent_vaccinated
FROM (
    SELECT location, MAX(population) AS population
    FROM covid_deaths
    GROUP BY location
) AS deaths
JOIN (
    SELECT location, MAX(people_vaccinated) AS partially_vaccinated
    FROM covid_vaccinations
    GROUP BY location
) AS vaccinations
ON deaths.location = vaccinations.location;

-- 6. Population vs partially vaccinated (Country)
SELECT deaths.location, deaths.population, vaccinations.fully_vaccinated, 
(vaccinations.fully_vaccinated / deaths.population * 100) AS percent_vaccinated
FROM (
    SELECT location, MAX(population) AS population
    FROM covid_deaths
    GROUP BY location
) AS deaths
JOIN (
    SELECT location, MAX(people_fully_vaccinated) AS fully_vaccinated
    FROM covid_vaccinations
    GROUP BY location
) AS vaccinations
ON deaths.location = vaccinations.location;

-- 7. Population VS vaccinated in countries 
CREATE INDEX idx_location_date ON covid_vaccinations (location(255), date(10));
CREATE INDEX idx_location_date ON covid_deaths (location(255), date(10));

SELECT vacc.location, death.population, 
MAX(vacc.people_vaccinated) AS partially_vaccinated,
MAX(vacc.people_fully_vaccinated) AS fully_vaccinated
FROM covid_vaccinations AS vacc
INNER JOIN covid_deaths AS death
ON death.location = vacc.location
-- WHERE vacc.location IN ('Singapore')
GROUP BY vacc.location, death.population
ORDER BY vacc.location ASC; 

-- 8. Comparing vaccination with GDP, HDI and death rates
DROP TEMPORARY TABLE IF EXISTS Temp_Vaccinated_Population;
CREATE TEMPORARY TABLE Temp_Vaccinated_Population
(
location CHAR(255) CHARACTER SET UTF8MB4, 
population BIGINT,
Partially_Vaccinated INT, 
Fully_Vaccinated INT, 
gdp_per_capita DECIMAL(15,3),
human_development_index DECIMAL(15,3)
);

INSERT INTO Temp_Vaccinated_Population
SELECT vacc.location, death.population, 
MAX(vacc.people_vaccinated) AS Partially_Vaccinated,
MAX(vacc.people_fully_vaccinated) AS Fully_Vaccinated, 
MAX(vacc.gdp_per_capita) AS gdp_per_capita, 
MAX(vacc.human_development_index) AS human_development_index
FROM covid_vaccinations AS vacc
INNER JOIN covid_deaths AS death
ON death.location = vacc.location
GROUP BY vacc.location, death.population
ORDER BY vacc.location ASC;

SELECT *, 
ROUND((Partially_Vaccinated / population)*100, 0) AS Partially_Vaccinated_Percent,
ROUND((Fully_Vaccinated / population)*100, 0) AS Fully_Vaccinated_Percent
FROM Temp_Vaccinated_Population
ORDER BY location ASC;

-- 9. Total cases VS death rate percentage by each day in Asia
SELECT STR_TO_DATE(date, '%d/%m/%y') AS formatted_date, 
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
(SUM(new_deaths)/SUM(New_Cases))*100 as DeathPercentage
FROM covid_deaths
GROUP BY formatted_date
HAVING total_cases > 0 AND total_deaths > 0
ORDER BY formatted_date DESC;






