/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT year(I.InvoiceDate) as Year,
       month(I.InvoiceDate) as Month,
       AVG(IL.UnitPrice) AS Average,
       SUM(IL.UnitPrice * IL.Quantity) AS Total
FROM Sales.Invoices I
LEFT JOIN Sales.InvoiceLines IL on I.InvoiceID = IL.InvoiceID
WHERE ConfirmedDeliveryTime is not null
GROUP BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
ORDER BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT year(I.InvoiceDate) as Year,
       month(I.InvoiceDate) as Month,
       Total = SUM(COALESCE(IL.UnitPrice, 0) * COALESCE(IL.Quantity, 0))
FROM Sales.Invoices I
LEFT JOIN Sales.InvoiceLines IL on I.InvoiceID = IL.InvoiceID
GROUP BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)
HAVING SUM(COALESCE(IL.UnitPrice, 0) * COALESCE(IL.Quantity, 0)) > 4600000
ORDER BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate)

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

DECLARE @start AS date = (SELECT TOP(1) datetrunc(month, Sales.Invoices.InvoiceDate) FROM Sales.Invoices ORDER BY Sales.Invoices.InvoiceDate)
DECLARE @end AS date = (SELECT TOP(1) eomonth(InvoiceDate) FROM Sales.Invoices ORDER BY Sales.Invoices.InvoiceDate DESC)

;WITH months (date)
AS
(
    SELECT @start
    UNION ALL
    SELECT DATEADD(month, 1, date)
    FROM months
    WHERE DATEADD(day, -1, DATEADD(month, 1, DATEFROMPARTS(YEAR(date), MONTH(date), 1))) < @end
)

SELECT year(date) as Year, month(date) as Month, items.StockItemName, COALESCE(items.Total, 0) as Total, items.FirstSaleDate, COALESCE(items.Quantity, 0) AS Quantity FROM months
OUTER APPLY (
    SELECT SI.StockItemID, SI.StockItemName, items.Quantity, items.Total, items.FirstSaleDate FROM Warehouse.StockItems SI
    LEFT JOIN (SELECT IL.StockItemID, SUM(IL.Quantity) AS Quantity, SUM(IL.Quantity * Il.UnitPrice) as Total, MIN(I.InvoiceDate) as FirstSaleDate FROM Sales.InvoiceLines IL INNER JOIN Sales.Invoices I ON I.InvoiceID = IL.InvoiceID
                              WHERE I.InvoiceDate BETWEEN date AND eomonth(date)
                              GROUP BY IL.StockItemID
                              ) items ON SI.StockItemID = items.StockItemID
) AS items
WHERE COALESCE(items.Quantity, 0) < 50
ORDER BY date

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/
