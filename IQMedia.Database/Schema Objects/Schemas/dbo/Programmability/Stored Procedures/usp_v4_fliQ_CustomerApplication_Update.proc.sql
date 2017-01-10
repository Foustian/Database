CREATE PROCEDURE [dbo].[usp_v4_fliQ_CustomerApplication_Update]
	@ID bigint,
	@CustomerID bigint,
	@ApplicationID bigint,
	@IsActive bit,
	@Status int output
AS
BEGIN
	DECLARE @AppCount int 
	SELECT 
			@AppCount = COUNT(*)
	FROM
			fliQ_CustomerApplication
				inner join fliQ_ClientApplication 
					on fliQ_CustomerApplication._FliqApplicationID = fliQ_ClientApplication._FliqApplicationID
				inner join Client 
					on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
					and Client.IsActive = 1
					and Client.IsFliq = 1
				inner join fliQ_Customer 
					on fliQ_CustomerApplication._FliqCustomerGUID = fliQ_Customer.CustomerGUID
					and fliQ_Customer.ClientID = Client.ClientKey
					and fliQ_Customer.IsActive = 1
	WHERE
			fliQ_CustomerApplication._FliqApplicationID = @ApplicationID 
			and fliQ_Customer.CustomerKey = @CustomerID
			and fliQ_CustomerApplication.ID != @ID
			
	IF(@AppCount = 0)
	BEGIN
		DECLARE @CustomerGuid uniqueidentifier

		SELECT @CustomerGuid = fliQ_Customer.CustomerGUID
		FROM	
			fliQ_Customer 
				inner join Client
					on fliQ_Customer.ClientID = Client.ClientKey
					and fliQ_Customer.IsActive = 1 
					and Client.IsActive = 1
					and Client.IsFliq = 1
		WHERE
			 fliQ_Customer.CustomerKey = @CustomerID

		IF(@CustomerGuid IS NOT NULL)
		BEGIN
			
			UPDATE
					fliQ_CustomerApplication
			SET
					_FliqApplicationID = @ApplicationID,
					_FliqCustomerGUID = @CustomerGuid,
					IsActive = @IsActive,
					DateModified = GETDATE()
			WHERE
					ID = @ID

			SET @Status = @@ROWCOUNT;
		END
		ELSE
		BEGIN
			SET @Status = -1
		END
	END
	ELSE
	BEGIN
		SET @Status = 0
	END
END