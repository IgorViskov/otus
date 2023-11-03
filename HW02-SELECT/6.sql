SELECT DISTINCT C.[CustomerID], [CustomerName], [PhoneNumber] FROM [WideWorldImporters].[Sales].[Customers] C
INNER JOIN [WideWorldImporters].[Sales].[Orders] O ON O.[CustomerID] = C.[CustomerID]
INNER JOIN [WideWorldImporters].[Sales].[OrderLines] OL ON O.[OrderID] = OL.[OrderID]
INNER JOIN [WideWorldImporters].Warehouse.StockItems SI ON OL.StockItemID = SI.StockItemID
WHERE SI.[StockItemName] = 'Chocolate frogs 250g'
ORDER BY C.[CustomerID]