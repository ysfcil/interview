WITH MedianValues AS (
    SELECT
        country,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY daily_vaccinations) OVER (PARTITION BY country) AS median_daily_vaccinations
    FROM
        daily_vaccination_count
    WHERE
        daily_vaccinations IS NOT NULL
),
FilledData AS (
    SELECT
        d.date,
        d.country,
        COALESCE(d.daily_vaccinations, m.median_daily_vaccinations, 0) AS daily_vaccinations
    FROM
        daily_vaccination_count d
    LEFT JOIN
        MedianValues m ON d.country = m.country
)
UPDATE
    daily_vaccination_count d
SET
    daily_vaccinations = f.daily_vaccinations
FROM
    FilledData f
WHERE
    d.date = f.date
    AND d.country = f.country
    AND d.daily_vaccinations IS NULL;