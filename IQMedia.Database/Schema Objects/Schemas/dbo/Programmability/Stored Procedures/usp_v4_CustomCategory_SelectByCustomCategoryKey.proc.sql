-- =============================================
-- Author:		<Author,,Name>
-- Create date: 16 July 2013
-- Description:	Select custom category by CustomCategoryKey
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_CustomCategory_SelectByCustomCategoryKey]
	@CustomCategoryKey	BIGINT,
	@ClientGuid			UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
			CategoryKey,
			CategoryName,
			CategoryDescription
	FROM	CustomCategory
	WHERE	CategoryKey = @CustomCategoryKey
	AND		ClientGuid = @ClientGuid
	AND		IsActive = 1

END