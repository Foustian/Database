CREATE PROCEDURE [dbo].[usp_ArticleNMDownload_DeactivateArticle]
	@ID			BIGINT
AS
BEGIN
	
	UPDATE 
			ArticleNMDownload
	Set
			IsActive=0
	Where
			ID=@ID
	
END