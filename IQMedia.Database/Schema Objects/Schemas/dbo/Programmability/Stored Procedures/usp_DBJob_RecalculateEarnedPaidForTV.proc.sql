USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_RecalculateEarnedPaidForTV]    Script Date: 10/20/2016 3:09:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
DECLARE @RecalStatus CHAR(40)
EXEC usp_DBJob_RecalculateEarnedPaidSummary @RecalStatus = @RecalStatus OUTPUT
SELECT @RecalStatus
*/
CREATE PROCEDURE [dbo].[usp_DBJob_RecalculateEarnedPaidForTV]      
@RecalStatus CHAR(40) OUTPUT
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY     
 
   CREATE TABLE #IQAgent_TableResults_DirtyTable	(
	[Dirtytbl_ID] [bigint]   NULL,
	[_IQAgent_MediaID] [bigint] NOT NULL,
	[MediaType] [varchar](2) NOT NULL,
	[Flag] [char](1) NOT NULL,
	[GMTDatetime] [datetime] NULL,
	[LocalTime] [datetime] NULL,
	[SearchRequestID] [bigint] NULL,
	[RL_Market] [varchar](150) NULL,
	[Rl_Station] [varchar](150) NULL,
	[Number_Hits] [int] NULL,
	[Earned] [int] NULL,
	[Paid] [int] NULL,
	[Process] [CHAR](1) NULL
	)

   CREATE TABLE #IQAgent_TableResults_DirtyTable0	(
	[Dirtytbl_ID] [bigint]   NULL,
	[_IQAgent_MediaID] [bigint] NOT NULL
	)

	CREATE TABLE #IQAgent_TableResults_DirtyTable1	(
	[Dirtytbl_ID] [bigint]   NULL,
	[_IQAgent_MediaID] [bigint] NOT NULL
	)

   CREATE TABLE #IQAgent_TVResults_Delete
   (
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalTime] [DATETIME] NULL,
	[Rl_Station] VARCHAR(150) NULL,
	[RL_Market] VARCHAR(150) NULL,
	[Country_Number] SMALLINT NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[AM18_20] [BIGINT] NULL,
	[AM21_24] [BIGINT] NULL,
	[AM25_34] [BIGINT] NULL,
	[AM35_49] [BIGINT] NULL,
	[AM50_54] [BIGINT] NULL,
	[AM55_64] [BIGINT] NULL,
	[AM65_Plus] [BIGINT] NULL,
	[AF18_20] [BIGINT] NULL,
	[AF21_24] [BIGINT] NULL,
	[AF25_34] [BIGINT] NULL,
	[AF35_49] [BIGINT] NULL,
	[AF50_54] [INT] NULL,
	[AF55_64] [BIGINT] NULL,
	[AF65_Plus] [BIGINT] NULL,
	[Earned] [INT] NULL,
	[Paid] [INT] NULL
	)

   CREATE TABLE #IQAgent_EarnedPaidDaySummary_Delete_ADS
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[DayDate] DATE not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT NOT NULL,
	[NumberOFDocs] INT NULL,
	[NumberOFHits] BIGINT NULL,
	[AM18_20] [BIGINT] NULL,
	[AM21_24] [BIGINT] NULL,
	[AM25_34] [BIGINT] NULL,
	[AM35_49] [BIGINT] NULL,
	[AM50_54] [BIGINT] NULL,
	[AM55_64] [BIGINT] NULL,
	[AM65_Plus] [BIGINT] NULL,
	[AF18_20] [BIGINT] NULL,
	[AF21_24] [BIGINT] NULL,
	[AF25_34] [BIGINT] NULL,
	[AF35_49] [BIGINT] NULL,
	[AF50_54] [BIGINT] NULL,
	[AF55_64] [BIGINT] NULL,
	[AF65_Plus] [BIGINT] NULL,
	[TotalAudience] BIGINT NULL,
	[PositiveSentiment] INT NULL,
	[NegativeSentiment] INT NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Seen_Earned] [INT] NULL,
	[Seen_Paid] [INT] NULL,
	[Heard_Earned] [INT] NULL,
	[Heard_Paid] [INT] NULL
    )
	   
	CREATE TABLE #IQAgent_EarnedPaidLocalTimeDaySummary_Delete_ADS
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[DayDate] DATE not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT NOT NULL,
	[NumberOFDocs] INT NULL,
	[NumberOFHits] BIGINT NULL,
	[AM18_20] [BIGINT] NULL,
	[AM21_24] [BIGINT] NULL,
	[AM25_34] [BIGINT] NULL,
	[AM35_49] [BIGINT] NULL,
	[AM50_54] [BIGINT] NULL,
	[AM55_64] [BIGINT] NULL,
	[AM65_Plus] [BIGINT] NULL,
	[AF18_20] [BIGINT] NULL,
	[AF21_24] [BIGINT] NULL,
	[AF25_34] [BIGINT] NULL,
	[AF35_49] [BIGINT] NULL,
	[AF50_54] [BIGINT] NULL,
	[AF55_64] [BIGINT] NULL,
	[AF65_Plus] [BIGINT] NULL,
	[TotalAudience] BIGINT NULL,
	[PositiveSentiment] INT NULL,
	[NegativeSentiment] INT NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Seen_Earned] [INT] NULL,
	[Seen_Paid] [INT] NULL,
	[Heard_Earned] [INT] NULL,
	[Heard_Paid] [INT] NULL
    )

	CREATE TABLE #IQAgent_EarnedPaidHourSummary_Delete_ADS
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[HourDateTime] DATETIME not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT NOT NULL,
	[NumberOFDocs] INT NULL,
	[NumberOFHits] BIGINT NULL,
	[AM18_20] [BIGINT] NULL,
	[AM21_24] [BIGINT] NULL,
	[AM25_34] [BIGINT] NULL,
	[AM35_49] [BIGINT] NULL,
	[AM50_54] [BIGINT] NULL,
	[AM55_64] [BIGINT] NULL,
	[AM65_Plus] [BIGINT] NULL,
	[AF18_20] [BIGINT] NULL,
	[AF21_24] [BIGINT] NULL,
	[AF25_34] [BIGINT] NULL,
	[AF35_49] [BIGINT] NULL,
	[AF50_54] [BIGINT] NULL,
	[AF55_64] [BIGINT] NULL,
	[AF65_Plus] [BIGINT] NULL,
	[TotalAudience] BIGINT NULL,
	[PositiveSentiment] INT NULL,
	[NegativeSentiment] INT NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Seen_Earned] [INT] NULL,
	[Seen_Paid] [INT] NULL,
	[Heard_Earned] [INT] NULL,
	[Heard_Paid] [INT] NULL
	)
		
	CREATE TABLE #IQAgent_EarnedPaidDaySummary_OldHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[DayDate] DATE not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT  NULL,
	[NumberOFHits] BIGINT NULL,
	[Earned] BIGINT NULL,
	[Paid] BIGINT NULL,
	)

	CREATE TABLE #IQAgent_EarnedPaidLocalTimeDaySummary_OldHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[DayDate] DATE not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT  NULL,
	[NumberOFHits] BIGINT NULL,
	[Earned] BIGINT NULL,
	[Paid] BIGINT NULL,
	)

	CREATE TABLE #IQAgent_EarnedPaidHourSummary_OldHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[HourDateTime] DATETIME not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT  NULL,
	[NumberOFHits] BIGINT NULL,
	[Earned] BIGINT NULL,
	[Paid] BIGINT NULL,
	)  
   
	CREATE TABLE #IQAgent_EarnedPaidDaySummary_NewHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[DayDate] DATE not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT  NULL,
	[NumberOFHits] BIGINT NULL,
	[Earned] BIGINT NULL,
	[Paid] BIGINT NULL,
	)

	CREATE TABLE #IQAgent_EarnedPaidLocalTimeDaySummary_NewHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[DayDate] DATE not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT  NULL,
	[NumberOFHits] BIGINT NULL
	)

	CREATE TABLE #IQAgent_EarnedPaidHourSummary_NewHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[HourDateTime] DATETIME not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT NULL,
	[NumberOFHits] BIGINT NULL
	)  

	CREATE TABLE #IQAgent_TVResults_IQAnalytic
	(
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalTime] [DATETIME] NULL,
	[Rl_Station] VARCHAR(150) NULL,
	[RL_Market] VARCHAR(150) NULL,
	[Country_Number] SMALLINT NULL,
	[Number_Hits] [BIGINT] NULL,
	[Earned] [BIGINT] NULL,
	[Paid] [BIGINT] NULL,
	)  
/*
		CREATE TABLE #IQAgent_EarnedPaidDaySummary_ADS_NewHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[DayDate] DATE not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT  NULL,
	[NumberOFHits] BIGINT NULL
	)

	CREATE TABLE #IQAgent_EarnedPaidLocalTimeDaySummary_ADS_NewHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[DayDate] DATE not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT  NULL,
	[NumberOFHits] BIGINT NULL
	)

	CREATE TABLE #IQAgent_EarnedPaidHourSummary_ADS_NewHits
	(
	[ClientGuid] uniqueidentifier NOT NULL,
	[HourDateTime] DATETIME not null,
	[SearchRequestID] BIGINT NOT NULL,
	[Market] VARCHAR(150) NOT NULL,
	[CountryNumber] SMALLINT NULL,
	[NumberOFHits] BIGINT NULL
	)  
*/
	DECLARE @Status SMALLINT
	DECLARE @IQ_ADS_Station_Control TABLE (StationID VARCHAR(100))
     	 
	/*
	DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff Float    ,@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
    	SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_DBJob_EarnedPaidSummary' */
   
   
   -- Get Number_Hits have been changed and have been processed adding to the IQAgent_EarnedPaidSummary and the IQAgent_EarnedPaidHourSummary

	INSERT INTO #IQAgent_TableResults_DirtyTable	(
		[Dirtytbl_ID],
		[_IQAgent_MediaID],
		[MediaType],
		[Flag],
		[GMTDatetime],
		[SearchRequestID],
		[RL_Market],
		[Rl_Station],
		[Number_Hits],
		[Earned],
		[Paid],
		[Process]
		)
	SELECT 
		d.ID,
		_IQAgent_MediaID,
		MediaType,
		Flag,
		GMTDatetime,
		SearchRequestID,
		RL_Market,
		Rl_Station,
		Number_Hits,
		Earned,
		Paid,
		Process
	FROM IQAgent_TableResults_DirtyTable d WITH (NOLOCK)
	WHERE Flag = 'C' AND IsACtive = 1 AND Process ='Y' 

 -- Get Number_Hits That have been changed, but the TVs have been marked inactive. Nothing needs to be done. Their values have been subtracted through dirtytable process. 
 -- Need to get this to delete those rows from IQAgent_TableResults_DirtyTable 
   	INSERT INTO #IQAgent_TableResults_DirtyTable0	(
		[Dirtytbl_ID],
		[_IQAgent_MediaID]
		)
	SELECT 
		d.ID,
		_IQAgent_MediaID
	FROM IQAgent_TableResults_DirtyTable d WITH (NOLOCK)
	WHERE Flag = 'C' AND IsACtive = 0

-- Get Number_hits that have been changed, but they have not been processed, Nothing needs to be done. 
-- Need to do this to delete those rows from IQAgent_TableResults_DirtyTable 

	INSERT INTO #IQAgent_TableResults_DirtyTable1	(
		[Dirtytbl_ID],
		[_IQAgent_MediaID]
		)
	SELECT 
		d.ID,
		_IQAgent_MediaID
	FROM IQAgent_TableResults_DirtyTable d WITH (NOLOCK)
	WHERE Flag = 'C' AND IsACtive = 1 AND Process IS NULL

	IF (SELECT COUNT(1) FROM #IQAgent_TableResults_DirtyTable) > 0  OR (SELECT COUNT(1) FROM #IQAgent_TableResults_DirtyTable0) > 0 OR (SELECT COUNT(1) FROM #IQAgent_TableResults_DirtyTable1) > 0
	    BEGIN
	
			INSERT INTO @IQ_ADS_Station_Control(StationID) SELECT StationID FROM IQ_ADS_Station_Control

			INSERT INTO #IQAgent_TVResults_Delete
				(
				[ID],
				[SearchRequestID],
				[GMTDatetime],
				[LocalTime],
				[Rl_Station],
				[RL_Market],
				[Country_Number],
				[Number_Hits],
				[PositiveSentiment],
				[NegativeSentiment],
				[IQAdShareValue],
				[AM18_20],
				[AM21_24],
				[AM25_34],
				[AM35_49],
				[AM50_54],
				[AM55_64],
				[AM65_Plus],
				[AF18_20],
				[AF21_24],
				[AF25_34],
				[AF35_49],
				[AF50_54],
				[AF55_64],
				[AF65_Plus],
				[Earned],
				[Paid]
				)
			SELECT 
				[TV].[ID],
				[TV].[SearchRequestID],
				[TV].[GMTDatetime],
				CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(tv.GMTDatetime) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = sr.ClientGuid),tv.GMTDatetime) ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = sr.ClientGuid),tv.GMTDatetime) END),
				[TV].[Rl_Station],
				[TV].[RL_Market],
				(SELECT Country_Num FROM IQ_STATION WITH (NOLOCK) WHERE IQ_STATION_ID = tv.Rl_Station) AS Country_Number,
				[tmp].[Number_Hits],
				ISNULL(Sentiment.query('Sentiment/PositiveSentiment').value('.','INT'),0) AS [PositiveSentiment],
				ISNULL(Sentiment.query('Sentiment/NegativeSentiment').value('.','INT'),0)  AS [NegativeSentiment],
				[TV].[IQAdShareValue],
				[AM18_20],
				[AM21_24],
				[AM25_34],
				[AM35_49],
				[AM50_54],
				[AM55_64],
				[AM65_Plus],
				[AF18_20],
				[AF21_24],
				[AF25_34],
				[AF35_49],
				[AF50_54],
				[AF55_64],
				[AF65_Plus],
				[tmp].[Earned],
				[tmp].[Paid]
			FROM IQAgent_TVResults tv  WITH (NOLOCK), #IQAgent_TableResults_DirtyTable tmp, IQAgent_SearchRequest sr  WITH (NOLOCK)
				WHERE tv.ID  = tmp._IQAgent_MediaID
				--  AND tmp.MediaType ='TV'
				  AND tv.Process = 'Y'
				  AND sr.ID = tv.SearchRequestID


-- Get old Value of the Number of Hits

			-- For Day Summary GMT Time
			INSERT INTO  #IQAgent_EarnedPaidDaySummary_Delete_ADS
				(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOFHits],
				[AM18_20],
				[AM21_24],
				[AM25_34],
				[AM35_49],
				[AM50_54],
				[AM55_64],
				[AM65_Plus],
				[AF18_20],
				[AF21_24],
				[AF25_34],
				[AF35_49],
				[AF50_54],
				[AF55_64],
				[AF65_Plus],
				[TotalAudience],
				[PositiveSentiment],
				[NegativeSentiment],
				[IQAdShareValue],
				[Heard_Earned],
				[Heard_Paid]
				)
			Select  ClientGUID,
				CONVERT(DATE,GMTDatetime),
				SearchRequestID,
				RL_Market,
				Country_Number, 
				COUNT(tv.ID) AS NoOfDocs,
				SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(AM18_20,0)) AS AM18_20,
				SUM( ISNULL(AM21_24,0)) AS AM21_24,
				SUM( ISNULL(AM25_34,0)) AS AM25_34,
				SUM( ISNULL(AM35_49,0)) AS AM35_49,
				SUM( ISNULL(AM50_54,0)) AS AM50_54,
				SUM( ISNULL(AM55_64,0)) AS AM55_64,
				SUM( ISNULL(AM65_Plus,0)) AS AM65_Plus,
				SUM( ISNULL(AF18_20,0)) AS AF18_20,
				SUM( ISNULL(AF21_24,0)) AS AF21_24,
				SUM( ISNULL(AF25_34,0)) AS AF25_34,
				SUM( ISNULL(AF35_49,0)) AS AF35_49,
				SUM( ISNULL(AF50_54,0)) AS AF50_54,
				SUM( ISNULL(AF55_64,0)) AS AF55_64,
				SUM( ISNULL(AF65_Plus,0)) AS AF65_Plus,
				SUM( ISNULL(AM18_20,0)+ ISNULL(AM21_24,0)+ISNULL(AM25_34,0)+ISNULL(AM35_49,0)+ISNULL(AM50_54,0)+ISNULL(AM55_64,0)+ISNULL(AM65_Plus,0)+
					     ISNULL(AF18_20,0)+ ISNULL(AF21_24,0)+ISNULL(AF25_34,0)+ISNULL(AF35_49,0)+ISNULL(AF50_54,0)+ISNULL(AF55_64,0)+ISNULL(AF65_Plus,0)) AS TotalAudience,
				SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
				SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
				SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
				SUM( ISNULL(Earned,0)) AS Heard_Earned,
				SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_TVResults_Delete tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE tv.RL_Station IN (SELECT StationID FROM @IQ_ADS_Station_Control)
			GROUP BY ClientGUID,CONVERT(DATE,GMTDatetime),SearchRequestID,RL_Market,Country_Number

			-- For Day Summary Local Time
			INSERT INTO  #IQAgent_EarnedPaidLocalTimeDaySummary_Delete_ADS
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOFHits],
				[AM18_20],
				[AM21_24],
				[AM25_34],
				[AM35_49],
				[AM50_54],
				[AM55_64],
				[AM65_Plus],
				[AF18_20],
				[AF21_24],
				[AF25_34],
				[AF35_49],
				[AF50_54],
				[AF55_64],
				[AF65_Plus],
				[TotalAudience],
				[PositiveSentiment],
				[NegativeSentiment],
				[IQAdShareValue],
				[Heard_Earned],
				[Heard_Paid]
			)
			Select  ClientGUID,
					CONVERT(DATE,LocalTime),
					SearchRequestID,
					RL_Market,
					Country_Number, 
					COUNT(tv.ID) AS NoOfDocs,
					SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
					SUM( ISNULL(AM18_20,0)) AS AM18_20,
					SUM( ISNULL(AM21_24,0)) AS AM21_24,
					SUM( ISNULL(AM25_34,0)) AS AM25_34,
					SUM( ISNULL(AM35_49,0)) AS AM35_49,
					SUM( ISNULL(AM50_54,0)) AS AM50_54,
					SUM( ISNULL(AM55_64,0)) AS AM55_64,
					SUM( ISNULL(AM65_Plus,0)) AS AM65_Plus,
					SUM( ISNULL(AF18_20,0)) AS AF18_20,
					SUM( ISNULL(AF21_24,0)) AS AF21_24,
					SUM( ISNULL(AF25_34,0)) AS AF25_34,
					SUM( ISNULL(AF35_49,0)) AS AF35_49,
					SUM( ISNULL(AF50_54,0)) AS AF50_54,
					SUM( ISNULL(AF55_64,0)) AS AF55_64,
					SUM( ISNULL(AF65_Plus,0)) AS AF65_Plus,
					SUM( ISNULL(AM18_20,0)+ ISNULL(AM21_24,0)+ISNULL(AM25_34,0)+ISNULL(AM35_49,0)+ISNULL(AM50_54,0)+ISNULL(AM55_64,0)+ISNULL(AM65_Plus,0)+
					     ISNULL(AF18_20,0)+ ISNULL(AF21_24,0)+ISNULL(AF25_34,0)+ISNULL(AF35_49,0)+ISNULL(AF50_54,0)+ISNULL(AF55_64,0)+ISNULL(AF65_Plus,0)) AS TotalAudience,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
					SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_TVResults_Delete tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE tv.RL_Station IN (SELECT StationID FROM @IQ_ADS_Station_Control)
			GROUP BY ClientGUID,CONVERT(DATE,LocalTime),SearchRequestID,RL_Market,Country_Number

			-- For Hour Summary
			INSERT INTO  #IQAgent_EarnedPaidHourSummary_Delete_ADS
			(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOFHits],
				[AM18_20],
				[AM21_24],
				[AM25_34],
				[AM35_49],
				[AM50_54],
				[AM55_64],
				[AM65_Plus],
				[AF18_20],
				[AF21_24],
				[AF25_34],
				[AF35_49],
				[AF50_54],
				[AF55_64],
				[AF65_Plus],
				[TotalAudience],
				[PositiveSentiment],
				[NegativeSentiment],
				[IQAdShareValue],
				[Heard_Earned],
				[Heard_Paid]
			)
			Select  ClientGUID,
					DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)) AS HourDateTime,
					SearchRequestID,
					RL_Market,
					Country_Number, 
					COUNT(tv.ID) AS NoOfDocs,
					SUM( ISNULL(Number_Hits,0)) AS NoOfHits,
					SUM( ISNULL(AM18_20,0)) AS AM18_20,
					SUM( ISNULL(AM21_24,0)) AS AM21_24,
					SUM( ISNULL(AM25_34,0)) AS AM25_34,
					SUM( ISNULL(AM35_49,0)) AS AM35_49,
					SUM( ISNULL(AM50_54,0)) AS AM50_54,
					SUM( ISNULL(AM55_64,0)) AS AM55_64,
					SUM( ISNULL(AM65_Plus,0)) AS AM65_Plus,
					SUM( ISNULL(AF18_20,0)) AS AF18_20,
					SUM( ISNULL(AF21_24,0)) AS AF21_24,
					SUM( ISNULL(AF25_34,0)) AS AF25_34,
					SUM( ISNULL(AF35_49,0)) AS AF35_49,
					SUM( ISNULL(AF50_54,0)) AS AF50_54,
					SUM( ISNULL(AF55_64,0)) AS AF55_64,
					SUM( ISNULL(AF65_Plus,0)) AS AF65_Plus,
					SUM( ISNULL(AM18_20,0)+ ISNULL(AM21_24,0)+ISNULL(AM25_34,0)+ISNULL(AM35_49,0)+ISNULL(AM50_54,0)+ISNULL(AM55_64,0)+ISNULL(AM65_Plus,0)+
					     ISNULL(AF18_20,0)+ ISNULL(AF21_24,0)+ISNULL(AF25_34,0)+ISNULL(AF35_49,0)+ISNULL(AF50_54,0)+ISNULL(AF55_64,0)+ISNULL(AF65_Plus,0)) AS TotalAudience,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
					SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_TVResults_Delete tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE tv.RL_Station IN (SELECT StationID FROM @IQ_ADS_Station_Control)
			GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)),SearchRequestID,RL_Market,Country_Number

-- For IQAgent_Analytics tables 
			INSERT INTO #IQAgent_TVResults_IQAnalytic
					(
					ID,
					SearchRequestID,
					GMTDatetime,
					LocalTime,
					Rl_Station,
					RL_Market,
					Number_Hits,
					Earned,
					Paid
					)  
			SELECT 
					tv.ID,
					tv.SearchRequestID,
					tv.GMTDatetime,
					CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(tv.GMTDatetime) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = sr.ClientGuid),tv.GMTDatetime) ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = sr.ClientGuid),tv.GMTDatetime) END),
					tv.Rl_Station,
					tv.RL_Market,
					tmp.Number_Hits,
					tmp.Earned,
					tmp.Paid
			FROM IQAgent_TVResults tv  WITH (NOLOCK), IQAgent_TableResults_DirtyTable tmp WITH (NOLOCK), IQAgent_SearchRequest sr  WITH (NOLOCK)
				WHERE tv.ID  = tmp._IQAgent_MediaID
					AND sr.ID = tv.SearchRequestID
					AND tv.DirtyTblProcess='Y'

			-- For Day Summary GMT Time
			INSERT INTO  #IQAgent_EarnedPaidDaySummary_OldHits
				(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[NumberOFHits],
				[Earned],
				[Paid]
				)
			Select  ClientGUID,
					CONVERT(DATE,GMTDatetime),
					SearchRequestID,
					RL_Market,
					SUM( ISNULL(tv.Number_Hits,0)) AS NoOfHits,
					SUM( ISNULL(tv.Earned,0)) AS Earned,
					SUM( ISNULL(tv.Paid,0)) AS Paid
			FROM #IQAgent_TVResults_IQAnalytic tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
	--		WHERE tv.RL_Station NOT IN (SELECT StationID FROM @IQ_ADS_Station_Control)
			GROUP BY ClientGUID,CONVERT(DATE,GMTDatetime),SearchRequestID,RL_Market

			-- For Day Summary Local Time
			INSERT INTO  #IQAgent_EarnedPaidLocalTimeDaySummary_OldHits
				(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[NumberOFHits],
				[Earned],
				[Paid]
				)
			Select  ClientGUID,
					CONVERT(DATE,LocalTime),
					SearchRequestID,
					RL_Market,
					SUM( ISNULL(tv.Number_Hits,0)) AS NoOfHits,
					SUM( ISNULL(tv.Earned,0)) AS Earned,
					SUM( ISNULL(tv.Paid,0)) AS Paid
			FROM #IQAgent_TVResults_IQAnalytic tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
	--		WHERE tv.RL_Station NOT IN (SELECT StationID FROM @IQ_ADS_Station_Control)
			GROUP BY ClientGUID,CONVERT(DATE,LocalTime),SearchRequestID,RL_Market

			-- For Hour Summary
			INSERT INTO  #IQAgent_EarnedPaidHourSummary_OldHits
				(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
				[NumberOFHits],
				[Earned],
				[Paid]
				)
			Select  ClientGUID,
				DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)) AS HourDateTime,
				SearchRequestID,
				RL_Market,
				SUM( ISNULL(tv.Number_Hits,0)) AS NoOfHits,
				SUM( ISNULL(tv.Earned,0)) AS Earned,
				SUM( ISNULL(tv.Paid,0)) AS Paid
			FROM #IQAgent_TVResults_IQAnalytic tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
	--		WHERE tv.RL_Station NOT IN (SELECT StationID FROM @IQ_ADS_Station_Control)
			GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)),SearchRequestID,RL_Market

-- Get new Value of the Number of Hits
			-- For Day Summary GMT Time
			INSERT INTO  #IQAgent_EarnedPaidDaySummary_NewHits
				(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[NumberOFHits]
				)
			Select  ClientGUID,
				CONVERT(DATE,tv.GMTDatetime),
				tv.SearchRequestID,
				tv.RL_Market,
				SUM( ISNULL(IQAgent_TVResults.Number_Hits,0)) AS NoOfHits
			FROM #IQAgent_TVResults_IQAnalytic tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			JOIN IQAgent_TVResults WITH(NOLOCK)
				 ON tv.ID = IQAgent_TVResults.ID
	--		WHERE tv.RL_Station NOT IN (SELECT StationID FROM @IQ_ADS_Station_Control)
			GROUP BY ClientGUID,CONVERT(DATE,tv.GMTDatetime),tv.SearchRequestID,tv.RL_Market

			-- For Day Summary Local Time
			INSERT INTO  #IQAgent_EarnedPaidLocalTimeDaySummary_NewHits
				(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[NumberOFHits]
				)
			Select  ClientGUID,
				CONVERT(DATE,LocalTime),
				tv.SearchRequestID,
				tv.RL_Market,
				SUM( ISNULL(IQAgent_TVResults.Number_Hits,0)) AS NoOfHits
			FROM #IQAgent_TVResults_IQAnalytic tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			JOIN IQAgent_TVResults WITH(NOLOCK)
				 ON tv.ID = IQAgent_TVResults.ID
	--		WHERE tv.RL_Station NOT IN (SELECT StationID FROM @IQ_ADS_Station_Control)
			GROUP BY ClientGUID,CONVERT(DATE,LocalTime),tv.SearchRequestID,tv.RL_Market

			-- For Hour Summary
			INSERT INTO  #IQAgent_EarnedPaidHourSummary_NewHits
				(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
				[NumberOFHits]
				)
			Select  ClientGUID,
				DATEADD (HOUR,DATEPART(HOUR,tv.GMTDatetime), CONVERT(VARCHAR(10),tv.GMTDatetime,101)) AS HourDateTime,
				tv.SearchRequestID,
				tv.RL_Market,
				SUM( ISNULL(IQAgent_TVResults.Number_Hits,0)) AS NoOfHits
			FROM #IQAgent_TVResults_IQAnalytic tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			JOIN IQAgent_TVResults 	WITH(NOLOCK)
				 ON tv.ID = IQAgent_TVResults.ID
	--		WHERE tv.RL_Station NOT IN (SELECT StationID FROM @IQ_ADS_Station_Control)
           		GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,tv.GMTDatetime), CONVERT(VARCHAR(10),tv.GMTDatetime,101)),tv.SearchRequestID,tv.RL_Market


		END
	
	IF (SELECT COUNT(1) FROM #IQAgent_TVResults_Delete) > 0 OR (SELECT COUNT(1) FROM #IQAgent_TableResults_DirtyTable0) > 0 OR (SELECT COUNT(1) FROM #IQAgent_TVResults_IQAnalytic)> 0
	   BEGIN
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidDaySummary_Delete_ADS (ClientGUID,DayDate,SearchRequestID,Market)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidLocalTimeDaySummary_Delete_ADS (ClientGUID,DayDate,SearchRequestID,Market)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidHourSummary_Delete_ADS (ClientGUID,HourDateTime,SearchRequestID,Market)

			CREATE INDEX idx1 ON #IQAgent_EarnedPaidDaySummary_NewHits (ClientGUID,DayDate,SearchRequestID,Market)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidLocalTimeDaySummary_NewHits (ClientGUID,DayDate,SearchRequestID,Market)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidHourSummary_NewHits (ClientGUID,HourDateTime,SearchRequestID,Market)

			CREATE INDEX idx1 ON #IQAgent_EarnedPaidDaySummary_OldHits (ClientGUID,DayDate,SearchRequestID,Market)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidLocalTimeDaySummary_OldHits (ClientGUID,DayDate,SearchRequestID,Market)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidHourSummary_OldHits (ClientGUID,HourDateTime,SearchRequestID,Market)

			CREATE INDEX idx1 ON #IQAgent_TableResults_DirtyTable (Dirtytbl_ID)
			CREATE INDEX idx2 ON #IQAgent_TableResults_DirtyTable (_IQAgent_MediaID)
			CREATE INDEX idx1 ON #IQAgent_TableResults_DirtyTable0 (Dirtytbl_ID)
			CREATE INDEX idx2 ON #IQAgent_TableResults_DirtyTable0 (_IQAgent_MediaID)
			CREATE INDEX idx1 ON #IQAgent_TableResults_DirtyTable1 (Dirtytbl_ID)
			CREATE INDEX idx2 ON #IQAgent_TableResults_DirtyTable1 (_IQAgent_MediaID)

			EXEC @Status = usp_DBJob_RecalculateEarnedPaidSummary_ForTV  WITH RECOMPILE
			IF @Status = 0
			  SET @RecalStatus ='Recalculated TV Hits SUCCEEDED'
			ELSE
			  SET @RecalStatus ='Recalculated TV Hits FAILED'
	   END
	ELSE
	    SET @RecalStatus ='Recalculated TV Hits IDLE'

	RETURN 0
	
 /*
SET @QueryDetail ='Preparing MediaResults table'
SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
SET @Stopwatch = GETDATE()
*/
    
  END TRY        
  BEGIN CATCH        

   DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActive	BIT
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_DBJob_RecalculateEarnedPaidSummary',
				@ModifiedBy='usp_DBJob_RecalculateEarnedPaidSummary',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END

























GO


