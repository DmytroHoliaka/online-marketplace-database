USE DigitalMarketplace;

DROP INDEX IF EXISTS IX_Messages_UserID
ON [Messages];

CREATE NONCLUSTERED INDEX IX_Messages_UserID
ON [Messages](UserID);


SELECT 
	MessageID,
	UserID
FROM 
	[Messages]
WHERE
	UserID = 46
