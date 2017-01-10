-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12 June 2013
-- Description:	Select By Customer
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ArticleNMDownload_SelectByCustomer]
	@CustomerGUID	UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	UPDATE 
			ArticleNMDownload
	SET
			DownloadStatus = 2,
			DownloadLocation =   ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_NM.Location,'')
	FROM 
			ArticleNMDownload
				INNER JOIN ArchiveNM	
					ON ArticleNMDownload.ArticleID = ArchiveNM.ArticleID
					AND ArticleNMDownload.CustomerGuid = @CustomerGUID 
					AND ArchiveNM.IsActive = 1
					AND DownloadStatus = 1
				INNER JOIN IQCore_NM
					ON ArchiveNM.ArticleID = IQCore_NM.ArticleID
					AND [Status] = 'Generated'
				INNER JOIN IQCore_RootPath
					ON	IQCore_NM._RootPathID = IQcore_RootPath.ID

	SELECT	
			ArchiveNM.Title,
			ArchiveNM.ArticleID,
			ArticleNMDownload.ID,
			ArticleNMDownload.CustomerGuid,
			ArticleNMDownload.DownloadStatus,
			ArticleNMDownload.DownloadLocation,
			ArticleNMDownload.DLRequestDateTime,
			ArticleNMDownload.DownLoadedDateTime,
			ArticleNMDownload.IsActive
			
	FROM	ArticleNMDownload
	
	INNER JOIN	ArchiveNM
	ON		ArchiveNM.ArticleID = ArticleNMDownload.ArticleID
	AND		ArticleNMDownload.CustomerGUID = @CustomerGUID
	AND		ArchiveNM.IsActive = 1
	
	WHERE	ArticleNMDownload.CustomerGUID = @CustomerGUID
	AND		ArticleNMDownload.IsActive = 1
    
END