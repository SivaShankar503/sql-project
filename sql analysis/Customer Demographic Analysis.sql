-- Calculate revenue by customer age group.

WITH AGEWISEREVENUE AS
 (
 SELECT C.[Name],C.[Birthday],S.[Order_Date],
 P.[Unit_Price_USD] * S.[Quantity] REVENUE,
 DATEDIFF(YYYY, [Birthday], GETDATE()) AS AGE 
 FROM [dbo].[Sales] AS S
 LEFT JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 LEFT JOIN [dbo].[Customers] AS C
 ON C.[CustomerKey] = S.[CustomerKey]
 ),
 AGECATE AS 
 (
 SELECT REVENUE, 
 CASE 
     WHEN AGE  >= 18 AND AGE <= 25 THEN '18-25'
     WHEN AGE >= 26 AND AGE <= 35 THEN '26-35'
     WHEN AGE >= 36 AND AGE <= 45 THEN '36-45'
     WHEN AGE >= 46 AND AGE <= 60 THEN '46-60'
     ELSE '60+'
 END AS AGEGROUP 
 FROM AGEWISEREVENUE 
 )
 SELECT AGEGROUP,
 SUM(REVENUE) AS REVENUE
 FROM AGECATE
 GROUP BY AGEGROUP