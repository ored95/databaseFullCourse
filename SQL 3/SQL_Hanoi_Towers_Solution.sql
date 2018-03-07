---------------------------------------------
---------------- PROCEDURES -----------------
---------------------------------------------
---------- #Problem: "Hanoi Towers" ---------
CREATE PROCEDURE dbo.ShowTowers
AS
BEGIN
	WITH SevenNumbers(Num) AS
	(
		SELECT 1
		UNION ALL
		SELECT Num + 1
		FROM SevenNumbers
		WHERE Num < 7
	),
	GetTowerA(Disc) AS-- towel A
	(
		SELECT COALESCE(a.Disc, -1) AS Disc
		FROM SevenNumbers f LEFT JOIN #TowerA a ON f.Num = a.Disc
	),
	GetTowerB(Disc) AS-- towel B
	(
		SELECT COALESCE(b.Disc, -1) AS Disc
		FROM SevenNumbers f LEFT JOIN #TowerB a ON f.Num = b.Disc
	),
	GetTowerC(Disc) AS-- towel C
	(
		SELECT COALESCE(c.Disc, -1) AS Disc
		FROM SevenNumbers f LEFT JOIN #TowerC a ON f.Num = c.Disc
	)
	
	SELECT 
		CASE a.Disc
			WHEN 7 THEN ' =======7======= '
			WHEN 6 THEN '  ======6======  '
			WHEN 5 THEN '   =====5=====   '
			WHEN 4 THEN '    ====4====    '
			WHEN 3 THEN '     ===3===     '
			WHEN 2 THEN '      ==2==      '
			WHEN 1 THEN '       =1=       '
			ELSE        '        |        '
			END AS Tower_A,
		CASE b.Disc
			WHEN 7 THEN ' =======7======= '
			WHEN 6 THEN '  ======6======  '
			WHEN 5 THEN '   =====5=====   '
			WHEN 4 THEN '    ====4====    '
			WHEN 3 THEN '     ===3===     '
			WHEN 2 THEN '      ==2==      '
			WHEN 1 THEN '       =1=       '
			ELSE        '        |        '
			END AS Tower_B,
		CASE c.Disc
			WHEN 7 THEN ' =======7======= '
			WHEN 6 THEN '  ======6======  '
			WHEN 5 THEN '   =====5=====   '
			WHEN 4 THEN '    ====4====    '
			WHEN 3 THEN '     ===3===     '
			WHEN 2 THEN '      ==2==      '
			WHEN 1 THEN '       =1=       '
			ELSE        '        |        '
			END AS Tower_C
	FROM
	(
		SELECT  ROW_NUMBER() OVER(ORDER BY Disc) AS Num,
				COALESCE(Disc, -1) AS Disc
		FROM GetTowerA
	) a
	FULL OUTER JOIN
	(
		SELECT  ROW_NUMBER() OVER(ORDER BY Disc) AS Num,
				COALESCE(Disc, -1) AS Disc
		FROM GetTowerB
	)  b ON a.Num = b.Num
	FULL OUTER JOIN 
	(
		SELECT  ROW_NUMBER() OVER(ORDER BY Disc) AS Num,
				COALESCE(Disc, -1) AS Disc
		FROM GetTowerC
	) c ON b.Num = c.Num
	ORDER BY a.Num;
END;
GO

CREATE PROCEDURE dbo.MoveOneDisc
(
	@Source NCHAR(1),
	@Destination NCHAR(1)
)
AS 
BEGIN
	-- @Smallest Disc
	DECLARE @SmallestDisc INT = 0
	
	-- Using IF..ELSE conditional statement to get the smallest disc from the correct source tower
	IF @Source = N'A'
	BEGIN
		-- Identify the smallest disc in tower A
		SELECT @SmallestDisc = MIN(Disc)
		FROM #TowerA;
		
		-- Remmove that smallest disc
		DELETE FROM #TowerA WHERE Disc = @SmallestDisc;
	END
	ELSE IF @Source = N'B'
	BEGIN
		-- Identify the smallest disc in tower B
		SELECT @SmallestDisc = MIN(Disc)
		FROM #TowerB;
		
		-- Remmove that smallest disc
		DELETE FROM #TowerB WHERE Disc = @SmallestDisc;
	END
	ELSE IF @Source = N'C'
	BEGIN
		-- Identify the smallest disc in tower A
		SELECT @SmallestDisc = MIN(Disc)
		FROM #TowerC;
		
		-- Remmove that smallest disc
		DELETE FROM #TowerC WHERE Disc = @SmallestDisc;
	END
	
	-- Show message about movement disc
	SELECT	N'Moving Disc (' + CAST(COALESCE(@SmallestDisc, 0) AS NCHAR(1)) +
			N') from Tower ' + @Source + N' to Tower ' + @Destination + ':' AS Discription;
	
	-- Excute movement (using INSERT)
	IF @Destination = N'A'
		INSERT INTO #TowerA(Disc) VALUES (@SmallestDisc);
	ELSE IF @Destination = N'B'
		INSERT INTO #TowerB(Disc) VALUES (@SmallestDisc);
	ELSE IF @Destination = N'C'
		INSERT INTO #TowerC(Disc) VALUES (@SmallestDisc);
	
	EXECUTE dbo.ShowTowers;
END;
GO

-- Move disces (Using recursive)
CREATE PROCEDURE dbo.MoveDiscs
(
	@DiscNum INT,
	@MoveNum INT OUTPUT,
	@Source NCHAR(1) = N'A',
	@Destination NCHAR(1) = N'C',
	@Auxiliary NCHAR(1) = N'B'
)
AS
BEGIN
	IF @DiscNum = 0
		PRINT N'Done';
	ELSE
	BEGIN
		-- If the number of discs need moving is 1, go ahead and move it
		IF @DiscNum = 1
		BEGIN
			-- Increase counter by 1
			SELECT @MoveNum = @MoveNum + 1;
			
			-- Move one disc from source to destination
			EXECUTE dbo.MoveOneDisc @Source, @Destination;
		END
		ELSE
		BEGIN
			-- Determine number of discs to move from source to destination
			DECLARE @n INT = @DiscNum - 1;
			
			-- Move (@DiscNum - 1) discs from source to auxiliary tower
			EXECUTE dbo.MoveDiscs @n, @MoveNum OUTPUT, @Source, @Auxiliary, @Destination;
			
			-- Move 1 disc from source to final destination tower
			EXECUTE dbo.MoveDiscs 1, @MoveNum OUTPUT, @Source, @Destination ,@Auxiliary;
			
			-- Move (@DiscNum - 1) discs from auxiliary to final destination
			EXECUTE dbo.MoveDiscs @n, @MoveNum OUTPUT, @Auxiliary, @Destination, @Source;
		END;
	END;
END;
GO

IF OBJECT_ID('dbo.SolveTowers') IS NOT NULL
	DROP PROCEDURE dbo.SolveTowers;
GO

-- Create database 3 #Towers
CREATE PROCEDURE dbo.SolveTowers
AS
BEGIN
	-- Set NOCOUNT ON to eliminate system messages that will clutter up the Message display
	SET NOCOUNT ON;
	
	-- Create three towers: #TowerA, #TowerB, #TowerC
	CREATE TABLE #TowerA (Disc INT PRIMARY KEY NOT NULL);
	CREATE TABLE #TowerB (Disc INT PRIMARY KEY NOT NULL);
	CREATE TABLE #TowerC (Disc INT PRIMARY KEY NOT NULL);
	
	-- Populate Tower A with all seven discs
	INSERT INTO #TowerA (Disc) VALUES
	(1), (2), (3), (4), (5), (6), (7);
	
	-- Initialize the move number to 0
	DECLARE @MoveNum INT = 0;
	
	-- Show the initial state of towers
	EXECUTE dbo.ShowTowers;
	
	-- Solve the puzzle
	EXECUTE dbo.MoveDiscs 7, @MoveNum OUTPUT;
	
	-- Count moves
	PRINT N'Solved in ' + CAST(@MoveNum AS NVARCHAR(10)) + N' moves.';
	
	-- Drop temp tables to clean up
	DROP TABLE #TowerC;
	DROP TABLE #TowerB;
	DROP TABLE #TowerA;
	
	-- Set NOCOUNT OFF to exit
	SET NOCOUNT OFF;
END;
GO

EXECUTE dbo.SolveTowers;
GO