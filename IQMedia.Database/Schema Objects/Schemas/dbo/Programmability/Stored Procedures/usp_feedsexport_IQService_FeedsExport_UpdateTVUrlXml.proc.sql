CREATE PROCEDURE [dbo].[usp_feedsexport_IQService_FeedsExport_UpdateTVUrlXml]
(
	@ID		BIGINT,
	@TVUrlXml XML,
	@Status	VARCHAR(50)	
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	
	DECLARE @ModifiedDate DATETIME = GETDATE()
	
	UPDATE	IQMediaGroup.dbo.IQService_FeedsExport
		SET [Status] = @Status,
			TVUrlXml = @TVUrlXml,
			NumPasses = ISNULL(NumPasses, 0) + 1,
			[ModifiedDate] = @ModifiedDate			
	WHERE
		ID = @ID		
		
	COMMIT TRANSACTION	
		
END
