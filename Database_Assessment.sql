-- ============================================================
-- Task 2 Part A: HospitalDB Schema
-- ============================================================
DROP DATABASE IF EXISTS HospitalDB;
CREATE DATABASE HospitalDB;
USE HospitalDB;

CREATE TABLE Patient (
    patient_id   VARCHAR(50)  NOT NULL,
    first_name   CHAR(15)     NOT NULL,
    last_name    CHAR(15)     NOT NULL,
    date_of_birth DATE        NOT NULL,
    gender       ENUM('M', 'F', 'O'),
    phone_number VARCHAR(50)  UNIQUE,
    email        VARCHAR(50)  UNIQUE,
    CONSTRAINT Patient_PK PRIMARY KEY (patient_id)
);

CREATE TABLE Doctor (
    doctor_id          VARCHAR(50) NOT NULL,
    first_name         CHAR(15)    NOT NULL,
    last_name          CHAR(15)    NOT NULL,
    specialization     CHAR(1)     NOT NULL,
    email              VARCHAR(50) UNIQUE,
    years_of_experience INT,
    CHECK (years_of_experience > 0),
    CONSTRAINT Doctor_PK PRIMARY KEY (doctor_id)
);

CREATE TABLE Room (
    room_number  INT          NOT NULL,
    room_type    ENUM('General', 'ICU', 'Private'),
    availability ENUM('Y', 'N'),
    -- FIX: DEFAULT must be on the same line as the column definition
    -- FIX: Changed INT to DECIMAL(10,2) to properly store currency values
    rate_per_day DECIMAL(10,2) NOT NULL DEFAULT 100.00,
    CHECK (rate_per_day > 0),
    CONSTRAINT Room_PK PRIMARY KEY (room_number)
);

CREATE TABLE Treatment (
    treatment_id INT         NOT NULL,
    patient_id   VARCHAR(50),
    doctor_id    VARCHAR(50),
    room_number  INT,
    Start_Date   DATE        NOT NULL,
    End_Date     DATE        NOT NULL,
    -- FIX: Changed INT to DECIMAL(10,2) to properly store currency values
    Total_Cost   DECIMAL(10,2) NOT NULL,
    CHECK (Total_Cost > 0),
    -- FIX: Added date logic constraint so Part E insert will correctly fail
    CHECK (End_Date >= Start_Date),
    CONSTRAINT Treatment_PK PRIMARY KEY (treatment_id),
    CONSTRAINT Patient_FK   FOREIGN KEY (patient_id)   REFERENCES Patient(patient_id),
    CONSTRAINT Doctor_FK    FOREIGN KEY (doctor_id)    REFERENCES Doctor(doctor_id),
    CONSTRAINT Room_FK      FOREIGN KEY (room_number)  REFERENCES Room(room_number)
);

CREATE TABLE Medication (
    medication_id    INT         NOT NULL,
    treatment_id     INT         NOT NULL,
    medication_name  VARCHAR(50) NOT NULL,
    -- dosage stored as INT (units/tablets per dose)
    dosage           INT         NOT NULL,
    CHECK (dosage > 0),
    frequency_per_day INT        NOT NULL,
    -- FIX: MySQL does not support chained comparisons (1 < x < 4 always evaluates TRUE).
    -- Must use explicit AND to enforce both bounds.
    CHECK (frequency_per_day > 1 AND frequency_per_day < 4),
    CONSTRAINT Medication_PK  PRIMARY KEY (medication_id),
    CONSTRAINT Treatment_FK   FOREIGN KEY (treatment_id) REFERENCES Treatment(treatment_id)
);

-- ============================================================
-- Task 2 Part C: Valid dummy data
-- ============================================================

INSERT INTO Patient VALUES ('CB01', 'John',    'Smith',    '2001-05-24', 'M', '0207-774-5632', 'johnsmith12@gmail.com');
INSERT INTO Patient VALUES ('CB02', 'Emily',   'Johnson',  '1995-08-12', 'F', '0207-774-5633', 'emilyjohnson@gmail.com');
INSERT INTO Patient VALUES ('CB03', 'Michael', 'Brown',    '1988-03-30', 'M', '0207-774-5634', 'michaelbrown@gmail.com');
INSERT INTO Patient VALUES ('CB04', 'Sarah',   'Davis',    '2003-11-19', 'F', '0207-774-5635', 'sarahdavis@gmail.com');
INSERT INTO Patient VALUES ('CB05', 'James',   'Wilson',   '1975-07-07', 'M', '0207-774-5636', 'jameswilson@gmail.com');

INSERT INTO Doctor VALUES ('SUR011', 'Alex',   'Doe',      'S', 'alexdoe41@gmail.com',      12);
INSERT INTO Doctor VALUES ('SUR012', 'Rachel', 'Moore',    'S', 'rachelmoore@gmail.com',     8);
INSERT INTO Doctor VALUES ('CAR013', 'David',  'Taylor',   'C', 'davidtaylor@gmail.com',    15);
INSERT INTO Doctor VALUES ('NEU014', 'Laura',  'Anderson', 'N', 'lauraanderson@gmail.com',  10);
INSERT INTO Doctor VALUES ('PED015', 'Mark',   'Thomas',   'P', 'markthomas@gmail.com',      6);

INSERT INTO Room VALUES (1, 'Private', 'Y', 300.00);
INSERT INTO Room VALUES (2, 'General', 'Y', 100.00);
INSERT INTO Room VALUES (3, 'ICU',     'N', 500.00);
INSERT INTO Room VALUES (4, 'General', 'Y', 100.00);
INSERT INTO Room VALUES (5, 'Private', 'Y', 300.00);

INSERT INTO Treatment VALUES (30, 'CB01', 'SUR011', 2, '2009-05-14', '2011-10-23', 54000.00);
INSERT INTO Treatment VALUES (31, 'CB02', 'CAR013', 1, '2015-01-10', '2015-01-20', 12000.00);
INSERT INTO Treatment VALUES (32, 'CB03', 'NEU014', 3, '2018-06-01', '2018-06-15', 30000.00);
INSERT INTO Treatment VALUES (33, 'CB04', 'SUR012', 4, '2020-09-05', '2020-09-12',  8400.00);
INSERT INTO Treatment VALUES (34, 'CB05', 'PED015', 5, '2022-03-17', '2022-03-24',  9600.00);

INSERT INTO Medication VALUES (3, 30, 'Paracetamol', 2, 3);
INSERT INTO Medication VALUES (4, 31, 'Aspirin',     1, 2);
INSERT INTO Medication VALUES (5, 32, 'Ibuprofen',   3, 3);
INSERT INTO Medication VALUES (6, 33, 'Amoxicillin', 2, 2);
INSERT INTO Medication VALUES (7, 34, 'Metformin',   1, 3);

-- ============================================================
-- Task 2 Part D: Intentionally invalid inserts (all should fail)
-- ============================================================

-- Fails: patient_id is NOT NULL — cannot insert NULL as primary key
INSERT INTO Patient VALUES (
    NULL, 'Mary', 'Fred', '2011-04-14', 'F', '0456-774-5632', 'maryfred31@gmail.com');

-- Fails: email 'alexdoe41@gmail.com' already exists — UNIQUE constraint violation
INSERT INTO Doctor VALUES (
    '11', 'Alix', 'Doee', 'P', 'alexdoe41@gmail.com', 13);

-- Fails: 'T' is not a valid value for availability ENUM('Y', 'N')
-- Note: room_number 3 already exists so this would also fail on duplicate PK,
-- but the ENUM violation is the intended demonstration.
INSERT INTO Room VALUES (
    6, 'ICU', 'T', 1000.00);

-- Fails: Total_Cost = 0.40 is a positive decimal but the column is DECIMAL(10,2),
-- so it stores as 0.40 which violates CHECK (Total_Cost > 0) — wait, 0.40 > 0 is true.
-- The original intent was INT rounding to 0. With DECIMAL(10,2) it stores 0.40 which passes CHECK.
-- To keep the spirit of the original failing insert, we use 0.00 explicitly:
-- Fails: Total_Cost = 0.00 violates CHECK (Total_Cost > 0)
INSERT INTO Treatment VALUES (
    10, 'CB04', 'SUR012', 4, '2011-03-24', '2013-12-13', 0.00);

-- Fails: treatment_id 40 does not exist in Treatment table — FK violation
-- FIX: medication_id changed from 4 to 10 to avoid conflict with valid Aspirin insert (id=4)
INSERT INTO Medication VALUES (
    10, 40, 'Panadol', 4, 3);

-- ============================================================
-- Task 2 Part E: Intentionally invalid insert (should fail)
-- ============================================================

-- Fails: room_number 9 does not exist in Room table — FK violation on Room_FK
-- Also fails: End_Date '2003-02-03' is before Start_Date '2019-06-04' — CHECK (End_Date >= Start_Date)
INSERT INTO Treatment VALUES (
    56, 'CB01', 'SUR011', 9, '2019-06-04', '2003-02-03', 4000.00);

-- ============================================================
-- Task 2 Part F: View
-- ============================================================

CREATE VIEW Patient_Public_View AS
    SELECT patient_id, first_name, last_name, gender
    FROM Patient;

SELECT * FROM Patient_Public_View;

-- ============================================================
-- Tasks 3 & 4: Assessment_3B_24s2_HomebaseDB
-- FIX: Removed DROP DATABASE — this database must already exist.
--      Dropping it then immediately USEing it would cause an error.
-- ============================================================
USE Assessment_3B_24s2_HomebaseDB;

-- Task 3 Part A:
SELECT clientNo, fName, lName, emailAddr, prefType, maxRent
FROM Client
WHERE prefType = 'Flat' AND maxRent > 400;

-- Task 3 Part B:
INSERT INTO Client VALUES (
    'CR80', 'Chris', 'Smith', '12 Mary St Brisbane', '0141583594',
    'chrissmith@hotmail.com.au', 'Flat', 750);

-- Task 3 Part C:
DELETE FROM Inspection
WHERE clientNo = 'CN75' AND propertyNo = 'PF016' AND viewDate = '2023-04-20';

-- Task 3 Part D:
SET SQL_SAFE_UPDATES = 0;
UPDATE Staff SET salary = salary * 2.07 WHERE staffNo IN ('SN037', 'ST041');
SELECT * FROM Staff;

-- Task 3 Part E:
SELECT PO.fName, PO.lName, COUNT(*) AS num_properties
FROM PropertyForRent PFR
JOIN PropertyOwner PO ON PFR.ownerNo = PO.ownerNo
GROUP BY PO.fName, PO.lName
HAVING PO.fName = 'Maggie' AND PO.lName = 'Simpson';

-- Task 3 Part F:
SELECT *
FROM PropertyForRent
WHERE address LIKE '16%' OR address LIKE '18%';

-- Task 3 Part G:
SELECT B.address, COUNT(P.propertyNo) AS num_properties
FROM Branch B
JOIN PropertyForRent P ON B.branchNo = P.branchNo
GROUP BY B.address
HAVING COUNT(P.propertyNo) > 1;

-- Task 4 Part A:
SELECT *
FROM Client
WHERE clientNo IN (
    SELECT clientNo
    FROM Inspection
    WHERE viewDate > '2023-05-01'
);

-- Task 4 Part B:
SELECT fName, lName, address
FROM PropertyOwner
WHERE ownerNo IN (
    SELECT ownerNo
    FROM PropertyForRent
    WHERE rooms > 2
);

-- Task 4 Part C:
SELECT fName, lName
FROM Client
WHERE clientNo IN (
    SELECT clientNo
    FROM Inspection
    WHERE propertyNo IN (
        SELECT propertyNo
        FROM PropertyForRent
        WHERE branchNo IN (
            SELECT branchNo
            FROM Branch
            WHERE postcode = 'Q4041'
        )
    )
);

-- Task 4 Part D:
SELECT
    B.address,
    B.postcode,
    SUM(S.salary)              AS total_salary,
    COUNT(DISTINCT S.staffNo)  AS num_employees,
    COUNT(DISTINCT P.propertyNo) AS num_properties
FROM Staff S
RIGHT JOIN Branch B          ON S.branchNo = B.branchNo
RIGHT JOIN PropertyForRent P ON B.branchNo = P.branchNo
GROUP BY B.address, B.postcode;

-- ============================================================
-- Task 5: BankingDB
-- ============================================================

-- Part A:
DROP DATABASE IF EXISTS BankingDB;
CREATE DATABASE BankingDB;
USE BankingDB;

-- Part B:
CREATE TABLE Customer (
    customer_id INT         NOT NULL,
    First_Name  VARCHAR(50) NOT NULL,
    Last_Name   VARCHAR(50) NOT NULL,
    DOB         DATE        NOT NULL,
    -- Note: CHAR(20) may truncate longer email addresses; VARCHAR(100) is safer in practice
    Email       VARCHAR(100) NOT NULL,
    CONSTRAINT Customer_PK PRIMARY KEY (customer_id)
);

-- Part C:
CREATE TABLE Account (
    account_id   INT  NOT NULL,
    customer_id  INT,
    account_type ENUM('Savings', 'Checking', 'Loan'),
    -- FIX: Changed INT to DECIMAL(10,2) to properly store monetary balances
    balance      DECIMAL(10,2),
    CHECK (balance >= 0),
    CONSTRAINT Account_PK  PRIMARY KEY (account_id),
    CONSTRAINT Customer_FK FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- Part D: Create users with expiring passwords
CREATE USER IF NOT EXISTS 'admin'@'localhost'            IDENTIFIED BY 'admin123'     PASSWORD EXPIRE;
CREATE USER IF NOT EXISTS 'teller'@'localhost'           IDENTIFIED BY 'teller1234'   PASSWORD EXPIRE;
CREATE USER IF NOT EXISTS 'auditor'@'localhost'          IDENTIFIED BY 'auditor123'   PASSWORD EXPIRE;
CREATE USER IF NOT EXISTS 'customer_support'@'localhost' IDENTIFIED BY 'customer1234' PASSWORD EXPIRE;
SELECT User, Host FROM mysql.user;

-- Part E: Grant privileges directly to each user
-- FIX: Roles were created but never assigned — grants now go directly to users as intended.
--      Role creation lines removed to avoid confusion between role-based and user-based access control.
GRANT ALL                                  ON BankingDB.Customer TO 'admin'@'localhost';
GRANT ALL                                  ON BankingDB.Account  TO 'admin'@'localhost';
GRANT INSERT, UPDATE, DELETE, SELECT       ON BankingDB.Customer TO 'teller'@'localhost';
GRANT INSERT, UPDATE, DELETE, SELECT       ON BankingDB.Account  TO 'teller'@'localhost';
GRANT SELECT                               ON BankingDB.Customer TO 'auditor'@'localhost';
GRANT SELECT                               ON BankingDB.Account  TO 'auditor'@'localhost';
GRANT SELECT                               ON BankingDB.Customer TO 'customer_support'@'localhost';
SHOW GRANTS FOR 'teller'@'localhost';

-- Part F: Revoke DELETE from teller
REVOKE DELETE ON BankingDB.Customer FROM 'teller'@'localhost';
REVOKE DELETE ON BankingDB.Account  FROM 'teller'@'localhost';

-- ============================================================
-- Task 6: RetailDB
-- ============================================================

-- Part A:
DROP DATABASE IF EXISTS RetailDB;
CREATE DATABASE RetailDB;
USE RetailDB;

-- Part B:
CREATE TABLE Product (
    product_id     VARCHAR(50) NOT NULL,
    product_name   CHAR(50)    NOT NULL,
    stock_quantity INT         NOT NULL,
    CHECK (stock_quantity >= 0),
    CONSTRAINT Product_PK PRIMARY KEY (product_id)
);

CREATE TABLE Orders (
    order_id       VARCHAR(50) NOT NULL,
    product_id     VARCHAR(50) NOT NULL,
    order_quantity INT         NOT NULL,
    CONSTRAINT Orders_PK  PRIMARY KEY (order_id),
    CONSTRAINT Product_FK FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Part C: Dummy data
INSERT INTO Product VALUES ('1',  'Laptop',      10);
INSERT INTO Product VALUES ('2',  'Smartphone',  15);
INSERT INTO Product VALUES ('3',  'Headphones',   5);
INSERT INTO Product VALUES ('4',  'Monitor',      8);
INSERT INTO Product VALUES ('5',  'Keyboard',    20);
INSERT INTO Product VALUES ('6',  'Mouse',       25);
INSERT INTO Product VALUES ('7',  'Webcam',      12);
INSERT INTO Product VALUES ('8',  'USB Hub',     30);
INSERT INTO Product VALUES ('9',  'SSD Drive',   18);
INSERT INTO Product VALUES ('10', 'Laptop Stand',14);
SELECT * FROM Product;

INSERT INTO Orders VALUES ('ORD001', '1',  2);
INSERT INTO Orders VALUES ('ORD002', '2',  3);
INSERT INTO Orders VALUES ('ORD003', '3',  1);
INSERT INTO Orders VALUES ('ORD004', '4',  2);
INSERT INTO Orders VALUES ('ORD005', '5',  5);
INSERT INTO Orders VALUES ('ORD006', '6',  4);
INSERT INTO Orders VALUES ('ORD007', '7',  1);
INSERT INTO Orders VALUES ('ORD008', '8',  6);
INSERT INTO Orders VALUES ('ORD009', '9',  3);
INSERT INTO Orders VALUES ('ORD010', '10', 2);

-- Part D: Deduct stock for an order using a transaction
START TRANSACTION;
UPDATE Product
SET stock_quantity = stock_quantity - 3
WHERE product_id = '1';
COMMIT;
SELECT * FROM Product;