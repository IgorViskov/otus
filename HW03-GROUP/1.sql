SELECT FORMAT(DATEFROMPARTS(YEAR(O.OrderDate), MONTH(O.OrderDate), 1) , 'MMMM yyyy', 'ru-RU') AS Date,
       SUM(OL.UnitPrice * OL.Quantity) AS Total, AVG(OL.UnitPrice) AS Average
FROM Sales.Orders O
LEFT JOIN Sales.OrderLines OL on O.OrderID = OL.OrderID
GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY YEAR(O.OrderDate), MONTH(O.OrderDate)