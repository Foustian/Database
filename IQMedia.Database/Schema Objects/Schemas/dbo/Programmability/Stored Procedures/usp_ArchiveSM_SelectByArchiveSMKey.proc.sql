CREATE PROCEDURE [dbo].[usp_ArchiveSM_SelectByArchiveSMKey]
	@ArchiveSMKey bigint
AS
BEGIN
	
	SET NOCOUNT ON;
    
    SELECT
		ArchiveSMKey,
		Title,
		[Keywords],
		[Description],
		CategoryGUID,
		SubCategory1GUID,
		SubCategory2GUID,
		SubCategory3GUID,
		Rating
	
	FROM
		ArchiveSM
	WHERE
		ArchiveSM.ArchiveSMKey=@ArchiveSMKey and ArchiveSM.IsActive = 1
END
