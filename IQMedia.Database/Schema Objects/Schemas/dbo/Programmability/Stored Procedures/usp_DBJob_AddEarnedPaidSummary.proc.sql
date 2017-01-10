CREATE PROCEDURE [dbo].[usp_DBJob_AddEarnedPaidSummary]  (      
@NumberOfRecord INT,  @MaxIQSeqIDOfADS BIGINT,@InsertLRStatus CHAR(30) OUTPUT,  @InsertTVStatus CHAR(30) OUTPUT)
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY        
   DECLARE @Status SMALLINT

   CREATE TABLE  #NumberOFHitsChanged (IQAgent_TVResults_ID BIGINT) 

   CREATE TABLE #IQAgent_TVResults
   (
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[Rl_Station] VARCHAR(150) NULL,
	[RL_Market] VARCHAR(150) NULL,
	[Country_Number] SMALLINT NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
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
	[Earned] [BIGINT] NULL,
	[Paid] [BIGINT] NULL
	)
	
	CREATE TABLE #IQAgent_LRResults
	(
	[ID] [bigint] NOT NULL,
	[IQAgentSearchRequestID] [bigint] NOT NULL,
	[IQ_CC_KEY] [varchar](28) NOT NULL,
	[StartingPoint] [smallint] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[RL_Market] VARCHAR(150) NULL,
	[Country_Number] SMALLINT NULL,
	[Stationid] [varchar](20) NULL,
	[NumberOfHits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
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
	[Earned] [int] NULL,
	[Paid] [int] NULL
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
	[LocalHourDateTime] DATETIME NULL,
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

    -- DECLARE @LastIQSeqID BIGINT = 0
	 
	/*
	    DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff Float    ,@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
    SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_DBJob_EarnedPaidSummary' */
 
   INSERT INTO #IQAgent_TVResults
		(
			[ID],
			[SearchRequestID],
			[GMTDatetime],
			[LocalDatetime],
			[Rl_Station],
			[RL_Market],
			[Country_Number],
			[Number_Hits],
			[PositiveSentiment],
			[NegativeSentiment],
			[IQAdShareValue],
			[Nielsen_Audience],
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
	SELECT TOP (@NumberOfRecord)
			tv.ID,
			SearchRequestID,
			GMTDatetime,
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(GMTDatetime) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = sr.ClientGuid),GMTDatetime) ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = sr.ClientGuid),GMTDatetime) END),

			Rl_Station,
			RL_Market,
			(SELECT Country_Num FROM IQ_STATION WITH (NOLOCK) WHERE IQ_STATION_ID = Rl_Station) AS Country_Number,
			Number_Hits,
			ISNULL(Sentiment.query('Sentiment/PositiveSentiment').value('.','INT'),0) AS PositiveSentiment,
			ISNULL(Sentiment.query('Sentiment/NegativeSentiment').value('.','INT'),0)  AS NegativeSentiment,
			IQAdShareValue,
			Nielsen_Audience,
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
			AF65_Plus,
			Earned,
			Paid
			FROM IQAgent_TVResults tv WITH (NOLOCK)
			   JOIN #IQ_ADS_Results ads 
			   ON tv.IQ_CC_key = ads.IQ_CC_Key
			      AND tv.Process IS NULL
				  AND tv.IsActive = 1
				  AND (tv.Paid IS NOT NULL or tv.Earned IS NOT NULL)
			   JOIN IQAgent_SearchRequest sr WITH (NOLOCK)
			      ON tv.SearchRequestID = sr.ID

	IF (SELECT COUNT(1) FROM #IQAgent_TVResults) > 0
	    BEGIN
			
			INSERT INTO #NumberOFHitsChanged(IQAgent_TVResults_ID)
			   SELECT ID FROM #IQAgent_TVResults WHERE (Earned + Paid) != Number_Hits

            DELETE #IQAgent_TVResults
			   FROM #IQAgent_TVResults JOIN #NumberOFHitsChanged tmp ON ID = tmp.IQAgent_TVResults_ID

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
				--	SUM( ISNULL(Nielsen_Audience,0)) AS TotalAudience,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
					SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_TVResults tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			 	 GROUP BY ClientGUID,CONVERT(DATE,GMTDatetime),SearchRequestID,RL_Market,Country_Number -- RL_Station,

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
					CONVERT(DATE,LocalDatetime),	
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
				--	SUM( ISNULL(Nielsen_Audience,0)) AS TotalAudience,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
					SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_TVResults tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			 	 GROUP BY ClientGUID,CONVERT(DATE,LocalDateTime),SearchRequestID,RL_Market,Country_Number -- RL_Station,

			-- For Hour Summary
			INSERT INTO  #IQAgent_EarnedPaidHourSummary
			(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
			--	[Station],
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
			--		Rl_Station,
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
				--	SUM( ISNULL(Nielsen_Audience,0)) AS TotalAudience,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
					SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
					SUM( ISNULL(Earned,0)) AS Heard_Earned,
					SUM( ISNULL(Paid,0)) AS Heard_Paid
			FROM #IQAgent_TVResults tv WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON SearchRequestID	= IQAgent_SearchRequest.ID 
			 	 GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)),SearchRequestID,RL_Market,Country_Number -- RL_Station,

			UPDATE #IQAgent_EarnedPaidHourSummary SET LocalHourDateTime  = CONVERT(datetime,CASE WHEN dbo.fnIsDayLightSaving(HourDateTime) = 1 THEN  
				DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = sr.ClientGuid),HourDateTime) 
				ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = sr.ClientGuid),HourDateTime) END)
				FROM 	#IQAgent_EarnedPaidHourSummary JOIN IQAgent_SearchRequest sr WITH (NOLOCK) ON SearchRequestID = ID

			CREATE INDEX idx1 ON #IQAgent_TVResults(ID)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidSummary (ClientGUID,DayDate,SearchRequestID,Market,CountryNumber)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidLocalTimeSummary (ClientGUID,DayDate,SearchRequestID,Market,CountryNumber)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidHourSummary (ClientGUID,HourDateTime,SearchRequestID,Market,CountryNumber)

			EXEC @Status = usp_DBJob_AddEarnedPaidSummary_TV @MaxIQSeqIDOfADS WITH RECOMPILE
			IF @Status = 0
			  SET @InsertTVStatus ='INSERT TV SUCCEEDED'
			ELSE
			  SET @InsertTVStatus ='INSERT TV FAILED'
		   
		   DROP INDEX idx1 ON #IQAgent_EarnedPaidSummary
		   DROP INDEX idx1 ON #IQAgent_EarnedPaidLocalTimeSummary
		   DROP INDEX idx1 ON #IQAgent_EarnedPaidHourSummary
		   TRUNCATE TABLE #IQAgent_EarnedPaidSummary
		   TRUNCATE TABLE #IQAgent_EarnedPaidLocalTimeSummary
		   TRUNCATE TABLE #IQAgent_EarnedPaidHourSummary
		END
	ELSE
	  BEGIN
		SET @InsertTVStatus ='INSERT TV IDLE'
		IF EXISTS (SELECT ID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE MediaType='SADS')
				UPDATE IQ_DBJobLastIQSeqID SET LastIQSeqID = @MaxIQSeqIDOfADS, ModifiedDate = GETDATE() WHERE MediaType='SADS'
		ELSE
				INSERT INTO IQ_DBJobLastIQSeqID (MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive) 
				VALUES('SADS',@MaxIQSeqIDOfADS,GETDATE(),GETDATE(),1)
	  END
	
	INSERT INTO #IQAgent_LRResults
		(
			[ID],
			[IQAgentSearchRequestID],
			[IQ_CC_KEY],
			[Stationid],
			[RL_Market],
			[Country_Number],
			[GMTDatetime],
			[LocalDateTime],
			[NumberOfHits],
			[PositiveSentiment],
			[NegativeSentiment],
			[IQAdShareValue],
			[Nielsen_Audience],
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
	SELECT TOP (@NumberOfRecord)
			lr.ID,
			IQAgentSearchRequestID,
			lr.IQ_CC_KEY,
			Stationid,
			(SELECT dma_name FROM IQ_STATION WITH (NOLOCK) WHERE IQ_STATION_ID = Stationid) AS dma_name,
			(SELECT Country_Num FROM IQ_STATION WITH (NOLOCK) WHERE IQ_STATION_ID = Stationid) AS Country_Number,
			lr.GMTDateTime,
				CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(lr.GMTDateTime) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = sr.ClientGuid),lr.GMTDateTime) ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = sr.ClientGuid),lr.GMTDateTime) END),
			NumOfHits,
			ISNULL(Sentiment.query('Sentiment/PositiveSentiment').value('.','INT'),0) AS PositiveSentiment,
			ISNULL(Sentiment.query('Sentiment/NegativeSentiment').value('.','INT'),0)  AS NegativeSentiment,
			IQAdShareValue,
			Nielsen_Audience,
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
			AF65_Plus,
			lr.Earned,
			lr.Paid
	FROM IQAgent_LRResults lr
	     JOIN #IQ_ADS_Results ads 
			   ON lr.IQ_CC_key = ads.IQ_CC_Key
			      AND lr.Process IS NULL
				  AND lr.IsActive = 1
				  AND (lr.Earned IS NOT NULL or lr.Paid IS NOT NULL)
		 JOIN IQAgent_SearchRequest sr WITH (NOLOCK)
			       ON lr.IQAgentSearchRequestID = sr.ID
		 JOIN IQAgent_TVResults tv WITH (NOLOCK)
				   ON tv._LRResultsID = lr.ID

	IF (SELECT COUNT(1) FROM #IQAgent_LRResults) > 0
	   BEGIN
			
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
				--	SUM( ISNULL(Nielsen_Audience,0)) AS TotalAudience,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
					SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
					SUM( ISNULL(Earned,0)) AS Seen_Earned,
					SUM( ISNULL(Paid,0)) AS Seen_Paid
			FROM #IQAgent_LRResults lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			 	 GROUP BY ClientGUID,CONVERT(DATE,GMTDatetime),IQAgentSearchRequestID,RL_Market,Country_Number -- Stationid,

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
				[Seen_Earned],
				[Seen_Paid]
			)
			Select  ClientGUID,
					CONVERT(DATE,LocalDateTime),
					IQAgentSearchRequestID,
					RL_Market,
					Country_Number, 
					COUNT(lr.ID) AS NoOfDocs,
					SUM( ISNULL(NumberOfHits,0)) AS NumberOfHits,
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
				--	SUM( ISNULL(Nielsen_Audience,0)) AS TotalAudience,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
					SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
					SUM( ISNULL(Earned,0)) AS Seen_Earned,
					SUM( ISNULL(Paid,0)) AS Seen_Paid
			FROM #IQAgent_LRResults lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			 	 GROUP BY ClientGUID,CONVERT(DATE,LocalDateTime),IQAgentSearchRequestID,RL_Market,Country_Number -- Stationid,

			-- For Hour Summary
				INSERT INTO  #IQAgent_EarnedPaidHourSummary
			(
				[ClientGuid],
				[HourDateTime],
				[SearchRequestID],
				[Market],
			--	[Station],
				[CountryNumber],
				[NumberOfDocs],
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
				[Seen_Earned],
				[Seen_Paid]
			)
			Select  ClientGUID,
					DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)) AS HourDateTime,
					IQAgentSearchRequestID,
					RL_Market,
				--	Stationid,
					Country_Number, 
					COUNT(lr.ID) AS NoOfDocs,
					SUM( ISNULL(NumberOfHits,0)) AS NumberOfHits,
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
				--	SUM( ISNULL(Nielsen_Audience,0)) AS TotalAudience,
					SUM( ISNULL(PositiveSentiment,0)) AS PositiveSentiment,
					SUM( ISNULL(NegativeSentiment,0)) AS NegativeSentiment,
					SUM( ISNULL(IQAdShareValue,0)) AS IQAdShareValue,
					SUM( ISNULL(Earned,0)) AS Seen_Earned,
					SUM( ISNULL(Paid,0)) AS Seen_Paid
			FROM #IQAgent_LRResults  lr WITH(NOLOCK)
			JOIN dbo.IQAgent_SearchRequest 	WITH(NOLOCK)
			 	 ON IQAgentSearchRequestID	= IQAgent_SearchRequest.ID 
			 	 GROUP BY ClientGUID,DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), 
				 CONVERT(VARCHAR(10),GMTDatetime,101)),IQAgentSearchRequestID,RL_Market,Country_Number --Stationid,
			
			UPDATE #IQAgent_EarnedPaidHourSummary SET LocalHourDateTime  = CONVERT(datetime,CASE WHEN dbo.fnIsDayLightSaving(HourDateTime) = 1 THEN  
				DATEADD(HOUR,(SELECT gmt + dst From Client where ClientGuid = sr.ClientGuid),HourDateTime) 
				ELSE DATEADD(HOUR,(SELECT gmt From Client where ClientGuid = sr.ClientGuid),HourDateTime) END)
				FROM 	#IQAgent_EarnedPaidHourSummary JOIN IQAgent_SearchRequest sr WITH (NOLOCK) ON SearchRequestID = ID

			CREATE INDEX idx1 ON #IQAgent_LRResults(ID)
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidSummary (ClientGUID,DayDate,SearchRequestID,Market,CountryNumber) -- Station,
			CREATE INDEX idx1 ON #IQAgent_EarnedPaidHourSummary (ClientGUID,HourDateTime,SearchRequestID,Market,CountryNumber) -- Station,
			
			EXEC @Status = usp_DBJob_AddEarnedPaidSummary_LR @MaxIQSeqIDOfADS WITH RECOMPILE
			IF @Status = 0
			  SET @InsertLRStatus ='INSERT LOGO SUCCEEDED'
			ELSE
			  SET @InsertLRStatus ='INSERT LOGO FAILED'
					
	   END
    ELSE
	  BEGIN
	   SET @InsertLRStatus ='INSERT LOGO IDLE'
	   IF EXISTS (SELECT ID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE MediaType='SADS')
				UPDATE IQ_DBJobLastIQSeqID SET LastIQSeqID = @MaxIQSeqIDOfADS, ModifiedDate = GETDATE() WHERE MediaType='SADS'
		ELSE
				INSERT INTO IQ_DBJobLastIQSeqID (MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive) 
				VALUES('SADS',@MaxIQSeqIDOfADS,GETDATE(),GETDATE(),1)
	  END

 /*
SET @QueryDetail ='Preparing MediaResults table'
SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
SET @Stopwatch = GETDATE()
*/
 
  Return 0      
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
				@CreatedBy='usp_DBJob_EarnedPaidSummary',
				@ModifiedBy='usp_DBJob_EarnedPaidSummary',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END


























GO


