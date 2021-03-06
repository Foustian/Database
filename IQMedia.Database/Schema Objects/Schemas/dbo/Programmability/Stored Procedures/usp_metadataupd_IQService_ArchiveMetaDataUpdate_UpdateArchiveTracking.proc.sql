﻿CREATE PROCEDURE [dbo].[usp_metadataupd_IQService_ArchiveMetaDataUpdate_UpdateArchiveTracking]
(
	@ID BIGINT,
	@ArchiveTracking XML,
	@Status VARCHAR(50)
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRANSACTION

    UPDATE IQReport_Feeds
    SET
		ArchiveTracking = @ArchiveTracking,
		Status = @Status,
		NumMetaDataPasses = NumMetaDataPasses + 1,
		LastModified = GETDATE()
    WHERE
		ID = @ID
	
	DECLARE @LastModified DATETIME
	DECLARE @TypeID	BIGINT
	
	SELECT	@TypeID = JobTypeID,
			@LastModified = LastModified
	FROM	IQReport_Feeds
	WHERE	ID = @ID
	
	exec usp_Service_JobMaster_UpdateStatus @ID, @Status, @LastModified, @TypeID
	
	COMMIT TRANSACTION
    
END
