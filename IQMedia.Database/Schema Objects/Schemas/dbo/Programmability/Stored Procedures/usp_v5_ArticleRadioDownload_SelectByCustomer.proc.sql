CREATE PROCEDURE [dbo].[usp_v5_ArticleRadioDownload_SelectByCustomer]
(
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT	
			ArchiveRadio.Title,
			ArticleRadioDownload.ID,
			ArticleRadioDownload.CustomerGUID,
			ArticleRadioDownload.ClipDownloadStatus,
			ArticleRadioDownload.ClipFileLocation,
			ArticleRadioDownload.ClipDLFormat,
			ArticleRadioDownload.ClipDLRequestDateTime,
			ArticleRadioDownload.ClipDownLoadedDateTime,
			ArticleRadioDownload.IsActive,
			ArticleRadioDownload.ClipGuid			
	FROM	
			IQMediaGroup.dbo.ArticleRadioDownload	
				INNER JOIN	ArchiveRadio WITH (NOLOCK)
					ON	ArticleRadioDownload.ClipGuid = ArchiveRadio.ClipGuid
					AND	ArticleRadioDownload.CustomerGUID = @CustomerGUID
				INNER JOIN	Client
					ON	ArchiveRadio.ClientGUID = Client.ClientGUID
				INNER JOIN	Customer
					ON	Client.ClientKey = Customer.ClientID
					AND	Customer.CustomerGUID = @CustomerGUID
	WHERE	
			ArticleRadioDownload.ClipDownloadStatus IN (1,2,3)
		AND	ArchiveRadio.IsActive = 1
		AND ArticleRadioDownload.IsActive = 1
END
