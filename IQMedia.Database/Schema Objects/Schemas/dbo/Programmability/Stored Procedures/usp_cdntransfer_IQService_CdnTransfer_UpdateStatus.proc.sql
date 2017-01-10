CREATE PROCEDURE [dbo].[usp_cdntransfer_IQService_CdnTransfer_UpdateStatus]
(
	@ID		BIGINT,
	@Status	VARCHAR(50)	
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	
	UPDATE	IQService_CdnTransfer
		SET [Status]=@Status,
			[LastModified]=GETDATE()
	WHERE
		ID=@ID		
		
	COMMIT TRANSACTION
	
		
END