CREATE PROCEDURE [dbo].[usp_pshell_IQService_TwitterSettings_SelectQueued]
AS
BEGIN	  
	UPDATE   
		IQMediaGroup.dbo.IQService_TwitterSettings
	SET  
		[Status] = 'SELECT',  
		ModifiedDate = GETDATE()  
	WHERE
		[Status] IN ('QUEUED','IN_PROCESS','FAILED')
  
	 SELECT   
		ID
	FROM  
		IQMediaGroup.dbo.IQService_TwitterSettings
	 WHERE  
		[Status] = 'SELECT'  
END
