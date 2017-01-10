CREATE PROCEDURE [dbo].[usp_cdntransfer_IQService_CdnTransfer_SelectQueued]
(
	 @TopRows INT,  
	 @MachineName VARCHAR(255)  
)
AS
BEGIN

	SET NOCOUNT ON;
	
	;WITH TempCdnTransfer AS  
	 (  
		SELECT TOP(@TopRows)  
				ID
		FROM  
				IQService_CdnTransfer
		WHERE   
				[Status] = 'QUEUED'  
		ORDER BY  
				LastModified DESC
	 )  
  
	UPDATE   
		IQService_CdnTransfer
	SET  
		[Status] = 'SELECT',  
		MachineName = @MachineName,  
		LastModified = GETDATE()  
	FROM   
		IQService_CdnTransfer
			INNER JOIN TempCdnTransfer
				ON IQService_CdnTransfer.ID = TempCdnTransfer.ID
				AND IQService_CdnTransfer.[Status] = 'QUEUED'  
  
	 SELECT   
		ID,  
		RecordfileGUID,
		Direction  
	 FROM  
		IQService_CdnTransfer
	 WHERE  
		[Status] = 'SELECT'  
		AND MachineName = @MachineName  

END