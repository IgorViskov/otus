SELECT PO.* FROM [WideWorldImporters].[Purchasing].[PurchaseOrders] PO
INNER JOIN [WideWorldImporters].[Application].[DeliveryMethods] DM ON PO.[DeliveryMethodID] = DM.[DeliveryMethodID]
WHERE [ExpectedDeliveryDate] BETWEEN '01-01-2013' AND '01-31-2013 23:59:59'
  AND DM.[DeliveryMethodName] IN ('Air Freight', 'Refrigerated Air Freight')
  AND [IsOrderFinalized] = 1