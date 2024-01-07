CREATE DATABASE insurance;
USE insurance;

SELECT COUNT(DISTINCT p.driver_id) 
FROM PERSON p 
JOIN PARTICIPATED pa ON p.driver_id = pa.driver_id 
JOIN ACCIDENT a ON pa.report_no = a.report_no
WHERE YEAR(a.acc_date) = 2021;

SELECT COUNT(DISTINCT a.report_no) 
FROM ACCIDENT a 
JOIN PARTICIPATED pa ON a.report_no = pa.report_no 
JOIN PERSON p ON pa.driver_id = p.driver_id
WHERE p.name = 'mahesh';

SELECT COUNT(DISTINCT a.report_no) 
FROM ACCIDENT a
INNER JOIN participated pa ON a.report_no = pa.report_no
INNER JOIN person p ON pa.driver_id = p.driver_id
WHERE p.name = 'smith';

INSERT INTO ACCIDENT 
VALUES (26, '2022-01-01', 'Seattle');
INSERT INTO participated VALUES
(5,"45321",26,3500);

DELETE FROM CAR 
WHERE regno IN 
(SELECT regno FROM OWNS o JOIN PERSON p ON o.driver_id = p.driver_id WHERE p.name = 'madesh' AND model = 'venue');

UPDATE PARTICIPATED
SET damage_amt = 5000
WHERE regno = '22259' AND report_no = 14;

CREATE VIEW car_accident_view AS 
SELECT model, YEAR FROM CAR
JOIN PARTICIPATED ON CAR.regno = PARTICIPATED.regno;
SELECT * FROM car_accident_view;

CREATE VIEW driver_car_view AS 
SELECT NAME, address FROM PERSON;
SELECT * FROM driver_car_view;

CREATE VIEW driver_accident_place_view AS
SELECT NAME 
FROM PERSON p
JOIN PARTICIPATED pa ON p.driver_id = pa.driver_id
JOIN ACCIDENT a ON  pa.report_no = a.report_no
WHERE a.location = 'Seattle';
SELECT * FROM driver_accident_place_view

DELIMITER $$
CREATE TRIGGER check_damage_amount 
BEFORE INSERT ON OWNS 
FOR EACH ROW 
BEGIN
    DECLARE damage_total INT;
    SET damage_total = (SELECT SUM(damage_amt) FROM PARTICIPATED WHERE driver_id = NEW.driver_id);
    IF damage_total > 50000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Driver has exceeded the damage limit.';
    END IF;
END;$$
SHOW TRIGGERS;$$

DELIMITER $$
CREATE TRIGGER check_accident_count 
BEFORE INSERT ON PARTICIPATED 
FOR EACH ROW 
BEGIN
    IF (
        SELECT COUNT(*) 
        FROM PARTICIPATED 
        WHERE driver_id = NEW.driver_id 
        AND YEAR(acc_date) = YEAR(CURRENT_DATE())
    ) > 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Driver exceeded annual accident limit.';
    END IF;
END;$$
