CREATE PROCEDURE [dbo].[usp_IQCore_NM_SelectLocationAndStatusByList]
	@ArticleXml XML
AS
BEGIN
		SELECT
			IQCore_NM.ArticleID,
			IQCore_NM.[Status],
			ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_NM.Location,'') As DownloadLocation
	FROM
			IQCore_NM 
				INNER JOIN IQcore_RootPath
					ON IQCore_NM._RootPathID = IQcore_RootPath.ID
				INNER JOIN @ArticleXml.nodes('root/Article') elem(Article)
					ON IQCore_NM.ArticleID = elem.Article.value('@ArticleID','varchar(50)') 
END