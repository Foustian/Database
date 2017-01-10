CREATE PROCEDURE [dbo].[usp_IOSService_fliQ_UploadTracking_Insert]
	@UniqueID uniqueidentifier,
	@FileName	varchar(256),
	@CategoryGuid uniqueidentifier,
	@Tags varchar(256),
	@DeviceDateTime	datetime,
	@DeviceTimeZone varchar(56),
	@VideoTimeZone datetime
AS
BEGIN
	
	DECLARE @ApplicationID bigint, @CustomerGuid uniqueidentifier, @ID bigint

	SET @ID = 0

	SELECT
			@ApplicationID = fliQ_Application.ID,
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

	WHERE
			fliQ_Customer.IsActive = 1 
			AND Client.IsActive = 1 
			AND fliQ_CustomerApplication.IsActive = 1 
			AND fliQ_ClientApplication.IsActive = 1 
			AND fliQ_Application.IsActive = 1
			AND fliQ_CustomerApplication.UniqueID = @UniqueID

	IF(@ApplicationID IS NOT NULL)
	BEGIN
		INSERT INTO fliQ_UploadTracking
		(
			_FliqCustomerGUID,
			_FliqApplicationID,
			UniqueID,
			[FileName],
			_CategoryGUID,
			Tags,
			DeviceDateTime,
			DeviceTimeZone,
			VideoDateTime,
			[Status],
			CreatedDate,
			ModifiedDate,
			IsActive
		)
		Values
		(
			@CustomerGuid,
			@ApplicationID,
			@UniqueID,
			@FileName,
			@CategoryGuid,
			@Tags,
			@DeviceDateTime,
			@DeviceTimeZone,
			@VideoTimeZone,
			'Started',
			GETDATE(),
			GETDATE(),
			1
		)

		IF(@@ROWCOUNT > 0)
		BEGIN
			SET @ID = SCOPE_IDENTITY()
		END
	END
	ELSE
	BEGIN
		SET @ID = -1
	END

	SELECT @ID as ID
END