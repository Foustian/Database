CREATE PROCEDURE [dbo].[usp_conversion_IQService_Conversion_SelectQueued]
(
	 @TopRows INT,  
	 @MachineName VARCHAR(255)  
)
AS
BEGIN

	SET NOCOUNT ON;
	
	;WITH TempConversion AS  
	 (  
		SELECT TOP(@TopRows)  
				ID
		FROM  
				IQService_Conversion
		WHERE   
				[Status] = 'QUEUED'  
		ORDER BY  
				LastModified DESC
	 )  
  
	UPDATE   
		IQService_Conversion
	SET  
		[Status] = 'SELECT',  
		MachineName = @MachineName,  
		LastModified = GETDATE()  
	FROM   
		IQService_Conversion
			INNER JOIN TempConversion
				ON IQService_Conversion.ID = TempConversion.ID
				AND IQService_Conversion.[Status] = 'QUEUED'  
  
	 SELECT   
		ID,  
		Filename
	 FROM  
		IQService_Conversion
	 WHERE  
		[Status] = 'SELECT'  
		AND MachineName = @MachineName  

END