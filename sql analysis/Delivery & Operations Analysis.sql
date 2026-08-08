-- Calculate delivery days for each order.
 SELECT [Order_Number],  
 DATEDIFF(DAY, [Order_Date], [Delivery_Date]) AS DELIVERYDAYS,
 C.[Name]
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Customers] AS C 
 ON S.[CustomerKey] = C.[CustomerKey]
 WHERE [Order_Date] IS NOT NULL AND [Delivery_Date] IS NOT NULL

 -- Calculate average delivery days by country.
  SELECT [Country],  
 AVG(DATEDIFF(DAY, [Order_Date], [Delivery_Date])) AS DELIVERYDAYS
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Customers] AS C 
 ON S.[CustomerKey] = C.[CustomerKey]
 GROUP BY [Country]

 -- Find stores with the fastest average delivery time.
  WITH FASTESTDELIVERYTIME AS 
 (
 SELECT [Order_Number],
 N.[StoreKey], N.[Country], N.[State],
 DATEDIFF(DAY, S.[Order_Date],  S.[Delivery_Date]) AS DELIVERYDAYS
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Stores] AS N
 ON N.[StoreKey] = S.[StoreKey]
 WHERE S.[Order_Date] IS NOT NULL AND 
 S.[Delivery_Date] IS NOT NULL
 )
 SELECT [StoreKey], [Country], [State],
 COUNT([Order_Number]) AS TOTALORDERS,
 AVG(CAST(DeliveryDays AS DECIMAL(10,2))) AS AvgDeliveryDays
 FROM  FASTESTDELIVERYTIME
 GROUP BY [StoreKey], [Country], [State]
 ORDER BY  AVGDELIVERYDAYS 

 -- Find the top 5 stores with the slowest delivery time.
 WITH FASTESTDELIVERYTIME AS 
 (
 SELECT [Order_Number],
 N.[StoreKey], N.[Country], N.[State],
 DATEDIFF(DAY, S.[Order_Date],  S.[Delivery_Date]) AS DELIVERYDAYS
 FROM [dbo].[Sales] AS S
 INNER JOIN [dbo].[Stores] AS N
 ON N.[StoreKey] = S.[StoreKey]
 WHERE S.[Order_Date] IS NOT NULL AND 
 S.[Delivery_Date] IS NOT NULL
 )
 SELECT TOP 5  [StoreKey], [Country], [State],
 AVG(CAST(DeliveryDays AS DECIMAL(10,2))) AS AvgDeliveryDays
 FROM  FASTESTDELIVERYTIME
 GROUP BY [StoreKey], [Country], [State]
 ORDER BY  AVGDELIVERYDAYS 