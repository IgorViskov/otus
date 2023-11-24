/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT P.PersonID, P.FullName FROM Application.People P WHERE IsSalesperson = 1 AND (SELECT count(1) FROM Sales.Invoices I WHERE P.PersonID = I.SalespersonPersonID AND I.InvoiceDate = '2015-07-04') = 0

;WITH cte AS (
    SELECT count(*) as Count, I.SalespersonPersonID FROM Sales.Invoices I WHERE I.InvoiceDate = '2015-07-04' group by I.SalespersonPersonID
    )

SELECT P.PersonID, P.FullName FROM Application.People P
LEFT JOIN cte ON P.PersonID = cte.SalespersonPersonID
WHERE IsSalesperson = 1 AND COALESCE(cte.Count, 0) = 0

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

SELECT SI.StockItemID, SI.StockItemName, SI.UnitPrice FROM Warehouse.StockItems SI WHERE SI.UnitPrice = (SELECT min(SI2.UnitPrice) FROM Warehouse.StockItems SI2)

;WITH cte AS (
    SELECT min(SI2.UnitPrice) AS MinPrice FROM Warehouse.StockItems SI2
)

SELECT SI.StockItemID, SI.StockItemName, SI.UnitPrice FROM Warehouse.StockItems SI, cte WHERE SI.UnitPrice = cte.MinPrice

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

SELECT * FROM Sales.Customers WHERE CustomerID IN (SELECT TOP 5 WITH TIES CustomerID FROM Sales.CustomerTransactions CT ORDER BY TransactionAmount DESC)

;WITH cte AS (
    SELECT TOP 5 WITH TIES CustomerID FROM Sales.CustomerTransactions CT ORDER BY TransactionAmount DESC
)

SELECT * FROM Sales.Customers C, cte WHERE C.CustomerID IN (cte.CustomerID)


/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/
SELECT CT.CityID, CT.CityName, P.FullName FROM Sales.Invoices I
INNER JOIN Sales.Customers C on C.CustomerID = I.CustomerID
INNER JOIN Application.Cities CT ON C.DeliveryCityID = CT.CityID
INNER JOIN Sales.InvoiceLines IL on I.InvoiceID = IL.InvoiceID
INNER JOIN Application.People P ON I.PackedByPersonID = P.PersonID
WHERE I.ConfirmedDeliveryTime IS NOT NULL AND IL.StockItemID IN (SELECT TOP 3 WITH TIES IL.StockItemID FROM (SELECT IL.StockItemID, MAX(IL.UnitPrice) as UnitPrice FROM Sales.InvoiceLines IL GROUP BY IL.StockItemID, IL.Description) IL
                         ORDER BY IL.UnitPrice DESC)
GROUP BY CT.CityID, CT.CityName, P.FullName
ORDER BY CityName, FullName



;WITH cte AS ( SELECT TOP 3 WITH TIES StockItemID FROM (SELECT IL.StockItemID, MAX(IL.UnitPrice) as UnitPrice FROM Sales.InvoiceLines IL GROUP BY IL.StockItemID, IL.Description) IL
                         ORDER BY IL.UnitPrice DESC)

SELECT CT.CityID, CT.CityName, P.FullName FROM Sales.Invoices I
INNER JOIN Sales.Customers C on C.CustomerID = I.CustomerID
INNER JOIN Application.Cities CT ON C.DeliveryCityID = CT.CityID
INNER JOIN Sales.InvoiceLines IL on I.InvoiceID = IL.InvoiceID
INNER JOIN Application.People P ON I.PackedByPersonID = P.PersonID
WHERE I.ConfirmedDeliveryTime IS NOT NULL AND IL.StockItemID IN ( SELECT cte.StockItemID FROM cte)
GROUP BY CT.CityID, CT.CityName, P.FullName
ORDER BY CityName, FullName

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
-- Ищем все заказы (Id, дата) на сумму больше 27000, того кто эти заказы продал, и сумму на которую случалась отправка(?)
-- (PickedQuantity - не представляю что это)


;WITH SalesTotals AS (
    SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000
), TotalSummForPickedItems AS (
    SELECT O.OrderId, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) AS Summ
		FROM Sales.OrderLines
		INNER JOIN Sales.Orders O on Sales.OrderLines.OrderID = O.OrderID
		WHERE O.PickingCompletedWhen IS NOT NULL
		GROUP BY O.OrderId
)

SELECT
	Invoices.InvoiceID,
	Invoices.InvoiceDate,
	People.FullName AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice,
	TotalSummForPickedItems.Summ AS TotalSummForPickedItems
FROM Sales.Invoices
	JOIN SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceID
    LEFT JOIN Application.People ON Invoices.SalespersonPersonID = People.PersonID
    LEFT JOIN Sales.Orders ON Orders.OrderId = Invoices.OrderId AND Orders.PickingCompletedWhen IS NOT NULL
    LEFT JOIN TotalSummForPickedItems ON Orders.OrderId = TotalSummForPickedItems.OrderID
ORDER BY TotalSumm DESC

