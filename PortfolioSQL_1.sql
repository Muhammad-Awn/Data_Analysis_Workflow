----------------- Only Turkey and China Total New Cases and Max Cases do not match

SELECT location, MAX(total_cases) as Cases, SUM(new_cases) as TotalCases,
MAX(total_deaths) as Deaths
FROM PortfolioProject..CovidDeaths
where continent is not NULL
GROUP BY location
HAVING MAX(total_cases) - SUM(new_cases) > 10


------------------ Joining and EDA Both Tables

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations))
		OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From 
	PortfolioProject..CovidDeaths dea
Join 
	PortfolioProject..CovidVaccinations vac
On 
	dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null 
order by 2,3


-------------------- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinated)
AS
(
	SELECT 
		dea.continent, dea.location,
		dea.date, dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations))
			OVER (
				PARTITION BY dea.Location
				ORDER BY dea.location, dea.Date
				) AS Total_Vaccinated
	FROM PortfolioProject..CovidDeaths dea
		Join PortfolioProject..CovidVaccinations vac
			On dea.location = vac.location
			AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL 
)


SELECT *, ROUND((Total_Vaccinated/Population)*100, 2) AS VaccinationPercent
FROM PopvsVac
WHERE New_Vaccinations IS NOT NULL
ORDER BY Location, Date