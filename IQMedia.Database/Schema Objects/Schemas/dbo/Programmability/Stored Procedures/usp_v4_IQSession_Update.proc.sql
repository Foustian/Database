CREATE PROCEDURE [dbo].[usp_v4_IQSession_Update]
(
	@SessionID	VARCHAR(255),
	@LastAccessTime	DATETIME,
	@SessionTimeOut	DATETIME
)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
			IQSession
	SET
			LastAccessTime = @LastAccessTime,
			SessionTimeOut = @SessionTimeOut
	WHERE
			SessionID = @SessionID

	EXEC [usp_v4_IQSession_DeleteByTimeout]


END