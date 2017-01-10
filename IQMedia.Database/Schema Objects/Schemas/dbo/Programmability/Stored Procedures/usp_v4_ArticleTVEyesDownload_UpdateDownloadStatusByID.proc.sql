CREATE PROCEDURE [dbo].[usp_v4_ArticleTVEyesDownload_UpdateDownloadStatusByID]
	@ID		BIGINT,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	UPDATE
			ArticleTVEyesDownload
	SET
			DownloadStatus = 3
	WHERE
			ID = @ID
			AND CustomerGuid = @CustomerGuid
END