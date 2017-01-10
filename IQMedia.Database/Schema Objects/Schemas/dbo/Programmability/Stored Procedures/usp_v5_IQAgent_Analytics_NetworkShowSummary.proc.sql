USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_NetworkShowSummary]    Script Date: 12/8/2016 11:49:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_NetworkShowSummary]
(
	@ClientGUID			uniqueidentifier,
	@Medium				varchar(15),
	@Tab				varchar(50),
	@DateInterval		varchar(50),
	@TopTen				xml,
	@SearchRequestIDXml	xml
)	
AS
BEGIN
	DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)
 
	SET @SPStartTime=GetDate()
	SET @Stopwatch=GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v5_IQAgent_Analytics_NetworkShowSummary'  

	CREATE TABLE #tempData 
	(
		DayDate datetime, 
		SearchRequestID bigint, 
		SubMediaType varchar(20), 
		Category varchar(150),
		NoOfDocs int, 
		NoOfHits bigint, 
		Audience bigint, 
		MediaValue decimal(18,2), 
		PositiveSentiment int, 
		NegativeSentiment int,
		SeenEarned int,
		SeenPaid int,
		HeardEarned int,
		HeardPaid int,
		ThumbUrl varchar(255),
		Market varchar(150),
		AM18_20 bigint, AM21_24 bigint, AM25_34 bigint, AM35_49 bigint, AM50_54 bigint, AM55_64 bigint, AM65_Plus bigint, 
		AF18_20 bigint, AF21_24 bigint, AF25_34 bigint, AF35_49 bigint, AF50_54 bigint, AF55_64 bigint, AF65_Plus bigint
	)


	DECLARE @Query NVARCHAR(MAX) 
	DECLARE @InsertQueryAdd VARCHAR(MAX) 
	DECLARE @SelectQueryAdd VARCHAR(MAX) 
	DECLARE @FromQueryAdd VARCHAR(MAX) 
	DECLARE @WhereQueryAdd VARCHAR(MAX) 

	CREATE TABLE #TopTenTable 
   ( 
	   ID varchar(50)
   )
    INSERT INTO #TopTenTable ( ID )
    SELECT TopNodes.req.value('@id', 'varchar(50)') from @TopTen.nodes('list/item') as TopNodes(req)

	CREATE TABLE #SearchRequestIDTable 
	( 
		ID varchar(50),
		FromDate datetime,
		ToDate datetime
	)

	IF @DateInterval = 'day' OR @DateInterval = 'month'
		BEGIN
			INSERT INTO #SearchRequestIDTable ( ID, FromDate, ToDate )
			SELECT Search.req.value('@id', 'bigint'), CAST(Search.req.value('@fromDate', 'date') AS datetime), CAST(Search.req.value('@toDate', 'date') AS datetime) from @SearchRequestIDXml.nodes('list/item') as Search(req)

			IF @Tab = 'Networks'
				BEGIN
					SET @InsertQueryAdd = ', Category, DayDate'
					SET @SelectQueryAdd = ', Station_Affil, TVR.RL_Date'
					SET @FromQueryAdd = ' INNER JOIN IQMediaGroup.dbo.IQ_Station WITH (NOLOCK) ON Rl_Station = IQ_Station_ID 
										  INNER JOIN #TopTenTable AS TempTable ON TempTable.ID = IQ_Station.Station_Affil'
					SET @WhereQueryAdd = ' WHERE TVR.GMTDatetime BETWEEN SearchRequestTable.FromDate AND SearchRequestTable.ToDate'
				END
			IF @Tab = 'Shows'
				BEGIN
					SET @InsertQueryAdd = ', Category, DayDate'
					SET @SelectQueryAdd = ', TVR.Title120, TVR.RL_Date'
					SET @FromQueryAdd = ' INNER JOIN #TopTenTable AS TempTable ON TempTable.ID = TVR.Title120'
					SET @WhereQueryAdd = ' WHERE TVR.GMTDatetime BETWEEN SearchRequestTable.FromDate AND SearchRequestTable.ToDate'
				END
			IF @Tab = 'Stations'
				BEGIN
					SET @InsertQueryAdd = ', Category, DayDate'
					SET @SelectQueryAdd = ', Rl_Station, TVR.RL_Date'
					SET @FromQueryAdd = ' INNER JOIN #TopTenTable AS TempTable ON TempTable.ID = Rl_Station'
					SET @WhereQueryAdd = ' WHERE TVR.GMTDatetime BETWEEN SearchRequestTable.FromDate AND SearchRequestTable.ToDate'
				END
		END
	IF @DateInterval = 'hour'
		BEGIN
			INSERT INTO #SearchRequestIDTable ( ID, FromDate, ToDate )
			SELECT Search.req.value('@id', 'bigint'), Search.req.value('@fromDateGMT', 'datetime'), Search.req.value('@toDateGMT', 'datetime') from @SearchRequestIDXml.nodes('list/item') as Search(req)

			IF @Tab = 'Networks'
				BEGIN
					SET @InsertQueryAdd = ', Category, DayDate'
					SET @SelectQueryAdd = ', Station_Affil, TVR.GMTDatetime'
					SET @FromQueryAdd = ' INNER JOIN IQMediaGroup.dbo.IQ_Station WITH (NOLOCK) ON Rl_Station = IQ_Station_ID 
										  INNER JOIN #TopTenTable AS TempTable ON TempTable.ID = IQ_Station.Station_Affil'
					SET @WhereQueryAdd = ''
				END
			IF @Tab = 'Shows'
				BEGIN
					SET @InsertQueryAdd = ', Category, DayDate'
					SET @SelectQueryAdd = ', TVR.Title120, TVR.GMTDatetime'
					SET @FromQueryAdd = ' INNER JOIN #TopTenTable AS TempTable ON TempTable.ID = TVR.Title120'
					SET @WhereQueryAdd = ' WHERE TVR.GMTDatetime BETWEEN SearchRequestTable.FromDate AND SearchRequestTable.ToDate'
				END
			IF @Tab = 'Stations'
				BEGIN
					SET @InsertQueryAdd = ', Category, DayDate'
					SET @SelectQueryAdd = ', Rl_Station, TVR.RL_Date'
					SET @FromQueryAdd = ' INNER JOIN #TopTenTable AS TempTable ON TempTable.ID = Rl_Station'
					SET @WhereQueryAdd = ' WHERE TVR.GMTDatetime BETWEEN SearchRequestTable.FromDate AND SearchRequestTable.ToDate'
				END
		END


	SET @Query = 'INSERT INTO #tempData 
			(
				SearchRequestID, 
				SubMediaType, 
				NoOfDocs, 
				NoOfHits, 
				Audience, 
				MediaValue, 
				PositiveSentiment, 
				NegativeSentiment,
				SeenEarned,
				SeenPaid,
				HeardEarned,
				HeardPaid,
				ThumbUrl,
				Market,
				AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus, 
				AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus'
			+ @InsertQueryAdd
			+ ') 
			SELECT 
				TVR.SearchRequestID, 
				''TV'',
				TVR.Number_Hits, 
				TVR.Number_Hits, 
				TVR.Nielsen_Audience, 
				TVR.IQAdShareValue, 
				TVR.Sentiment.query(''/Sentiment/PositiveSentiment'').value(''.'',''tinyint'') AS PositiveSentiment, 
				TVR.Sentiment.query(''/Sentiment/NegativeSentiment'').value(''.'',''tinyint'') AS NegativeSentiment,
				LRR.Earned,
				LRR.Paid,
				TVR.Earned,
				TVR.Paid,
				TVR.RawMediaThumbUrl,
				TVR.RL_Market,
				TVR.AM18_20, TVR.AM21_24, TVR.AM25_34, TVR.AM35_49, TVR.AM50_54, TVR.AM55_64, TVR.AM65_Plus, 
				TVR.AF18_20, TVR.AF21_24, TVR.AF25_34, TVR.AF35_49, TVR.AF50_54, TVR.AF55_64, TVR.AF65_Plus'
			+ @SelectQueryAdd
			+ ' FROM IQMediaGroup.dbo.IQAgent_TVResults TVR WITH (NOLOCK)
				INNER JOIN #SearchRequestIDTable AS SearchRequestTable
					ON TVR.SearchRequestID = SearchRequestTable.ID
				LEFT OUTER JOIN IQMediaGroup.dbo.IQAgent_LRResults LRR WITH (NOLOCK)
					ON TVR._LRResultsID = LRR.ID '
			+ @FromQueryAdd + ' '
			+ @WhereQueryAdd + ' AND TVR.IsActive > 0'

	EXEC sp_executesql @Query
	print @Query 

	INSERT INTO #tempData
	SELECT
		SearchRequestTable.FromDate,
		SearchRequest.ID,
		@Medium,
		NULL,	-- Category
		0,		-- NoOfDocs
		0,		-- NoOfHits
		0,		-- Audience
		0,		-- MediaValue
		0,		-- PositiveSentiment
		0,		-- NegativeSentiment
		0,		-- SeenEarned
		0,		-- SeenPaid
		0,		-- HeardEarned
		0,		-- HeardPaid
		'',		-- ThumbUrl
		'',		-- Market
		0, 0, 0, 0, 0, 0, 0,	-- Male Demographics
		0, 0, 0, 0, 0, 0, 0		-- Female Demographics
	FROM #SearchRequestIDTable AS SearchRequestTable
	LEFT OUTER JOIN IQAgent_SearchRequest AS SearchRequest WITH (NOLOCK)
		ON SearchRequest.ID = SearchRequestTable.ID AND SearchRequest.IsActive > 0

	SET @QueryDetail ='populate temp table from IQAgent_TVResults'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking
	(
		[Guid],
		SPName,
		QueryDetail,
		TotalTime
	) 
	VALUES
	(
		@SPTrackingID,
		@SPName,
		@QueryDetail,
		@TimeDiff
	)
	SET @Stopwatch = GetDate()	

	IF @DateInterval != 'month'
		BEGIN
		SELECT
			'OverallSummary' as TableType,
			tempData.DayDate,
			IQAgent_SearchRequest.ID,
			IQAgent_SearchRequest.Query_Name,
			tempData.SubMediaType,
			tempData.Category AS 'Category',
			tempData.Market,
			SUM(CASE WHEN NoOfDocs > 0 THEN CAST(NoOfDocs AS bigint) ELSE 0 END) AS 'NoOfDocs',
			SUM(CASE WHEN NoOfHits > 0 THEN CAST(NoOfHits AS bigint) ELSE 0 END) AS 'NoOfHits',
			Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',
			Sum(CASE WHEN MediaValue > 0 THEN MediaValue ELSE 0 END) as 'IQMediaValue',
			Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',
			Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment',
			SUM(CASE WHEN HeardEarned > 0 THEN CAST(HeardEarned AS bigint) ELSE 0 END) AS 'HeardEarned',
			SUM(CASE WHEN HeardPaid > 0 THEN CAST(HeardPaid AS bigint) ELSE 0 END) AS 'HeardPaid',
			SUM(CASE WHEN SeenEarned > 0 THEN CAST(SeenEarned AS bigint) ELSE 0 END) AS 'SeenEarned',
			SUM(CASE WHEN SeenPaid > 0 THEN CAST(SeenPaid AS bigint) ELSE 0 END) AS 'SeenPaid',
			MAX(tempData.ThumbUrl) AS 'ThumbUrl',
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
		FROM IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
		INNER JOIN #SearchRequestIDTable AS SearchRequestTable
			ON IQAgent_SearchRequest.ID = SearchRequestTable.ID
		LEFT OUTER JOIN #tempData AS tempData
			ON tempData.SearchRequestID = IQAgent_SearchRequest.ID
		WHERE IQAgent_SearchRequest.IsActive > 0
		GROUP BY DayDate, IQAgent_SearchRequest.ID, IQAgent_SearchRequest.Query_Name, SubMediaType, Category, Market
	END

	IF @DateInterval = 'month'
		BEGIN
			SELECT
				'OverallSummary' as TableType,
				MAX(tempData.DayDate) AS 'DayDate',
				IQAgent_SearchRequest.ID,
				IQAgent_SearchRequest.Query_Name,
				tempData.SubMediaType,
				tempData.Category AS 'Category',
				tempData.Market,
				SUM(CASE WHEN NoOfDocs > 0 THEN CAST(NoOfDocs AS bigint) ELSE 0 END) AS 'NoOfDocs',
				SUM(CASE WHEN NoOfHits > 0 THEN CAST(NoOfHits AS bigint) ELSE 0 END) AS 'NoOfHits',
				Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',
				Sum(CASE WHEN MediaValue > 0 THEN MediaValue ELSE 0 END) as 'IQMediaValue',
				Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',
				Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment',
				SUM(CASE WHEN HeardEarned > 0 THEN CAST(HeardEarned AS bigint) ELSE 0 END) AS 'HeardEarned',
				SUM(CASE WHEN HeardPaid > 0 THEN CAST(HeardPaid AS bigint) ELSE 0 END) AS 'HeardPaid',
				SUM(CASE WHEN SeenEarned > 0 THEN CAST(SeenEarned AS bigint) ELSE 0 END) AS 'SeenEarned',
				SUM(CASE WHEN SeenPaid > 0 THEN CAST(SeenPaid AS bigint) ELSE 0 END) AS 'SeenPaid',
				MAX(tempData.ThumbUrl) AS 'ThumbUrl',
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
			FROM IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
			INNER JOIN #SearchRequestIDTable AS SearchRequestTable
				ON IQAgent_SearchRequest.ID = SearchRequestTable.ID
			LEFT OUTER JOIN #tempData AS tempData
				ON tempData.SearchRequestID = IQAgent_SearchRequest.ID
			WHERE IQAgent_SearchRequest.IsActive > 0
			GROUP BY DATEPART(YEAR, DayDate), DATEPART(MONTH, DayDate), IQAgent_SearchRequest.ID, IQAgent_SearchRequest.Query_Name, SubMediaType, Category, Market
		END

	SET @QueryDetail ='get all day summary'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking
	(
		[Guid],
		SPName,
		QueryDetail,
		TotalTime
	) 
	VALUES
	(
		@SPTrackingID,
		@SPName,
		@QueryDetail,
		@TimeDiff
	)
	SET @Stopwatch = GetDate()	

	CREATE TABLE #tempMapData 
	(
		MapType varchar(20), 
		Name varchar(100), 
		SearchRequestID bigint,
		Mentions bigint
	)

	INSERT INTO #tempMapData 
	(
		MapType, 
		Name, 
		SearchRequestID,
		Mentions
	)
	SELECT
		'DMA', 
		DMA_Name,
		IQAgent_SearchRequest.ID,
		ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0)
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
	WHERE
		IQ_Station.Country_num = 1 -- Limit results to US
		AND (@Medium IS NULL OR IQAgent_TVResults.v5SubMediaType = @Medium)
	GROUP BY 
		IQ_Station.Dma_Name, IQAgent_SearchRequest.ID

		SET @QueryDetail ='populate temp table for TV dma summary'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking
		(
			[Guid],
			SPName,
			QueryDetail,
			TotalTime
		) 
		VALUES
		(
			@SPTrackingID,
			@SPName,
			@QueryDetail,
			@TimeDiff
		)
		SET @Stopwatch = GetDate()	
		
		INSERT INTO #tempMapData 
		(
			MapType, 
			Name, 
			SearchRequestID,
			Mentions
		)
		SELECT 
			'Canada',
			Province,
			IQAgent_SearchRequest.ID,
			ISNULL(sum(CONVERT(BIGINT,Number_Hits)),0)
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
		WHERE
			IQ_Station.Country_num = 2 -- Limit results to Canada
			AND (@Medium IS NULL OR IQAgent_TVResults.v5SubMediaType = @Medium)
		GROUP BY 
			IQ_DMAProvinceLookup.Province, IQAgent_SearchRequest.ID

		SET @QueryDetail ='populate temp table for TV Canada summary'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking
		(
			[Guid],
			SPName,
			QueryDetail,
			TotalTime
		) 
		VALUES
		(
			@SPTrackingID,
			@SPName,
			@QueryDetail,
			@TimeDiff
		)
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
GO

