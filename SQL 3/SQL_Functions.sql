-- CREATE SOURCE (table with value from 1 to 1000000)
IF OBJECT_ID('dbo.Numbers') IS NOT NULL
	DROP TABLE dbo.Numbers
ELSE
	CREATE TABLE dbo.Numbers(N INT NOT NULL PRIMARY KEY)
GO

-- Insert table using recursive
WITH Pos(N) AS 
(
	SELECT 1
	UNION ALL
	SELECT N + 1
	FROM Pos
	WHERE N < 1000000
)
INSERT INTO dbo.Numbers(N)
SELECT N
FROM Pos
OPTION (MAXRECURSION 0);
GO

--Select * From dbo.Numbers

----------------------------------------------------
-------------------- FUNCTIONS ---------------------
----------------------------------------------------
---------- 1. Simple Scalar function ---------------
IF OBJECT_ID('dbo.IsPrime') IS NOT NULL
	DROP FUNCTION dbo.IsPrime
GO

CREATE FUNCTION dbo.IsPrime(@number INT)
RETURNS VARCHAR(15)
AS
BEGIN
	IF @number IS NULL
		RETURN 'Unidentified'
		
	IF @number  = 2
		RETURN 'TRUE'
		
	IF @number % 2 = 0 OR @number < 2
		RETURN 'FALSE'
		
	DECLARE @i INT = 3
	
	WHILE @i < SQRT(@number)
	BEGIN
		IF @number % @i = 0
			BREAK
		SET @i = @i + 2
	END
	
	IF @i <= SQRT(@number)
		RETURN 'FALSE'
	RETURN 'TRUE'
END;
GO

SELECT dbo.IsPrime(NULL);
SELECT dbo.IsPrime(0);
SELECT dbo.IsPrime(2);
SELECT dbo.IsPrime(3);
SELECT dbo.IsPrime(101);
SELECT dbo.IsPrime(129);

---------- 2. Function returns table ---------------
IF OBJECT_ID('dbo.ListPrime') IS NOT NULL
	DROP FUNCTION dbo.ListPrime
GO

CREATE FUNCTION dbo.ListPrime(@x INT, @y INT)
RETURNS TABLE
AS
RETURN
(
	WITH PrimeTab(N, [Type]) AS
	(
		SELECT p.N AS N, 
			   "Type" = CASE dbo.IsPrime(p.N)
							WHEN 'TRUE' THEN 'Prime'
							ELSE ''
						END	
		FROM dbo.Numbers AS p
		WHERE (p.N BETWEEN @x AND @y) OR (p.N BETWEEN @y AND @x)
	)
	SELECT * FROM PrimeTab
);
GO

SELECT * FROM dbo.ListPrime(0, 1000);
SELECT * FROM dbo.ListPrime(19, 0);

SELECT N FROM dbo.ListPrime(0, 1000) AS list
WHERE list.Type = 'Prime'
ORDER BY N DESC;
GO

------- 3. Multioperator function returns table -----
IF OBJECT_ID('dbo.CheckPrime') IS NOT NULL
	DROP FUNCTION dbo.CheckPrime;
GO

CREATE FUNCTION dbo.CheckPrime(@x INT = 1, @y INT = 1)
RETURNS @Subs TABLE(N INT NOT NULL PRIMARY KEY, [Type] VARCHAR(20))
AS
BEGIN
	DECLARE @from INT = @x
	DECLARE @to INT = @y
	
	IF @from > @to
	BEGIN
		SET @from = @y
		SET @to = @x
	END
	
	DECLARE @retPrime VARCHAR(20)
	--INSERT INTO @Subs(N, [Type])
	--SELECT N, [Type] FROM dbo.ListPrime(@x, @y)
	WHILE @from <= @to
	BEGIN
		IF dbo.IsPrime(@from) = 'TRUE'
			SET @retPrime = 'Prime'
		ELSE
			SET @retPrime = ''
			
		INSERT INTO @Subs(N, [Type])
		VALUES (@from, @retPrime);
		
		SET @from = @from + 1
	END
	RETURN;
END
GO

SELECT * FROM CheckPrime(40, 50);
GO

--------- 4. Function using recursive OTB ----------
IF OBJECT_ID('dbo.Gcd') IS NOT NULL
	DROP FUNCTION dbo.Gcd;
GO
	
CREATE FUNCTION dbo.Gcd(@x INT, @y INT)
RETURNS INT
WITH RETURNS NULL ON NULL INPUT
AS
BEGIN
	IF @x = @y
		RETURN @x;
	
	IF @x > @y
		RETURN dbo.Gcd(@x - @y, @y);
	
	RETURN dbo.Gcd(@x, @y - @x);
END;
GO

SELECT dbo.Gcd(NULL, 32) AS N'Gcd(NULL, 32)';
SELECT dbo.Gcd(10, 101)  AS N'Gcd(10, 101)';
SELECT dbo.Gcd(114, 294) AS N'Gcd(114, 294)';
SELECT dbo.Gcd(10, 15)   AS N'Gcd(10, 15)';
GO