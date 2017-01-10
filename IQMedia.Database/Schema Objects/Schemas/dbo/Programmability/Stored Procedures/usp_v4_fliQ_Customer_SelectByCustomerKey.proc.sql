CREATE PROCEDURE [dbo].[usp_v4_fliQ_Customer_SelectByCustomerKey]
(
	@CustomerID bigint
)
AS
BEGIN
	SELECT
			CustomerKey,
			FirstName,
			LastName,
			LoginID,
			Email,
			ContactNo,
			ClientID,
			IsActive,
			CustomerComment
	FROM	
			fliQ_Customer
	WHERE
			CustomerKey = @CustomerID
END