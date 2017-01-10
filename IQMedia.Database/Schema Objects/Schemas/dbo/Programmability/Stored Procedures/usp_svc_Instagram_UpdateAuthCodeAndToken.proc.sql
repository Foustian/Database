CREATE PROCEDURE [dbo].[usp_svc_Instagram_UpdateAuthCodeAndToken]
(
	@ClientGUID	UNIQUEIDENTIFIER,
	@AuthCode	VARCHAR(150),
	@AuthToken	VARCHAR(200)	
)
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRY	
		BEGIN TRANSACTION

		IF (SELECT COUNT(*) FROM IQ_InstagramClients WHERE _ClientGUID = @ClientGUID) = 0
		  BEGIN
			INSERT INTO IQ_InstagramClients (_ClientGUID)
			VALUES (@ClientGUID)
		  END		
		
		UPDATE IQ_InstagramClients
		SET InstagramAuthCode = @AuthCode,
			InstagramAuthToken = @AuthToken,
			ModifiedDate = GETDATE(),
			IsActive = 1,
			IsTokenExpired = 0
		WHERE _ClientGUID = @ClientGUID
		
		SELECT 1

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT>0)
		BEGIN
			ROLLBACK TRANSACTION
		END
		
		DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActive	BIT				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(500),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_svc_Instagram_UpdateAuthCodeAndToken',
				@ModifiedBy='usp_svc_Instagram_UpdateAuthCodeAndToken',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT	

		SELECT -1
	END CATCH

END