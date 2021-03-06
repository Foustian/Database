CREATE PROCEDURE [dbo].[usp_feedsexport_IQService_FeedsExport_UpdateStatus]
(
	@ID		BIGINT,
	@Status	VARCHAR(50)	
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	
	DECLARE @ModifiedDate DATETIME=GETDATE()
	
	UPDATE	IQMediaGroup.dbo.IQService_FeedsExport
		SET [Status]=@Status,
			[ModifiedDate]=@ModifiedDate			
	WHERE
		ID=@ID	
	
	IF (@Status='IN_PROCESS' OR @Status='COMPLETED' OR @Status='FAILED')
	BEGIN
	
		DECLARE @TypeID	BIGINT
		
		SELECT
			@TypeID=ID
		FROM
			IQMediaGroup.dbo.IQJob_Type
		WHERE
			Name='FeedsCSVExport'
		
		EXEC IQMediaGroup.dbo.usp_Service_JobMaster_UpdateStatus @ID, @Status, @ModifiedDate, @TypeID
	END
	
		
	COMMIT TRANSACTION
	
		
END
