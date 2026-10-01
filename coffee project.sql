SET sql_safe_updates = 0;
SET sql_safe_updates = 0;

select count(*) as total_rows
from coffee;

DESCRIBE coffee;

ALTER TABLE coffee
MODIFY COLUMN transaction_date DATE;


-- to know the date format in total rows -- 
select 
   CASE
        WHEN transaction_date LIKE '____-__-__' THEN 'YYYY-MM-DD'
        WHEN instr(transaction_date, '/') > 0 THEN 'M/D/YY'
        ELSE 'other'
        END AS date_format,
        COUNT(*) AS total_rows
	FROM coffee
    GROUP BY date_format;
    
    --  to know the invalid dates -- 
    SELECT COUNT(*) AS invalid_date
    FROM coffee
    WHERE str_to_date(transaction_date, '%c%e%y') IS NULL;
    
    
    -- to find the invalid dates in table 
    SELECT COUNT(*) AS invalid_date
    FROM coffee
    WHERE str_to_date(transaction_date, '%c/%e/%y') IS NULL;
    
    -- changing the date format -- 
    UPDATE coffee
			SET transaction_date =
	date_format(
		str_to_date(transaction_date, '%c/%e/%Y'), '%Y-%m-%d'
        );
        
        
        -- Change the column's data type to DATE. -- 
        ALTER TABLE coffee
        MODIFY COLUMN transaction_date  DATE;
        
        describe coffee;
        
        
        -- Change the column's data type to TIME. -- 
        ALTER TABLE coffee
        MODIFY COLUMN transaction_time TIME;
        
        
        -- changing the column name --  
        SELECT * FROM  coffee;
        ALTER TABLE coffee
        RENAME COLUMN ï»¿transaction_id TO transaction_id;
        
        -- changing the column name -- 
        ALTER TABLE coffee
        CHANGE COLUMN transaction_id Transaction_id INT;
        
           -- changing the column name -- 
        ALTER TABLE coffee
        CHANGE COLUMN Transaction_id transaction_id INT;
        
        SELECT * FROM coffee;
        
        -- to know which column actually need cleaning -- 
        SELECT
    SUM(transaction_id IS NULL) AS transaction_id_nulls,
    SUM(transaction_date IS NULL) AS transaction_date_nulls,
    SUM(transaction_time IS NULL) AS transaction_time_nulls,
    SUM(transaction_qty IS NULL) AS transaction_qty_nulls,
    SUM(store_id IS NULL) AS store_id_nulls,
    SUM(store_location IS NULL) AS store_location_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(unit_price IS NULL) AS unit_price_nulls,
    SUM(product_category IS NULL) AS product_category_nulls,
    SUM(product_type IS NULL) AS product_type_nulls,
    SUM(product_detail IS NULL) AS product_detail_nulls
FROM coffee;

 

-- 1. Total Sales Analysis -- 
-- * calculate total sales for each respective month -- 
SELECT round(SUM(unit_price * transaction_qty),2) AS total_sales
FROM coffee
		WHERE 
			month(transaction_date) = 5 ; -- May Month -- 
            

 -- * Determine the month on month increase or decrease in sale  & 
 -- * calculate the difference in sales between the selected month and the previous month -- 
SELECT 
     month(transaction_date) AS MONTH,   -- number of month
round(SUM(unit_price * transaction_qty)) AS total_sales,  -- total sales column    
sum(unit_price * transaction_qty) - LAG(sum(unit_price * transaction_qty),1)  -- month sales difference
OVER(ORDER BY MONTH(transaction_date)) / LAG(sum(unit_price * transaction_qty),1)  -- dividing by previous month
OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage   -- converting into percentage
FROM
    coffee
WHERE 
     MONTH(transaction_date) in (4,5)    -- for month of april and may 
GROUP BY 
	 MONTH(transaction_date)
ORDER BY 
     MONTH(transaction_date);


--  2. Total Order Analysis -- 
--  * Calculate the total number of orders for each respective month --
SELECT COUNT(transaction_id) AS total_orders
FROM coffee
WHERE  
     MONTH(transaction_date) = 3;    --  March Month
     

-- * Determine the month on month increases or decreases in the number of rows & -- 
-- * Calculate the difference in the number of rows between the selected month and previous month -- 
SELECT 
     MONTH(transaction_date) AS MONTH,    --  present month 
     ROUND(COUNT(transaction_id)) AS total_orders,   -- total orders
     (COUNT(transaction_id) - LAG(COUNT(transaction_id),1)     -- order sales difference
     OVER(ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id),1)    -- dividing by previous month
     OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage      -- converting into percentage
FROM 
    coffee
WHERE 
     MONTH(transaction_date) IN  (4, 5)     -- for april and May month
GROUP BY
        MONTH(transaction_date)
ORDER BY 
        MONTH(transaction_date);
        
        
-- 3. Total qty sold Analysis -- 
--  * Calculate the total qty sold for respective month --   
SELECT sum(transaction_qty) AS total_quantity_sold
FROM coffee
WHERE
     MONTH(transaction_date) = 4;     -- for April Month
     
     
--  *  Determine the month on month increases or decreases in the total qty sold & -- 
--  *  Calculate the difference in the total qty sold between the selected month and the previous month --
SELECT 
      MONTH(transaction_date) AS MONTH,   --  present month
      ROUND(SUM(transaction_qty)) AS total_qty_sold,   -- total qty sold
      (sum(transaction_qty) - LAG(sum(transaction_qty),1)  -- total qty sold difference
      OVER(ORDER BY MONTH(transaction_date))) / LAG(sum(transaction_qty),1)     -- dividing by previous month
      OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage   -- converting into percentage
      
FROM coffee
	WHERE 
         MONTH(transaction_date) IN (4,5)    --  for April and May month
GROUP BY
        MONTH(transaction_date)
Order BY
        MONTH(transaction_date);
        
-- 4. Charts required -- 
-- * To find total sales, total orders and total qty sold Deal with calender heat map-- 
SELECT
      CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales, 
      CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K')  AS total_orders,
      CONCAT(ROUND(SUM(transaction_qty)/1000,1), 'K') AS total_qty_sold
FROM coffee
WHERE
     transaction_date = '2023-03-27';
     
-- * To find sales analysis by weekdays & weekends -- 
-- weekends - saturday and sunday -- 
-- weedays  - monday to friday  -- 
-- Sun - 1
-- Mon - 2
-- .
-- .
-- .
-- Sat - 7  

SELECT 
     CASE
         WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'weekends'
	ELSE 'weekdays'
    END AS date_type,
CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee
WHERE MONTH(transaction_date) = 5  -- May Month
GROUP BY 
	CASE
         WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'weekends'
	ELSE 'weekdays'
    END;
    
--  * To find the sales analysis by location -- 
SELECT 
     store_location,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee
WHERE
     MONTH(transaction_date) = 5  --  May Month
     GROUP BY store_location
     ORDER BY SUM(unit_price * transaction_qty) DESC;
     
SELECT store_location
FROM coffee
GROUP BY store_location;
     
-- * To find Daily sales analysis with average line -- 
SELECT
     CONCAT(ROUND(AVG(total_sales)/1000,1), 'K') AS Avg_sales
FROM
    (
    SELECT 
         SUM(transaction_qty * unit_price) AS total_sales
	FROM coffee
    WHERE MONTH (transaction_date) = 5    --  for May Month
    GROUP BY transaction_date 
    ) AS internal_query; 
    
 --    Total sales by day of month -- 
 SELECT
       DAY(transaction_date) AS day_of_month,
       CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
       FROM coffee
WHERE 
     MONTH(transaction_date) = 5
     GROUP BY DAY(transaction_date)
     Order BY DAY(transaction_date);
     
-- to  find the sales status -- 
SELECT 
      day_of_month,
	  CASE 
         WHEN total_sales > Avg_sales THEN 'Above Average'
         WHEN total_sales < Avg_sales THEN 'Below Average'
         ELSE 'Equal to Average'
	END AS sales_status,
    total_sales
    FROM (
		SELECT 
		       DAY(transaction_date) AS day_of_month,
               CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales,
               AVG(SUM(unit_price * transaction_qty)) OVER () AS Avg_sales
       FROM coffee
WHERE 
     MONTH(transaction_date) = 5
     GROUP BY DAY(transaction_date)) AS sales_data
     Order BY day_of_month;
     
-- find the total sales by product category -- 
SELECT 
	  product_category,
      CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee
WHERE
     MONTH(transaction_date) = 5 
     GROUP BY product_category
     ORDER BY SUM(unit_price * transaction_qty) DESC;
     
-- To find the TOP 10 products by sales -- 
SELECT
	 product_type,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee
WHERE
     MONTH(transaction_date) = 5
     GROUP BY product_type
     ORDER BY SUM(unit_price * transaction_qty) DESC
     LIMIT 10;
     
--  to find sales by days / hours -- 
SELECT
      CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales,   -- total sales
      SUM(transaction_qty) AS total_qty_sold,                                        -- total qty sold
      COUNT(*) AS total_orders                                                       -- total orders
FROM coffee
WHERE
	MONTH(transaction_date) = 5                 -- for May Month
    AND DAYOFWEEK(transaction_date) = 1         -- Sunday
    AND HOUR(transaction_time) = 14;             -- hour of 14
      
      
--  to find the total sales by hours -- 
SELECT
      HOUR(transaction_time),
      CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_slaes
FROM coffee
WHERE
	 MONTH(transaction_date) =  5 
     GROUP BY HOUR(transaction_time)
     ORDER BY HOUR(transaction_time);
     
-- To find the total sales by weekdays -- 
SELECT
      CASE
          WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
          WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
          WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
          WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
          WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
          WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
          ELSE 'Sunday'
END AS day_of_week,
		 CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee
WHERE 
     MONTH(transaction_date) = 5    -- for May Month
     GROUP BY
			CASE
          WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
          WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
          WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
          WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
          WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
          WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
          ELSE 'Sunday'
END;
     
