SELECT DISTINCT O.* FROM [WideWorldImporters].[Sales].[Orders] O
INNER JOIN [WideWorldImporters].[Sales].[OrderLines] OL ON O.[OrderID] = OL.[OrderID]
WHERE (OL.[UnitPrice] > 100 OR OL.[Quantity] > 20) AND O.[PickingCompletedWhen] IS NOT NULL
