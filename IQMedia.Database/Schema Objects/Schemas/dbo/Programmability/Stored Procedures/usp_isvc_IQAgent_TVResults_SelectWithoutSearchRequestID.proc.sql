CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_TVResults_SelectWithoutSearchRequestID]   
(  
 @ClientGuid   UNIQUEIDENTIFIER,   
 @SeqID    BIGINT,  
 @PageSize   INT,  
 @IsNielsenAccess BIT  
)  
AS  
BEGIN   
 SET NOCOUNT ON;  
  
    DECLARE @TotalResults BIGINT, @MaxSinceID BIGINT  
   
 SELECT   
   @TotalResults = COUNT(IQAgent_MediaResults.ID),  
   @MaxSinceID = MAX(IQAgent_MediaResults.ID)  
 FROM  
   IQAgent_MediaResults WITH(NOLOCK)       
    INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)  
     ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID       
     AND IQAgent_MediaResults.MediaType = 'TV'  
 WHERE  
   IQAgent_MediaResults.IsActive = 1   
   AND IQAgent_SearchRequest.IsActive > 0
   AND IQAgent_SearchRequest.ClientGUID = @ClientGuid  
     
 SELECT TOP(@PageSize)  
   IQAgent_MediaResults.ID AS SeqID,  
   IQAgent_MediaResults.Title AS ProgramTitle,  
   IQAgent_MediaResults.PositiveSentiment,  
   IQAgent_MediaResults.NegativeSentiment,  
   IQAgent_SearchRequest.ID AS SRID,  
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
   IQAgent_MediaResults._ParentID AS ParentID  
 FROM  
   IQAgent_MediaResults WITH(NOLOCK)   
    INNER JOIN IQAgent_TVResults WITH(NOLOCK)  
     ON IQAgent_MediaResults._MediaID = IQAgent_TVResults.ID  
     AND IQAgent_MediaResults.MediaType = 'TV'  
    INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)  
     ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID               
 WHERE  
   IQAgent_MediaResults.IsActive = 1   
   AND IQAgent_TVResults.IsActive = 1  
   AND IQAgent_SearchRequest.IsActive > 0
   AND IQAgent_SearchRequest.ClientGUID = @ClientGuid  
   AND (IQAgent_MediaResults.ID > @SeqID)  
 ORDER BY   
   IQAgent_MediaResults.ID ASC  
     
 SELECT @TotalResults AS TotalResults, @MaxSinceID AS SinceID  
      
END  