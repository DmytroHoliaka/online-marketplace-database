USE DigitalMarketplace;

/* ������������� �1:
	�������� �������������, ��� ���� ������ ������� ���������� ��� �����������, ���� ��: ������������� �����������, ���� ����� ��'�, �������� ���� �����, ��� �� ��������, ����� ��������� �������� �� ����� ������ ����������
*/ 

GO

CREATE OR ALTER VIEW UserInfo (UserID, FullName, OrderPrice, Phone, FullAddress) AS
	WITH UserOrderPrice AS
	(
		SELECT 
			u.UserID,
			COALESCE(SUM(Price), 0) AS OrderPrice
		FROM Users AS u
		LEFT JOIN Orders AS o ON o.UserID = u.UserID
		LEFT JOIN OrderDetails AS od ON od.OrderID = o.OrderID
		GROUP BY u.UserID
	)
	SELECT 
		p.UserID,
		CONCAT(u.FirstName, ' ', u.LastName) AS FullName,
		p.OrderPrice,
		u.Phone,
		CONCAT(a.Country, ', ', a.City, ', ', COALESCE(a.Region + ', ', ''), a.Street, ', ', a.BuildingNumber, ', [', a.PostalCode, ']') AS FullAddress
	FROM UserOrderPrice AS p
	INNER JOIN Users AS u ON u.UserID = p.UserID
	INNER JOIN Addresses AS a ON a.AddressID = u.AddressID;

GO

SELECT *
FROM UserInfo;




/* ������������� �2:
	�������� �������������, ��� ���� ������ ���������� ��� �������, �� ������� ���� ���������. ������ ���� � ��������, �� ���� �������� ����� ������ ����
*/

GO

CREATE OR ALTER VIEW ProductInfo (ProductId, ProductName, UnitPrice, UnitWeight, PromotionId, ReturnCount) AS
	WITH ProductReturnCount AS
	(
		SELECT 
			p.ProductID,
			COUNT(p.ProductID) AS ReturnCount
		FROM Products AS p
		INNER JOIN OrderDetails AS od ON od.ProductID = p.ProductID
		INNER JOIN Orders AS o ON o.OrderID = od.OrderID
		INNER JOIN [Returns] AS r on r.OrderID = o.OrderID
		GROUP BY p.ProductID
	)
	SELECT 
		p.ProductID,
		p.[Name] AS ProductName,
		p.UnitPrice,
		p.UnitWeight,
		p.PromotionID,
		c.ReturnCount
	FROM ProductReturnCount AS c
	INNER JOIN Products AS p ON p.ProductID = c.ProductID
	WHERE ReturnCount > 1
WITH CHECK OPTION

GO

SELECT *
FROM ProductInfo




/* ������������� �3:
	�������� �������������, ��� �������� ���������� ��� ������� �� ������� ��������, �� ���� �������. ������ ���� � ������, ������� ���� �������� 9.0 � ������� �������� �������� 2.
*/

GO

CREATE OR ALTER VIEW CompanyInfo AS
	SELECT 
		c.Delivery�ompanyID,
		c.[Name] AS CompanyName,
		c.Rating,
		c.AddressID,
		d.DeliveryCount
	FROM (SELECT 
		      c.Delivery�ompanyID,
		      COUNT(c.Delivery�ompanyID) AS DeliveryCount
		  FROM Delivery�ompany AS c
		  INNER JOIN DeliveryDetails AS d ON d.Delivery�ompanyID = c.Delivery�ompanyID
		  INNER JOIN Orders AS o ON o.DeliveryDetailsID = d.DeliveryDetailsID
		  GROUP BY c.Delivery�ompanyID) AS d
	INNER JOIN Delivery�ompany AS c ON c.Delivery�ompanyID = d.Delivery�ompanyID
	WHERE DeliveryCount > 2 AND Rating > 9
WITH CHECK OPTION

GO

SELECT *
FROM CompanyInfo