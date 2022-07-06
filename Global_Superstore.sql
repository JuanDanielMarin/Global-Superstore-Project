-- DATA EXPLORATION 

SELECT TOP 5 *
FROM Global_Superstore;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Checking the table dimensions

SELECT 
	COUNT (*) AS Total_Rows,
	(SELECT 
		COUNT (*) 
	 FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE TABLE_NAME = 'Global_Superstore') AS Total_Columns
FROM Global_Superstore;

-- We can see that the Data has 51,290 data entries with 24 features

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Checking the data types

SELECT
	DATA_TYPE AS Data_Type,
	COUNT (DATA_TYPE) AS Total
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Global_Superstore'
GROUP BY Data_Type
ORDER BY 2 DESC;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Cheeking for missing values in all columns

SELECT 
	COUNT (*) - COUNT (Row_ID) AS missing_Row_ID,
	COUNT (*) - COUNT (Order_ID) AS missing_Order_ID,
	COUNT (*) - COUNT (Order_Date) AS missing_Order_Date,
	COUNT (*) - COUNT (Ship_Date) AS missing_Ship_Date,
	COUNT (*) - COUNT (Customer_ID) AS missing_Customer_ID,
	COUNT (*) - COUNT (Customer_Name) AS missing_Customer_Name,
	COUNT (*) - COUNT (Segment) AS missing_Segment,
	COUNT (*) - COUNT (City) AS missing_City,
	COUNT (*) - COUNT (State) AS missing_State,
	COUNT (*) - COUNT (Country) AS missing_Country,
	COUNT (*) - COUNT (Postal_Code) AS missing_Postal_Code,
	COUNT (*) - COUNT (Market) AS missing_Market,
	COUNT (*) - COUNT (Region) AS missing_Region,
	COUNT (*) - COUNT (Product_ID) AS missing_Product_ID,
	COUNT (*) - COUNT (Category) AS missing_Category,
	COUNT (*) - COUNT (Sub_Category) AS missing_Sub_Category,
	COUNT (*) - COUNT (Product_Name) AS missing_Product_Name,
	COUNT (*) - COUNT (Sales) AS missing_Sales,
	COUNT (*) - COUNT (Quantity) AS missing_Quantity,
	COUNT (*) - COUNT (Discount) AS missing_Discount,
	COUNT (*) - COUNT (Profit) AS missing_Profit,
	COUNT (*) - COUNT (Shipping_Cost) AS missing_Shipping_Cost,
	COUNT (*) - COUNT (Order_Priority) AS missing_Order_Priority
FROM Global_Superstore;

-- We can see that only the postal code attribute has 41,296 null values, that is almost 80 % of the values in the column.

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Checking the categorical columns

SELECT 
	COLUMN_NAME AS Categorical_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Global_Superstore' AND DATA_TYPE = 'nvarchar';

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Checking the unique values columns

SELECT 
	COLUMN_NAME AS Unique_Values_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Global_Superstore' AND DATA_TYPE = 'float';

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DATA CLEANING

-- Changing Order_Date and Ship_Date from nvarchar to date format

ALTER TABLE Global_Superstore
ALTER COLUMN Order_Date date;

ALTER TABLE Global_Superstore
ALTER COLUMN Ship_Date date;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standarizing the Market classification

SELECT
	DISTINCT Market
FROM Global_Superstore;

/* We can see some errors in the clasify terms. According to the standard terminology: 
	Africa should be EMEA
	EU should be EMEA
	Canada should be NA
	US should be NA
*/ 

SELECT
	DISTINCT Market,
CASE
	WHEN Market = 'Africa' THEN 'EMEA'
	WHEN Market = 'EU' THEN 'EMEA'
	WHEN Market = 'Canada' THEN 'NA'
	WHEN Market = 'US' THEN 'NA'
	ELSE Market
END AS Market_Corrected
FROM Global_Superstore
ORDER BY 2;

UPDATE Global_Superstore
SET Market = 
	CASE
		WHEN Market = 'Africa' THEN 'EMEA'
		WHEN Market = 'EU' THEN 'EMEA'
		WHEN Market = 'Canada' THEN 'NA'
		WHEN Market = 'US' THEN 'NA'
		ELSE Market
	END
FROM Global_Superstore;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standarizing the Region classification

SELECT
	DISTINCT Country,
	Region
FROM Global_Superstore;

SELECT *
FROM Regional_Classification;

SELECT
	DISTINCT a.Country,
	a.Region,
	b.Country,
	b.Region
FROM Global_Superstore a
LEFT OUTER JOIN Regional_Classification b
	ON a.Country = b.Country
ORDER BY a.Country;

UPDATE Global_Superstore 
SET Region = (
	SELECT Region
	FROM Regional_Classification
	WHERE Global_Superstore.Country = Regional_Classification.Country )
FROM Global_Superstore;

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Aggreate a Revenue column

ALTER TABLE Global_Superstore
ADD Revenue float;

UPDATE Global_Superstore
SET Revenue = Sales * Quantity;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM Global_Superstore;

ALTER TABLE Global_Superstore
DROP COLUMN	
	Postal_Code;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- PRODUCT ANALYSIS 

-- 1. Which are the top 5 profit-making product types on a yearly basis?

DROP TABLE IF EXISTS #Temp_Year
SELECT
	Row_ID,
	DATEPART (YEAR, Order_Date) AS Year
INTO #Temp_Year
FROM Global_Superstore

SELECT * FROM #Temp_Year;

-- 2011 
SELECT
	TOP 5 a.Sub_Category,
	ROUND (SUM (a.Profit), 0) AS Profit_Making,
	b.Year
FROM Global_Superstore a
INNER JOIN #Temp_Year b
	ON a.Row_ID = b.Row_ID
WHERE Year = 2011
GROUP BY a.Sub_Category, b.Year
ORDER BY b.Year, Profit_Making DESC

-- 2012
SELECT
	TOP 5 a.Sub_Category,
	ROUND (SUM (a.Profit), 0) AS Profit_Making,
	b.Year
FROM Global_Superstore a
INNER JOIN #Temp_Year b
	ON a.Row_ID = b.Row_ID
WHERE Year = 2012
GROUP BY a.Sub_Category, b.Year
ORDER BY b.Year, Profit_Making DESC

-- 2013
SELECT
	TOP 5 a.Sub_Category,
	ROUND (SUM (a.Profit), 0) AS Profit_Making,
	b.Year
FROM Global_Superstore a
INNER JOIN #Temp_Year b
	ON a.Row_ID = b.Row_ID
WHERE Year = 2013
GROUP BY a.Sub_Category, b.Year
ORDER BY b.Year, Profit_Making DESC

-- 2014
SELECT
	TOP 5 a.Sub_Category,
	ROUND (SUM (a.Profit), 0) AS Profit_Making,
	b.Year
FROM Global_Superstore a
INNER JOIN #Temp_Year b
	ON a.Row_ID = b.Row_ID
WHERE Year = 2014
GROUP BY a.Sub_Category, b.Year
ORDER BY b.Year, Profit_Making DESC;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Which are the category and sub category with more revenues?

SELECT 
	DISTINCT Category,
	ROUND (SUM (Revenue), 0) AS Revenue
FROM Global_Superstore
GROUP BY Category
ORDER BY Revenue DESC; 

SELECT 
	DISTINCT TOP 5 Sub_Category,
	ROUND (SUM (Revenue), 0) AS Revenue
FROM Global_Superstore
GROUP BY Sub_Category
ORDER BY Revenue DESC; 

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CUSTOMER ANALYSIS 

-- 3. Profile the customers based on their frequency of purchase – calculate frequency of purchase for each customer.

DROP TABLE IF EXISTS #Temp_Frecuency
SELECT
	Customer_ID,
	DATEDIFF (DAY, MIN (Order_Date), MAX (Order_Date)) / COUNT (DISTINCT Order_ID) AS Frequency
INTO #Temp_Frencuency
FROM Global_Superstore
GROUP BY Customer_ID

SELECT * FROM #Temp_Frencuency;

SELECT
	a.Customer_ID,
	COUNT (a.Order_ID) AS Purchases,
	SUM (a.Sales) AS Total_Sales,
	SUM (a.Shipping_Cost) AS Total_Cost,		
	MIN (a.Order_Date) AS First_Purchase_Date,
	MAX (a.Order_Date) AS Latest_Purchase_Date,
	COUNT (DISTINCT a.City) AS Location_Count, 
	DATEDIFF (DAY, MIN (Order_Date), MAX (Order_Date)) AS Duration,
	b.Frequency
FROM Global_Superstore a
INNER JOIN #Temp_Frencuency b
	ON a.Customer_ID = b.Customer_ID
GROUP BY b.Frequency, a.Customer_ID
ORDER BY a.Customer_ID;

-- Frequency describe 

SELECT
	COUNT (*) AS Count_Frequency,
	AVG (Frequency) AS Mean,
	ROUND (STDEV (Frequency), 2) AS std,
	MIN (Frequency) AS min,
	MAX (Frequency) AS max	
FROM #Temp_Frencuency

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4. Do the high frequent customers are contributing more revenue?

SELECT
	DISTINCT a.Customer_ID,
	a.Frequency,
	CASE 
		WHEN a.Frequency > 430 THEN 'High'
		WHEN a.Frequency < 220 THEN 'Low'
		ELSE 'Mid'
	END AS Frequency_Range,
	ROUND (SUM (b.Revenue), 0) AS Revenue
FROM #Temp_Frencuency a
INNER JOIN Global_Superstore b
	ON a.Customer_ID = b.Customer_ID
GROUP BY a.Customer_ID, a.Frequency
ORDER BY Revenue DESC;

--The high revenues corresponds to the low frequency customers

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. Which customer segment is most profitable in each year?

SELECT
	DISTINCT b.Year,
	a.Segment,
	COUNT (a.Segment) AS Count
FROM Global_Superstore a
INNER JOIN #Temp_Year b
	ON a.Row_ID = b.Row_ID
GROUP BY b.Year, a.Segment
ORDER BY b.Year, Count DESC;
---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- COUNTRY AND DELIVERY ANALYSIS 

-- 6. How the customers are distributed across the countries?

SELECT TOP 10
	Country,
	COUNT (Country) AS Count
FROM Global_Superstore
GROUP BY Country
ORDER BY 2 DESC;

------------------------------------------------------------------------------------------------------------------------------------------

-- 7. Which Country has top sales?

SELECT TOP 20
	Country,
	COUNT (Sales) AS Sales
FROM Global_Superstore
GROUP BY Country
ORDER BY 2 DESC;

------------------------------------------------------------------------------------------------------------------------------------------

-- 8. What is the avergage delivery time across the countries?

SELECT
    Country,
	AVG (DATEDIFF (DAY, Order_Date, Ship_Date)) AS AVG_Shipment_Date
FROM Global_Superstore
GROUP BY Country
ORDER BY 2 DESC, 1; 
