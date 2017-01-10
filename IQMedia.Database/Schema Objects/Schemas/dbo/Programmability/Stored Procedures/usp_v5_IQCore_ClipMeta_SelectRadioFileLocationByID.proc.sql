CREATE PROCEDURE [dbo].[usp_v5_IQCore_ClipMeta_SelectRadioFileLocationByID] 
	@ID	BIGINT,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ClipGuid AS UNIQUEIDENTIFIER

	SELECT @ClipGuid = ClipGuid
	FROM	IQMediaGroup.dbo.ArticleRadioDownload
	WHERE	ID = @ID
	AND CustomerGUID = @CustomerGuid
	
    SELECT Value as FileLocation FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipGuid
    AND	Field IN ('FileLocation','UGCFileLocation')
    
END