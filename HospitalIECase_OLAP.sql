
CREATE TABLE MedicineDimension(
MedicineCode INT PRIMARY KEY IDENTITY (1,1),
MedicineID INT,
MedicineName VARCHAR(255),
MedicineExpiredDate DATE,
MedicineSellingPrice BIGINT,
MedicineBuyingPrice BIGINT,	
ValidFrom DATETIME,
ValidTo DATETIME )

CREATE TABLE DoctorDimension(
DoctorCode INT PRIMARY KEY IDENTITY (1,1),
DoctorID INT,
DoctorName VARCHAR(255),
DoctorAddress VARCHAR(255),
DoctorSalary BIGINT,
ValidFrom DATETIME,
ValidTo DATETIME
)

CREATE TABLE StaffDimension(
StaffCode INT PRIMARY KEY IDENTITY (1,1),
StaffID INT,
StaffName VARCHAR(255),
StaffDOB DATE,
StaffGender CHAR(1),
StaffAddress VARCHAR(255),
StaffSalary BIGINT,
ValidFrom DATETIME,
ValidTo DATETIME)

CREATE TABLE CustomerDimension(
CustomerCode INT PRIMARY KEY IDENTITY (1,1),
CustomerID INT,
CustomerName VARCHAR(255),
CustomerDOB DATE,
CustomerGender CHAR(1),
CustomerAddress VARCHAR(255),
ValidFrom DATETIME,
ValidTo DATETIME)


CREATE TABLE BenefitDimension(
BenefitCode INT PRIMARY KEY IDENTITY (1,1),
BenefitID INT,
BenefitName VARCHAR(255),
BenefitPrice BIGINT,
ValidFrom DATETIME,
ValidTo DATETIME
)
CREATE TABLE TreatmentDimension(
TreatmentCode INT PRIMARY KEY IDENTITY (1,1),
TreatmentID INT,
TreatmentName VARCHAR(255),
TreatemntPrice BIGINT,
ValidFrom DATETIME,
ValidTo DATETIME
) 

CREATE TABLE DistributorDimension(
DistributorCode INT PRIMARY KEY IDENTITY (1,1),
DistributorID INT,
DistributorName VARCHAR(255),
DistributorAddress VARCHAR(255),
DistributorPhone VARCHAR(255)
)


--FACT 
CREATE TABLE SalesTransaction(
MedicineCode INT,
StaffCode INT,
CustomerCode INT,
TimeCode INT,
[Total Sales Earning] BIGINT, 
[Total MEdicine sold] BIGINT ) 

CREATE TABLE PurchaseTransaction(
MedicineCode INT,
StaffCode INT,
DisributorCode INT,
TimeCode INT,
[Total Purchase Cost] BIGINT,
[Total Medicine Sold] BIGINT
)
CREATE TABLE SubscriptionTransaction (
CustomerCode INT,
StaffCode INT,
BenefitCode INT,
[Total Subscription Earning] BIGINT, 
[Subcriber Count] BIGINT )

CREATE TABLE ServiceTransaction(
CustomerCode INT,
TreatmentCode INT,
DoctorCode INT,
[Total Service Earning] BIGINT,
[Number Of Doctor] BIGINT

)

DROP TABLE FilterTimeStamp
CREATE TABLE TimeDimension(
[TimeCode] INT PRIMARY KEY IDENTITY (1,1),
[Date]  DATE,
[Month] INT, 
[Quarter] INT,
[Year] INT 
)

Create Table FilterTimeStamp(
TableName VARCHAR(255) PRIMARY KEY,
LastETL DATETIME
)


IF EXISTS(
SELECT * FROM OLAP_HospitalIE.dbo.FilterTimeStamp
WHERE TableName = 'TimeDimension'
)
BEGIN
--sudah pernah 
SELECT DISTINCT
	[Date] = X.DATE,
	[Month] = MONTH(X.DATE),
	[Quarter] = DATEPART(Quarter,X.DATE),
	[Year] = YEAR(X.DATE) 
FROM (
SELECT 
	[DATE] = SalesDate
	FROM OLTP_HospitalIE.dbo.TrSalesHeader
	UNION 
	SELECT 
	[DATE] = PurchaseDate
	FROM OLTP_HospitalIE.dbo.TrPurchaseHeader
	UNION 
	SELECT
	[DATE] = SubscriptionStartDate
	FROM OLTP_HospitalIE.dbo.TrSubscriptionHeader
	UNION
	SELECT 
	[DATE] = ServiceDate
	FROM OLTP_HospitalIE.dbo.TrServiceHeader
) AS X WHERE(
SELECT LastETL
FROM
OLAP_HospitalIE.dbo.FilterTimeStamp) > X.DATE
END 

ELSE 

BEGIN
SELECT DISTINCT 
	[Date] = X.DATE,
	[Month] = MONTH(X.DATE),
	[Quarter] = DATEPART(Quarter,X.DATE),
	[Year] = YEAR(X.DATE) 
FROM (
	SELECT 
	[DATE] = SalesDate
	FROM OLTP_HospitalIE.dbo.TrSalesHeader
	UNION 
	SELECT 
	[DATE] = PurchaseDate
	FROM OLTP_HospitalIE.dbo.TrPurchaseHeader
	UNION 
	SELECT
	[DATE] = SubscriptionStartDate
	FROM OLTP_HospitalIE.dbo.TrSubscriptionHeader
	UNION
	SELECT 
	[DATE] = ServiceDate
	FROM OLTP_HospitalIE.dbo.TrServiceHeader
) AS X 
END 


--FiltertimeStamp
IF EXISTS(
SELECT * FROM OLAP_HospitalIE.dbo.FilterTimeStamp
WHERE TableName = 'TimeDimension'
)
--Belum pernah 
BEGIN
UPDATE OLAP_HospitalIE.dbo.FilterTimeStamp 
SET LastETL = GETDATE()
WHERE TableName = 'TimeDimension' 
END 

ELSE 
--Sudah Pernah 
BEGIN 
INSERT INTO OLAP_HospitalIE.dbo.FilterTimeStamp
VALUES ('TimeDimension', GETDATE())
END 

