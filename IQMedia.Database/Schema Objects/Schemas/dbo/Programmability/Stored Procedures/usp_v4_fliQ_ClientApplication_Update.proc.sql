CREATE PROCEDURE [dbo].[usp_v4_fliQ_ClientApplication_Update]
	@ID bigint ,
	@ClientID bigint,
	@CategoryGuid uniqueidentifier,
	@ApplicationID bigint,
	@FTPHost varchar(255),
	@FTPPath varchar(255),
	@FTPLoginID varchar(255),
	@FTPPwd varchar(255),
	@MaxVideoDuration int,
	@ForceLandscape bit,
	@IsCategoryEnable bit,
	@IsActive bit,
	@Status bigint output
AS
BEGIN
	DECLARE @AppCount int

	SELECT @AppCount = COUNT(*)
	FROM 
		fliQ_ClientApplication inner join Client 
			on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
	Where 
		_FliqApplicationID = @ApplicationID and Client.ClientKey = @ClientID and ID != @ID

	IF(@AppCount = 0)
	BEGIN
		
		DECLARE @ClientGuid uniqueidentifier

		SELECT @ClientGuid = Client.ClientGUID FROM Client Where ClientKey = @ClientID and Client.IsFliq = 1 and Client.IsActive = 1
		
		IF(@ClientGuid IS NOT NULL)
		BEGIN

			UPDATE 
					fliQ_ClientApplication
			SET

					ClientGUID = @ClientGuid,
					_FliqApplicationID = @ApplicationID,
					FTPHost = @FTPHost,
					FTPPath = @FTPPath,
					FTPLoginID = @FTPLoginID,
					FTPPwd = @FTPPwd,
					MaxVideoDuration = @MaxVideoDuration,
					ForceLandscape = @ForceLandscape,
					IsActive = @IsActive,
					DefaultCategory = @CategoryGuid,
					IsCategoryEnable = @IsCategoryEnable,
					DateModified = GETDATE()
			WHERE
					ID = @ID
		
			SET @Status = @@ROWCOUNT
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