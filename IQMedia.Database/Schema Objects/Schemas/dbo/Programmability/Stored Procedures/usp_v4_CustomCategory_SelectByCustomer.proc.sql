-- =============================================
-- Author:		<Author,,Name>
-- Create date: 16 July 2013
-- Description:	Select records by Customer
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_CustomCategory_SelectByCustomer]
	@ClientGuid	UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
			1 AS IsDefault,
			CategoryKey,
			CategoryName,
			CategoryDescription,
			CategoryGUID,
			CategoryRanking
	FROM	CustomCategory
	WHERE	ClientGuid = @ClientGuid
	AND		IsActive = 1
	AND		CategoryName = 'Default'
	
	UNION
	
	SELECT 
			0 AS IsDefault,
			CategoryKey,
			CategoryName,
			CategoryDescription,
			CategoryGUID,
			CategoryRanking
	FROM	CustomCategory
	WHERE	ClientGuid = @ClientGuid
	AND		IsActive = 1
	AND		CategoryName <> 'Default'
	
	ORDER BY IsDefault DESC,CategoryName

END
