CREATE PROCEDURE [dbo].[usp_ArticleNMDownload_InsertList]
	@CustomerGuid	uniqueidentifier,
	@XmlData		xml
AS
BEGIN
	
	INSERT INTO ArticleNMDownload(
			CustomerGuid,
			ArticleID,
			DownloadStatus,
			DownloadLocation)
	SELECT
			@CustomerGuid,
			XmlTbl.d.value('@ArticleID','varchar(50)') as ArticleID,
			CASE WHEN IQCore_NM.[Status] = 'Generated' THEN 2 ELSE 1 END,
			ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_NM.Location,'')
	FROM
			IQCore_NM
				INNER JOIN @XmlData.nodes('ArticleDownload/Article') as XmlTbl(d)
					ON IQCore_NM.ArticleID = XmlTbl.d.value('@ArticleID','varchar(50)')
				INNER JOIN IQcore_RootPath
					ON IQCore_NM._RootPathID = IQcore_RootPath.ID
	WHERE 
			XmlTbl.d.value('@ArticleID','varchar(50)') NOT IN
			(
				Select 
						DISTINCT ArticleID
				From
						ArticleNMDownload
				Where
						ArticleID = XmlTbl.d.value('@ArticleID','varchar(50)') AND 			
						CustomerGUID=@CustomerGuid AND						
						(DownloadStatus=1 OR DownloadStatus=2) AND
						IsActive=1
		)
END