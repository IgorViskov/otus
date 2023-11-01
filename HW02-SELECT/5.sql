SELECT TOP(10) O.*, C.[CustomerName], AP.[FullName] as SalespersonName FROM [WideWorldImporters].[Sales].[Orders] O
INNER JOIN [WideWorldImporters].[Sales].[Customers] C on C.[CustomerID] = O.[CustomerID]
INNER JOIN [WideWorldImporters].[Application].[People] AP ON O.[SalespersonPersonID] = AP.[PersonID]
ORDER BY O.[OrderDate] DESC