USE DigitalMarketplace;

DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS [Returns];
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Warehouse;
DROP TABLE IF EXISTS Promotions;
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS DeliveryDetails;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS ProductCategories;
DROP TABLE IF EXISTS Managers;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS DeliveryÑompany;
DROP TABLE IF EXISTS [Messages];
DROP TABLE IF EXISTS Users_NewsletterSubscriptions;
DROP TABLE IF EXISTS ShoppingCart;
DROP TABLE IF EXISTS ProductReviews;
DROP TABLE IF EXISTS NewsletterSubscriptions;
DROP TABLE IF EXISTS Addresses;
DROP TABLE IF EXISTS Positions;

GO

CREATE TABLE Payments
(
	PaymentID INT IDENTITY(1,1),	-- PRIMARY KEY
	Amount MONEY NOT NULL,			-- CHECK
	PaymentDate DATE NOT NULL,
	PaymentMethod VARCHAR(128),
	OrderID INT NOT NULL,			-- UNIQUE FOREIGN KEY

	CONSTRAINT PK_Payments_PaymentID PRIMARY KEY(PaymentID),
	CONSTRAINT CHK_Payments_Amount CHECK(Amount BETWEEN 0 AND POWER(2,20)),
);

GO

CREATE TABLE [Returns]
(
	ReturnID INT IDENTITY(1, 1),	-- PRIMARY KEY
	ReturnReason VARCHAR(256),
	ReturnStatus VARCHAR(32),		-- CHECK
	OrderID INT NOT NULL,			-- UNIQUE FOREIGN KEY

	CONSTRAINT PK_Returns_ReturnID PRIMARY KEY(ReturnID),
	CONSTRAINT PK_Returns_ReturnStatus CHECK(ReturnStatus IN 
		('Pending', 'Under Review', 'Approved', 'Denied', 'Refunded', 'Exchanged', 'Processing')),
);

GO

CREATE TABLE Suppliers
(
	SupplierID INT IDENTITY(1, 1),	-- PRIMARY KEY
	CompanyName VARCHAR(256) NOT NULL,
	HeadFirstName VARCHAR(64),
	HeadLastName VARCHAR(64),
	Phone VARCHAR(32),				-- CHECK
	Email VARCHAR(32),				-- CHECK
	OfficeAddressID INT NOT NULL,	-- UNIQUE FOREIGN KEY

	CONSTRAINT PK_Suppliers_SupplierID PRIMARY KEY(SupplierID),
	CONSTRAINT CHK_Suppliers_Phone CHECK(Phone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	CONSTRAINT CHK_Suppliers_Email CHECK(Email LIKE '_%@_%._%'),
);

GO

CREATE TABLE Warehouse
(
	WarehouseID INT IDENTITY(1, 1),	-- PRIMARY KEY
	[Name] VARCHAR(256),
	TotalCapacity INT NOT NULL,		-- CHECK
	UsedCapacity INT,				-- CHECK
	SupplierID INT NOT NULL,		-- FOREIGN KEY
	AddressID INT NOT NULL,			-- UNIQUE FOREIGN KEY

	CONSTRAINT PK_Warehouse_WarehouseID PRIMARY KEY(WarehouseID),
	CONSTRAINT CHK_Warehouse_TotalCapacity CHECK(TotalCapacity BETWEEN 0 AND POWER(2, 30)),
	CONSTRAINT CHK_Warehouse_UsedCapacity CHECK(UsedCapacity BETWEEN 0 AND TotalCapacity),
);

GO

CREATE TABLE Promotions
(
	PromotionID INT IDENTITY(1, 1),	-- PRIMARY KEY
	[Name] VARCHAR(256) NOT NULL,
	Discount REAL NOT NULL,			-- CHECK
	[Description] VARCHAR(512),
	StartDate DATE,
	EndDate DATE NOT NULL

	CONSTRAINT PK_Promotions_PromotionID PRIMARY KEY(PromotionID),
	CONSTRAINT CHK_Promotions_Discount CHECK(Discount BETWEEN 0 AND 1),
);

GO

CREATE TABLE OrderDetails
(
	OrderID INT NOT NULL,				-- PRIMARY KEY -> FOREIGN KEY1
	ProductID INT NOT NULL,				-- PRIMARY KEY -> FOREIGN KEY2
	Quantity INT NOT NULL,				-- CHECK
	Price MONEY NOT NULL,				-- CHECK
	WarehouseID INT NOT NULL,			-- FOREIGN KEY

	CONSTRAINT PK_OrderDetails_OrderID_ProductID PRIMARY KEY(OrderID, ProductID),
	CONSTRAINT CHK_OrderDetails_Quantity CHECK(Quantity BETWEEN 1 AND POWER(2, 16)),
	CONSTRAINT CHK_OrderDetails_Price CHECK (Price > 0 AND Price <= POWER(2, 20)),
);

GO

CREATE TABLE Orders
(
	OrderID INT IDENTITY(1, 1),		-- PRIMARY KEY
	OrderDate DATE,			
	[Status] VARCHAR(64),			-- CHECK
	UserID INT NOT NULL,			-- FOREIGN KEY
	DeliveryDetailsID INT NOT NULL,	-- UNIQUE FOREIGN KEY

	CONSTRAINT PK_Orders_OrderID PRIMARY KEY(OrderID),
	CONSTRAINT CHK_Orders_Status CHECK([Status] IN 
		('New', 'Processing', 'Shipped', 'Delivered', 'Cancelled')),
);

GO

CREATE TABLE Addresses
(
	AddressID INT IDENTITY(1, 1),	-- PRIMARY KEY
	Country VARCHAR(256) NOT NULL,
	City VARCHAR (256) NOT NULL,
	Region VARCHAR(256),
	Street VARCHAR(256) NOT NULL,
	BuildingNumber INT NOT NULL,	-- CHECK
	PostalCode VARCHAR(64) NOT NULL,	

	CONSTRAINT PK_Addresses_AddressID PRIMARY KEY(AddressID),
	CONSTRAINT CHK_Addresses_BuildingNumber CHECK(BuildingNumber BETWEEN 1 AND POWER(2, 16)),
);

GO

CREATE TABLE DeliveryDetails
(
	DeliveryDetailsID INT IDENTITY(1, 1),	-- PRIMARY KEY
	SendingDate DATE NOT NULL,
	DeliveryDate DATE NOT NULL,
	DeliveryStatus VARCHAR(64),		-- CHECK
	TrackingNumber INT NOT NULL,	-- UNIQUE
	AddressID INT NOT NULL,			-- UNIQUE FOREIGN KEY
	DeliveryÑompanyID INT NOT NULL,	-- FOREIGN KEY

	CONSTRAINT PK_DeliveryDetails_CompanyID_DeliveryDetailsID PRIMARY KEY(DeliveryDetailsID),
	CONSTRAINT CHK_DeliveryDetails_DeliveryDate CHECK(DeliveryDate > SendingDate),
	CONSTRAINT UQ_DeliveryDetails_TrackingNumber UNIQUE(TrackingNumber),
	CONSTRAINT CHK_DeliveryDetails_DeliveryStatus CHECK(DeliveryStatus IN 
		('Awaiting Shipment', 'Shipped', 'In Transit', 'Delivered', 'Delayed', 'Failed Delivery', 'Returning to Sender')),
);

GO

CREATE TABLE ProductCategories
(
	CategoryID INT IDENTITY(1, 1),	-- PRIMARY KEY
	[Name] VARCHAR(128) NOT NULL,
	[Description] VARCHAR(1024),

	CONSTRAINT PK_ProductCategories_CategoryID PRIMARY KEY(CategoryID),
);

GO

CREATE TABLE Products
(
	ProductID INT IDENTITY(1, 1),	-- PRIMARY KEY
	[Name] VARCHAR(256) NOT NULL,
	UnitPrice MONEY NOT NULL,		-- CHECK
	UnitWeight REAL NOT NULL,		-- CHECK
	StockAvailability INT NOT NULL,	-- CHECK
	[Description] VARCHAR(1024),
	CategoryID INT NOT NULL,		-- FOREIGN KEY
	PromotionID	INT,				-- FOREIGN KEY

	CONSTRAINT PK_Products_ProductID PRIMARY KEY(ProductID),
	CONSTRAINT CHK_Products_UnitPrice CHECK (UnitPrice > 0 AND UnitPrice <= POWER(2, 20)),
	CONSTRAINT CHK_Products_UnitWeight CHECK (UnitWeight > 0 AND UnitWeight <= POWER(2, 16)),
	CONSTRAINT CHK_Products_StockAvailability CHECK (StockAvailability BETWEEN 0 AND POWER(2, 20)),
);

GO

CREATE TABLE Positions
(
	PositionID INT IDENTITY(1, 1),				-- PRIMARY KEY
	[Name] VARCHAR(64) NOT NULL,
	Salary MONEY NOT NULL,						-- CHECK
	ExperienceRequired INT,						-- CHECK
	EducationRequired VARCHAR(256) NOT NULL,	
	[Description] VARCHAR(4096),

	CONSTRAINT PK_Positions_PositionID PRIMARY KEY(PositionID),
	CONSTRAINT CHK_Positions_Salary CHECK(Salary BETWEEN 0 AND POWER(2, 16)),
	CONSTRAINT CHK_Positions_ExperienceRequired CHECK(ExperienceRequired BETWEEN 0 AND 12*100),
);

GO

CREATE TABLE Managers
(
	ManagerID INT IDENTITY(1, 1),	-- PRIMARY KEY
	FirstName VARCHAR(64) NOT NULL,
	LastName VARCHAR(64) NOT NULL,
	[Status] VARCHAR(32),			-- CHECK
	AppointmentDate DATE,
	Phone VARCHAR(64) NOT NULL,		-- CHECK
	Email VARCHAR(64) NOT NULL,		-- CHECK
	PositionID INT NOT NULL,		-- FOREIGN KEY
	AddressID INT NOT NULL,			-- UNIQUE FOREIGN KEY

	CONSTRAINT PK_Managers_ManagerID PRIMARY KEY(ManagerID),
	CONSTRAINT CHK_Managers_Status CHECK([Status] IN ('Active', 'Inactive')),
	CONSTRAINT CHK_Managers_Phone CHECK(Phone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	CONSTRAINT CHK_Managers_Email CHECK(Email LIKE '_%@_%._%'),
);

GO

CREATE TABLE Users
(
	UserID INT IDENTITY(1, 1),		-- PRIMARY KEY
	FirstName VARCHAR(64) NOT NULL,
	LastName VARCHAR(64) NOT NULL,
	Phone VARCHAR(64) NOT NULL,		-- CHECK
	Email VARCHAR(64) NOT NULL,		-- CHECK
	AddressID INT,					-- UNIQUE FOREIGN KEY

	CONSTRAINT PK_Users_UserID PRIMARY KEY(UserID),
	CONSTRAINT CHK_Users_Phone CHECK(Phone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	CONSTRAINT CHK_Users_Email CHECK(Email LIKE '_%@_%._%'),
);

GO

CREATE TABLE DeliveryÑompany
(
	DeliveryÑompanyID INT IDENTITY(1, 1),	-- PRIMARY KEY
	[Name] VARCHAR(256) NOT NULL,
	Rating REAL,							-- CHECK
	AvarageDelivaryTime TIME,
	Phone VARCHAR(64) NOT NULL,				-- CHECK
	Email VARCHAR(64) NOT NULL,				-- CHECK
	AddressID INT NOT NULL,					-- UNIQUE FOREIGN KEY

	CONSTRAINT PK_DeliveryÑompany_DeliveryÑompanyID PRIMARY KEY(DeliveryÑompanyID),
	CONSTRAINT CHK_DeliveryÑompany_Rating CHECK(Rating BETWEEN 1 AND 10),
	CONSTRAINT CHK_DeliveryÑompany_Phone CHECK(Phone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	CONSTRAINT CHK_DeliveryÑompany_Email CHECK(Email LIKE '_%@_%._%'),
);

GO

CREATE TABLE [Messages]
(
	MessageID INT IDENTITY(1, 1),	-- PRIMARY KEY
	UserID INT NOT NULL,			-- FOREIGN KEY
	ManagerID INT NOT NULL,			-- FOREIGN KEY
	MessageText VARCHAR(4096) NOT NULL,
	[DateTime] DATETIME NOT NULL,

	CONSTRAINT PK_Messages_MessageID PRIMARY KEY(MessageID),
);

GO

CREATE TABLE Users_NewsletterSubscriptions
(
	UserID INT NOT NULL,			-- PRIMARY KEY -> FOREIGN KEY1
	SubscriptionID INT NOT NULL,	-- PRIMARY KEY -> FOREIGN KEY2

	CONSTRAINT PK_Users_NewsletterSubscriptions_UserID_SubscriptionID PRIMARY KEY(UserID, SubscriptionID),
);

GO

CREATE TABLE ShoppingCart
(
	UserID INT NOT NULL,	-- PRIMARY KEY -> FOREIGN KEY1
	ProductID INT NOT NULL,	-- PRIMARY KEY -> FOREIGN KEY2
	Quantity INT NOT NULL,	-- CHECK

	CONSTRAINT PK_ShoppingCard_UserID_ProductID PRIMARY KEY(UserID, ProductID),
	CONSTRAINT CHK_ShoppingCard_UserID_Quantity CHECK(Quantity > 0 AND Quantity <= POWER(2,16)),
);

GO

CREATE TABLE ProductReviews
(
	ProductReviewID INT IDENTITY(1, 1),	-- PRIMARY KEY
	UserID INT NOT NULl,				-- FOREIGN KEY
	ProductID INT NOT NULL,				-- FOREIGN KEY
	Rating REAL,						-- CHECK
	Comment VARCHAR(4096),

	CONSTRAINT PK_ProductReviews_ProductReviewID PRIMARY KEY(ProductReviewID),
	CONSTRAINT CHK_ProductReviews_Rating CHECK(Rating BETWEEN 1 AND 10),
);

GO

CREATE TABLE NewsletterSubscriptions
(
	SubscriptionID INT IDENTITY(1, 1),	-- PRIMARY KEY
	SubscriptionStatus VARCHAR(64) NOT NULL,
	Frequency TIME NOT NULL,
	AllowedSMS BIT,
	LastSentDate DATETIME,
	Desctiption VARCHAR(1024) NOT NULL,

	CONSTRAINT PK_NewsletterSubscriptions_SubscriptionID PRIMARY KEY(SubscriptionID),
);

GO