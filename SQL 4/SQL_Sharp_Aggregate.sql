--------------------------------------------------
--------- 2. Aggregate functions -----------------
--------------------------------------------------
USE Sharp;
GO

DROP SCHEMA Aggregates;
GO

CREATE SCHEMA Aggregates;
GO

DROP AGGREGATE Aggregates.[GeometricProduct];
DROP AGGREGATE Aggregates.[Concat];
DROP ASSEMBLY SQLServerAggregate;
GO

CREATE ASSEMBLY SQLServerAggregate
FROM 'D:\BigDATA\SQL 4\SQLServerAggregate\SQLServerAggregate\bin\Debug\SQLServerAggregate.dll'
WITH PERMISSION_SET = SAFE;
GO

-- Calculates the geometric mean of numerical values
CREATE AGGREGATE Aggregates.GeometricProduct(@number FLOAT)
RETURNS FLOAT
EXTERNAL NAME SQLServerAggregate.[SqlUserDefinedAggregateAttribute.GeometricProduct]
GO

-- Concatenates the strings with a given delimiter
CREATE AGGREGATE Aggregates.Concat(@string NVARCHAR(MAX),
							  @delimiter NVARCHAR(MAX),
						      @nullYieldsToNull bit)
RETURNS NVARCHAR(MAX)
EXTERNAL NAME SQLServerAggregate.[SqlUserDefinedAggregateAttribute.Concat]
GO

-----------------------------------------------------------------
------------------- TEST AGGREGATE FUNCTION ---------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
---------------- #1: GeometricProduct(value) --------------------
-----------------------------------------------------------------
-- Test-run 1: Result = sqrt(2)
SELECT Aggregates.GeometricProduct(Val) AS Result
FROM (SELECT 1 AS Val UNION ALL
	  SELECT 2 AS Val) [table];
GO

-- Test-run 2: Result = NULL
SELECT Aggregates.GeometricProduct(Val) AS Result
FROM (SELECT 1 AS Val UNION ALL
	  SELECT NULL AS Val UNION ALL
	  SELECT 100 AS Val) [table];
GO

-- Test-run 3: Result = 3
SELECT Aggregates.GeometricProduct(Val) AS Result
FROM (SELECT 3 AS Val UNION ALL
      SELECT 1 AS Val UNION ALL
      SELECT 81 AS Val UNION ALL
      SELECT 1 AS Val UNION ALL
      SELECT 1 AS Val) [table];
GO

-- Test-run 4: using partitioning
SELECT DISTINCT 
	Cat AS CatID, 
	Aggregates.GeometricProduct(Val) OVER (PARTITION BY Cat) AS Result
FROM (SELECT 1 AS Cat, 2 AS Val UNION ALL
      SELECT 1 AS Cat, 8 AS Val UNION ALL
      SELECT 1 AS Cat, 4 AS Val UNION ALL
      SELECT 1 AS Cat, 4 AS Val UNION ALL
      SELECT 2 AS Cat, 0.1 AS Val UNION ALL
      SELECT 2 AS Cat, 1000 AS Val) [table];
GO

-----------------------------------------------------------------
------------ #2: Concat(string, delimiter, flag) ----------------
-----------------------------------------------------------------
-- Test-run 1:
SELECT Aggregates.Concat(a.Val, ', ', 0) AS Result
FROM (SELECT 'A' AS Val UNION ALL
      SELECT 'B' AS Val UNION ALL
      SELECT 'C' AS Val) a;
GO

-- Test-run 2, NULL in the set, NullYieldsToNull = false
SELECT Aggregates.Concat(a.Val, ', ', 0) AS Result
FROM (SELECT 'A'  AS Val UNION ALL
      SELECT 'B'  AS Val UNION ALL
      SELECT NULL AS Val UNION ALL
      SELECT 'C'  AS Val) a
GO

-- Test-run 3, NULL in the set, NullYieldsToNull = true
SELECT Aggregates.Concat(a.Val, ', ', 1) AS Result
FROM (SELECT 'A'  AS Val UNION ALL
      SELECT 'B'  AS Val UNION ALL
      SELECT NULL AS Val UNION ALL
      SELECT 'C'  AS Val) a;
GO

-- Test-run 4, NULL in the set, NullYieldsToNull = true
SELECT Aggregates.Concat(song.SongTitle, ', ', 1) AS Result
FROM dbo.TopSongs song;
GO