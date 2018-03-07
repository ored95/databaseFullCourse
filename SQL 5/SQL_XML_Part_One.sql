------------------------------------------------
--------------- XML documents ------------------
------------------------------------------------
-- Part #1: Test database from the first DB,
--			using semantic FOR XML
------------------------------------------------

USE Lab01;
GO

-- Show type #1: list elements (using AUTO)
SELECT TOP 5 CompanyName, CompanyLocation
FROM tblCompany
FOR XML AUTO, ELEMENTS
GO

-- Show type #2: show schema first and then data (using RAW)
SELECT TOP 5 CompanyName, CompanyLocation
FROM tblCompany
FOR XML RAW, XMLDATA
GO

-- Create XML with name Seller as elements (using RAW)
SELECT TOP 10 *
FROM tblSeller
FOR XML RAW('Seller'), ELEMENTS
GO

-- Create XML (using EXPLICIT) to show [schema,] data
SELECT 1 AS Tag, NULL AS Parent, ProductName AS [Product!1!Name], ProductMaterial AS [Product!1!Material], ProductMadeIn AS [Product!1!MadeIn]
FROM tblProduct
WHERE ProductName = 'cap'
--FOR XML EXPLICIT--, XMLDATA
FOR XML EXPLICIT, XMLDATA
GO

-- Create XML (using EXPLICIT) to show as list
SELECT 1    AS Tag,
       NULL AS Parent,  
       SellerID AS [Seller!1!ID],  
       NULL     AS [Information!2!FirstName!ELEMENT],  
       NULL     AS [Information!2!LastName!ELEMENT],
       NULL     AS [Information!2!Gender!ELEMENT],
       NULL		AS [Information!2!Series!ELEMENT]
FROM   tblSeller
UNION ALL  
SELECT 2 as Tag,
       1 as Parent,
       SellerID,
       SellerFirstName,   
       SellerLastName,
	   SellerGender,
	   SellerVisaCardSeries
FROM   tblSeller
ORDER BY [Seller!1!ID], [Information!2!FirstName!ELEMENT]
FOR XML EXPLICIT, XMLDATA;
GO

-- Create XML (using PATH)
SELECT *
FROM dbo.BookInventory
--FOR XML PATH('Book')--, ELEMENTS XSINIL
FOR XML PATH('Book'), ELEMENTS XSINIL
--FOR XML PATH('Book'), ELEMENTS ABSENT -- (same as without using ELEMENTS XSINIL)
GO