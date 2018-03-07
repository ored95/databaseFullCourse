-------------------------------------------------
------------------ 5. Trigger -------------------
-------------------------------------------------
USE Sharp;
GO

IF OBJECT_ID('dbo.Users') IS NOT NULL
	DROP TABLE dbo.Users;
GO
CREATE TABLE Users
(
	[UserName] NVARCHAR(200) NOT NULL,
	[Password] NVARCHAR(200) NOT NULL
)

IF OBJECT_ID('dbo.UsersAudit') IS NOT NULL
	DROP TABLE dbo.UsersAudit;
GO
CREATE TABLE UsersAudit
(
	[UserName] NVARCHAR(200) NOT NULL
)
GO

DROP TRIGGER dbo.UserNameAudit;
DROP ASSEMBLY [Trigger];
GO

CREATE ASSEMBLY [Trigger]
FROM 'D:\BigDATA\SQL 4\Triggers\Triggers\bin\Debug\Triggers.dll'
WITH PERMISSION_SET = SAFE;
GO

CREATE TRIGGER dbo.UserNameAudit
ON dbo.Users
FOR INSERT
AS
EXTERNAL NAME [Trigger].[TriggerInsertDemo].[UserNameAudit]
GO

-- Insert one user name that is not an e-mail address and one that is
INSERT INTO Users VALUES('anonymous', 'cnffjbeq')
INSERT INTO Users VALUES('someone@example.com', 'cnffjbeq')

-- check the Users and UsersAudit tables to see the results of the trigger
SELECT * FROM dbo.Users;
SELECT * FROM dbo.UsersAudit;
GO

