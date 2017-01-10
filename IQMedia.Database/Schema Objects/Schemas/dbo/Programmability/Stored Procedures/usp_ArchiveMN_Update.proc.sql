-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- EXEC [dbo].[usp_CustomCategory_Update] 20,'a','aaaaaaaaaaaaaaaaa'

CREATE PROCEDURE [dbo].[usp_ArchiveMN_Update]
	
	@ArchiveNMKey	bigint,
	@Title			VARCHAR(255),
	@CategoryGUID uniqueidentifier,
	@SubCategory1GUID uniqueidentifier,
	@SubCategory2GUID uniqueidentifier,
	@SubCategory3GUID uniqueidentifier,
	@Keywords		  varchar(MAX),
	@Description	  varchar(MAX),
	@Rating		tinyint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;


	UPDATE ArchiveNM
			SET
				Title = @Title,
				CategoryGUID = @CategoryGUID,
				SubCategory1GUID = @SubCategory1GUID,
				SubCategory2GUID = @SubCategory2GUID,
				SubCategory3GUID = @SubCategory3GUID,
				[Keywords] = @Keywords,
				[Description] = @Description  ,
				Rating = @Rating
			WHERE
				ArchiveNMKey = @ArchiveNMKey
END

