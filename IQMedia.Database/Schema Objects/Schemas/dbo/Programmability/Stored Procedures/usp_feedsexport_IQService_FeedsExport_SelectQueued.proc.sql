CREATE PROCEDURE [dbo].[usp_feedsexport_IQService_FeedsExport_SelectQueued]
(
	 @TopRows INT,  
	 @MachineName VARCHAR(255)  
)
AS
BEGIN

	SET NOCOUNT ON;
	
	;WITH TempFeedsExport AS  
	 (  
		SELECT TOP(@TopRows)  
				ID
		FROM  
				IQMediaGroup.dbo.IQService_FeedsExport
		WHERE   
				[Status] IN ('QUEUED', 'TIMEOUT_URL_GENERATION')
		ORDER BY  
				ModifiedDate DESC
	 )  
  
	UPDATE   
		IQMediaGroup.dbo.IQService_FeedsExport
	SET  
		[Status] = 'SELECT',  
		MachineName = @MachineName,  
		ModifiedDate=GETDATE()  
	FROM   
		IQService_FeedsExport
			INNER JOIN TempFeedsExport
				ON IQService_FeedsExport.ID = TempFeedsExport.ID
				AND IQService_FeedsExport.[Status] IN ('QUEUED', 'TIMEOUT_URL_GENERATION') 
  
	 SELECT   
		ID,  
		CustomerGUID,
		SearchCriteria,
		ArticleXml,
		SortType,
		_RootPathID,
		CreatedDate,
		IsSelectAll,
		Title,
		GetTVUrl,
		TVUrlXml
	FROM  
		IQMediaGroup.dbo.IQService_FeedsExport
	 WHERE  
		[Status] = 'SELECT'  
		AND MachineName = @MachineName  

END