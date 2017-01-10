CREATE PROCEDURE [dbo].[usp_ArchiveSM_Update]
	@ArchiveSMKey		bigint,
	@Title				VARCHAR(255),
	@CategoryGUID		uniqueidentifier,
	@SubCategory1GUID	uniqueidentifier,
	@SubCategory2GUID	uniqueidentifier,
	@SubCategory3GUID	uniqueidentifier,
	@Keywords			varchar(MAX),
	@Description		varchar(MAX),
	@Rating				tinyint
AS
BEGIN
	SET NOCOUNT OFF;

	UPDATE ArchiveSM
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
				ArchiveSMKey = @ArchiveSMKey
END