CREATE PROCEDURE [dbo].[usp_ArchiveTweets_SelectByCategory]
	@ClientGUID		uniqueidentifier,
	@SortField		VARCHAR(250),
	@IsAscending	bit,
	@TweetDate		date,
	@CategoryGUID	uniqueidentifier
AS
BEGIN
	DECLARE @Query NVARCHAR(MAX)
	
	
	SET @Query = ' WITH TempArchiveTweets  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + 'Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL AND @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' ArchiveTweets.Tweet_PostedDateTime'
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
    
    SET @Query = @Query + 	') as RowNumber,
		
		ArchiveTweets.Title,
		ArchiveTweets.Actor_link,
		ArchiveTweets.Actor_DisplayName,
		ArchiveTweets.ArchiveTweets_Key,
		ArchiveTweets.Actor_FollowersCount,
		ArchiveTweets.Actor_FriendsCount,
		ArchiveTweets.Tweet_Body,
		ArchiveTweets.Actor_Image,
		ArchiveTweets.Tweet_PostedDateTime,
		ArchiveTweets.gnip_Klout_Score,
		''@'' + ArchiveTweets.Actor_PreferredUserName as ''Actor_PreferredUserName''
			
	FROM
			ArchiveTweets
	WHERE
			ArchiveTweets.ClientGuid='''+CONVERT(varchar(40),@ClientGUID)+'''
			ANd ArchiveTweets.CategoryGuid = '''+ CONVERT(varchar(40),@CategoryGUID) +'''
			AND CONVERT(date,ArchiveTweets.CreatedDate) = CONVERT(date,'''+CONVERT(varchar(10),@TweetDate) +''')
			AND ArchiveTweets.IsActive = 1
	)
		 SELECT * FROM TempArchiveTweets '
	
	print @Query 
	
	EXEC sp_executesql @Query
END