DECLARE @start AS date = (SELECT TOP(1)  DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) FROM Sales.Orders ORDER BY Sales.Orders.OrderDate)
DECLARE @end AS date = (SELECT TOP(1) DATEADD(day, -1, DATEADD(month, 1, DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1))) FROM Sales.Orders ORDER BY Sales.Orders.OrderDate DESC)

;WITH months (date)
AS
(
    SELECT @start
    UNION ALL
    SELECT DATEADD(month, 1, date)
    FROM months
    WHERE DATEADD(day, -1, DATEADD(month, 1, DATEFROMPARTS(YEAR(date), MONTH(date), 1))) < @end
)

SELECT date, items.StockItemName, COALESCE(items.Quantity, 0) AS Quantity FROM months
OUTER APPLY (
    SELECT SI.StockItemID, SI.StockItemName, CTE.Quantity FROM Warehouse.StockItems SI
    LEFT JOIN (SELECT OL.StockItemID, SUM(OL.Quantity) AS Quantity FROM Sales.OrderLines OL INNER JOIN Sales.Orders O ON O.OrderID = OL.OrderID
                              WHERE O.OrderDate BETWEEN date AND DATEADD(day, -1, DATEADD(month, 1, date))
                              GROUP BY OL.StockItemID
                              ) CTE ON SI.StockItemID = CTE.StockItemID
) AS items
WHERE COALESCE(items.Quantity, 0) < 50
ORDER BY date
