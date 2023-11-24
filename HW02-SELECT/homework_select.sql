/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT SI.StockItemID, SI.StockItemName FROM [Warehouse].[StockItems] SI
         WHERE [StockItemName] LIKE '%urgent%' OR [StockItemName] LIKE 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/
SELECT S.SupplierID, S.[SupplierName] FROM [Purchasing].[Suppliers] S
LEFT JOIN [Purchasing].[PurchaseOrders] PO on S.[SupplierID] = PO.[SupplierID]
GROUP BY S.SupplierID, S.[SupplierName]
HAVING COUNT(PO.[PurchaseOrderID]) = 0

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
DECLARE
    @pagesize BIGINT = 100, -- Размер страницы
    @pagenum  BIGINT = 11;  -- Номер страницы

SELECT DISTINCT O.OrderID, O.OrderDate, format(O.OrderDate, 'MMMM', 'ru-ru') as [Month],
                DATEPART(quarter, O.OrderDate) as Quarter,
                CASE
                    WHEN (month(O.OrderDate) % 4) = 0 THEN month(O.OrderDate) / 4
                    WHEN (month(O.OrderDate) % 4) != 0 THEN month(O.OrderDate) / 4 + 1
                END as Triple,
                C.CustomerName
FROM [Sales].[Orders] O
INNER JOIN [Sales].[OrderLines] OL ON O.[OrderID] = OL.[OrderID]
INNER JOIN Sales.Customers C on C.CustomerID = O.CustomerID
WHERE (OL.[UnitPrice] > 100 OR OL.[Quantity] > 20) AND O.[PickingCompletedWhen] IS NOT NULL
ORDER BY Quarter, Triple, O.OrderDate
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT DeliveryMethodName, PO.ExpectedDeliveryDate, S.SupplierName, P.FullName as ContactPerson FROM [Purchasing].[PurchaseOrders] PO
INNER JOIN [Application].[DeliveryMethods] DM ON PO.[DeliveryMethodID] = DM.[DeliveryMethodID]
INNER JOIN [Purchasing].[Suppliers] S ON PO.[SupplierID] = S.[SupplierID]
INNER JOIN [Application].[People] P ON PO.[ContactPersonID] = P.[PersonID]
WHERE [ExpectedDeliveryDate] BETWEEN '01-01-2013' AND '01-31-2013'
  AND DM.[DeliveryMethodName] IN ('Air Freight', 'Refrigerated Air Freight')
  AND [IsOrderFinalized] = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP(10) WITH TIES O.*, C.[CustomerName], AP.[FullName] as SalespersonName FROM [WideWorldImporters].[Sales].[Orders] O
INNER JOIN [WideWorldImporters].[Sales].[Customers] C on C.[CustomerID] = O.[CustomerID]
INNER JOIN [WideWorldImporters].[Application].[People] AP ON O.[SalespersonPersonID] = AP.[PersonID]
ORDER BY O.[OrderDate] DESC

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT DISTINCT C.[CustomerID], [CustomerName], [PhoneNumber] FROM [WideWorldImporters].[Sales].[Customers] C
INNER JOIN [WideWorldImporters].[Sales].[Orders] O ON O.[CustomerID] = C.[CustomerID]
INNER JOIN [WideWorldImporters].[Sales].[OrderLines] OL ON O.[OrderID] = OL.[OrderID]
INNER JOIN [WideWorldImporters].Warehouse.StockItems SI ON OL.StockItemID = SI.StockItemID
WHERE SI.[StockItemName] = 'Chocolate frogs 250g'
ORDER BY C.[CustomerID]
