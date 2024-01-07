CREATE DATABASE orderprocess;
USE orderprocess;

SELECT Orders.orderno, Shipment.ship_date
FROM Orders 
JOIN Shipment ON Orders.orderno = Shipment.orderno
JOIN Warehouse ON Shipment.warehouseno = Warehouse.warehouseno
WHERE Warehouse.warehouseno = 2;

SELECT Orders.orderno, Shipment.warehouseno
FROM Orders
JOIN Places ON Orders.orderno = Places.orderno
JOIN Customer2 ON Places.custid = Customer2.custid
JOIN Shipment ON Orders.orderno = Shipment.orderno
WHERE Customer2.cname = 'Kumar';

SELECT Cname, COUNT(OrderID) AS #ofOrders, AVG(OrderAmount) AS Avg_Order_Amt
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Cname;

SET FOREIGN_KEY_CHECKS=0;
DELETE FROM Orders
WHERE orderno IN (SELECT o.orderno FROM orders o,places p,customer2 c WHERE o.orderno=p.orderno AND p.custid=c.custid AND c.cname= 'Kumar');
SELECT * FROM orders;

SELECT itemno, unitprice
FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);

CREATE VIEW Orders_from_W2 AS
SELECT Orders.orderno, Shipment.ship_date
FROM Orders
JOIN Shipment ON Orders.orderno = Shipment.orderno
JOIN Warehouse ON Shipment.warehouseno = Warehouse.warehouseno
WHERE Warehouse.warehouseno = 2;
SELECT * FROM Orders_from_W2;

CREATE VIEW Kumar_Warehouse AS
SELECT Orders.orderno, Warehouse.warehouseno
FROM Orders
JOIN Places ON Orders.orderno = Places.orderno
JOIN Customer2 ON Places.custid = Customer2.custid
JOIN Shipment ON Orders.orderno = Shipment.orderno
JOIN Warehouse ON Shipment.warehouseno = Warehouse.warehouseno
WHERE Customer2.cname = 'Kumar';

DELIMITER $$
CREATE TRIGGER update_order_amount1
AFTER INSERT ON Order_item
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET order_amt = order_amt + (NEW.qty * (SELECT unitprice FROM Item WHERE Item.itemno = NEW.itemno))
    WHERE Orders.orderno = NEW.orderno;
END $$
DELIMITER ;
SHOW TRIGGERS;
INSERT INTO orders (orderno,odate) VALUE (5,"2023-10-01");
INSERT INTO Order_item (orderno,itemno,qty) VALUE (5,2,5);
