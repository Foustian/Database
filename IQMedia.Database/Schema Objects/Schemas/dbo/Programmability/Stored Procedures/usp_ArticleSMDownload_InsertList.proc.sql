CREATE PROCEDURE [dbo].[usp_ArticleSMDownload_InsertList]
	@CustomerGuid	uniqueidentifier,
	@XmlData		xml
AS
BEGIN
	
	INSERT INTO ArticleSMDownload(
			CustomerGuid,
			ArticleID,
			DownloadStatus,
			DownloadLocation)
	SELECT
			@CustomerGuid,
			XmlTbl.d.value('@ArticleID','varchar(50)') as ArticleID,
			CASE WHEN IQCore_SM.[Status] = 'Generated' THEN 2 ELSE 1 END,
			ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_SM.Location,'')
	FROM
			IQCore_SM
				INNER JOIN @XmlData.nodes('ArticleDownload/Article') as XmlTbl(d)
					ON IQCore_SM.ArticleID = XmlTbl.d.value('@ArticleID','varchar(50)')
				INNER JOIN IQcore_RootPath
					ON IQCore_SM._RootPathID = IQcore_RootPath.ID
	WHERE 
			XmlTbl.d.value('@ArticleID','varchar(50)') NOT IN
			(
				Select 
						DISTINCT ArticleID
				From
						ArticleSMDownload
				Where
						ArticleID = XmlTbl.d.value('@ArticleID','varchar(50)') AND 			
						CustomerGUID=@CustomerGuid AND						
						(DownloadStatus=1 OR DownloadStatus=2) AND
						IsActive=1
		)
END