USE DigitalMarketplace;

/* - ����� �1
	������� ��� ������������, �� �� �������, ������� ����������
*/

SELECT *
FROM Users
WHERE UserID NOT IN (
	SELECT UserID
	FROM Orders
  );

GO




/* - ����� �2
	������� ��� ���������, �� ������������ � ����
*/

SELECT 
	m.ManagerID,
	CONCAT(m.FirstName, ' ', m.LastName) AS FullName,
	CONCAT(a.Country, ' ', a.City, ' ', COALESCE(a.Region + ' ', ''), a.Street) AS FullAdress
FROM Managers AS m
INNER JOIN Addresses AS a ON m.AddressID = a.AddressID
WHERE Country = 'Japan';

GO




/* - ����� �3
	������� ��� ���������, �� ��������� �� ����� ������ � ���������� ����� 2000 �� ����������� �� �� ���������� ��������.
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




/* - ����� �4
	������� ��� ������������, �� �������� ����� 4 ������ � ��������� �������. ³���������� ��������� �� ���������� ������� ������ � ������.	
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
	



/* - ����� �5
	������� ������������, �� ���������� ����������� ������, � ���� ������� ��� �������� ������ �� 02:30:00. ������������ ����������� ������ �� ��������� ���������� ���� ��������.
*/

SELECT 
	u.UserID,
	CONCAT_WS(' ', u.FirstName, u.LastName) AS UserFullName,
	c.[Name] AS CompanyName,
	c.AvarageDelivaryTime
FROM Users AS u
INNER JOIN Orders AS o ON o.UserID = u.UserID
INNER JOIN DeliveryDetails AS d ON d.DeliveryDetailsID = o.DeliveryDetailsID
INNER JOIN Delivery�ompany AS c ON c.Delivery�ompanyID = d.Delivery�ompanyID
WHERE AvarageDelivaryTime < '02:30:00'
ORDER BY AvarageDelivaryTime DESC;

GO




/* - ����� �6
	������� ������, ����� ��������� ���� ���������� �� ����� �D�, �� ����� ������ � �����, �������� ������� ���� ����� ���������. ������� �������� SupplierID.
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




/* - ����� �7
	������� ������������ �� �����, �� ����� �������, �� � ��������� �� ����� ������.
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




/* - ����� �8
	������� ������������, �� �������� �������� ������� ���������. ������ ������� ��������� �� ����������� ������ �� ������������ ������ �� ���������� �������������� �����������.
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




/* - ����� �9
	������� ������������, � ���� ������������� ������ ���������� ����� �����, �� ���������� � ���� ����, � ������� ������ ������ ����, �� ������� ���������� �������� 30 ����������. ������� ��������.
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




/* - ����� �10
	������� ��������, �� ������� ���� �� ���� ����� � ����������
*/

SELECT *
FROM Products AS p
WHERE NOT EXISTS (
	SELECT ProductID
	FROM OrderDetails AS od
	WHERE p.ProductID = od.ProductID
  );




/* - ����� �11
	������� ����������� � ����� � ��������� ������ ����������� ����� ������ �������� �� �������� ����������� ������ ��� ����� 20%
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




/* - ����� �12
	������� ����������, �� ������ ����� 5 ����� ��������
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




/* - ����� �13
	������� ��������, �� ����� �� ���������� ���������� ������ ��� �� ������� ������ �������� 1.5
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




/* - ����� �14
	������� ������������, �� �������� ������� �� �������� ���� ����� 1000 � �����
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




/* - ����� �15
	������� �������� ��'�� ������� �� ��������� ��������
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




/* - ����� �16
	������� ������������, �� ������ ��������� ��� ������� ���� � ���� ����������
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




/* - ����� �17
	������� ��� 5 ������� ���������� �������� �� ������� ���������
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




/* - ����� �18
	�������� ����� ������������, �� ������� �� ������, ��� �� �������� ������� ����������. ������ � ������ ����� ���������� ��� ���� ������� ��� ������� �����������.
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




/* - ����� �19
	������� ��� �������������, �� �� ����� ������� ���������� � ��������� �����:
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
		YEAR(o.OrderDate) = YEAR('2023-12-05') AND	-- ����� ����������� CURRENT_TIMESTAMP ��� GET_DATE()
		MONTH(o.OrderDate) = MONTH('2023-12-05')	-- ����� ����������� CURRENT_TIMESTAMP ��� GET_DATE()
)

GO




/* - ����� �20
	������� ����������, �������� ������� ���� �������� ������� ������� ����������:
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