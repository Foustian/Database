CREATE PROCEDURE [dbo].[usp_IQCore_SM_SelectArticlePathByArticleID]
	@ArticleID varchar(50)
AS
BEGIN
	
	SELECT 
			ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_SM.Location,'') As ArticlePath
	FROM 
			IQCore_SM INNER JOIN IQcore_RootPath
				ON IQCore_SM._RootPathID = IQcore_RootPath.ID
			AND IQCore_SM.ArticleID = @ArticleID
END
