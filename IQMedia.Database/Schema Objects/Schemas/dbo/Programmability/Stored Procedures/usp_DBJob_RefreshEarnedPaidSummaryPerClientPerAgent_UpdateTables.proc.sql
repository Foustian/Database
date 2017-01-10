USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_RefreshEarnedPaidSummaryPerClientPerAgent_UpdateTables]    Script Date: 10/20/2016 3:12:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_RefreshEarnedPaidSummaryPerClientPerAgent_UpdateTables]  (      
@ClientGUID UNIQUEIDENTIFIER, @AgentID BIGINT)
AS       
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY 
	
		
		
		MERGE INTO #IQAgent_EarnedPaidSummary AS TARGET
		  USING #IQAgent_EarnedPaidSummary_LR AS SOURCE
		  ON  TARGET.DayDate = SOURCE.DayDate
		  AND TARGET.ClientGuid = SOURCE.ClientGuid
		  AND TARGET.SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		--  AND TARGET.Station = SOURCE.Station
		  AND TARGET.COuntryNumber = SOURCE.CountryNumber
		  WHEN MATCHED THEN
		  UPDATE
			SET NumberOfDocs	  = ISNULL(TARGET.NumberOfDocs,0) + ISNULL(SOURCE.NumberOfDocs,0),
				NumberOfHits	  = ISNULL(TARGET.NumberOfHits,0) + ISNULL(SOURCE.NumberOfHits,0),
				AM18_20	  		  = ISNULL(TARGET.AM18_20,0) + ISNULL(SOURCE.AM18_20,0),
				AM21_24	  		  = ISNULL(TARGET.AM21_24,0) + ISNULL(SOURCE.AM21_24,0),
				AM25_34	  		  = ISNULL(TARGET.AM25_34,0) + ISNULL(SOURCE.AM25_34,0),
				AM35_49	  		  = ISNULL(TARGET.AM35_49,0) + ISNULL(SOURCE.AM35_49,0),
				AM50_54	  		  = ISNULL(TARGET.AM50_54,0) + ISNULL(SOURCE.AM50_54,0),
				AM55_64	  		  = ISNULL(TARGET.AM55_64,0) + ISNULL(SOURCE.AM55_64,0),
				AM65_Plus		  = ISNULL(TARGET.AM65_Plus,0) + ISNULL(SOURCE.AM65_Plus,0),
				AF18_20	  		  = ISNULL(TARGET.AF18_20,0) + ISNULL(SOURCE.AF18_20,0),
				AF21_24	  		  = ISNULL(TARGET.AF21_24,0) + ISNULL(SOURCE.AF21_24,0),
				AF25_34	  		  = ISNULL(TARGET.AF25_34,0) + ISNULL(SOURCE.AF25_34,0),
				AF35_49	  		  = ISNULL(TARGET.AF35_49,0) + ISNULL(SOURCE.AF35_49,0),
				AF50_54	  		  = ISNULL(TARGET.AF50_54,0) + ISNULL(SOURCE.AF50_54,0),
				AF55_64	  		  = ISNULL(TARGET.AF55_64,0) + ISNULL(SOURCE.AF55_64,0),
				AF65_Plus		  = ISNULL(TARGET.AF65_Plus,0) + ISNULL(SOURCE.AF65_Plus,0),
				TotalAudience	  = ISNULL(TARGET.TotalAudience,0) + ISNULL(SOURCE.TotalAudience,0),
				PositiveSentiment = ISNULL(TARGET.PositiveSentiment,0) + ISNULL(SOURCE.PositiveSentiment,0),
				NegativeSentiment = ISNULL(TARGET.NegativeSentiment,0) + ISNULL(SOURCE.NegativeSentiment,0),
				IQAdShareValue    = ISNULL(TARGET.IQAdShareValue,0) + ISNULL(SOURCE.IQAdShareValue,0),
				Seen_Earned		  = ISNULL(TARGET.Seen_Earned,0) + ISNULL(SOURCE.Seen_Earned,0),
				Seen_Paid		  = ISNULL(TARGET.Seen_Paid,0) + ISNULL(SOURCE.Seen_Paid,0),
				Heard_Earned      = ISNULL(TARGET.Heard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				Heard_Paid		  = ISNULL(TARGET.Heard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0)
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT(ClientGuid,DayDate,SearchRequestID,Market,Station,CountryNumber,NumberOfDocs,NumberOfHits,
		  		AM18_20,AM21_24,AM25_34,AM35_49,AM50_54,AM55_64,AM65_Plus,
				AF18_20,AF21_24,AF25_34,AF35_49,AF50_54,AF55_64,AF65_Plus,
				TotalAudience,PositiveSentiment,NegativeSentiment,IQAdShareValue,
				Seen_Earned,Seen_Paid,Heard_Earned,Heard_Paid) VALUES
				(ClientGuid,DayDate,SearchRequestID,Market,NULL,CountryNumber,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0));

		MERGE INTO #IQAgent_EarnedPaidLocalTimeSummary AS TARGET
		  USING #IQAgent_EarnedPaidLocalTimeSummary_LR AS SOURCE
		  ON  TARGET.DayDate = SOURCE.DayDate
		  AND TARGET.ClientGuid = SOURCE.ClientGuid
		  AND TARGET.SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		--  AND TARGET.Station = SOURCE.Station
		  AND TARGET.COuntryNumber = SOURCE.CountryNumber
		  WHEN MATCHED THEN
		  UPDATE
			SET NumberOfDocs	  = ISNULL(TARGET.NumberOfDocs,0) + ISNULL(SOURCE.NumberOfDocs,0),
				NumberOfHits	  = ISNULL(TARGET.NumberOfHits,0) + ISNULL(SOURCE.NumberOfHits,0),
				AM18_20	  		  = ISNULL(TARGET.AM18_20,0) + ISNULL(SOURCE.AM18_20,0),
				AM21_24	  		  = ISNULL(TARGET.AM21_24,0) + ISNULL(SOURCE.AM21_24,0),
				AM25_34	  		  = ISNULL(TARGET.AM25_34,0) + ISNULL(SOURCE.AM25_34,0),
				AM35_49	  		  = ISNULL(TARGET.AM35_49,0) + ISNULL(SOURCE.AM35_49,0),
				AM50_54	  		  = ISNULL(TARGET.AM50_54,0) + ISNULL(SOURCE.AM50_54,0),
				AM55_64	  		  = ISNULL(TARGET.AM55_64,0) + ISNULL(SOURCE.AM55_64,0),
				AM65_Plus		  = ISNULL(TARGET.AM65_Plus,0) + ISNULL(SOURCE.AM65_Plus,0),
				AF18_20	  		  = ISNULL(TARGET.AF18_20,0) + ISNULL(SOURCE.AF18_20,0),
				AF21_24	  		  = ISNULL(TARGET.AF21_24,0) + ISNULL(SOURCE.AF21_24,0),
				AF25_34	  		  = ISNULL(TARGET.AF25_34,0) + ISNULL(SOURCE.AF25_34,0),
				AF35_49	  		  = ISNULL(TARGET.AF35_49,0) + ISNULL(SOURCE.AF35_49,0),
				AF50_54	  		  = ISNULL(TARGET.AF50_54,0) + ISNULL(SOURCE.AF50_54,0),
				AF55_64	  		  = ISNULL(TARGET.AF55_64,0) + ISNULL(SOURCE.AF55_64,0),
				AF65_Plus		  = ISNULL(TARGET.AF65_Plus,0) + ISNULL(SOURCE.AF65_Plus,0),
				TotalAudience	  = ISNULL(TARGET.TotalAudience,0) + ISNULL(SOURCE.TotalAudience,0),
				PositiveSentiment = ISNULL(TARGET.PositiveSentiment,0) + ISNULL(SOURCE.PositiveSentiment,0),
				NegativeSentiment = ISNULL(TARGET.NegativeSentiment,0) + ISNULL(SOURCE.NegativeSentiment,0),
				IQAdShareValue    = ISNULL(TARGET.IQAdShareValue,0) + ISNULL(SOURCE.IQAdShareValue,0),
				Seen_Earned		  = ISNULL(TARGET.Seen_Earned,0) + ISNULL(SOURCE.Seen_Earned,0),
				Seen_Paid		  = ISNULL(TARGET.Seen_Paid,0) + ISNULL(SOURCE.Seen_Paid,0),
				Heard_Earned      = ISNULL(TARGET.Heard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				Heard_Paid		  = ISNULL(TARGET.Heard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0)
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT(ClientGuid,DayDate,SearchRequestID,Market,Station,CountryNumber,NumberOfDocs,NumberOfHits,
		  		AM18_20,AM21_24,AM25_34,AM35_49,AM50_54,AM55_64,AM65_Plus,
				AF18_20,AF21_24,AF25_34,AF35_49,AF50_54,AF55_64,AF65_Plus,
				TotalAudience,PositiveSentiment,NegativeSentiment,IQAdShareValue,
				Seen_Earned,Seen_Paid,Heard_Earned,Heard_Paid) VALUES
				(ClientGuid,DayDate,SearchRequestID,Market,NULL,CountryNumber,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0));

		
        MERGE INTO #IQAgent_EarnedPaidHourSummary AS TARGET
		  USING #IQAgent_EarnedPaidHourSummary_LR AS SOURCE
		  ON  TARGET.HourDateTime = SOURCE.HourDateTime
		  AND TARGET.ClientGuid = SOURCE.ClientGuid
		  AND TARGET.SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		--  AND TARGET.Station = SOURCE.Station
		  AND TARGET.COuntryNumber = SOURCE.CountryNumber
		  WHEN MATCHED THEN
		  UPDATE
			SET NumberOfDocs	  = ISNULL(TARGET.NumberOfDocs,0) + ISNULL(SOURCE.NumberOfDocs,0),
			    NumberOfHits	  = ISNULL(TARGET.NumberOfHits,0) + ISNULL(SOURCE.NumberOfHits,0),
				AM18_20	  		  = ISNULL(TARGET.AM18_20,0) + ISNULL(SOURCE.AM18_20,0),
				AM21_24	  		  = ISNULL(TARGET.AM21_24,0) + ISNULL(SOURCE.AM21_24,0),
				AM25_34	  		  = ISNULL(TARGET.AM25_34,0) + ISNULL(SOURCE.AM25_34,0),
				AM35_49	  		  = ISNULL(TARGET.AM35_49,0) + ISNULL(SOURCE.AM35_49,0),
				AM50_54	  		  = ISNULL(TARGET.AM50_54,0) + ISNULL(SOURCE.AM50_54,0),
				AM55_64	  		  = ISNULL(TARGET.AM55_64,0) + ISNULL(SOURCE.AM55_64,0),
				AM65_Plus		  = ISNULL(TARGET.AM65_Plus,0) + ISNULL(SOURCE.AM65_Plus,0),
				AF18_20	  		  = ISNULL(TARGET.AF18_20,0) + ISNULL(SOURCE.AF18_20,0),
				AF21_24	  		  = ISNULL(TARGET.AF21_24,0) + ISNULL(SOURCE.AF21_24,0),
				AF25_34	  		  = ISNULL(TARGET.AF25_34,0) + ISNULL(SOURCE.AF25_34,0),
				AF35_49	  		  = ISNULL(TARGET.AF35_49,0) + ISNULL(SOURCE.AF35_49,0),
				AF50_54	  		  = ISNULL(TARGET.AF50_54,0) + ISNULL(SOURCE.AF50_54,0),
				AF55_64	  		  = ISNULL(TARGET.AF55_64,0) + ISNULL(SOURCE.AF55_64,0),
				AF65_Plus		  = ISNULL(TARGET.AF65_Plus,0) + ISNULL(SOURCE.AF65_Plus,0),
				TotalAudience	  = ISNULL(TARGET.TotalAudience,0) + ISNULL(SOURCE.TotalAudience,0),
				PositiveSentiment = ISNULL(TARGET.PositiveSentiment,0) + ISNULL(SOURCE.PositiveSentiment,0),
				NegativeSentiment = ISNULL(TARGET.NegativeSentiment,0) + ISNULL(SOURCE.NegativeSentiment,0),
				IQAdShareValue    = ISNULL(TARGET.IQAdShareValue,0) + ISNULL(SOURCE.IQAdShareValue,0),
				Seen_Earned		  = ISNULL(TARGET.Seen_Earned,0) + ISNULL(SOURCE.Seen_Earned,0),
				Seen_Paid		  = ISNULL(TARGET.Seen_Paid,0) + ISNULL(SOURCE.Seen_Paid,0),
				Heard_Earned      = ISNULL(TARGET.Heard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				Heard_Paid		  = ISNULL(TARGET.Heard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0)
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT(ClientGuid,HourDateTime,SearchRequestID,Market,Station,CountryNumber,NumberOfDocs,NumberOfHits,
		  		AM18_20,AM21_24,AM25_34,AM35_49,AM50_54,AM55_64,AM65_Plus,
				AF18_20,AF21_24,AF25_34,AF35_49,AF50_54,AF55_64,AF65_Plus,
				TotalAudience,PositiveSentiment,NegativeSentiment,IQAdShareValue,
				Seen_Earned,Seen_Paid,Heard_Earned,Heard_Paid) VALUES
				(ClientGuid,HourDateTime,SearchRequestID,Market,NULL,CountryNumber,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0));

	BEGIN TRANSACTION	

DELETE IQAgent_EarnedPaidDaySummary WHERE _ClientGUID = @ClientGUID AND _SearchRequestID = @AgentID
DELETE IQAgent_EarnedPaidHourSummary WHERE _ClientGUID = @ClientGUID AND _SearchRequestID = @AgentID
	
	INSERT INTO IQAgent_EarnedPaidDaySummary (
	[_ClientGuid],
	[DayDate],
	[_SearchRequestID],
	[Market],
	-- [Station],
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
	[Seen_Paid],
	[Heard_Earned],
	[Heard_Paid],
	[LastUpdated],
	[MediaType],
	[SubMediaType]
	)
	SELECT
		[ClientGuid],
		[DayDate],
		[SearchRequestID],
		[Market],
		-- [Station],
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
		[AF25_34]L,
		[AF35_49],
		[AF50_54],
		[AF55_64],
		[AF65_Plus],
		[TotalAudience],
		[PositiveSentiment],
		[NegativeSentiment],
		[IQAdShareValue]L,
		[Seen_Earned],
		[Seen_Paid],
		[Heard_Earned],
		[Heard_Paid],
		GETDATE(),
		'TV',
		'TV'
	FROM #IQAgent_EarnedPaidSummary
	
	MERGE INTO IQAgent_EarnedPaidDaySummary AS TARGET
		  USING #IQAgent_EarnedPaidLocalTimeSummary AS SOURCE
		  ON  TARGET.DayDate = SOURCE.DayDate
		  AND TARGET._ClientGuid = SOURCE.ClientGuid
		  AND TARGET._SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		  AND TARGET.COuntryNumber = SOURCE.CountryNumber
		   AND MediaType ='TV'
		  AND SubMediaTYpe='TV'
		  WHEN MATCHED THEN
		  UPDATE
			SET LtNumberOfDocs	      = ISNULL(TARGET.LtNumberOfDocs,0) + ISNULL(SOURCE.NumberOfDocs,0),
				LtNumberOfHits	      = ISNULL(TARGET.LtNumberOfHits,0) + ISNULL(SOURCE.NumberOfHits,0),
				LtAM18_20	  		  = ISNULL(TARGET.LtAM18_20,0) + ISNULL(SOURCE.AM18_20,0),
				LtAM21_24	  		  = ISNULL(TARGET.LtAM21_24,0) + ISNULL(SOURCE.AM21_24,0),
				LtAM25_34	  		  = ISNULL(TARGET.LtAM25_34,0) + ISNULL(SOURCE.AM25_34,0),
				LtAM35_49	  		  = ISNULL(TARGET.LtAM35_49,0) + ISNULL(SOURCE.AM35_49,0),
				LtAM50_54	  		  = ISNULL(TARGET.LtAM50_54,0) + ISNULL(SOURCE.AM50_54,0),
				LtAM55_64	  		  = ISNULL(TARGET.LtAM55_64,0) + ISNULL(SOURCE.AM55_64,0),
				LtAM65_Plus		      = ISNULL(TARGET.LtAM65_Plus,0) + ISNULL(SOURCE.AM65_Plus,0),
				LtAF18_20	  		  = ISNULL(TARGET.LtAF18_20,0) + ISNULL(SOURCE.AF18_20,0),
				LtAF21_24	  		  = ISNULL(TARGET.LtAF21_24,0) + ISNULL(SOURCE.AF21_24,0),
				LtAF25_34	  		  = ISNULL(TARGET.LtAF25_34,0) + ISNULL(SOURCE.AF25_34,0),
				LtAF35_49	  		  = ISNULL(TARGET.LtAF35_49,0) + ISNULL(SOURCE.AF35_49,0),
				LtAF50_54	  		  = ISNULL(TARGET.LtAF50_54,0) + ISNULL(SOURCE.AF50_54,0),
				LtAF55_64	  		  = ISNULL(TARGET.LtAF55_64,0) + ISNULL(SOURCE.AF55_64,0),
				LtAF65_Plus		      = ISNULL(TARGET.LtAF65_Plus,0) + ISNULL(SOURCE.AF65_Plus,0),
				LtTotalAudience	      = ISNULL(TARGET.LtTotalAudience,0) + ISNULL(SOURCE.TotalAudience,0),
				LtPositiveSentiment   = ISNULL(TARGET.LtPositiveSentiment,0) + ISNULL(SOURCE.PositiveSentiment,0),
				LtNegativeSentiment   = ISNULL(TARGET.LtNegativeSentiment,0) + ISNULL(SOURCE.NegativeSentiment,0),
				LtIQAdShareValue      = ISNULL(TARGET.LtIQAdShareValue,0) + ISNULL(SOURCE.IQAdShareValue,0),
				LtSeen_Earned		  = ISNULL(TARGET.LtSeen_Earned,0) + ISNULL(SOURCE.Seen_Earned,0),
				LtSeen_Paid		      = ISNULL(TARGET.LtSeen_Paid,0) + ISNULL(SOURCE.Seen_Paid,0),
				LtHeard_Earned        = ISNULL(TARGET.LtHeard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				LtHeard_Paid		  = ISNULL(TARGET.LtHeard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0),
				LastUpdated		  = GETDATE()
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT(_ClientGuid,DayDate,_SearchRequestID,Market,CountryNumber,
				LtNumberOfDocs,LtNumberOfHits,
		  		LtAM18_20,LtAM21_24,LtAM25_34,LtAM35_49,LtAM50_54,LtAM55_64,LtAM65_Plus,
				LtAF18_20,LtAF21_24,LtAF25_34,LtAF35_49,LtAF50_54,LtAF55_64,LtAF65_Plus,
				LtTotalAudience,LtPositiveSentiment,LtNegativeSentiment,LtIQAdShareValue,
				LtSeen_Earned,LtSeen_Paid,LtHeard_Earned,LtHeard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				(ClientGuid,DayDate,SearchRequestID,Market,CountryNumber,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');

	INSERT INTO IQAgent_EarnedPaidHourSummary (
	[_ClientGuid],
	[HourDateTime],
	[_SearchRequestID],
	[Market],
	-- [Station],
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
	[Seen_Paid],
	[Heard_Earned],
	[Heard_Paid],
	[LastUpdated],
	[MediaType],
	[SubMediaType]
	)
	SELECT
		[ClientGuid],
		[HourDateTime],
		[SearchRequestID],
		[Market],
	--	[Station],
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
		[AF25_34]L,
		[AF35_49],
		[AF50_54],
		[AF55_64],
		[AF65_Plus],
		[TotalAudience],
		[PositiveSentiment],
		[NegativeSentiment],
		[IQAdShareValue]L,
		[Seen_Earned],
		[Seen_Paid],
		[Heard_Earned],
		[Heard_Paid],
		GETDATE(),
		'TV',
		'TV'
	FROM #IQAgent_EarnedPaidHourSummary
	

	UPDATE IQAgent_TVResults 
	    SET Process='Y'
	 FROM IQAgent_TVResults tv WITH (NOLOCK)
	     JOIN #IQAgent_TVResults temp
		   ON tv.ID = temp.ID
	
	UPDATE IQAgent_LRResults 
	    SET Process='Y'
	 FROM IQAgent_LRResults lr WITH (NOLOCK)
	     JOIN #IQAgent_LRResults temp
		   ON lr.ID = temp.ID

	COMMIT TRANSACTION

 RETURN 0      
 END TRY        

 BEGIN CATCH        

   IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION

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
				@CreatedBy='usp_DBJob_RefreshEarnedPaidSummaryPerClientPerAgent_UpdateTables',
				@ModifiedBy='usp_DBJob_RefreshEarnedPaidSummaryPerClientPerAgent_UpdateTables',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END
GO


