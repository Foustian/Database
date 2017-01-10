CREATE PROCEDURE [dbo].[usp_ArticleSMDownload_SelectByCustomerGuid]
	@CustomerGuid		uniqueidentifier
AS
BEGIN
	SELECT DISTINCT 
			ArticleSMDownload.ID,
			ArticleSMDownload.ArticleID,
			ArticleSMDownload.DownloadStatus,
			ArticleSMDownload.DLRequestDateTime,
			ArticleSMDownload.DownloadLocation,
			ArchiveSM.Title
	From
			ArticleSMDownload 
				INNER JOIN ArchiveSM
					ON ArticleSMDownload.ArticleID = ArchiveSM.ArticleID 
					--AND ArticleSMDownload.CustomerGuid = ArchiveSM.CustomerGuid
	WHERE
		   ArticleSMDownload.CustomerGuid = @CustomerGuid 
		   AND ArticleSMDownload.IsActive = 1
		   AND 	ArticleSMDownload.DownloadStatus != 3
END
