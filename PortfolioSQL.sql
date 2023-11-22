---- General Data
---- For Countries with:
----		Highest Cases -				    Order By 3 
----		Highest Deaths -			    Order By 4
----		Highest Cases per Population -  Order By 5
----		Highest Deaths per Population - Order By 6
----		Highest Deaths per Cases -		Order By 7

SELECT Location, population as Population, MAX(total_cases) as Cases, MAX(total_deaths) as Deaths,
ROUND(MAX(total_cases) / Population * 100, 2) as InfectionPercentage,
ROUND(MAX(cast(Total_deaths as int)) / Population * 100, 2) as DeathPercentage,
ROUND(MAX(cast(Total_deaths as int)) / MAX(total_cases) * 100, 2) as Lethality
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY 3 DESC


---- Continents Data

SELECT location, MAX(total_cases) as Cases, MAX(total_deaths) as Deaths
FROM PortfolioProject..CovidDeaths
where continent is NULL
GROUP BY location


---- Countries with Highest Cases in their Continent

SELECT
    cd.continent AS Continent,
    cd.location AS Country,
    cd.population AS Population,
    cd.total_cases AS Cases,
    cd.total_deaths AS Deaths
FROM
    PortfolioProject..CovidDeaths cd
JOIN (
    SELECT
        continent,
        MAX(total_cases) AS Cases
    FROM
        PortfolioProject..CovidDeaths
    WHERE
        continent IS NOT NULL
    GROUP BY
        continent
) max_cases
ON
    cd.continent = max_cases.continent
    AND cd.total_cases = max_cases.Cases;


---- Top 3 Countries with Highest Infection Rate in their Continents

SELECT
    cd.continent AS Continent,
    cd.location AS Country,
	ROUND(cd.cases / cd.population * 100, 2) as InfectedPercent			 -- For Infection Rate
--	ROUND(cd.deaths / cd.population * 100, 2) as DeathPercent			 -- For Death Rate
--  cd.population AS Population, cd.cases AS Cases, cd.deaths AS Deaths  -- For General Data
FROM(
	SELECT A.continent, A.location, A.population, MAX(A.total_cases) as cases, MAX(A.total_deaths) as deaths, 
    DENSE_RANK() OVER ( 
        PARTITION BY A.continent
		ORDER BY MAX(A.total_cases) / A.population DESC ) AS R
--      ORDER BY MAX(A.total_cases) DESC ) AS R
    FROM PortfolioProject..CovidDeaths A
	WHERE A.Continent IS NOT NULL
	GROUP BY A.continent, A.location, A.population
) cd WHERE cd.R <= 3
order by cd.continent, InfectedPercent DESC