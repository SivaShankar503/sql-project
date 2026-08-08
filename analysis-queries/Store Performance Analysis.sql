-- Find the store with the highest revenue.
 SELECT TOP 1 N.[StoreKey], 
 SUM([Unit_Price_USD] * [Quantity]) AS SALES
 FROM [dbo].[Stores] AS N
 INNER JOIN [dbo].[Sales] AS S
 ON N.[StoreKey] = S.[StoreKey]
 INNER JOIN [dbo].[Products] AS P
 ON S.[ProductKey] = P.[ProductKey]
 GROUP BY N.[StoreKey] 

 -- Calculate revenue by store country and state.
 SELECT S.[Country], S.[State],    
 SUM(P.[Unit_Price_USD] * N.[Quantity])  AS REVENUE 
 FROM [dbo].[Sales] AS N
 LEFT JOIN [dbo].[Stores] AS S
 ON S.[StoreKey] = N.[StoreKey]
 LEFT JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = N.[ProductKey]
 GROUP BY S.[Country], S.[State] 

 -- Analyze store revenue by location and store size.
 WITH HIGHSALES AS
(
SELECT  N.[StoreKey], [Country], [State], [Square_Meters], 
(P.[Unit_Price_USD] * [Quantity]) AS REVENUE
FROM [dbo].[Stores] AS N
INNER JOIN [dbo].[Sales] AS S
ON S.[StoreKey] = N.[StoreKey]
INNER JOIN [dbo].[Products] AS P
ON P.[ProductKey] = S.[ProductKey] 
)
SELECT [StoreKey],[Country], [Square_Meters], 
SUM(REVENUE) AS REVENUE FROM HIGHSALES
GROUP BY [StoreKey], [Country], [Square_Meters] 
ORDER BY SUM(REVENUE) DESC

-- Identify stores that have never processed an order.
 SELECT S.[StoreKey],S.[Country],S.[State] 
 FROM [dbo].[Stores] AS S
 LEFT JOIN [dbo].[Sales] AS N
 ON N.[StoreKey] = S.[StoreKey]
 WHERE N.[StoreKey] IS NULL

-- Rank stores by total revenue.
 WITH RANKSTORE AS
 (
 SELECT N.[StoreKey], N.[Country],
 P.[Unit_Price_USD] * S.[Quantity] AS REVENUE
 FROM [dbo].[Sales] AS S
 LEFT JOIN [dbo].[Stores] AS N
 ON N.[StoreKey] = S.[StoreKey]
 LEFT JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 ),
 TOTALREVENUE AS
 (
 SELECT [StoreKey], [Country], 
 SUM(REVENUE) AS REVENUE
 FROM RANKSTORE 
 GROUP BY [StoreKey], [Country] 
 )
 SELECT [StoreKey], [Country], REVENUE,
 RANK() OVER (ORDER BY REVENUE DESC) AS STORERNK
 FROM  TOTALREVENUE 