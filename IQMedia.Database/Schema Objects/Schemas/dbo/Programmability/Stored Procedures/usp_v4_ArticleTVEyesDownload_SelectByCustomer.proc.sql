CREATE PROCEDURE [dbo].[usp_v4_ArticleTVEyesDownload_SelectByCustomer]
	@CustomerGUID	UNIQUEIDENTIFIER
AS
BEGIN

	UPDATE
			ArticleTVEyesDownload
	SET
			DownloadStatus = 2,
			DownloadLocation = ISNULL(IQCore_RootPath.StoragePath + Location + AudioFile,'')
	FROM		
			ArticleTVEyesDownload
				INNER JOIN ArchiveTVEyes 
					ON ArticleTVEyesDownload.ArticleID = ArchiveTVEyes.ArchiveTVEyesKey
					AND ArticleTVEyesDownload.CustomerGuid = @CustomerGUID
					AND ArchiveTVEyes.IsActive = 1 
					AND ArticleTVEyesDownload.IsActive = 1
					AND DownloadStatus = 1
					AND ArchiveTVEyes.[Status] = 'DOWNLOADED'
				INNER JOIN IQCore_RootPath 
					ON ArchiveTVEyes._RootPathID = IQCore_RootPath.ID
	SELECT
			ArchiveTVEyes.Title,
			ArchiveTVEyes.ArchiveTVEyesKey,
			ArticleTVEyesDownload.ID,
			ArticleTVEyesDownload.CustomerGuid,
			ArticleTVEyesDownload.DownloadStatus,
			ArticleTVEyesDownload.DownloadLocation,
			ArticleTVEyesDownload.DLRequestDateTime,
			ArticleTVEyesDownload.DownLoadedDateTime,
			ArticleTVEyesDownload.IsActive
	FROM
			ArticleTVEyesDownload
				INNER JOIN ArchiveTVEyes 
					ON ArticleTVEyesDownload.ArticleID = ArchiveTVEyes.ArchiveTVEyesKey
	WHERE
			ArticleTVEyesDownload.CustomerGuid = @CustomerGUID
			AND ArchiveTVEyes .IsActive = 1
			AND ArticleTVEyesDownload.IsActive = 1
END