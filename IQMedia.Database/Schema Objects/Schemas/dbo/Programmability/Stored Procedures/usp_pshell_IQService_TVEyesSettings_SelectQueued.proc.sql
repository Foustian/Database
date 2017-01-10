CREATE PROCEDURE [dbo].[usp_pshell_IQService_TVEyesSettings_SelectQueued]
AS
BEGIN	  
	UPDATE   
		IQMediaGroup.dbo.IQService_TVEyesSettings
	SET  
		[Status] = 'SELECT',  
		ModifiedDate = GETDATE()  
	WHERE
		[Status] IN ('QUEUED','IN_PROCESS','FAILED')
  
	 SELECT   
		ID, _SearchRequestID
	FROM  
		IQMediaGroup.dbo.IQService_TVEyesSettings
	 WHERE  
		[Status] = 'SELECT'  
END