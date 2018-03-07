USE Lab01;
GO

-- add Primary Key and Foreign Key
ALTER TABLE dbo.tblSeller ADD 
	CONSTRAINT PK_SellerID PRIMARY KEY(SellerID),
	CONSTRAINT CK_SellerGender CHECK ((SellerGender = 'Male') OR (SellerGender = 'Female')),
	CONSTRAINT CK_Valid_SellerVisaCardSeries CHECK ((SellerVisaCardSeries LIKE '4%') AND (LEN(SellerVisaCardSeries) = 16));

ALTER TABLE dbo.tblCompany ADD CONSTRAINT PK_CompanyID PRIMARY KEY(CompanyID);

ALTER TABLE dbo.tblProduct ADD CONSTRAINT PK_ProductID PRIMARY KEY(ProductID);

ALTER TABLE dbo.tblBill ADD
	CONSTRAINT PK_Bill PRIMARY KEY(BillSellerID, BillCompanyID, BillProductID),
	CONSTRAINT FK_Bill_Seller FOREIGN KEY(BillSellerID) REFERENCES dbo.tblSeller(SellerID),
	CONSTRAINT FK_Bill_Company FOREIGN KEY(BillCompanyID) REFERENCES dbo.tblCompany(CompanyID),
	CONSTRAINT FK_Bill_Product FOREIGN KEY(BillProductID) REFERENCES dbo.tblProduct(ProductID);
GO

CREATE RULE RULE_GreaterThanZero AS @value > 0;
GO

EXEC sp_bindrule 'RULE_GreaterThanZero', 'dbo.tblBill.BillQuantity';
EXEC sp_bindrule 'RULE_GreaterThanZero', 'dbo.tblBill.BillPrice';
GO