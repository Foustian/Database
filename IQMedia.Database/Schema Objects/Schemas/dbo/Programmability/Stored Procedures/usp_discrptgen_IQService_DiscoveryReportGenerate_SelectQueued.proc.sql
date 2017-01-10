CREATE PROCEDURE [dbo].[usp_discrptgen_IQService_DiscoveryReportGenerate_SelectQueued]
(
	 @TopRows INT,  
	 @MachineName VARCHAR(255)  
)
AS
BEGIN

	SET NOCOUNT ON;
	
	;WITH TempReportDiscovery AS  
	 (  
		SELECT TOP(@TopRows)  
				ID
		FROM  
				IQReport_Discovery
		WHERE   
				[Status] = 'QUEUED'
		ORDER BY  
				LastModified DESC
	 )  
  
	UPDATE   
		IQReport_Discovery
	SET  
		[Status] = 'SELECT',  
		GenerateMachineName = @MachineName,  
		LastModified = GETDATE()  
	FROM   
		IQReport_Discovery
			INNER JOIN TempReportDiscovery
				ON IQReport_Discovery.ID = TempReportDiscovery.ID
				AND IQReport_Discovery.[Status] = 'QUEUED'
  
	 SELECT   
		ID,  
		MediaID,
		ClientGUID,
		CustomerGUID
	 FROM  
		IQReport_Discovery
	 WHERE  
		[Status] = 'SELECT'  
		AND GenerateMachineName = @MachineName  

END