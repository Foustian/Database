CREATE PROCEDURE [dbo].[usp_feedrptgen_IQService_FeedReportGenerate_SelectQueued]
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
				[Status] = 'QUEUED'
		ORDER BY  
				LastModified DESC
	 )  
  
	UPDATE   
		IQReport_Feeds
	SET  
		[Status] = 'SELECT',  
		GenerateMachineName = @MachineName,  
		LastModified = GETDATE()  
	FROM   
		IQReport_Feeds
			INNER JOIN TempReportFeeds
				ON IQReport_Feeds.ID = TempReportFeeds.ID
				AND IQReport_Feeds.[Status] = 'QUEUED'
  
	 SELECT   
		ID,  
		MediaID,
		CustomerGuid,
		ClientGuid
	 FROM  
		IQReport_Feeds
	 WHERE  
		[Status] = 'SELECT'  
		AND GenerateMachineName = @MachineName  

END