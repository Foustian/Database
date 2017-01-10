CREATE PROCEDURE [dbo].[usp_v4_ArticleTVEyesDownload_SelectDownloadLimit]
	@CustomerGUID	UNIQUEIDENTIFIER
AS
BEGIN
	SELECT	COUNT(*) AS DownloadCount 
	FROM  ArticleTVEyesDownload
	WHERE	CustomerGUID = @CustomerGUID
	AND		DownloadStatus <> 3
END