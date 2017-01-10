CREATE PROCEDURE [dbo].[usp_metadataupd_IQService_ArchiveMetaDataUpdate_SelectQueued]
(
	 @TopRows INT,  
	 @MachineName VARCHAR(255)  
)
AS
BEGIN

	SET NOCOUNT ON;
	
	;WITH TempReportFeeds AS  
	 (  
		SELECT TOP(@TopRows)  
				ID
		FROM  
				IQReport_Feeds
		WHERE   
				[Status] IN ('READY_FOR_METADATA', 'EXCEPTION_METADATA', 'TIMEOUT_METADATA')
		ORDER BY  
				LastModified DESC
	 )  
  
	UPDATE   
		IQReport_Feeds
	SET  
		[Status] = 'SELECT',  
		MetaDataMachineName = @MachineName,  
		LastModified = GETDATE()  
	FROM   
		IQReport_Feeds
			INNER JOIN TempReportFeeds
				ON IQReport_Feeds.ID = TempReportFeeds.ID
				AND IQReport_Feeds.[Status] IN ('READY_FOR_METADATA', 'EXCEPTION_METADATA', 'TIMEOUT_METADATA')
  
	 SELECT   
		ID,  
		ArchiveTracking
	 FROM  
		IQReport_Feeds
	 WHERE  
		[Status] = 'SELECT'  
		AND MetaDataMachineName = @MachineName  

END