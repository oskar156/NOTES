/************************************************************************
SQL NOTES PART 2
Following Sams Teach Yourself SQL in 10 Minutues by Ben Forta


TOC
LESSON 11 - Working with Subqueries
LESSON 12 and 13 - Creating a Join / Creating Advanced Joins
	INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN
	Multiple Join
	Self Join
	Joins and aggregate functions
LESSON 14 - Combining Queries
	UNION
LESSON 15 - Inserting Data
	INSERT INTO
	VALUES
	INTO
LESSON 16 - Updating and Deleting Data
	UPDATE SET
	DELETE FROM
	TRUNCATE TABLE
LESSON 17 - Creating and Manipulating Tables
	CREATE TABLE
	ALTER TABLE, ADD, DELETE COLUMN
	SP_RENAME (rename a table)
	DROP TABLE (delete a table)
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

/************************************************************************
LESSON 11
Working with Subqueries

Query - Any SQL statement, usually refers to SELECT statemetn
Subquery - queries that are embedded into other queries
************************************************************************/
--Filtering by Subquery
--you can match data in related tables
--below we're looking for VERIFIED EMAILS, the VERIFIED data is not stored in the _1 table, but the _2 table, so we use the common column of EMAIL to look it up
SELECT *
FROM SQL_NOTES_SAMPLE_TABLE_1
WHERE EMAIL IN (SELECT EMAIL FROM SQL_NOTES_SAMPLE_TABLE_2 WHERE ValidationStatusId='VERIFIED') -- it's SELECT EMAIL in the sub query, not SELECT *
GO

--Using subqueries as calculated fields
--Number of Verified emails per TITLE
--TITLE must exist in both tables
SELECT 
	SQL_NOTES_SAMPLE_TABLE_1.TITLE
	, (SELECT COUNT(*) 
	   FROM SQL_NOTES_SAMPLE_TABLE_2
	   WHERE SQL_NOTES_SAMPLE_TABLE_1.TITLE=SQL_NOTES_SAMPLE_TABLE_2.TITLE AND SQL_NOTES_SAMPLE_TABLE_2.ValidationStatusId='VERIFIED')
FROM SQL_NOTES_SAMPLE_TABLE_1
GO


/************************************************************************
LESSON 12 and 13
Creating a Join / Creating Advanced Join s

Before using joins, you must understand Relational Tables:

Relational Tables 
	-designed so that information is split into multiple tables one for each data type (eg Orders, Shipments, Customers, Products etc...)
	-The tables relate to eachother through common values
	-this way, information never gets repeated
	-if data is updated you only need to update it one place
	-relational tables scale well

JOINS ALLOW YOU  TO RETRIEVE DATA WITHIN MULTIPLE TABLES IN A SINGLE SELECT STATEMENT

************************************************************************/

--YOU CAN CREATE JOINS USING THE JOIN KEYWORD OR JUST USING WHERE CLAUSES
--ONLY THE FIRST EXAMPLE WILL SHOW THE WHERE EXAMPLE, THE REST WILL USE THE JOIN KEYWORD

--think of each join like a different type of venn diagram look at this image: https://www.codeproject.com/KB/database/Visual_SQL_Joins/Visual_SQL_JOINS_V2.png
--it's not totally accurate to call joins venn diagrams, but it does help in some ways. there are times where it isn't true though

--INNER JOIN            --Middle
SELECT A.EMAIL, B.ValidationStatusId
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A INNER JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL --RETURNS ONLY IF EMAIL IS IN BOTH
GO
SELECT A.EMAIL, B.ValidationStatusId
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A, SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
WHERE A.EMAIL=B.EMAIL --WHERE EXAMPLE
GO

--LEFT JOIN             --Left + Middle
SELECT A.EMAIL, B.ValidationStatusId
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A LEFT JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL --RETURNS ALL OF A AND GETS WHAT IT CAN FROM B, IF NO MATCH THEN NULL
GO

--LEFT OUTER JOIN       --Left
SELECT A.EMAIL, B.ValidationStatusId
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A LEFT JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL --RETURNS ONLY THE RECORDS THAT DON'T MATCH FROM B
WHERE B.EMAIL IS NULL
GO

--RIGHT JOIN            --Right + Middle
SELECT A.EMAIL, B.ValidationStatusId
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A RIGHT JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL --RETURNS ALL OF B AND GETS WHAT IT CAN FROM A, IF NO MATCH THEN NULL
GO

--RIGHT OUTER JOIN      --Right
SELECT A.EMAIL, B.ValidationStatusId
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A RIGHT JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL --RETURNS ONLY THE RECORDS THAT DON'T MATCH FROM B --nothing because all of B is in A
WHERE A.EMAIL IS NULL
GO
SELECT B.EMAIL
FROM SQL_NOTES_SAMPLE_TABLE_2_BAD AS A RIGHT JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL --ALL THE EMAILS IN B NOT IN A (WHICH IS ALL OF THEM)
WHERE A.EMAIL IS NULL
GO

--FULL OUTER JOIN       --Left + Right
SELECT A.EMAIL AS BAD_EMAILS, B.EMAIL AS GOOD_EMAILS
FROM SQL_NOTES_SAMPLE_TABLE_2_BAD AS A FULL OUTER JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL
WHERE A.EMAIL IS NULL OR B.EMAIL IS NULL
GO

--FULL JOIN             --Left + Middle + Right
SELECT A.EMAIL, B.ValidationStatusId
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A FULL OUTER JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL
GO

--MULTIPLE JOIN
SELECT A.EMAIL, B.ValidationStatusId AS GOOD, C.ValidationStatusId AS OK, D.ValidationStatusId AS BAD
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A 
	LEFT JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B ON A.EMAIL=B.EMAIL
	LEFT JOIN SQL_NOTES_SAMPLE_TABLE_2_OK AS C ON A.EMAIL=C.EMAIL
	LEFT JOIN SQL_NOTES_SAMPLE_TABLE_2_BAD AS D ON A.EMAIL=D.EMAIL
GO

--SELF JOIN
--for example: FINDING ALL THE EMPLOYEES AT THE COMPANY WHERE LINDSAY BENEDICT WORKS AT
--THIS IS EASY IN 2 STATEMENTS, BUT IS A BIT TRICKY IN 1 STATEMENT, YOU CAN DO IT WITH A SELF JOIN
SELECT EMAIL, COMPANY, [FIRST],[LAST]
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE COMPANY=(SELECT COMPANY FROM SQL_NOTES_SAMPLE_TABLE_1 WHERE [FIRST]='LINDSAY' AND [LAST]='BENEDICT')

--JOINS AND AGGREGATE FUNCTIONS
--find all title with more than 3 valid emails
SELECT A.TITLE, COUNT(B.ValidationStatusId)
FROM SQL_NOTES_SAMPLE_TABLE_1 AS A LEFT JOIN SQL_NOTES_SAMPLE_TABLE_2_VALIDS AS B
ON A.EMAIL=B.EMAIL --RETURNS ONLY THE RECORDS THAT DON'T MATCH FROM B
GROUP BY A.TITLE
HAVING COUNT(B.ValidationStatusId) > 3
GO


/************************************************************************
LESSON 14
Combining Queries
************************************************************************/
--you can combine multiple SELECT queries with UNION
	--unions must be composed of 2+ SELECT statements separated by UNION
	--each query in an UNION must contain the same columns
	--column datatypes must be compatible
	--UNION automatically removes any duplicates in the data
SELECT EMAIL FROM SQL_NOTES_SAMPLE_TABLE_2_VALIDS
UNION
SELECT EMAIL FROM SQL_NOTES_SAMPLE_TABLE_2_OK
UNION
SELECT EMAIL FROM SQL_NOTES_SAMPLE_TABLE_2_BAD
UNION
SELECT EMAIL FROM SQL_NOTES_SAMPLE_TABLE_2
Order by EMAIL


/************************************************************************
LESSON 15
Inserting Data
************************************************************************/

--INSERTING INTO AN EXISTING TABLE
INSERT INTO SQL_NOTES_SAMPLE_TABLE_1 
VALUES ('COMPANY','BOB','JONSON','THE BOSS',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
GO--MUST INERT VALUES IN THE SAME ORDER AS THE TABLE, THIS IS CONSIDERED VERY UNSAFE BECAUSE YOURE BLINDLY ENTERING THE DATA

INSERT INTO SQL_NOTES_SAMPLE_TABLE_1 
	([COMPANY],[FIRST],[LAST],[TITLE],[TITLE GROUP],[TITLE ID],[ACTUAL TITLE GROUP],[ADDRESS 1],[ADDRESS 2],[CITY],[STATE],[COUNTY],[ZIP],[ZIP4],[EMAIL],[EMAIL DOMAIN]
	,[PHONE],[SALES],[EMPLOYEES],[SICCODE],[SICDESCRIPTION],[SOURCE],[SOURCE_PRIORITY],[MKEY],[ADDRESS],[UNIQUE_ID])
VALUES 
	('COMPANY','GREG','JONES',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)
GO--THIS IS MORE CUMBERSOME, BUT YOURE EXPLICITYLY SAYING WHICH COLUMN SHOULD GET WHICH PIECE OF DATA. THIS IS RECOMMENDED, IT'S ALSO NOT DEPENDENT ON COLUMN ORDER

INSERT INTO SQL_NOTES_SAMPLE_TABLE_1 ([COMPANY],[FIRST],[LAST])
VALUES ('COMPANY','SARAH','SMITH')
GO--USING A COLUMN LIST IN INSERT INTO LETS YOU INSERT A PARTIAL COLUMN, THE UNLISTED COLUMNS WILL BE NULL

INSERT INTO SQL_NOTES_SAMPLE_TABLE_3 ([COMPANY],[FIRST],[LAST]) 
SELECT [COMPANY],[FIRST],[LAST] 
FROM SQL_NOTES_SAMPLE_TABLE_1
GO--INSERTING SPECIFIC COLUMNS FROM RETRIEVED DATA
INSERT INTO SQL_NOTES_SAMPLE_TABLE_3
SELECT *
FROM SQL_NOTES_SAMPLE_TABLE_1
GO--INSERTING AN ENTIRE TABLE, NOT THE ERROR, THE TABLES MUST HAVE THE EXACT SAME LAYOUT FOR THIS TO WORK

--COPYING AN ENTIRE TABLE TO ANOTHER NEW TABLE
SELECT *
INTO SQL_NOTES_SAMPLE_TABLE_4
FROM SQL_NOTES_SAMPLE_TABLE_1
GO


/************************************************************************
LESSON 16
Updating and Deleting Data
************************************************************************/

--*** BE CAREFUL WHEN USING UPDATE! IF YOU DON'T SPECIFY A WHERE CLAUSE IN THE UPDATE STATEMENT, THE ENTIRE COLUMN WILL BE UPDATED!

UPDATE SQL_NOTES_SAMPLE_TABLE_4
SET [TITLE ID]='5'
WHERE TITLE='MANAGER'
GO

--YOU CAN UPDATE MULTIPLE COLUMNS AT ONCE
UPDATE SQL_NOTES_SAMPLE_TABLE_4
SET 
	[TITLE ID]='5'
	,[TITLE GROUP]='MANAGEMENT'
WHERE TITLE='MANAGER'
GO

--UPDATING ACROSS TABLES
--blanking out bad emails
UPDATE SQL_NOTES_SAMPLE_TABLE_4
SET EMAIL=NULL
WHERE EMAIL IN (SELECT EMAIL FROM SQL_NOTES_SAMPLE_TABLE_2_BAD)
GO
--now bring those emails back
UPDATE A
SET A.EMAIL=B.EMAIL
FROM SQL_NOTES_SAMPLE_TABLE_4 AS A, SQL_NOTES_SAMPLE_TABLE_2_BAD AS B
WHERE A.EMAIL IS NULL
GO

--DELETEING DATA
--deletes entire rows, can potentially delete all rows in a table, but will never delete the table
DELETE FROM SQL_NOTES_SAMPLE_TABLE_4
WHERE [TITLE ID]='12'
GO

--TRUNCATE TABLE will delete all rows in a table, but not the table itself
--you can do the same thing with DELETE FROM
--TRUNCATE TABLE SQL_NOTES_SAMPLE_TABLE_4


/************************************************************************
LESSON 17
Creating and Manipulating Tables
************************************************************************/
--Creating a new table
CREATE TABLE SQL_NOTES_SAMPLE_TABLE_5
(
	[COMPANY] VARCHAR(255)
	,[FIRST] VARCHAR(255)
	,[LAST] VARCHAR(255)
	,[EMAIL] VARCHAR(255)
	,AGE INT NULL
	,POSITION VARCHAR(255) NOT NULL
	,[STATUS] VARCHAR(255) NULL DEFAULT 'UNKNOWN'
	,PAY decimal(10,2) NOT NULL DEFAULT 0
)
/* CREATE TABLE SYNTAX
CREATE TABLE [TABLE NAME]
(
	[COLUMN NAME] / DATATYPE / (optional) NULL / (optional) DEFAULT VALUE
)

-each column has NULL by default
-so specifying NULL does nothing
-specifying NOT NULL prevents that column from accepting NULLs - if you try to insert a NULL in that column it will fail and run into an error

-if you excplicity enter a NULL into a column with a DEFAULT VALUE, then it will still be NULL
-if you insert a row into a table and leave a column with a DEFAULT VALUE off the INSERT INTO column list, then it will use the DEFAULT VALUE
*/

INSERT INTO SQL_NOTES_SAMPLE_TABLE_5 VALUES('','','','',0,'','',0)--works
INSERT INTO SQL_NOTES_SAMPLE_TABLE_5 VALUES('','','','',0,'',NULL,0)--works
INSERT INTO SQL_NOTES_SAMPLE_TABLE_5 VALUES('','','','',0,NULL,'',NULL)--results in error bc of POSITION and PAY NOT NULL
INSERT INTO SQL_NOTES_SAMPLE_TABLE_5 VALUES('','','','',0,'',NULL,0)--works, STATUS is NULL
INSERT INTO SQL_NOTES_SAMPLE_TABLE_5(company,POSITION) VALUES('','')--works, STATUS is UNKNOWN, the default value, POSITION and PAY default to '' and 0.00

--altering a table, add a new column
ALTER TABLE SQL_NOTES_SAMPLE_TABLE_5
ADD NOTES VARCHAR(255)
GO

--altering a table, dropping a column
ALTER TABLE SQL_NOTES_SAMPLE_TABLE_5
DROP COLUMN NOTES
GO

--re-naming a table
--this is handeled different by every DBMS
--here, it's:
SP_RENAME SQL_NOTES_SAMPLE_TABLE_5, SQL_NOTES_SAMPLE_TABLE_5B
GO--SP_RENAME OLD_NAME NEW_NAME

--deleting a table
DROP TABLE SQL_NOTES_SAMPLE_TABLE_5B
GO
