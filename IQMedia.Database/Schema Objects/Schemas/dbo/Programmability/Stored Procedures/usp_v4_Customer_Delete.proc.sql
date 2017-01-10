CREATE PROCEDURE [dbo].[usp_v4_Customer_Delete]
	@CustomerKey bigint
AS
BEGIN

	UPDATE 
		Customer
	SET 
		IsActive = 0 ,
		ModifiedDate = GETDATE()
	WHERE 
		CustomerKey = @CustomerKey

	SELECT @@ROWCOUNT
	
END