-- Harus urut!!!
CALL pCheckoutTrans('O24112501', 'Transfer');
SELECT * FROM SALES;

SELECT * FROM vSalesToday;

SELECT * FROM vBestCustomers;

SELECT * FROM vPendingOrder;

SELECT * FROM vProdProfit;

CALL pSubmitReview('ASE01', 'S06122501', 5, 'ENAKK!');
SELECT * FROM feedback;

SET @parID = null;
CALL pOrderGenID('2025-11-28', @parID);
SELECT @parID;

SELECT fLiveStock('P0002');

SELECT fEstCartTotal('O12112501');

SELECT fGenCustID('Asep Widjaja');

-- Check Stock
INSERT INTO Sales_List (Product_ID, Sales_ID, Quantity, Total_Price)
    VALUES ('P0001', 'S12112501', 100, 0);

-- Rating 1-5 saja
INSERT INTO Feedback (Feedback_ID, Sales_ID, Customer_ID, Feedback_comment, Rating, status_del)
VALUES ('FTESTT01', 'S12112501', 'BUD01', 'terlalu enak wkewkwek!', 6, 0);
SELECT * FROM Feedback WHERE Feedback_ID = 'FTESTT01';

-- Auto hitung Total_Price
INSERT INTO Sales_List (Product_ID, Sales_ID, Quantity, Total_Price)
VALUES ('P0002', 'S12112501', 2, 0);
SELECT * FROM Sales_List WHERE Sales_ID = 'S12112501' AND Product_ID = 'P0002';

-- Order Status utk Checkout
SELECT * FROM orders;