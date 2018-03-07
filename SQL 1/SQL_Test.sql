Use Lab01;	-- using database
GO

SELECT TOP 10 SellerFirstName, SellerLastName, SellerVisaCardSeries 
FROM dbo.tblSeller 
WHERE (SellerGender = N'Male') AND (SellerVisaCardSeries LIKE N'41%1');
GO

SELECT Top 10 * 
FROM dbo.tblBill INNER JOIN dbo.tblSeller  ON tblBill.BillSellerID = tblSeller.SellerID
				 INNER JOIN dbo.tblCompany ON tblBill.BillCompanyID = tblCompany.CompanyID
				 INNER JOIN dbo.tblProduct ON tblBill.BillProductID = tblProduct.ProductID;
GO

SELECT SellerFirstName, SellerLastName, CompanyName, ProductName, BillQuantity, BillPrice
FROM dbo.tblBill INNER JOIN dbo.tblSeller  ON tblBill.BillSellerID = tblSeller.SellerID
				 INNER JOIN dbo.tblCompany ON tblBill.BillCompanyID = tblCompany.CompanyID
				 INNER JOIN dbo.tblProduct ON tblBill.BillProductID = tblProduct.ProductID
				 ORDER BY BillPrice ASC;
GO