USE DigitalMarketplace;

DROP USER IF EXISTS Dmytro;
DROP USER IF EXISTS Alex;
DROP USER IF EXISTS John;
DROP USER IF EXISTS Thomas;

GO

DROP ROLE IF EXISTS UserRole;
DROP ROLE IF EXISTS ManagerRole;
DROP ROLE IF EXISTS GuestRole;

GO

CREATE OR ALTER PROCEDURE DropLoginIfExists
	@LoginName NVARCHAR(256)
AS
BEGIN
		IF EXISTS (
			SELECT * 
			FROM sys.server_principals 
			WHERE name = @LoginName
		  )
		BEGIN
			DECLARE @SQL NVARCHAR(512);
			SET @SQL = 'DROP LOGIN ' + QUOTENAME(@LoginName) + ';';
			EXEC sp_executesql @SQL;
		END
END;

GO

EXEC DropLoginIfExists @LoginName = 'Administrator';
EXEC DropLoginIfExists @LoginName = 'Manager';
EXEC DropLoginIfExists @LoginName = 'User';
EXEC DropLoginIfExists @LoginName = 'Guest';


-- Create «Administrator»

CREATE LOGIN Administrator WITH PASSWORD = 'Administrator';
CREATE USER Dmytro FOR LOGIN Administrator;

ALTER ROLE db_owner 
ADD MEMBER Dmytro;

GO




-- Create «Manager»

CREATE ROLE ManagerRole;

GRANT SELECT
ON DATABASE::DigitalMarketplace
TO ManagerRole;

GRANT UPDATE, DELETE, INSERT
ON Products
TO ManagerRole;


GRANT UPDATE, DELETE, INSERT
ON ProductCategories
TO ManagerRole;

GRANT UPDATE, DELETE, INSERT
ON Promotions
TO ManagerRole;

GRANT UPDATE, DELETE, INSERT
ON NewsletterSubscriptions
TO ManagerRole;

GRANT UPDATE, DELETE, INSERT
ON Users_NewsletterSubscriptions
TO ManagerRole;

GRANT UPDATE(ReturnStatus)
ON [Returns]
TO ManagerRole;

CREATE LOGIN Manager WITH PASSWORD = 'Manager';
CREATE USER Alex FOR LOGIN Manager;

ALTER ROLE ManagerRole
ADD MEMBER Alex;

GO




-- Create «User»

CREATE ROLE UserRole;

GRANT SELECT
ON DATABASE::DigitalMarketplace
TO UserRole;

GRANT UPDATE, INSERT, DELETE
ON Users_NewsletterSubscriptions
TO UserRole;

GRANT UPDATE, INSERT, DELETE
ON ShoppingCart
TO UserRole;

GRANT UPDATE, INSERT, DELETE
ON Orders
TO UserRole;

GRANT UPDATE, INSERT, DELETE
ON [Messages]
TO UserRole;

GRANT UPDATE, INSERT, DELETE
ON ProductReviews
TO UserRole;

GRANT UPDATE, INSERT, DELETE
ON Addresses
TO UserRole;

CREATE LOGIN [User] WITH PASSWORD = 'User';
CREATE USER John FOR LOGIN [User];

ALTER ROLE UserRole
ADD MEMBER John;

GO



-- Create «Guest»

CREATE ROLE GuestRole;

GRANT SELECT
ON Products
TO GuestRole;

GRANT SELECT
ON Promotions
TO GuestRole;

GRANT SELECT
ON ProductCategories
TO GuestRole;

CREATE LOGIN Guest WITH PASSWORD = 'Guest';
CREATE USER Thomas FOR LOGIN Guest;

ALTER ROLE GuestRole
ADD MEMBER Thomas;

GO