-------------------------------------------------
------------ 3. Table-Valued Funtion ------------
-------------------------------------------------

USE master;
GO;

DROP FUNCTION dbo.FileLog;
DROP ASSEMBLY SQLTVF;
GO

CREATE ASSEMBLY SQLTVF
FROM 'D:\BigDATA\SQL 4\TVF\TVF\bin\Debug\TVF.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;
GO

-- Show file with name, size and create
CREATE FUNCTION dbo.FileLog(@targetDirectory NVARCHAR(500), @searchPattern NVARCHAR(20))
RETURNS TABLE
(
	[FileName] NVARCHAR(500), 
	[FileSize] BIGINT,
	[CreationTime] DATETIME
)
AS EXTERNAL NAME SQLTVF.[DemoTVF].FileLog;
GO

-- Test-run 1: file *.sql
SELECT * FROM dbo.FileLog('D:\BigData\SQL 4\', '*.sql');
GO

-- Test-tun 2: *.evtx (logs from windows)
SELECT * FROM dbo.FileLog('C:\Logs', '*.evtx');
GO

-- Test-run 3: *.*
SELECT * FROM dbo.FileLog('D:\', '*.*');
GO