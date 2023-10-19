CREATE DATABASE VanMart_OLAP


--Dimension
CREATE TABLE CustomerDimension(
CustomerCode INT PRIMARY KEY IDENTITY(1,1),
CustomerID CHAR(7),
CustomerDOB VARCHAR(255),
CustomerGender VARCHAR(10),
CustomerPhone VARCHAR(20),
CustomerAddress VARCHAR (255)
) 

CREATE TABLE StaffDimension(
StaffCode INT PRIMARY KEY IDENTITY (1,1),
StaffID CHAR(7),
StaffName VARCHAR(20),
StaffDOB DATE,
StaffGender VARCHAR(10),
StaffAddress VARCHAR(255),
StaffPhone VARCHAR(20),
StaffSalary INT,
ValidFrom DATETIME,
ValidTO DATETIME
)

CREATE TABLE GoodsDimension(
GoodsCode INT PRIMARY KEY IDENTITY(1,1),
GoodsID CHAR(7), 
GoodsName VARCHAR(255),
GoodsSellingPrice INT,
GoodsBuyingPRice INT,
Goodsweight INT,
ValidFrom DATETIME,
ValidTo DATETIME
)
CREATE TABLE SupplierDimension(
supplierCode INT PRIMARY KEY IDENTITY (1,1),
SupplierID CHAR(7),
CityName VARCHAR(255),
SupplierName VARCHAR(20),
SupplierAddress VARCHAR(255),
SupplierPhone VARCHAR(20),
SupplierEmail VARCHAR (20)
)

CREATE TABLE BranchDimension(
BranchCode INT PRIMARY KEY IDENTITY (1,1),
BranchID CHAR(7),
CityName VARCHAR(255),
BranchName VARCHAR(255),
BranchPhone VARCHAR(255),
)

CREATE TABLE BenefitDimension(
BenefitCode INT PRIMARY KEY IDENTITY (1,1),
BenefitID CHAR(7),
BenefitName VARCHAR(255),
BenefitPrice INT,
BenefitDescription VARCHAR(255),
ValidFrom DATETIME,
ValidTo DATETIME
)

CREATE TABLE TimeDimension(
[TimeCode] INT PRIMARY KEY IDENTITY(1,1),
[Date] DATE,
[Day] INT,
[Month] INT,
[Year] INT,
[Quarter] INT,
)

CREATE TABLE FilterTimeStamp(
TableName VARCHAR(255) PRIMARY KEY,
LastETL DATETIME
)
--Fact
CREATE TABLE SalesFact(
GoodsCode INT,
Staffcode INT,
CustomerCode INT,
BranchCode INT,
[TotalEarning] BIGINT,
[TotalGoodSold] BIGINT
)
CREATE TABLE PurchaseFact(
Goodscode INT,
StaffCode INT,
BranchCode INT,
SupplierCode INT,
[TotalPurchaseCost] BIGINT,
[TotalGoodsPurchase] BIGINT
)
CREATE TABLE ReturnFact(
GoodsCode INT,
StaffCode INT,  
BranchCode INT,
SupplierCode INT,
[TotalGoodsReturned]  BIGINT, 
[NumberOfStaff]  BIGINT)

CREATE TABLE SubscriptionFact(
CustomerCode INT,
StaffCode INT,
BenefitCode INT,
[TotalSubcriptionEarning] BIGINT,
[NumberOfSubscriber] BIGINT
)

IF EXISTS (
SELECT * FROM VanMart_OLAP.dbo.FilterTimeStamp
WHERE TableName = 'TimeDimension'
)

BEGIN
SELECT DISTINCT
[Date] = X.DATE,
[Day] = DAY(X.DATE),
[Month] = MONTH(X.DATE),
[Year] = YEAR(X.DATE),
[Quarter] = DATEPART(QUARTER, X.DATE)
FROM (
SELECT [Date] = SalesDate
FROM VanMart.dbo.TrSalesHeader
UNION
SELECT [Date] = PurchaseDate
FROM VanMart.dbo.TrPurchaseHeader
UNION 
SELECT [Date] = ReturnDate
FROM VanMart.dbo.TrReturnHeader
UNION
SELECT [Date] = SubscriptionStartDate
FROM VanMart.dbo.TrSubscriptionHeader
) AS X WHERE (
SELECT LastETL
FROM VanMart_OLAP.dbo.FilterTimeStamp
) > X.DATE

END 

ELSE 

BEGIN 
SELECT DISTINCT
[Date] = X.DATE,
[Day] = DAY(X.DATE),
[Month] = MONTH(X.DATE),
[Year] = YEAR(X.DATE),
[Quarter] = DATEPART(QUARTER, X.DATE)
FROM (
SELECT [Date] = SalesDate
FROM VanMart.dbo.TrSalesHeader
UNION
SELECT [Date] = PurchaseDate
FROM VanMart.dbo.TrPurchaseHeader
UNION 
SELECT [Date] = ReturnDate
FROM VanMart.dbo.TrReturnHeader
UNION
SELECT [Date] = SubscriptionStartDate
FROM VanMart.dbo.TrSubscriptionHeader
) AS X 

IF EXISTS (
SELECT * FROM VanMart_OLAP..FilterTimeStamp
WHERE TableName = 'TimeDimension'
)
--Sudah pernah 
BEGIN 
UPDATE VanMart_OLAP.dbo.FilterTimeStamp
SET LastETL = GETDATE()
WHERE TableName = 'TimeDimension'
END

ELSE 
 
BEGIN 
INSERT INTO VanMart_OLAP.dbo.FilterTimeStamp
VALUES ('TimeDimension', GETDATE())
END

 





























