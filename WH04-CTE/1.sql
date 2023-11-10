SELECT P.PersonID, P.FullName FROM Application.People P
                              WHERE IsSalesperson = 1


SELECT DISTINCT I.SalespersonPersonID FROM Sales.Invoices I WHERE I.InvoiceDate BETWEEN '2015-04-01' AND '2015-04-30' AND I.ConfirmedDeliveryTime IS NOT NULL

AND
                                    (SELECT COUNT(I.InvoiceID)
                                     FROM Sales.Invoices I
                                     WHERE SalespersonPersonID = P.PersonID
                                       AND I.InvoiceDate BETWEEN '2015-04-01' AND '2015-04-30'
                                     GROUP BY SalespersonPersonID) > 0