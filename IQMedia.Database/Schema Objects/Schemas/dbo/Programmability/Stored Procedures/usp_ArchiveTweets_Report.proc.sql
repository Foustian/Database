CREATE PROCEDURE [dbo].[usp_ArchiveTweets_Report]
	@ClientGuid uniqueidentifier,
	@TweetDate date
AS 
BEGIN
	SELECT 
			MAX(CustomCategory.CategoryName) as CategoryName,
			ArchiveTweets.CategoryGuid,
			COUNT(ArchiveTweets.ArchiveTweets_Key) As Total
	FROM
			ArchiveTweets 
				Inner JOIN CustomCategory
					ON ArchiveTweets.CategoryGuid = CustomCategory.CategoryGUID
	WHERE
			ArchiveTweets.ClientGuid = @ClientGuid
			AND CONVERT(Date,ArchiveTweets.CreatedDate) = @TweetDate
			AND ArchiveTweets.IsActive = 1
	GROUP BY 
			ArchiveTweets.CategoryGuid
	HAVING
			COUNT(ArchiveTweets.ArchiveTweets_Key) > 0
END