USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_DeleteEarnedPaidSummary]    Script Date: 10/20/2016 2:59:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_DeleteEarnedPaidSummary]      
@NumberOfRecord INT,  @MaxIQSeqIDOfADS BIGINT,@DeleteStatus CHAR(20) OUTPUT
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY     
 
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
	[Paid] [INT] NULL,
	[IsActive] [BIT] NULL
	)

	CREATE TABLE #IQAgent_LRResults_Delete
	(
	[ID] [bigint] NOT NULL,
	[IQAgentSearchRequestID] [bigint] NOT NULL,
	[IQ_CC_KEY] [varchar](28) NOT NULL,
	[StartingPoint] [smallint] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalTime] [DATETIME] NULL,
	[RL_Market] VARCHAR(150) NULL,
	[Country_Number] SMALLINT NULL,
	[Stationid] [varchar](20) NULL,
	[NumberOfHits] [BIGINT] NULL,
	[Earned] [int] NULL,
	[Paid] [int] NULL,
	[IsActive] [BIT] NULL
	) 
	
		  CREATE TABLE #IQAgent_EarnedPaidSummary_Delete
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
	   
	 CREATE TABLE #IQAgent_EarnedPaidLocalTimeSummary_Delete
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

	CREATE TABLE #IQAgent_EarnedPaidHourSummary_Delete
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
	  
	 CREATE TABLE #IQAgent_EarnedPaidSummary
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
	   
	CREATE TABLE #IQAgent_EarnedPaidLocalTimeSummary
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

	CREATE TABLE #IQAgent_EarnedPaidHourSummary
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
   DECLARE @Status SMALLINT

     	 
	/*
	    DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff Float    ,@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
    SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_DBJob_EarnedPaidSummary' */
   
   -- Building IQAgent_QHTVResults_Delete from the IQAgent_QHTVLRResults_DirtyTable (#Tmp_DirtyTabl) For TV
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
			[Paid],
			[IsActive]
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
			[TV].[Earned],
			[TV].[Paid],
			[tmp].[IsActive]
			FROM IQAgent_TVResults tv  WITH (NOLOCK), #Tmp_DirtyTable tmp, IQAgent_SearchRequest sr  WITH (NOLOCK)
				WHERE tv.ID  = tmp._IQAgent_MediaID
				  AND tmp.MediaType ='TV'
				  AND tv.Process = 'Y'
				  AND sr.ID = tv.SearchRequestID
				
	IF (SELECT COUNT(1) FROM #IQAgent_TVResults_Delete) > 0
	    BEGIN
			
			-- For Day Summary GMT Time
			INSERT INTO  #IQAgent_EarnedPaidSummary_Delete
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOfHits],
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
			WHERE tv.IsActive = 0
			 	 GROUP BY ClientGUID,CONVERT(DATE,GMTDatetime),SearchRequestID,RL_Market,Country_Number

			-- For Day Summary Local Time
	   		INSERT INTO  #IQAgent_EarnedPaidLocalTimeSummary_Delete
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOfHits],
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
			WHERE tv.IsActive = 0
			 	 GROUP BY ClientGUID,CONVERT(DATE,LocalTime),SearchRequestID,RL_Market,Country_Number

			-- For Hour Summary
			INSERT INTO  #IQAgent_EarnedPaidHourSummary_Delete
			(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOfHits],
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
			WHERE tv.IsActive = 0
			 	 GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)),SearchRequestID,RL_Market,Country_Number

			-- This is for reactivate media through a SQL update
		 	-- For Day Summary GMT Time
			INSERT INTO  #IQAgent_EarnedPaidSummary
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOfHits],
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
			WHERE tv.IsActive = 1
			 	 GROUP BY ClientGUID,CONVERT(DATE,GMTDatetime),SearchRequestID,RL_Market,Country_Number

			-- For Day Summary Local Time
	   		INSERT INTO  #IQAgent_EarnedPaidLocalTimeSummary
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOfHits],
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
			WHERE tv.IsActive = 1
			 	 GROUP BY ClientGUID,CONVERT(DATE,LocalTime),SearchRequestID,RL_Market,Country_Number

			-- For Hour Summary
			INSERT INTO  #IQAgent_EarnedPaidHourSummary
			(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOFDocs],
				[NumberOfHits],
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
			WHERE tv.IsActive = 1
			 	 GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)),SearchRequestID,RL_Market,Country_Number	  

		END
			
	INSERT INTO #IQAgent_LRResults_Delete
		(
			[ID],
			[IQAgentSearchRequestID],
			[IQ_CC_KEY],
			[Stationid],
			[RL_Market],
			[Country_Number],
			[GMTDatetime],
			[LocalTime],
			[NumberOfHits],
			[Earned],
			[Paid],
			[IsActive] 
		)
	SELECT 
			[lr].[ID],
			[IQAgentSearchRequestID],
			[IQ_CC_KEY],
			[Stationid],
			(SELECT dma_name FROM IQ_STATION WITH (NOLOCK) WHERE IQ_STATION_ID = Stationid) AS RL_Market,
			(SELECT Country_Num FROM IQ_STATION WITH (NOLOCK) WHERE IQ_STATION_ID = Stationid) AS Country_Number,
			lr.GMTDateTime,
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(lr.GMTDatetime) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = sr.ClientGuid),lr.GMTDatetime) ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = sr.ClientGuid),lr.GMTDatetime) END),
			[lr].[NumOfHits],
			[lr].[Earned],
			[lr].[Paid],
			[tmp].[IsActive]
	FROM IQAgent_LRResults lr  WITH (NOLOCK), #Tmp_DirtyTable tmp, IQAgent_SearchRequest sr  WITH (NOLOCK)
		WHERE lr.ID = tmp._IQAgent_MediaID
		    AND MediaType = 'LR'
			AND lr.Process = 'Y'
			AND lr.IQAgentSearchRequestID = sr.ID




	IF (SELECT COUNT(1) FROM #IQAgent_LRResults_Delete) > 0
	   BEGIN
		-- Delete Media - Make IsActive to 0	
			-- For Day Summary GMT Time
			INSERT INTO  #IQAgent_EarnedPaidSummary_Delete
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOfDocs],
				[NumberOfHits],
				[Seen_Earned],
				[Seen_Paid]
			)
			Select  ClientGUID,
					CONVERT(DATE,GMTDatetime),
					IQAgentSearchRequestID,
					RL_Market,
					Country_Number, 
					COUNT(lr.ID) AS NoOfDocs,
					SUM( ISNULL(NumberOfHits,0)) AS NumberOfHits,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_LRResults_Delete lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE lr.IsActive = 0
			 	 GROUP BY ClientGUID,CONVERT(DATE,GMTDatetime),IQAgentSearchRequestID,RL_Market,Country_Number

			-- For Day Summary Local Time
			INSERT INTO  #IQAgent_EarnedPaidSummary_Delete
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOfDocs],
				[NumberOfHits],
				[Seen_Earned],
				[Seen_Paid]
			)
			Select  ClientGUID,
					CONVERT(DATE,LocalTime),
					IQAgentSearchRequestID,
					RL_Market,
					Country_Number, 
					COUNT(lr.ID) AS NoOfDocs,
					SUM( ISNULL(NumberOfHits,0)) AS NumberOfHits,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_LRResults_Delete lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE lr.IsActive = 0
			 	 GROUP BY ClientGUID,CONVERT(DATE,LocalTime),IQAgentSearchRequestID,RL_Market,Country_Number

			-- For Hour Summary
				INSERT INTO  #IQAgent_EarnedPaidHourSummary_Delete
			(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOfDocs],
				[NumberOfHits],
				[Seen_Earned],
				[Seen_Paid]
			)
			Select  ClientGUID,
					DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)) AS HourDateTime,
					IQAgentSearchRequestID,
					RL_Market,
					Country_Number, 
				    COUNT(lr.ID) AS NoOfDocs,
					SUM( ISNULL(NumberOfHits,0)) AS NumberOfHits,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_LRResults_Delete lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE lr.IsActive = 0
			 	 GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), 
				 CONVERT(VARCHAR(10),GMTDatetime,101)),IQAgentSearchRequestID,RL_Market,Country_Number
            
			-- Re-activate Media - Make IsActive to 1
			-- For Day Summary GMT Time
			INSERT INTO  #IQAgent_EarnedPaidSummary
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOfDocs],
				[NumberOfHits],
				[Seen_Earned],
				[Seen_Paid]
			)
			Select  ClientGUID,
					CONVERT(DATE,GMTDatetime),
					IQAgentSearchRequestID,
					RL_Market,
					Country_Number, 
					COUNT(lr.ID) AS NoOfDocs,
					SUM( ISNULL(NumberOfHits,0)) AS NumberOfHits,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_LRResults_Delete lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE lr.IsActive = 1
			 	 GROUP BY ClientGUID,CONVERT(DATE,GMTDatetime),IQAgentSearchRequestID,RL_Market,Country_Number

			-- For Day Summary Local Time
			INSERT INTO  #IQAgent_EarnedPaidLocalTimeSummary
			(
				[ClientGuid],
				[DayDate],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOfDocs],
				[NumberOfHits],
				[Seen_Earned],
				[Seen_Paid]
			)
			Select  ClientGUID,
					CONVERT(DATE,LocalTime),
					IQAgentSearchRequestID,
					RL_Market,
					Country_Number, 
					COUNT(lr.ID) AS NoOfDocs,
					SUM( ISNULL(NumberOfHits,0)) AS NumberOfHits,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_LRResults_Delete lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE lr.IsActive = 1
			 	 GROUP BY ClientGUID,CONVERT(DATE,LocalTime),IQAgentSearchRequestID,RL_Market,Country_Number

			-- For Hour Summary
				INSERT INTO  #IQAgent_EarnedPaidHourSummary
			(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
				[CountryNumber],
				[NumberOfDocs],
				[NumberOfHits],
				[Seen_Earned],
				[Seen_Paid]
			)
			Select  ClientGUID,
					DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)) AS HourDateTime,
					IQAgentSearchRequestID,
					RL_Market,
					Country_Number, 
				    COUNT(lr.ID) AS NoOfDocs,
					SUM( ISNULL(NumberOfHits,0)) AS NumberOfHits,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_LRResults_Delete lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			WHERE lr.IsActive = 1
			 	 GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), 
				 CONVERT(VARCHAR(10),GMTDatetime,101)),IQAgentSearchRequestID,RL_Market,Country_Number
			
	   END
	  
	
	IF (SELECT COUNT(1) FROM #IQAgent_EarnedPaidSummary_Delete) > 0 OR (SELECT COUNT(1) FROM #IQAgent_EarnedPaidSummary) > 0
	   BEGIN
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidSummary_Delete (ClientGUID,DayDate,SearchRequestID,Market,CountryNumber)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidLocalTimeSummary_Delete (ClientGUID,DayDate,SearchRequestID,Market,CountryNumber)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidHourSummary_Delete (ClientGUID,HourDateTime,SearchRequestID,Market,CountryNumber)

			CREATE INDEX idx1 ON #IQAgent_EarnedPaidSummary (ClientGUID,DayDate,SearchRequestID,Market,CountryNumber)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidLocalTimeSummary (ClientGUID,DayDate,SearchRequestID,Market,CountryNumber)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidHourSummary (ClientGUID,HourDateTime,SearchRequestID,Market,CountryNumber)

	        EXEC @Status = usp_DBJob_DeleteEarnedPaidSummary_ForTVLR  WITH RECOMPILE
			IF @Status = 0
			  SET @DeleteStatus ='DELETE TV/LR SUCCEEDED'
			ELSE
			  SET @DeleteStatus ='DELETE TV/LR FAILED'
		END
	ELSE
	  SET @DeleteStatus ='DELETE TV/LR IDLE'
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
				@CreatedBy='usp_DBJob_DeleteEarnedPaidSummary',
				@ModifiedBy='usp_DBJob_DeleteEarnedPaidSummary',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END

























GO


