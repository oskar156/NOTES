/************************************************************************
SQL NOTES PART 3
Following Sams Teach Yourself SQL in 10 Minutues by Ben Forta


TOC
LESSON 18 - Using Views
	CREATE VIEW
	DROP VIEW
LESSON 19 - Working with Stored Procedures
LESSON 20 - Managing Transaction Processing
	BEGIN TRANSACTION, COMMIT TRANSACTION
	ROLLBACK
	SAVE TRANSACTION
	ROLLBACK TRANSACTION
LESSON 21 - Using Cursors
	DECLARE x CURSOR FOR y
	OPEN, CLOSE
	FETCH NEXT FROM 
	DECLARE
	DEALLOCATE
LESSON 22 - Understand Advanced SQL Features
	Contstraints
		PRIMARY KEY
		ADD CONSTRAINT
		FOREIGN KEY REFERENCES
		UNIQUE
		CHECK
	Indexes
		CREATE INDEX
		DROP INDEX
		CREATE UNIQUE INDEX ... WITH IGNORE_DUP_KEY ON [PRIMARY] (DEDUPE)
	Triggers
		CREATE TRIGGER, DROP TRIGGER
*********************************************/


--SQL04
USE TEMP_OK
GO

--SQL_NOTES_SAMPLE_TABLE_1 is GPPO245478_1_RAW
--SQL_NOTES_SAMPLE_TABLE_2 is GPPO245478_1_EO_VALID 
--SQL_NOTES_SAMPLE_TABLE_2_VALIDS is GPPO245478_1_EO_VALID where validationstatusid ='verified'
--SQL_NOTES_SAMPLE_TABLE_2_OK is GPPO245478_1_EO_VALID where validationstatusid ='catch all'or validationstatusid ='unknown'
--SQL_NOTES_SAMPLE_TABLE_2_BAD is GPPO245478_1_EO_VALID where validationstatusid <>'verified' and validationstatusid <>'catch all'and validationstatusid <>'unknown'
--SQL_NOTES_SAMPLE_TABLE_3 is GPPO245515_1_RAW
--SQL_NOTES_SAMPLE_TABLE_4


/************************************************************************
LESSON 18
Using Views

-Views are virtual tables.
-Unlike tables that contain data, view contain queries that dynamically retrieve data when used.
************************************************************************/
--creating the view
CREATE VIEW [SQL_NOTES_SAMPLE_VIEW_VALID_EMAILS] AS
SELECT * 
FROM [SQL_NOTES_SAMPLE_TABLE_2]
WHERE VALIDATIONSTATUSID='VERIFIED'
GO

--selecting from the view
SELECT * 
FROM [SQL_NOTES_SAMPLE_VIEW_VALID_EMAILS]
GO--ROW COUNT: 143

--updating the original table then selecting from the view again
INSERT INTO [SQL_NOTES_SAMPLE_TABLE_2](EMAIL,VALIDATIONSTATUSID) VALUES('TEST@TEST.COM','VERIFIED')
GO
SELECT * 
FROM [SQL_NOTES_SAMPLE_VIEW_VALID_EMAILS]
GO--ROW COUNT: 144

--deleting the view
DROP VIEW [SQL_NOTES_SAMPLE_VIEW_VALID_EMAILS]
GO


/************************************************************************
LESSON 19
Working with Stored Procedures

-Stored Procedures are like functions in other languages
************************************************************************/
--Each DBMS handles stored procedures differently, some don't support them at all

--using stored procedures are simple
--here's a built-in stored procedure that renames tables
SP_RENAME SQL_NOTES_SAMPLE_TABLE_4, SQL_NOTES_SAMPLE_TABLE_4B
GO
SP_RENAME SQL_NOTES_SAMPLE_TABLE_4B, SQL_NOTES_SAMPLE_TABLE_4
GO

--here's a user created stored procedure that dedupe a table based on a column
DEDUPE SQL_NOTES_SAMPLE_TABLE_4,EMAIL
GO

--creating and modifying stored procedures go beyond the scope of these notes, so i'll only quickly outline how to do it
/*
1. In the Object Explorer, expand your Database and expand the Programmability Folder
2. right click the Stored Procedure folder and go to New > Stored Procedure
3. a new tab wil open
4. repalce the placeholder text 
5. look at existing stored procedures to see how it's done by expanding the Stored Procedure folder right-clicking a stored procedure and clicking Modify
*/


/************************************************************************
LESSON 20
Managing Transaction Processing
************************************************************************/
--Transaction processing is used to manage INSERT, UPDATE and DELETE statements
--you can't roll back SELECT, CREATE or DROP statements

SELECT * 
INTO SQL_NOTES_SAMPLE_TABLE_6
FROM SQL_NOTES_SAMPLE_TABLE_4
GO--SQL_NOTES_SAMPLE_TABLE_6 WILL BE THE TEST DUMMY FOR THIS SECTION
SELECT * 
INTO SQL_NOTES_SAMPLE_TABLE_7
FROM SQL_NOTES_SAMPLE_TABLE_4
GO--SQL_NOTES_SAMPLE_TABLE_6 AND 7 WILL BE THE TEST DUMMY FOR THIS SECTION

--TRANSACTION blocks (different between DBMSs)
BEGIN TRANSACTION
--statements
--an SQL between BEGIN and COMMIT must be executed entirely or not at all
COMMIT TRANSACTION
GO

--ROLLBACK
--undo only for INSERT, UPDATE and DELETE
BEGIN TRANSACTION
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_6 --695
GO
DELETE FROM SQL_NOTES_SAMPLE_TABLE_6   --695
GO
ROLLBACK
GO
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_6 --695
GO

--COMMIT, there is no rollbacking after commit
BEGIN TRANSACTION
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_6 --695
GO
DELETE FROM SQL_NOTES_SAMPLE_TABLE_6   --695
GO
COMMIT TRANSACTION
GO
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_6 --0
GO


--SAVEPOINTSBEGIN TRANSACTION
BEGIN TRANSACTION
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_7 WHERE [FIRST]='TEST' --0
GO
SAVE TRANSACTION SQL_NOTES_SAMPLE_TRANSACTION --THIS IS THE SAVE POINT WHERE IT WILL BE ROLLED BACK TO
GO
INSERT INTO SQL_NOTES_SAMPLE_TABLE_7([FIRST]) VALUES ('TEST') --1
GO
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_7 WHERE [FIRST]='TEST' --1
GO
ROLLBACK TRANSACTION SQL_NOTES_SAMPLE_TRANSACTION
GO
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_7 WHERE [FIRST]='TEST' --0
GO
COMMIT TRANSACTION

--ROLLBACK and ROLLBACK TRANSACTION is useful for Error Handling


/************************************************************************
LESSON 21
Using Cursors

Using simple SELECT statements there is no way to get the first row, the next row or the previous 10 rows.
But sometimes there is a need to step through rows forward or backward, and one or more at a time.
This is what cursors are used for.
************************************************************************/
--Creating Cursors
DECLARE SQL_NOTES_SAMPLE_CURSOR CURSOR FOR
SELECT [FIRST]
FROM SQL_NOTES_SAMPLE_TABLE_7
GO

--LETS YOU USE THE CURSOR
--IE LETS YOU STEP THROUGH THE SELECT STATEMENT'S RESULTS
OPEN SQL_NOTES_SAMPLE_CURSOR
GO
FETCH NEXT FROM SQL_NOTES_SAMPLE_CURSOR
GO--LINDSAY
FETCH NEXT FROM SQL_NOTES_SAMPLE_CURSOR
GO--VICKIE
--etc...
CLOSE SQL_NOTES_SAMPLE_CURSOR
GO--CLOSING THEN OPENING IT ESSENTIALLY RESETS IT


--LOOP THROUGH THE RESULTS
--USING GO WILL TAKE THE DECLARED VARIABLE OUT OF SCOPE

DECLARE @NAME VARCHAR(255)

OPEN SQL_NOTES_SAMPLE_CURSOR

FETCH NEXT FROM SQL_NOTES_SAMPLE_CURSOR
INTO @NAME

SELECT @NAME--LINDSAY


WHILE @@FETCH_STATUS  = 0
BEGIN

FETCH NEXT FROM SQL_NOTES_SAMPLE_CURSOR
INTO @NAME

SELECT @NAME --WILL SHOW ALL 696 NAMES
END

CLOSE SQL_NOTES_SAMPLE_CURSOR
GO

--DELETES THE CURSOR
DEALLOCATE SQL_NOTES_SAMPLE_CURSOR
GO

/************************************************************************
LESSON 22
Understand Advanced SQL Features
************************************************************************/

----------------
--Constraints
----------------
--rules that govern how database data is inserted or manipulated
--DBMSs enforce referential integrity by imposing constraints on tables
--You can define constraints in Table Definitions, or by using ADD CONSTRAINT

--Primary Key columns must not be null, unique  and never reused
CREATE TABLE SQL_NOTES_SAMPLE_TABLE_8
(
	customer_id VARCHAR(255) NOT NULL PRIMARY KEY
)


--or you can do it this way
--this also shows you can use multiple columns in a Primary Key
CREATE TABLE SQL_NOTES_SAMPLE_TABLE_9
(
	customer_name VARCHAR(255) NOT NULL 
	,customer_number VARCHAR(255) NOT NULL 
)
go
ALTER TABLE SQL_NOTES_SAMPLE_TABLE_9
ADD CONSTRAINT PK_CUSTOMER PRIMARY KEY (customer_name,customer_number)
GO

--Foreign Keys
--a columns in a table whose values must be listed in a primary key in another table
CREATE TABLE SQL_NOTES_SAMPLE_TABLE_10
(
	order_id INT NOT NULL PRIMARY KEY
	,customer_id VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES SQL_NOTES_SAMPLE_TABLE_8(customer_id)
)

--UNIQUE
--functions the same as PRIMARY KEY, but you can have multiple UNIQUE constraints per table, but only 1 PRIMARY KEY constraint per table
--similar syntax:
--CREATE TABLE SQL_NOTES_SAMPLE_TABLE_10
--(
--	order_id INT NOT NULL PRIMARY KEY
--	,customer_id INT NOT NULL UNIQUE
--	,shipment_id INT NOT NULL UNIQUE
--)

--Check Constraints
--custom criteria
--CREATE TABLE SQL_NOTES_SAMPLE_TABLE_10
--(
--	customer_id INT NOT NULL PRIMARY KEY
--	,AGE INT NOT NULL CHECK (AGE >= 18)
--)
--or ADD CONSTRAINT CHECK (NAME <> 'BOB JOHNSON')

----------------
--Indexes
----------------
--adding an index on column has pros and cons
--PROS: better retrieval performance
--CONS: worse performance on data insertion, modification and deletion. they take up lots of storage
--not all columns or combinations of columns are suitable for indexing (for example STATE has tons of duplicates, so its a bad candidate. But ADDRESS has many more unique values, so it's better)

CREATE INDEX IDX_ADDRESS_1 
ON SQL_NOTES_SAMPLE_TABLE_4 ([ADDRESS 1])
GO
DROP INDEX IDX_ADDRESS_1 
ON SQL_NOTES_SAMPLE_TABLE_4
GO

--HERE'S A QUICK WAY TO DE-DUPE A TABLE
SELECT TOP 0 * 
INTO SQL_NOTES_SAMPLE_TABLE_4_DEDUPED 
FROM SQL_NOTES_SAMPLE_TABLE_4
GO
CREATE UNIQUE INDEX UNIQUE_INDEX 
ON SQL_NOTES_SAMPLE_TABLE_4_DEDUPED (COMPANY) 
WITH IGNORE_DUP_KEY ON [PRIMARY] 
GO
INSERT INTO SQL_NOTES_SAMPLE_TABLE_4_DEDUPED 
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_4
GO--209 (DOWN FROM ~650)

--ANY FURTHER DATA INSERTED INTO THIS TABLE WILL AUTOMATICALLY IGNORE AND NOT INSERT ROWS WITH DUPLICATE COMPANY VALUES

--YOU CAN ALSO DROP THIS INDEX THE USUAL WAY
DROP INDEX UNIQUE_INDEX 
ON SQL_NOTES_SAMPLE_TABLE_4_DEDUPED
GO

----------------
--Triggers
----------------
--Triggers are special stored procedures that are executre automatically when specific database activity occurs
--Triggers can be associated with INSERT, UPDATE an DELETE Statements
--Triggers, unlike Stored Procedures, are tied to specific tables

--use cases: 
	--converting all customer names to UPPER on INSERT or UPDATE
	--updating timestamps, updating calculations
	--etc...

CREATE TRIGGER CASE_TRIGGER 
ON SQL_NOTES_SAMPLE_TABLE_4_DEDUPED
FOR INSERT, UPDATE
AS
UPDATE SQL_NOTES_SAMPLE_TABLE_4_DEDUPED
SET COMPANY=UPPER(COMPANY)
go


--now to test it
INSERT INTO SQL_NOTES_SAMPLE_TABLE_4_DEDUPED(COMPANY) 
VALUES('test company')
go
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_4_DEDUPED
WHERE COMPANY='test company'
GO--RETURNS 'TEST COMPANY'

--AND TO DROP
DROP TRIGGER CASE_TRIGGER
GO