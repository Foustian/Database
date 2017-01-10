CREATE PROCEDURE [dbo].[usp_metadataupd_IQService_DiscoveryArchiveMetaDataUpdate_UpdateStatus]
(
	@ID		BIGINT,
	@Status	VARCHAR(50),
	@ResetMachineName BIT
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	
	UPDATE	IQReport_Discovery
		SET [Status]=@Status,
			[LastModified]=GETDATE()
	WHERE
		ID=@ID		
		
	IF @ResetMachineName = 1 
	BEGIN	
		UPDATE	IQReport_Discovery
			SET [MetaDataMachineName] = NULL
		WHERE
			ID=@ID	
	END
	
	DECLARE @LastModified DATETIME
	DECLARE @TypeID	BIGINT
	
	SELECT	@TypeID = JobTypeID,
			@LastModified = LastModified
	FROM	IQReport_Discovery
	WHERE	ID = @ID
	
	exec usp_Service_JobMaster_UpdateStatus @ID, @Status, @LastModified, @TypeID
		
	COMMIT TRANSACTION
	
		
END
