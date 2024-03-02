USE DigitalMarketplace;

-- DROP CONSTRAINTS IF EXIST

ALTER TABLE Payments
DROP CONSTRAINT IF EXISTS FK_Payments_OrderID;

ALTER TABLE Payments
DROP CONSTRAINT IF EXISTS UQ_Payments_OrderID;

GO

ALTER TABLE [Returns]
DROP CONSTRAINT IF EXISTS FK_Returns_OrderID;

ALTER TABLE [Returns]
DROP CONSTRAINT IF EXISTS UQ_Returns_OrderID;

GO

ALTER TABLE Suppliers
DROP CONSTRAINT IF EXISTS FK_Suppliers_OfficeAddressID;

ALTER TABLE Suppliers
DROP CONSTRAINT IF EXISTS UQ_Suppliers_OfficeAddressID;

GO

ALTER TABLE Warehouse
DROP CONSTRAINT IF EXISTS FK_Warehouse_SupplierID;

ALTER TABLE Warehouse
DROP CONSTRAINT IF EXISTS FK_Warehouse_AddressID;

ALTER TABLE Warehouse
DROP CONSTRAINT IF EXISTS UQ_Warehouse_AddressID;

GO

ALTER TABLE OrderDetails
DROP CONSTRAINT IF EXISTS FK_OrderDetails_OrderID;

ALTER TABLE OrderDetails
DROP CONSTRAINT IF EXISTS FK_OrderDetails_ProductID;

ALTER TABLE OrderDetails
DROP CONSTRAINT IF EXISTS FK_OrderDetails_WarehouseID;

GO

ALTER TABLE Orders
DROP CONSTRAINT IF EXISTS FK_Orders_UserID;

ALTER TABLE Orders
DROP CONSTRAINT IF EXISTS FK_Orders_DeliveryDetailsID;

ALTER TABLE Orders
DROP CONSTRAINT IF EXISTS UQ_Orders_DeliveryDetailsID;

GO

ALTER TABLE DeliveryDetails
DROP CONSTRAINT IF EXISTS FK_DeliveryDetails_AddressID;

ALTER TABLE DeliveryDetails
DROP CONSTRAINT IF EXISTS UQ_DeliveryDetails_AddressID;

ALTER TABLE DeliveryDetails
DROP CONSTRAINT IF EXISTS FK_DeliveryDetails_Delivery—ompanyID;

GO

ALTER TABLE Products
DROP CONSTRAINT IF EXISTS FK_Products_CategoryID;

ALTER TABLE Products
DROP CONSTRAINT IF EXISTS FK_Products_PromotionID;

GO

ALTER TABLE Managers
DROP CONSTRAINT IF EXISTS FK_Managers_PositionID;

ALTER TABLE Managers
DROP CONSTRAINT IF EXISTS FK_Managers_AddressID;

ALTER TABLE Managers
DROP CONSTRAINT IF EXISTS UQ_Managers_AddressID;

GO

ALTER TABLE Users
DROP CONSTRAINT IF EXISTS FK_Users_AddressID;

ALTER TABLE Users
DROP CONSTRAINT IF EXISTS UQ_Users_AddressID;

GO

ALTER TABLE Delivery—ompany
DROP CONSTRAINT IF EXISTS FK_Delivery—ompany_AddressID;

ALTER TABLE Delivery—ompany
DROP CONSTRAINT IF EXISTS UQ_Delivery—ompany_AddressID;

GO

ALTER TABLE [Messages]
DROP CONSTRAINT IF EXISTS FK_Messages_UserID;

ALTER TABLE [Messages]
DROP CONSTRAINT IF EXISTS FK_Messages_ManagerID;

GO

ALTER TABLE ShoppingCart
DROP CONSTRAINT IF EXISTS FK_ShoppingCart_UserID;

ALTER TABLE ShoppingCart
DROP CONSTRAINT IF EXISTS FK_ShoppingCart_ProductID;

GO

ALTER TABLE ProductReviews
DROP CONSTRAINT IF EXISTS FK_ProductReviews_UserID;

ALTER TABLE ProductReviews
DROP CONSTRAINT IF EXISTS FK_ProductReviews_ProductID;

GO

ALTER TABLE Users_NewsletterSubscriptions
DROP CONSTRAINT IF EXISTS FK_Users_NewsletterSubscriptions_UserID;

ALTER TABLE Users_NewsletterSubscriptions
DROP CONSTRAINT IF EXISTS FK_Users_NewsletterSubscriptions_ManagerID;

GO




-- CREATE CONSTRAINT

ALTER TABLE Payments
ADD CONSTRAINT FK_Payments_OrderID FOREIGN KEY(OrderID) REFERENCES Orders(OrderID);

ALTER TABLE Payments
ADD CONSTRAINT UQ_Payments_OrderID UNIQUE(OrderID);

GO

ALTER TABLE [Returns]
ADD CONSTRAINT FK_Returns_OrderID FOREIGN KEY(OrderID) REFERENCES Orders(OrderID);

ALTER TABLE [Returns]
ADD CONSTRAINT UQ_Returns_OrderID UNIQUE(OrderID);

GO

ALTER TABLE Suppliers
ADD CONSTRAINT FK_Suppliers_OfficeAddressID FOREIGN KEY(OfficeAddressID) REFERENCES Addresses(AddressID);

ALTER TABLE Suppliers
ADD CONSTRAINT UQ_Suppliers_OfficeAddressID UNIQUE(OfficeAddressID);

GO

ALTER TABLE Warehouse
ADD CONSTRAINT FK_Warehouse_SupplierID FOREIGN KEY(SupplierID) REFERENCES Suppliers(SupplierID);

ALTER TABLE Warehouse
ADD CONSTRAINT FK_Warehouse_AddressID FOREIGN KEY(AddressID) REFERENCES Addresses(AddressID);

ALTER TABLE Warehouse
ADD CONSTRAINT UQ_Warehouse_AddressID UNIQUE(AddressID);

GO

ALTER TABLE OrderDetails
ADD CONSTRAINT FK_OrderDetails_OrderID FOREIGN KEY(OrderID) REFERENCES Orders(OrderID);

ALTER TABLE OrderDetails
ADD CONSTRAINT FK_OrderDetails_ProductID FOREIGN KEY(ProductID) REFERENCES Products(ProductID);

ALTER TABLE OrderDetails
ADD CONSTRAINT FK_OrderDetails_WarehouseID FOREIGN KEY(WarehouseID) REFERENCES Warehouse(WarehouseID);

GO

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_UserID FOREIGN KEY(UserID) REFERENCES Users(UserID);

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_DeliveryDetailsID FOREIGN KEY(DeliveryDetailsID) REFERENCES DeliveryDetails(DeliveryDetailsID);

ALTER TABLE Orders
ADD CONSTRAINT UQ_Orders_DeliveryDetailsID UNIQUE(DeliveryDetailsID);

GO

ALTER TABLE DeliveryDetails
ADD CONSTRAINT FK_DeliveryDetails_AddressID FOREIGN KEY(AddressID) REFERENCES Addresses(AddressID);

ALTER TABLE DeliveryDetails
ADD CONSTRAINT UQ_DeliveryDetails_AddressID UNIQUE(AddressID);

ALTER TABLE DeliveryDetails
ADD CONSTRAINT FK_DeliveryDetails_Delivery—ompanyID FOREIGN KEY(Delivery—ompanyID) REFERENCES Delivery—ompany(Delivery—ompanyID);

GO

ALTER TABLE Products
ADD CONSTRAINT FK_Products_CategoryID FOREIGN KEY(CategoryID) REFERENCES ProductCategories(CategoryID);

ALTER TABLE Products
ADD CONSTRAINT FK_Products_PromotionID FOREIGN KEY(PromotionID) REFERENCES Promotions(PromotionID);

GO

ALTER TABLE Managers
ADD CONSTRAINT FK_Managers_PositionID FOREIGN KEY(PositionID) REFERENCES Positions(PositionID);

ALTER TABLE Managers
ADD CONSTRAINT FK_Managers_AddressID FOREIGN KEY(AddressID) REFERENCES Addresses(AddressID);

ALTER TABLE Managers
ADD CONSTRAINT UQ_Managers_AddressID UNIQUE(AddressID);

GO

ALTER TABLE Users
ADD CONSTRAINT FK_Users_AddressID FOREIGN KEY(AddressID) REFERENCES Addresses(AddressID);

ALTER TABLE Users
ADD CONSTRAINT UQ_Users_AddressID UNIQUE(AddressID);

GO

ALTER TABLE Delivery—ompany
ADD CONSTRAINT FK_Delivery—ompany_AddressID FOREIGN KEY(AddressID) REFERENCES Addresses(AddressID);

ALTER TABLE Delivery—ompany
ADD CONSTRAINT UQ_Delivery—ompany_AddressID UNIQUE(AddressID);

GO

ALTER TABLE [Messages]
ADD CONSTRAINT FK_Messages_UserID FOREIGN KEY(UserID) REFERENCES Users(UserID);

ALTER TABLE [Messages]
ADD CONSTRAINT FK_Messages_ManagerID FOREIGN KEY(ManagerID) REFERENCES Managers(ManagerID);

GO

ALTER TABLE ShoppingCart
ADD CONSTRAINT FK_ShoppingCart_UserID FOREIGN KEY(UserID) REFERENCES Users(UserID);

ALTER TABLE ShoppingCart
ADD CONSTRAINT FK_ShoppingCart_ProductID FOREIGN KEY(ProductID) REFERENCES Products(ProductID);

GO

ALTER TABLE ProductReviews
ADD CONSTRAINT FK_ProductReviews_UserID FOREIGN KEY(UserID) REFERENCES Users(UserID);

ALTER TABLE ProductReviews
ADD CONSTRAINT FK_ProductReviews_ProductID FOREIGN KEY(ProductID) REFERENCES Products(ProductID);

GO

ALTER TABLE Users_NewsletterSubscriptions
ADD CONSTRAINT FK_Users_NewsletterSubscriptions_UserID FOREIGN KEY(UserID) REFERENCES Users(UserID);

ALTER TABLE Users_NewsletterSubscriptions
ADD CONSTRAINT FK_Users_NewsletterSubscriptions_ManagerID FOREIGN KEY(SubscriptionID) REFERENCES NewsletterSubscriptions(SubscriptionID);

GO
