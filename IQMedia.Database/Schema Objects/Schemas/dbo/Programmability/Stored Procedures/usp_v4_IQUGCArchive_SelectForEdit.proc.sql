-- =============================================
-- Author:		<Author,,Name>
-- Create date: 29 July 2013
-- Description:	Edit IQUGCArchive record
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQUGCArchive_SelectForEdit]
	@ClientGuid			UNIQUEIDENTIFIER,
	@IQUGCArchiveKey	BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	EXEC [dbo].[usp_v4_Customer_SelectByClientGuid] @ClientGuid
	
	EXEC [dbo].[usp_V4_CustomCategory_SelectByClientGUID] @ClientGuid
	
	SELECT
			IQUGCArchiveKey,
			Title,
			CategoryGUID,
			SubCategory1GUID,
			SubCategory2GUID,
			SubCategory3GUID,
			Keywords,
			[Description],
			CustomerGUID
	
	FROM	IQUGCArchive 
	WHERE	IQUGCArchiveKey = @IQUGCArchiveKey
	AND		IsActive = 1

END