-- Calculate total quantity by store country and category.
SELECT STORE_CNTRY.[Country], P.[Category],
SUM([Quantity]) AS TOTAL_QTY
FROM [dbo].[Stores] AS STORE_CNTRY
INNER JOIN [dbo].[Sales] S
ON STORE_CNTRY.[StoreKey] = S.[StoreKey]
INNER JOIN [dbo].[Products] AS P
ON S.[ProductKey] = P.[ProductKey]
GROUP BY STORE_CNTRY.[Country], P.[Category]

-- Calculate customer profit by country.
 SELECT C.[Country],
 SUM(P.[Unit_Cost_USD] * S.[Quantity]) AS TOTAL_PROFIT
 FROM [dbo].[Products] AS P
 INNER JOIN [dbo].[Sales] AS S
 ON S.[ProductKey] = P.[ProductKey]
 INNER JOIN [dbo].[Customers] AS C
 ON S.[CustomerKey] = C.[CustomerKey]
 GROUP BY C.[Country] 

 -- Calculate total revenue by continent.
  WITH CONT_AMT AS 
 (
 SELECT C.[Continent], 
 P.[Unit_Price_USD] * S.[Quantity] AS SALES_AMOUNT
 FROM [dbo].[Sales] AS S
 LEFT JOIN [dbo].[Customers]  AS C
 ON S.[CustomerKey] = C.[CustomerKey] 
 LEFT JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 )
 SELECT [Continent], SUM(SALES_AMOUNT) AS EACH_CONTITNENT FROM CONT_AMT
 GROUP BY [Continent]

 -- Find the top 5 brands by revenue in each country.
  WITH TOPFIVEBRANDS AS 
 (
 SELECT  C.[Country], P.[Brand],
 P.[Unit_Price_USD] * S.[Quantity] AS REVENUE
 FROM  [dbo].[Sales] AS S
 INNER JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 INNER JOIN [dbo].[Customers] AS C
 ON C.[CustomerKey] = S.[CustomerKey] 
 )

 SELECT TOP 5 [Country], [Brand],
 SUM(REVENUE) AS REVENUE,
 RANK() OVER (ORDER BY  SUM(REVENUE) DESC) AS RNK
 FROM TOPFIVEBRANDS
 GROUP BY [Country], [Brand]


