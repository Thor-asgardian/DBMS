CREATE DATABASE sailorboat;
USE sailorboat;
SELECT * FROM sailor;
SELECT * FROM boat;
SELECT * FROM reserves;

SELECT color FROM boat b
JOIN reserves r ON b.bid=r.bid
WHERE r.sid=(SELECT sid FROM sailor WHERE sname="albert");

SELECT DISTINCT(s.sid) FROM sailor s
JOIN reserves r ON s.sid=r.sid
WHERE s.rating >6 OR r.bid=3;

SELECT sname FROM sailor 
WHERE sid NOT IN 
(SELECT DISTINCT(r.sid) FROM reserves r
JOIN boat b ON r.bid=b.bid
WHERE bname="b3")
ORDER BY sname ASC;

SELECT sname
FROM SAILOR
WHERE NOT EXISTS (SELECT * FROM BOAT
WHERE BOAT.bid NOT IN (SELECT bid FROM RESERVES WHERE RESERVES.sid = SAILOR.sid));

SELECT sname,age FROM sailor 
WHERE age=(SELECT MAX(s2.age) FROM sailor s2);

SELECT b.bid,AVG(s.age) 
FROM sailor s,boat b,reserves r
WHERE s.age>=40 AND s.sid=r.sid AND r.bid=b.bid
GROUP BY b.bid
HAVING COUNT(DISTINCT(s.sid))>=5;

CREATE VIEW Sailors_rating AS
SELECT sname, rating
FROM SAILOR
ORDER BY rating DESC;
SELECT * FROM Sailors_rating;

CREATE VIEW Sailors_reservation AS
SELECT sname
FROM SAILOR s,reserves r
WHERE s.sid = r.sid AND DATE="2020-10-03";
SELECT * FROM Sailors_reservation;

CREATE VIEW Boat_reservation AS
SELECT bname, color
FROM BOAT b
JOIN RESERVES r ON b.bid = r.bid
JOIN SAILOR s ON s.sid = r.sid
WHERE rating = 8;
SELECT * FROM Boat_reservation;

CREATE TRIGGER Prevent_Delete_Boats
BEFORE DELETE ON BOAT
FOR EACH ROW
BEGIN
IF (EXISTS (SELECT * FROM RESERVES WHERE bid = OLD.bid)) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Cannot delete boat with active reservations';
END IF;
END;
DELETE FROM boat WHERE bid=1;

CREATE TRIGGER Prevent_low_rating_reservation
BEFORE INSERT ON RESERVES
FOR EACH ROW
BEGIN
IF (SELECT rating FROM SAILOR WHERE sid = NEW.sid) < 3 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Sailors with rating less than 3 cannot reserve a boat';
END IF;
END; 

DELIMITER $$
CREATE TRIGGER Delete_expired_reservations
AFTER INSERT ON RESERVES
FOR EACH ROW
BEGIN
DELETE FROM RESERVES
WHERE DATE < "2020-10-01";
END; $$
SHOW TRIGGERS;