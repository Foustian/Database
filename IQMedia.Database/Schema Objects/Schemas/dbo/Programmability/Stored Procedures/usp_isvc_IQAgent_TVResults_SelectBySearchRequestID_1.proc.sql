CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_TVResults_SelectBySearchRequestID]
	@ClientGuid			uniqueidentifier,
	@CustomerGuid		uniqueidentifier,
	@SearchRequestID	bigint,
	@SeqID				bigint,
	@PageSize			int,
	@TotalResults		bigint output,
	@MaxSinceID			bigint output
AS
BEGIN

	DECLARE @IsNielsenAccess bit

	SET @SeqID = CASE WHEN @SeqID IS NULL THEN 0 ELSE @SeqID END

	SELECT 
		@IsNielsenAccess = CASE WHEN  ClientRole.IsAccess = 1 AND CustomerRole.IsAccess = 1 THEN 1 ELSE 0 END
	FROM 
		[Role]
			INNER JOIN CustomerRole 
				on CustomerRole.RoleID = [Role].RoleKey
			INNER JOIN ClientRole
				ON ClientRole.RoleID = [Role].RoleKey
			   AND 	CustomerRole.RoleID =ClientRole.RoleID 
			 inner join Customer ON 
				Customer.CustomerKey = CustomerRole.CustomerID 
			 inner join Client ON
				Client.ClientKey = ClientRole.ClientID
				AND Customer.ClientID = Client.ClientKey
	WHERE
		Customer.CustomerGUID   = @CustomerGUID   
		AND Client.ClientGUID = @ClientGUID
		AND [Role].IsActive = 1 AND ClientRole.IsActive = 1 AND CustomerRole.IsActive = 1		
		AND Customer.IsActive =1 AND Client.IsActive = 1
		and RoleName ='NielsenData'

	SELECT 
			@TotalResults = COUNT(*),
			@MaxSinceID = MAX(IQAgent_MediaResults.ID)
	FROM
			IQAgent_MediaResults	
				INNER JOIN IQAgent_TVResults
					ON IQAgent_MediaResults._MediaID = IQAgent_TVResults.ID
					AND IQAgent_MediaResults.MediaType = 'TV'
				INNER JOIN IQAgent_SearchRequest
					ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID					
	WHERE
			IQAgent_MediaResults.IsActive = 1 
			AND IQAgent_TVResults.IsActive = 1
			AND IQAgent_SearchRequest.IsActive = 1
			AND IQAgent_SearchRequest.ClientGUID = @ClientGuid
			AND (@SearchRequestID IS NULL OR IQAgent_SearchRequest.ID = @SearchRequestID)
	
	SELECT top(@PageSize)
			IQAgent_MediaResults.ID as SeqID,
			IQAgent_MediaResults.Title as ProgramTitle,
			CONVERT(int,IQAgent_MediaResults.PositiveSentiment) as PositiveSentiment,
			CONVERT(int,IQAgent_MediaResults.NegativeSentiment) as NegativeSentiment,
			IQAgent_SearchRequest.ID as SRID,
			IQAgent_TVResults.GMTDatetime,
			IQAgent_TVResults.RL_VideoGUID as VideoGUID,
			(SElECT Station_Call_Sign FRoM IQ_Station Where IQ_Station_ID = IQAgent_TVResults.Rl_Station) as Station,
			CONVERT(datetime,CONVERT(varchar(Max),IQAgent_TVResults.RL_Date,101) + ' '+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),IQAgent_TVResults.RL_Time)/convert(decimal(5,2),100)))),'.',':')+':00') as MediaDateTime,
			ISNULL(Convert(nvarchar(max),CC_Highlight.query('HighlightedCCOutput/CC')),'') as HighLights,
			IQAgent_TVResults.RL_Market as DMAName,
			IQAgent_TVResults.Number_Hits as HitCount,
			CASE WHEN @IsNielsenAccess = 1 THEN IQAgent_TVResults.Nielsen_Audience ELSE NULL END as Audience,
			CASE WHEN @IsNielsenAccess = 1 THEN IQAgent_TVResults.IQAdShareValue ELSE NULL END as MediaValue,
			IQAgent_MediaResults._ParentID as ParentID,
			NULL as CC,
			NULL as StationLogo,
			NULL as URL
	FROM
			IQAgent_MediaResults	
				INNER JOIN IQAgent_TVResults
					ON IQAgent_MediaResults._MediaID = IQAgent_TVResults.ID
					AND IQAgent_MediaResults.MediaType = 'TV'
				INNER JOIN IQAgent_SearchRequest
					ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID					
	WHERE
			IQAgent_MediaResults.IsActive = 1 
			AND IQAgent_TVResults.IsActive = 1
			AND IQAgent_SearchRequest.IsActive = 1
			AND IQAgent_SearchRequest.ClientGUID = @ClientGuid
			AND (@SearchRequestID IS NULL OR IQAgent_SearchRequest.ID = @SearchRequestID)
			AND IQAgent_MediaResults.ID > @SeqID
	ORDER BY 
			IQAgent_MediaResults.ID asc
	
END