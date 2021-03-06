CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectForceCategorySelection]
	@ClientGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT	TOP 1 [Value] as 'ForceCategorySelection'
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'ForceCategorySelection'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid Desc		
				  
END
