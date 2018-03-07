------------------------------------------------
-------------------- TRIGGERS ------------------
------------------------------------------------
------------ 1. Trigger 'FOR' ------------------
------------------------------------------------
USE Lab01;
GO

SELECT * FROM dbo.BookInventory;
GO

IF OBJECT_ID('dbo.DMLActionLog') IS NOT NULL
	DROP TABLE dbo.DMLActionLog;
GO
CREATE TABLE dbo.DMLActionLog
(
	EntryNum INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	SchemaName SYSNAME NOT NULL,
	TableName SYSNAME NOT NULL,
	ActionType NVARCHAR(10) NOT NULL,
	ActionXml XML NOT NULL,
	UserName NVARCHAR(256) NOT NULL,
	SpId INT NOT NULL,
	ActionDateTime DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

CREATE TRIGGER BookDetails ON dbo.BookInventory
AFTER INSERT, UPDATE, DELETE
NOT FOR REPLICATION
AS
BEGIN
	DECLARE @Count INT;
	SET @Count = @@ROWCOUNT;
	
	IF (@Count > 0)
	BEGIN
		SET NOCOUNT ON;
		DECLARE @ActionType NVARCHAR(10);
		DECLARE @ActionXml XML;
		
		DECLARE @inserted_count INT;
		SET @inserted_count = (SELECT COUNT(*) FROM inserted);
		
		DECLARE @deleted_count INT;
		SET @deleted_count = (SELECT COUNT(*) FROM deleted);
		
		--DECLARE @updated_count INT;
		--SET @updated_count = (SELECT COUNT(*) FROM updated);
		SELECT @ActionType = CASE
			WHEN (@inserted_count > 0) AND (@deleted_count = 0)	THEN N'Insert'
			WHEN (@inserted_count = 0) AND (@deleted_count > 0) THEN N'Delete'
			ELSE N'Update' 
		END;
		
		SELECT @ActionXml = COALESCE
		(
			(
				SELECT *
				FROM deleted
				FOR XML AUTO
			), N'<deleted/>'
		) + COALESCE
		(
			(
				SELECT *
				FROM inserted
				FOR XML AUTO
			), N'<inserted/>'
		);
		
		INSERT INTO dbo.DmlActionLog
		(
			SchemaName,
			TableName,
			ActionType,
			ActionXml,
			UserName,
			SpId,
			ActionDateTime
		)
		SELECT	OBJECT_SCHEMA_NAME(@@PROCID, DB_ID()),
				OBJECT_NAME(t.parent_id, DB_ID()),
				@ActionType,
				@ActionXml,
				USER_NAME(),
				@@SPID,
				GETDATE()
		FROM sys.triggers t
		WHERE t.object_id = @@PROCID;
	END;
END;
GO

-- TEST TRIGGGER
UPDATE BookInventory
SET Quantity = Quantity + 5
WHERE Title = 'Catch 22';
GO

INSERT BookInventory VALUES
(12, N'If I stay', 12),
(35, N'Past', 7);
GO

DELETE FROM BookInventory
WHERE TitleID = 35;
GO

SELECT * FROM dbo.DMLActionLog;
GO

SELECT * FROM BookInventory;
GO


--------------------------------------------------
------------ 2. Trigger 'INSTEAD OF' -------------
--------------------------------------------------
CREATE DATABASE InsteadOfTriggerTest;
GO

USE InsteadOfTriggerTest;
GO

IF OBJECT_ID('DMLActionLog') IS NOT NULL
	DROP TABLE DMLActionLog;
GO
CREATE TABLE DMLActionLog
(
	EntryNum INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
	SchemaName SYSNAME NOT NULL,
	TableName SYSNAME NOT NULL,
	ActionType NVARCHAR(10) NOT NULL,
	ActionXml XML NOT NULL,
	UserName NVARCHAR(256) NOT NULL,
	SpId INT NOT NULL,
	ActionDateTime DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('XMLDetailShow') IS NOT NULL
	DROP PROC XMLDetailShow;
GO
CREATE PROCEDURE XMLDetailShow
AS
SELECT	SchemaName,
		TableName,
		ActionType,
		ActionXml,
		UserName,
		SpId,
		ActionDateTime
FROM dbo.DMLActionLog;
GO

IF OBJECT_ID('BasePersonTable') IS NOT NULL
	DROP TABLE BasePersonTable;
GO
CREATE TABLE BasePersonTable
(
	BasePersonID INT PRIMARY KEY IDENTITY(1, 1),
	BasePersonFirstName NVARCHAR(20) NOT NULL,
	BasePersonLastName NVARCHAR(20) NOT NULL,
	BaseFullName AS (BasePersonFirstName + ' ' + BasePersonLastName)
);
GO

-- create view
IF OBJECT_ID('InsteadView') IS NOT NULL
	DROP VIEW InsteadView;
GO
CREATE VIEW InsteadView AS
SELECT BasePersonID, BasePersonFirstName, BasePersonLastName, BaseFullName
FROM BasePersonTable
GO

-- create trigger
IF OBJECT_ID('InsteadTrigger') IS NOT NULL
	DROP TRIGGER InsteadTrigger;
GO
CREATE TRIGGER InsteadTrigger ON InsteadView
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @Count INT;
	SET @Count = @@ROWCOUNT;
	
	IF (@Count > 0)
	BEGIN
		SET NOCOUNT ON;
		DECLARE @ActionType NVARCHAR(10);
		DECLARE @ActionXml XML;
		
		DECLARE @inserted_count INT;
		SET @inserted_count = (SELECT COUNT(*) FROM inserted);
		
		IF @inserted_count > 0
		BEGIN
			--Build an INSERT statement ignoring inserted.BasePersonID and inserted.BasePersonFullName
			INSERT INTO BasePersonTable
			SELECT BasePersonFirstName, BasePersonLastName
			FROM inserted;
		
			IF @@ROWCOUNT = 0
				RAISERROR('Error: No matching orders, can NOT perform inserted!', 10, 1);
		END;
		
		DECLARE @deleted_count INT;
		SET @deleted_count = (SELECT COUNT(*) FROM deleted);
		
		--DECLARE @updated_count INT;
		--SET @updated_count = (SELECT COUNT(*) FROM updated);
		SELECT @ActionType = CASE
			WHEN (@inserted_count > 0) AND (@deleted_count = 0)	THEN N'Insert'
			WHEN (@inserted_count = 0) AND (@deleted_count > 0) THEN N'Delete'
			ELSE N'Update' 
		END;
		
		SELECT @ActionXml = COALESCE
		(
			(
				SELECT *
				FROM deleted
				FOR XML AUTO
			), N'<deleted/>'
		) + COALESCE
		(
			(
				SELECT *
				FROM inserted
				FOR XML AUTO
			), N'<inserted/>'
		);
		
		INSERT INTO DMLActionLog
		(
			SchemaName,
			TableName,
			ActionType,
			ActionXml,
			UserName,
			SpId,
			ActionDateTime
		)
		SELECT	OBJECT_SCHEMA_NAME(@@PROCID, DB_ID()),
				OBJECT_NAME(t.parent_id, DB_ID()),
				@ActionType,
				@ActionXml,
				USER_NAME(),
				@@SPID,
				GETDATE()
		FROM sys.triggers t
		WHERE t.object_id = @@PROCID;
	END;
END;
GO

-- test trigger
INSERT INTO BasePersonTable(BasePersonFirstName, BasePersonLastName)
SELECT TOP 5 SellerFirstName, SellerLastName
FROM Lab01.dbo.tblSeller
GO

SELECT * FROM BasePersonTable;
GO

EXEC XMLDetailShow;
GO

-- insert into VIEW
INSERT INTO InsteadView(BasePersonID, BasePersonFirstName, BasePersonLastName)
VALUES (7, N'Asley', N'Young');
GO

SELECT * FROM BasePersonTable;
GO

EXEC XMLDetailShow;
GO

-- error command insert
INSERT INTO BasePersonTable
VALUES (10, N'Flicky', N'Van', 'Flicky Van');
GO

SELECT * FROM BasePersonTable;
GO

SELECT * FROM InsteadView;
GO

EXEC XMLDetailShow;
GO


-- Drop all
DROP TABLE BasePersonTable;
DROP VIEW InsteadView;
DROP TRIGGER InsteadTriger;
EXEC XMLDetailShow;
GO