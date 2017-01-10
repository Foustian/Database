-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description: Website ==> MyIQ Report
			--		This Will get data from ArchiveTweets table by Fromdate and Todate and CategoryGuid selected			
-- =============================================
CREATE PROCEDURE [dbo].[usp_Report_myiq_ArchiveTweets_SelectByDurationNCategory]
	@ClientGUID uniqueidentifier,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@FromDate		date,
	@ToDate		date,
	@CategoryGUID	uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON 
	
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
		''@'' + ArchiveTweets.Actor_PreferredUserName as ''Actor_PreferredUserName'',
		ArchiveTweets.CategoryGuid,
		CustomCategory.CategoryName
			
	FROM
			ArchiveTweets
			
			INNER JOIN CustomCategory 
			ON ArchiveTweets.CategoryGuid = CustomCategory.CategoryGUID
			
	WHERE
			ArchiveTweets.ClientGuid='''+CONVERT(varchar(40),@ClientGUID)+''''
			IF(@CategoryGUID IS NOT NULL)
				BEGIN
				SET @Query = @Query +  ' AND ArchiveTweets.CategoryGuid = '''+ CONVERT(varchar(40),@CategoryGUID) +''''
				END
			
			SET @Query = @Query + ' AND CONVERT(date,ArchiveTweets.CreatedDate) between CONVERT(date,'''+CONVERT(varchar(10),@FromDate) +''') and CONVERT(date,'''+CONVERT(varchar(10),@ToDate) +''')
			 AND ArchiveTweets.IsActive = 1
	)
		 SELECT * FROM TempArchiveTweets '
	
	print @Query 
	
	EXEC sp_executesql @Query
	
END
