CREATE PROCEDURE [dbo].[usp_IQCore_NM_UpdateStatusByArticleID]
	@ArticleID		varchar(50)
AS
BEGIN

	UPDATE 
			IQCore_NM
	SET
			Status ='QUEUED'
	WHERE
			ArticleID = @ArticleID		
END