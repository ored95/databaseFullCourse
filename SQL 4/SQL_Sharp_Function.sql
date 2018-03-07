-------------------------------------------------
-- Remember that SQL 2008 uses .NET Framework 3.5
-------------------------------------------------

CREATE DATABASE Sharp;
GO

USE Sharp;
GO

---- Create a new schema for the aggregates
--CREATE SCHEMA Aggregates;
--GO

-- create table
IF OBJECT_ID('dbo.TopSongs') IS NOT NULL
	DROP TABLE dbo.TopSongs;
GO
CREATE TABLE dbo.TopSongs
(
	SongID INT IDENTITY PRIMARY KEY,
	SongTitle VARCHAR(50),
	SongArtist VARCHAR(50),
	SongYoutubeViewsPerMillions INT,
--	SongDateUploaded DATETIME
);
GO

INSERT INTO dbo.TopSongs(SongTitle, SongArtist, SongYoutubeViewsPerMillions) VALUES
('Gangnam Style', 'PSY', 2666),
('See You Again', 'Wiz Khalifa ft. Charlie Puth', 2155),
('Sorry', 'Justin Bieber', 1912),
('Uptown Funk', 'Mark Ronson ft. Bruno Mars', 1911),
('Blank Space', 'Taylor Swifts', 1812),
('Hello', 'Adele', 1754),
('Shake It Off', 'Taylor Swifts', 1690),
('Bailando', 'Enrique Iglesias ft. Descemer Bueno, Gente De Zona', 1665),
('Roar', 'Katy Perry', 1589),
('Sugar', 'Maroon 5', 1505),
('Counting Stars', 'OneRepublic', 1480),
('Chanderlier', 'Sia', 1430),
('What Do You Mean?', 'Justin Bieber', 1293),
('Love Me Like You Do', 'Ellie Goulding', 1284),
('Wake Me Up', 'Avicii', 1101),
('Rude', 'Magic!', 1065);
GO

SELECT * FROM TopSongs;
GO

-------------------------------------------------
--------------- 1. Functions --------------------
-------------------------------------------------

DROP ASSEMBLY HandWrittenClassLibrary;
GO

CREATE ASSEMBLY HandWrittenClassLibrary
FROM 'D:\BigDATA\SQL 4\HandWrittenClassLibrary\HandWrittenClassLibrary\bin\Debug\HandWrittenClassLibrary.dll'
WITH PERMISSION_SET = SAFE;
GO

IF OBJECT_ID('dbo.IsPrime') IS NOT NULL
	DROP FUNCTION dbo.IsPrime;
GO
CREATE FUNCTION dbo.IsPrime(@N INT)
RETURNS INT
AS
EXTERNAL NAME
HandWrittenClassLibrary.[HandWrittenClassLibrary.UserDefinedFunctions].IsPrime
GO

-- [FIXED!!!]
-- Execution of user code in the .NET Framework is disabled. Enable "clr enabled" configuration option
EXEC sp_configure 'clr enabled', 1
GO
RECONFIGURE
GO
EXEC sp_configure 'clr enabled'
GO

-- test function
SELECT dbo.IsPrime(1) AS Result;
SELECT dbo.IsPrime(31) AS Result;
GO