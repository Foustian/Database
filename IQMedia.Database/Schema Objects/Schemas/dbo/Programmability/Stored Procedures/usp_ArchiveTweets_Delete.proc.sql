CREATE PROCEDURE [dbo].[usp_ArchiveTweets_Delete]
(
	@ArchiveTweetsKeys varchar(MAX)
)
AS
BEGIN

	DECLARE @Query as nvarchar(1000)
	
	SET @Query = 'UPDATE ArchiveTweets SET ArchiveTweets.IsActive = 0 WHERE ArchiveTweets_Key IN (' + @ArchiveTweetsKeys + ')'

	EXEC sp_executesql @Query
	
END