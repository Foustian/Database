CREATE PROCEDURE usp_feedrptgen_IQService_FeedReportGenerate_ResetJob
	@ID bigint,
	@RequestID bigint
AS
BEGIN

	DECLARE @AddToReportTypeID bigint
	
	SELECT @AddToReportTypeID = ID 
	FROM IQJob_Type 
	WHERE Name = 'FeedsReportGenerateUpdate'	
	
    UPDATE IQReport_Feeds
    SET	ArchiveTracking = CASE JobTypeID WHEN @AddToReportTypeID THEN ArchiveTracking ELSE NULL END,
		Status = 'QUEUED',
		GenerateMachineName = NULL,
		MetaDataMachineName = NULL,
		LastModified = GETDATE()
	WHERE ID = @RequestID
		
	IF @@ROWCOUNT = 1
	  BEGIN
		UPDATE IQJob_Master
		SET _RequestedDateTime = GETDATE(),
			_CompletedDateTime = null,
			Status = 'QUEUED'
		WHERE ID = @ID
		
		SELECT @@ROWCOUNT
	  END
	ELSE
	  BEGIN
		SELECT 0
	  END
END