CREATE PROCEDURE [dbo].[usp_IQAgent_TwitterResults_SelectReportByDate]
	
	@ClientGuid uniqueidentifier,
	@IQAgentSearchRequestID bigint,
	@FromDate DateTime,
	@ToDate	  DateTime,
	@NoOfRecordsToDisplay int,
	@Query_Name varchar(100) OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Query nvarchar(max)

    SET @Query = 'SELECT ' + CASE WHEN ISNULL(@NoOfRecordsToDisplay,0) != 0 THEN 'top '+ CONVERT(Varchar(10),@NoOfRecordsToDisplay)  ELSE '' END  + '
				IQAgent_TwitterResults.ID,
				IQAgent_TwitterResults.actor_link,
				IQAgent_TwitterResults.actor_displayName,
				IQAgent_TwitterResults.[actor_preferredName],
				IQAgent_TwitterResults.Summary,
				IQAgent_TwitterResults.gnip_Klout_score,
				IQAgent_TwitterResults.actor_followerscount,
				IQAgent_TwitterResults.actor_friendscount,
				IQAgent_TwitterResults.tweet_postedDateTime,
				IQAgent_TwitterResults.actor_image,
				IQAgent_TwitterResults.tweetid	
	FROM
			IQAgent_TwitterResults
				INNER JOIN IQAgent_SearchRequest
					ON IQAgent_TwitterResults.IQAgentSearchRequestID =  IQAgent_SearchRequest.ID
					INNER JOIN Client	
						ON IQAgent_SearchRequest.ClientGuid = Client.ClientGUID
	WHERE
			 
			IQAgent_TwitterResults.tweet_posteddatetime Between ''' + CONVERT(Varchar(20),@FromDate) + ''' AND ''' + CONVERT(Varchar(20),@ToDate) + ''' 
			AND IQAgent_TwitterResults.IQAgentSearchRequestID = ' + CONVERT(Varchar(10),@IQAgentSearchRequestID) + '
			AND Client.ClientGUID = ''' + CONVERT(Varchar(40),@ClientGuid) + '''
			AND IQAgent_TwitterResults.IsActive = 1
			AND IQAgent_SearchRequest.IsActive = 1
	ORDER BY 
			IQAgent_TwitterResults.tweet_postedDateTime desc'

	print @Query

	exec sp_executesql @Query 

	SELECT @Query_Name = IQAgent_SearchRequest.Query_Name From IQAgent_SearchRequest Where IQAgent_SearchRequest.ID = @IQAgentSearchRequestID;
    
END
