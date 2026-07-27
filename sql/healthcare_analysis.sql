-- ============================================================
-- Healthcare Data Engineering Pipeline
-- Amazon Athena Analytical Queries
-- ============================================================


-- 1. Average healthcare expenditure by country

SELECT
    country,
    AVG(exp) AS avg_health_exp
FROM health_gdp
GROUP BY country;


-- 2. Countries with health insurance coverage below 20%

SELECT
    country,
    year,
    cov
FROM insurance
WHERE cov < 20
  AND cov IS NOT NULL;


-- 3. Countries where insurance coverage decreased
-- between 1910 and 1975

SELECT
    country,
    cov_1910,
    cov_1975,
    cov_1975 - cov_1910 AS coverage_change
FROM (
    SELECT
        country,
        MAX(CASE WHEN year = 1910 THEN cov END) AS cov_1910,
        MAX(CASE WHEN year = 1975 THEN cov END) AS cov_1975
    FROM insurance
    GROUP BY country
) subquery
WHERE cov_1975 < cov_1910;


-- 4. Top 3 regions with the lowest healthcare expenditure

SELECT
    Entity AS region,
    year,
    exp
FROM health_exp
WHERE code IS NULL
ORDER BY exp ASC
LIMIT 3;


-- 5. Year-over-year percentage change in healthcare expenditure

SELECT
    Entity AS region,
    year,
    exp,
    (
        exp - LAG(exp, 1) OVER (
            PARTITION BY Entity
            ORDER BY year
        )
    )
    / LAG(exp, 1) OVER (
        PARTITION BY Entity
        ORDER BY year
    ) * 100 AS percentage_change
FROM health_exp
WHERE code IS NULL
ORDER BY Entity, year;


-- 6. Years with highest and lowest percentage
-- of people without health insurance

(
    SELECT
        year,
        without_ins
    FROM no_ins
    ORDER BY without_ins DESC
    LIMIT 1
)

UNION ALL

(
    SELECT
        year,
        without_ins
    FROM no_ins
    ORDER BY without_ins ASC
    LIMIT 1
);
