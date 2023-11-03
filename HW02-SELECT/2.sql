SELECT * FROM [WideWorldImporters].[Purchasing].[Suppliers] S WHERE SupplierID IN (
SELECT S.[SupplierID] FROM [WideWorldImporters].[Purchasing].[Suppliers] S
LEFT JOIN [WideWorldImporters].[Purchasing].[PurchaseOrders] PO on S.[SupplierID] = PO.[SupplierID]
GROUP BY S.[SupplierID]
HAVING COUNT(PO.[PurchaseOrderID]) = 0)