CREATE PROCEDURE [dbo].[usp_v4_fliQ_ClientApplication_Insert]
	@ClientID bigint,
	@ApplicationID bigint,
	@CategoryGuid uniqueidentifier,
	@FTPHost varchar(255),
	@FTPPath varchar(255),
	@FTPLoginID varchar(255),
	@FTPPwd varchar(255),
	@MaxVideoDuration int,
	@ForceLandscape bit,
	@IsActive bigint,
	@IsCategoryEnable bit,
	@ID bigint output
AS
BEGIN
	DECLARE @AppCount int

	SELECT @AppCount = COUNT(*)
	FROM 
		fliQ_ClientApplication inner join Client 
			on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
	Where 
		_FliqApplicationID = @ApplicationID and Client.ClientKey = @ClientID

	IF(@AppCount = 0)
	BEGIN
		
		DECLARE @ClientGuid uniqueidentifier

		SELECT @ClientGuid = Client.ClientGUID FROM Client Where ClientKey = @ClientID and Client.IsFliq = 1 and Client.IsActive = 1
		
		IF(@ClientGuid IS NOT NULL)
		BEGIN
			INSERT INTO fliQ_ClientApplication
			(
				ClientGUID,
				_FliqApplicationID,
				DefaultCategory,
				FTPHost,
				FTPPath,
				FTPLoginID,
				FTPPwd,
				MaxVideoDuration,
				ForceLandscape,
				IsActive,
				IsCategoryEnable,
				DateCreated,
				DateModified
			)
			values
			(
				@ClientGuid,
				@ApplicationID,
				@CategoryGuid,
				@FTPHost,
				@FTPPath,
				@FTPLoginID,
				@FTPPwd,
				@MaxVideoDuration,
				@ForceLandscape,
				@IsActive,
				@IsCategoryEnable,
				GETDATE(),
				GETDATE()
			)

			SET @ID = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SET @ID = -1
		END
	END
	ELSE
	BEGIN
		SET @ID = 0
	END

END