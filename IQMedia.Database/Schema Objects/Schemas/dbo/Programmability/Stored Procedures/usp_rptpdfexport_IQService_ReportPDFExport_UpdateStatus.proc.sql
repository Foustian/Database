CREATE PROCEDURE [dbo].[usp_rptpdfexport_IQService_ReportPDFExport_UpdateStatus]
(
	@ID		BIGINT,
	@Status	VARCHAR(50)	
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	
	DECLARE @ModifiedDate DATETIME = GETDATE()
	
	UPDATE	IQMediaGroup.dbo.IQService_ReportPDFExport
		SET [Status] = @Status,
			ModifiedDate = @ModifiedDate			
	WHERE
		ID = @ID	

	IF @Status NOT IN ('IN_PROCESS', 'COMPLETED', 'FAILED')
	BEGIN
		SET @Status = 'FAILED'
	END
	
	DECLARE @TypeID	BIGINT
		
	SELECT
		@TypeID = ID
	FROM
		IQMediaGroup.dbo.IQJob_Type
	WHERE
		Name='ReportPDFExport'
		
	EXEC IQMediaGroup.dbo.usp_Service_JobMaster_UpdateStatus @ID, @Status, @ModifiedDate, @TypeID
			
	COMMIT TRANSACTION
			
END