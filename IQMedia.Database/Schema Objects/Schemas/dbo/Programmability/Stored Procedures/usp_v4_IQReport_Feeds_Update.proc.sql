CREATE PROCEDURE [dbo].[usp_v4_IQReport_Feeds_Update]
	@MediaID varchar(max),
	@ReportID bigint,
	@ClientGuid  uniqueidentifier,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @UpdateJobTypeID bigint
	DECLARE @CurrentJobTypeID bigint
	
	SELECT	@UpdateJobTypeID = ID 
	FROM	IQJob_Type 
	WHERE	Name = 'FeedsReportGenerateUpdate'
	
	SELECT	@CurrentJobTypeID = JobTypeID
	FROM	IQReport_Feeds
	WHERE	ID = @ReportID
	
	-- If a user adds to a queued report, update the existing job rather than creating a new one
	IF (SELECT [Status] FROM IQReport_Feeds WHERE ID = @ReportID) = 'QUEUED'
	  BEGIN
		UPDATE IQJob_Master
		SET _CustomerGuid = @CustomerGuid,
			_RequestedDateTime = GETDATE()
		WHERE _RequestID = @ReportID
			AND _TypeID = @CurrentJobTypeID
			AND [Status] = 'QUEUED'
	  END
	ELSE
	  BEGIN					
		INSERT INTO IQJob_Master
		(
		   _RequestID,
		   _TypeID,
		   _CustomerGuid,
		   _Title,
		   _RequestedDateTime,
		   _CompletedDateTime,
		   _DownloadPath,
		  [Status],
		  _RootPathID
		)
		VALUES
		(
			@ReportID,
			@UpdateJobTypeID,
			@CustomerGuid,
			(SELECT Title FROM IQReport_Feeds WHERE ID = @ReportID),
			GETDATE(),
			NULL,
			NULL,
			'QUEUED',
			NULL
		)
		
		-- If adding to a completed report, set the job type to 'Add To Report' and reset the number of MetaDataUpdate passes
		Update 
			IQReport_Feeds
		Set 
			JobTypeID = @UpdateJobTypeID,
			NumMetaDataPasses = 0
		Where
			ID = @ReportID AND ClientGuid = @ClientGuid
	  END

    Update
		IQReport_Feeds
	Set 
		MediaID = cast(@MediaID as XML),
		[Status] = 'QUEUED',
		LastModified = GETDATE(),
		GenerateMachineName = NULL,
		MetaDataMachineName = NULL
	Where
		ID = @ReportID AND ClientGuid = @ClientGuid
END