-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12 June 2013
-- Description:	Select By Customer
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ArticleSMDownload_SelectByCustomer]
	@CustomerGUID	UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE 
			ArticleSMDownload
	SET
			DownloadStatus = 2,
			DownloadLocation = ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_SM.Location,'')
	FROM 
			ArticleSMDownload
				INNER JOIN ArchiveSM	
					ON ArticleSMDownload.ArticleID = ArchiveSM.ArticleID
					AND ArticleSMDownload.CustomerGuid = @CustomerGUID 
					AND ArchiveSM.IsActive = 1
					AND DownloadStatus = 1
				INNER JOIN IQCore_SM
					ON ArchiveSM.ArticleID = IQCore_SM.ArticleID
					AND [Status] = 'Generated'
				INNER JOIN IQcore_RootPath 
					ON	IQCore_SM._RootPathID = IQcore_RootPath.ID

	SELECT	
			ArchiveSM.Title,
			ArchiveSM.ArticleID,
			ArticleSMDownload.ID,
			ArticleSMDownload.CustomerGuid,
			ArticleSMDownload.DownloadStatus,
			ArticleSMDownload.DownloadLocation,
			ArticleSMDownload.DLRequestDateTime,
			ArticleSMDownload.DownLoadedDateTime,
			ArticleSMDownload.IsActive
			
	FROM	ArticleSMDownload
	
	INNER JOIN	ArchiveSM
	ON		ArchiveSM.ArticleID = ArticleSMDownload.ArticleID
	AND		ArticleSMDownload.CustomerGUID = @CustomerGUID
	AND		ArchiveSM.IsActive = 1
	
	WHERE	ArticleSMDownload.CustomerGUID = @CustomerGUID
	AND		ArticleSMDownload.IsActive = 1
    
END
