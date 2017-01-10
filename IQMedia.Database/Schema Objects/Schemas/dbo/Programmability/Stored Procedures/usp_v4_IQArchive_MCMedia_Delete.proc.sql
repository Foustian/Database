CREATE PROCEDURE [dbo].[usp_v4_IQArchive_MCMedia_Delete]
	@MasterClientID INT,
	@MediaIDs XML,
	@ReturnValue INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @MasterClientGUID UNIQUEIDENTIFIER
		SELECT @MasterClientGUID = ClientGUID FROM Client WHERE ClientKey = @MasterClientID

		UPDATE	IQArchive_MCMedia
		SET		IsActive = 0,
				ModifiedDate = GETDATE()
		WHERE	MasterClientGUID = @MasterClientGUID
				AND IsActive = 1
				AND @MediaIDs.exist('list/item[@id=sql:column("IQArchive_MCMedia.ArchiveID")]') = 1

		SET @ReturnValue = @@ROWCOUNT

		COMMIT TRANSACTION	
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SET @ReturnValue = -1
		
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
				@CreatedBy='usp_v4_IQArchive_MCMedia_Delete',
				@ModifiedBy='usp_v4_IQArchive_MCMedia_Delete',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
						
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT		
	END CATCH

    
END
