-- Eda Using Sql

-- heal -> tail -> sample
-- for numerical cols
-- 		-- 8 number summary[count, min, max, mean, std, q1, q2, q3]
-- 		-- missing values
--		-- outliers values
--		-- horizontal/ vertical histogram 

-- For categorical cols
--		-- values count -> pie charts
--		-- missing values

-- Numerical - Numericals
--		-- side by side 8 number analysis
-- 		-- scatterplot
-- 		-- correlation

-- categorical- categorical
--		-- contigency table -> stack bar chart

-- Numerical - categorical 
-- 		compare distributation across categories

-- Missing values treatments

-- Features engineering 
	-- ppi
    -- price_bracket

-- Not hot encoding

select * from laptopdata;

-- Data Inspection (Head, Tail, Sample)
select * from laptopdata
order by `id` limit 5;

select * from laptopdata
order by `id` desc limit 5;

select * from laptopdata
order by rand() limit 5;

-- Numerical Univariate Analysis
select count(Price) Over(), 
Min(Price) Over(), 
Max(price) Over(),
Avg(Price) Over(), 
STD(Price) Over(),
Percentile_cont(0.25) within group(order by Price) over() as 'Q1',
Percentile_cont(0.5) within group(order by Price) over() as 'Q2',
Percentile_cont(0.75) within group(order by Price) over() as 'Q3'
from laptopdata
order by 'id' limit 1;

-- Check NULL Values
select count(Price)
from laptopdata
where Price is null;


-- Outlier Detection (Price < Q1 - 1.5*IQR OR Price > Q3 + 1.5*IQR)
SELECT * FROM (
    SELECT *,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY Price) OVER() AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY Price) OVER() AS Q3
    FROM laptopdata
) t
WHERE t.Price < t.Q1 - (1.5 * (t.Q3 - t.Q1)) 
   OR t.Price > t.Q3 + (1.5 * (t.Q3 - t.Q1));
   
-- Distribution Analysis
SELECT 
    SUM(CASE WHEN Price BETWEEN 0 AND 25000 THEN 1 ELSE 0 END) AS '[0-25K]',
    SUM(CASE WHEN Price BETWEEN 25001 AND 50000 THEN 1 ELSE 0 END) AS '[25K-50K]',
    SUM(CASE WHEN Price BETWEEN 50001 AND 75000 THEN 1 ELSE 0 END) AS '[50K-75K]',
    SUM(CASE WHEN Price > 75000 THEN 1 ELSE 0 END) AS '[75K_Plus]'
FROM laptopdata;

SELECT 
    CASE 
        WHEN Price <= 25000 THEN '0-25K'
        WHEN Price <= 50000 THEN '25K-50K'
        WHEN Price <= 75000 THEN '50K-75K'
        ELSE '75K+' 
    END AS Price_Range,
    COUNT(*) AS Total_Count,
    REPEAT('*', COUNT(*)/25) AS Histogram 
FROM laptopdata
GROUP BY Price_Range
ORDER BY MIN(Price);

-- Categorical Analysis
SELECT Company, COUNT(Company) AS 'Count'
FROM laptopdata
group by Company;

-- Feature Engineering
SELECT Cpu_speed, Price FROM laptopdata;

SELECT Cpu_speed, Price,
    ROUND((COUNT(*) * SUM(Cpu_speed * Price) - SUM(Cpu_speed) * SUM(Price)) / 
    (SQRT(
        (COUNT(*) * SUM(Cpu_speed * Cpu_speed) - POW(SUM(Cpu_speed), 2)) * (COUNT(*) * SUM(Price * Price) - POW(SUM(Price), 2))
    )) * 100, 2) AS Correlation_Coefficient
FROM laptopdata;

-- Bivariate Analysis (Categorical-Categorical)
SELECT Company, 
    SUM(CASE WHEN Touch_screen = 1 THEN 1 ELSE 0 END) AS Touchscreen_YES,
    SUM(CASE WHEN Touch_screen = 0 THEN 1 ELSE 0 END) AS Touchscreen_NO
FROM laptopdata
GROUP BY Company;

SELECT * FROM laptopdata;


SELECT Company, 
    SUM(CASE WHEN Cpu_brand = 'Intel' THEN 1 ELSE 0 END) AS Intel,
    SUM(CASE WHEN Cpu_brand = 'AMD' THEN 1 ELSE 0 END) AS AMD,
    SUM(CASE WHEN Cpu_brand = 'Samsung' THEN 1 ELSE 0 END) AS Samsung
    
FROM laptopdata
GROUP BY Company;


SELECT 
    id, 
    Company, 
    ROUND(SQRT(POW(Resolution_width, 2) + POW(Resolution_hight, 2)) / Inches, 2) AS ppi
FROM laptopdata;


SELECT 
    id, 
    Company, 
    Price,
    CASE 
        WHEN Price < 35000 THEN 'Budget'
        WHEN Price BETWEEN 35000 AND 70000 THEN 'Mid-Range'
        WHEN Price BETWEEN 70001 AND 120000 THEN 'Premium'
        ELSE 'High-End/Workstation'
    END AS price_bracket
FROM laptopdata;


SELECT 
    id, 
    Company, 
    TypeName,
    -- Engineered PPI
    ROUND(SQRT(POW(Resolution_width, 2) + POW(Resolution_hight, 2)) / Inches, 2) AS ppi,
    -- Engineered Price Bracket
    CASE 
        WHEN Price < 35000 THEN 'Budget'
        WHEN Price BETWEEN 35000 AND 75000 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_bracket,
    -- Engineered Weight Class
    CASE 
        WHEN Weight < 1.5 THEN 'Ultra-Portable'
        WHEN Weight BETWEEN 1.5 AND 2.5 THEN 'Standard'
        ELSE 'Heavy'
    END AS portability
FROM laptopdata;

SELECT 
    Company,
    ROUND(AVG(SQRT(POW(Resolution_width, 2) + POW(Resolution_hight, 2)) / Inches), 2) AS Avg_PPI
FROM laptopdata
WHERE Price BETWEEN 35000 AND 75000
GROUP BY Company
ORDER BY Avg_PPI DESC;
