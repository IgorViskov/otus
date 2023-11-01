SELECT S.[SupplierName] FROM [WideWorldImporters].[Purchasing].[Suppliers] S
LEFT JOIN [WideWorldImporters].[Purchasing].[PurchaseOrders] PO on S.[SupplierID] = PO.[SupplierID]
GROUP BY S.[SupplierName]
HAVING COUNT(PO.[PurchaseOrderID]) = 0