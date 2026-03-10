-- total rows
SELECT COUNT(*) total_rows FROM bmw_sales
-- alternative query to find total rows there is no performance issue slightly negligible
SELECT COUNT(1) total_rows FROM bmw_sales 

-- column profile
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
--------------------------------------------------------------------------------------------------------


/* finding blank and empty spaces and i didn't apply null values on number fields because i does not allow string values */
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN TRIM(model) = '' THEN 1 ELSE 0 END) AS blank_models,
    SUM(CASE WHEN TRIM(color) = '' THEN 1 ELSE 0 END) AS blank_color,
    SUM(CASE WHEN TRIM(fuel_type) = '' THEN 1 ELSE 0 END) AS blank_fuel_type,
    SUM(CASE WHEN TRIM(transmission) = '' THEN 1 ELSE 0 END) AS blank_transmission,
    SUM(CASE WHEN TRIM(sales_classification) = '' THEN 1 ELSE 0 END) AS blank_sales_classification
FROM bmw_sales;

-- even better version
SELECT 
	SUM(CASE 
		WHEN model IS NULL OR TRIM(model) = '' 
		THEN 1 ELSE 0 
	END) AS invalid_model
FROM bmw_sales
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
/* finding duplicate values (as there is no any primary key i would prefere full type match) */
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
-- alternative to find the duplicates using window functions
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
--------------------------------------------------------------------------------------------------

-- As there are no any null/empty values and duplicates there are no any handlings

--data distribution on categorical columns so that i can understand data inconsistency, uneven data and spelling mistakes ect..
SELECT DISTINCT model FROM bmw_sales ORDER BY model
SELECT DISTINCT year FROM bmw_sales ORDER BY year
SELECT DISTINCT region FROM bmw_sales ORDER BY region
SELECT DISTINCT color FROM bmw_sales ORDER BY color
SELECT DISTINCT fuel_type FROM bmw_sales ORDER BY fuel_type
SELECT DISTINCT transmission FROM bmw_sales ORDER BY transmission
SELECT DISTINCT sales_classification FROM bmw_sales ORDER BY sales_classification

-- Outliners
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

---------------------------------------------------------------------

/* 2. What are the distinct BMW models Available*/
SELECT DISTINCT model FROM bmw_sales  
-- GROUP BY without any aggregation method will give same result
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

-----------------------------------------------------------------------------------
/* 3. How Many unique regions are present in the dataset? */

SELECT DISTINCT region FROM bmw_sales

-------------------------------------------------------------------------------------
/* 4. What are the different transmission types are available*/

SELECT DISTINCT transmission FROM bmw_sales

-------------------------------------------------------------------------------------
/* 5. How mmany vehicles are there for each fuel type?*/

SELECT 
	fuel_type,
	SUM(sales_volume) AS total_vehicles
FROM bmw_sales
GROUP BY fuel_type

--------------------------------------------------------------------------------------------
/* 6. What is the minimum and maximum vehicle price*/

SELECT
	MIN(price_usd) AS min_price,
	MAX(price_usd) AS max_price
FROM bmw_sales

-----------------------------------------------------------------------------------------------
/* 7. What is the average engine size of vehicles */
SELECT
	ROUND(AVG(engine_size_l),2) AS avg_engine_size
FROM bmw_sales

---------------------------------------------------------------------
/* 8. What is the average mileage of vehicles */

SELECT
	AVG(CAST(mileage_km AS BIGINT)) AS avg_mileage
FROM bmw_sales

-------------------------------------------------------------------------------
/* 9. How many vehicles are sold in each sales classification(High/Low)*/

SELECT
	sales_classification,
	SUM(sales_volume) AS total_sales
FROM bmw_sales
GROUP BY sales_classification

----------------------------------------------------------------------------------
/* 10. How many cars wer produced each year*/
SELECT
	year,
	SUM(sales_volume) AS total_cars_produced
FROM bmw_sales
GROUP BY year
ORDER BY year 


	--PART 2 — Aggregation Analysis (11–20)--

/* 11. What is the total sales volume for all BMW vehicles? */
SELECT
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales

------------------------------------------------------------------
/* 12. What is the average price of vehicles per model? */
SELECT
	model,
	AVG(price_usd) AS avg_model_price
FROM bmw_sales
GROUP BY model

----------------------------------------------------------------------
/* 13. Which region has the highest sales volume? */
SELECT TOP 1
	region,
	SUM(sales_volume) AS highest_sales_volume
FROM bmw_sales
GROUP BY region
ORDER BY highest_sales_volume DESC

--------------------------------------------------------------------------

/*14. What is the total sales volume per region? */
SELECT 
	region,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY region

-----------------------------------------------------------------------------

/*15. What is the average mileage per model? */
SELECT
	model,
	AVG(mileage_km) AS model_avg_mileage
FROM bmw_sales
GROUP BY model

--------------------------------------------------------------------------------

/* 16. Which model has the highest average price? */
SELECT TOP 1
	model,
	AVG(price_usd) AS avg_price
FROM bmw_sales
GROUP BY model
ORDER BY avg_price DESC

----------------------------------------------------------------------------------

/* 17. What is the average engine size per fuel type? */
SELECT 
	fuel_type,
	ROUND(AVG(engine_size_l),2) AS avg_engine_size
FROM bmw_sales
GROUP BY fuel_type

------------------------------------------------------------------------------------------
/* 18.  Which year recorded the highest sales volume? */
SELECT TOP 1 
	year,
	SUM(sales_volume) AS sales_volume
FROM bmw_sales
GROUP BY year
ORDER BY sales_volume DESC

-------------------------------------------------------------------------------------

/* 19. What is the total number of vehicles sold per transmission type? */
SELECT
	transmission,
	SUM(sales_volume) AS total_sales
FROM bmw_sales
GROUP BY transmission

-----------------------------------------------------------------------------------
/* 20. Which color appears most frequently in the dataset? */
SELECT TOP 1
	color,
	COUNT(*) AS color_most
FROM bmw_sales
GROUP BY color
ORDER BY color_most DESC

           --PART 3 — GROUP BY + HAVING (21–30) --

/* 21. Which models have average price greater than $70,000? */
SELECT 
	model,
	AVG(price_usd) AS avg_price
FROM bmw_sales
GROUP BY model
HAVING AVG(price_usd) > 70000

--------------------------------------------------------------------------------------------
/* 22. Which regions have total sales volume greater than 50,000? */
SELECT
	region,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY region
HAVING SUM(sales_volume) > 50000

-------------------------------------------------------------------------------------------------

/* 23. Which models sold more than 20,000 units? */
SELECT 
	model,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model
HAVING SUM(sales_volume) > 20000

-------------------------------------------------------------------------------------------------

/* 24. Find models with average mileage greater than 80,000 km. */
SELECT
	model,
	AVG(mileage_km) AS model_avg_mileage
FROM bmw_sales
GROUP BY model
HAVING AVG(mileage_km) > 80000

----------------------------------------------------------------------

/* 25. Which years have average price greater than overall average price? */
SELECT
	year,
	AVG(price_usd) AS avg_year_price
FROM bmw_sales
GROUP BY year
HAVING AVG(price_usd) > (SELECT AVG(CAST(price_usd AS BIGINT)) FROM bmw_sales)

------------------------------------------------------------------------------------------

/* 26. Find fuel types that appear more than 5,000 times. */
SELECT
	fuel_type,
	COUNT(*) AS total_count
FROM bmw_sales
GROUP BY fuel_type
HAVING COUNT(*) > 5000

-------------------------------------------------------------------------------------------------

/* 27. Which models have engine size greater than 3L on average? */
SELECT 
	model,
	AVG(engine_size_l) AS avg_engine
FROM bmw_sales
GROUP BY model
HAVING AVG(engine_size_l) > 3


----------------------------------------------------------------------------------------------------

/* 28. Which regions have average sales volume greater than 6000? */
SELECT
	region,
	AVG(sales_volume) AS avg_region_sales
FROM bmw_sales
GROUP BY region
HAVING AVG(sales_volume) > 6000

--------------------------------------------------------------------------------------------------------

/* 29. Find models with maximum price above $100,000. */
SELECT 
	model,
	MAX(price_usd) AS model_max_price
FROM bmw_sales
GROUP BY model
HAVING MAX(price_usd) > 100000

-------------------------------------------------------------------------------------------------------------

/* 30. Which transmission type has highest total sales volume? */

SELECT TOP 1
	transmission,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY transmission
ORDER BY total_sales_volume DESC

-------------------------------------------------------------------------------------------------------------

--PART 4 — Intermediate Business Problems (31–35)--

/* 31. Find the top 5 most sold BMW models. */
SELECT TOP 5
	model,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model
ORDER BY total_sales_volume DESC

---------------------------------------------------------------------------------------------------------
/* 32. Which region has the highest average vehicle price? */
SELECT TOP 1
	region,
	AVG(price_usd) AS avg_price
FROM bmw_sales
GROUP BY region
ORDER BY avg_price DESC

-------------------------------------------------------------------------------------------------------
/* 33. Find the least selling BMW model. */
SELECT TOP 1
	model,
	SUM(sales_volume) AS total_sales_volume
FROM bmw_sales
GROUP BY model
ORDER BY total_sales_volume

----------------------------------------------------------------------------------------------------------
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

-----------------------------------------------------------------------------------------------------------------

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









--PART 5 — Subquery Problems (36–40)--

/* 36. Find vehicles whose price is greater than the overall average price. */

/* 37. Find models whose sales volume is higher than the average sales volume. */

/* 38. Find the model with the highest sales volume. */

/* 39. Find vehicles whose engine size is above the average engine size. */

/* 40. Find the region with the highest total sales volume using a subquery. */

      --PART 6 — Window Function Problems (41–45)--

/* 41. Rank BMW models by sales volume. */

/* 42. Find the top 3 most expensive vehicles in each region. */

/* 43. Calculate running total of sales volume by year. */

/* 44. Find the highest priced car per model. */

/* 45. Calculate average price per region using window function. */

 --PART 7 — CTE Based Business Problems (46–50)--

/* 46. Using CTE, find top 5 regions by total sales volume. */

/* 47. Using CTE, calculate average price per model and filter models above average. */

/* 48. Using CTE, rank models by sales volume and show top models per region. */

/* 49. Using CTE, find vehicles with price above regional average price. */

/* 50. Using CTE + window function, find top selling model each year. */









