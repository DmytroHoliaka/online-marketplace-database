USE DigitalMarketplace;


/* - Процедура №1
	Процедура для генерації щомісячного звіту про продажі. Вона обчислює загальний обсяг продажів, кількість замовлень та середню суму замовлення за місяць.
*/

GO 

CREATE OR ALTER PROCEDURE GenerateMonthlySalesReport
	@Year INT = 2023,
	@Month INT = 12
AS
BEGIN
	DECLARE @NumberOfOrders INT;
	DECLARE @TotalSales FLOAT;
	DECLARE @AvgOrderValue FLOAT;

	SELECT 
		@NumberOfOrders = COUNT(DISTINCT o.OrderID),
		@TotalSales = SUM(od.Price)
	FROM 
		OrderDetails AS od
	INNER JOIN 
		Orders AS o ON o.OrderID = od.OrderID
	WHERE 
		YEAR(o.OrderDate) = @Year AND
		MONTH(o.OrderDate) = @Month;


	WITH OrderPriceTable AS
	(
		SELECT
			od.OrderID,
			SUM(od.Price) AS OrderPrice
		FROM 
			Orders AS o
		INNER JOIN
			OrderDetails AS od ON od.OrderID = o.OrderID
		GROUP BY
			od.OrderID, o.OrderDate
		HAVING
			YEAR(o.OrderDate) = @Year AND
			MONTH(o.OrderDate) = @Month
	)
	SELECT 
		@AvgOrderValue = AVG(OrderPrice)
	FROM 
		OrderPriceTable
	

	SELECT 
		@NumberOfOrders AS NumberOfOrders,
		@TotalSales AS TotalSales,
		@AvgOrderValue AS AvarageOrderValue;
END;

GO


EXEC GenerateMonthlySalesReport
	@Year = 2023,
	@Month = 11;




/* - Процедура №2
	-- Отримати категорії товарів, які доставлялися конкретною компанією
*/

GO

CREATE OR ALTER PROCEDURE GetCategories
	@DeliveryCompanyID INT
AS
BEGIN
	WITH CompanyCategoryMap AS
	(
		SELECT 
			d.DeliveryСompanyID,
			pc.CategoryID,
			ROW_NUMBER() OVER (
			    PARTITION BY pc.CategoryID
				ORDER BY pc.CategoryID
			  )AS DuplicateCount
		FROM 
			DeliveryСompany AS c
			INNER JOIN DeliveryDetails AS d ON d.DeliveryСompanyID = c.DeliveryСompanyID
			INNER JOIN Orders AS o ON o.DeliveryDetailsID = d.DeliveryDetailsID
			INNER JOIN OrderDetails AS od ON od.OrderID = o.OrderID
			INNER JOIN Products AS p ON p.ProductID = od.OrderID
			INNER JOIN ProductCategories AS pc ON pc.CategoryID = p.CategoryID
		WHERE 
			c.DeliveryСompanyID = @DeliveryCompanyID
	)
	SELECT 
		c.DeliveryСompanyID,
		c.[Name] AS CompanyName,
		c.Rating,
		c.Phone,
		p.CategoryID,
		p.[Name] AS CategoryName
	FROM 
		CompanyCategoryMap AS m
		INNER JOIN DeliveryСompany AS c ON c.DeliveryСompanyID = m.DeliveryСompanyID
		INNER JOIN ProductCategories AS p ON p.CategoryID = m.CategoryID
	WHERE 
		DuplicateCount = 1
END

GO


DECLARE @CategoriesTable TABLE (
	DeliveryСompanyID INT,
	CompanyName VARCHAR(256),
	Rating REAL,
	Phone VARCHAR(64),
	CategoryID INT,
	CategoryName VARCHAR(128)
);

INSERT INTO @CategoriesTable
EXECUTE GetCategories @DeliveryCompanyID = 4;

SELECT *
FROM @CategoriesTable;




/* - Процедура №3
	-- Отримати кількість товарів у вказаній категорії
*/

GO

CREATE OR ALTER PROCEDURE GetProductCount
	@CategoryID INT,
	@ProductCount INT OUTPUT
AS
BEGIN
	SELECT @ProductCount = COUNT(CategoryID)
	FROM Products
	WHERE CategoryID = @CategoryID
END;

GO


DECLARE @CategoryID INT = 1;
DECLARE @ProductCount INT;

EXECUTE GetProductCount
	@CategoryID = @CategoryID,
	@ProductCount = @ProductCount OUTPUT;

SELECT 
	CategoryID,
	[Name] AS CategoryName,
	@ProductCount AS ProductCount
FROM ProductCategories
WHERE CategoryID = @CategoryID




/* - Процедура №4
	Написати процедуру, яка змінюватиме скидку вказаної акції на вказану величину. Додати валідацію даних.
*/

GO

CREATE OR ALTER PROCEDURE ChangePromotionDiscount
	@PromotionID INT,
	@Ratio REAL
AS
BEGIN
	IF NOT EXISTS(
		SELECT 1
		FROM Promotions
		WHERE PromotionID = @PromotionID
	  )
		BEGIN
			PRINT('The promotion with this ID does not exist');
			RETURN;
		END;

	DECLARE @PreviousDiscount REAL;
	DECLARE @NewDiscount REAL;

	SELECT 
		@PreviousDiscount = Discount
	FROM Promotions
	WHERE PromotionID = @PromotionID;

	IF ((@PreviousDiscount + @Ratio) > 1 OR 
		(@PreviousDiscount + @Ratio) <= 0)
		BEGIN
			PRINT('Incorrect ratio');
			RETURN;
		END;

	SET @NewDiscount = @PreviousDiscount + @Ratio;

	UPDATE Promotions
	SET Discount = @NewDiscount
	WHERE PromotionID = @PromotionID
END;

GO


EXECUTE ChangePromotionDiscount
	@PromotionID = 4,
	@Ratio = 0.1

SELECT *
FROM Promotions




/* - Процедура №5
	-- Вивести всіх користувачів, які купили конкретний товар
*/

GO

CREATE OR ALTER PROCEDURE GetUsersBuyedProduct
	@ProductID INT
AS 
BEGIN
	SELECT 
		u.UserID,
		u.FirstName,
		u.LastName,
		p.ProductID,
		p.[Name] AS ProductName
	FROM Users AS u
	INNER JOIN Orders AS o ON o.UserID = u.UserID
	INNER JOIN OrderDetails AS od ON od.OrderID = o.OrderID
	INNER JOIN Products AS p ON p.ProductID = od.ProductID
	WHERE p.ProductID = @ProductID
END;

GO


DECLARE @ProductID INT = 86;

EXECUTE GetUsersBuyedProduct
	@ProductID = @ProductID;







	
/* - Функція №1
	Функція для перевірки, чи кількість запасу продукту достатня для виконання замовлення. Використовується для автоматизації перевірки наявності перед додаванням замовлення.
*/


GO

CREATE OR ALTER FUNCTION CheckProductStock(
	@ProductID INT,
	@DesiredQuantity INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @Stock INT;
	DECLARE @Result BIT = 0;

	SELECT @Stock = StockAvailability
	FROM Products
	WHERE ProductID = @ProductID;

	IF @Stock IS NOT NULL AND @DesiredQuantity >= 0 AND @Stock >= @DesiredQuantity
	BEGIN
		SET @Result = 1;
	END

	RETURN @Result;
END;

GO


DECLARE @Flag BIT;

SET @Flag = dbo.CheckProductStock(1, 100);

IF @Flag = 1
	PRINT('Purchase is allowed');
ELSE
	PRINT('Purchase is not possible');




/* - Функція №2
	-- Повернути таблицю із повідомленнями конкретного користувача
*/

GO

CREATE OR ALTER FUNCTION GetMessageTable(
	@UserID INT
)
RETURNS TABLE
AS
RETURN
	SELECT *
	FROM [Messages]
	WHERE UserID = @UserID;

GO


SELECT *
FROM GetMessageTable(57);




/* - Функція №3
	-- Повернути таблицю компаній, які доставляли товар для конкретного користувача
*/

GO

CREATE OR ALTER FUNCTION GetCompanyTable(
	@UserID INT
)
RETURNS @CompanyTable TABLE(
	UserID INT,
	FullName VARCHAR(128),
	CompanyName VARCHAR(256),
	Rating REAL,
	Phone VARCHAR(64)
)
AS
BEGIN
	INSERT INTO @CompanyTable
	SELECT 
		u.UserID,
		CONCAT(u.FirstName, ' ', u.LastName) AS FullName, 
		c.[Name] AS CompanyName,
		c.Rating,
		c.Phone
	FROM DeliveryСompany AS c
	INNER JOIN DeliveryDetails AS d ON d.DeliveryСompanyID = c.DeliveryСompanyID
	INNER JOIN Orders AS o ON o.DeliveryDetailsID = d.DeliveryDetailsID
	INNER JOIN Users AS u ON u.UserID = o.UserID
	WHERE u.UserID = @UserID;

	RETURN;
END;

GO


SELECT *
FROM GetCompanyTable(10);




/* - Функція №4
	-- Порахувати загальну суму на яку купив товарів користувач
*/

GO

CREATE OR ALTER FUNCTION GetTotalAmount(
	@UserID INT
)
RETURNS MONEY
AS
BEGIN
	DECLARE @TotalPrice MONEY;

	SELECT 
		@TotalPrice = SUM(Price)
	FROM Users AS u
	INNER JOIN Orders AS o ON o.UserID = u.UserID
	INNER JOIN OrderDetails AS od ON od.OrderID = o.OrderID
	WHERE u.UserID = @UserId
	GROUP BY u.UserID

	RETURN COALESCE(@TotalPrice, 0);
END;

GO


DECLARE @UserID INT = 5;

SELECT 
	UserID,
	FirstName,
	LastName,
	dbo.GetTotalAmount(@UserID) AS TotalPrice
FROM Users
WHERE UserID = @UserID;




/* - Функція №5
	-- Отримати середній рейтинг відгуків на конкретний товар
*/

GO

CREATE OR ALTER FUNCTION GetAvarageRating(
	@ProductID INT
)
RETURNS REAL
AS
BEGIN
	DECLARE @AvgRating REAL;

	SELECT
		@AvgRating = AVG(Rating)
	FROM ProductReviews
	WHERE ProductID = @ProductID
	GROUP BY ProductID

	RETURN COALESCE(@AvgRating, 0);
END;

GO


DECLARE @ProductID INT = 6;

SELECT 
	ProductID,
	[Name] AS ProductName,
	dbo.GetAvarageRating(@ProductID) AS AvgRating
FROM Products
WHERE ProductID = @ProductID;