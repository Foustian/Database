CREATE PROCEDURE [dbo].[usp_Service_JobMaster_UpdateStatus]
(
	@RequestID		BIGINT,
	@JobStatus		VARCHAR(50),
	@CompletedDateTime	DATETIME,
	@TypeID		BIGINT
)
AS
BEGIN

	SET NOCOUNT ON;
	
		UPDATE	IQJob_Master
		SET [Status]=@JobStatus,
			_CompletedDateTime=CASE WHEN @JobStatus='Completed' OR @JobStatus='Failed' THEN @CompletedDateTime ELSE _CompletedDateTime END
		WHERE
			_RequestID=@RequestID
		AND	_TypeID=@TypeID
		AND _CompletedDateTime IS NULL

END