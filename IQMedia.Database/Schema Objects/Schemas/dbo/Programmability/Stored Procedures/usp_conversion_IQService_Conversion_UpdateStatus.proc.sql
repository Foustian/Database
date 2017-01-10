CREATE PROCEDURE [dbo].[usp_conversion_IQService_Conversion_UpdateStatus]
(
	@ID		BIGINT,
	@Status	VARCHAR(50)	
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	
	UPDATE	IQService_Conversion
		SET [Status]=@Status,
			[LastModified]=GETDATE()
	WHERE
		ID=@ID		
		
	COMMIT TRANSACTION	
		
END
