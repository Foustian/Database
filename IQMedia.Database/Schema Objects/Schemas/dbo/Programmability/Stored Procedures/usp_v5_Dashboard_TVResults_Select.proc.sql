CREATE PROCEDURE [dbo].[usp_v5_Dashboard_TVResults_Select]
(
	@ClientGUID			UNIQUEIDENTIFIER,
	@SearchRequestIDXml	XML,
	@FromDate			DATETIME,
	@ToDate				DATETIME,
	@MediaType			VARCHAR(50),
	@MediaTypeAccessXml xml
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SPStartTime DATETIME=GetDate(),
			@Stopwatch DATETIME=GetDate(),
			@SPTrackingID UNIQUEIDENTIFIER = NEWID(),
			@SPName VARCHAR(100) ='usp_v5_Dashboard_TVResults_Select',
			@TimeDiff DECIMAL(18,2),
			@QueryDetail VARCHAR(500)
			
	DECLARE @TVResultsTbl TABLE (ID BIGINT, Number_Hits BIGINT, IQAdShareValue FLOAT, Nielsen_Audience BIGINT, PositiveSentiment INT, NegativeSentiment INT, SubMediaType VARCHAR(50), 
									IQ_Station_ID VARCHAR(255), Country VARCHAR(50), Country_Num INT, Dma_Name VARCHAR(255), Dma_Num VARCHAR(255))
	DECLARE @MediaTypeAccessTbl TABLE(MediaType VARCHAR(50), SubMediaType VARCHAR(50), HasAccess BIT)

	INSERT INTO @MediaTypeAccessTbl
	 (
		MediaType,
		SubMediaType,
		HasAccess
	 )
	 SELECT
		MT.A.value('@MediaType','VARCHAR(50)'),
		MT.A.value('@SubMediaType','VARCHAR(50)'),
		MT.A.value('@HasAccess','BIT')
	 FROM
			@MediaTypeAccessXml.nodes('list/item') AS MT(A)
	 WHERE
			MT.A.value('@TypeLevel','INT') = 2	
			AND MT.A.value('@MediaType','VARCHAR(50)') = @MediaType

	DECLARE @SRIDTbl TABLE(ID BIGINT)
	DECLARE	@SRIDCount INT=0

	INSERT INTO @SRIDTbl
	(
		ID
	)
	SELECT
			Search.req.value('@id','BIGINT') 
	FROM
			@SearchRequestIDXml.nodes('list/item') as Search(req)  

	SELECT
			@SRIDCount = COUNT(*)
	FROM
			@SRIDTbl AS SRID

	Declare @FDate datetime=NULL,  
			@TDate datetime=NULL		
  
	IF(@FromDate is not null AND @ToDate is not null)  
		BEGIN  
		   Declare @IsDST bit,  
			 @gmt decimal(18,2),  
			 @dst decimal(18,2)  
     
		   Select  
			 @gmt=Client.gmt,  
			 @dst=Client.dst  
		   From  
			 Client  
		   Where  
			 ClientGUID=@ClientGUID  
   
		   SET @FDate=@FromDate  
		   SET @TDate=DATEADD(MINUTE,1439,Convert(datetime, @ToDate))  
     
		   Select @IsDST=dbo.fnIsDayLightSaving(@FDate);  
   
		   If(@IsDST=1)  
		   BEGIN  
			 Set @FDate=DATEADD(HOUR,-(@gmt),CONVERT(datetime,@FDate))  
			 Set @FDate=DATEADD(HOUR,-@dst,CONVERT(datetime, @FDate))  
		   END  
		   ELSE  
		   BEGIN  
			 Set @FDate=DATEADD(HOUR,-(@gmt),CONVERT(datetime, @FDate))  
		   END  
   
		   Select @IsDST=dbo.fnIsDayLightSaving(@TDate);  
   
		   If(@IsDST=1)  
		   BEGIN  
			 Set @TDate=DATEADD(HOUR,-(@gmt),@TDate)  
			 Set @TDate=DATEADD(HOUR,-@dst,@TDate)  
		   END  
		   ELSE  
		   BEGIN  
			 Set @TDate=DATEADD(HOUR,-(@gmt),@TDate)  
		   END  
		END 

	IF(@SRIDCount > 0)  
		BEGIN  
			INSERT INTO @TVResultsTbl (ID, Number_Hits, IQAdShareValue, Nielsen_Audience, PositiveSentiment, NegativeSentiment, SubMediaType, IQ_Station_ID, Country, Country_Num, Dma_Name, Dma_Num)
			SELECT
				IQAgent_TVResults.ID,
				ISNULL(IQAgent_TVResults.Number_Hits, 0),
				ISNULL(CASE WHEN IQAdShareValue > 0 THEN IQAdShareValue ELSE 0 END, 0),
				ISNULL(CASE WHEN Nielsen_Audience > 0 THEN Nielsen_Audience ELSE 0 END, 0),
				ISNULL(IQAgent_MediaResults.PositiveSentiment, 0),
				ISNULL(IQAgent_MediaResults.NegativeSentiment, 0),
				IQAgent_TVResults.v5SubMediatype,
				IQ_Station.IQ_Station_ID,
				IQ_Station.Country,
				IQ_Station.Country_num,
				IQ_Station.Dma_Name,
				IQ_Station.Dma_Num
			FROM
				IQAGENT_TVResults WITH(NOLOCK)
					INNER JOIN IQAgent_MediaResults WITH (NOLOCK)  
						ON	IQAgent_MediaResults._MediaID = IQAgent_TVResults.ID
						AND IQAgent_MediaResults.v5Category = IQAgent_TVResults.v5SubMediaType
						AND IQAgent_MediaResults.IsActive = 1
					INNER JOIN @MediaTypeAccessTbl AS MTA
						ON	IQAGENT_TVResults.v5SubMediaType = MTA.SubMediaType
						AND	MTA.HasAccess = 1 
					INNER JOIN IQ_Station WITH (NOLOCK)  
						ON IQAGENT_TVResults.RL_STation = IQ_Station.IQ_STation_ID  
					INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
						ON IQAGENT_TVResults.SearchRequestID = IQAgent_SearchRequest.ID  
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
						AND IQAgent_SearchRequest.IsActive > 0
					INNER JOIN @SRIDTbl AS SRID
						ON IQAgent_SearchRequest.ID = SRID.ID
			WHERE  
				((@FDate is null or @TDate is null) OR IQAGENT_TVResults.GMTDatetime BETWEEN @FDate AND @TDate)  
				AND IQAGENT_TVResults.IsActive = 1  

			SET @QueryDetail ='populate temp results table with agent IDs'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()

		END  
	ELSE  
		BEGIN  
			INSERT INTO @TVResultsTbl (ID, Number_Hits, IQAdShareValue, Nielsen_Audience, PositiveSentiment, NegativeSentiment, SubMediaType, IQ_Station_ID, Country, Country_Num, Dma_Name, Dma_Num)
			SELECT
				IQAgent_TVResults.ID,
				ISNULL(IQAgent_TVResults.Number_Hits, 0),
				ISNULL(CASE WHEN IQAdShareValue > 0 THEN IQAdShareValue ELSE 0 END, 0),
				ISNULL(CASE WHEN Nielsen_Audience > 0 THEN Nielsen_Audience ELSE 0 END, 0),
				ISNULL(IQAgent_MediaResults.PositiveSentiment, 0),
				ISNULL(IQAgent_MediaResults.NegativeSentiment, 0),
				IQAgent_TVResults.v5SubMediatype,
				IQ_Station.IQ_Station_ID,
				IQ_Station.Country,
				IQ_Station.Country_num,
				IQ_Station.Dma_Name,
				IQ_Station.Dma_Num
			FROM
				IQAGENT_TVResults WITH(NOLOCK)
					INNER JOIN IQAgent_MediaResults WITH (NOLOCK)  
						ON	IQAgent_MediaResults._MediaID = IQAgent_TVResults.ID
						AND IQAgent_MediaResults.v5Category = IQAgent_TVResults.v5SubMediaType
						AND IQAgent_MediaResults.IsActive = 1
					INNER JOIN @MediaTypeAccessTbl AS MTA
						ON	IQAGENT_TVResults.v5SubMediaType = MTA.SubMediaType
						AND	MTA.HasAccess = 1 
					INNER JOIN IQ_Station WITH (NOLOCK)  
						ON IQAGENT_TVResults.RL_STation = IQ_Station.IQ_STation_ID  
					INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)  
						ON IQAGENT_TVResults.SearchRequestID = IQAgent_SearchRequest.ID  
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID  
						AND IQAgent_SearchRequest.IsActive > 0
			WHERE  
				((@FDate is null or @TDate is null) OR IQAGENT_TVResults.GMTDatetime BETWEEN @FDate AND @TDate)  
				AND IQAGENT_TVResults.IsActive = 1  

			SET @QueryDetail ='populate temp results table w/out agent IDs'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()

		END  
			

	SELECT top 10   
		IQ_Station_ID,  
		MAX(Dma_Num) as DMA_Num,  
		MAX(DMA_Name) as DMA_Name,  
		count(ID) as NoOfDocs,  
		sum(Number_Hits) as Mentions,  
		sum(IQAdShareValue) as MediaValue,  
		sum(Nielsen_Audience) as Audience,  
		sum(PositiveSentiment) as PositiveSentiment,
		sum(NegativeSentiment) as NegativeSentiment,
		MAX(SubMediaType) AS SubMediaType
	FROM   
		@TVResultsTbl
	WHERE  
		Country_num = 1 -- Limit results to US
  
	GROUP BY   
		IQ_Station_ID  
	ORDER BY sum(Number_Hits) desc,count(ID) desc  
  
		SET @QueryDetail ='get top dma for tv'  
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
		SET @Stopwatch = GetDate()   
  
		SELECT top 10   
		DMA_Num as DMA_Num,  
		MAX(DMA_Name) as DMA_Name,  
		count(ID) as NoOfDocs,  
		sum(Number_Hits) as Mentions,  
		sum(IQAdShareValue) as MediaValue,  
		sum(Nielsen_Audience) as Audience,  
		sum(PositiveSentiment) as PositiveSentiment,
		sum(NegativeSentiment) as NegativeSentiment,
		MAX(SubMediaType) AS SubMediaType
	FROM   
		@TVResultsTbl
	WHERE  
		Country_num = 1 -- Limit results to US
        
	GROUP BY   
		DMA_Num  
	ORDER BY sum(Number_Hits) desc,count(ID) desc  
  
		SET @QueryDetail ='get top station for tv'  
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
		SET @Stopwatch = GetDate()   
  
		SELECT   
		Dma_Num ,  
		DMA_Name,  
		sum(Number_Hits) as Mentions
	FROM
		@TVResultsTbl
	WHERE  
		Country_num = 1 -- Limit results to US
  
	GROUP BY   
		Dma_Num,Dma_Name  
  
		SET @QueryDetail ='get all dma summary'  
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
		SET @Stopwatch = GetDate()       

		SELECT 
		Province,
		sum(Number_Hits) as Mentions
	FROM 
		@TVResultsTbl TVResultsTbl
			INNER JOIN IQ_DMAProvinceLookup			
				ON TVResultsTbl.Dma_Num = IQ_DMAProvinceLookup.DMA_Num
	WHERE
		Country_num = 2 -- Limit results to Canada

	GROUP BY 
		IQ_DMAProvinceLookup.Province

		SET @QueryDetail ='get all canada dma summary'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	

		SELECT top 10   
		Country_Num,
		Country,
		count(ID) as NoOfDocs,  
		sum(Number_Hits) as Mentions,   
		sum(PositiveSentiment) as PositiveSentiment,
		sum(NegativeSentiment) as NegativeSentiment,
		MAX(SubMediaType) AS SubMediaType
	FROM   
		@TVResultsTbl
	WHERE  
		Country_num <> 1 -- Exclude US

	GROUP BY   
		Country_Num,
		Country  
	ORDER BY ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) desc,count(ID) desc  
  
		SET @QueryDetail ='get top countries for tv'  
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())  
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)  
		SET @Stopwatch = GetDate() 
END