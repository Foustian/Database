CREATE PROCEDURE [dbo].[usp_IOSService_fliQ_UploadTracking_UpdateStatus]
	@ID bigint,
	@Status varchar(16),
	@Comments varchar(512)
AS
BEGIN

	UPDATE
			fliQ_UploadTracking
	SET
			[Status] =  @Status,
			Comments = @Comments,
			UploadedDateTime = GETDATE(),
			ModifiedDate = GETDATE()
	WHERE
			ID = @ID
			AND IsActive = 1

	SELECT @@ROWCOUNT
END