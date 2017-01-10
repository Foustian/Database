CREATE PROCEDURE [dbo].[usp_metadataupd_IQService_DiscoveryArchiveMetaDataUpdate_SelectQueued]
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
				[Status] IN ('READY_FOR_METADATA', 'EXCEPTION_METADATA', 'TIMEOUT_METADATA')
		ORDER BY  
				LastModified DESC
	 )  
  
	UPDATE   
		IQReport_Discovery
	SET  
		[Status] = 'SELECT',  
		MetaDataMachineName = @MachineName,  
		LastModified = GETDATE()  
	FROM   
		IQReport_Discovery
			INNER JOIN TempReportDiscovery
				ON IQReport_Discovery.ID = TempReportDiscovery.ID
				AND IQReport_Discovery.[Status] IN ('READY_FOR_METADATA', 'EXCEPTION_METADATA', 'TIMEOUT_METADATA')
  
	 SELECT   
		ID,  
		ArchiveTracking
	 FROM  
		IQReport_Discovery
	 WHERE  
		[Status] = 'SELECT'  
		AND MetaDataMachineName = @MachineName  

END