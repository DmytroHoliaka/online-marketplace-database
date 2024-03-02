USE DigitalMarketplace;

/* Тригер №1
	Перевірка наявності і автоматичне оновлення запасів при додаванні нових замовлень
*/

GO

CREATE OR ALTER TRIGGER CheckAndReduceStockOnNewOrder
ON OrderDetails
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @OrderID INT;
	DECLARE @ProductID INT;
	DECLARE @Quantity INT;
	DECLARE @Price MONEY;
	DECLARE @WarehouseID INT;
	DECLARE @StockAvailability INT;

	DECLARE Iter CURSOR LOCAL FORWARD_ONLY FOR
	SELECT *
	FROM inserted;

	OPEN Iter;

	FETCH NEXT
	FROM Iter
	INTO @OrderID, @ProductID, @Quantity, @Price, @WarehouseID;

	WHILE @@FETCH_STATUS = 0
		BEGIN 
			IF (@Quantity <= 0)
				BEGIN
					ROLLBACK TRANSACTION; 
					RAISERROR('Incorrect quantity for ID: %d', 16, 1, @ProductID);
					CLOSE Iter;
					DEALLOCATE Iter;
					
					RETURN;
				END;

			SELECT @StockAvailability = StockAvailability 
			FROM Products
			WHERE ProductID = @ProductID

			IF (@StockAvailability < @Quantity)
				BEGIN
					ROLLBACK TRANSACTION; 
					RAISERROR('There is not enough goods in stock for ID: %d', 16, 1, @ProductID);
					CLOSE Iter;
					DEALLOCATE Iter;
					
					RETURN;
				END;

			UPDATE Products
			SET StockAvailability -= @Quantity
			WHERE ProductID = @ProductID;

			FETCH NEXT
			FROM Iter
			INTO @OrderID, @ProductID, @Quantity, @Price, @WarehouseID;
		END;


	CLOSE Iter;
	DEALLOCATE Iter;
END;

GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price, WarehouseID)
VALUES
(36, 13, 50, 768.83, 50),
(69, 38, 20, 145.76, 12),
(14, 68, 10, 456.23, 65),
(58, 87, 40, 146.23, 13);

SELECT 
	*
FROM 
	Products
WHERE 
	ProductID IN (13, 38, 68, 87);





/* Тригер №2
	Тригер, який при видаленні користувача, видалятиме всі пов'язані із ним дані.
*/

GO

CREATE OR ALTER TRIGGER RemoveUserAddressOnDelete
ON Users
INSTEAD OF DELETE
AS
BEGIN
	DELETE FROM [Returns]
	WHERE OrderID IN (
		SELECT OrderID
		FROM Orders
		WHERE UserID IN (
			SELECT UserID
			FROM deleted
		  )
	  );

	DELETE FROM OrderDetails
	WHERE OrderID IN (
		SELECT OrderID
		FROM Orders
		WHERE UserID IN (
			SELECT UserID
			FROM deleted
		  )
	  );

	DELETE FROM Payments
	WHERE OrderID IN (
		SELECT OrderID
		FROM Orders
		WHERE UserID IN (
			SELECT UserID
			FROM deleted
		  )
	  );

	DELETE FROM Orders
	WHERE UserID IN (
		SELECT UserID
		FROM deleted
	  );

	DELETE FROM DeliveryDetails
	WHERE DeliveryDetailsID IN (
		SELECT DeliveryDetailsID 
		FROM Orders
		WHERE UserId IN (
			SELECT UserID
			FROM deleted
		  )
	  );

	DELETE FROM [Messages]
	WHERE UserID IN (
		SELECT UserID
		FROM deleted
	  );

	DELETE FROM ShoppingCart
	WHERE UserID IN (
		SELECT UserID
		FROM deleted
	  );

	DELETE FROM ProductReviews
	WHERE UserID IN (
		SELECT UserID
		FROM deleted
	  );

	DELETE FROM Users_NewsletterSubscriptions
	WHERE UserID IN (
		SELECT UserID
		FROM deleted
	  );

	DELETE FROM Users
	WHERE UserID IN (
		SELECT UserID
		FROM deleted
	  );

	DELETE FROM Addresses
	WHERE AddressID IN (
		SELECT AddressID
		FROM deleted
	  );
END;

SELECT 
	*
FROM 
	Users
WHERE 
	UserId = 1;

SELECT 
	*
FROM 
	Orders
WHERE 
	UserID = 1;

SELECT 
	*
FROM 
	Addresses
WHERE 
	AddressID = 65;


DELETE FROM 
	Users
WHERE 
	UserID = 1;

GO

/* Тригер №3
	Створити тригер, який при додаванні запису в [Returns] буде змінювати Status в Orders на 'Processing' 
*/

GO

CREATE OR ALTER TRIGGER UpdateOrderStatusOnReturn
ON [Returns]
AFTER INSERT
AS
BEGIN
	UPDATE Orders
	SET [Status] = 'Processing'
	WHERE OrderID IN (
		SELECT OrderID
		FROM inserted
	  );
END;

GO

SELECT 
	*
FROM 
	Orders
WHERE
	OrderID = 6;

INSERT INTO [Returns] (ReturnReason, ReturnStatus, OrderID)
VALUES
('Item damaged during shipping', 'Under Review', 6);


/* Тригер №4
	Створити тригер, який дозволить додавати відкуги лише тим користувачам, які купили вказаний продукт
*/

GO

CREATE OR ALTER TRIGGER EnsureProductPurchasedBeforeReview
ON ProductReviews
AFTER INSERT
AS 
BEGIN
	DECLARE @UserID INT;

	IF EXISTS(
		SELECT 
			1
		FROM 
			inserted AS i
		WHERE
			NOT EXISTS(
				SELECT
					1
				FROM 
					Orders AS o
					INNER JOIN OrderDetails AS od ON od.OrderID = o.OrderID
					INNER JOIN Payments AS p ON p.OrderID = o.OrderID
					INNER JOIN Users AS u ON u.UserID = o.UserID
				WHERE 
					od.ProductID = i.ProductID AND
					u.UserID = i.UserID
		  )
	  )
	  BEGIN
		ROLLBACK TRANSACTION; 
		RAISERROR('The user did not buy the product, it is impossible to leave a review', 16, 1);
	  END;
END;

GO

SELECT DISTINCT
	u.UserID,
	od.ProductID
FROM
	ProductReviews AS pr
	INNER JOIN Users AS u ON u.UserID = pr.UserID
	INNER JOIN Orders AS o ON o.UserID = u.UserID
	INNER JOIN OrderDetails AS od ON od.OrderID = o.OrderID
	INNER JOIN Payments AS p ON p.OrderID = o.OrderID
WHERE 
	u.UserID = 7
ORDER BY 
	UserID


INSERT INTO 
	ProductReviews (UserID, ProductID, Rating, Comment)
VALUES
	(7, 29, 9.2, 'Average experience'),
	(7, 152, 7.6, 'Good quality'),
	(7, 134, 8.5, 'Outstanding quality');

	
/* Тригер №5
	Тригер, який перевірятиме, чи значення при оплаті співпадає із фактичною вартістю замовлення
*/

GO

CREATE OR ALTER TRIGGER CheckPaymentAmount
ON Payments
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS TempErrorTable;

	SELECT 
		od.OrderID,
		i.Amount,
		SUM(od.Price) AS TotalOrderAmount
	INTO 
		TempErrorTable
	FROM
		inserted AS i
	INNER JOIN 
		OrderDetails AS od ON od.OrderID = i.OrderID
	GROUP BY
		od.OrderID,
		i.Amount
	HAVING 
		i.Amount <> SUM(od.Price) 
		
	IF EXISTS (
		SELECT 1
		FROM TempErrorTable
	  )
	BEGIN
		ROLLBACK TRANSACTION; 
		RAISERROR('Payment value does not match the order value', 16, 1);
	END;
END;

GO

SELECT 
	OrderID,
	SUM(Price) AS TotalPrice
FROM 
	OrderDetails
WHERE 
	OrderID IN (2, 9)
GROUP BY 
	OrderID


INSERT INTO		 
	Payments
VALUES
	(329.89, '01-01-2023', 'Credit cart', 2),	-- Correct: 329.89
	(269.82, '01-01-2023', 'Credit cart', 9);	-- Correct: 269.82


DELETE FROM	
	Payments
WHERE 
	OrderID = 2 OR
	OrderID = 9
