CREATE PROCEDURE [dbo].[usp_v4_Client_Delete]
	@ClientKey bigint
AS
BEGIN

	UPDATE 
		Client 
	SET 
		IsActive = 0 ,
		ModifiedDate = GETDATE()
	WHERE 
		ClientKey = @ClientKey

	SELECT @@ROWCOUNT

	UPDATE 
		Customer
	SET
		IsActive = 0,
		ModifiedDate = GETDATE()
	WHERE
		ClientID = @ClientKey
		AND IsActive = 1


	UPDATE 
		fliQ_Customer
	SET
		IsActive = 0,
		ModifiedDate = GETDATE()
	WHERE
		ClientID = @ClientKey
		AND IsActive = 1
	
END
