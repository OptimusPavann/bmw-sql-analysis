-- Finding the total rows in the dataset

SELECT COUNT(*) AS total_rows FROM bmw_sales

-- Alternative query to find total rows there is no performance issue slightly negligible
SELECT COUNT(1) AS total_rows FROM bmw_sales 

-- Column Profile
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'bmw_sales'

-- Data inspection
SELECT TOP 10 * FROM bmw_sales

--FINDING NULL VALUES 
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN model IS NULL THEN 1 ELSE 0 END) AS null_models,
    SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS null_year,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN color IS NULL THEN 1 ELSE 0 END) AS null_color,
    SUM(CASE WHEN fuel_type IS NULL THEN 1 ELSE 0 END) AS null_fuel_type,
    SUM(CASE WHEN transmission IS NULL THEN 1 ELSE 0 END) AS null_transmission,
    SUM(CASE WHEN engine_size_l IS NULL THEN 1 ELSE 0 END) AS null_engine_size_l,
    SUM(CASE WHEN mileage_km IS NULL THEN 1 ELSE 0 END) AS null_mileage_km,
    SUM(CASE WHEN price_usd IS NULL THEN 1 ELSE 0 END) AS null_price_usd,
    SUM(CASE WHEN sales_volume IS NULL THEN 1 ELSE 0 END) AS null_sales_volume,
    SUM(CASE WHEN sales_classification IS NULL THEN 1 ELSE 0 END) AS null_sales_classification
FROM bmw_sales;
-- Alternative version
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(model) AS null_models,
    COUNT(*) - COUNT(year) AS null_year
FROM bmw_sales;

--To find the null percentage 
SELECT 
	SUM(CASE WHEN model IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS model_null_pct
	--do it for all the columns 
FROM bmw_sales


/* finding blank and empty spaces and i didn't apply null values on number fields because i does not allow string values */
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN TRIM(model) = '' THEN 1 ELSE 0 END) AS blank_models,
    SUM(CASE WHEN TRIM(color) = '' THEN 1 ELSE 0 END) AS blank_color,
    SUM(CASE WHEN TRIM(fuel_type) = '' THEN 1 ELSE 0 END) AS blank_fuel_type,
    SUM(CASE WHEN TRIM(transmission) = '' THEN 1 ELSE 0 END) AS blank_transmission,
    SUM(CASE WHEN TRIM(sales_classification) = '' THEN 1 ELSE 0 END) AS blank_sales_classification
FROM bmw_sales;

-- Even better version
SELECT 
	SUM(CASE 
		WHEN model IS NULL OR TRIM(model) = '' 
		THEN 1 ELSE 0 
	END) AS invalid_model
FROM bmw_sales

/* Finding duplicate values (as there is no any primary key i would prefere full type match) */
SELECT 
	model,
	year,
	region,
	color,
	fuel_type,
	transmission,
	engine_size_l,
	mileage_km,
	price_usd,
	sales_volume,
	sales_classification,
	COUNT(*) duplicates
FROM bmw_sales
GROUP BY
	model,
	year,
	region,
	color,
	fuel_type,
	transmission,
	engine_size_l,
	mileage_km,
	price_usd,
	sales_volume,
	sales_classification
HAVING COUNT(*) > 1
-- Alternative way to find the duplicates using window functions

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY
                   model,
                   year,
                   region,
                   color,
                   fuel_type,
                   transmission,
                   engine_size_l,
                   mileage_km,
                   price_usd,
                   sales_volume,
                   sales_classification
               ORDER BY model
           ) AS rn
    FROM bmw_sales
) t
WHERE rn > 1;


-- As there are no any null/empty values and duplicates there are no any handlings

--Data distribution on categorical columns so that i can understand data inconsistency, uneven data and spelling mistakes ect..

SELECT DISTINCT model FROM bmw_sales ORDER BY model
SELECT DISTINCT year FROM bmw_sales ORDER BY year
SELECT DISTINCT region FROM bmw_sales ORDER BY region
SELECT DISTINCT color FROM bmw_sales ORDER BY color
SELECT DISTINCT fuel_type FROM bmw_sales ORDER BY fuel_type
SELECT DISTINCT transmission FROM bmw_sales ORDER BY transmission
SELECT DISTINCT sales_classification FROM bmw_sales ORDER BY sales_classification

-- Outliners for the bmw_sales_data
SELECT
	MIN(year) old_date,
	MAX(year) latest_date
FROM bmw_sales

SELECT 
	MIN(engine_size_l) min_engine_size_l,
	MAX(engine_size_l) max_engine_size_l
FROM bmw_sales
SELECT 
	MIN(mileage_km) min_mileage,
	MAX(mileage_km) max_mileage
FROM bmw_sales

SELECT 
	MIN(price_usd) min_price_usd,
	MAX(price_usd) max_price_usd
FROM bmw_sales

SELECT 
	MIN(sales_volume) min_sales_volume,
	MAX(sales_volume) max_sales_volume
FROM bmw_sales

/* 1. How many total records exist in the dataset? */
SELECT 
	COUNT(*) AS total_recods
FROM bmw_sales

/* 2. What are the distinct BMW models Available*/
SELECT DISTINCT model FROM bmw_sales  
-- (GROUP BY without any aggregation method will give same result)
SELECT 
	 model
FROM bmw_sales
GROUP BY model
SELECT 
	model,
	COUNT(*) AS total_records,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model

/* 3. How Many unique regions are present in the dataset? */

SELECT DISTINCT region FROM bmw_sales

/* 4. What are the different transmission types are available*/

SELECT DISTINCT transmission FROM bmw_sales

/* 5. How mmany vehicles are there for each fuel type?*/

SELECT 
	fuel_type,
	SUM(sales_volume) AS total_vehicles
FROM bmw_sales
GROUP BY fuel_type

/* 6. What is the minimum and maximum vehicle price*/

SELECT
	MIN(price_usd) AS min_price,
	MAX(price_usd) AS max_price
FROM bmw_sales

/* 7. What is the average engine size of vehicles */

SELECT
	ROUND(AVG(engine_size_l),2) AS avg_engine_size
FROM bmw_sales

/* 8. What is the average mileage of vehicles */

SELECT
	AVG(CAST(mileage_km AS BIGINT)) AS avg_mileage
FROM bmw_sales

/* 9. How many vehicles are sold in each sales classification(High/Low)*/

SELECT
	sales_classification,
	SUM(sales_volume) AS total_sales
FROM bmw_sales
GROUP BY sales_classification

/* 10. How many cars wer produced each year*/

SELECT
	year,
	SUM(sales_volume) AS total_cars_produced
FROM bmw_sales
GROUP BY year
ORDER BY year 

/* 11. What is the total sales volume for all BMW vehicles? */

SELECT
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales

/* 12. What is the average price of vehicles per model? */

SELECT
	model,
	AVG(price_usd) AS avg_model_price
FROM bmw_sales
GROUP BY model

/* 13. Which region has the highest sales volume? */
SELECT TOP 1
	region,
	SUM(sales_volume) AS highest_sales_volume
FROM bmw_sales
GROUP BY region
ORDER BY highest_sales_volume DESC

/*14. What is the total sales volume per region? */

SELECT 
	region,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY region

/*15. What is the average mileage per model? */

SELECT
	model,
	AVG(mileage_km) AS model_avg_mileage
FROM bmw_sales
GROUP BY model

/* 16. Which model has the highest average price? */

SELECT TOP 1
	model,
	AVG(price_usd) AS avg_price
FROM bmw_sales
GROUP BY model
ORDER BY avg_price DESC

/* 17. What is the average engine size per fuel type? */

SELECT 
	fuel_type,
	ROUND(AVG(engine_size_l),2) AS avg_engine_size
FROM bmw_sales
GROUP BY fuel_type

/* 18.  Which year recorded the highest sales volume? */

SELECT TOP 1 
	year,
	SUM(sales_volume) AS sales_volume
FROM bmw_sales
GROUP BY year
ORDER BY sales_volume DESC

/* 19. What is the total number of vehicles sold per transmission type? */

SELECT
	transmission,
	SUM(sales_volume) AS total_sales
FROM bmw_sales
GROUP BY transmission

/* 20. Which color appears most frequently in the dataset? */

SELECT TOP 1
	color,
	COUNT(*) AS color_most
FROM bmw_sales
GROUP BY color
ORDER BY color_most DESC

/* 21. Which models have average price greater than $70,000? */

SELECT 
	model,
	AVG(price_usd) AS avg_price
FROM bmw_sales
GROUP BY model
HAVING AVG(price_usd) > 70000

/* 22. Which regions have total sales volume greater than 50,000? */

SELECT
	region,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY region
HAVING SUM(sales_volume) > 50000

/* 23. Which models sold more than 20,000 units? */

SELECT 
	model,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model
HAVING SUM(sales_volume) > 20000

/* 24. Find models with average mileage greater than 80,000 km. */

SELECT
	model,
	AVG(mileage_km) AS model_avg_mileage
FROM bmw_sales
GROUP BY model
HAVING AVG(mileage_km) > 80000

/* 25. Which years have average price greater than overall average price? */

SELECT
	year,
	AVG(price_usd) AS avg_year_price
FROM bmw_sales
GROUP BY year
HAVING AVG(price_usd) > (SELECT AVG(CAST(price_usd AS BIGINT)) FROM bmw_sales)

/* 26. Find fuel types that appear more than 5,000 times. */

SELECT
	fuel_type,
	COUNT(*) AS total_count
FROM bmw_sales
GROUP BY fuel_type
HAVING COUNT(*) > 5000

/* 27. Which models have engine size greater than 3L on average? */

SELECT 
	model,
	AVG(engine_size_l) AS avg_engine
FROM bmw_sales
GROUP BY model
HAVING AVG(engine_size_l) > 3

/* 28. Which regions have average sales volume greater than 6000? */

SELECT
	region,
	AVG(sales_volume) AS avg_region_sales
FROM bmw_sales
GROUP BY region
HAVING AVG(sales_volume) > 6000

/* 29. Find models with maximum price above $100,000. */

SELECT 
	model,
	MAX(price_usd) AS model_max_price
FROM bmw_sales
GROUP BY model
HAVING MAX(price_usd) > 100000

/* 30. Which transmission type has highest total sales volume? */

SELECT TOP 1
	transmission,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY transmission
ORDER BY total_sales_volume DESC

/* 31. Find the top 5 most sold BMW models. */

SELECT TOP 5
	model,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model
ORDER BY total_sales_volume DESC

/* 32. Which region has the highest average vehicle price? */

SELECT TOP 1
	region,
	AVG(price_usd) AS avg_price
FROM bmw_sales
GROUP BY region
ORDER BY avg_price DESC

/* 33. Find the least selling BMW model. */

SELECT TOP 1
	model,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model
ORDER BY total_sales_volume

/* 34. Find the average price difference between Automatic and Manual transmission cars. */

SELECT 
	MAX(avg_price) - MIN(avg_price) AS avg_diff_price
FROM (
SELECT 
	transmission,
	AVG(price_usd) AS avg_price
FROM bmw_sales
GROUP BY transmission) T
	
--ALTERNATE WAY
SELECT
    AVG(CASE WHEN transmission = 'Automatic' THEN price_usd END)
    -
    AVG(CASE WHEN transmission = 'Manual' THEN price_usd END)
    AS avg_price_difference
FROM bmw_sales;

/* 35. Identify the most common model in each region.*/

SELECT
	region,
	model,
	total_records
FROM (
	SELECT
		region,
		model,
		COUNT(*) AS total_records,
		DENSE_RANK() OVER(
			PARTITION BY region
			ORDER BY COUNT(*) DESC
		) AS rnk
	FROM bmw_sales
	GROUP BY region, model
) T
WHERE rnk = 1;

/* 36. Find vehicles whose price is greater than the overall average price. */

SELECT
	model,
	price_usd
FROM bmw_sales
WHERE price_usd >(
	SELECT
		AVG(CAST(price_usd AS BIGINT)) AS avg_price
	FROM bmw_sales
)

/* 37. Find models whose sales volume is higher than the average sales volume. */

SELECT
	model,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model
HAVING SUM(sales_volume) > (
	SELECT AVG(sales_volume)
	FROM bmw_sales
);

/* 38. Find the model with the highest sales volume. */

SELECT TOP 1 WITH TIES 
	model,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model
ORDER BY total_sales_volume DESC

/* 39. Find vehicles whose engine size is above the average engine size. */

SELECT 
	model,
	engine_size_l
FROM bmw_sales
WHERE engine_size_l > (
	SELECT AVG(engine_size_l)
	FROM bmw_sales
);

/* 40. Find the region with the highest total sales volume using a subquery. */

SELECT
	region,
	total_sales_volume
FROM (
	SELECT
		region,
		SUM(sales_volume) AS total_sales_volume
	FROM bmw_sales
	GROUP BY region
) T
WHERE total_sales_volume = (
	SELECT MAX(total_sales_volume)
	FROM (
		SELECT
			region,
			SUM(sales_volume) AS total_sales_volume
		FROM bmw_sales
		GROUP BY region
	) X
);

-- simplest way 
SELECT TOP 1
	region,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY region
ORDER BY total_sales_volume DESC;

/* 41. Rank BMW models by sales volume. */

SELECT
	model,
	SUM(sales_volume) AS total_sales_volume,
	RANK() OVER(ORDER BY SUM(sales_volume) DESC) AS sales_rank
	--RANK() OVER()
FROM bmw_sales
GROUP BY model

/* 42. Find the top 3 most expensive vehicles in each region. */

SELECT
	region,
	model,
	price_usd
FROM(
	SELECT
		region,
		model,
		price_usd,
		DENSE_RANK() OVER(PARTITION BY region ORDER BY price_usd DESC) AS rnk
	FROM bmw_sales
)T
WHERE rnk <=3

/* 43. Calculate running total of sales volume by year. */

SELECT
    year,
    SUM(sales_volume) AS yearly_sales,
    SUM(SUM(sales_volume)) OVER (
        ORDER BY year
    ) AS running_total_sales
FROM bmw_sales
GROUP BY year
ORDER BY year;

/* 44. Find the highest priced car per model. */

SELECT
    model,
    price_usd
FROM (
    SELECT
        model,
        price_usd,
        ROW_NUMBER() OVER (
            PARTITION BY model
            ORDER BY price_usd DESC
        ) AS rn
    FROM bmw_sales
) t
WHERE rn = 1;

/* 45. Calculate average price per region using window function. */

SELECT
    region,
    model,
    price_usd,
    AVG(price_usd) OVER (
        PARTITION BY region
    ) AS avg_region_price
FROM bmw_sales;

/* 46. Using CTE, find top 5 regions by total sales volume */

WITH CTE_top_regions AS(
	SELECT 
		region,
		SUM(sales_volume) AS total_sales_volume
	FROM bmw_sales
	GROUP BY region
)
SELECT TOP 5
	region,
	total_sales_volume
FROM CTE_top_regions
ORDER BY total_sales_volume DESC

/* 47. Using CTE, calculate average price per model and filter models above average. */

/* 47. Using CTE, calculate average price per model and filter models above average */

/* 47. Using CTE, calculate average price per model and filter models above average */

WITH CTE_avg_price AS (
    SELECT
        model,
        AVG(price_usd) AS avg_model_price
    FROM bmw_sales
    GROUP BY model
)

SELECT
    model,
    avg_model_price
FROM CTE_avg_price
WHERE avg_model_price > (
    SELECT AVG(CAST(price_usd AS BIGINT))
    FROM bmw_sales
);

--Cleaned and better version

WITH model_avg_price AS (
    SELECT
        model,
        AVG(price_usd) AS avg_model_price
    FROM bmw_sales
    GROUP BY model
),
overall_avg AS (
    SELECT AVG(price_usd) AS overall_avg_price
    FROM bmw_sales
)

SELECT
    m.model,
    m.avg_model_price
FROM model_avg_price m
CROSS JOIN overall_avg o
WHERE m.avg_model_price > o.overall_avg_price;

/* 48. Using CTE, rank models by sales volume and show top models per region. */

WITH CTE_model_sales AS (
    SELECT
        region,
        model,
        SUM(sales_volume) AS total_sales_volume
    FROM bmw_sales
    GROUP BY region, model
),

ranked_models AS (
    SELECT
        region,
        model,
        total_sales_volume,
        RANK() OVER (
            PARTITION BY region
            ORDER BY total_sales_volume DESC
        ) AS sales_rank
    FROM CTE_model_sales
)
SELECT
    region,
    model,
    total_sales_volume
FROM ranked_models
WHERE sales_rank = 1;

/* 49. Using CTE, find vehicles with price above regional average price. */
WITH CTE_regional_avg AS (
    SELECT
        region,
        AVG(price_usd) AS avg_region_price
    FROM bmw_sales
    GROUP BY region
)
SELECT
    b.region,
    b.model,
    b.price_usd,
    r.avg_region_price
FROM bmw_sales b
JOIN CTE_regional_avg r
    ON b.region = r.region
WHERE b.price_usd > r.avg_region_price;

--Alternative (Advanced Window Fucntion Version)

WITH price_analysis AS (
    SELECT
        region,
        model,
        price_usd,
        AVG(price_usd) OVER(PARTITION BY region) AS avg_region_price
    FROM bmw_sales
)

SELECT *
FROM price_analysis
WHERE price_usd > avg_region_price;

/* 50. Using CTE + window function, find top selling model each year. */

/* 50. Using CTE + window function, find top selling model each year */

WITH CTE_yearly_model_sales AS (
    SELECT
        year,
        model,
        SUM(sales_volume) AS total_sales_volume
    FROM bmw_sales
    GROUP BY year, model
),

ranked_models AS (
    SELECT
        year,
        model,
        total_sales_volume,
        RANK() OVER (
            PARTITION BY year
            ORDER BY total_sales_volume DESC
        ) AS sales_rank
    FROM CTE_yearly_model_sales
)
SELECT
    year,
    model,
    total_sales_volume
FROM ranked_models
WHERE sales_rank = 1
ORDER BY year;








