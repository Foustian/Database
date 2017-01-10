USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_MonthSummary]    Script Date: 10/25/2016 13:36:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_MonthSummary]
(
	@ClientGUID			uniqueidentifier,
	@Medium				varchar(15),
	@SearchRequestIDXml	xml
)	
AS
BEGIN
	DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)
 
	SET @SPStartTime=GetDate()
	SET @Stopwatch=GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v5_IQAgent_Analytics_MonthSummary'  

	CREATE TABLE #tempData 
	(
		DayDate date, 
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
			INSERT INTO #tempData (DayDate, SearchRequestID, ClientGuid, SubMediaType, Market, NoOfDocs, NoOfHits, Audience, MediaValue, PositiveSentiment, NegativeSentiment, SeenEarned, SeenPaid, HeardEarned, HeardPaid, AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus, AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus)
			SELECT
				DayDate, 
				_SearchRequestID, 
				_ClientGuid, 
				SubMediaType, 
				Market, 
				CtNumberOfDocs, 
				CtNumberOfHits, 
				CtTotalAudiences, 
				CtIQMediaValue, 
				CtPositiveSentiment, 
				CtNegativeSentiment, 
				CtSeen_Earned, 
				CtSeen_Paid, 
				CtHeard_Earned, 
				CtHeard_Paid, 
				CtAM18_20, CtAM21_24, CtAM25_34, CtAM35_49, CtAM50_54, CtAM55_64, CtAM65_Plus, 
				CtAF18_20, CtAF21_24, CtAF25_34, CtAF35_49, CtAF50_54, CtAF55_64, CtAF65_Plus
			FROM	IQMediaGroup.dbo.IQAgent_AnalyticsDaySummary WITH (NOLOCK)
			INNER	JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
					ON IQAgent_AnalyticsDaySummary._SearchRequestID = Search.req.value('@id', 'bigint')
			WHERE	IQAgent_AnalyticsDaySummary.DayDate BETWEEN Search.req.value('@fromDate', 'date') AND Search.req.value('@toDate', 'date')
					AND (@Medium IS NULL OR SubMediaType = @Medium)
	  END
	ELSE
	  BEGIN
		IF @Medium IS NULL OR @Medium != 'TV'
		BEGIN
			INSERT INTO #tempData 
			(
				DayDate, 
				SearchRequestID, 
				ClientGuid, 
				SubMediaType, 
				NoOfDocs, 
				NoOfHits, 
				Audience,
				MediaValue, 
				PositiveSentiment, 
				NegativeSentiment,
				ReadEarned
			)
			SELECT	DayDate, _SearchRequestID, ClientGuid, SubMediaType, NoOfDocsLD, NoOfHitsLD, AudienceLD, IQMediaValueLD, PositiveSentimentLD, NegativeSentimentLD, NoOfHitsLD
			FROM	IQMediaGroup.dbo.IQAgent_DaySummary WITH (NOLOCK)
			INNER	JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
					ON IQAgent_DaySummary._SearchRequestID = Search.req.value('@id', 'bigint')
			WHERE	IQAgent_DaySummary.DayDate BETWEEN Search.req.value('@fromDate', 'date') AND Search.req.value('@toDate', 'date')
					AND (SubMediaType != 'TV')
					AND (@Medium IS NULL OR SubMediaType = @Medium)
		END
	
		IF @Medium IS NULL OR @Medium = 'TV'
		  BEGIN
			INSERT INTO #tempData (DayDate, SearchRequestID, ClientGuid, SubMediaType, Market, NoOfDocs, NoOfHits, Audience, MediaValue, PositiveSentiment, NegativeSentiment, SeenEarned, SeenPaid, HeardEarned, HeardPaid, AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus, AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus)
			SELECT
				DayDate, 
				_SearchRequestID, 
				_ClientGuid, 
				'TV', 
				Market, 
				LtNumberOfDocs, 
				LtNumberOfHits, 
				LtTotalAudience, 
				LtIQAdShareValue, 
				LtPositiveSentiment, 
				LtNegativeSentiment, 
				LtSeen_Earned, 
				LtSeen_Paid, 
				LtHeard_Earned, 
				LtHeard_Paid, 
				LtAM18_20, LtAM21_24, LtAM25_34, LtAM35_49, LtAM50_54, LtAM55_64, LtAM65_Plus, 
				LtAF18_20, LtAF21_24, LtAF25_34, LtAF35_49, LtAF50_54, LtAF55_64, LtAF65_Plus
			FROM	IQMediaGroup.dbo.IQAgent_EarnedPaidDaySummary WITH (NOLOCK)
			INNER	JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
					ON IQAgent_EarnedPaidDaySummary._SearchRequestID = Search.req.value('@id', 'bigint')
			WHERE	IQAgent_EarnedPaidDaySummary.DayDate BETWEEN Search.req.value('@fromDate', 'date') AND Search.req.value('@toDate', 'date')

		END
	  END

	INSERT INTO #tempData
	SELECT
		Search.req.value('@fromDate', 'date'),
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

	SET @QueryDetail ='populate temp table from IQAgent_DaySummary and IQAgent_EarnedPaidDaySummary'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()	

	SELECT
		'OverallSummary' as TableType,
		tempData.ClientGuid,
		Max(DayDate) AS 'DayDate',
		IQAgent_SearchRequest.ID,
		IQAgent_SearchRequest.Query_Name,
		SubMediaType,
		tempData.Market AS 'Market',
		SUM(CASE WHEN NoOfDocs > 0 THEN CAST(NoOfDocs AS bigint) ELSE 0 END) AS 'NoOfDocs',
		SUM(CASE WHEN NoOfHits > 0 THEN CAST(NoOfHits AS bigint) ELSE 0 END) AS 'NoOfHits',
		Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',
		Sum(CASE WHEN MediaValue > 0 THEN MediaValue ELSE 0 END) as 'IQMediaValue',
		Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',
		Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment',
		Sum(Cast(ReadEarned as bigint)) as 'ReadEarned',
		Sum(Cast(SeenEarned as bigint)) as 'SeenEarned',
		Sum(Cast(SeenPaid as bigint)) as 'SeenPaid',
		Sum(Cast(HeardEarned as bigint)) as 'HeardEarned',
		Sum(Cast(HeardPaid as bigint)) as 'HeardPaid',
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
		IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
			INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
				ON IQAgent_SearchRequest.ID = Search.req.value('@id', 'bigint')
				AND IQAgent_SearchRequest.IsActive > 0
			LEFT OUTER JOIN #tempData tempData
				ON tempData.SearchRequestID = IQAgent_SearchRequest.ID
	GROUP BY
		DATEPART(YEAR, DayDate), DATEPART(MONTH, DayDate),tempData.ClientGuid,IQAgent_SearchRequest.ID,IQAgent_SearchRequest.Query_Name,SubMediaType,Market

	SET @QueryDetail ='get all day summary'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()	

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
			Province, IQAgent_SearchRequest.ID

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

