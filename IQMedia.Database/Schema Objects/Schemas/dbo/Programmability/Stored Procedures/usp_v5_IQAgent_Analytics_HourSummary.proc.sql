USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_HourSummary]    Script Date: 12/15/2016 10:45:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_HourSummary]
(
	@ClientGUID				uniqueidentifier,
	@Medium					varchar(15),
	@SearchRequestIDXml		xml,
	@LoadEverything     bit
)
AS
BEGIN
	DECLARE @StopWatch datetime,@SPStartTime datetime,@SPTrackingID uniqueidentifier,@TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)

	SET @SPStartTime = GETDATE()
	SET @StopWatch = GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName = 'usp_v5_IQAgent_Analytics_HourSummary'

	CREATE TABLE #tempData 
	(
		DayDate datetime, 
		GMTDateTime datetime,
		LocalDateTime datetime,
		SearchRequestID bigint, 
		ClientGuid uniqueidentifier, 
		SubMediaType varchar(20),
		Market varchar(50),
		NoOfDocs int, 
		NoOfHits bigint, 
		Audience bigint,	
		MediaValue decimal(18,2), 
		PositiveSentiment int, 
		NegativeSentiment int, 
		ReadEarned int, 
		SeenEarned int, 
		SeenPaid int, 
		HeardEarned int, 
		HeardPaid int, 
		AM18_20 bigint, AM21_24 bigint, AM25_34 bigint, AM35_49 bigint, AM50_54 bigint, AM55_64 bigint, AM65_Plus bigint, 
		AF18_20 bigint, AF21_24 bigint, AF25_34 bigint, AF35_49 bigint, AF50_54 bigint, AF55_64 bigint, AF65_Plus bigint
	)
	
	-- Use new table for IQ Media, Corbin-Hillman, and Entertainment Industry Foundation
	IF @ClientGUID IN ('7722A116-C3BC-40AE-8070-8C59EE9E3D2A', '1D0A3DD5-47B7-4316-B3AD-10C018CA503D', '36E623A5-FDD2-4FF6-802F-317D12B6415A')
	  BEGIN
			INSERT INTO #tempData 
			(
				GMTDateTime
				,LocalDateTime
				,SearchRequestID
				,ClientGuid
				,SubMediaType
				,Market
				,NoOfDocs
				,NoOfHits
				,Audience
				,MediaValue
				,PositiveSentiment
				,NegativeSentiment
				,SeenEarned
				,SeenPaid
				,HeardEarned
				,HeardPaid
				,AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus
				,AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus
			)
			SELECT	
				GMTHourDateTime
				,LocalHourDateTime
				,_SearchRequestID
				,_ClientGuid
				,SubMediaType
				,Market
				,NumberOfDocs
				,NumberOfHits
				,TotalAudiences
				,IQMediaValue
				,PositiveSentiment
				,NegativeSentiment
				,Seen_Earned + Seen_Inprogram
				,Seen_Paid
				,Heard_Earned + Heard_Inprogram
				,Heard_Paid
				,AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus
				,AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus
			FROM	IQMediaGroup.dbo.IQAgent_AnalyticsHourSummary WITH (NOLOCK)
			INNER	JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
					ON IQAgent_AnalyticsHourSummary._SearchRequestID = Search.req.value('@id', 'bigint')
			WHERE	GMTHourDateTime BETWEEN Search.req.value('@fromDateGMT', 'datetime') AND Search.req.value('@toDateGMT', 'datetime')	
					AND (@Medium IS NULL OR SubMediaType = @Medium)	
	  END
	ELSE
	  BEGIN
		IF @Medium IS NULL OR @Medium != 'TV'
		  BEGIN
			INSERT INTO #tempData 
			(
				DayDate
				,SearchRequestID
				,ClientGuid
				,SubMediaType
				,NoOfDocs
				,NoOfHits
				,Audience
				,MediaValue
				,PositiveSentiment
				,NegativeSentiment
				,ReadEarned
			)
			SELECT	
				HourDateTime
				,_SearchRequestID
				,ClientGuid
				,SubMediaType
				,NoOfDocs
				,NoOfHits
				,Audience
				,IQMediaValue
				,PositiveSentiment
				,NegativeSentiment
				,NoOfHits
			FROM	IQMediaGroup.dbo.IQAgent_HourSummary WITH (NOLOCK)
			INNER	JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
					ON IQAgent_HourSummary._SearchRequestID = Search.req.value('@id', 'bigint')
			WHERE	HourDateTime BETWEEN Search.req.value('@fromDateGMT', 'datetime') AND Search.req.value('@toDateGMT', 'datetime')
					AND (SubMediaType != 'TV')
					AND (@Medium IS NULL OR SubMediaType = @Medium)
		  END
	
		IF @Medium IS NULL OR @Medium = 'TV'
		  BEGIN
			INSERT INTO #tempData 
			(
				DayDate
				,SearchRequestID
				,ClientGuid
				,SubMediaType
				,Market
				,NoOfDocs
				,NoOfHits
				,Audience
				,MediaValue
				,PositiveSentiment
				,NegativeSentiment
				,SeenEarned
				,SeenPaid
				,HeardEarned
				,HeardPaid
				,AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus
				,AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus
			)
			SELECT	
				HourDateTime
				,_SearchRequestID
				,_ClientGuid
				,'TV'
				,Market
				,NumberOfDocs
				,NumberOfHits
				,TotalAudience
				,IQAdShareValue
				,PositiveSentiment
				,NegativeSentiment
				,Seen_Earned
				,Seen_Paid
				,Heard_Earned
				,Heard_Paid
				,AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus
				,AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus
			FROM	IQMediaGroup.dbo.IQAgent_EarnedPaidHourSummary WITH (NOLOCK)
			INNER	JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
					ON IQAgent_EarnedPaidHourSummary._SearchRequestID = Search.req.value('@id', 'bigint')
			WHERE	HourDateTime BETWEEN Search.req.value('@fromDateGMT', 'datetime') AND Search.req.value('@toDateGMT', 'datetime')
		  END
	  END

	INSERT INTO #tempData
	(
		DayDate
		,SearchRequestID
		,ClientGuid
		,SubMediaType
		,Market
		,NoOfDocs
		,NoOfHits
		,Audience
		,MediaValue
		,PositiveSentiment
		,NegativeSentiment
		,ReadEarned
		,SeenEarned
		,SeenPaid
		,HeardEarned
		,HeardPaid
		,AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus
		,AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus
	)
	SELECT
		Search.req.value('@fromDate', 'datetime'),
		SearchRequest.ID,
		@ClientGUID,
		@Medium,
		NULL,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0
	FROM @SearchRequestIDXml.nodes('list/item') AS Search(req)
		LEFT OUTER JOIN IQAgent_SearchRequest AS SearchRequest WITH (NOLOCK)
			ON SearchRequest.ID = Search.req.value('@id', 'bigint') AND SearchRequest.IsActive > 0

	SET @QueryDetail ='populate temp table from IQAgent_HourSummary and IQAgent_EarnedPaidHourSummary'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()

	SELECT
		'OverallSummary' AS TableType,
		tempData.ClientGuid,
		DayDate,
		GMTDateTime,
		LocalDateTime,
		SearchRequest.ID,
		Query_Name,
		SubMediaType,
		tempData.Market AS 'Market',
		SUM(CASE WHEN NoOfDocs > 0 THEN CAST(NoOfDocs AS bigint) ELSE 0 END) AS 'NoOfDocs',
		SUM(CASE WHEN NoOfHits > 0 THEN CAST(NoOfHits AS bigint) ELSE 0 END) AS 'NoOfHits',
		SUM(CASE WHEN Audience > 0 THEN CAST(Audience AS bigint) ELSE 0 END) AS 'Audience',
		SUM(CASE WHEN MediaValue > 0 THEN MediaValue ELSE 0 END) AS 'IQMediaValue',
		SUM(CAST(PositiveSentiment AS bigint)) AS 'PositiveSentiment',
		SUM(CAST(NegativeSentiment AS bigint)) AS 'NegativeSentiment',
		SUM(CAST(ReadEarned as bigint)) as 'ReadEarned',
		SUM(CAST(SeenEarned as bigint)) as 'SeenEarned',
		SUM(CAST(SeenPaid as bigint)) as 'SeenPaid',
		SUM(CAST(HeardEarned as bigint)) as 'HeardEarned',
		SUM(CAST(HeardPaid as bigint)) as 'HeardPaid',
		SUM(CAST(AM18_20 AS bigint)) AS 'AM18_20',
		SUM(CAST(AM21_24 AS bigint)) AS 'AM21_24',
		SUM(CAST(AM25_34 AS bigint)) AS 'AM25_34',
		SUM(CAST(AM35_49 AS bigint)) AS 'AM35_49',
		SUM(CAST(AM50_54 AS bigint)) AS 'AM50_54',
		SUM(CAST(AM55_64 AS bigint)) AS 'AM55_64',
		SUM(CAST(AM65_Plus AS bigint)) AS 'AM65_Plus',
		SUM(CAST(AF18_20 AS bigint)) AS 'AF18_20',
		SUM(CAST(AF21_24 AS bigint)) AS 'AF21_24',
		SUM(CAST(AF25_34 AS bigint)) AS 'AF25_34',
		SUM(CAST(AF35_49 AS bigint)) AS 'AF35_49',
		SUM(CAST(AF50_54 AS bigint)) AS 'AF50_54',
		SUM(CAST(AF55_64 AS bigint)) AS 'AF55_64',
		SUM(CAST(AF65_Plus AS bigint)) AS 'AF65_Plus'

	FROM
		IQMediaGroup.dbo.IQAgent_SearchRequest SearchRequest WITH (NOLOCK)
			INNER JOIN @SearchRequestIDXml.nodes('list/item') AS Search(req)
				ON SearchRequest.ID = Search.req.value('@id', 'bigint')
				AND SearchRequest.IsActive > 0
			LEFT OUTER JOIN #tempData tempData
				ON tempData.SearchRequestID = SearchRequest.ID

	GROUP BY
		DayDate
		,GMTDateTime
		,LocalDateTime
		,tempData.ClientGuid
		,SearchRequest.ID
		,SearchRequest.Query_Name
		,SubMediaType
		,tempData.Market

	IF @LoadEverything = 1
	BEGIN
		SET @QueryDetail = 'get all hour summary'
		SET @TimeDiff = DATEDIFF(ms, @StopWatch, GETDATE())
		INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @StopWatch = GETDATE()

		CREATE TABLE #tempMapData (MapType varchar(20), Name varchar(100), SearchRequestID bigint, Mentions bigint)

			INSERT INTO #tempMapData (MapType, Name, SearchRequestID, Mentions)
			SELECT
				'DMA', 
				DMA_Name,
				IQAgent_SearchRequest.ID,
				ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) + ISNULL(SUM(CONVERT(BIGINT,NumOfHits)),0)
			FROM 
				IQMediaGroup.dbo.IQ_Station WITH (NOLOCK)
					INNER JOIN IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK)
						ON IQAgent_TVResults.RL_STation = IQ_Station.IQ_STation_ID
					INNER JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
						ON IQAgent_TVResults.SearchRequestID = IQAgent_SearchRequest.ID
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
						AND IQAgent_SearchRequest.IsActive > 0
						AND IQAgent_TVResults.IsActive = 1
					INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req) 
						ON IQAgent_SearchRequest.ID = Search.req.value('@id','bigint')
						AND IQAgent_TVResults.GMTDatetime BETWEEN Search.req.value('@fromDateGMT', 'datetime') AND Search.req.value('@toDateGMT', 'datetime')
					LEFT OUTER JOIN IQMediaGroup.dbo.IQAgent_LRResults AS LRR WITH (NOLOCK)
						ON LRR.ID = IQAgent_TVResults._LRResultsID
			WHERE
				IQ_Station.Country_num = 1 -- Limit results to US
				AND (@Medium IS NULL OR IQAgent_TVResults.v5SubMediaType = @Medium)
			GROUP BY 
				IQ_Station.Dma_Name, IQAgent_SearchRequest.ID

			SET @QueryDetail ='populate temp table for TV dma summary'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()	
		
			INSERT INTO #tempMapData (MapType, Name, SearchRequestID, Mentions)
			SELECT 
				'Canada',
				Province,
				IQAgent_SearchRequest.ID,
				ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) + ISNULL(SUM(CONVERT(BIGINT,NumOfHits)),0)
			FROM 
				IQMediaGroup.dbo.IQ_DMAProvinceLookup
					INNER JOIN IQMediaGroup.dbo.IQ_Station WITH (NOLOCK)
						ON IQ_Station.Dma_Num = IQ_DMAProvinceLookup.DMA_Num
					INNER JOIN IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK)
						ON IQAgent_TVResults.RL_STation = IQ_Station.IQ_STation_ID
					INNER JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
						ON IQAgent_TVResults.SearchRequestID = IQAgent_SearchRequest.ID
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
						AND IQAgent_SearchRequest.IsActive > 0
						AND IQAgent_TVResults.IsActive = 1
					INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req) 
						ON IQAgent_SearchRequest.ID = Search.req.value('@id','bigint')
						AND IQAgent_TVResults.GMTDatetime BETWEEN Search.req.value('@fromDateGMT', 'datetime') AND Search.req.value('@toDateGMT', 'datetime')
					LEFT OUTER JOIN IQMediaGroup.dbo.IQAgent_LRResults AS LRR WITH (NOLOCK)
						ON LRR.ID = IQAgent_TVResults._LRResultsID
			WHERE
				IQ_Station.Country_num = 2 -- Limit results to Canada
				AND (@Medium IS NULL OR IQAgent_TVResults.v5SubMediaType = @Medium)
			GROUP BY 
				IQ_DMAProvinceLookup.Province, IQAgent_SearchRequest.ID

			SET @QueryDetail ='populate temp table for TV Canada summary'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()	

			INSERT INTO #tempMapData (MapType, Name, SearchRequestID, Mentions)
			SELECT
				'DMA',
				CASE WHEN (IQ_DMA_Name IS NULL OR IQ_DMA_Name = 'Unknown') THEN 'Global' ELSE IQ_DMA_Name END,
				IQAgent_SearchRequest.ID,
				ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions
			FROM 
				IQMediaGroup.dbo.IQAgent_NMResults WITH (NOLOCK)
					LEFT OUTER JOIN IQMediaGroup.dbo.IQDMA WITH (NOLOCK)
						ON IQAgent_NMResults._IQDmaID = IQDMA.ID
					INNER JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
						ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
						AND IQAgent_SearchRequest.IsActive > 0
						AND IQAgent_NMResults.IsActive = 1
					INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req) 
						ON IQAgent_SearchRequest.ID = Search.req.value('@id','bigint')
						AND IQAgent_NMResults.harvest_time BETWEEN Search.req.value('@fromDateGMT', 'datetime') AND Search.req.value('@toDateGMT', 'datetime')
			WHERE
				@Medium IS NULL OR IQAgent_NMResults.v5SubMediaType = @Medium
			GROUP BY 
				IQ_DMA_Name, IQAgent_SearchRequest.ID

			SET @QueryDetail ='populate temp table for NM dma summary'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()
		
			INSERT INTO #tempMapData (MapType, Name, SearchRequestID, Mentions)
			SELECT
				'Canada',
				State,
				IQAgent_SearchRequest.ID,
				ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0) as Mentions
			FROM 
				IQMediaGroup.dbo.IQAgent_NMResults WITH (NOLOCK)
					INNER JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
						ON IQAgent_NMResults.IQAgentSearchRequestID = IQAgent_SearchRequest.ID
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
						AND IQAgent_SearchRequest.IsActive > 0
						AND IQAgent_NMResults.IsActive = 1
					INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req) 
						ON IQAgent_SearchRequest.ID = Search.req.value('@id','bigint')
						AND IQAgent_NMResults.harvest_time BETWEEN Search.req.value('@fromDateGMT', 'datetime') AND Search.req.value('@toDateGMT', 'datetime')		
			WHERE
				IQAgent_NMResults.CountryCode = 'CA'
				AND (@Medium IS NULL OR IQAgent_NMResults.v5SubMediaType = @Medium)					
			GROUP BY 
				IQAgent_NMResults.State, IQAgent_SearchRequest.ID

			SET @QueryDetail ='populate temp table for NM Canada summary'
			SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GetDate()

		SELECT	'DMAMap' as TableType,
				Name as DMA_Name,
				SearchRequestID,
				SUM(Mentions) as Mentions
		FROM	 #tempMapData
		WHERE	MapType = 'DMA'
		GROUP	BY Name, SearchRequestID

		SELECT	'CanadaMap' as TableType,
				Name as Province,
				SearchRequestID,
				SUM(Mentions) as Mentions
		FROM	 #tempMapData
		WHERE	MapType = 'Canada'
		GROUP	BY Name, SearchRequestID
	END
END