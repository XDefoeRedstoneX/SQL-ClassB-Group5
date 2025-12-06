
DROP DATABASE IF EXISTS kajjabase;
CREATE DATABASE kajjabase;
USE kajjabase;

CREATE TABLE Customers (
    Customer_ID VARCHAR(10) PRIMARY KEY,
    Customer_Name VARCHAR(50) NOT NULL,
    Cust_Email VARCHAR(50) NOT NULL,
    Cust_Password VARCHAR(255) NOT NULL,
    Cust_Number VARCHAR(20) NOT NULL,
    status_del INT DEFAULT 0
);

CREATE TABLE Products (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Product_Name VARCHAR(50) NOT NULL,
    Sell_Price DECIMAL(12, 2),
    status_del INT DEFAULT 0
);

CREATE TABLE Orders (
    Orders_ID VARCHAR(10) PRIMARY KEY,
    Customer_ID VARCHAR(10),
    Date_In DATE,
    Order_Status INT DEFAULT 0,
    Order_For_Date DATE,
    status_del INT DEFAULT 0,
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
);

CREATE TABLE Order_List (
    Product_ID VARCHAR(10),
    Orders_ID VARCHAR(10),
    Quantity INT,
    Order_Date DATE,
    PRIMARY KEY (Product_ID, Orders_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Orders_ID) REFERENCES Orders(Orders_ID)
);

CREATE TABLE Sales (
    Sales_ID VARCHAR(10) PRIMARY KEY,
    Orders_ID VARCHAR(10),
    Date_Completed DATE,
    Payment VARCHAR(15),
    status_del INT DEFAULT 0,
    FOREIGN KEY (Orders_ID) REFERENCES Orders(Orders_ID)
);

CREATE TABLE Sales_List (
    Product_ID VARCHAR(10),
    Sales_ID VARCHAR(10),
    Quantity INT,
    Total_Price DECIMAL(12, 2),
    PRIMARY KEY (Product_ID, Sales_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Sales_ID) REFERENCES Sales(Sales_ID)
);

CREATE TABLE Production (
                            Production_ID VARCHAR(10) PRIMARY KEY,
                            Product_ID VARCHAR(5),
                            Date_In DATE,
                            Quantity INT,
                            Production_Cost DECIMAL(12, 2),
                            status_del INT DEFAULT 0,
                            FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

CREATE TABLE Waste (
    Waste_ID VARCHAR(10) PRIMARY KEY,
    Production_ID VARCHAR(10),
    Product_ID VARCHAR(10),
    Quantity INT,
    Price DECIMAL(12, 2),
    status_del INT DEFAULT 0,
    FOREIGN KEY (Production_ID) REFERENCES Production(Production_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);

CREATE TABLE Feedback (
    Feedback_ID VARCHAR(10) PRIMARY KEY,
    Sales_ID VARCHAR(10),       
    Customer_ID VARCHAR(10),
    feedback_comment TEXT,
    Rating INT,
    status_del INT DEFAULT 0,
    FOREIGN KEY (Sales_ID) REFERENCES Sales(Sales_ID), 
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
);

-- obejcts
CREATE OR REPLACE VIEW vSalesToday AS
SELECT
    s.Sales_ID,
    s.Date_Completed,
    SUM(sl.Total_Price) as Daily_Revenue
FROM Sales s
         JOIN Sales_List sl ON s.Sales_ID = sl.Sales_ID
WHERE s.Date_Completed = CURDATE()
GROUP BY s.Sales_ID, s.Date_Completed;


CREATE OR REPLACE VIEW vBestCustomers AS
SELECT
    c.Customer_Name,
    COUNT(DISTINCT s.Sales_ID) as Total_Transactions,
    SUM(sl.Total_Price) as Total_Value
FROM Customers c
         JOIN Orders o ON c.Customer_ID = o.Customer_ID
         JOIN Sales s ON o.Orders_ID = s.Orders_ID
         JOIN Sales_List sl ON s.Sales_ID = sl.Sales_ID
WHERE c.status_del = 0
GROUP BY c.Customer_ID, c.Customer_Name;

CREATE OR REPLACE VIEW vPendingOrder AS
SELECT
    o.Orders_ID,
    c.Customer_Name,
    o.Order_For_Date,
    o.Order_Status
FROM Orders o
         JOIN Customers c ON o.Customer_ID = c.Customer_ID
         LEFT JOIN Sales s ON o.Orders_ID = s.Orders_ID
WHERE s.Sales_ID IS NULL
  AND o.status_del = 0;


CREATE OR REPLACE VIEW vProdProfit AS
SELECT
    p.Product_Name,
    COALESCE(SUM(sl.Total_Price), 0) AS Revenue,
    (COALESCE(SUM(sl.Quantity), 0) * (SELECT AVG(Production_Cost) FROM Production pr WHERE pr.Product_ID = p.Product_ID)
        ) AS COGS,
    COALESCE(SUM(w.Price), 0) AS Waste,
    (
        COALESCE(SUM(sl.Total_Price), 0) -
        (COALESCE(SUM(sl.Quantity), 0) * (SELECT AVG(Production_Cost) FROM Production pr WHERE pr.Product_ID = p.Product_ID)) -
        COALESCE(SUM(w.Price), 0)
        ) AS Net_Profit

FROM Products p
         LEFT JOIN Sales_List sl ON p.Product_ID = sl.Product_ID
         LEFT JOIN Production pr ON p.Product_ID = pr.Product_ID
         LEFT JOIN Waste w ON pr.Production_ID = w.Production_ID
GROUP BY p.Product_ID, p.Product_Name;


DROP FUNCTION IF EXISTS fEstCartTotal;
DROP FUNCTION IF EXISTS fGenCustID;
DROP FUNCTION IF EXISTS fLiveStock;
DROP TRIGGER IF EXISTS tAutoPrice;
DROP TRIGGER IF EXISTS tCloseOrder;
DROP TRIGGER IF EXISTS tStockCheck;
DROP TRIGGER IF EXISTS fCheckRating;
DROP PROCEDURE IF EXISTS pCheckoutTrans;
DROP PROCEDURE IF EXISTS pSubmitReview;
DROP PROCEDURE IF EXISTS pOrderGenID;

DELIMITER //

CREATE FUNCTION fLiveStock(parProdID VARCHAR(10)) RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE v_Prod INT DEFAULT 0;
    DECLARE v_Sold INT DEFAULT 0;
    DECLARE v_Waste INT DEFAULT 0;

    SELECT COALESCE(SUM(Quantity),0) INTO v_Prod FROM Production WHERE Product_ID = parProdID;

    SELECT COALESCE(SUM(Quantity),0) INTO v_Sold FROM Sales_List WHERE Product_ID = parProdID;

    SELECT COALESCE(SUM(w.Quantity),0) INTO v_Waste
    FROM Waste w
             JOIN Production pr ON w.Production_ID = pr.Production_ID
    WHERE pr.Product_ID = parProdID;

    RETURN (v_Prod - v_Sold - v_Waste);
END //


CREATE FUNCTION fEstCartTotal(parOrderID VARCHAR(10)) RETURNS DECIMAL(12,2)
    DETERMINISTIC
BEGIN
    DECLARE v_Total DECIMAL(12,2);
    SELECT SUM(ol.Quantity * p.Sell_Price) INTO v_Total
    FROM Order_List ol
             JOIN Products p ON ol.Product_ID = p.Product_ID
    WHERE ol.Orders_ID = parOrderID;

    RETURN COALESCE(v_Total, 0.00);
END //

CREATE FUNCTION fGenCustID(parCustName VARCHAR(255)) RETURNS VARCHAR(10)
    DETERMINISTIC
BEGIN
    DECLARE v_Prefix VARCHAR(3);
    DECLARE v_Count INT;
    DECLARE v_Suffix VARCHAR(2);

    SET v_Prefix = UPPER(SUBSTRING(parCustName, 1, 3));

    SELECT COUNT(*) INTO v_Count
    FROM Customers
    WHERE Customer_ID LIKE CONCAT(v_Prefix, '%');

    SET v_Suffix = LPAD(v_Count + 1, 2, '0');

    RETURN CONCAT(v_Prefix, v_Suffix);
END //


CREATE TRIGGER tStockCheck
    BEFORE INSERT ON Sales_List
    FOR EACH ROW
BEGIN
    IF fLiveStock(NEW.Product_ID) < NEW.Quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient Stock available.';
    END IF;
END //

CREATE TRIGGER fCheckRating
    BEFORE INSERT ON Feedback
    FOR EACH ROW
BEGIN
    IF NEW.Rating < 1 THEN SET NEW.Rating = 1; END IF;
    IF NEW.Rating > 5 THEN SET NEW.Rating = 5; END IF;
END //

CREATE TRIGGER tCloseOrder
    AFTER INSERT ON Sales
    FOR EACH ROW
BEGIN
    UPDATE Orders SET Order_Status = 2 WHERE Orders_ID = NEW.Orders_ID; -- Changed to 2 (Completed) per your sheet
END //

CREATE TRIGGER tAutoPrice
    BEFORE INSERT ON Sales_List
    FOR EACH ROW
BEGIN
    DECLARE v_Price DECIMAL(12,2);
    SELECT Sell_Price INTO v_Price FROM Products WHERE Product_ID = NEW.Product_ID;
    SET NEW.Total_Price = NEW.Quantity * v_Price;
END //


DROP PROCEDURE IF EXISTS pCheckoutTrans;
CREATE PROCEDURE pCheckoutTrans(IN parOrderID VARCHAR(10), IN parPayment VARCHAR(15))
BEGIN
    DECLARE v_SalesID VARCHAR(10);
    DECLARE v_DateCode VARCHAR(6);
    DECLARE v_Count INT;
    DECLARE v_Suffix VARCHAR(2);

    SET v_DateCode = DATE_FORMAT(CURDATE(), '%d%m%y');
    SELECT COUNT(*) INTO v_Count FROM Sales WHERE Date_Completed = CURDATE();
    SET v_Suffix = LPAD(v_Count + 1, 2, '0');
    SET v_SalesID = CONCAT('S', v_DateCode, v_Suffix);

    INSERT INTO Sales (Sales_ID, Orders_ID, Date_Completed, Payment, status_del)
    VALUES (v_SalesID, parOrderID, CURDATE(), parPayment, 0);

    INSERT INTO Sales_List (Product_ID, Sales_ID, Quantity, Total_Price)
    SELECT ol.Product_ID, v_SalesID, ol.Quantity, (ol.Quantity * p.Sell_Price)
    FROM Order_List ol
             JOIN Products p ON ol.Product_ID = p.Product_ID
    WHERE ol.Orders_ID = parOrderID;

    SELECT 'Successfully added to Sales' AS Message;
END //

DROP PROCEDURE IF EXISTS pSubmitReview;
CREATE PROCEDURE pSubmitReview(IN parCustID VARCHAR(10), IN parSalesID VARCHAR(10), IN parRating INT, IN parComment TEXT)
BEGIN
    DECLARE v_Check INT;
    DECLARE v_FeedbackID VARCHAR(10);
    DECLARE v_CustInitials VARCHAR(3);
    DECLARE v_Count INT;
    DECLARE v_Suffix VARCHAR(2);


    SELECT COUNT(*) INTO v_Check FROM Sales WHERE Sales_ID = parSalesID;

    IF v_Check > 0 THEN
        SELECT UPPER(SUBSTRING(Customer_Name, 1, 3)) INTO v_CustInitials
        FROM Customers WHERE Customer_ID = parCustID;

        SELECT COUNT(*) INTO v_Count FROM Feedback WHERE Feedback_ID LIKE CONCAT('F', v_CustInitials, '%');
        SET v_Suffix = LPAD(v_Count + 1, 2, '0');
        SET v_FeedbackID = CONCAT('F', v_CustInitials, v_Suffix);

        INSERT INTO Feedback (Feedback_ID, Sales_ID, Customer_ID, Feedback_comment, Rating, status_del)
        VALUES (v_FeedbackID, parSalesID, parCustID, parComment, parRating, 0);

        SELECT 'Successfully submitted to Feedback' AS Message;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sales ID not found.';
    END IF;
END //

DROP PROCEDURE IF EXISTS pOrderGenID;
CREATE PROCEDURE pOrderGenID(IN parDate DATE, OUT parID VARCHAR(15))
BEGIN
    DECLARE v_DateCode VARCHAR(6);
    DECLARE v_Count INT;
    DECLARE v_Suffix VARCHAR(2);

    SET v_DateCode = DATE_FORMAT(parDate, '%d%m%y');

    SELECT COUNT(*) INTO v_Count
    FROM Orders
    WHERE Order_For_Date = parDate;

    SET v_Suffix = LPAD(v_Count + 1, 2, '0');

    SET parID = CONCAT('O', v_DateCode, v_Suffix);
END //

DELIMITER ;
