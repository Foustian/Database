CREATE PROCEDURE [dbo].[usp_ArticleNMDownload_SelectByCustomerGuid]
	@CustomerGuid		uniqueidentifier
AS
BEGIN
	SELECT DISTINCT
			ArticleNMDownload.ID,
			ArticleNMDownload.ArticleID,
			ArticleNMDownload.DownloadStatus,
			ArticleNMDownload.DLRequestDateTime,
			ArticleNMDownload.DownloadLocation,
			ArchiveNM.Title
	From
			ArticleNMDownload 
				INNER JOIN ArchiveNM
					ON ArticleNMDownload.ArticleID = ArchiveNM.ArticleID 
					--AND ArticleNMDownload.CustomerGuid = ArchiveNM.CustomerGuid
	WHERE
		   ArticleNMDownload.CustomerGuid = @CustomerGuid 
		   AND ArticleNMDownload.IsActive = 1
		   AND 	ArticleNMDownload.DownloadStatus != 3
END
