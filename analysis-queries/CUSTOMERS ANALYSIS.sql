-- Find the top 10 customers by revenue. 
  WITH TOTAL_SALES_REVENVE AS 
 (
 SELECT C.[Name],
 SUM([Unit_Price_USD] * [Quantity]) AS SALES,
 RANK() OVER (ORDER BY  SUM([Unit_Price_USD] * [Quantity]) DESC) AS RNK
 FROM [dbo].[Customers] AS C
 INNER JOIN [dbo].[Sales] AS S
 ON S.[CustomerKey] = C.[CustomerKey]
 INNER JOIN [dbo].[Products] AS P
 ON S.[ProductKey] = P.[ProductKey]
 GROUP BY C.[Name]
 )
 SELECT * FROM TOTAL_SALES_REVENVE 
 WHERE RNK  <= 10

 -- Calculate customer age at the time of purchase.
  SELECT
    C.[Name],
    DATEDIFF(YEAR, C.[Birthday], S.[Order_Date])
    - CASE
        WHEN DATEADD(YEAR,
                     DATEDIFF(YEAR, C.[Birthday], S.[Order_Date]),
                     C.[Birthday]) > S.[Order_Date]
        THEN 1
        ELSE 0
      END AS Age
FROM [dbo].[Customers] AS C
LEFT JOIN [dbo].[Sales] AS S
ON C.[CustomerKey] = S.[CustomerKey]
WHERE C.[Birthday] IS NOT NULL

--  Find customers who purchased from multiple stores. 
 WITH ONE_STORE AS 
 (
 SELECT C.[CustomerKey], C.[Name], S.[Order_Number], S.[StoreKey]
 FROM [dbo].[Customers] AS C
 INNER JOIN [dbo].[Sales] AS S
 ON S.[CustomerKey] = C.[CustomerKey]
 INNER JOIN [dbo].[Stores] AS N
 ON N.[StoreKey] = S.[StoreKey]
 ) 
 SELECT [CustomerKey],[Name], COUNT([StoreKey]) AS STORE FROM ONE_STORE
 GROUP BY  [CustomerKey], [Name] 
 HAVING COUNT([StoreKey]) > 1
 ORDER BY STORE 

 -- Identify repeat customers with multiple orders. 
  WITH CUS_MORE_ONE AS
 (
 SELECT C. [Name], S.[Order_Number] 
 FROM [dbo].[Customers] AS C
 INNER JOIN [dbo].[Sales] AS S
 ON S.[CustomerKey] = C.[CustomerKey]
 )
 SELECT [Name], COUNT([Order_Number]) AS TOTAL_ORDERS 
 FROM CUS_MORE_ONE
 GROUP BY [Name]
 HAVING COUNT([Order_Number]) > 1
 ORDER BY TOTAL_ORDERS

 -- Find customers who purchased from multiple categories.
  WITH ONE_STORE_CAT AS 
 (
 SELECT C.[CustomerKey], C.[Name], S.[Order_Number], P.[Category]
 FROM [dbo].[Customers] AS C
 INNER JOIN [dbo].[Sales] AS S
 ON S.[CustomerKey] = C.[CustomerKey]
 INNER JOIN  [dbo].[Products] AS P
 ON  P.[ProductKey] = S.[ProductKey] 
 ) 
 SELECT [Name], COUNT([Category]) AS CATEGORY FROM ONE_STORE_CAT
 GROUP BY  [CustomerKey], [Name] 
 HAVING COUNT([Category]) > 1
 ORDER BY CATEGORY

 -- Identify high-value customers by orders, quantity, and sales.
 SELECT C.[Name], C.[Country],
COUNT([Order_Number]) AS TOTALORDERS,
SUM([Quantity]) AS TOTALQUANTITY,
SUM(P.[Unit_Price_USD] * S.[Quantity]) AS TOTALSALESUSD
FROM [dbo].[Customers] AS C
LEFT JOIN [dbo].[Sales] AS S
ON S.[CustomerKey] = C.[CustomerKey]
LEFT JOIN [dbo].[Products] AS P
ON P.[ProductKey] = S.[ProductKey]
GROUP BY C.[Name], C.[Country]
ORDER BY SUM(P.[Unit_Price_USD] * S.[Quantity]) DESC

-- Find customers who purchased from at least three brands.
 WITH ONE_BRAND AS 
 (
 SELECT C.[CustomerKey], C.[Name], S.[Order_Number], P.[Brand] 
 FROM [dbo].[Customers] AS C
 INNER JOIN [dbo].[Sales] AS S
 ON S.[CustomerKey] = C.[CustomerKey]
 INNER JOIN  [dbo].[Products] AS P
 ON  P.[ProductKey] = S.[ProductKey] 
 ) 
 SELECT [Name], 
 COUNT([Brand]) AS BRANDS 
 FROM ONE_BRAND 
 GROUP BY [Name] 
 HAVING COUNT([Brand]) >= 3

 -- Find the oldest customer who placed an order.
  SELECT TOP 1
    C.Name,
    C.Country,
    C.Birthday
FROM dbo.Customers AS C
INNER JOIN dbo.Sales AS S
    ON C.CustomerKey = S.CustomerKey
ORDER BY C.Birthday ASC

-- Find customers spending above average.
WITH AVE_COUSTOMER_SPENDING AS
 (
 SELECT C.[Name],
 P.[Unit_Price_USD] * S.[Quantity] AS SALES
 FROM [dbo].[Customers] AS C
 INNER JOIN [dbo].[Sales] AS S
 ON S.[CustomerKey] = C.[CustomerKey]
 INNER JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 ),
 TOTALSPENDING AS 
 (
 SELECT [Name],
 SUM(SALES) AS TOTALSALES
 FROM AVE_COUSTOMER_SPENDING 
 GROUP BY [Name]
 )
 SELECT [Name],
 TOTALSALES 
 FROM TOTALSPENDING 
 WHERE  TOTALSALES  >
 (
 SELECT AVG(TOTALSALES)  
 FROM TOTALSPENDING
 ) 

 -- Calculate each customer’s revenue contribution percentage.
 WITH CUST_REV AS
(
    SELECT
        C.Name,
        P.Unit_Price_USD * S.Quantity AS Revenue
    FROM dbo.Customers AS C
    INNER JOIN dbo.Sales AS S
        ON C.CustomerKey = S.CustomerKey
    INNER JOIN dbo.Products AS P
        ON P.ProductKey = S.ProductKey
),
CUSTOMER_REVENUE AS
(
    SELECT
        Name,
        SUM(Revenue) AS TotalRevenue
    FROM CUST_REV
    GROUP BY Name
),
COMPANY_REVENUE AS
(
    SELECT
        SUM(TotalRevenue) AS CompanyRevenue
    FROM CUSTOMER_REVENUE
)
SELECT
CR.Name,
CR.TotalRevenue,
CAST(((CR.TotalRevenue * 100.0) / CP.CompanyRevenue) AS DECIMAL(10,2)) AS PercentageContribution
FROM CUSTOMER_REVENUE AS CR
CROSS JOIN COMPANY_REVENUE AS CP
ORDER BY PercentageContribution DESC

-- Find customers who purchased across multiple countries.
 WITH TRAVELSHOP AS
 (
 SELECT C.[Name],N.[Country],N.[StoreKey]
 FROM [dbo].[Products] AS P
 LEFT JOIN [dbo].[Sales] AS S
 ON S.[ProductKey] = P.[ProductKey]
 LEFT JOIN [dbo].[Customers] AS C
 ON C.[CustomerKey] = S.[CustomerKey]
 LEFT JOIN [dbo].[Stores] AS N
 ON N.[StoreKey] = S.[StoreKey]
 GROUP BY C.[Name],N.[Country],N.[StoreKey] 
 )
 SELECT [Name],
 COUNT(Country) AS COUNTRIESPURCHASED FROM TRAVELSHOP
 GROUP BY [Name]
 HAVING  COUNT(Country) > 1

