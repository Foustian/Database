CREATE PROCEDURE [dbo].[usp_discrptgen_IQService_DiscoveryReportGenerate_UpdateStatus]
(
	@ID		BIGINT,
	@Status	VARCHAR(50)
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	
	UPDATE	IQReport_Discovery
		SET [Status]=@Status,
			[LastModified]=GETDATE()
	WHERE
		ID=@ID		
		
	IF @Status = 'EXCEPTION'
	  BEGIN
		SET @Status = 'FAILED'
	  END	  
	
	DECLARE @LastModified DATETIME
	DECLARE @TypeID	BIGINT
	
	SELECT	@TypeID = JobTypeID,
			@LastModified = LastModified
	FROM	IQReport_Discovery
	WHERE	ID = @ID
	
	exec usp_Service_JobMaster_UpdateStatus @ID, @Status, @LastModified, @TypeID
		
	COMMIT TRANSACTION
		
END
