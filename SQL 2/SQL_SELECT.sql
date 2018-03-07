Use Lab01;
GO

-- Request #01: Comparison
SELECT DISTINCT P1.ProductName, P1.ProductMaterial, P1.ProductMadeIn
FROM tblProduct P1 JOIN tblProduct AS P2 ON P2.ProductMadeIn = P1.ProductMadeIn
WHERE P1.ProductMaterial <> P2.ProductMaterial AND P1.ProductMadeIn = 'Germany'
ORDER BY P1.ProductName

-- Request #02: BETWEEN
-- List of products with its quantity in range [5000; 10000].
SELECT DISTINCT ProductName, BillQuantity, BillPrice
FROM tblBill JOIN tblProduct ON BillProductID = ProductID
WHERE BillQuantity BETWEEN 5000 AND 10000

-- Request #03: LIKE
-- List of all sellers having the 2 last digits of visa card series is 55.
SELECT DISTINCT SellerFirstName, SellerLastName, SellerVisaCardSeries
FROM tblSeller
WHERE SellerVisaCardSeries LIKE '%55'

-- Request #04: IN
-- List of companies, which is Inc (Incorporated) and the bill quantity is lower than 5000.
SELECT CompanyName, CompanyLocation, BillQuantity
FROM tblCompany JOIN tblBill ON CompanyID = BillCompanyID
WHERE CompanyName LIKE '%Inc' AND CompanyID IN
(
	SELECT CompanyID 
	WHERE BillQuantity < 5000
)
	
-- Request #05: EXISTS
-- List of all companies which exists the bill over 9.000.000
SELECT CompanyName, CompanyLocation
FROM tblCompany
WHERE EXISTS
(
	SELECT BillCompanyID
	FROM tblBill
	WHERE BillCompanyID = CompanyID
	  AND BillPrice > 9000000
)

-- Request #06: Quantifier comparison (CHECK!) (so sanh dinh luong) ALL
-- List of products, which are made in Germany and its price is bigger than products made in China
SELECT ProductName, ProductMadeIn, BillQuantity, BillPrice
FROM tblBill join tblProduct ON ProductID = BillProductID
WHERE BillPrice > ALL
(
	SELECT BillPrice
	FROM tblBill JOIN tblProduct ON ProductID = BillProductID
	WHERE ProductMadeIn = 'China' -- MAX: 6,936,000
)
AND ProductMadeIn IN ('Germany', 'France')
ORDER BY BillPrice ASC
	  
--SELECT BillPrice
--FROM tblBill JOIN tblProduct ON ProductID = BillProductID
--WHERE ProductMadeIn = 'China'
--ORDER BY BillPrice DESC

-- Request #07: GROUP BY
SELECT TOP 10 BillSellerID, COUNT(BillSellerID) AS 'Times', SUM(BillPrice) AS 'Total Price'
FROM tblBill 
GROUP BY BillSellerID
ORDER BY [Total Price] DESC

-- Request #08: using scalar subqueries in the column expressions
SELECT TOP 10 ProductName, ProductMadeIn,
(
	SELECT COUNT(BillProductID)
	FROM tblBill
	WHERE BillProductID = ProductID
) AS 'Times'
FROM tblProduct
ORDER BY Times DESC

-- Request #09: Simple CASE
SELECT ProductName,ProductMadeIn,
	CASE 
	WHEN EXISTS
		(
			SELECT BillProductID
			FROM tblBill
			WHERE BillProductID = ProductID
		) THEN 'Ordered'
	ELSE ''
	END AS 'Status'
FROM tblProduct

-- Request #10: Searching CASE
SELECT TOP 100 ProductName, BillQuantity, "Type" =
CASE
	WHEN BillQuantity < 10000 THEN 'FEW'
	WHEN BillQuantity > 50000 THEN 'MUCH'
	ELSE 'medium'
END
FROM tblBill JOIN tblProduct ON BillProductID = ProductID
--ORDER BY BillQuantity DESC, TYPE, ProductName

-- Request #11: Create a new local temporary table
-- Create BestSelling temp table, which show informations of product, it's quantity sold and maximum price
IF OBJECT_ID('tempdb..#BestSelling') IS NOT NULL
	DROP TABLE #BestSelling
ELSE
SELECT ProductID, 
	   ProductName,
	   ProductMaterial,
	   ProductMadeIn,
	   SUM(BillQuantity) AS 'Total Quantity',
	   MAX(BillPrice) AS 'Maximum Price'
INTO #BestSelling
FROM tblProduct INNER JOIN tblBill ON ProductID = BillProductID
GROUP BY ProductID, ProductName, ProductMaterial, ProductMadeIn
ORDER BY [Total Quantity] DESC, [Maximum Price]

SELECT * FROM #BestSelling


-- Request #12: FROM + UNION (complicacy)
-- Union top seller (by time and by price)
SELECT S.SellerID AS ID,
	   S.SellerFirstName + ' ' + S.SellerLastName AS 'Best seller',
	   'By times' AS 'Rank'
FROM tblSeller S JOIN (
	SELECT TOP 1 BillSellerID, COUNT(BillSellerID) AS Times
	FROM tblBill 
	GROUP BY BillSellerID
	ORDER BY Times DESC
	) AS TimeTop ON S.SellerID = TimeTop.BillSellerID
UNION
SELECT S.SellerID AS ID,
	   S.SellerFirstName + ' ' + S.SellerLastName AS 'Name',
	   'By prices' AS 'Rank'
FROM tblSeller S JOIN (
	SELECT TOP 1 BillSellerID
	FROM tblBill
	ORDER BY BillPrice DESC
	) AS PriceTop ON S.SellerID = PriceTop.BillSellerID

-- Request #13: Select (Complicacy LEVEL 3)
-- Top 3 products which have the highest ordered quantity
SELECT ProductID AS ID, 
	   ProductName AS 'Best order by quantity', 
	   ProductMaterial AS Material,
	   ProductMadeIn AS 'Made in'
FROM tblProduct
WHERE ProductID IN
(
	SELECT ProductID
	FROM tblBill JOIN tblProduct ON ProductID = BillProductID
	GROUP BY ProductID
	HAVING SUM(BillQuantity) IN
	(
		SELECT TOP 3 SUM(BillQuantity) AS Total
		FROM tblBill
		GROUP BY BillProductID
		HAVING MAX(BillPrice) IN
		(
			SELECT BillPrice
			FROM tblBill
			WHERE BillPrice > 50000
		)
		ORDER BY Total DESC
	)
)

-- Request #14: GROUP BY without HAVING
-- Top 10 companies having higest ordered times 
SELECT TOP 10
	   BillCompanyID AS 'ReceiverID',
	   COUNT(BillCompanyID) AS 'Times',
	   SUM(BillQuantity) AS 'Total Quantity',
	   '$' + CAST(SUM(BillPrice) AS VARCHAR(12)) AS 'Total Price'
FROM tblBill
--WHERE BillPrice > 100000
GROUP BY BillCompanyID
ORDER BY Times DESC

-- Request #15: GROUP BY + HAVING
-- Select the bill with maximum total quantity
SELECT BillSellerID AS SellerID,
	   BillCompanyID AS CompanyID,
	   BillProductID AS ProductID,
	   SUM(BillQuantity) AS 'Total quantity',
	   SUM(BillPrice) AS 'Total price'
FROM tblBill
GROUP BY BillSellerID, BillCompanyID, BillProductID
HAVING BillSellerID = 7

-- Request #16: INSERT
INSERT tblBill(BillSellerID, BillCompanyID, BillProductID, BillQuantity, BillPrice)
VALUES (1, 999, 500, 12800, 1024000)

-- Request #17: INSERT + Select
INSERT tblBill(BillSellerID, BillCompanyID, BillProductID, BillQuantity, BillPrice)
SELECT(
			SELECT TOP 1 BillSellerID
			FROM tblSeller RIGHT OUTER JOIN tblBill ON BillSellerID = SellerID
			ORDER BY BillPrice ASC
	  ), 
	  (		
			SELECT TOP 1 CompanyID
			FROM tblCompany
			WHERE CompanyName LIKE '%Inc'
			ORDER BY CompanyLocation DESC
	  ),
	  5, 1000000, 9750000

-- Request #18: UPDATE (simple)
UPDATE tblSeller
SET SellerGender = 'Male'
WHERE SellerID = 500
--SELECT * FROM tblSeller WHERE SellerID > 498

-- Request #19: UPDATE scalar
UPDATE tblBill
SET BillQuantity = 
(
	SELECT MAX(BillQuantity) + 1000
	FROM tblBill
	WHERE BillPrice = 
	(
		SELECT MAX(BillPrice)
		FROM tblBill
	)
)
WHERE BillPrice = 
(
	SELECT MAX(BillPrice)
	FROM tblBill
)

--SELECT * FROM tblBill WHERE BillPrice = 
--(
--	SELECT MAX(BillPrice)
--	FROM tblBill
--)

-- Request #20: DELETE (simple)
DELETE tblBill
WHERE BillCompanyID = 100 AND BillProductID = 100 AND BillSellerID = 100

-- Request #21: DELETE + SELECT
DELETE FROM tblBill
WHERE BillPrice IN
(
	SELECT BillPrice
	FROM tblBill LEFT OUTER JOIN tblSeller ON BillSellerID = SellerID
	WHERE SellerVisaCardSeries LIKE N'49999%'
)

-- Request #22: Select from simple table 
WITH ShortListProduct(ProductID, TotalPrice)
AS
(
	SELECT TOP 10 BillProductID, SUM(BillPrice) AS Total
	FROM tblBill
	GROUP BY BillProductID
	ORDER BY Total DESC
)
SELECT UPPER(ProductName) AS Product, '$' + CAST(TotalPrice AS VARCHAR(10)) AS 'Total Price'
FROM ShortListProduct LEFT OUTER JOIN tblProduct ON tblProduct.ProductID = ShortListProduct.ProductID

-- Request #23: SELECT (recursive) OTB
IF OBJECT_ID('dbo.TestBook') IS NOT NULL
	DROP TABLE dbo.TestBook
CREATE TABLE dbo.TestBook
(
	BookID INT NOT NULL,
	BookTitle NVARCHAR(30) NOT NULL,
	BookEdition INT NULL,
	BookAuthor NVARCHAR(30) NOT NULL,
	BookAuthorID INT NULL,
	BookPrice INT NOT NULL,
	--BookReleaseDate DATETIME,
	CONSTRAINT PK_BookID PRIMARY KEY (BookID ASC)
);
GO

INSERT INTO dbo.TestBook VALUES
(1, N'The trespasser', 1, N'Tanna French', NULL, 16),
(2, N'Truevine', 3, N'Beth Macy', 2, 20),
(3, N'Today will be different', NULL, 'Maria Semple', NULL, 16),
(4, N'Messy', 1, N'Tim Harford', NULL, 17),
(5, N'The Wangs vs. the World', NULL, N'Jade Chang', 1, 15);

SELECT * FROM dbo.TestBook

-- Define OTB
WITH Details(BookID, BookAuthorID, BookTile, BookEdition, BookPrice, Deal)
AS
(
	SELECT e.BookID, e.BookAuthorID, e.BookTitle, e.BookEdition, e.BookPrice, 50 AS Deal
	FROM dbo.TestBook AS e
	WHERE e.BookAuthorID IS NULL
	UNION ALL -- Recursive
	SELECT e.BookID,  e.BookAuthorID, e.BookTitle, e.BookEdition, e.BookPrice, Deal + 10
	FROM dbo.TestBook AS e INNER JOIN Details AS d ON e.BookAuthorID = d.BookID
)
SELECT * FROM Details

-- Request #24: PIVOT
-- Pivot with 1 rows and 5 columns
SELECT 'Price' AS BookID, [1], [2], [3], [4], [5]
FROM
(
	SELECT BookID, BookPrice
	FROM dbo.TestBook
) AS SourceTable
PIVOT
(
	SUM(BookPrice)
	FOR	BookID IN ([1], [2], [3], [4], [5])
) AS PivotTable

-- Pivot with 10 rows and 6 columns
SELECT TOP 10 BillSellerID AS 'SellerID',
			  [472] AS 'Pr[472]', [668] AS 'Pr[668]', [713] AS 'Pr[713]',
			  [270] AS 'Pr[270]', [834] AS 'Pr[834]', [993] AS 'Pr[993]'
FROM
(
	SELECT BillSellerID, BillProductID, BillCompanyID
	FROM tblBill
) AS SourceTable
PIVOT
(
	COUNT(BillCompanyID)
	FOR BillProductID IN ([472], [668], [713], [270], [834], [993])
) AS PivotTable
ORDER BY [472] DESC, [668] DESC, [713] DESC, [270] DESC, [834] DESC, [993] DESC

-- UNPIVOT (using table from previous selection)
IF OBJECT_ID('dbo.PivotTableFromBill') IS NOT NULL
	DROP TABLE dbo.PivotTableFromBill
ELSE 
CREATE TABLE dbo.PivotTableFromBill
(
	SellerID INT NOT NULL,
	Pr472 INT NOT NULL, 
	Pr668 INT NOT NULL,
	Pr713 INT NOT NULL,
	Pr270 INT NOT NULL,
	Pr834 INT NOT NULL,
	Pr993 INT NOT NULL
)
GO

INSERT INTO dbo.PivotTableFromBill VALUES
(51, 1, 0, 0, 0, 0, 0),
(142, 1, 0, 0, 0, 0, 0),
(759, 0, 1, 0, 0, 0, 0),
(784, 0, 0, 1, 0, 0, 0),
(647, 0, 0, 0, 1, 0, 0),
(732, 0, 0, 0, 0, 1, 0),
(484, 0, 0, 0, 0, 0, 1),
(574, 0, 0, 0, 0, 0, 1),
(18, 0, 0, 0, 0, 0, 0);

-- unpivot table
SELECT BillSellerID, BillProductID, BillCountCompany
FROM
(
	SELECT SellerID AS 'BillSellerID', 
		   Pr472,-- AS '472',
		   Pr668,-- AS '668',
		   Pr713,-- AS '713',
		   Pr270,-- AS '270',
		   Pr834,-- AS '834',
		   Pr993-- AS '993'
	FROM dbo.PivotTableFromBill
) AS PivotSource
UNPIVOT
(
	BillCountCompany
	FOR BillProductID IN (PivotSource.Pr472, PivotSource.Pr668, PivotSource.Pr713, PivotSource.Pr270, PivotSource.Pr834, PivotSource.Pr993)
) AS UnpivotSource
--WHERE BillCountCompany > 0
ORDER BY BillSellerID

-- Request #25: MERGE
IF OBJECT_ID ('dbo.BookInventory', 'U') IS NOT NULL
	DROP TABLE dbo.BookInventory
ELSE
CREATE TABLE dbo.BookInventory  -- target
(
	TitleID INT NOT NULL PRIMARY KEY,
	Title NVARCHAR(100) NOT NULL,
	Quantity INT NOT NULL
	CONSTRAINT Quantity_Default_1 DEFAULT 0
);
 
IF OBJECT_ID ('dbo.BookOrder', 'U') IS NOT NULL
	DROP TABLE dbo.BookOrder
ELSE
CREATE TABLE dbo.BookOrder  -- source
(
	TitleID INT NOT NULL PRIMARY KEY,
	Title NVARCHAR(100) NOT NULL,
	Quantity INT NOT NULL
    CONSTRAINT Quantity_Default_2 DEFAULT 0
);
 
INSERT INTO BookInventory VALUES
(1, 'The Catcher in the Rye', 6),
(2, 'Pride and Prejudice', 3),
(3, 'The Great Gatsby', 0),
(5, 'Jane Eyre', 0),
(6, 'Catch 22', 0),
(8, 'Slaughterhouse Five', 4);
 
INSERT INTO BookOrder VALUES
(1, 'The Catcher in the Rye', 3),
(3, 'The Great Gatsby', 0),
(4, 'Gone with the Wind', 4),
(5, 'Jane Eyre', 5),
(7, 'Age of Innocence', 8);

SELECT * FROM BookInventory;
SELECT * FROM BookOrder;

-- CASE 1: Using only MATCHED with keyword UPDATE
--MERGE BookInventory AS BookTarget
--USING BookOrder AS BookSource
--ON BookTarget.TitleID = BookSource.TitleID
--WHEN MATCHED THEN
--	UPDATE
--	SET BookTarget.Quantity = BookTarget.Quantity + BookSource.Quantity;

--SELECT * FROM BookInventory

-- CASE 2: Using MATCHED with keyword DELETE
--MERGE BookInventory AS BookTarget
--USING BookOrder AS BookSource
--ON BookTarget.TitleID = BookSource.TitleID
--WHEN MATCHED 
--     AND BookTarget.Quantity + BookSource.Quantity = 0
--     THEN DELETE
--WHEN MATCHED THEN
--	UPDATE
--	SET BookTarget.Quantity = BookTarget.Quantity + BookSource.Quantity;

--SELECT * FROM BookInventory

-- Case 3: Using NOT MATCHED with keyword INSERT
MERGE BookInventory AS BookTarget
USING BookOrder AS BookSource
ON BookTarget.TitleID = BookSource.TitleID
WHEN MATCHED 
     AND BookTarget.Quantity + BookSource.Quantity = 0
     THEN DELETE
WHEN MATCHED THEN
	UPDATE
	SET BookTarget.Quantity = BookTarget.Quantity + BookSource.Quantity
WHEN NOT MATCHED BY TARGET THEN
	INSERT (TitleID, Title, Quantity)
	VALUES (BookSource.TitleID, BookSource.Title, BookSource.Quantity)
OUTPUT $action,
	   DELETED.TitleID AS TargetTitleID,
	   DELETED.Title AS TargetTiltle,
	   DELETED.Quantity AS TargetQuantity,
	   INSERTED.TitleID AS SourceTiltleID,
	   INSERTED.Title AS SourceTitle,
	   INSERTED.Quantity AS SourceQuantity;

SELECT * FROM BookInventory