-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveTweets_GetByArchiveTweets_Key]
	@ArchiveTweets_Key bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
    Select
		ArchiveTweets.ArchiveTweets_Key,
		ArchiveTweets.Title,
		ArchiveTweets.CategoryGuid,
		ArchiveTweets.SubCategory1Guid,
		ArchiveTweets.SubCategory2Guid,
		ArchiveTweets.SubCategory3Guid,
		ArchiveTweets.[Description],
		ArchiveTweets.Keywords,
		ArchiveTweets.Rating
		
	From
		ArchiveTweets
	Where ArchiveTweets_Key = @ArchiveTweets_Key
    
END