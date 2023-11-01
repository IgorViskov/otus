SELECT DISTINCT C.[CustomerID], [CustomerName], [PhoneNumber] FROM [WideWorldImporters].[Sales].[Customers] C
INNER JOIN [WideWorldImporters].[Sales].[Orders] O ON O.[CustomerID] = C.[CustomerID]
INNER JOIN [WideWorldImporters].[Sales].[OrderLines] OL ON O.[OrderID] = OL.[OrderID]
WHERE OL.[Description] = 'Chocolate frogs 250g'
ORDER BY C.[CustomerID]