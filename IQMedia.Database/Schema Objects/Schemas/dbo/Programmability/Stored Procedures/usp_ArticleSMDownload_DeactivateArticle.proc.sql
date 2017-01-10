CREATE PROCEDURE [dbo].[usp_ArticleSMDownload_DeactivateArticle]
	@ID			BIGINT
AS
BEGIN
	
	UPDATE 
			ArticleSMDownload
	SET
			IsActive=0
	WHERE
			ID=@ID
	
END