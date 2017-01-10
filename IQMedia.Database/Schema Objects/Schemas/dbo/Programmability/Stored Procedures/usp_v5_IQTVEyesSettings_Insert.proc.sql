CREATE PROCEDURE [dbo].[usp_v5_IQTVEyesSettings_Insert]
(
	@ClientGUID UNIQUEIDENTIFIER,
	@SearchRequestID BIGINT,
	@AgentName VARCHAR(MAX),
	@SearchTerm VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY
		BEGIN TRANSACTION   

		INSERT INTO IQMediaGroup.dbo.IQ_TVEyes_Settings (
			ClientGUID, 
			SRID,
			TVESearchGUID,
			TVESearchTerm,
			SearchDisplayName, 
			Comments, 
			CreatedDate, 
			ModifiedDate, 
			IsActive
		)
		VALUES (
			@ClientGUID, 
			@SearchRequestID,
			null,
			@SearchTerm,
			@AgentName + ' Search Term', 
			@AgentName + ' Search Term', 
			GETDATE(), 
			GETDATE(), 
			1
		)

		DECLARE @TVESettingsKey BIGINT
		SET @TVESettingsKey = SCOPE_IDENTITY()

		INSERT INTO IQMediaGroup.dbo.IQ_TVEyes_Settings_History (
			_TVESettingsKey,
			TVESearchTerm,
			CreatedDate
		)
		VALUES (
			@TVESettingsKey,
			@SearchTerm,
			GETDATE()
		)
		
		SELECT @TVESettingsKey
		COMMIT TRANSACTION		
	END TRY
	BEGIN CATCH			
		ROLLBACK TRANSACTION
		
		declare @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit				
		
		Select 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v5_IQTVEyesSettings_Insert',
				@ModifiedBy='usp_v5_IQTVEyesSettings_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output

		SELECT -1
	END CATCH
END