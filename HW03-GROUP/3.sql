SELECT FORMAT(DATEFROMPARTS(YEAR(O.OrderDate), MONTH(O.OrderDate), 1) , 'MMMM yyyy', 'ru-RU') AS Date,
       SI.StockItemName,
       SUM(OL.UnitPrice * OL.Quantity) AS Total,
       SUM(OL.Quantity) AS Quantity,
       MIN(O.OrderDate) AS FirstSellDate
FROM Sales.Orders O
LEFT JOIN Sales.OrderLines OL on O.OrderID = OL.OrderID
LEFT JOIN [WideWorldImporters].Warehouse.StockItems SI ON OL.StockItemID = SI.StockItemID
GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate), SI.StockItemName
HAVING SUM(OL.Quantity) < 50
ORDER BY YEAR(O.OrderDate), MONTH(O.OrderDate), SI.StockItemName