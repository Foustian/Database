CREATE PROCEDURE [dbo].[usp_v5_Dashboard_NMResults_Select]
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
			@SPName VARCHAR(100) ='usp_v5_Dashboard_NMResults_Select',
			@TimeDiff DECIMAL(18,2),
			@QueryDetail VARCHAR(500)

	DECLARE @NMResultsTbl TABLE (ID BIGINT, CompeteURL VARCHAR(255), NumHits BIGINT, MediaValue FLOAT, Audience BIGINT, PositiveSentiment INT, NegativeSentiment INT, _IQDmaID INT, State VARCHAR(100), CountryCode VARCHAR(2), SubMediaType VARCHAR(50))
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
			INSERT INTO @NMResultsTbl (ID, CompeteURL, NumHits, MediaValue, Audience, PositiveSentiment, NegativeSentiment, _IQDmaID, State, CountryCode, SubMediaType)
			SELECT
				IQAgent_NMResults.ID,
				CompeteURL,
				ISNULL(Number_Hits, 0),
				ISNULL(CASE WHEN IQAdShareValue > 0 THEN IQAdShareValue ELSE 0 END, 0),
				ISNULL(CASE WHEN Compete_Audience > 0 THEN Compete_Audience ELSE 0 END, 0),
				ISNULL(IQAgent_MediaResults.PositiveSentiment, 0),
				ISNULL(IQAgent_MediaResults.NegativeSentiment, 0),
				_IQDMAID,
				State,
				CountryCode,
				v5SubMediaType
			FROM
				IQAgent_NMResults WITH (NOLOCK)
					INNER JOIN IQAgent_MediaResults WITH (NOLOCK)
						ON IQAgent_MediaResults._MediaID = IQAgent_NMResults.ID
						AND IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediaType
						AND IQAgent_MediaResults.IsActive = 1
					INNER JOIN @MediaTypeAccessTbl AS MTA
						ON	IQAgent_NMResults.v5SubMediaType = MTA.SubMediaType
						AND	MTA.HasAccess = 1 
					INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
						ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
						AND IQAgent_SearchRequest.IsActive > 0
					INNER JOIN @SRIDTbl AS SRID
						ON IQAgent_SearchRequest.ID = SRID.ID
			WHERE
				((@FDate is null or @TDate is null) OR IQAgent_NMResults.harvest_time BETWEEN @FDate AND @TDate)
				AND IQAgent_NMResults.IsActive = 1	

			SET @QueryDetail ='populate temp results table with agent IDs'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()		

		END
	ELSE
		BEGIN
			INSERT INTO @NMResultsTbl (ID, CompeteURL, NumHits, MediaValue, Audience, PositiveSentiment, NegativeSentiment, _IQDmaID, State, CountryCode, SubMediaType)
			SELECT
				IQAgent_NMResults.ID,
				CompeteURL,
				ISNULL(Number_Hits, 0),
				ISNULL(CASE WHEN IQAdShareValue > 0 THEN IQAdShareValue ELSE 0 END, 0),
				ISNULL(CASE WHEN Compete_Audience > 0 THEN Compete_Audience ELSE 0 END, 0),
				ISNULL(IQAgent_MediaResults.PositiveSentiment, 0),
				ISNULL(IQAgent_MediaResults.NegativeSentiment, 0),
				_IQDMAID,
				State,
				CountryCode,
				v5SubMediaType
			FROM
				IQAgent_NMResults WITH (NOLOCK)
					INNER JOIN IQAgent_MediaResults WITH (NOLOCK)
						ON IQAgent_MediaResults._MediaID = IQAgent_NMResults.ID
						AND IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediaType
						AND IQAgent_MediaResults.IsActive = 1
					INNER JOIN @MediaTypeAccessTbl AS MTA
						ON	IQAgent_NMResults.v5SubMediaType = MTA.SubMediaType
						AND	MTA.HasAccess = 1 
					INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
						ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
						AND IQAgent_SearchRequest.IsActive > 0
			WHERE
				((@FDate is null or @TDate is null) OR IQAgent_NMResults.harvest_time BETWEEN @FDate AND @TDate)
				AND IQAgent_NMResults.IsActive = 1	

			SET @QueryDetail ='populate temp results table w/out agent IDs'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()

		END

		SELECT top 10 
			CompeteURL,
			count(ID) as NoOfDocs,
			sum(NumHits) as Mentions,
			sum(MediaValue) as MediaValue,
			sum(Audience) as Audience,
			sum(PositiveSentiment) as PositiveSentiment,
			sum(NegativeSentiment) as NegativeSentiment,
			MAX(SubMediaType) AS SubMediaType
		FROM 
			@NMResultsTbl

		GROUP BY 
			CompeteURL
		ORDER BY sum(CONVERT(BIGINT,NumHits)) desc,count(ID) desc

		SET @QueryDetail ='get top outlet for nm'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()

		SELECT top 10 
			CASE WHEN (MAX(IQ_Dma_Num) IS NULL OR  MAX(IQ_Dma_Num) = '999') THEN 'Other' ELSE MAX(IQ_Dma_Num) END as DMA_Num,
			CASE WHEN (MAX(IQ_DMA_Name) IS NULL OR MAX(IQ_DMA_Name) = 'Unknown') THEN 'Global' ELSE MAX(IQ_DMA_Name) END as DMA_Name,
			_IQDmaID,
			count(NMResultsTbl.ID) as NoOfDocs,
			sum(NumHits) as Mentions,
			sum(MediaValue) as MediaValue,
			sum(Audience) as Audience,
			sum(PositiveSentiment) as PositiveSentiment,
			sum(NegativeSentiment) as NegativeSentiment,
			MAX(SubMediaType) AS SubMediaType
		FROM 
			@NMResultsTbl NMResultsTbl
				LEFT OUTER JOIN IQDMA WITH (NOLOCK)
					ON NMResultsTbl._IQDmaID = IQDMA.ID

		GROUP BY 
			_IQDmaID
		ORDER BY ISNULL(sum(CONVERT(BIGINT,NumHits)),0) desc,count(NMResultsTbl.ID) desc

		SET @QueryDetail ='get top dma for nm'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()

		SELECT 
			CASE WHEN (IQ_Dma_Num IS NULL OR  IQ_Dma_Num = '999') THEN 'Other' ELSE IQ_Dma_Num END as DMA_Num,
			CASE WHEN (IQ_DMA_Name IS NULL OR IQ_DMA_Name = 'Unknown') THEN 'Global' ELSE IQ_DMA_Name END as DMA_Name,
			ISNULL(sum(CONVERT(BIGINT,NumHits)),0) as Mentions
		FROM 
			@NMResultsTbl NMResultsTbl
				LEFT OUTER JOIN IQDMA WITH (NOLOCK)
					ON NMResultsTbl._IQDmaID = IQDMA.ID

		GROUP BY 
			IQ_Dma_Num,IQ_DMA_Name

		SET @QueryDetail ='get all dma summary'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()

		SELECT
			State as Province,
			ISNULL(sum(CONVERT(BIGINT,NumHits)),0) as Mentions
		FROM 
			@NMResultsTbl
		WHERE
			CountryCode = 'CA'
						
		GROUP BY 
			State

		SET @QueryDetail ='get all canada dma summary'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()		

END