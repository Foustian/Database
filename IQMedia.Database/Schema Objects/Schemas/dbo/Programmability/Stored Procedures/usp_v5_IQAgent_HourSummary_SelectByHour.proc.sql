CREATE PROCEDURE [dbo].[usp_v5_IQAgent_HourSummary_SelectByHour]
(  
 @ClientGUID  uniqueidentifier,  
 @FromDate   datetime,  
 @ToDate    datetime,  
 @Medium  varchar(20),  
 @SearchRequestIDXml xml,
 @MediaTypeAccessXml xml
)  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
  
 DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)  
   
 Set @SPStartTime=GetDate()  
 Set @Stopwatch=GetDate()  
 SET @SPTrackingID = NEWID()  
 SET @SPName ='usp_v5_IQAgent_HourSummary_SelectByHour'     

 DECLARE @MediaTypeAccessTbl TABLE(SubMediaType VARCHAR(50), HasAccess BIT)
 DECLARE @SRIDTbl TABLE(ID BIGINT)
 DECLARE	@HasMediaTypeAccess BIT=0

 DECLARE @SRIDCount INT=0

 INSERT INTO @MediaTypeAccessTbl
 (
	SubMediaType,
	HasAccess
 )
 SELECT
	MT.A.value('@SubMediaType','VARCHAR(50)'),
	MT.A.value('@HasAccess','BIT')
 FROM
		@MediaTypeAccessXml.nodes('list/item') AS MT(A)
 WHERE
			MT.A.value('@TypeLevel','INT') = 2

INSERT INTO @SRIDTbl
(
	ID
)
SELECT
		Search.req.value('@id','BIGINT') 
FROM
		@SearchRequestIDXml.nodes('list/item') as Search(req)  

IF (@Medium IS NOT NULL)
		BEGIN
			SELECT
					@HasMediaTypeAccess = MT.A.value('@HasAccess','BIT')
			FROM
					@MediaTypeAccessXml.nodes('list/item') AS MT(A)
			WHERE
					MT.A.value('@TypeLevel','INT') = 1
				AND	MT.A.value('@MediaType','VARCHAR(2)') = @Medium
		END
  
SELECT
		@SRIDCount = COUNT(*)
FROM
		@SRIDTbl AS SRID

 IF(@SRIDCount > 0)  
 BEGIN  
  SELECT  
    IQAgent_HourSummary.ClientGuid,  
    HourDateTime AS 'DayDate',  
	MediaType,
	IQAgent_HourSummary.SubMediaType,
    IQAgent_SearchRequest.ID,  
    IQAgent_SearchRequest.Query_Name,  
       Sum(Cast(NoOfDocs as bigint)) as 'NoOfDocs',  
       Sum(Cast(NoOfHits as bigint)) as 'NoOfHits',  
    Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',  
    Sum(CASE WHEN IQMediaValue > 0 THEN IQMediaValue ELSE 0 END) as 'IQMediaValue',  
    Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',  
    Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment'  
  FROM  
    IQAgent_SearchRequest WITH (NOLOCK)  
     INNER JOIN @SRIDTbl AS SRID
      ON IQAgent_SearchRequest.ID = SRID.ID
      AND IQAgent_SearchRequest.IsActive > 0
     INNER JOIN IQAgent_HourSummary WITH (NOLOCK)  
		ON IQAgent_HourSummary._SearchRequestID = IQAgent_SearchRequest.ID  
		AND	IQAgent_HourSummary.ClientGuid=@ClientGUID    
		AND	((@FromDate is null or @ToDate is null) OR IQAgent_HourSummary.HourDateTime  BETWEEN @FromDate AND @ToDate)    
		AND	(@Medium is Null or (MediaType = @Medium AND @HasMediaTypeAccess = 1))
	INNER JOIN @MediaTypeAccessTbl AS MTA
		ON IQAgent_HourSummary.SubMediaType = MTA.SubMediaType
		AND MTA.HasAccess = 1
   
  Group By   
    HourDateTime,IQAgent_HourSummary.ClientGuid,IQAgent_SearchRequest.ID,IQAgent_SearchRequest.Query_Name,MediaType, IQAgent_HourSummary.SubMediaType
    
  
  SET @QueryDetail ='get all hour summary'  
  SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
  INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
  SET @Stopwatch = GetDate()   
 END  
 ELSE  
 BEGIN  
  SELECT  
    IQAgent_HourSummary.ClientGuid,  
    HourDateTime AS 'DayDate',  
	MediaType,
	IQAgent_HourSummary.SubMediaType,
       Sum(Cast(NoOfDocs as bigint)) as 'NoOfDocs',  
       Sum(Cast(NoOfHits as bigint)) as 'NoOfHits',  
    Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',  
    Sum(CASE WHEN IQMediaValue > 0 THEN IQMediaValue ELSE 0 END) as 'IQMediaValue',  
    Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',  
    Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment'  
  FROM  
    IQAgent_HourSummary WITH (NOLOCK)  
     INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
      ON IQAgent_HourSummary._SearchRequestID = IQAgent_SearchRequest.ID  
      AND IQAgent_SearchRequest.IsActive > 0
	INNER JOIN @MediaTypeAccessTbl AS MTA
		ON IQAgent_HourSummary.SubMediaType = MTA.SubMediaType
		AND MTA.HasAccess = 1
  Where  
    (IQAgent_HourSummary.ClientGuid=@ClientGUID)  
  AND  ((@FromDate is null or @ToDate is null) OR IQAgent_HourSummary.HourDateTime  BETWEEN @FromDate AND @ToDate)    
  AND  (@Medium is Null or (MediaType = @Medium AND @HasMediaTypeAccess = 1))
   
  Group By   
    HourDateTime,IQAgent_HourSummary.ClientGuid,MediaType,IQAgent_HourSummary.SubMediaType
  
  SET @QueryDetail ='get all hour summary'  
  SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
  INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
  SET @Stopwatch = GetDate()   
 END  
 
 DECLARE @DayDifference  int   
 SET @DayDifference  = DATEDIFF(HOUR,@FromDate,@ToDate) + 1  
  
 DECLARE @FromDatePrev datetime  
 DECLARE @ToDatePrev datetime  
  
 SET @FromDatePrev = DATEADD(HOUR,-@DayDifference,@FromDate)  
 SET @ToDatePrev = DATEADD(HOUR,-@DayDifference,@ToDate)  
  
 if(@Medium IS NOT NULL AND @HasMediaTypeAccess = 1)  
 BEGIN  
  IF(@SRIDCount > 0 AND   
      EXISTS(  
       SELECT top 1 IQAgent_SearchRequest.ID FROM   
        IQAgent_SearchRequest  WITH (NOLOCK)  
         INNER JOIN @SRIDTbl AS SRID  
          ON IQAgent_SearchRequest.ID = SRID.ID
          AND IQAgent_SearchRequest.IsActive > 0
        Where   
         (  
          IQAgent_SearchRequest.CreatedDate <= @FromDatePrev  
          OR (SELECT Min(HourDateTime) FROM IQAgent_HourSummary WITH (NOLOCK) WHERE _SearchRequestID = IQAgent_SearchRequest.ID and NoOfDocs > 0) <= @FromDatePrev   
         )  
       ))  
  BEGIN  
   SELECT  
    Sum(Cast(NoOfDocs as bigint)) as 'NoOfDocs',  
    Sum(Cast(NoOfHits as bigint)) as 'NoOfHits',       
	Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',  
    Sum(CASE WHEN IQMediaValue > 0 THEN IQMediaValue ELSE 0 END) as 'IQMediaValue',  
    Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',  
    Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment'  
   FROM  
    IQAgent_SearchRequest WITH (NOLOCK)  
     INNER JOIN @SRIDTbl AS SRID
      ON IQAgent_SearchRequest.ID = SRID.ID
      AND IQAgent_SearchRequest.IsActive > 0
     INNER JOIN IQAgent_HourSummary  
      ON IQAgent_HourSummary._SearchRequestID = IQAgent_SearchRequest.ID  
      AND IQAgent_HourSummary.ClientGuid=@ClientGUID    
	  AND ((@FromDatePrev is null or @ToDatePrev is null) OR IQAgent_HourSummary.HourDateTime  BETWEEN @FromDatePrev AND @ToDatePrev)       
	  AND  MediaType = @Medium
	INNER JOIN @MediaTypeAccessTbl as MTA
		ON IQAgent_HourSummary.SubMediaType = MTA.SubMediaType
		AND MTA.HasAccess = 1
  
   SET @QueryDetail ='get previous summary'  
   SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
   INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
   SET @Stopwatch = GetDate()  
  
  END  
  ELSE IF (@SRIDCount = 0  and EXISTS(SELECT top 1 ID FROM   
        IQAgent_SearchRequest  WITH (NOLOCK)  
        Where   
         (  
          IQAgent_SearchRequest.CreatedDate <= @FromDatePrev   
          OR (SELECT Min(HourDateTime) FROM IQAgent_HourSummary WITH (NOLOCK) WHERE _SearchRequestID = IQAgent_SearchRequest.ID and NoOfDocs > 0) <= @FromDatePrev   
         )  
         AND IQAgent_SearchRequest.IsActive > 0
         AND IQAgent_SearchRequest.ClientGUID = @ClientGUID))  
  BEGIN  
   SELECT  
    Sum(Cast(NoOfDocs as bigint)) as 'NoOfDocs',  
    Sum(Cast(NoOfHits as bigint)) as 'NoOfHits',      
	Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',  
    Sum(CASE WHEN IQMediaValue > 0 THEN IQMediaValue ELSE 0 END) as 'IQMediaValue',  
    Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',  
    Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment'  
   FROM  
    IQAgent_HourSummary WITH (NOLOCK)  
     INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
		ON	IQAgent_HourSummary._SearchRequestID = IQAgent_SearchRequest.ID  
		AND	IQAgent_HourSummary.ClientGuid=@ClientGUID  
		AND	IQAgent_SearchRequest.IsActive > 0
		AND	((@FromDatePrev is null or @ToDatePrev is null) OR IQAgent_HourSummary.HourDateTime  BETWEEN @FromDatePrev AND @ToDatePrev)       
		AND	MediaType = @Medium
	INNER JOIN @MediaTypeAccessTbl AS MTA
		ON IQAgent_HourSummary.SubMediaType = MTA.SubMediaType
		AND MTA.HasAccess = 1
  
   SET @QueryDetail ='get previous summary'  
   SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
   INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
   SET @Stopwatch = GetDate()  
  END  
 END  
 ELSE IF(@Medium IS NULL)  
 BEGIN  
  IF(@SRIDCount > 0 AND   
      EXISTS(  
       SELECT top 1 IQAgent_SearchRequest.ID FROM   
        IQAgent_SearchRequest  WITH (NOLOCK)  
         INNER JOIN @SRIDTbl SRID
          ON IQAgent_SearchRequest.ID = SRID.ID
          AND IQAgent_SearchRequest.IsActive > 0
        Where            
        (  
          IQAgent_SearchRequest.CreatedDate <= @FromDatePrev   
          OR (SELECT Min(HourDateTime) FROM IQAgent_HourSummary WITH (NOLOCK) WHERE _SearchRequestID = IQAgent_SearchRequest.ID and NoOfDocs > 0) <= @FromDatePrev   
         )  
       ))  
  BEGIN  
   SELECT * from   
   (  
    SELECT  
	 MediaType,
	 IQAgent_HourSummary.SubMediaType,
     Sum(Cast(NoOfDocs as bigint)) as 'NoOfDocs',  
     Sum(Cast(NoOfHits as bigint)) as 'NoOfHits',       
	 Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',  
	 Sum(CASE WHEN IQMediaValue > 0 THEN IQMediaValue ELSE 0 END) as 'IQMediaValue',  
     Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',  
     Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment'  
    FROM  
     IQAgent_SearchRequest WITH (NOLOCK)  
      INNER JOIN @SRIDTbl AS SRID
		ON	IQAgent_SearchRequest.ID = SRID.ID
        AND	IQAgent_SearchRequest.IsActive > 0
      INNER JOIN	IQAgent_HourSummary WITH (NOLOCK)  
       ON	IQAgent_HourSummary._SearchRequestID = IQAgent_SearchRequest.ID  
       AND	IQAgent_HourSummary.ClientGuid=@ClientGUID    
	   AND  ((@FromDatePrev is null or @ToDatePrev is null) OR IQAgent_HourSummary.HourDateTime  BETWEEN @FromDatePrev AND @ToDatePrev)      	   
	INNER JOIN @MediaTypeAccessTbl AS MTA
		ON IQAgent_HourSummary.SubMediaType = MTA.SubMediaType
		AND MTA.HasAccess = 1
    GROUP BY  
      IQAgent_HourSummary.ClientGuid,	
      MediaType,  
	  IQAgent_HourSummary.SubMediaType
    Union   
       
     SELECT  
     NULL as MediaType,  
     NULL as SubMediaType,  
     NULL as 'NoOfDocs',  
     NULL as 'NoOfHits',  
     NULL as 'Audience',  
     NULL 'IQMediaValue',  
     NULL as 'PositiveSentiment',  
     NULL as 'NegativeSentiment'  
     )  
     as A   
     Order by NoOfDocs desc  
  
   SET @QueryDetail ='get previous summary'  
   SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
   INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
   SET @Stopwatch = GetDate()  
  END  
  ELSE IF (@SRIDCount = 0  and EXISTS(SELECT top 1 ID FROM   
        IQAgent_SearchRequest  WITH (NOLOCK)  
        Where   
         (  
          IQAgent_SearchRequest.CreatedDate <= @FromDatePrev   
          OR (SELECT Min(HourDateTime) FROM IQAgent_HourSummary WITH (NOLOCK) WHERE _SearchRequestID = IQAgent_SearchRequest.ID and NoOfDocs > 0) <= @FromDatePrev   
         )  
         AND IQAgent_SearchRequest.IsActive > 0
         AND IQAgent_SearchRequest.ClientGUID = @ClientGUID))  
  BEGIN  
   select * from   
   (  
    SELECT  
	 MediaType,
	 IQAgent_HourSummary.SubMediaType,
     Sum(Cast(NoOfDocs as bigint)) as 'NoOfDocs',  
     Sum(Cast(NoOfHits as bigint)) as 'NoOfHits',       
	 Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',  
	 Sum(CASE WHEN IQMediaValue > 0 THEN IQMediaValue ELSE 0 END) as 'IQMediaValue',   
     Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',  
     Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment'  
    FROM  
     IQAgent_HourSummary WITH (NOLOCK)  
      INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
       ON IQAgent_HourSummary._SearchRequestID = IQAgent_SearchRequest.ID  
       AND IQAgent_HourSummary.ClientGuid=@ClientGUID  
       AND IQAgent_SearchRequest.IsActive > 0
	   AND	((@FromDatePrev is null or @ToDatePrev is null) OR IQAgent_HourSummary.HourDateTime  BETWEEN @FromDatePrev AND @ToDatePrev)      	   
	 INNER JOIN @MediaTypeAccessTbl AS MTA
		ON IQAgent_HourSummary.SubMediaType = MTA.SubMediaType
		AND MTA.HasAccess = 1
    GROUP BY  
      IQAgent_HourSummary.ClientGuid,
      MediaType,  
	  IQAgent_HourSummary.SubMediaType
   Union   
       
     SELECT  
     NULL as MediaType,  
     NULL as SubMediaType,  
     NULL as 'NoOfDocs',  
     NULL as 'NoOfHits',  
     NULL as 'Audience',  
     NULL 'IQMediaValue',  
     NULL as 'PositiveSentiment',  
     NULL as 'NegativeSentiment'  
     )  
     as A   
     Order by NoOfDocs desc  
  
   SET @QueryDetail ='get previous summary'  
   SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
   INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
   SET @Stopwatch = GetDate()  
  END  
 END  
  
 SET @QueryDetail ='0'  
 SET @TimeDiff = DateDiff(ms, @SPStartTime, GetDate())  
  INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  

END