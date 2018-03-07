-------------------------------------------------
----------- 4. Stored procedure -----------------
-------------------------------------------------
USE Sharp;
GO

IF OBJECT_ID('dbo.Currency') IS NOT NULL
	DROP TABLE dbo.Currency;
GO
CREATE TABLE dbo.Currency
(
	CurrencyCode NVARCHAR(50),
	Name		 NVARCHAR(50),
	ModifiedDate DATETIME
)
GO

INSERT INTO dbo.Currency VALUES('abcd', '####', GETDATE());
GO

DROP PROC dbo.InsertCurrency;
DROP ASSEMBLY StoredProc;
GO

CREATE ASSEMBLY StoredProc
FROM 'D:\BigDATA\SQL 4\Stored procedure\Stored procedure\bin\Debug\Stored procedure.dll'
WITH PERMISSION_SET = SAFE;
GO

CREATE PROC dbo.InsertCurrency(@currencyCode NVARCHAR(50), @name NVARCHAR(50))
AS
EXTERNAL NAME StoredProc.[StoredProcedure].InsertCurrency
GO

EXEC dbo.InsertCurrency 'AAA', 'Currency Test';
GO

SELECT * FROM dbo.Currency;
GO