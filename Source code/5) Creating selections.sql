USE DigitalMarketplace;

/* - Запит №1
	Вивести всіх користувачів, які не зробили, жодного замовлення
*/

SELECT *
FROM Users
WHERE UserID NOT IN (
	SELECT UserID
	FROM Orders
  );

GO




/* - Запит №2
	Вивести всіх менеджерів, які проживаються в Японії
*/

SELECT 
	m.ManagerID,
	CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
	CONCAT(a.Country, ' ', a.City, ' ', COALESCE(a.Region + ' ', ''), a.Street) AS FullAdress
FROM Managers AS m
INNER JOIN Addresses AS a ON m.AddressID = a.AddressID
WHERE Country = 'Japan';

GO




/* - Запит №3
	Вивести всіх менеджерів, які праціюють на даний момент і заробляють більше 2000 та порядкувати їх за зростанням зарплатні.
*/

SELECT 
	CONCAT_WS(' ', m.FirstName, m.LastName) AS FullName,
	[Status],
	Salary
FROM Managers AS m
INNER JOIN Positions AS p ON p.PositionID = m.PositionID
WHERE 
	Salary > 2000 AND
	[Status] = 'Active'
ORDER BY Salary

GO




/* - Запит №4
	Вивести всіх користувачів, які добавили більше 4 товарів у купівельну корзину. Відсортувати результат за зростанням кількості товарів у корхині.	
*/


WITH Filtred AS
(
	SELECT 
		u.UserID,
		COUNT(u.UserID) AS Quantity
	FROM Users AS u
	INNER JOIN ShoppingCart AS s ON s.UserID = u.UserID
	GROUP BY u.UserID
	HAVING COUNT(u.UserID) > 4
)
SELECT 
	f.UserID,
	CONCAT_WS(' ', u.FirstName, u.LastName) AS FullName,
	f.Quantity
FROM Filtred AS f
INNER JOIN Users AS u ON u.UserID = f.UserID
ORDER BY Quantity

GO
	



/* - Запит №5
	Вивести користувачів, чиї замовлення доставляють компанії, у яких середній час доставки менший ніж 02:30:00. Впорядкувати результуючу вибірку за спаданням середнього часу доставки.
*/

SELECT 
	u.UserID,
	CONCAT_WS(' ', u.FirstName, u.LastName) AS UserFullName,
	c.[Name] AS CompanyName,
	c.AvarageDelivaryTime
FROM Users AS u
INNER JOIN Orders AS o ON o.UserID = u.UserID
INNER JOIN DeliveryDetails AS d ON d.DeliveryDetailsID = o.DeliveryDetailsID
INNER JOIN DeliveryСompany AS c ON c.DeliveryСompanyID = d.DeliveryСompanyID
WHERE AvarageDelivaryTime < '02:30:00'
ORDER BY AvarageDelivaryTime DESC;

GO




/* - Запит №6
	Вивести компанії, імена директорів яких починається на літеру «D», які мають склади в Іспанії, загальна місткість яких більша півмільйона. Уникати дублікатів SupplierID.
*/

WITH Filtered AS 
(
	SELECT 
		s.SupplierID,
		s.CompanyName,
		CONCAT_WS(' ', s.HeadFirstName, s.HeadLastName) AS HeadFullName,
		a.Country,
		w.TotalCapacity,
		w.UsedCapacity,
		ROW_NUMBER() OVER (
			PARTITION BY s.SupplierID
			ORDER BY s.SupplierID
		  ) AS ValueOrder
	FROM Suppliers AS s
	INNER JOIN Warehouse AS w ON w.SupplierID = s.SupplierID
	INNER JOIN Addresses AS a ON a.AddressID = w.AddressID
	WHERE 
		Country = 'Spain' AND
		TotalCapacity > 500000 AND
		s.HeadFirstName LIKE 'D%'
)
SELECT 
	SupplierID,
	CompanyName,
	HeadFullName,
	Country,
	TotalCapacity,
	UsedCapacity
FROM Filtered
WHERE ValueOrder = 1;

GO




/* - Запит №7
	Вивести користувачів із Китаю, які мають підписки, що є активними на даний момент.
*/

SELECT 
	u.UserID,
	CONCAT_WS(' ', u.FirstName, u.LastName) AS FullName,
	n.SubscriptionStatus,
	a.Country
FROM Users AS u
INNER JOIN Users_NewsletterSubscriptions AS uw ON uw.UserID = u.UserID
INNER JOIN NewsletterSubscriptions AS n ON n.SubscriptionID = uw.SubscriptionID
INNER JOIN Addresses AS a ON a.AddressID = u.AddressID
WHERE 
	n.SubscriptionStatus = 'Active' AND
	a.Country = 'China';

GO




/* - Запит №8
	Вивести користувачів, які написали найбільшу кількість коментарів. Додати кількість коментарів до результуючої вибірки та впорядкувати вибірку за зростанням ідентифікатора користувача.
*/

WITH Filtered AS 
(
	SELECT 
		u.UserID,
		COUNT(u.UserID) AS CommentsQuantity,
		RANK() OVER(
			ORDER BY COUNT(u.UserID) DESC
		  ) AS Position
	FROM Users AS u
	INNER JOIN ProductReviews AS p ON p.UserID = u.UserID
	GROUP BY u.UserID
)
SELECT 
	f.UserID,
	CONCAT_WS(' ', u.FirstName, u.LastName) AS FullName,
	f.CommentsQuantity
FROM Filtered AS f
INNER JOIN Users AS u ON u.UserID = f.UserID 
WHERE Position = 1
ORDER BY UserID;

GO




/* - Запит №9
	Вивести користувачів, у яких постачальники товарів замовлення мають номер, що починається з трьої нулів, а кількість товарів одного виду, що замовив користувач перевищує 30 екземплярів. Уникати дублікатів.
*/

WITH Filtered AS
(
	SELECT 
		u.UserID,
		CONCAT_WS(' ', u.FirstName, u.LastName) AS UserFullName,
		s.Phone AS SupplierPhone,
		od.Quantity,
		ROW_NUMBER() OVER(
			PARTITION BY u.UserID
			ORDER BY u.UserID
		  ) AS DuplicateQuantity
	FROM Users AS u
	INNER JOIN Orders AS o ON o.UserID = u.UserID
	INNER JOIN OrderDetails AS od ON od.OrderID = o.OrderID
	INNER JOIN Warehouse AS w ON w.WarehouseID = od.WarehouseID
	INNER JOIN Suppliers AS s ON s.SupplierID = w.SupplierID
	WHERE 
		s.Phone LIKE '000%' AND
		od.Quantity > 30
)
SELECT 
	UserID,
	UserFullName,
	Quantity,
	SupplierPhone
FROM Filtered
WHERE DuplicateQuantity = 1;

GO




/* - Запит №10
	Вивести продукти, які жодного разу не були додані в замовлення
*/

SELECT *
FROM Products AS p
WHERE NOT EXISTS (
	SELECT ProductID
	FROM OrderDetails AS od
	WHERE p.ProductID = od.ProductID
  );




/* - Запит №11
	Вивести користувача у якого в купівельній корзині знаходиться більше одного продукту із акційною пропозицією скидка якої більше 20%
*/

GO

WITH Filtered AS (
	SELECT 
		u.UserID,
		COUNT(u.UserID) AS ProductsQuantity
	FROM Users AS u
	INNER JOIN ShoppingCart AS s ON s.UserID = u.UserID
	INNER JOIN Products AS p ON p.ProductID = s.ProductID
	INNER JOIN Promotions AS pr ON pr.PromotionID = p.PromotionID
	WHERE Discount > 0.2
	GROUP BY u.UserID
	HAVING COUNT(u.UserID) > 1
  )
SELECT 
	f.UserID,
	CONCAT(u.FirstName, ' ', u.LastName) AS FullName,
	f.ProductsQuantity
FROM Filtered AS f
INNER JOIN Users AS u ON u.UserID = f.UserID

GO




/* - Запит №12
	Вивести замовлення, які містять більше 5 різних продуктів
*/

WITH Filtered AS (
	SELECT 
		od.OrderID,
		COUNT(od.OrderID) AS ProductsQuantity
	FROM OrderDetails AS od
	GROUP BY od.OrderID
	HAVING COUNT(od.OrderID) > 5
)
SELECT 
	f.OrderId,
	o.OrderDate,
	f.ProductsQuantity
FROM Filtered AS f
INNER JOIN Orders AS o ON o.OrderID = f.OrderID




/* - Запит №13
	Вивести продукти, які ніколи не отримували позитивних відгуків але їх середня оцінка перевищує 1.5
*/

GO

WITH Filtered AS (
	SELECT 
		f.ProductID,
		AVG(pr.Rating) AS AvgRating
	FROM ProductReviews AS pr
	INNER JOIN (
		SELECT ProductID
		FROM Products
		WHERE ProductID NOT IN (
			SELECT ProductID
			FROM ProductReviews
			WHERE Rating > 3
		  )
	  ) AS f ON f.ProductID = pr.ProductID
	GROUP BY f.ProductID
	HAVING AVG(pr.Rating) > 1.5
)
SELECT 
	f.ProductID,
	p.[Name] AS ProductName,
	p.UnitPrice,
	p.[Description],
	f.AvgRating
FROM Filtered AS f
INNER JOIN Products AS p ON p.ProductID = f.ProductID

GO




/* - Запит №14
	Вибрати користувачів, які здійснили покупок на загальну суму більше 1000 у валюті
*/


SELECT 
	m.UserID,
	CONCAT(u.FirstName, ' ', u.LastName) AS UserFullName,
	u.Phone,
	u.Email,
	m.TotalAmount
FROM Users AS u
INNER JOIN (
	SELECT 
		u.UserID,
		SUM(p.Amount) AS TotalAmount
	FROM Users AS u
	INNER JOIN Orders AS o ON o.UserID = u.UserID
	INNER JOIN Payments AS p ON p.OrderID = o.OrderID
	WHERE p.Amount > 1000
	GROUP BY u.UserID
) AS m ON m.UserID = u.UserID;

GO




/* - Запит №15
	Вивести сумарний об'єм продажів по категоріям продуктів
*/

WITH Filtered AS (
	SELECT 
		pc.CategoryID,
		SUM(od.Price) AS TotalSales
	FROM OrderDetails AS od
	INNER JOIN Products AS p ON p.ProductID = od.ProductID
	INNER JOIN ProductCategories AS pc ON pc.CategoryID = p.CategoryID
	GROUP BY pc.CategoryID
)
SELECT 
	f.CategoryId,
	pc.[Name] AS CategoryName,
	pc.[Description] AS CategoryDescription,
	f.TotalSales
FROM Filtered AS f
INNER JOIN ProductCategories AS pc ON pc.CategoryID = f.CategoryID;

GO




/* - Запит №16
	Вивести користувачів, які успішно повернули або обміняли хоча б одне замовлення
*/

WITH Filtered AS (
	SELECT 
		u.UserID,
		CONCAT(u.FirstName, ' ', u.LastName) AS UserFullName,
		o.OrderID,
		r.ReturnID,
		r.ReturnStatus,
		ROW_NUMBER() OVER(
			PARTITION BY u.UserID
			ORDER BY u.UserID
		  )	AS DuplicateQuantity
	FROM Users AS u
	INNER JOIN Orders AS o ON o.UserID = u.UserID
	INNER JOIN [Returns] AS r ON r.OrderID = o.OrderID
	WHERE 
		r.ReturnStatus IN ('Refunded', 'Exchanged')
)
SELECT 
	UserID,
	UserFullName,
	ReturnID, 
	ReturnStatus
FROM Filtered
WHERE DuplicateQuantity = 1

GO




/* - Запит №17
	Вибрати топ 5 найбільш популярних продуктів за кількістю замовлень
*/

SELECT 
	p.ProductID,
	p.[Name] AS ProductName,
	p.UnitPrice,
	f.OrderCount
FROM Products AS p
INNER JOIN (
	SELECT TOP(5)
		ProductID,
		COUNT(ProductID) AS OrderCount
	FROM OrderDetails
	GROUP BY ProductID
	ORDER BY OrderCount DESC
  ) AS f ON f.ProductID = p.ProductID

GO




/* - Запит №18
	Отримати імена користувачів, які підписані на новини, але не здійснили жодного замовлення. Додати у вибірку також інформацію про стан підписки для кожного користувача.
*/

SELECT 
	u.UserID,
	CONCAT(u.FirstName, ' ', u.LastName) AS UserFullName,
	u.Phone,
	n.SubscriptionStatus
FROM Users AS u
INNER JOIN Users_NewsletterSubscriptions AS un ON un.UserID = u.UserID
INNER JOIN NewsletterSubscriptions AS n ON n.SubscriptionID = un.SubscriptionID
WHERE u.UserID NOT IN (
	SELECT UserID
	FROM Orders
  );

GO




/* - Запит №19
	Вибрати всіх постачальників, які не мають жодного замовлення в поточному місяці:
*/

SELECT 
	SupplierID,
	CompanyName,
	Phone,
	Email
FROM Suppliers
WHERE SupplierID NOT IN (
	SELECT s.SupplierID
	FROM Suppliers AS s
	INNER JOIN Warehouse AS w ON w.SupplierID = s.SupplierID
	INNER JOIN OrderDetails AS od ON od.WarehouseID = w.WarehouseID
	INNER JOIN Orders AS o ON o.OrderID = od.OrderID
	WHERE 
		YEAR(o.OrderDate) = YEAR('2023-12-05') AND	-- Можна використати CURRENT_TIMESTAMP або GET_DATE()
		MONTH(o.OrderDate) = MONTH('2023-12-05')	-- Можна використати CURRENT_TIMESTAMP або GET_DATE()
)

GO




/* - Запит №20
	Вибрати замовлення, загальна вартість яких перевищує середню вартість замовлення:
*/

WITH TotalAmountOrderTable AS (
	SELECT 
		o.OrderID,
		SUM(od.Price) AS TotalAmount
	FROM Orders AS o
	INNER JOIN OrderDetails AS od ON od.OrderID = o.OrderID
	GROUP BY o.OrderID
), AvgAmountTable AS (
	SELECT AVG(TotalAmount) AS AvgAmount
	FROM TotalAmountOrderTable
)
SELECT 
	t.OrderID,
	t.TotalAmount,
	a.AvgAmount,
	o.OrderDate,
	o.UserID
FROM TotalAmountOrderTable AS t, AvgAmountTable AS a, Orders AS o
WHERE 
	t.OrderID = o.OrderID AND
	TotalAmount > AvgAmount;

GO