CREATE PROCEDURE [dbo].[usp_IOSService_Customer_CheckMobileLogin]
(
	@LoginID	varchar(300),	
	@UDID		varchar(40),
	@Application varchar(max),
	@AppVersion varchar(20),
	@Status		int output,
	@AppPath	varchar(512) output,
	@ClientGuid uniqueidentifier output,
	@CustomerPassword	VARCHAR(60)	OUTPUT,
	@PasswordAttempts	TINYINT OUTPUT
)
AS
BEGIN
	
	SET @Status = 0
	
	DECLARE @CustomerKey bigint,
			@CustomerApplicationKey bigint	

	DECLARE @FTPHost varchar(255), @FTPPath varchar(255), @FTPLoginID varchar(255), @FTPPwd varchar(255), @DefaultCategory uniqueidentifier, @IsCategoryEnabled bit, @MaxVideoDuration int, @ForceLandscape bit


	SELECT 
		@CustomerKey = CustomerKey,
		@ClientGuid = Client.ClientGUID,
		@CustomerPassword=CustomerPassword,
		@PasswordAttempts=PasswordAttempts
	FROM 
		fliQ_Customer
			Inner join  Client
				on Client.ClientKey = fliQ_Customer.ClientID 
	WHERE 
		fliQ_Customer.LoginID = @LoginID 
		AND fliQ_Customer.IsActive = 1 
		AND Client.IsActive = 1

	IF(@CustomerKey IS NOT NULL)
	BEGIN
		IF EXISTS(SELECT 1 from fliQ_Application Where [Application]=@Application and [Version] = @AppVersion and IsActive =1)
		BEGIN
			SELECT 
					@CustomerApplicationKey = fliQ_CustomerApplication.ID,
					@FTPHost = fliQ_ClientApplication.FTPHost,
					@FTPPath = fliQ_ClientApplication.FTPPath,
					@FTPLoginID = fliQ_ClientApplication.FTPLoginID,
					@FTPPwd = fliQ_ClientApplication.FTPPwd,
					@DefaultCategory = fliQ_ClientApplication.DefaultCategory,
					@MaxVideoDuration = fliQ_ClientApplication.MaxVideoDuration,
					@IsCategoryEnabled =  fliQ_ClientApplication.IsCategoryEnable,
					@ForceLandscape =  fliQ_ClientApplication.ForceLandscape
			FROM	
					fliQ_Customer 
					INNER JOIN Client ON 
					  fliQ_Customer.ClientID = Client.ClientKey
					  and fliQ_Customer .CustomerKey = @CustomerKey
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
						
			IF(@CustomerApplicationKey IS NOT NULL)
			BEGIN
				UPDATE
					fliQ_CustomerApplication
				SET
					UniqueID = @UDID
				WHERE
					ID = @CustomerApplicationKey

				SET @Status = 0
			END
			ELSE
			BEGIN
				SET @Status = -1
			END
		END
		ELSE
		BEGIN
			
			SELECT @AppPath = [Path] FROM  fliQ_Application Where [Application] = @Application order by [Version] desc
			IF(@AppPath IS NOT NULL)
			BEGIN
				SET @Status = -3
			END
			ELSE
			BEGIN
				SET @Status = -1
			END
		END
		
	END
	ELSE
	BEGIN
		SET @Status = -2
	END

	SELECT 
		@FTPHost as FTPHost, 
		@FTPPath as FTPPath, 
		@FTPLoginID as FTPLoginID, 
		@FTPPwd as FTPPwd,
		@DefaultCategory as DefaultCategory,
		@IsCategoryEnabled as IsCategoryEnabled,
		@MaxVideoDuration as MaxVideoDuration,
		@ForceLandscape as ForceLandscape

	SELECT @Status,@ClientGuid,@AppPath
END