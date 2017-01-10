-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveBLPM_Update]
	
	@ArchiveBLPMKey	bigint,
	@Title			VARCHAR(255),
	@Description varchar(1000),
	@CategoryGUID uniqueidentifier,
	@SubCategory1GUID uniqueidentifier,
	@SubCategory2GUID uniqueidentifier,
	@SubCategory3GUID uniqueidentifier,
	@Keywords		  varchar(MAX),	
	@Rating		tinyint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;


	UPDATE ArchiveBLPM
			SET
				Headline = @Title,
				[Description]= @Description,
				CategoryGUID = @CategoryGUID,
				SubCategory1GUID = @SubCategory1GUID,
				SubCategory2GUID = @SubCategory2GUID,
				SubCategory3GUID = @SubCategory3GUID,
				[Keywords] = @Keywords,				
				Rating = @Rating
			WHERE
				ArchiveBLPMKey = @ArchiveBLPMKey
				
END