CREATE PROCEDURE [dbo].[usp_IOSService_fliQ_Exception_Insert]
	@UDID		varchar(40),
	@Application	varchar(155),
	@ExceptionMessage varchar(MAX)
AS
BEGIN
	DECLARE @CustomerGuid uniqueidentifier
	SELECT 
			@CustomerGuid = fliQ_Customer.CustomerGuid
		
	From 
			fliQ_Customer 
				INNER JOIN Client ON 
					fliQ_Customer.ClientID = Client.ClientKey
				inner join fliQ_CustomerApplication ON
					fliQ_Customer.CustomerGUID = fliQ_CustomerApplication._FliqCustomerGUID
				inner join fliQ_ClientApplication ON
					Client.ClientGUID = fliQ_ClientApplication.ClientGUID
					and fliQ_CustomerApplication._FliqApplicationID = fliQ_ClientApplication._FliqApplicationID
				inner join fliQ_Application ON
					fliQ_Application.ID = fliQ_CustomerApplication._FliqApplicationID
					AND fliQ_Application.ID = fliQ_ClientApplication._FliqApplicationID
					AND fliQ_Application.[Application] = @Application
	WHERE
			fliQ_Customer.IsActive = 1 
			AND Client.IsActive = 1 
			AND fliQ_CustomerApplication.IsActive = 1 
			AND fliQ_ClientApplication.IsActive = 1 
			AND fliQ_Application.IsActive = 1
			AND fliQ_CustomerApplication.UniqueID = '1DE683C3-6800-4D04-AE12-43CDFF726358'

	INSERT INTO fliQ_Exception
	(
		[Application],
		Exception,
		_Fliq_CustomerGuid,
		CreatedDate,
		IsActive
	)
	values
	(
		@Application,
		@ExceptionMessage,
		@CustomerGuid,
		GETDATE(),
		1
	)

	SELECT @@ROWCOUNT
END