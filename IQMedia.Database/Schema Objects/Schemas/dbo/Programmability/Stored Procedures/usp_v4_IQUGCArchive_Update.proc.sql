-- =============================================
-- Author:		<Author,,Name>
-- Create date: 30 July 2013
-- Description:	Update UGC record
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQUGCArchive_Update]
	@IQUGCArchiveKey			BIGINT,
	@Title						VARCHAR(2048),
	@Keywords					VARCHAR(MAX),
	@CustomerGuid				UNIQUEIDENTIFIER,
	@CategoryGuid				UNIQUEIDENTIFIER,
	@SubCategory1Guid			UNIQUEIDENTIFIER,
	@SubCategory2Guid			UNIQUEIDENTIFIER,
	@SubCategory3Guid			UNIQUEIDENTIFIER,
	@Description				VARCHAR(MAX),
	@ClientGuid					UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE IQUGCArchive
	SET
		Title = @Title,
		Keywords = @Keywords,
		CustomerGUID = @CustomerGuid,
		CategoryGUID = @CategoryGuid,
		SubCategory1GUID = @SubCategory1Guid,
		SubCategory2GUID = @SubCategory2Guid,
		SubCategory3GUID = @SubCategory3Guid,
		[Description] = @Description,
		ModifiedDate = GETDATE()
	WHERE
		IQUGCArchiveKey = @IQUGCArchiveKey
	AND	ClientGUID = @ClientGuid
	AND	IsActive = 1

END
