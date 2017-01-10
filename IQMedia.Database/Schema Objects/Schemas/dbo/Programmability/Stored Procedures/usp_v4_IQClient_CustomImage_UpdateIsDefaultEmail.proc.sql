CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomImage_UpdateIsDefaultEmail]
	@ID bigint,
	@ClientGuid uniqueidentifier,
	@Output int output
AS
BEGIN
	BEGIN TRANSACTION;        
	BEGIN TRY 
	
		UPDATE
			IQClient_CustomImage
		SET
			IsDefaultEmail = 1,
			ModifiedDate = GETDATE()
		WHERE
			ID = @ID
			AND _ClientGUID = @ClientGuid

		SET @Output = @@ROWCOUNT

		IF(@Output > 0)
		BEGIN
			UPDATE 
				IQClient_CustomImage
			SET
				IsDefaultEmail = 0,
				ModifiedDate = GETDATE()
			WHERE
				_ClientGUID = @ClientGuid
				AND IsDefaultEmail = 1 AND ID != @ID
		END
		COMMIT TRANSACTION;        
	END TRY
	BEGIN CATCH          
		ROLLBACK TRANSACTION;    
		SET @Output = -1
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
			@CreatedBy='usp_v4_IQClient_CustomImage_UpdateIsDefaultEmail',
			@ModifiedBy='usp_v4_IQClient_CustomImage_UpdateIsDefaultEmail',
			@CreatedDate=GETDATE(),
			@ModifiedDate=GETDATE(),
			@IsActive=1
					
			
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output    
	END CATCH
END