-------------------------------------------------
-------------- 6. User-Defined Types ------------
-------------------------------------------------
USE Sharp;
GO

DROP TYPE dbo.IVector;
DROP ASSEMBLY UDT;
GO

CREATE ASSEMBLY UDT
FROM 'D:\BigDATA\SQL 4\User-Defined Types\User-Defined Types\bin\Debug\User-Defined Types.dll'
WITH PERMISSION_SET = SAFE;
GO

CREATE TYPE dbo.IVector EXTERNAL NAME UDT.Vector;
GO

IF OBJECT_ID('dbo.Vector') IS NOT NULL
	DROP TABLE dbo.Vector;
GO
CREATE TABLE dbo.Vector
(
	ID INT IDENTITY(1,1) NOT NULL,
	Value IVector NULL
)
GO

------------------------------------------------
------------------ TEST UDT --------------------
------------------------------------------------
-- Testing inserts
INSERT INTO dbo.Vector(Value) VALUES('2,3'); 
INSERT INTO dbo.Vector(Value) VALUES('7,0');
INSERT INTO dbo.Vector(Value) VALUES('3,4');
GO

-- Check the data - byte stream
SELECT * FROM Vector;
GO

-- An incorrect value 
INSERT INTO dbo.Vector VALUES('1.12, 5');
INSERT INTO dbo.Vector VALUES('(1, 5)');
INSERT INTO dbo.Vector VALUES('[4, 5]');
GO

-- Use default string representation
SELECT ID, Value.ToString() AS Value 
FROM dbo.Vector;
GO

-- Test NULLs
INSERT INTO dbo.Vector VALUES(NULL); 
 
SELECT ID, 
	   Value.ToString() AS Value,  
	   Value.X AS [X], 
	   Value.Y AS [Y]
FROM dbo.Vector;
GO

-------------------------------------------------------
------------- Test methods (operations) ---------------
-------------------------------------------------------
-- Length
SELECT ID, Value.ToString() AS Value, Value.[Length]() AS [Length]
FROM dbo.Vector;
GO

-- Addition 
DECLARE @V1 IVector, @V2 IVector, @V3 IVector
SET @V1 = CAST('0, 5' AS IVector)
SET @V2 = '2, 1'
SET @V3 = @V1.[Add](@V2); 
SELECT @V3.ToString(), CAST(@V3 AS VARCHAR(MAX)), @V3.X, @V3.Y
GO 

-- Dot product
DECLARE @V1 IVector, @V2 IVector, @V3 IVector
SET @V1 = CAST('0, 5' AS IVector)
SET @V2 = '2, 1'
SET @V3 = NULL
SELECT @V1.Dot(@V1, @V2) AS Result_12, @V1.Dot(@V1, @V3) AS Result_13
GO

-- Scale 
SELECT ID, Value.ToString() AS Value, Value.Scale(2).ToString() AS [DoubleValue]
FROM dbo.Vector;
GO