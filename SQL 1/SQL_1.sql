CREATE DATABASE Lab01;	-- create database
GO	-- end package

Use Lab01;	-- using database
GO

-- create tables with their properties
CREATE TABLE tblSeller
(
	SellerID INT NOT NULL,
	SellerFirstName VARCHAR(20) NOT NULL,
	SellerLastName VARCHAR(20) NOT NULL,
	SellerGender VARCHAR(10) NOT NULL,
	SellerVisaCardSeries VARCHAR(20) NOT NULL
);

CREATE TABLE tblCompany
(
	CompanyID INT NOT NULL,
	CompanyName VARCHAR(50) NOT NULL,
	CompanyLocation VARCHAR(50) NOT NULL
);

CREATE TABLE tblProduct
(
	ProductID INT NOT NULL,
	ProductName VARCHAR(20) NOT NULL,
	ProductMaterial VARCHAR(20) NOT NULL,
	ProductMadeIn VARCHAR(20) NOT NULL
);

CREATE TABLE tblBill
(
	BillSellerID INT NOT NULL,
	BillCompanyID INT NOT NULL,
	BillProductID INT NOT NULL,
	BillQuantity INT NOT NULL,
	BillPrice INT NOT NULL
);

GO

DROP DATABASE Lab01;
GO