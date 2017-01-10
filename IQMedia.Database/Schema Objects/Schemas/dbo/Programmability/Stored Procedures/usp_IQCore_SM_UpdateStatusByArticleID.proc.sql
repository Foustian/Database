CREATE PROCEDURE [dbo].[usp_IQCore_SM_UpdateStatusByArticleID]
	@ArticleID		varchar(50)
AS
BEGIN

	UPDATE 
			IQCore_SM
	SET
			Status ='QUEUED'
	WHERE
			ArticleID = @ArticleID		
END