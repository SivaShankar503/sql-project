-- Calculate total sales revenue in USD.
SELECT SUM([Unit_Price_USD] * S.Quantity)  
AS TOTASALESUSD
FROM [dbo].[Products] AS P
INNER JOIN [dbo].[Sales] AS S 
ON P.[ProductKey] = S.[ProductKey]

-- Calculate sales in each order’s local currency.
SELECT S.[Order_Number], S.[Currency_Code],
SUM(([Unit_Price_USD] * [Quantity])  * [Exchange]) AS LOCAL_SALES
FROM [dbo].[Products] AS P
INNER JOIN [dbo].[Sales] AS S
ON P.[ProductKey] = S.[ProductKey]
INNER JOIN [dbo].[Exchange_Rates] AS E
ON S.[Order_Date] = E.[Date]
AND S.[Currency_Code] = E.[Currency]
GROUP BY S.[Order_Number], S.[Currency_Code]

-- Display USD sales and local sales for each order.
 SELECT [Order_Number],
 SUM([Unit_Price_USD] * [Quantity]) AS SALESUSD,
 SUM(([Unit_Price_USD] * [Quantity])  * [Exchange]) AS LOCAL_SALES
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Products] AS P 
 ON S.[ProductKey] = P.[ProductKey]
 INNER JOIN [dbo].[Exchange_Rates] AS E
 ON S.[Order_Date] = E.[Date]
 AND S.[Currency_Code] = E.[Currency]
 GROUP BY [Order_Number]

 -- Convert each order’s local amount to USD.
  WITH AMTUSD AS
 (
 SELECT S.[Order_Number], E.[Exchange],
 P.[Unit_Price_USD] * [Quantity] AS SALESAMT
 FROM  [dbo].[Sales] AS S
 LEFT JOIN [dbo].[Exchange_Rates]  AS  E
 ON S.[Currency_Code]  = E.[Currency]
 LEFT JOIN [dbo].[Products] AS P
 ON P.[ProductKey] =  S.[ProductKey]
 ),
 SALESAMT AS 
 (
 SELECT [Order_Number],[Exchange], 
 SUM(SALESAMT) AS LOCALCURRENCYAMT
 FROM AMTUSD
 GROUP BY [Order_Number],[Exchange]
 )
 SELECT [Order_Number],
 LOCALCURRENCYAMT / [Exchange] AS USDAMT
 FROM  SALESAMT

 -- Calculate monthly sales revenue by country.
  WITH MONTHLYSALES AS
 (
 SELECT C.[Country],S.[Order_Date],
 YEAR([Order_Date]) AS YEAR,
 MONTH([Order_Date]) AS MONTH,
 [Unit_Price_USD] * [Quantity] AS TOTALREVENUE
 FROM [dbo].[Sales] AS S
 LEFT JOIN [dbo].[Customers] AS C
 ON C.[CustomerKey] = S.[CustomerKey]
 LEFT JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 WHERE S.[Order_Date] IS NOT NULL
 )
 SELECT [Country], YEAR, MONTH, 
 SUM(TOTALREVENUE) AS SALESUSD
 FROM MONTHLYSALES
 GROUP BY [Country], YEAR, MONTH

 -- Calculate revenue, cost, profit, margin, and local revenue by country.
 WITH CountrySales AS
(
    SELECT
        C.Country,
        P.Unit_Price_USD * S.Quantity AS RevenueUSD,
        P.Unit_Cost_USD * S.Quantity AS CostUSD,
        P.Unit_Price_USD * S.Quantity * E.Exchange AS RevenueLocalCurrency
    FROM dbo.Sales AS S
    INNER JOIN dbo.Customers AS C
        ON C.CustomerKey = S.CustomerKey
    INNER JOIN dbo.Products AS P
        ON P.ProductKey = S.ProductKey
    INNER JOIN dbo.Exchange_Rates AS E
        ON E.Currency = S.Currency_Code
)
SELECT
    Country,
    SUM(RevenueUSD) AS RevenueUSD,
    SUM(CostUSD) AS CostUSD,
    SUM(RevenueUSD) - SUM(CostUSD) AS ProfitUSD,
    ROUND(
        ((SUM(RevenueUSD) - SUM(CostUSD)) * 100.0) /
        NULLIF(SUM(RevenueUSD), 0),
        2
    ) AS PercentageUSD,
    SUM(RevenueLocalCurrency) AS RevenueLocalCurrency
FROM CountrySales
GROUP BY Country
ORDER BY PercentageUSD DESC

-- Display order revenue in USD and local currency.

WITH CAL_REVENUE AS
(
SELECT S.[Order_Number], 
C.[Name] , S.[Currency_Code],
[Unit_Price_USD] * [Quantity] AS REVENUE,
([Unit_Price_USD] * [Quantity])  * [Exchange] AS REVENUELOCAL
FROM [dbo].[Sales] AS S
LEFT JOIN [dbo].[Customers] AS C
ON C.[CustomerKey] = S.[CustomerKey]
LEFT JOIN [dbo].[Products] AS P
ON P.[ProductKey] = S.[ProductKey] 
LEFT JOIN [dbo].[Exchange_Rates] AS E
ON E.[Currency] = S.[Currency_Code]
)
SELECT [Order_Number], [Name],[Currency_Code],
SUM(REVENUE) AS REVENUE,
SUM(REVENUELOCAL) AS REVENUELOCAL
FROM CAL_REVENUE
GROUP BY [Order_Number], [Name],[Currency_Code]

-- Calculate average order value by country.
 WITH CTEORDER AS 
 (
 SELECT C.[Country],S.[Order_Number],
 (P.[Unit_Price_USD] * S.[Quantity]) AS ORDERVALUE
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Customers] AS C
 ON C.[CustomerKey] = S.[CustomerKey]
 INNER JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 ),
 ORDERVALUE AS
 (
 SELECT [Country], 
 SUM(ORDERVALUE) AS TOTALREVENUE,
 COUNT([Order_Number]) AS TOTALORDERS
 FROM CTEORDER
 GROUP BY [Country] 
 )
 SELECT [Country],
 AVG(TOTALREVENUE /  TOTALORDERS) AS AVGORDERVALE
 FROM ORDERVALUE
 GROUP BY [Country]

 -- Calculate yearly revenue by product category.
  WITH PRODUCTCAT AS
 (
 SELECT P.[Category], S.[Order_Date],
 P.[Unit_Price_USD] * S.[Quantity] AS REVENUE
 FROM  [dbo].[Sales] AS S
 INNER JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 )
 SELECT [Category], [Order_Date],
 DATEPART(YYYY, [Order_Date]) AS YEARLY,
 SUM(REVENUE) AS REVENUE
 FROM PRODUCTCAT
 GROUP BY  [Category],[Order_Date] 

 -- Calculate monthly revenue by product brand.
  WITH PRODUCTBRAND AS
 (
 SELECT S.[Order_Date], P.[Brand],
 P.[Unit_Price_USD] * S.[Quantity] AS REVENUE
 FROM  [dbo].[Sales] AS S
 INNER JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 )
 SELECT [Order_Date], DATEPART(YYYY, [Order_Date]) AS SALESYEAR,
 DATENAME(MONTH, [Order_Date]) AS MONTHLYSALES,
 [Brand],
 SUM(REVENUE) AS REVENUE
 FROM PRODUCTBRAND  
 GROUP BY  [Brand], [Order_Date]

 -- Calculate monthly and cumulative revenue.

  WITH RUNNINGEVENUE AS
 (
 SELECT S.[Order_Date],
 P.[Unit_Price_USD] * S.[Quantity] AS REVENUE
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 WHERE S.Order_Date IS NOT NULL
 )
 SELECT [Order_Date],
 DATEPART(YYYY, [Order_Date]) AS SALESYEAR,
 DATENAME(MONTH, [Order_Date]) AS MONHTLYSALES,
 SUM(REVENUE) AS DAILYREVENUE,
 SUM(SUM(Revenue)) OVER (ORDER BY Order_Date ROWS UNBOUNDED PRECEDING) AS RunningRevenue
 FROM RUNNINGEVENUE
 GROUP BY  [Order_Date], 
 DATEPART(YYYY, [Order_Date]),
 DATENAME(MONTH, [Order_Date])

 -- Calculate monthly revenue and month-over-month growth.

  WITH REVENUEMONTH AS
 (
 SELECT [Order_Date],
 YEAR([Order_Date]) AS SALESYEAR,
 MONTH([Order_Date]) AS SALESMONTH,
 SUM(P.[Unit_Price_USD] * [Quantity]) AS REVENUE
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Products] AS P
 ON P.[ProductKey] = S.[ProductKey]
 WHERE S.Order_Date IS NOT NULL
 GROUP BY  [Order_Date], YEAR([Order_Date]), MONTH([Order_Date])
 )
 SELECT 
 SALESYEAR,
 SALESMONTH,
 REVENUE,
 LAG(REVENUE) OVER (ORDER BY SALESMONTH DESC) AS PREVIOUSMONTH,
 REVENUE -  LAG(REVENUE) OVER (ORDER BY SALESMONTH DESC) AS MOMGROWTH
 FROM REVENUEMONTH  

 -- Calculate overall company sales and business KPIs.
 WITH TOTALREV AS
(
    SELECT
        S.Order_Number,
        S.CustomerKey,
        S.Quantity,
        E.[Exchange],
        (P.Unit_Price_USD * S.Quantity) AS TotalRevenueUSD,
        (P.Unit_Cost_USD * S.Quantity) AS TotalCostUSD,
        (P.Unit_Price_USD * S.Quantity * E.[Exchange]) AS TotalRevenueLocalCurrency
    FROM dbo.Sales AS S
    INNER JOIN dbo.Products AS P
        ON P.ProductKey = S.ProductKey
    INNER JOIN dbo.Exchange_Rates AS E
        ON E.Currency = S.Currency_Code
)
SELECT
    SUM(TotalRevenueUSD) AS TotalRevenueUSD,
    SUM(TotalCostUSD) AS TotalCostUSD,
    SUM(TotalRevenueUSD) - SUM(TotalCostUSD) AS TotalProfitUSD,
    ((SUM(TotalRevenueUSD) - SUM(TotalCostUSD))
        / SUM(TotalRevenueUSD)) * 100 AS ProfitPercentage,
    COUNT(DISTINCT Order_Number) AS TotalOrders,
    COUNT(DISTINCT CustomerKey) AS TotalCustomers,
    SUM(Quantity) AS TotalProductsSold,
    AVG(TotalRevenueUSD) / COUNT(DISTINCT Order_Number)
        AS AverageOrderValueUSD,
    SUM(TotalRevenueLocalCurrency)
        AS TotalRevenueLocalCurrency
FROM TOTALREV

