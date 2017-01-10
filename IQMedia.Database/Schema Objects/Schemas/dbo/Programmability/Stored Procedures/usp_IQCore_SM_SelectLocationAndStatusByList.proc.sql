CREATE PROCEDURE [dbo].[usp_IQCore_SM_SelectLocationAndStatusByList]
	@ArticleXml XML
AS
BEGIN
	SELECT
			IQCore_SM.ArticleID,
			IQCore_SM.[Status],
			ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_SM.Location,'') As DownloadLocation
	FROM
			IQCore_SM 
				INNER JOIN IQcore_RootPath
					ON IQCore_SM._RootPathID = IQcore_RootPath.ID
				INNER JOIN @ArticleXml.nodes('root/Article') elem(Article)
					ON IQCore_SM.ArticleID = elem.Article.value('@ArticleID','varchar(50)') 
END