CREATE PROCEDURE [dbo].[usp_pshell_IQAgent_DeleteControl_UpdateStatus]
(
	@ID		BIGINT,
	@IsDatabase BIT,
	@IsSuccess BIT OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION
		
		-- This procedure will only be called if the delete succeeds
		IF @IsDatabase = 1
		  BEGIN
			UPDATE	IQAgent_DeleteControl
				SET isDBUpdated = 'COMPLETED',
					dbUpdateDate = GETDATE()
			WHERE
				ID = @ID		
		  END
		ELSE		
		  BEGIN
			UPDATE	IQAgent_DeleteControl
				SET isSolrUpdated = 'COMPLETED',
					solrUpdateDate = GETDATE()
			WHERE
				ID = @ID	
				
			DECLARE @LastModified DATETIME = GETDATE()
			DECLARE @TypeID	BIGINT
			
			SELECT @TypeID = ID FROM IQJob_Type WHERE Name = 'FeedsDelete'
			
			exec usp_Service_JobMaster_UpdateStatus @ID, 'COMPLETED', @LastModified, @TypeID
		  END
			
		SET @IsSuccess = 1
				
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT>0)
		  BEGIN		          
			ROLLBACK TRANSACTION;  
		  END
		
		SET @IsSuccess = 0 
		
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
			@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
			@CreatedBy='usp_pshell_IQAgent_DeleteControl_UpdateStatus',
			@ModifiedBy='usp_pshell_IQAgent_DeleteControl_UpdateStatus',
			@CreatedDate=GETDATE(),
			@ModifiedDate=GETDATE(),
			@IsActive=1

		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
	END CATCH 		
END
