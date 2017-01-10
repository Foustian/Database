CREATE PROCEDURE [dbo].[usp_ArchiveBLPM_SelectByArchiveBLPMKey]
	@ArchiveBLPMKey bigint
AS
BEGIN
	
	SET NOCOUNT ON;
    
    SELECT
		ArchiveBLPMKey,
		Headline,
		[Description],
		[Keywords],		
		CategoryGUID,
		SubCategory1GUID,
		SubCategory2GUID,
		SubCategory3GUID,
		Rating
	
	FROM
		ArchiveBLPM
	WHERE
		ArchiveBLPM.ArchiveBLPMKey=@ArchiveBLPMKey and ArchiveBLPM.IsActive = 1
END