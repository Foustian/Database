CREATE PROCEDURE [dbo].[usp_v4_fliq_Customer_Delete]
	@CustomerKey bigint
AS
BEGIN

	UPDATE 
		fliQ_Customer
	SET 
		IsActive = 0 ,
		ModifiedDate = GETDATE()
	WHERE 
		CustomerKey = @CustomerKey

	SELECT @@ROWCOUNT
	
END