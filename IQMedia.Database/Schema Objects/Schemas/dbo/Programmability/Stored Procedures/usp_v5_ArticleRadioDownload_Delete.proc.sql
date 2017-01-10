CREATE PROCEDURE [dbo].[usp_v5_ArticleRadioDownload_Delete]
	@CustomerGUID			UNIQUEIDENTIFIER,
	@ClipDownloadKey		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE IQMediaGroup.dbo.ArticleRadioDownload
	SET
		IsActive = 0,
		ModifiedDate = GETDATE()
	WHERE
		ID = @ClipDownloadKey
	AND	CustomerGUID = @CustomerGUID

END
