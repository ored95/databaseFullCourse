BULK INSERT dbo.tblSeller FROM 'D:\DATA\dbBill\Seller.txt'
WITH (DATAFILETYPE = 'char', FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n');
GO

BULK INSERT dbo.tblCompany FROM 'D:\DATA\dbBill\Company.txt'
WITH (DATAFILETYPE = 'char', FIELDTERMINATOR = ';', ROWTERMINATOR = '\n');
GO

BULK INSERT dbo.tblProduct FROM 'D:\DATA\dbBill\Product.txt'
WITH (DATAFILETYPE = 'char', FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n');
GO

BULK INSERT dbo.tblBill FROM 'D:\DATA\dbBill\Bill.txt'
WITH (DATAFILETYPE = 'char', FIELDTERMINATOR = '\t', ROWTERMINATOR = '\n');
GO