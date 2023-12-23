/************************************************************************
SQL NOTES PART 1
Following Sams Teach Yourself SQL in 10 Minutues by Ben Forta


TOC
LESSON 1 - Understand SQL
LESSON 2 - Retreiving Data
	SELECT * FROM
	DISTINCT
	SELECT TOP
	COMMENTS
LESSON 3 - Sorting Retreived Data
	ORDER BY
	ASC, DESC
LESSON 4 - Filtering Data
	WHERE
	BETWEEN, IS NULL
LESSON 5 - Advanced Filtering Data
	AND, OR, NOT, IN
LESSON 6 - Wildcard Filtering
	LIKE
	wildcards:%, _, []
LESSON 7 and 8 - Creating Calculated Fields / Using Data Manipulation Functions
	Aliases, AS
	TEXT
	DATE AND TIME
	NUMERIC
LESSON 9 - Summarizing Data
	AVG(), COUNT(), SUM(), etc...
	aggregates on distinct values
LESSON 10 - Grouping Data
	GROUP BY
	HAVING
CLAUSE ORDERING

************************************************************************/


--SQL04
USE TEMP_OK
GO

--SQL_NOTES_SAMPLE_TABLE_1 is GPPO245478_1_RAW


/************************************************************************
LESSON 1 
Understand SQL

SQL stands for Structured Query Language (pronounced sequel for short)
SQL is a language designed specifically for communitating with databases

Database - collection of daa sotre in some organized fashion (eg a filing cabinet)
Tables - a structured file that can store data of a specific type (eg a file within a filing cabinet)
Columns - tables are made up of columns. a column contains a particular piece of information within a table. also called a field
Datatype - a type of allowed data. every column has an associated datatype that restricts/allows specific data in that column
Rows - a record in a table

Primary Keys - column(s) whoese values uniquely identify every row in a table. cannot be NULL, must be unique, must never be modified, should not be reused
************************************************************************/


/************************************************************************
LESSON 2
Retreiving Data

Keyword - a reserved word that is part of the SQL lamguage (eg SELECT, FROM, WHERE etc...)
************************************************************************/
--The SELECT statement
--to retreive table data must specify what you want to select and where you want to select it from

--Selecting all columns from a table
SELECT *
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--you can end each statement with a semi-colon, or split them with GO statements
--you can also choose to keep the statement on a single or multiple lines
--SELECT * FROM SQL_NOTES_SAMPLE_TABLE_1 is just as valid as the above example

--Selecting specific columns from a table
SELECT COMPANY,TITLE
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--Selecting distinct rows based on 1 column
SELECT DISTINCT TITLE
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--Selecting distinct rows on multiple column
SELECT DISTINCT COMPANY, TITLE
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--Limiting Results (not random, but the order is arbitrary)
SELECT TOP(10) *
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--You can have single comment in SQL using--
/*
and you can have
Multi Line comment in SQL using /* */
*/


/************************************************************************
LESSON 3
Sorting Retreived Data
************************************************************************/
--Select all columns from table and order them by the COMPANY column
SELECT *
FROM SQL_NOTES_SAMPLE_TABLE_1
ORDER BY COMPANY
GO

--You can sort by multiple columns, the first one listed takes precedence
SELECT *
FROM SQL_NOTES_SAMPLE_TABLE_1
ORDER BY COMPANY, TITLE
GO

--You can also sort by column position (this is the same as ORDER BY COMPANY, because COMPANY is the 1st col)
SELECT *
FROM SQL_NOTES_SAMPLE_TABLE_1
ORDER BY 1
GO

--Specifying Sort Direction
--this can be applied at will on each ORDER BY column
SELECT *
FROM SQL_NOTES_SAMPLE_TABLE_1
ORDER BY COMPANY DESC, TITLE ASC
GO


/************************************************************************
LESSON 4
Filtering Data
************************************************************************/
--Use the WHERE clause to filter data
SELECT *
FROM SQL_NOTES_SAMPLE_TABLE_1
WHERE CITY = 'GRAND RAPIDS'
GO

--WHERE CLAUSE OPERATORS (with examples)
-- = EQUALITY
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_1 WHERE CITY = 'GRAND RAPIDS'
GO
-- <> NON-EQUALITY (!= also works)
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_1 WHERE CITY <> 'GRAND RAPIDS'
GO
-- <, <=, >, >= lesser than, lesser/equal, greater than, greater/equal
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_1 WHERE CITY < 'G'
GO
-- !< not lesser than, !> not greater than
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_1 WHERE CITY !< 'G'
GO
-- BETWEEN
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_1 WHERE CITY BETWEEN 'A' AND 'C'
GO
-- IS NULL / IS NOT NULL
SELECT * FROM SQL_NOTES_SAMPLE_TABLE_1 WHERE CITY IS NULL
GO


/************************************************************************
LESSON 5
Advanced Filtering Data
************************************************************************/
--You can combine WHERE clauses using AND / OR
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE CITY = 'New York' AND TITLE = 'DIRECTOR' -- Both must be true
GO
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE CITY = 'New York' OR TITLE = 'DIRECTOR' -- Only one must be true
GO
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE (CITY = 'New York' OR CITY = 'Austin') AND TITLE = 'OFFICE MANAGER' -- Use parantheses to get more specific
GO
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE NOT TITLE = 'DIRECTOR' -- Use NOT to negate a condition
GO
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE CITY IN ('GRAND RAPIDS', 'AUSTIN') -- IN functions like an OR in parantheses
GO


/************************************************************************
LESSON 6
Wildcard Filtering

Wildcard - special characters used to match parts of a value
Search Pattern - search condition made up of literal text, wildcard characters, or any combo of them
************************************************************************/
-- Using LIKE lets you use search patterns
--% is the wildcard
--% can represent any character any number of times
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE COMPANY LIKE '%NEW%' --can have NEW anywhere in the value (% at both ends)
GO
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE COMPANY LIKE 'AD%' --must start with AD (% at end)
GO
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE COMPANY LIKE '%ING' --must end with ING (% at start)
GO
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE COMPANY LIKE 'A%D%ING' --a more complicated example
GO

SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE TITLE LIKE 'C_O' --the underscore _ is the same as the % but matches only a single character
GO
SELECT * 
FROM SQL_NOTES_SAMPLE_TABLE_1 
WHERE COMPANY LIKE '[AB]%' --use brackets to specify a set of characters (can start with A or B)
GO


/************************************************************************
LESSON 7 and 8
Creating Calculated Fields / Using Data Manipulation Functions

-some of these functions may not be supported by all DBMSs, or they may have different names

************************************************************************/

--Data stored in a table is often not available in the exact format you need
--Calculated fields let you reformat the data in many ways

--You can use aliases to rename normal columns, but they're especially useful to rename calculated columns
--Create an alias using the AS keyword
--each of the below examples will use aliases

---------------------------------------
-- TEXT
---------------------------------------

--CONCAT
--short for Concatentate, combine multiple pieces of text
SELECT [ADDRESS] + ' ' + CITY + ', ' + [STATE] + ' ' + ZIP AS FULL_ADDRESS_USING_PLUS 
FROM SQL_NOTES_SAMPLE_TABLE_1
GO
SELECT CONCAT([ADDRESS],  ' ', CITY, ' ', [STATE], ' ',  ZIP) AS FULL_ADDRESS_USING_CONCAT 
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--TRIM
--removes whitespace at the edges of a string, 3 variatiosn TRIM(), RTRIM(), LTRIM()
--RTRIM removes from the rigt end, LTRIM the left, TRIM from both
SELECT 
	TRIM([ADDRESS]) AS [TRIM]
	, RTRIM([ADDRESS]) AS [RTRIM]
	, LTRIM([ADDRESS]) AS [LTRIM] 
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--UPPER, LOWER (changes the case)
SELECT 
	UPPER(CITY) as [UPPER]
	, LOWER(CITY) as [lower] 
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--LEN (length of the string)
SELECT 
	CITY
	, LEN(CITY) AS CITY_LENGTH 
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--SUBSTRING
SELECT
	CITY
	, SUBSTRING(CITY, 1, 2) AS CITY_SUBSTR
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--CHARINDEX, PATINDEX, REPLACE, STUFF
SELECT 
	COMPANY
	, CHARINDEX('O', COMPANY) AS [CHAR]
	, PATINDEX('%ING', COMPANY) AS [PAT]
	, REPLACE(COMPANY, 'O', 'A') AS [REPLACE]
	, STUFF(COMPANY, PATINDEX('%ING', COMPANY), 3, 'A') AS [STUFF]
FROM SQL_NOTES_SAMPLE_TABLE_1
GO

---------------------------------------
-- DATE AND TIME
---------------------------------------
--Current Date/Time
SELECT CURRENT_TIMESTAMP, SYSDATETIME(), GETDATE()

--DATEPART
--gets a specified part of a date
SELECT DATEPART(YEAR, '1/3/2012'), DATEPART(MONTH, '1/3/2012'), DATEPART(DAY, '1/3/2012')
--same as YEAR(date), MONTH(date), DAY(date)

---------------------------------------
-- NUMERIC
---------------------------------------
SELECT 
	[TITLE ID]
	, [TITLE ID] + 1 AS ADDITION 
	, [TITLE ID] % 5 AS MODULO 
FROM SQL_NOTES_SAMPLE_TABLE_1
GO --you can use +,-,*,/,% for addition, subtraction, multiplication, division, modulo (remainder)

SELECT 
	ABS(-1) --ABSOLUTE VALUE
	,CEILING(5.5) --ROUND UP
	,FLOOR(5.5) --ROUND DOWN
	,ROUND(5.5, 0) --ROUND CLOSEST TO X DECIMAL PLACES
	,SQRT(4) --SQUARE ROOT
	,SQUARE(4)
	,POWER(4, 2)
	,PI()


/************************************************************************
LESSON 9
Summarizing Data

Aggregate Functions - functions that operate on a set of rows to calculate and return a single value
************************************************************************/
SELECT AVG(CAST([TITLE ID] AS FLOAT)) FROM SQL_NOTES_SAMPLE_TABLE_1
GO
SELECT COUNT([TITLE ID]) FROM SQL_NOTES_SAMPLE_TABLE_1
GO
SELECT MAX(CAST([TITLE ID] AS INT)) FROM SQL_NOTES_SAMPLE_TABLE_1
GO
SELECT MIN(CAST([TITLE ID] AS INT)) FROM SQL_NOTES_SAMPLE_TABLE_1
GO
SELECT SUM(CAST([TITLE ID] AS INT)) FROM SQL_NOTES_SAMPLE_TABLE_1
GO
SELECT RIGHT([TITLE ID], 5), LEFT([TITLE ID], 5) FROM SQL_NOTES_SAMPLE_TABLE_1
GO

--aggregates on distinct values
SELECT AVG(DISTINCT CAST([TITLE ID] AS FLOAT)) FROM SQL_NOTES_SAMPLE_TABLE_1
GO


/************************************************************************
LESSON 10
Grouping Data
************************************************************************/
--GROUP BY + AGGREGATE
SELECT [TITLE ID], COUNT(*) AS [TITLE ID COUNT]
FROM SQL_NOTES_SAMPLE_TABLE_1
GROUP BY [TITLE ID]
ORDER BY COUNT(*) DESC
GO
--HAVING
SELECT [TITLE ID], COUNT(*) AS [TITLE ID COUNT]
FROM SQL_NOTES_SAMPLE_TABLE_1
GROUP BY [TITLE ID]
HAVING COUNT(*) > 5
ORDER BY [TITLE ID]
GO



/************************************************************************
CLAUSE ORDERING

CLAUSE     / DESCRIPTION                       / REQUIRED
---------------------------------------------------------------------------------------------------
SELECT      Columns/Expresions to be returned    YES
FROM        Table to retrieve data from          Only if selecting data from a table
WHERE       Row-level filtering                  NO
GROUP BY    Group specification                  Only if calculating aggregates by group
HAVING      Group-level filtering                NO
ORDER BY    Output sort order                    NO
************************************************************************/
