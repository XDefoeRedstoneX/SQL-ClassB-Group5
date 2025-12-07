-- harus urut
use kajjabase;

-- Register a new customer
CALL pRegisterCustomer('Zahck Snyder', 'zack@mail.com', 'pass123', '0811223344');
SELECT * FROM customers;
-- Added 'ZAH01'

-- Update Profile (Email)
CALL pUpdateProfile('ZAH01', 'realzack@mail.com', '0811223344');
SELECT * FROM customers;
-- New email 'realzack@mail.com'

-- Add New Product
CALL pAddNewProduct('Spicy BapBap (SUPER)', 40000);
SELECT * FROM products;
-- Added 'P0005'

-- Record Production
CALL pRecordProduction('P0005', 30, 15000);
SELECT * FROM production;
-- Added New 'PR...'

-- Record Waste
CALL pRecordWaste(CONCAT('PR', DATE_FORMAT(CURDATE(), '%d%m%y'),'01'),5);
SELECT * FROM waste;
-- Added New 'W...'


-- Generate ID for Order
SET @futureID = null;
CALL pOrderGenID('2026-01-01', @futureID);
SELECT @futureID;

-- Create New Order

CALL pCreateOrder('ZAH01');
SELECT * FROM customers;
-- Added New 'O....'

-- Add Items
CALL pAddItemToOrder(CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01'), 'P0005', 2);
CALL pAddItemToOrder(CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01'), 'P0001', 1);
SELECT * FROM order_list WHERE Orders_ID = CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01');

-- Remove Item
CALL pRemoveItemFromOrder(CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01'), 'P0001');
SELECT * FROM order_list WHERE Orders_ID = CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01');

-- Check Cart Total
SELECT fEstCartTotal(CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01'));

-- Pending Orders (Order_Status = 0)
SELECT * FROM vPendingOrder;

-- Manual Status Update (1 = to Deliver)
CALL pUpdateStatus(CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01'), 1);
SELECT * FROM Orders WHERE Orders_ID = CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01');

-- Pay for Order
CALL pCheckoutTrans(CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01'), 'Transfer');
SELECT * FROM Orders WHERE Orders_ID = CONCAT('O', DATE_FORMAT(CURDATE(), '%d%m%y'),'01');
SELECT * FROM Sales;

-- Submit Review
CALL pSubmitReview('ZAH01', CONCAT('S', DATE_FORMAT(CURDATE(), '%d%m%y'),'01'), 5, 'enaeeaeaenaeak!');
SELECT * FROM feedback;

-- Check Customer History
CALL pGetCustomerHistory('ZAH01');

-- Check Average Rating
SELECT fGetAvgRating('P0005');

-- Check Profit Margin
SELECT fGetProductMargin('P0005');

-- Check Waste Ratio (Percentage)
SELECT fGetWasteRatio('P0005');

-- Format Currency
SELECT fFormatCurrency(80000);

-- Sales Today
SELECT * FROM vSalesToday;

-- Best Customers
SELECT * FROM vBestCustomers;

-- Pending Orders (Order_Status = 0)
SELECT * FROM vPendingOrder;

-- Real Profitability (From Production Cost & Waste)
SELECT * FROM vProdProfit;

-- Low Stock Alert (< 10)
SELECT * FROM vLowStockAlert;

-- Top Selling Products
SELECT * FROM vTopSellingProducts;

-- Prevent Future Date
INSERT INTO Orders (Orders_ID, Customer_ID, Date_In, Order_Status, Order_For_Date, status_del)
VALUES ('O9999', 'ZAC01', '2099-01-01', 0, '2099-01-01', 0);

-- Ensure Valid Email
INSERT INTO Customers (Customer_ID, Customer_Name, Cust_Email, Cust_Password, Cust_Number, status_del)
VALUES ('BAD01', 'Fake', 'email.com', 'pass', '000', 0);

-- Stock Check
INSERT INTO Sales_List (Product_ID, Sales_ID, Quantity, Total_Price)
VALUES ('P0005', 'S07122501', 1000, 0);

-- Prevent Delete Active Customer (Has Unfinished Orders)
CALL pCreateOrder('ZAH01');
UPDATE Customers SET status_del = 1 WHERE Customer_ID = 'ZAH01';
