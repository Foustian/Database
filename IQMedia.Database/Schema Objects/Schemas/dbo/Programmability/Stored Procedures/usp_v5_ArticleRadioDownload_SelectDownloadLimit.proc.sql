CREATE PROCEDURE [dbo].[usp_v5_ArticleRadioDownload_SelectDownloadLimit]
(
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN
	SELECT	
			COUNT(ID) AS DownloadCount 
	FROM 
			IQMediaGroup.dbo.ArticleRadioDownload
				INNER JOIN	IQMediaGroup.dbo.ArchiveRadio  WITH (NOLOCK)
					ON	ArticleRadioDownload.ClipGuid = ArchiveRadio.ClipGuid
					AND	ArticleRadioDownload.CustomerGUID = @CustomerGUID
				INNER JOIN	IQMediaGroup.dbo.Client
					ON	ArchiveRadio.ClientGUID = Client.ClientGUID
				INNER JOIN	IQMediaGroup.dbo.Customer
					ON	Client.ClientKey = Customer.ClientID
					AND	Customer.CustomerGUID = @CustomerGUID
	WHERE	
			ClipDownloadStatus IN (1,2,3)
		AND	ArchiveRadio.IsActive = 1
		AND ArticleRadioDownload.IsActive = 1
END