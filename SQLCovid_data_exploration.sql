Select *
from PorfolioProject..CovidDeath


-- Cal the % of affected victims in Asia
SELECT location, continent, date, population, total_cases, (total_cases/population)*100 as AffectedPercentage
FROM PorfolioProject..CovidDeath
where continent = 'Asia' and total_cases IS NOT NULL
ORDER BY 3,4

--- Looking at Country with Highest infection rate compared to Population
SELECT location , population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as AffectedPercentage
FROM PorfolioProject..CovidDeath
GROUP BY location , population
ORDER BY AffectedPercentage DESC

-- Showing country with highest death count per population
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--- show the continent with the highest death count
SELECT continent, MAX (cast(total_deaths as int)) as Dead_count
FROM PorfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Dead_count DESC

-- Looking at total population and total vaccination
WITH ATC as (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
					SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PorfolioProject..CovidDeath AS dea
JOIN PorfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location and dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM ATC

--