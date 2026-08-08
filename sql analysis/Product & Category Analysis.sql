-- Find the best-selling product in each category.
 WITH BEST_SELLING_PRODUCT AS 
 (
 SELECT [Category], [Product_Name],
 SUM([Unit_Price_USD] * [Quantity]) AS SALES,
 DENSE_RANK() OVER (PARTITION BY [Category] ORDER BY SUM([Unit_Price_USD] * [Quantity]) DESC) AS RNK
 FROM [dbo].[Products] AS P
 INNER JOIN [dbo].[Sales] AS S
 ON P.[ProductKey] = S.[ProductKey]
 GROUP BY [Category], [Product_Name]
 )
 SELECT * FROM BEST_SELLING_PRODUCT 
 WHERE RNK = 1

 -- Find the top 5 brands by revenue. 
  WITH PRODUCT_BRANDS AS 
 (
 SELECT [Brand],
 SUM([Unit_Price_USD] * [Quantity]) AS SALES,
 RANK() OVER (ORDER BY SUM([Unit_Price_USD] * [Quantity]) DESC) AS RNK
 FROM [dbo].[Products] AS P 
 INNER JOIN [dbo].[Sales] AS S
 ON P.[ProductKey] = S.[ProductKey]
 GROUP BY [Brand]
 )
 SELECT TOP 5 * FROM PRODUCT_BRANDS
 
 SELECT TOP 5 [Brand],
 SUM([Unit_Price_USD] * [Quantity]) AS REVENUE
 FROM [dbo].[Products] AS P 
 INNER JOIN [dbo].[Sales] AS S
 ON P.[ProductKey] = S.[ProductKey]
 GROUP BY [Brand]

 -- Calculate profit by product category.

 SELECT [Category], 
 SUM(P.[Unit_Price_USD] * S.[Quantity]) AS SALESAMOUNT,
 SUM(P.[Unit_Cost_USD] * S.[Quantity]) AS COSTAMOUNT, 
 SUM(P.[Unit_Price_USD] * S.[Quantity]) -  SUM(P.[Unit_Cost_USD] * S.[Quantity]) AS PROFIT
 FROM [dbo].[Products] AS P
 INNER JOIN [dbo].[Sales] AS S
 ON S.[ProductKey] = P.[ProductKey]
 GROUP BY [Category]

 -- Find the top 3 products by revenue in each category.
  WITH THREE_SELLING_PRODUCTS AS
 (
 SELECT [Category], [Product_Name],
 SUM(P.[Unit_Price_USD] * S.[Quantity]) AS REVENUE,
 ROW_NUMBER() OVER (PARTITION BY [Category] ORDER BY SUM([Unit_Price_USD]) DESC) AS RNK
 FROM [dbo].[Products] AS P 
 INNER JOIN [dbo].[Sales] AS S
 ON S.[ProductKey] = P.[ProductKey]
 GROUP BY [Category], [Product_Name]
 )
 SELECT * FROM THREE_SELLING_PRODUCTS 
 WHERE RNK <= 3

 -- Find the top-selling product by quantity in each country.
  WITH TOPPRODUCT AS
 (
 SELECT  C.[Country], P.[Product_Name],
 SUM([Quantity]) AS TOTALQTY,
 ROW_NUMBER() OVER (PARTITION BY [Country] ORDER BY  SUM([Quantity]) DESC) AS RNK
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Products] AS P
 ON S.[ProductKey] = P.[ProductKey]
 INNER JOIN [dbo].[Customers] AS C
 ON S.[CustomerKey] = C.[CustomerKey]
 GROUP BY C.[Country], P.[Product_Name]
 )
 SELECT [Country],[Product_Name],TOTALQTY FROM TOPPRODUCT 
 WHERE RNK = 1
 ORDER BY TOTALQTY DESC

-- Find products with the highest profit.
SELECT [Product_Name], [Brand],  
SUM(P.[Unit_Price_USD] * S.[Quantity]) AS REVENUE,
SUM(P.[Unit_Cost_USD] * S.[Quantity]) AS COST,
SUM(P.[Unit_Price_USD] * S.[Quantity]) - SUM(P.[Unit_Cost_USD] * S.[Quantity]) AS PROFIT
FROM [dbo].[Sales] AS S
LEFT JOIN [dbo].[Products] P
ON P.[ProductKey] = S.[ProductKey]
GROUP BY [Product_Name], [Brand]
ORDER BY PROFIT DESC

-- Find the best-selling category in each country.
WITH BEST_SELLING_PRODUCT AS
(
SELECT C.[Country], P.[Category],
[Unit_Price_USD] * [Quantity] AS REVENUE
FROM [dbo].[Sales] AS S
LEFT JOIN [dbo].[Products] AS P
ON P.[ProductKey] = S.[ProductKey]
LEFT JOIN [dbo].[Customers] AS C
ON C.[CustomerKey] = S.[CustomerKey]
)
SELECT [Country], [Category],
SUM(REVENUE) AS REVENUE FROM BEST_SELLING_PRODUCT
GROUP BY [Country], [Category]
ORDER BY REVENUE DESC

-- Identify products that have never been sold.
 SELECT P.[ProductKey],
 P.[Product_Name] 
 FROM [dbo].[Products] AS P
 LEFT JOIN [dbo].[Sales] AS S
 ON S.[ProductKey] = P.[ProductKey]
 WHERE S.[ProductKey] IS NULL

 -- Calculate profit margin by product category.
 WITH PROFITPERCENTAGE AS
(
SELECT P.[Category], 
P.[Unit_Price_USD] * S.[Quantity] AS REVENUE,
P.[Unit_Cost_USD] * S.[Quantity] AS COST
FROM [dbo].[Sales] AS S
LEFT JOIN [dbo].[Products] P
ON P.[ProductKey] = S.[ProductKey]
)
SELECT [Category],
SUM(Revenue) AS REVENUE,
SUM(Cost) AS COST,
SUM(Revenue) -  SUM(Cost) AS Profit,
ROUND(((SUM(Revenue) - SUM(Cost)) * 100.0) / NULLIF(SUM(Cost), 0),2
) AS ProfitPercentage
FROM PROFITPERCENTAGE
GROUP BY [Category]
ORDER BY ProfitPercentage DESC

-- Find the best-selling product color in each category. 
 WITH HIGHSELLINGCOLOR AS
 (
 SELECT P.[Category], P.[Color],
 SUM([Quantity]) AS QTY
 FROM [dbo].[Products] AS P
 INNER JOIN [dbo].[Sales] AS S
 ON S.[ProductKey] = P.[ProductKey]
 GROUP BY [Category],[Color]
 ),
 HIGHSELLING AS
 (
 SELECT [Category],[Color],QTY,
 RANK() OVER (PARTITION BY [Category] ORDER BY QTY DESC) AS RNK
 FROM HIGHSELLINGCOLOR
 )
 SELECT * FROM HIGHSELLING 
 WHERE RNK = 1

 