--------------------------------------------
--------------- PROCEDURES -----------------
--------------------------------------------
----CREATE PROCEDURE  procedure_name
----    -- The variable parameter in/out
----    {@parameter data_type  input/output }
----AS 
----Begin
----    [Declare variables for processing]
----    {Transact-SQL statements} 
----End
--- EXECUTE procedure_name --> Stored-proc nonparametric
--- EXEC procedure_name Para1_value, Para2_value,… 
-----> Stored-proc with parameters

IF OBJECT_ID('dbo.Say') IS NOT NULL
	DROP PROCEDURE dbo.Say
GO
CREATE PROCEDURE dbo.Say
AS
BEGIN
	PRINT 'Hello world from SQL!'
END
GO
EXECUTE dbo.Say;
GO

--------------------------------------------------
------ PROCEDURE GENERATE USER AND PASSWORD ------
IF OBJECT_ID('dbo.randNumber') IS NOT NULL
	DROP VIEW dbo.randNumber
GO
CREATE VIEW dbo.randNumber
AS
	SELECT RAND() AS RandNumber
GO
IF OBJECT_ID('dbo.randbetween') IS NOT NULL
	DROP FUNCTION dbo.randbetween
GO
CREATE FUNCTION dbo.randbetween(@first INT, @second INT)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
	DECLARE @x INT = @first
	DECLARE @y INT = @second
	
	IF @first > @second
	BEGIN
		SET @y = @first
		SET @x = @second
	END
	
	RETURN (SELECT CAST(ROUND((@y - @x) * randNumber + @first, 0) AS INTEGER) FROM dbo.randNumber)
END
GO

IF OBJECT_ID('dbo.GeneratePassword') IS NOT NULL
	DROP FUNCTION dbo.GeneratePassword
GO
CREATE FUNCTION dbo.GeneratePassword()
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @randInt INT;
	DECLARE @NewCharacter VARCHAR(1); 
	DECLARE @NewPassword VARCHAR(10); 
	SET @NewPassword = '';

	--6 random characters
	WHILE (LEN(@NewPassword) <6)
	BEGIN
		SELECT @randInt = dbo.randbetween(48,122)
		--         0-9                   < = > ? @ A-Z [ \ ]                   a-z      
		IF (@randInt <= 57) OR (@randInt >= 60 AND @randInt <= 93) OR (@randInt >= 97 AND @randInt <= 122)
		BEGIN
			SELECT @NewCharacter = CHAR(@randInt)
			SELECT @NewPassword = @NewPassword + @NewCharacter
		END
	END
	
	--Ensure a lowercase
	SELECT @NewCharacter = CHAR(dbo.randbetween(97,122))
	SELECT @NewPassword = @NewPassword + @NewCharacter
  
	--Ensure an upper case
	SELECT @NewCharacter = CHAR(dbo.randbetween(65,90))
	SELECT @NewPassword = @NewPassword + @NewCharacter
  
	--Ensure a number
	SELECT @NewCharacter = CHAR(dbo.randbetween(48,57))
	SELECT @NewPassword = @NewPassword + @NewCharacter
  
	--Ensure a symbol
	WHILE (LEN(@NewPassword) <10)
	BEGIN
		SELECT @randInt = dbo.randbetween(33,64)
		--           !               # $ % &                            < = > ? @
		IF @randInt=33 OR (@randInt>=35 AND @randInt<=38) OR (@randInt>=60 AND @randInt<=64) 
		BEGIN
			SELECT @NewCharacter = CHAR(@randInt)
			SELECT @NewPassword = @NewPassword + @NewCharacter
		END
	END

	RETURN(@NewPassword);
END
GO

IF OBJECT_ID('dbo.Generate') IS NOT NULL
	DROP PROC dbo.Generate;
GO
CREATE PROC dbo.Generate
	@NUSER INT
AS
BEGIN
	CREATE TABLE #Account(UserID VARCHAR(6) PRIMARY KEY NOT NULL, UserPassword VARCHAR(10) NOT NULL)
	DECLARE @i INT = 1
	WHILE @i < @NUser
	BEGIN
		INSERT #Account VALUES ('RU' + CONVERT(VARCHAR(4), @i) , dbo.GeneratePassword());
		SET @i = @i + 1
	END
	
	SELECT * FROM #Account
	DROP TABLE #Account
END
GO
EXEC dbo.Generate 10;
GO

------------------------------------------------------------
------------------ PROCEDURE WITH CURSORS ------------------
------------------------------------------------------------

IF OBJECT_ID('dbo.ListPersonUsingCursor') IS NOT NULL
	DROP PROC dbo.ListPersonUsingCursor
GO
CREATE PROC dbo.ListPersonUsingCursor
AS
BEGIN
	DECLARE @total INT  = (SELECT COUNT(*) FROM [Family].[dbo].[Person])
	DECLARE @counter INT = 1, @PersonID INT, @PersonName VARCHAR(20), @Age INT
	DECLARE cs_Person CURSOR
	GLOBAL
	FOR
		SELECT	PersonID, 
				FirstName + ' ' + LastName AS PersonName,
				DATEDIFF(YEAR, DateOfBirth, DateOfDeath) AS [PersonAge]
		FROM [Family].[dbo].[Person]
		WHERE DateOfDeath IS NOT NULL AND DATEDIFF(YEAR, DateOfBirth, DateOfDeath) > 0;
	
	-- opening cursor
	OPEN cs_Person;
	-- read first data
	FETCH NEXT FROM cs_Person INTO @PersonID, @PersonName, @Age;
	PRINT 'Person #' + CAST(@counter AS VARCHAR(2)) + ' (ID: ' + CAST(@PersonID AS VARCHAR) +
					   ', Name: ' + @PersonName + ', Age: ' + CAST(@Age AS VARCHAR);
	
	-- looping to the end
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		SELECT @counter = @counter + 1
		FETCH NEXT FROM cs_Person INTO @PersonID, @PersonName, @Age;
		IF (@@FETCH_STATUS = 0)
		PRINT 'Person #' + CAST(@counter AS VARCHAR(2)) + ' (ID: ' + CAST(@PersonID AS VARCHAR) +
					              ', Name: ' + @PersonName + ', Age: ' + CAST(@Age AS VARCHAR);
	END;
	CLOSE cs_Person;
	DEALLOCATE cs_Person;
END
GO
EXECUTE dbo.ListPersonUsingCursor;
GO

------------------------------------------------------------
------------------ PROCEDURE WITH OTB ----------------------
------------------------------------------------------------
IF OBJECT_ID('dbo.ListPersonRecursive') IS NOT NULL
	DROP PROC dbo.ListPersonRecursive
GO
CREATE PROC dbo.ListPersonRecursive
AS
	WITH Infor(FatherID, MotherID, PersonID) AS
	(
		SELECT FatherID, MotherID, PersonID
		FROM [Family].[dbo].[Person]
		WHERE FatherID IS NOT NULL AND MotherID IS NOT NULL
		UNION ALL
		SELECT FirstPerson.FatherID, FirstPerson.MotherID, FirstPerson.PersonID
		FROM [Family].[dbo].[Person] AS FirstPerson
		INNER JOIN [Family].[dbo].[Person] AS SecondPerson ON FirstPerson.FatherID = SecondPerson.PersonID
		INNER JOIN [Family].[dbo].[Person] AS ThirdPerson ON FirstPerson.MotherID = ThirdPerson.PersonID
		WHERE FirstPerson.FatherID IS NOT NULL AND FirstPerson.MotherID IS NOT NULL
	)
	SELECT DISTINCT * FROM Infor ORDER BY MotherID
GO
EXECUTE dbo.ListPersonRecursive;
GO

------------------------------------------------------------
--------- PROCEDURE WITH DBCC DBREINDEX --------------------
------------------------------------------------------------
DROP TABLE [MyObjectList]
CREATE TABLE [MyObjectList]
(
	[DBName][sysname] NOT NULL,
	[Object_Type][varchar](20) NULL,
	[Object_Create_Date][varchar](10) NOT NULL,
	[Object_Modify_Date][varchar](10) NOT NULL
);
GO

ALTER TABLE MyObjectList ADD CONSTRAINT PK_DbName PRIMARY KEY(DBName);
GO

IF OBJECT_ID('Object_owned_by_none_dbo') IS NOT NULL
	DROP PROC Object_owned_by_none_dbo;
GO
CREATE PROC Object_owned_by_none_dbo
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE cs_DBName CURSOR
	FOR
	SELECT	name AS dbName,
			CASE type
				WHEN 'U' THEN 'Table'
				WHEN 'V' THEN 'View'
				WHEN 'FN' THEN 'Function'
				WHEN 'P' THEN 'Procedure'
				WHEN 'IF' THEN 'T-Funtion'
				WHEN 'SQ' THEN 'Queue Event'
				WHEN 'IT' THEN 'Queue messages'
				WHEN 'PK' THEN 'Primary key'
				WHEN 'D' THEN 'Default'
				WHEN 'S' THEN 'sys'
			ELSE 'unknown'
			END AS dType,
		    CONVERT(VARCHAR(10), create_date, 103) AS dCt,
			CONVERT(VARCHAR(10), modify_date, 103) AS dMd
	FROM sys.objects
	WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')
	ORDER BY name ASC;
	
	OPEN cs_DBName;
	DECLARE @dbName sysname, @dType VARCHAR(20), @dCt VARCHAR(10), @dMd VARCHAR(10);
	FETCH NEXT FROM cs_DBName INTO @dbName, @dType, @dCt, @dMd;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO MyObjectList(DBName, Object_Type, Object_Create_Date, Object_Modify_Date)  
		VALUES(@dbName, @dType, @dCt, @dMd);
		--DBCC DBREINDEX(MyObjectList, PK_DbName, 70);
		FETCH NEXT FROM cs_DBName INTO @dbName, @dType, @dCt, @dMd;
	END;
	
	CLOSE cs_DBName;
	DEALLOCATE cs_DBName;
	SET NOCOUNT OFF;
END
GO

EXEC Object_owned_by_none_dbo;
GO

SELECT * FROM MyObjectList;
GO

DBCC DBREINDEX(MyObjectList, PK_DbName, 90);
GO

DROP TABLE [MyObjectList]
GO
