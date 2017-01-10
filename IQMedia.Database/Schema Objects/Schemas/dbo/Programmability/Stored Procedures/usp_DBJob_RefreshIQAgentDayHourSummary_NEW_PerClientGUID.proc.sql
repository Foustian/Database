USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_RefreshIQAgentDayHourSummary_NEW_PerClientGUID]    Script Date: 10/20/2016 3:18:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_RefreshIQAgentDayHourSummary_NEW_PerClientGUID]        
@ClientGUID UNIQUEIDENTIFIER, @AgentID BIGINT, @StartDate DATE, @EndDate DATE, @Process CHAR(1), @Message VARCHAR(200) OUTPUT
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
   
   /*
SELECT * from IQMediaGroupException where convert(date,createddate)='2016-09-19'
delete IQMediaGroupException where IQMediaGroupExceptionKey >= 130185

DECLARE @Message VARCHAR(100)
DECLARE @ClientGUID UNIQUEIDENTIFIER='43E4329E-9C07-4374-9C50-5725190D9D54'
DECLARE @AgentID BIGINT = NULL
DECLARE @StartDate DATE = '2015-01-01'
DECLARE @EndDate DATE = '2015-01-31'
exec usp_DBJob_IQAnalyticProcessPerClientGUID1 @ClientGUID, @AgentID, @StartDate, @EndDate, @Message =@Message OUTPUT
SELECT @Message

*/     
  
 BEGIN TRY  

	CREATE TABLE #IQAgent_TVResults
   	(
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[DateTimeHour] [DATETIME] NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
	[v5MediaType] VARCHAR(2) NULL,
	[v5Category] VARCHAR(15) NULL,
	[Process] CHAR(1) NULL
	)      

	CREATE TABLE #IQAgent_LRResults
   	(
[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[DateTimeHour] [DATETIME] NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
	[v5MediaType] VARCHAR(2) NULL,
	[v5Category] VARCHAR(15) NULL,
	[Process] CHAR(1) NULL
	)      

	CREATE TABLE #IQAgent_NMResults
   	(
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[DateTimeHour] [DATETIME] NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
	[v5MediaType] VARCHAR(2) NULL,
	[v5Category] VARCHAR(15) NULL,
	[Process] CHAR(1) NULL
	)      

	CREATE TABLE #IQAgent_SMResults
   	(
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[DateTimeHour] [DATETIME] NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
	[v5MediaType] VARCHAR(2) NULL,
	[v5Category] VARCHAR(15) NULL,
	[Process] CHAR(1) NULL
	)      

	CREATE TABLE #IQAgent_TWitterResults
   	(
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[DateTimeHour] [DATETIME] NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
	[v5MediaType] VARCHAR(2) NULL,
	[v5Category] VARCHAR(15) NULL,
	[Process] CHAR(1) NULL
	)      

	CREATE TABLE #IQAgent_TVEyesResults
   	(
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[DateTimeHour] [DATETIME] NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
	[v5MediaType] VARCHAR(2) NULL,
	[v5Category] VARCHAR(15) NULL,
	[Process] CHAR(1) NULL
	)      

	CREATE TABLE #IQAgent_BLPMResults
   	(
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[DateTimeHour] [DATETIME] NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
	[v5MediaType] VARCHAR(2) NULL,
	[v5Category] VARCHAR(15) NULL,
	[Process] CHAR(1) NULL
	)      

	CREATE TABLE #IQAgent_PQResults
   	(
	[ID] [BIGINT]  NOT NULL,
	[SearchRequestID] [BIGINT] NULL,
	[GMTDatetime] [DATETIME] NULL,
	[LocalDatetime] [DATETIME] NULL,
	[DateTimeHour] [DATETIME] NULL,
	[Number_Hits] [BIGINT] NULL,
	[PositiveSentiment] [INT] NULL,
	[NegativeSentiment] [INT] NULL,
	[IQAdShareValue] [FLOAT] NULL,
	[Nielsen_Audience] [BIGINT] NULL,
	[v5MediaType] VARCHAR(2) NULL,
	[v5Category] VARCHAR(15) NULL,
	[Process] CHAR(1) NULL
	)      

            
      	CREATE TABLE #TmpDaySummaryResults
	(
		[MediaDate] DATE NOT NULL,
		[ClientGUID] UNIQUEIDENTIFIER NOT NULL,
		[MediaType] VARCHAR(2) NOT NULL,
		[SubMediaType] VARCHAR(50)  NOT NULL,		
		[_SearchRequestID] BIGINT NOT NULL,
		[NoOfDocs] INT  NULL,
		[NoOfHits] BIGINT  NULL,
		[Audience] BIGINT  NULL,
		[MediaValue] Float    NULL,
		[PositiveSentiment] BIGINT  NULL,
		[NegativeSentiment] BIGINT  NULL
	)
	
	CREATE TABLE #TmpDaySummaryLDResults
	(
		[LocalMediaDate] DATE NOT NULL,
		[ClientGUID] UNIQUEIDENTIFIER NOT NULL,
		[MediaType] VARCHAR(2) NOT NULL,
		[SubMediaType] VARCHAR(50)  NOT NULL,		
		[_SearchRequestID] BIGINT NOT NULL,
		[NoOfDocs] INT  NULL,
		[NoOfHits] BIGINT  NULL,
		[Audience] BIGINT  NULL,
		[MediaValue] Float     NULL,
		[PositiveSentiment] BIGINT  NULL,
		[NegativeSentiment] BIGINT  NULL
	)
	
	CREATE TABLE #TmpHourSummaryResults
	(
		[MediaDateTime] DATETIME NOT NULL,
		[ClientGUID] UNIQUEIDENTIFIER NOT NULL,
		[MediaType] VARCHAR(2) NOT NULL,
		[SubMediaType] VARCHAR(50)  NOT NULL,		
		[_SearchRequestID] BIGINT NOT NULL,
		[LocalMediaDateTime] DATETIME NULL,
		[NoOfDocs] INT  NULL,
		[NoOfHits] BIGINT NULL,
		[Audience] BIGINT  NULL,
		[MediaValue] Float      NULL,
		[PositiveSentiment] BIGINT  NULL,
		[NegativeSentiment] BIGINT  NULL
	)

 /*
	DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff Float    ,@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
    	SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_DBJob_IQAnalyticProcessPerAgentID' 
*/
	
	DECLARE @status SMALLINT
	DECLARE @AgentTbl TABLE (AgentID BIGINT)

	IF @ClientGUID IS NULL
       BEGIN
	     PRINT 'usage: EXEC usp_DBJob_IQAnalyticProcessPerClientGUID1 @ClientGUID, @AgentID NULL=All Clien Agents, @StartDate, @EndDate, @Message=@Message OUTPUT --Date=Media Created Date'
	     RETURN 0
	   END
	ELSE
	   BEGIN
		 IF NOT EXISTS(SELECT * FROM IQAgent_SearchRequest WITH (NOLOCK) WHERE ClientGUID = @ClientGUID and IsActive = 1)
			BEGIN
				PRINT 'The Client GUID does not exists or inactive'
				RETURN 0
			END
	   END
	 
	IF @AgentID IS  NULL
	   INSERT INTO @AgentTbl(AgentID) SELECT ID FROM IQAgent_SearchRequest WITH (NOLOCK) WHERE ClientGUID = @ClientGUID and IsActive = 1
	ELSE
	   INSERT INTO @AgentTbl(AgentID) VALUES(@AgentID)
      
-- For TV

	INSERT INTO #IQAgent_TVResults
		(
			[ID],
			[SearchRequestID],
			[GMTDatetime],
			[LocalDatetime],
			[DateTimeHour],
			[Number_Hits],
			[PositiveSentiment],
			[NegativeSentiment],
			[IQAdShareValue],
			[Nielsen_Audience],
			[v5MediaType],
			[v5Category],
			[Process]
		)
	SELECT 
			tv.ID,
			SearchRequestID,
			GMTDatetime,
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(GMTDatetime) = 1 THEN  
			DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),GMTDatetime) 
			ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),GMTDatetime) END) AS LocalDateTime,
			DATEADD (HOUR,DATEPART(HOUR,GMTDatetime), CONVERT(VARCHAR(10),GMTDatetime,101)) AS DateTimeHour,
			Number_Hits,
			-- ISNULL(Sentiment.query('Sentiment/PositiveSentiment').value('.','INT'),0) AS PositiveSentiment,
			-- ISNULL(Sentiment.query('Sentiment/NegativeSentiment').value('.','INT'),0)  AS NegativeSentiment,
			ISNULL(mr.PositiveSentiment,0) AS PositiveSentiment,
			ISNULL(mr.NegativeSentiment,0) AS NegativeSentiment,
			IQAdShareValue,
			Nielsen_Audience,
			mr.v5MediaType,
			mr.v5Category,
			Process
	FROM IQAgent_TVResults tv WITH (NOLOCK)
		JOIN @AgentTbl AgentTbl ON SearchRequestID = AgentTbl.AgentID
		JOIN IQAgent_MediaResults mr ON mr._MediaID = tv.ID AND mr.MediaType='TV'
	WHERE (CONVERT(DATE,tv.CreatedDate) >= @StartDate AND CONVERT(DATE,tv.CreatedDate) <= @EndDate) AND tv.IsActive = 1 

-- Section For NM
	
	INSERT INTO #IQAgent_NMResults
		(
			[ID],
			[SearchRequestID],
			[GMTDatetime],
			[LocalDatetime],
			[DateTimeHour],
			[Number_Hits],
			[IQAdShareValue],
			[Nielsen_Audience],
			[v5MediaType],
			[v5Category],
			[PositiveSentiment],
			[NegativeSentiment]
		)
	SELECT  NM.ID,
			IQAgentSearchRequestID,
			Harvest_time,
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(Harvest_time) = 1 THEN  
			DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),Harvest_time) 
			ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),Harvest_time) END) AS LocalDatetime,
			DATEADD (HOUR,DATEPART(HOUR,Harvest_time), CONVERT(VARCHAR(10),Harvest_time,101)) AS DateTimeHour,
			Number_Hits,
			IQAdShareValue,
			Compete_Audience,
			mr.v5MediaType,
			mr.v5Category,
			ISNULL(mr.PositiveSentiment,0) AS PositiveSentiment,
			ISNULL(mr.NegativeSentiment,0) AS NegativeSentiment
		--	Earned,
		--	Paid
		FROM  IQAgent_NMResults  NM WITH(NOLOCK) 
			JOIN @AgentTbl AgentTbl ON IQAgentSearchRequestID = AgentTbl.AgentID
			JOIN IQAgent_MediaResults mr ON mr._MediaID = NM.ID AND mr.MediaType='NM'  
		WHERE (CONVERT(DATE,CreatedDate) >= @StartDate AND CONVERT(DATE,CreatedDate ) <= @EndDate) AND  NM.IsActive = 1 
		AND (isDuplicate = 0 OR isDuplicate IS NULL) -- AND Number_Hits > 0
	
-- For SM

	INSERT INTO #IQAgent_SMResults
		(
			[ID],
			[SearchRequestID],
			[GMTDatetime],
			[LocalDatetime],
			[DateTimeHour],
			[Number_Hits],
			[IQAdShareValue],
			[Nielsen_Audience],
			[v5MediaType],
			[v5Category],
			[PositiveSentiment],
			[NegativeSentiment]
		)
	SELECT  SM.ID,
			IQAgentSearchRequestID,
			itemHarvestDate_DT,
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(itemHarvestDate_DT) = 1 THEN  
			DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),itemHarvestDate_DT) 
			ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),itemHarvestDate_DT) END),
			DATEADD (HOUR,DATEPART(HOUR,itemHarvestDate_DT), CONVERT(VARCHAR(10),itemHarvestDate_DT,101)),
			Number_Hits,
			IQAdShareValue,
			Compete_Audience,
			mr.v5MediaType,
			mr.v5Category,
			ISNULL(mr.PositiveSentiment,0) AS PositiveSentiment,
			ISNULL(mr.NegativeSentiment,0) AS NegativeSentiment
		FROM  IQAgent_SMResults  SM WITH(NOLOCK) 
			JOIN @AgentTbl AgentTbl ON IQAgentSearchRequestID = AgentTbl.AgentID
			JOIN IQAgent_MediaResults mr ON mr._MediaID = SM.ID AND mr.MediaType='SM' 
		WHERE (CONVERT(DATE,CreatedDate) >= @StartDate AND CONVERT(DATE,CreatedDate ) <= @EndDate) AND SM.IsActive = 1 
		-- AND (isDuplicate = 0 OR isDuplicate IS NULL) -- AND Number_Hits > 0
        
-- For  Twitter
	INSERT INTO #IQAgent_TwitterResults
			(
			[ID],
			[SearchRequestID],
			[GMTDatetime],
			[LocalDatetime],
			[DateTimeHour],
			[Number_Hits],
			[Nielsen_Audience],
			[IQAdShareValue],
			[v5MediaType],
			[v5Category],
			[PositiveSentiment],
			[NegativeSentiment]
			)
	SELECT  TW.ID,
			IQAgentSearchRequestID,
			tweet_posteddatetime,
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(tweet_posteddatetime) = 1 THEN  
			DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),tweet_posteddatetime) 
			ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),tweet_posteddatetime) END),
			DATEADD (HOUR,DATEPART(HOUR,tweet_posteddatetime), CONVERT(VARCHAR(10),tweet_posteddatetime,101)),
			Number_Hits,
			actor_followersCount AS Audience,
			gnip_klout_score AS IQMediaValue,
			mr.v5MediaType,
			mr.v5Category,
			ISNULL(mr.PositiveSentiment,0) AS PositiveSentiment,
			ISNULL(mr.NegativeSentiment,0) AS NegativeSentiment
		FROM  IQAgent_TwitterResults TW  WITH(NOLOCK) 
			JOIN @AgentTbl AgentTbl ON IQAgentSearchRequestID = AgentTbl.AgentID
			JOIN IQAgent_MediaResults mr ON mr._MediaID = TW.ID AND mr.MediaType='TW'
		WHERE (CONVERT(DATE,CreatedDate) >= @StartDate AND CONVERT(DATE,CreatedDate ) <= @EndDate) AND TW.IsActive = 1

	INSERT INTO #IQAgent_TVEyesResults
			(
			[ID],
			[SearchRequestID],
			[GMTDatetime],
			[LocalDatetime],
			[DateTimeHour],
			[v5MediaType],
			[v5Category],
			[PositiveSentiment],
			[NegativeSentiment]
			
			)
	SELECT  TM.ID,
			SearchRequestID,
			[UTCDateTime],
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(UTCDateTime) = 1 THEN  
			DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),UTCDateTime) 
			ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),UTCDateTime) END) AS LocalDatetime,
			DATEADD (HOUR,DATEPART(HOUR,UTCDateTime), CONVERT(VARCHAR(10),UTCDateTime,101)) AS DateTimeHour,
			mr.v5MediaType,
			mr.v5Category,
			ISNULL(mr.PositiveSentiment,0) AS PositiveSentiment,
			ISNULL(mr.NegativeSentiment,0) AS NegativeSentiment
		FROM  IQAgent_TVEyesResults  TM WITH(NOLOCK) 
			JOIN @AgentTbl AgentTbl ON SearchRequestID = AgentTbl.AgentID
			JOIN IQAgent_MediaResults mr ON mr._MediaID = TM.ID AND mr.MediaType='TM'
		WHERE (CONVERT(DATE,CreatedDate) >= @StartDate AND CONVERT(DATE,CreatedDate ) <= @EndDate) AND TM.IsActive = 1 

				 	 
-- Section For PM 

	INSERT INTO #IQAgent_BLPMResults
			(
			[ID],
			[SearchRequestID],
			[GMTDatetime],
			[LocalDatetime],
			[DateTimeHour],
			[Nielsen_Audience],
			[v5MediaType],
			[v5Category],
			[PositiveSentiment],
			[NegativeSentiment]
			)
	SELECT  BLPM.ID,
			SearchRequestID,
			PubDate,
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(PubDate) = 1 THEN  
			DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),PubDate) 
			ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),PubDate) END),
			DATEADD (HOUR,DATEPART(HOUR,PubDate), CONVERT(VARCHAR(10),PubDate,101)),
			Circulation,
			mr.v5MediaType,
			mr.v5Category,
			ISNULL(mr.PositiveSentiment,0) AS PositiveSentiment,
			ISNULL(mr.NegativeSentiment,0) AS NegativeSentiment
		FROM  IQAgent_BLPMResults BLPM WITH(NOLOCK) 
			JOIN @AgentTbl AgentTbl ON SearchRequestID = AgentTbl.AgentID
			JOIN IQAgent_MediaResults mr ON mr._MediaID = BLPM.ID AND mr.MediaType='PM'
		WHERE (CONVERT(DATE,CreatedDate) >= @StartDate AND CONVERT(DATE,CreatedDate ) <= @EndDate) AND BLPM.IsActive = 1 

-- For PQ
	INSERT INTO #IQAgent_PQResults
			(
			[ID],
			[SearchRequestID],
			[GMTDatetime],
			[LocalDatetime],
			[DateTimeHour],
			[Number_Hits],
			[v5MediaType],
			[v5Category],
			[PositiveSentiment],
			[NegativeSentiment]
			)
	SELECT  PQ.ID,
			IQAgentSearchRequestID,
			PQ.MediaDate,
			CONVERT(date,CASE WHEN dbo.fnIsDayLightSaving(PQ.MediaDate) = 1 THEN  
			DATEADD(HOUR,(SELECT gmt + dst From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),PQ.MediaDate) 
			ELSE DATEADD(HOUR,(SELECT gmt From Client WITH (NOLOCK) where ClientGuid = @ClientGuid),PQ.MediaDate) END),
			DATEADD (HOUR,DATEPART(HOUR,PQ.MediaDate), CONVERT(VARCHAR(10),PQ.MediaDate,101)),
			Number_Hits,
			mr.v5MediaType,
			mr.v5Category,
			ISNULL(mr.PositiveSentiment,0) AS PositiveSentiment,
			ISNULL(mr.NegativeSentiment,0) AS NegativeSentiment
		FROM  IQAgent_PQResults   PQ WITH(NOLOCK) 
			JOIN @AgentTbl AgentTbl ON IQAgentSearchRequestID = AgentTbl.AgentID
			JOIN IQAgent_MediaResults mr ON mr._MediaID = PQ.ID AND mr.MediaType='PQ'
		WHERE (CONVERT(DATE,CreatedDate) >= @StartDate AND CONVERT(DATE,CreatedDate ) <= @EndDate) AND PQ.IsActive = 1 


   		   Create index idx1_IQAgent_TVResults on #IQAgent_TVResults(SearchRequestID,GMTDatetime,v5Mediatype,v5Category)
		   Create index idx2_IQAgent_TVResults on #IQAgent_TVResults(SearchRequestID,LocalDatetime,v5Mediatype,v5Category)
		   Create index idx3_IQAgent_TVResults on #IQAgent_TVResults(SearchRequestID,DateTimeHour,v5Mediatype,v5Category)
	--	   Create index idx4_IQAgent_TVResults on #IQAgent_TVResults(ID)

		    Create index idx1_IQAgent_LRResults on #IQAgent_LRResults(SearchRequestID,GMTDatetime,v5Mediatype,v5Category)
		   Create index idx2_IQAgent_LRResults on #IQAgent_LRResults(SearchRequestID,LocalDatetime,v5Mediatype,v5Category)
		   Create index idx3_IQAgent_LRResults on #IQAgent_LRResults(SearchRequestID,DateTimeHour,v5Mediatype,v5Category)
	--	   Create index idx4_IQAgent_LRResults on #IQAgent_LRResults(ID)

		   Create index idx1_IQAgent_NMResults on #IQAgent_NMResults(SearchRequestID,GMTDatetime,v5Mediatype,v5Category)
		   Create index idx2_IQAgent_NMVResults on #IQAgent_NMResults(SearchRequestID,LocalDatetime,v5Mediatype,v5Category)
		   Create index idx3_IQAgent_NMResults on #IQAgent_NMResults(SearchRequestID,DateTimeHour,v5Mediatype,v5Category)
		--   Create index idx4_IQAgent_NMResults on #IQAgent_NMResults(ID)

		    Create index idx1_IQAgent_SMResults on #IQAgent_SMResults(SearchRequestID,GMTDatetime,v5Mediatype,v5Category)
		   Create index idx2_IQAgent_SMResults on #IQAgent_SMResults(SearchRequestID,LocalDatetime,v5Mediatype,v5Category)
		   Create index idx3_IQAgent_SMResults on #IQAgent_SMResults(SearchRequestID,DateTimeHour,v5Mediatype,v5Category)
		--   Create index idx4_IQAgent_SMResults on #IQAgent_SMResults(ID)

			Create index idx1_IQAgent_TwitterResults on #IQAgent_TwitterResults(SearchRequestID,GMTDatetime,v5Mediatype,v5Category)
		   Create index idx2_IQAgent_TwitterResults on #IQAgent_TwitterResults(SearchRequestID,LocalDatetime,v5Mediatype,v5Category)
		   Create index idx3_IQAgent_TwitterResults on #IQAgent_TwitterResults(SearchRequestID,DateTimeHour,v5Mediatype,v5Category)
		--   Create index idx4_IQAgent_TwitterResults on #IQAgent_TwitterResults(ID)

		   Create index idx1_IQAgent_TVEyesResults on #IQAgent_TVEyesResults(SearchRequestID,GMTDatetime,v5Mediatype,v5Category)
		   Create index idx2_IQAgent_TVEyesResults on #IQAgent_TVEyesResults(SearchRequestID,LocalDatetime,v5Mediatype,v5Category)
		   Create index idx3_IQAgent_TVEyesResults on #IQAgent_TVEyesResults(SearchRequestID,DateTimeHour,v5Mediatype,v5Category)
		--   Create index idx4_IQAgent_TVEyesResults on #IQAgent_TVEyesResults(ID)

		   Create index idx1_IQAgent_BLPMResults on #IQAgent_BLPMResults(SearchRequestID,GMTDatetime,v5Mediatype,v5Category)
		   Create index idx2_IQAgent_BLPMResults on #IQAgent_BLPMResults(SearchRequestID,LocalDatetime,v5Mediatype,v5Category)
		   Create index idx3_IQAgent_BLPMResults on #IQAgent_BLPMResults(SearchRequestID,DateTimeHour,v5Mediatype,v5Category)
	--	   Create index idx4_IQAgent_BLPMResults on #IQAgent_BLPMResults(ID)

		   Create index idx1_IQAgent_PQResults on #IQAgent_PQResults(SearchRequestID,GMTDatetime,v5Mediatype,v5Category)
		   Create index idx2_IQAgent_PQResults on #IQAgent_PQResults(SearchRequestID,LocalDatetime,v5Mediatype,v5Category)
		   Create index idx3_IQAgent_PQResults on #IQAgent_PQResults(SearchRequestID,DateTimeHour,v5Mediatype,v5Category)
	--	   Create index idx4_IQAgent_PQResults on #IQAgent_PQResults(ID)

		   Exec @status=usp_DBJob_RefreshIQAgentDayHourSummary_NEW_BuildSummaryTables @ClientGUID With Recompile
 
		   IF @status=0 
			  BEGIN
				Exec @status=usp_DBJob_RefreshIQAgentDayHourSummary_NEW_UpdateTables @Process With Recompile
				IF @status=0 
					SET @Message = 'Added  Summary Values to Day and Hour Tables'
				ELSE      
					SET  @Message = 'Failed Adding Summary Value to Day and Hour Tables'
			  END
		   ELSE
			  SET  @Message = 'Failed Populating Summary Tables'
	           

RETURN 0      

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
				@CreatedBy='usp_DBJob_RefreshIQAgentDayHourSummary_NEW_PerClientGUID',
				@ModifiedBy='usp_DBJob_RefreshIQAgentDayHourSummary_NEW_PerClientGUID',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
END CATCH      
  

    
END























GO


