USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Analytics_HourSummary_Campaign]    Script Date: 5/24/2016 16:59:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_HourSummary_Campaign]
(
	@SubMediaType	varchar(15),
	@CampaignIDXml	xml,
	@LoadEverything     bit
)	
AS
BEGIN
	DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)
 
	SET @SPStartTime=GetDate()
	SET @Stopwatch=GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v5_IQAgent_Analytics_HourSummary_Campaign'  

	DECLARE @ClientGUID UNIQUEIDENTIFIER
	SELECT	@ClientGUID = IQAgent_SearchRequest.ClientGUID
	FROM	IQMediaGroup.dbo.IQAgent_Campaign WITH (NOLOCK)
	INNER	JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
		ON IQAgent_SearchRequest.ID = IQAgent_Campaign._SearchRequestID
	INNER	JOIN @CampaignIDXml.nodes('list/item') as Search(req)
		ON IQAgent_Campaign.ID = Search.req.value('@id', 'bigint')

	CREATE TABLE #tempData 
	(
		DayDate datetime, 
		Query_Name varchar(max),
		CampaignID bigint, 
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
	
	IF @ClientGUID = '7722A116-C3BC-40AE-8070-8C59EE9E3D2A'
	  BEGIN
			INSERT INTO #tempData (DayDate, CampaignID, Query_Name, ClientGuid, SubMediaType, Market, NoOfDocs, NoOfHits, Audience, MediaValue, PositiveSentiment, NegativeSentiment, SeenEarned, SeenPaid, HeardEarned, HeardPaid, AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus, AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus)
			SELECT	GMTHourDateTime, 
					IQAgent_Campaign.ID, 
					IQAgent_SearchRequest.Query_Name,
					_ClientGuid, 
					SubMediaType, 
					Market,
					NumberOfDocs, 
					NumberOfHits, 
					TotalAudiences, 
					IQMediaValue, 
					PositiveSentiment, 
					NegativeSentiment, 
					Seen_Earned, 
					Seen_Paid, 
					Heard_Earned, 
					Heard_Paid, 
					AM18_20, 
					AM21_24, 
					AM25_34, 
					AM35_49, 
					AM50_54, 
					AM55_64, 
					AM65_Plus, 
					AF18_20, 
					AF21_24, 
					AF25_34, 
					AF35_49, 
					AF50_54, 
					AF55_64, 
					AF65_Plus
			FROM	IQMediaGroup.dbo.IQAgent_AnalyticsHourSummary WITH (NOLOCK)
			INNER	JOIN IQMediaGroup.dbo.IQAgent_Campaign WITH (NOLOCK)
					ON IQAgent_Campaign._SearchRequestID = IQAgent_AnalyticsHourSummary._SearchRequestID
					AND IQAgent_AnalyticsHourSummary.GMTHourDateTime BETWEEN IQAgent_Campaign.StartDatetimeGMT AND IQAgent_Campaign.EndDatetimeGMT
			INNER	JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
					ON IQAgent_SearchRequest.ID = IQAgent_Campaign._SearchRequestID
			INNER	JOIN @CampaignIDXml.nodes('list/item') as Search(req)
					ON IQAgent_Campaign.ID = Search.req.value('@id', 'bigint')
			WHERE	(@SubMediaType IS NULL OR SubMediaType = @SubMediaType)
	  END
	ELSE
	  BEGIN
		IF @SubMediaType IS NULL OR @SubMediaType != 'TV'
		  BEGIN
			INSERT INTO #tempData (DayDate, CampaignID, Query_Name, ClientGuid, SubMediaType, NoOfDocs, NoOfHits, Audience, MediaValue, PositiveSentiment, NegativeSentiment, ReadEarned)
			SELECT	HourDateTime, 
					IQAgent_Campaign.ID, 
					IQAgent_SearchRequest.Query_Name,
					IQAgent_HourSummary.ClientGuid, 
					SubMediaType, 
					NoOfDocs, 
					NoOfHits, 
					Audience, 
					IQMediaValue, 
					PositiveSentiment, 
					NegativeSentiment, 
					NoOfHits
			FROM	IQMediaGroup.dbo.IQAgent_HourSummary WITH (NOLOCK)
			INNER	JOIN IQMediaGroup.dbo.IQAgent_Campaign WITH (NOLOCK)
					ON IQAgent_Campaign._SearchRequestID = IQAgent_HourSummary._SearchRequestID
					AND IQAgent_HourSummary.HourDateTime BETWEEN IQAgent_Campaign.StartDatetimeGMT AND IQAgent_Campaign.EndDatetimeGMT
			INNER	JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
					ON IQAgent_SearchRequest.ID = IQAgent_Campaign._SearchRequestID
			INNER	JOIN @CampaignIDXml.nodes('list/item') as Search(req)
					ON IQAgent_Campaign.ID = Search.req.value('@id', 'bigint')
			WHERE	(SubMediaType != 'TV')
					AND (@SubMediaType IS NULL OR SubMediaType = @SubMediaType)
		  END
	
		IF @SubMediaType IS NULL OR @SubMediaType = 'TV'
		  BEGIN
			INSERT INTO #tempData (DayDate, CampaignID, Query_Name, ClientGuid, SubMediaType, Market, NoOfDocs, NoOfHits, Audience, MediaValue, PositiveSentiment, NegativeSentiment, SeenEarned, SeenPaid, HeardEarned, HeardPaid, AM18_20, AM21_24, AM25_34, AM35_49, AM50_54, AM55_64, AM65_Plus, AF18_20, AF21_24, AF25_34, AF35_49, AF50_54, AF55_64, AF65_Plus)
			SELECT	HourDateTime, 
					IQAgent_Campaign.ID, 
					IQAgent_SearchRequest.Query_Name,
					_ClientGuid, 
					'TV', 
					Market,
					NumberOfDocs, 
					NumberOfHits, 
					TotalAudience, 
					IQAdShareValue, 
					PositiveSentiment, 
					NegativeSentiment, 
					Seen_Earned, 
					Seen_Paid, 
					Heard_Earned, 
					Heard_Paid, 
					AM18_20, 
					AM21_24, 
					AM25_34, 
					AM35_49, 
					AM50_54, 
					AM55_64, 
					AM65_Plus, 
					AF18_20, 
					AF21_24, 
					AF25_34, 
					AF35_49, 
					AF50_54, 
					AF55_64, 
					AF65_Plus
			FROM	IQMediaGroup.dbo.IQAgent_EarnedPaidHourSummary WITH (NOLOCK)
			INNER	JOIN IQMediaGroup.dbo.IQAgent_Campaign WITH (NOLOCK)
					ON IQAgent_Campaign._SearchRequestID = IQAgent_EarnedPaidHourSummary._SearchRequestID
					AND IQAgent_EarnedPaidHourSummary.HourDateTime BETWEEN IQAgent_Campaign.StartDatetimeGMT AND IQAgent_Campaign.EndDatetimeGMT
			INNER	JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
					ON IQAgent_SearchRequest.ID = IQAgent_Campaign._SearchRequestID
			INNER	JOIN @CampaignIDXml.nodes('list/item') as Search(req)
					ON IQAgent_Campaign.ID = Search.req.value('@id', 'bigint')
				
		  END
	  END

	INSERT INTO #tempData
	SELECT
		Campaign.StartDatetimeGMT,
		SearchRequest.Query_Name,
		Campaign.ID,
		SearchRequest.ClientGUID,
		@SubMediaType,
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
	FROM @CampaignIDXml.nodes('list/item') AS Search(req)
		LEFT OUTER JOIN IQAgent_Campaign AS Campaign WITH (NOLOCK)
			ON Campaign.ID = Search.req.value('@id', 'bigint')
		LEFT OUTER JOIN IQAgent_SearchRequest AS SearchRequest WITH (NOLOCK)
			ON SearchRequest.ID = Campaign._SearchRequestID AND SearchRequest.IsActive > 0

	SET @QueryDetail ='populate temp table from IQAgent_DaySummary and IQAgent_EarnedPaidDaySummary'
	SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
	INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	SET @Stopwatch = GetDate()	


	SELECT	'OverallSummary' as TableType,
			tempData.ClientGuid,
			tempData.DayDate,
			tempData.Query_Name,
			IQAgent_Campaign._SearchRequestID as 'ID',
			IQAgent_Campaign.ID as 'CampaignID',
			IQAgent_Campaign.Name as 'CampaignName',
			SubMediaType,
			tempData.Market as 'Market',
			Sum(Cast(NoOfDocs as bigint)) as 'NoOfDocs',
			Sum(Cast(NoOfHits as bigint)) as 'NoOfHits',
			Sum(CASE WHEN Audience > 0 THEN Cast(Audience as bigint) ELSE 0 END) as 'Audience',
			Sum(CASE WHEN MediaValue > 0 THEN MediaValue ELSE 0 END) as 'IQMediaValue',
			Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',
			Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment',
			Sum(Cast(IsNull(ReadEarned, 0) as bigint)) as 'ReadEarned',
			Sum(Cast(IsNull(SeenEarned, 0) as bigint)) as 'SeenEarned',
			Sum(Cast(IsNull(SeenPaid, 0) as bigint)) as 'SeenPaid',
			Sum(Cast(IsNull(HeardEarned, 0) as bigint)) as 'HeardEarned',
			Sum(Cast(IsNull(HeardPaid, 0) as bigint)) as 'HeardPaid',
			SUM(CAST(IsNull(AM18_20, 0) AS bigint)) AS 'AM18_20',
			SUM(CAST(IsNull(AM21_24, 0) AS bigint)) AS 'AM21_24',
			SUM(CAST(IsNull(AM25_34, 0) AS bigint)) AS 'AM25_34',
			SUM(CAST(IsNull(AM35_49, 0) AS bigint)) AS 'AM35_49',
			SUM(CAST(IsNull(AM50_54, 0) AS bigint)) AS 'AM50_54',
			SUM(CAST(IsNull(AM55_64, 0) AS bigint)) AS 'AM55_64',
			SUM(CAST(IsNull(AM65_Plus, 0) AS bigint)) AS 'AM65_Plus',
			SUM(CAST(IsNull(AF18_20, 0) AS bigint)) AS 'AF18_20',
			SUM(CAST(IsNull(AF21_24, 0) AS bigint)) AS 'AF21_24',
			SUM(CAST(IsNull(AF25_34, 0) AS bigint)) AS 'AF25_34',
			SUM(CAST(IsNull(AF35_49, 0) AS bigint)) AS 'AF35_49',
			SUM(CAST(IsNull(AF50_54, 0) AS bigint)) AS 'AF50_54',
			SUM(CAST(IsNull(AF55_64, 0) AS bigint)) AS 'AF55_64',
			SUM(CAST(IsNull(AF65_Plus, 0) AS bigint)) AS 'AF65_Plus'
	FROM	IQMediaGroup.dbo.IQAgent_Campaign WITH (NOLOCK)
	INNER	JOIN #tempData tempData
			ON tempData.CampaignID = IQAgent_Campaign.ID
	GROUP	BY DayDate,
			tempData.ClientGuid,
			IQAgent_Campaign.ID,
			IQAgent_Campaign.Name,
			SubMediaType,
			tempData.Query_Name,
			_SearchRequestID,
            tempData.Market

	IF @LoadEverything = 1
	BEGIN
		SET @QueryDetail ='get all day summary'
		SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
		INSERT INTO IQMediaGroup.dbo.IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
		SET @Stopwatch = GetDate()	
	END
END
