
DECLARE @Number varchar(255) = $(Number)

SELECT * 
FROM ServiceRequest
WHERE Number = @Number


