SELECT FORMAT(DATEFROMPARTS(YEAR(O.OrderDate), MONTH(O.OrderDate), 1) , 'MMMM yyyy', 'ru-RU') AS Date,
       Total = SUM(OL.UnitPrice * OL.Quantity)
FROM Sales.Orders O
LEFT JOIN Sales.OrderLines OL on O.OrderID = OL.OrderID
GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
HAVING SUM(OL.UnitPrice * OL.Quantity) > 4600000
ORDER BY YEAR(O.OrderDate), MONTH(O.OrderDate)