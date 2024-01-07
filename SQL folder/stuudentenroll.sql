CREATE DATABASE stuudentenroll;
USE stuudentenroll;

SET FOREIGN_KEY_CHECKS=0;
INSERT INTO TEXT (book_ISBN, book_title, publisher, author)
VALUES (100, 'Introduction to Database Systems', 'Wiley', 'Elmasri and Navathe');
INSERT INTO BOOK_ADOPTION (courseid, sem, book_ISBN)
VALUES (300, 1, 12345);

SELECT COURSE.courseid, text.book_ISBN, TEXT.book_title
FROM COURSE
JOIN BOOk_ADOPTION ON COURSE.courseid = BOOK_ADOPTION.courseid
JOIN TEXT ON BOOK_ADOPTION.book_ISBN = TEXT.book_ISBN
WHERE COURSE.dept = 'Computer Science'
GROUP BY COURSE.courseid
HAVING COUNT(BOOK_ADOPTION.book_ISBN) >= 2
ORDER BY TEXT.book_title;

 SELECT DISTINCT c.dept
FROM course c
JOIN book_adoption b ON c.courseid = b.courseid
JOIN TEXT t ON t.book_isbn = b.book_isbn
WHERE t.publisher = 'Wiley'
AND c.dept NOT IN (
    SELECT c.dept
    FROM course c
    JOIN book_adoption b ON c.courseid = b.courseid
    JOIN TEXT t ON t.book_isbn = b.book_isbn
    WHERE t.publisher != 'Wiley'
);
     
     SELECT s.name,e.marks
     FROM student s,enroll e,course c
     WHERE s.regno=e.regno AND e.courseid=c.courseid AND c.cname="Database Systems" 
     AND e.marks=(SELECT MAX(marks) FROM enroll e WHERE e.courseid=c.courseid);
     
CREATE VIEW student_courses AS
SELECT STUDENT.name, COURSE.cname, ENROLL.marks
FROM STUDENT
JOIN ENROLL ON STUDENT.regno = ENROLL.regno
JOIN COURSE ON ENROLL.courseid = COURSE.courseid;
SELECT * FROM student_courses;

CREATE VIEW student_enroll AS
SELECT STUDENT.name, COURSE.cname, ENROLL.sem, ENROLL.marks
FROM STUDENT
JOIN ENROLL ON STUDENT.regno = ENROLL.regno
JOIN COURSE ON ENROLL.courseid = COURSE.courseid;
SELECT * FROM student_enroll;

CREATE VIEW course_books AS
SELECT COURSE.cname, BOOK_ADOPTION.book_ISBN, TEXT.book_title
FROM COURSE
JOIN BOOK_ADOPTION ON COURSE.courseid = BOOK_ADOPTION.courseid
JOIN TEXT ON BOOK_ADOPTION.book_ISBN = TEXT.book_ISBN;
SELECT * FROM course_books;

CREATE TRIGGER delete_enroll
AFTER DELETE ON COURSE
FOR EACH ROW
BEGIN
DELETE FROM ENROLL WHERE courseid = OLD.courseid;
END;

DELIMITER $$
CREATE TRIGGER check_threshold
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    DECLARE prereq_threshold INT;

    SELECT AVG(marks) INTO prereq_threshold
    FROM ENROLL
    WHERE regno = NEW.regno;

    IF prereq_threshold < 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not meet the minimum average marks requirement';
    END IF;
END;$$
