CREATE PROCEDURE [dbo].[usp_v4_ArticleTVEyesDownload_Insert]
	@CustomerGUID	UNIQUEIDENTIFIER,
	@ID				BIGINT
AS
BEGIN
	DECLARE @ArticleID AS VARCHAR(50),@DownloadStatus AS INT

	SELECT 
			@ArticleID = ArchiveTVEyesKey
	FROM	
			IQArchive_Media
				INNER JOIN ArchiveTVEyes
					ON	IQArchive_Media._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
					AND	IQArchive_Media.MediaType = 'TM'
	WHERE	
			IQArchive_Media.ID = @ID
			AND IQArchive_Media.CustomerGUID = @CustomerGUID

	IF @ArticleID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ArticleTVEyesDownload WHERE CustomerGUID = @CustomerGUID AND ArticleID = @ArticleID AND DownloadStatus != 3) 
	BEGIN
		
		IF EXISTS(SELECT ArchiveTVEyesKey FROM ArchiveTVEyes WHERE ArchiveTVEyesKey = @ArticleID AND [Status] = 'DOWNLOADED' AND IsDownLoaded = 1)
		BEGIN
			SET @DownloadStatus = 2
		END
		ELSE
		BEGIN
			SET @DownloadStatus = 1
		END

		INSERT INTO ArticleTVEyesDownload
		(
			ARticleID,
			CustomerGuid,
			DownloadStatus,
			DownloadLocation,
			DLRequestDateTime,
			DownLoadedDateTime,
			IsActive
		)
		SELECT
		
			@ArticleID,
			@CustomerGUID,
			@DownloadStatus,
			ISNULL(IQCore_RootPath.StoragePath + Location + AudioFile,''),
			GETDATE(),
			GETDATE(),
			1
		
		FROM 
			ArchiveTVEyes	
				INNER JOIN IQCore_RootPath 
					ON ArchiveTVEyes._RootPathID = IQCore_RootPath.ID
		WHERE
			ArchiveTVEyesKey = @ArticleID
	END
END