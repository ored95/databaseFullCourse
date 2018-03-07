Use SongDB;
GO

CREATE PROCEDURE dbo.GetSongByMonth(@month INT)
AS
BEGIN
	SELECT * FROM dbo.SongDB
	WHERE MONTH(SongPublishedDate) = @month
	ORDER BY SongPublishedDate DESC
END
GO

EXEC dbo.GetSongByMonth @month = 10;
GO