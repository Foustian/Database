USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_DBJob_AddEarnedPaidSummary_TV]    Script Date: 10/20/2016 2:55:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_DBJob_AddEarnedPaidSummary_TV]        
(@MaxIQSeqIDOfADS BIGINT)
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY        
	
	DECLARE @ProcessLastIQSeqID BIGINT 
	DECLARE @ADSCreateddate datetime

	-- SELECT @ProcessLastIQSeqID= MAX(ID) FROM #IQAgent_QHTVResults

	SELECT @ADSCreateddate = DATEADD(Day, -15, GETDATE())

	BEGIN TRANSACTION		
		
		MERGE INTO IQAgent_EarnedPaidDaySummary AS TARGET
		  USING #IQAgent_EarnedPaidSummary AS SOURCE
		  ON  TARGET.DayDate = SOURCE.DayDate
		  AND TARGET._ClientGuid = SOURCE.ClientGuid
		  AND TARGET._SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		  AND TARGET.COuntryNumber = SOURCE.CountryNumber
		  AND MediaType ='TV'
		  AND SubMediaTYpe='TV'
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
			--	Seen_Earned		  = ISNULL(TARGET.Seen_Earned,0) + ISNULL(SOURCE.Seen_Earned,0),
			--	Seen_Paid		  = ISNULL(TARGET.Seen_Paid,0) + ISNULL(SOURCE.Seen_Paid,0),
				Heard_Earned      = ISNULL(TARGET.Heard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				Heard_Paid		  = ISNULL(TARGET.Heard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0),
				LastUpdated		  = GETDATE()
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT(_ClientGuid,DayDate,_SearchRequestID,Market,CountryNumber,NumberOfDocs,NumberOfHits,
		  		AM18_20,AM21_24,AM25_34,AM35_49,AM50_54,AM55_64,AM65_Plus,
				AF18_20,AF21_24,AF25_34,AF35_49,AF50_54,AF55_64,AF65_Plus,
				TotalAudience,PositiveSentiment,NegativeSentiment,IQAdShareValue,
				Seen_Earned,Seen_Paid,Heard_Earned,Heard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				(ClientGuid,DayDate,SearchRequestID,Market,CountryNumber,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');


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
			SET LtNumberOfDocs	  = ISNULL(TARGET.LtNumberOfDocs,0) + ISNULL(SOURCE.NumberOfDocs,0),
				LtNumberOfHits	  = ISNULL(TARGET.LtNumberOfHits,0) + ISNULL(SOURCE.NumberOfHits,0),
				LtAM18_20	  		  = ISNULL(TARGET.LtAM18_20,0) + ISNULL(SOURCE.AM18_20,0),
				LtAM21_24	  		  = ISNULL(TARGET.LtAM21_24,0) + ISNULL(SOURCE.AM21_24,0),
				LtAM25_34	  		  = ISNULL(TARGET.LtAM25_34,0) + ISNULL(SOURCE.AM25_34,0),
				LtAM35_49	  		  = ISNULL(TARGET.LtAM35_49,0) + ISNULL(SOURCE.AM35_49,0),
				LtAM50_54	  		  = ISNULL(TARGET.LtAM50_54,0) + ISNULL(SOURCE.AM50_54,0),
				LtAM55_64	  		  = ISNULL(TARGET.LtAM55_64,0) + ISNULL(SOURCE.AM55_64,0),
				LtAM65_Plus		  = ISNULL(TARGET.LtAM65_Plus,0) + ISNULL(SOURCE.AM65_Plus,0),
				LtAF18_20	  		  = ISNULL(TARGET.LtAF18_20,0) + ISNULL(SOURCE.AF18_20,0),
				LtAF21_24	  		  = ISNULL(TARGET.LtAF21_24,0) + ISNULL(SOURCE.AF21_24,0),
				LtAF25_34	  		  = ISNULL(TARGET.LtAF25_34,0) + ISNULL(SOURCE.AF25_34,0),
				LtAF35_49	  		  = ISNULL(TARGET.LtAF35_49,0) + ISNULL(SOURCE.AF35_49,0),
				LtAF50_54	  		  = ISNULL(TARGET.LtAF50_54,0) + ISNULL(SOURCE.AF50_54,0),
				LtAF55_64	  		  = ISNULL(TARGET.LtAF55_64,0) + ISNULL(SOURCE.AF55_64,0),
				LtAF65_Plus		  = ISNULL(TARGET.LtAF65_Plus,0) + ISNULL(SOURCE.AF65_Plus,0),
				LtTotalAudience	  = ISNULL(TARGET.LtTotalAudience,0) + ISNULL(SOURCE.TotalAudience,0),
				LtPositiveSentiment = ISNULL(TARGET.LtPositiveSentiment,0) + ISNULL(SOURCE.PositiveSentiment,0),
				LtNegativeSentiment = ISNULL(TARGET.LtNegativeSentiment,0) + ISNULL(SOURCE.NegativeSentiment,0),
				LtIQAdShareValue    = ISNULL(TARGET.LtIQAdShareValue,0) + ISNULL(SOURCE.IQAdShareValue,0),
			--	Seen_Earned		  = ISNULL(TARGET.Seen_Earned,0) + ISNULL(SOURCE.Seen_Earned,0),
			--	Seen_Paid		  = ISNULL(TARGET.Seen_Paid,0) + ISNULL(SOURCE.Seen_Paid,0),
				LtHeard_Earned      = ISNULL(TARGET.LtHeard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
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


        MERGE INTO IQAgent_EarnedPaidHourSummary AS TARGET
		  USING #IQAgent_EarnedPaidHourSummary AS SOURCE
		  ON  TARGET.HourDateTime = SOURCE.HourDateTime
		  AND TARGET._ClientGuid = SOURCE.ClientGuid
		  AND TARGET._SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		  AND TARGET.COuntryNumber = SOURCE.CountryNumber
		  AND MediaType ='TV'
		  AND SubMediaTYpe='TV'
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
			--	Seen_Earned		  = ISNULL(TARGET.Seen_Earned,0) + ISNULL(SOURCE.Seen_Earned,0),
			--	Seen_Paid		  = ISNULL(TARGET.Seen_Paid,0) + ISNULL(SOURCE.Seen_Paid,0),
				Heard_Earned      = ISNULL(TARGET.Heard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				Heard_Paid		  = ISNULL(TARGET.Heard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0),
				LastUpdated		  = GETDATE()
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT(_ClientGuid,HourDateTime,_SearchRequestID,Market,CountryNumber,NumberOfDocs,NumberOfHits,
		  		AM18_20,AM21_24,AM25_34,AM35_49,AM50_54,AM55_64,AM65_Plus,
				AF18_20,AF21_24,AF25_34,AF35_49,AF50_54,AF55_64,AF65_Plus,
				TotalAudience,PositiveSentiment,NegativeSentiment,IQAdShareValue,
				Seen_Earned,Seen_Paid,Heard_Earned,Heard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				(ClientGuid,HourDateTime,SearchRequestID,Market,CountryNumber,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');


-- IQAnalytic Tables

		MERGE INTO IQAgent_AnalyticsDaySummary AS TARGET
		  USING #IQAgent_EarnedPaidSummary AS SOURCE
		  ON  TARGET.DayDate = SOURCE.DayDate
		  AND TARGET._ClientGuid = SOURCE.ClientGuid
		  AND TARGET._SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		  AND MediaType ='TV'
		  AND SubMediaTYpe='TV'
		  WHEN MATCHED THEN
		  UPDATE
			SET -- NumberOfDocs	  = ISNULL(TARGET.NumberOfDocs,0) + ISNULL(SOURCE.NumberOfDocs,0),
			--	NumberOfHits	  = ISNULL(TARGET.NumberOfHits,0) + ISNULL(SOURCE.NumberOfHits,0),
				Heard_Earned      = ISNULL(TARGET.Heard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				Heard_Paid		  = ISNULL(TARGET.Heard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0)
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT(_ClientGuid,DayDate,_SearchRequestID,Market,Heard_Earned,Heard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				(ClientGuid,DayDate,SearchRequestID,Market,ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');
/*
		  INSERT(ClientGuid,DayDate,_SearchRequestID,Market,NumberOfDocs,NumberOfHits,
		  		AM18_20,AM21_24,AM25_34,AM35_49,AM50_54,AM55_64,AM65_Plus,
				AF18_20,AF21_24,AF25_34,AF35_49,AF50_54,AF55_64,AF65_Plus,
				TotalAudiences,PositiveSentiment,NegativeSentiment,IQMediaValue,
				Seen_Earned,Seen_Paid,Heard_Earned,Heard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				(ClientGuid,DayDate,SearchRequestID,Market,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');
*/
	    MERGE INTO IQAgent_AnalyticsDaySummary AS TARGET
		  USING #IQAgent_EarnedPaidLocalTimeSummary AS SOURCE
		  ON  TARGET.DayDate = SOURCE.DayDate
		  AND TARGET._ClientGuid = SOURCE.ClientGuid
		  AND TARGET._SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		  AND MediaType ='TV'
		  AND SubMediaTYpe='TV'
		  WHEN MATCHED THEN
		  UPDATE
			SET -- LtNumberOfDocs	  = ISNULL(TARGET.LtNumberOfDocs,0) + ISNULL(SOURCE.NumberOfDocs,0),
			--	LtNumberOfHits	  = ISNULL(TARGET.LtNumberOfHits,0) + ISNULL(SOURCE.NumberOfHits,0),
				LtHeard_Earned      = ISNULL(TARGET.LtHeard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				LtHeard_Paid		  = ISNULL(TARGET.LtHeard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0)
		  WHEN NOT MATCHED BY TARGET THEN
		   INSERT(_ClientGuid,DayDate,_SearchRequestID,Market,LtHeard_Earned,LtHeard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				  (ClientGuid,DayDate,SearchRequestID,Market,ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');
/*
		  INSERT(ClientGuid,DayDate,_SearchRequestID,Market,LtNumberOfDocs,LtNumberOfHits,
		  		LtAM18_20,LtAM21_24,LtAM25_34,LtAM35_49,LtAM50_54,LtAM55_64,LtAM65_Plus,
				LtAF18_20,LtAF21_24,LtAF25_34,LtAF35_49,LtAF50_54,LtAF55_64,LtAF65_Plus,
				LtTotalAudiences,LtPositiveSentiment,LtNegativeSentiment,LtIQMediaValue,
				LtSeen_Earned,LtSeen_Paid,LtHeard_Earned,LtHeard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				(ClientGuid,DayDate,SearchRequestID,Market,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');
*/
        MERGE INTO IQAgent_AnalyticsHourSummary AS TARGET
		  USING #IQAgent_EarnedPaidHourSummary AS SOURCE
		  ON  TARGET.GMTHourDateTime = SOURCE.HourDateTime
		  AND TARGET._ClientGuid = SOURCE.ClientGuid
		  AND TARGET._SearchRequestID = SOURCE.SearchRequestID
		  AND TARGET.Market = SOURCE.Market
		  AND MediaType ='TV'
		  AND SubMediaTYpe='TV'
		  WHEN MATCHED THEN
		  UPDATE
			SET -- NumberOfDocs	  = ISNULL(TARGET.NumberOfDocs,0) + ISNULL(SOURCE.NumberOfDocs,0),
		--	    NumberOfHits	  = ISNULL(TARGET.NumberOfHits,0) + ISNULL(SOURCE.NumberOfHits,0),
				Heard_Earned      = ISNULL(TARGET.Heard_Earned,0) + ISNULL(SOURCE.Heard_Earned,0),
				Heard_Paid		  = ISNULL(TARGET.Heard_Paid,0) + ISNULL(SOURCE.Heard_Paid,0)
		  WHEN NOT MATCHED BY TARGET THEN
		  INSERT(_ClientGuid,GMTHourDateTime,_SearchRequestID,Market,LocalHourDateTime,Heard_Earned,Heard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				(ClientGuid,HourDateTime,SearchRequestID,Market,LocalHourDateTime,ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');

/*
		  INSERT(ClientGuid,HourDateTime,_SearchRequestID,Market,LocalHourDateTime,NumberOfDocs,NumberOfHits,
		  		AM18_20,AM21_24,AM25_34,AM35_49,AM50_54,AM55_64,AM65_Plus,
				AF18_20,AF21_24,AF25_34,AF35_49,AF50_54,AF55_64,AF65_Plus,
				TotalAudiences,PositiveSentiment,NegativeSentiment,IQMediaValue,
				Seen_Earned,Seen_Paid,Heard_Earned,Heard_Paid,LastUpdated,MediaType,SubMediaType) VALUES
				(ClientGuid,HourDateTime,SearchRequestID,Market,LocalHourDateTime,ISNULL(NumberOfDocs,0),ISNULL(NumberOfHits,0),
				ISNULL(AM18_20,0),ISNULL(AM21_24,0),ISNULL(AM25_34,0),ISNULL(AM35_49,0),ISNULL(AM50_54,0),ISNULL(AM55_64,0),ISNULL(AM65_Plus,0),
				ISNULL(AF18_20,0),ISNULL(AF21_24,0),ISNULL(AF25_34,0),ISNULL(AF35_49,0),ISNULL(AF50_54,0),ISNULL(AF55_64,0),ISNULL(AF65_Plus,0),
				ISNULL(TotalAudience,0),ISNULL(PositiveSentiment,0),ISNULL(NegativeSentiment,0),ISNULL(IQAdShareValue,0),
				ISNULL(Seen_Earned,0),ISNULL(Seen_Paid,0),ISNULL(Heard_Earned,0),ISNULL(Heard_Paid,0),GETDATE(),'TV','TV');
*/
-- End of IQAnalytic Tables
		    UPDATE IQAgent_TVResults WITH (ROWLOCK)
				   SET Process='Y'
			FROM IQAgent_TVResults tv 
			     JOIN #IQAgent_TVResults tmp
				   ON tv.ID = tmp.ID

			UPDATE IQAgent_TVResults WITH (ROWLOCK)
			     SET Earned = NULL,
				     Paid = NULL
			 FROM IQAgent_TVResults JOIN #NumberOFHitsChanged tmp ON ID = tmp.IQAgent_TVResults_ID

			UPDATE IQ_ADS_Results WITH (ROWLOCK)
		    SET FlagForEP = 'Y'
			FROM IQ_ADS_Results ads
				JOIN #IQ_ADS_Results tmp ON tmp.iq_cc_key = ads.iq_cc_key
					WHERE Createddate <= @ADSCreateddate
/*
		  IF EXISTS (SELECT ID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE MediaType='SADS')
				UPDATE IQ_DBJobLastIQSeqID SET LastIQSeqID = @MaxIQSeqIDOfADS, ModifiedDate = GETDATE() WHERE MediaType='SADS'
		  ELSE
				INSERT INTO IQ_DBJobLastIQSeqID (MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive) 
				VALUES('SADS',@MaxIQSeqIDOfADS,GETDATE(),GETDATE(),1)
			
*/
	COMMIT  TRANSACTION	
							
						
 Return 0      
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
				@CreatedBy='usp_DBJob_EarnedPaidSummary_TV',
				@ModifiedBy='usp_DBJob_EarnedPaidSummary_TV',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END
