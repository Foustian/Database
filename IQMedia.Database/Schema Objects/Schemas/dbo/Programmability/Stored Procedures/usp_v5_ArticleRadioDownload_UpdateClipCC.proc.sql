CREATE PROCEDURE [dbo].[usp_v5_ArticleRadioDownload_UpdateClipCC]
(
	@ClipDownloadKey	BIGINT,
	@ClipGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
			IQMediaGroup.dbo.ArticleRadioDownload
	SET
			CCDownloadStatus = 1,
			CCDownloadedDateTime = SYSDATETIME()
	WHERE
			ID = @ClipDownloadKey
		AND	ClipGuid = @ClipGUID

	SELECT @@ROWCOUNT

END