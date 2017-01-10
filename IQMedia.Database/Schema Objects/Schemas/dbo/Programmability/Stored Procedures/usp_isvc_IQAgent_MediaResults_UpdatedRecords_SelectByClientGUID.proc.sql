CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_MediaResults_UpdatedRecords_SelectByClientGUID]
(
	@ClientGUID	UNIQUEIDENTIFIER,
	@CustomerGUID UNIQUEIDENTIFIER,
	@SeqID	BIGINT,
	@PageSize	INT
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @TotalResults BIGINT, @MaxSinceID BIGINT
	
	SELECT 
			@TotalResults = COUNT(IQAgent_MediaResults_UpdatedRecords.ID),
			@MaxSinceID = MAX(IQAgent_MediaResults_UpdatedRecords.ID)
	FROM
			IQAgent_MediaResults_UpdatedRecords
				INNER JOIN IQAgent_MediaResults
					ON IQAgent_MediaResults_UpdatedRecords._MediaResultID=IQAgent_MediaResults.ID
				INNER JOIN IQAgent_SearchRequest
					ON IQAgent_MediaResults._SearchRequestID=IQAgent_SearchRequest.ID
					AND IQAgent_SearchRequest.ClientGUID=@ClientGUID
	WHERE
			IQAgent_MediaResults.IsActive = 1
		AND	IQAgent_SearchRequest.IsActive=1
	
	CREATE TABLE #tmpUpdatedIDs (ID	BIGINT, MediaResultID	BIGINT,MediaID BIGINT,Title VARCHAR(512), PositiveSentiment TINYINT,NegativeSentiment TINYINT, SRID BIGINT,ParentID BIGINT)
	
	INSERT INTO #tmpUpdatedIDs
	(
		ID,
		MediaResultID,
		MediaID,
		Title,
		PositiveSentiment,
		NegativeSentiment,
		SRID,
		ParentID
	)
	SELECT
		TOP(@PageSize)
		IQAgent_MediaResults_UpdatedRecords.ID,
		IQAgent_MediaResults_UpdatedRecords._MediaResultID,
		IQAgent_MediaResults._MediaID,
		IQAgent_MediaResults.Title,
		IQAgent_MediaResults.PositiveSentiment,
		IQAgent_MediaResults.NegativeSentiment,
		IQAgent_MediaResults._SearchRequestID,
		IQAgent_MediaResults._ParentID
	FROM
			IQAgent_MediaResults_UpdatedRecords
				INNER JOIN IQAgent_MediaResults
					ON IQAgent_MediaResults_UpdatedRecords._MediaResultID=IQAgent_MediaResults.ID
				INNER JOIN IQAgent_SearchRequest
					ON IQAgent_MediaResults._SearchRequestID=IQAgent_SearchRequest.ID
					AND IQAgent_SearchRequest.ClientGUID=@ClientGUID
	WHERE
			IQAgent_MediaResults.IsActive = 1
		AND	IQAgent_SearchRequest.IsActive=1
		AND (@SeqID IS NULL OR IQAgent_MediaResults_UpdatedRecords.ID > @SeqID)
	ORDER BY 
			IQAgent_MediaResults_UpdatedRecords.ID ASC

	DECLARE @IsNielsenAccess BIT
	  
	 SELECT   
			@IsNielsenAccess = CASE WHEN  ClientRole.IsAccess = 1 AND CustomerRole.IsAccess = 1 THEN 1 ELSE 0 END  
	 FROM   
			[ROLE]  
				INNER JOIN CustomerRole   
					ON CustomerRole.RoleID = [ROLE].RoleKey  
				INNER JOIN ClientRole  
					ON ClientRole.RoleID = [ROLE].RoleKey  
					 AND  CustomerRole.RoleID =ClientRole.RoleID   
				INNER JOIN Customer ON   
					Customer.CustomerKey = CustomerRole.CustomerID   
				INNER JOIN Client ON  
					Client.ClientKey = ClientRole.ClientID  
				AND Customer.ClientID = Client.ClientKey  
	 WHERE  
			 Customer.CustomerGUID   = @CustomerGUID     
		 AND Client.ClientGUID = @ClientGUID  
		 AND [ROLE].IsActive = 1 AND ClientRole.IsActive = 1 AND CustomerRole.IsActive = 1    
		 AND Customer.IsActive =1 AND Client.IsActive = 1  
						
		  
	 SELECT  
			UpdatedRecords.ID AS USeqID,
		   UpdatedRecords.MediaResultID AS SeqID,  
		   UpdatedRecords.Title AS ProgramTitle,  
		   UpdatedRecords.PositiveSentiment,  
		   UpdatedRecords.NegativeSentiment,  
		   UpdatedRecords.SRID,  
		   IQAgent_TVResults.GMTDatetime,  
		   IQAgent_TVResults.RL_VideoGUID AS VideoGUID,  
		   IQAgent_TVResults.RawMediaThumbUrl AS ThumbUrl,  
		   IQAgent_TVResults.Rl_Station AS StationID,  
		   (SELECT Station_Call_Sign FROM IQ_Station WHERE IQ_Station_ID = IQAgent_TVResults.Rl_Station) AS Station,   
		   IQAgent_TVResults.RL_Date,  
		   IQAgent_TVResults.RL_Time,  
		   CC_Highlight AS HighLights,  
		   IQAgent_TVResults.RL_Market AS DMAName,  
		   IQAgent_TVResults.Number_Hits AS HitCount,  
		   CASE WHEN @IsNielsenAccess = 1 THEN IQAgent_TVResults.Nielsen_Audience ELSE NULL END AS Audience,  
		   CASE WHEN @IsNielsenAccess = 1 THEN IQAgent_TVResults.IQAdShareValue ELSE NULL END AS MediaValue,  
		   UpdatedRecords.ParentID
	 FROM  
			#tmpUpdatedIDs AS UpdatedRecords
				INNER JOIN IQAgent_TVResults WITH(NOLOCK)  
					ON UpdatedRecords.MediaID = IQAgent_TVResults.ID  
					
	SELECT
		@TotalResults TotalResults,
			@MaxSinceID SinceID
	
END
