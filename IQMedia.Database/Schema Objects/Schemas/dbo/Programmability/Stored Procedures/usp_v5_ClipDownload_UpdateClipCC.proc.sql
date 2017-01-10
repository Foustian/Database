CREATE PROCEDURE [dbo].[usp_v5_ClipDownload_UpdateClipCC]
(
	@ClipDownloadKey	BIGINT,
	@ClipGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
			ClipDownload
	SET
			CCDownloadStatus = 1,
			CCDownloadedDateTime = SYSDATETIME()
	WHERE
			IQ_ClipDownload_Key = @ClipDownloadKey
		AND	ClipID = @ClipGUID

	SELECT @@ROWCOUNT

END