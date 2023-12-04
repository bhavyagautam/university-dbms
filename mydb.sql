DROP DATABASE IF EXISTS info_mgmt;
CREATE DATABASE IF NOT EXISTS info_mgmt;
USE info_mgmt;

-- Create Department Table
CREATE TABLE Department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(255) NOT NULL
)AUTO_INCREMENT = 101;

-- Create Student Table
CREATE TABLE Student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
)AUTO_INCREMENT = 101;

-- Create Course Table
CREATE TABLE Course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    credits INT NOT NULL,
    workload INT NOT NULL,
    department_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
)AUTO_INCREMENT = 101;

-- Create Instructor Table
CREATE TABLE Instructor (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
)AUTO_INCREMENT = 101;

-- Create Enrollment Table
CREATE TABLE Enrollment (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(255) NOT NULL,
    year INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
)AUTO_INCREMENT = 101;

-- Create CourseInstructor Table
CREATE TABLE CourseInstructor (
    course_id INT,
    instructor_id INT,
    PRIMARY KEY (course_id, instructor_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
    FOREIGN KEY (instructor_id) REFERENCES Instructor(instructor_id)
);

-- Trigger to delete student data in enrollment table when student data is deleted
DELIMITER //
CREATE TRIGGER before_delete_student
BEFORE DELETE ON Student
FOR EACH ROW
BEGIN
    DELETE FROM Enrollment WHERE student_id = OLD.student_id;
END;
//
DELIMITER ;


-- Create role for student and admin users
DROP ROLE IF EXISTS 'student_role', 'admin_role';
CREATE ROLE 'student_role';
CREATE ROLE 'admin_role';

-- Granting necessary privileges to roles
GRANT SELECT ON info_mgmt.* TO 'student_role';
GRANT ALL PRIVILEGES ON info_mgmt.* TO 'admin_role';

-- View with Instructor and Student name
CREATE VIEW CourseEnrollments AS
SELECT
    c.course_id,
    c.course_name,
    CONCAT(s.first_name,' ',s.last_name) AS student_name,
    CONCAT(i.first_name,' ',i.last_name) AS instructor_name,
    e.semester,
    e.year
FROM
    Course c
INNER JOIN Enrollment e ON c.course_id = e.course_id
INNER JOIN Student s ON e.student_id = s.student_id
INNER JOIN CourseInstructor ci ON c.course_id = ci.course_id
INNER JOIN Instructor i ON ci.instructor_id = i.instructor_id;


-- Insert data into Department Table
INSERT INTO Department (department_name) VALUES
('Computer Science'),
('Mathematics'),
('Economics'),
('Engineering'),
('Philosophy');

-- Insert data into Student Table
INSERT INTO Student (first_name, last_name, date_of_birth, email) VALUES
('Jason', 'Statham', '2000-05-15', 'jason.statham@tcd.ie'),
('Tom', 'Cruise', '2002-09-22', 'tom.cruise@tcd.ie'),
('Bob', 'Iger', '2001-03-10', 'bob.iger@tcd.ie'),
('Elon', 'Musk', '2003-07-05', 'elon.musk@tcd.ie'),
('Max', 'Verstappen', '2001-11-1', 'max.verstappen@tcd.ie');

-- Insert data into Course Table
INSERT INTO Course (course_name, credits, workload, department_id) VALUES
('Introduction to CS', 5, 80, 101),
('Calculus', 5, 120, 102),
('Information Management', 5, 100, 101),
('Deep Learning', 10, 180, 102),
('Macro Economics', 5, 60, 103);

-- Insert data into Instructor Table
INSERT INTO Instructor (first_name, last_name, email, department_id) VALUES
('Prof. Steve', 'Smith', 'steve.smith@tcd.ie', 101),
('Prof. Jane', 'Johnson', 'jane.johnson@tcd.ie', 102),
('Prof. Will', 'White', 'will.white@tcd.ie', 104),
('Prof. Lucas', 'Lee', 'lucas.lee@tcd.ie', 103),
('Prof. Bob', 'Brown', 'bob.brown@tcd.ie', 101);

-- Insert data into Enrollment Table
INSERT INTO Enrollment (student_id, course_id, semester, year) VALUES
(103, 105, 'Michaelmas', 2023),
(101, 103, 'Michaelmas', 2023),
(102, 104, 'Michaelmas', 2023),
(105, 101, 'Michaelmas', 2023),
(104, 102, 'Michaelmas', 2023);

-- Insert data into CourseInstructor Table
INSERT INTO CourseInstructor (course_id, instructor_id) VALUES
(101, 103),
(102, 101),
(103, 104),
(104, 105),
(105, 102);

-- Adding age
ALTER TABLE Student
ADD age INT;
UPDATE Student
SET age = DATE_FORMAT(FROM_DAYS(DATEDIFF(NOW(), date_of_birth)), '%Y') + 0;

-- Creating procedure to enroll students into a course
DELIMITER //
CREATE PROCEDURE EnrollStudentInCourse(
    IN studentID INT,
    IN courseID INT,
    IN semester VARCHAR(255),
    IN year INT
)
BEGIN
    DECLARE student_exists INT;
    DECLARE course_exists INT;

    SELECT COUNT(*) INTO student_exists FROM Student WHERE student_id = studentID;
    SELECT COUNT(*) INTO course_exists FROM Course WHERE course_id = courseID;

-- Checking if both student and course exists
    IF student_exists > 0 AND course_exists > 0 THEN
        INSERT INTO Enrollment (student_id, course_id, semester, year)
        VALUES (studentID, courseID, semester, year);

        SELECT 'Enrollment successful' AS result;
    ELSE
        SELECT 'Student or Course does not exist' AS result;
    END IF;
END;
//
DELIMITER ;

-- Call to the procedure
CALL EnrollStudentInCourse(103, 103, 'Hilary', 2023);

-- Viewing data from the tables
SELECT * FROM CourseEnrollments;
SELECT * FROM Enrollment;
SELECT * FROM Student;

-- Query students who are enrolled in the course named Information Management
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_id,
    c.course_name    
FROM
    Student s
JOIN
    Enrollment e ON s.student_id = e.student_id
JOIN
	Course c ON e.course_id = c.course_id
WHERE
    c.course_name = 'Information Management';

-- DELETE FROM Student WHERE student_id = 101;


