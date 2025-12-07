USE kajjabase;
INSERT INTO Customers (Customer_ID, Customer_Name, Cust_Email, Cust_Password, Cust_Number, status_del) VALUES
                                                                                                           ('BUD01', 'Budi Santoso', 'budi@mail.com', MD5('pass123'), '08123456789', 0),
                                                                                                           ('DIM01', 'Dimas Pratama', 'dimas@mail.com', MD5('pass123'), '08198765432', 0),
                                                                                                           ('ASE01', 'Asep Surasep', 'asep@mail.com', MD5('pass123'), '08134567890', 0),
                                                                                                           ('SIT01', 'Siti Aminah', 'siti@mail.com', MD5('pass123'), '08145678901', 0),
                                                                                                           ('JOK01', 'Joko Anwar', 'joko@mail.com', MD5('pass123'), '08156789012', 0);


INSERT INTO Products (Product_ID, Product_Name, Sell_Price, status_del) VALUES
                                                                            ('P0001', 'Chicky BapBap (Small)', 25000.00, 0),
                                                                            ('P0002', 'Chicky BapBap (Large)', 35000.00, 0),
                                                                            ('P0003', 'Minion BapBap (Small)', 25000.00, 0),
                                                                            ('P0004', 'Minion BapBap (Large)', 35000.00, 0);

INSERT INTO Production (Production_ID, Product_ID, Date_In, Quantity, Production_Cost, status_del) VALUES
                                                                                                       ('PR01112501', 'P0001', '2025-11-01', 50, 10000.00, 0),
                                                                                                       ('PR01112502', 'P0002', '2025-11-01', 50, 12000.00, 0),
                                                                                                       ('PR01112503', 'P0003', '2025-11-01', 50, 10000.00, 0),
                                                                                                       ('PR01112504', 'P0004', '2025-11-01', 50, 12000.00, 0);

INSERT INTO Orders (Orders_ID, Customer_ID, Date_In, Order_Status, Order_For_Date, status_del) VALUES
    ('O12112501', 'BUD01', '2025-11-12', 2, '2025-11-12', 0);

INSERT INTO Order_List (Product_ID, Orders_ID, Quantity, Order_Date) VALUES
    ('P0001', 'O12112501', 1, '2025-11-12');

INSERT INTO Orders (Orders_ID, Customer_ID, Date_In, Order_Status, Order_For_Date, status_del) VALUES
    ('O18112501', 'DIM01', '2025-11-18', 2, '2025-11-18', 0);

INSERT INTO Order_List (Product_ID, Orders_ID, Quantity, Order_Date) VALUES
                                                                         ('P0002', 'O18112501', 1, '2025-11-18'),
                                                                         ('P0003', 'O18112501', 1, '2025-11-18');


INSERT INTO Orders (Orders_ID, Customer_ID, Date_In, Order_Status, Order_For_Date, status_del) VALUES
    ('O24112501', 'ASE01', '2025-11-24', 0, '2025-11-24', 0);

INSERT INTO Order_List (Product_ID, Orders_ID, Quantity, Order_Date) VALUES
                                                                         ('P0004', 'O24112501', 1, '2025-11-24'),
                                                                         ('P0001', 'O24112501', 2, '2025-11-24');

INSERT INTO Sales (Sales_ID, Orders_ID, Date_Completed, Payment, status_del) VALUES
    ('S12112501', 'O12112501', '2025-11-12', 'Cash', 0);

INSERT INTO Sales_List (Product_ID, Sales_ID, Quantity, Total_Price) VALUES
    ('P0001', 'S12112501', 1, 25000.00);


INSERT INTO Sales (Sales_ID, Orders_ID, Date_Completed, Payment, status_del) VALUES
    ('S18112501', 'O18112501', '2025-11-18', 'Transfer', 0);

INSERT INTO Sales_List (Product_ID, Sales_ID, Quantity, Total_Price) VALUES
                                                                         ('P0002', 'S18112501', 1, 35000.00),
                                                                         ('P0003', 'S18112501', 1, 25000.00);


INSERT INTO Waste (Waste_ID, Production_ID, Quantity, status_del)
VALUES ('W01112501', 'PR01112503', 1, 0);

INSERT INTO Feedback (Feedback_ID, Sales_ID, Customer_ID, Feedback_comment, Rating, status_del) VALUES
    ('FBUD01', 'S12112501', 'BUD01', 'Portion was a bit small but tasty.', 4, 0);