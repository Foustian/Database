CREATE PROCEDURE [dbo].[usp_IOSService_Customer_CheckIsRegistered]
	@UDID		varchar(40),
	@Application	varchar(MAX),
	@ClientGuid uniqueidentifier output,
	@AppVersion	varchar(20),
	@Status		int output,
	@AppPath	varchar(512) output
AS
BEGIN

	DECLARE @FTPHost varchar(255), @FTPPath varchar(255), @FTPLoginID varchar(255), @FTPPwd varchar(255), @DefaultCategory uniqueidentifier, @IsCategoryEnabled bit, @MaxVideoDuration int, @ForceLandscape bit
	IF EXISTS(SELECT 1 from fliQ_Application Where [Application]=@Application and [Version] = @AppVersion and IsActive =1)
	BEGIN
		SELECT 
			@FTPHost = fliQ_ClientApplication.FTPHost,
			@FTPPath = fliQ_ClientApplication.FTPPath,
			@FTPLoginID = fliQ_ClientApplication.FTPLoginID,
			@FTPPwd = fliQ_ClientApplication.FTPPwd,
			@DefaultCategory = fliQ_ClientApplication.DefaultCategory,
			@MaxVideoDuration = fliQ_ClientApplication.MaxVideoDuration,
			@IsCategoryEnabled =  fliQ_ClientApplication.IsCategoryEnable,
			@ForceLandscape =  fliQ_ClientApplication.ForceLandscape,
			@ClientGuid = Client.ClientGUID
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
				AND fliQ_CustomerApplication.UniqueID = @UDID

		SET @Status = 0
	END
	ELSE
	BEGIN
		SET @Status = -1
		SELECT @AppPath = [Path] FROM  fliQ_Application Where [Application] = @Application and IsActive = 1 order by [Version] desc
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

	SELECT @ClientGuid,@Status,@AppPath
	
END