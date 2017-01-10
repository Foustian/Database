USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_DeleteEarnedPaidSummary_ForTVLR]    Script Date: 10/20/2016 2:59:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_DeleteEarnedPaidSummary_ForTVLR]        

AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY        
 
BEGIN TRANSACTION		
			
	IF (SELECT COUNT(1) FROM #IQAgent_EarnedPaidSummary_Delete) > 0
	   BEGIN
			UPDATE IQAgent_EarnedPaidDaySummary
					SET NumberOfDocs	  = SIGN( 1 + SIGN(ISNULL(T.NumberOfDocs,0) - ISNULL(S.NumberOfDocs,0))) * (ISNULL(T.NumberOfDocs,0) - ISNULL(S.NumberOfDocs,0)),
						NumberOfHits	  = SIGN( 1 + SIGN(ISNULL(T.NumberOfHits,0) - ISNULL(S.NumberOfHits,0))) * (ISNULL(T.NumberOfHits,0) - ISNULL(S.NumberOfHits,0)),
						AM18_20	  		  = SIGN( 1 + SIGN(ISNULL(T.AM18_20,0) - ISNULL(S.AM18_20,0))) * (ISNULL(T.AM18_20,0) - ISNULL(S.AM18_20,0)),
						AM21_24	  		  = SIGN( 1 + SIGN(ISNULL(T.AM21_24,0) - ISNULL(S.AM21_24,0))) * (ISNULL(T.AM21_24,0) - ISNULL(S.AM21_24,0)),
						AM25_34	  		  = SIGN( 1 + SIGN(ISNULL(T.AM25_34,0) - ISNULL(S.AM25_34,0))) * (ISNULL(T.AM25_34,0) - ISNULL(S.AM25_34,0)),
						AM35_49	  		  = SIGN( 1 + SIGN(ISNULL(T.AM35_49,0) - ISNULL(S.AM35_49,0))) * (ISNULL(T.AM35_49,0) - ISNULL(S.AM35_49,0)),
						AM50_54	  		  = SIGN( 1 + SIGN(ISNULL(T.AM50_54,0) - ISNULL(S.AM50_54,0))) * (ISNULL(T.AM50_54,0) - ISNULL(S.AM50_54,0)),
						AM55_64	  		  = SIGN( 1 + SIGN(ISNULL(T.AM55_64,0) - ISNULL(S.AM55_64,0))) * (ISNULL(T.AM55_64,0) - ISNULL(S.AM55_64,0)),
						AM65_Plus		  = SIGN( 1 + SIGN(ISNULL(T.AM65_Plus,0) - ISNULL(S.AM65_Plus,0))) * (ISNULL(T.AM65_Plus,0) - ISNULL(S.AM65_Plus,0)),
						AF18_20	  		  = SIGN( 1 + SIGN(ISNULL(T.AF18_20,0) - ISNULL(S.AF18_20,0))) * (ISNULL(T.AF18_20,0) - ISNULL(S.AF18_20,0)),
						AF21_24	  		  = SIGN( 1 + SIGN(ISNULL(T.AF21_24,0) - ISNULL(S.AF21_24,0))) * (ISNULL(T.AF21_24,0) - ISNULL(S.AF21_24,0)),
						AF25_34	  		  = SIGN( 1 + SIGN(ISNULL(T.AF25_34,0) - ISNULL(S.AF25_34,0))) * (ISNULL(T.AF25_34,0) - ISNULL(S.AF25_34,0)),
						AF35_49	  		  = SIGN( 1 + SIGN(ISNULL(T.AF35_49,0) - ISNULL(S.AF35_49,0))) * (ISNULL(T.AF35_49,0) - ISNULL(S.AF35_49,0)),
						AF50_54	  		  = SIGN( 1 + SIGN(ISNULL(T.AF50_54,0) - ISNULL(S.AF50_54,0))) * (ISNULL(T.AF50_54,0) - ISNULL(S.AF50_54,0)),
						AF55_64	  		  = SIGN( 1 + SIGN(ISNULL(T.AF55_64,0) - ISNULL(S.AF55_64,0))) * (ISNULL(T.AF55_64,0) - ISNULL(S.AF55_64,0)),
						AF65_Plus		  = SIGN( 1 + SIGN(ISNULL(T.AF65_Plus,0) - ISNULL(S.AF65_Plus,0))) * (ISNULL(T.AF65_Plus,0) - ISNULL(S.AF65_Plus,0)),
						TotalAudience	  = SIGN( 1 + SIGN(ISNULL(T.TotalAudience,0) - ISNULL(S.TotalAudience,0))) * (ISNULL(T.TotalAudience,0) - ISNULL(S.TotalAudience,0)),
						PositiveSentiment = SIGN( 1 + SIGN(ISNULL(T.PositiveSentiment,0)-ISNULL(S.PositiveSentiment,0)))*(ISNULL(T.PositiveSentiment,0)-ISNULL(S.PositiveSentiment,0)),
						NegativeSentiment = SIGN( 1 + SIGN(ISNULL(T.NegativeSentiment,0)-ISNULL(S.NegativeSentiment,0)))*(ISNULL(T.NegativeSentiment,0)-ISNULL(S.NegativeSentiment,0)),
						IQAdShareValue    = SIGN( 1 + SIGN(ISNULL(T.IQAdShareValue,0) - ISNULL(S.IQAdShareValue,0))) * (ISNULL(T.IQAdShareValue,0) - ISNULL(S.IQAdShareValue,0)),
						Seen_Earned		  = SIGN( 1 + SIGN(ISNULL(T.Seen_Earned,0) - ISNULL(S.Seen_Earned,0))) * (ISNULL(T.Seen_Earned,0) - ISNULL(S.Seen_Earned,0)),
						Seen_Paid		  = SIGN( 1 + SIGN(ISNULL(T.Seen_Paid,0) - ISNULL(S.Seen_Paid,0))) * (ISNULL(T.Seen_Paid,0) - ISNULL(S.Seen_Paid,0)),
						Heard_Earned	  = SIGN( 1 + SIGN(ISNULL(T.Heard_Earned,0) - ISNULL(S.Heard_Earned,0))) * (ISNULL(T.Heard_Earned,0) - ISNULL(S.Heard_Earned,0)),
						Heard_Paid		  = SIGN( 1 + SIGN(ISNULL(T.Heard_Paid,0) - ISNULL(S.Heard_Paid,0))) * (ISNULL(T.Heard_Paid,0) - ISNULL(S.Heard_Paid,0))
			FROM IQAgent_EarnedPaidDaySummary  T WITH (NOLOCK), #IQAgent_EarnedPaidSummary_Delete  S
		    WHERE T._ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.DayDate = S.DayDate
				AND T.Market = S.Market
				AND T.CountryNumber = S.CountryNumber
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'

			UPDATE IQAgent_EarnedPaidDaySummary
					SET LtNumberOfDocs	  = SIGN( 1 + SIGN(ISNULL(T.LtNumberOfDocs,0) - ISNULL(S.NumberOfDocs,0))) * (ISNULL(T.LtNumberOfDocs,0) - ISNULL(S.NumberOfDocs,0)),
						LtNumberOfHits	  = SIGN( 1 + SIGN(ISNULL(T.LtNumberOfHits,0) - ISNULL(S.NumberOfHits,0))) * (ISNULL(T.LtNumberOfHits,0) - ISNULL(S.NumberOfHits,0)),
						LtAM18_20	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAM18_20,0) - ISNULL(S.AM18_20,0))) * (ISNULL(T.LtAM18_20,0) - ISNULL(S.AM18_20,0)),
						LtAM21_24	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAM21_24,0) - ISNULL(S.AM21_24,0))) * (ISNULL(T.LtAM21_24,0) - ISNULL(S.AM21_24,0)),
						LtAM25_34	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAM25_34,0) - ISNULL(S.AM25_34,0))) * (ISNULL(T.LtAM25_34,0) - ISNULL(S.AM25_34,0)),
						LtAM35_49	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAM35_49,0) - ISNULL(S.AM35_49,0))) * (ISNULL(T.LtAM35_49,0) - ISNULL(S.AM35_49,0)),
						LtAM50_54	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAM50_54,0) - ISNULL(S.AM50_54,0))) * (ISNULL(T.LtAM50_54,0) - ISNULL(S.AM50_54,0)),
						LtAM55_64	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAM55_64,0) - ISNULL(S.AM55_64,0))) * (ISNULL(T.LtAM55_64,0) - ISNULL(S.AM55_64,0)),
						LtAM65_Plus		      = SIGN( 1 + SIGN(ISNULL(T.LtAM65_Plus,0) - ISNULL(S.AM65_Plus,0))) * (ISNULL(T.LtAM65_Plus,0) - ISNULL(S.AM65_Plus,0)),
						LtAF18_20	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAF18_20,0) - ISNULL(S.AF18_20,0))) * (ISNULL(T.LtAF18_20,0) - ISNULL(S.AF18_20,0)),
						LtAF21_24	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAF21_24,0) - ISNULL(S.AF21_24,0))) * (ISNULL(T.LtAF21_24,0) - ISNULL(S.AF21_24,0)),
						LtAF25_34	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAF25_34,0) - ISNULL(S.AF25_34,0))) * (ISNULL(T.LtAF25_34,0) - ISNULL(S.AF25_34,0)),
						LtAF35_49	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAF35_49,0) - ISNULL(S.AF35_49,0))) * (ISNULL(T.LtAF35_49,0) - ISNULL(S.AF35_49,0)),
						LtAF50_54	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAF50_54,0) - ISNULL(S.AF50_54,0))) * (ISNULL(T.LtAF50_54,0) - ISNULL(S.AF50_54,0)),
						LtAF55_64	  		  = SIGN( 1 + SIGN(ISNULL(T.LtAF55_64,0) - ISNULL(S.AF55_64,0))) * (ISNULL(T.LtAF55_64,0) - ISNULL(S.AF55_64,0)),
						LtAF65_Plus		  = SIGN( 1 + SIGN(ISNULL(T.LtAF65_Plus,0) - ISNULL(S.AF65_Plus,0)))* (ISNULL(T.LtAF65_Plus,0) - ISNULL(S.AF65_Plus,0)),
						LtTotalAudience	  = SIGN( 1 + SIGN(ISNULL(T.LtTotalAudience,0) - ISNULL(S.TotalAudience,0)))*(ISNULL(T.LtTotalAudience,0) - ISNULL(S.TotalAudience,0)),
						LtPositiveSentiment= SIGN(1+SIGN(ISNULL(T.LtPositiveSentiment,0)-ISNULL(S.PositiveSentiment,0)))*(ISNULL(T.LtPositiveSentiment,0)-ISNULL(S.PositiveSentiment,0)),
						LtNegativeSentiment= SIGN(1 +SIGN(ISNULL(T.LtNegativeSentiment,0)-ISNULL(S.NegativeSentiment,0)))*(ISNULL(T.LtNegativeSentiment,0)-ISNULL(S.NegativeSentiment,0)),
						LtIQAdShareValue    = SIGN( 1 + SIGN(ISNULL(T.LtIQAdShareValue,0) - ISNULL(S.IQAdShareValue,0)))*(ISNULL(T.LtIQAdShareValue,0) - ISNULL(S.IQAdShareValue,0)),
						LtSeen_Earned		  = SIGN( 1 + SIGN(ISNULL(T.LtSeen_Earned,0) - ISNULL(S.Seen_Earned,0))) * (ISNULL(T.LtSeen_Earned,0) - ISNULL(S.Seen_Earned,0)),
						LtSeen_Paid		  = SIGN( 1 + SIGN(ISNULL(T.LtSeen_Paid,0) - ISNULL(S.Seen_Paid,0))) * (ISNULL(T.LtSeen_Paid,0) - ISNULL(S.Seen_Paid,0)),
						LtHeard_Earned	  = SIGN( 1 + SIGN(ISNULL(T.LtHeard_Earned,0) - ISNULL(S.Heard_Earned,0))) * (ISNULL(T.LtHeard_Earned,0) - ISNULL(S.Heard_Earned,0)),
						LtHeard_Paid		  = SIGN( 1 + SIGN(ISNULL(T.LtHeard_Paid,0) - ISNULL(S.Heard_Paid,0))) * (ISNULL(T.LtHeard_Paid,0) - ISNULL(S.Heard_Paid,0))
			FROM IQAgent_EarnedPaidDaySummary  T WITH (NOLOCK), #IQAgent_EarnedPaidLocalTimeSummary_Delete  S
		    WHERE T._ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.DayDate = S.DayDate
				AND T.Market = S.Market
				AND T.CountryNumber = S.CountryNumber
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'
					
						
					
			UPDATE IQAgent_EarnedPaidHourSummary
					SET	NumberOfDocs	  = SIGN( 1 + SIGN(ISNULL(T.NumberOfDocs,0) - ISNULL(S.NumberOfDocs,0))) * (ISNULL(T.NumberOfDocs,0) - ISNULL(S.NumberOfDocs,0)),
						NumberOfHits	  = SIGN( 1 + SIGN(ISNULL(T.NumberOfHits,0) - ISNULL(S.NumberOfHits,0))) * (ISNULL(T.NumberOfHits,0) - ISNULL(S.NumberOfHits,0)),
						AM18_20	  		  = SIGN( 1 + SIGN(ISNULL(T.AM18_20,0) - ISNULL(S.AM18_20,0))) * (ISNULL(T.AM18_20,0) - ISNULL(S.AM18_20,0)),
						AM21_24	  		  = SIGN( 1 + SIGN(ISNULL(T.AM21_24,0) - ISNULL(S.AM21_24,0))) * (ISNULL(T.AM21_24,0) - ISNULL(S.AM21_24,0)),
						AM25_34	  		  = SIGN( 1 + SIGN(ISNULL(T.AM25_34,0) - ISNULL(S.AM25_34,0))) * (ISNULL(T.AM25_34,0) - ISNULL(S.AM25_34,0)),
						AM35_49	  		  = SIGN( 1 + SIGN(ISNULL(T.AM35_49,0) - ISNULL(S.AM35_49,0))) * (ISNULL(T.AM35_49,0) - ISNULL(S.AM35_49,0)),
						AM50_54	  		  = SIGN( 1 + SIGN(ISNULL(T.AM50_54,0) - ISNULL(S.AM50_54,0))) * (ISNULL(T.AM50_54,0) - ISNULL(S.AM50_54,0)),
						AM55_64	  		  = SIGN( 1 + SIGN(ISNULL(T.AM55_64,0) - ISNULL(S.AM55_64,0))) * (ISNULL(T.AM55_64,0) - ISNULL(S.AM55_64,0)),
						AM65_Plus		  = SIGN( 1 + SIGN(ISNULL(T.AM65_Plus,0) - ISNULL(S.AM65_Plus,0))) * (ISNULL(T.AM65_Plus,0) - ISNULL(S.AM65_Plus,0)),
						AF18_20	  		  = SIGN( 1 + SIGN(ISNULL(T.AF18_20,0) - ISNULL(S.AF18_20,0))) * (ISNULL(T.AF18_20,0) - ISNULL(S.AF18_20,0)),
						AF21_24	  		  = SIGN( 1 + SIGN(ISNULL(T.AF21_24,0) - ISNULL(S.AF21_24,0))) * (ISNULL(T.AF21_24,0) - ISNULL(S.AF21_24,0)),
						AF25_34	  		  = SIGN( 1 + SIGN(ISNULL(T.AF25_34,0) - ISNULL(S.AF25_34,0))) * (ISNULL(T.AF25_34,0) - ISNULL(S.AF25_34,0)),
						AF35_49	  		  = SIGN( 1 + SIGN(ISNULL(T.AF35_49,0) - ISNULL(S.AF35_49,0))) * (ISNULL(T.AF35_49,0) - ISNULL(S.AF35_49,0)),
						AF50_54	  		  = SIGN( 1 + SIGN(ISNULL(T.AF50_54,0) - ISNULL(S.AF50_54,0))) * (ISNULL(T.AF50_54,0) - ISNULL(S.AF50_54,0)),
						AF55_64	  		  = SIGN( 1 + SIGN(ISNULL(T.AF55_64,0) - ISNULL(S.AF55_64,0))) * (ISNULL(T.AF55_64,0) - ISNULL(S.AF55_64,0)),
						AF65_Plus		  = SIGN( 1 + SIGN(ISNULL(T.AF65_Plus,0) - ISNULL(S.AF65_Plus,0))) * (ISNULL(T.AF65_Plus,0) - ISNULL(S.AF65_Plus,0)),
						TotalAudience	  = SIGN( 1 + SIGN(ISNULL(T.TotalAudience,0) - ISNULL(S.TotalAudience,0))) * (ISNULL(T.TotalAudience,0) - ISNULL(S.TotalAudience,0)),
						PositiveSentiment = SIGN( 1 + SIGN(ISNULL(T.PositiveSentiment,0) - ISNULL(S.PositiveSentiment,0))) * (ISNULL(T.PositiveSentiment,0) - ISNULL(S.PositiveSentiment,0)),
						NegativeSentiment = SIGN( 1 + SIGN(ISNULL(T.NegativeSentiment,0) - ISNULL(S.NegativeSentiment,0)))*(ISNULL(T.NegativeSentiment,0) - ISNULL(S.NegativeSentiment,0)),
						IQAdShareValue    = SIGN( 1 + SIGN(ISNULL(T.IQAdShareValue,0) - ISNULL(S.IQAdShareValue,0))) * (ISNULL(T.IQAdShareValue,0) - ISNULL(S.IQAdShareValue,0)),
						Seen_Earned		  = SIGN( 1 + SIGN(ISNULL(T.Seen_Earned,0) - ISNULL(S.Seen_Earned,0))) * (ISNULL(T.Seen_Earned,0) - ISNULL(S.Seen_Earned,0)),
						Seen_Paid		  = SIGN( 1 + SIGN(ISNULL(T.Seen_Paid,0) - ISNULL(S.Seen_Paid,0))) * (ISNULL(T.Seen_Paid,0) - ISNULL(S.Seen_Paid,0)),
						Heard_Earned	  = SIGN( 1 + SIGN(ISNULL(T.Heard_Earned,0) - ISNULL(S.Heard_Earned,0))) * (ISNULL(T.Heard_Earned,0) - ISNULL(S.Heard_Earned,0)),
						Heard_Paid		  = SIGN( 1 + SIGN(ISNULL(T.Heard_Paid,0) - ISNULL(S.Heard_Paid,0))) * (ISNULL(T.Heard_Paid,0) - ISNULL(S.Heard_Paid,0))
		    FROM IQAgent_EarnedPaidHourSummary  T WITH (NOLOCK), #IQAgent_EarnedPaidHourSummary_Delete  S
		    WHERE T._ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.HourDateTime = S.HourDateTime
				AND T.Market = S.Market
				AND T.CountryNumber = S.CountryNumber
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'
/*
-- IQAnalytic_DaySummary

			UPDATE IQAnalytic_DaySummary
					SET NumberOfHits	  = SIGN( 1 + SIGN(ISNULL(T.NumberOfHits,0) - ISNULL(S.NumberOfHits,0))) * (ISNULL(T.NumberOfHits,0) - ISNULL(S.NumberOfHits,0)),
						Seen_Earned		  = SIGN( 1 + SIGN(ISNULL(T.Seen_Earned,0) - ISNULL(S.Seen_Earned,0))) * (ISNULL(T.Seen_Earned,0) - ISNULL(S.Seen_Earned,0)),
						Seen_Paid		  = SIGN( 1 + SIGN(ISNULL(T.Seen_Paid,0) - ISNULL(S.Seen_Paid,0))) * (ISNULL(T.Seen_Paid,0) - ISNULL(S.Seen_Paid,0)),
						Heard_Earned	  = SIGN( 1 + SIGN(ISNULL(T.Heard_Earned,0) - ISNULL(S.Heard_Earned,0))) * (ISNULL(T.Heard_Earned,0) - ISNULL(S.Heard_Earned,0)),
						Heard_Paid		  = SIGN( 1 + SIGN(ISNULL(T.Heard_Paid,0) - ISNULL(S.Heard_Paid,0))) * (ISNULL(T.Heard_Paid,0) - ISNULL(S.Heard_Paid,0))
			FROM IQAnalytic_DaySummary  T WITH (NOLOCK), #IQAgent_EarnedPaidSummary_Delete  S
		    WHERE T.ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.DayDate = S.DayDate
				AND T.Market = S.Market
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'

			UPDATE IQAnalytic_DaySummary
					SET LtNumberOfHits	  = SIGN( 1 + SIGN(ISNULL(T.LtNumberOfHits,0) - ISNULL(S.NumberOfHits,0))) * (ISNULL(T.LtNumberOfHits,0) - ISNULL(S.NumberOfHits,0)),
						LtSeen_Earned		  = SIGN( 1 + SIGN(ISNULL(T.LtSeen_Earned,0) - ISNULL(S.Seen_Earned,0))) * (ISNULL(T.LtSeen_Earned,0) - ISNULL(S.Seen_Earned,0)),
						LtSeen_Paid		  = SIGN( 1 + SIGN(ISNULL(T.LtSeen_Paid,0) - ISNULL(S.Seen_Paid,0))) * (ISNULL(T.LtSeen_Paid,0) - ISNULL(S.Seen_Paid,0)),
						LtHeard_Earned	  = SIGN( 1 + SIGN(ISNULL(T.LtHeard_Earned,0) - ISNULL(S.Heard_Earned,0))) * (ISNULL(T.LtHeard_Earned,0) - ISNULL(S.Heard_Earned,0)),
						LtHeard_Paid		  = SIGN( 1 + SIGN(ISNULL(T.LtHeard_Paid,0) - ISNULL(S.Heard_Paid,0))) * (ISNULL(T.LtHeard_Paid,0) - ISNULL(S.Heard_Paid,0))
			FROM IQAnalytic_DaySummary  T WITH (NOLOCK), #IQAgent_EarnedPaidLocalTimeSummary_Delete  S
		    WHERE T.ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.DayDate = S.DayDate
				AND T.Market = S.Market
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'
					
						
					
			UPDATE IQAnalytic_HourSummary
					SET	NumberOfHits	  = SIGN( 1 + SIGN(ISNULL(T.NumberOfHits,0) - ISNULL(S.NumberOfHits,0))) * (ISNULL(T.NumberOfHits,0) - ISNULL(S.NumberOfHits,0)),
						Seen_Earned		  = SIGN( 1 + SIGN(ISNULL(T.Seen_Earned,0) - ISNULL(S.Seen_Earned,0))) * (ISNULL(T.Seen_Earned,0) - ISNULL(S.Seen_Earned,0)),
						Seen_Paid		  = SIGN( 1 + SIGN(ISNULL(T.Seen_Paid,0) - ISNULL(S.Seen_Paid,0))) * (ISNULL(T.Seen_Paid,0) - ISNULL(S.Seen_Paid,0)),
						Heard_Earned	  = SIGN( 1 + SIGN(ISNULL(T.Heard_Earned,0) - ISNULL(S.Heard_Earned,0))) * (ISNULL(T.Heard_Earned,0) - ISNULL(S.Heard_Earned,0)),
						Heard_Paid		  = SIGN( 1 + SIGN(ISNULL(T.Heard_Paid,0) - ISNULL(S.Heard_Paid,0))) * (ISNULL(T.Heard_Paid,0) - ISNULL(S.Heard_Paid,0))
		    FROM IQAnalytic_HourSummary  T WITH (NOLOCK), #IQAgent_EarnedPaidHourSummary_Delete  S
		    WHERE T.ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.HourDateTime = S.HourDateTime
				AND T.Market = S.Market
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'
-- 
*/
	   END


	IF (SELECT COUNT(1) FROM #IQAgent_EarnedPaidSummary) > 0
	   BEGIN
			UPDATE IQAgent_EarnedPaidDaySummary
					SET NumberOfDocs	  = ISNULL(T.NumberOfDocs,0) + ISNULL(S.NumberOfDocs,0),
						NumberOfHits	  = ISNULL(T.NumberOfHits,0) + ISNULL(S.NumberOfHits,0),
						AM18_20	  		  = ISNULL(T.AM18_20,0) + ISNULL(S.AM18_20,0),
						AM21_24	  		  = ISNULL(T.AM21_24,0) + ISNULL(S.AM21_24,0),
						AM25_34	  		  = ISNULL(T.AM25_34,0) + ISNULL(S.AM25_34,0),
						AM35_49	  		  = ISNULL(T.AM35_49,0) + ISNULL(S.AM35_49,0),
						AM50_54	  		  = ISNULL(T.AM50_54,0) + ISNULL(S.AM50_54,0),
						AM55_64	  		  = ISNULL(T.AM55_64,0) + ISNULL(S.AM55_64,0),
						AM65_Plus		  = ISNULL(T.AM65_Plus,0) + ISNULL(S.AM65_Plus,0),
						AF18_20	  		  = ISNULL(T.AF18_20,0) + ISNULL(S.AF18_20,0),
						AF21_24	  		  = ISNULL(T.AF21_24,0) + ISNULL(S.AF21_24,0),
						AF25_34	  		  = ISNULL(T.AF25_34,0) + ISNULL(S.AF25_34,0),
						AF35_49	  		  = ISNULL(T.AF35_49,0) + ISNULL(S.AF35_49,0),
						AF50_54	  		  = ISNULL(T.AF50_54,0) + ISNULL(S.AF50_54,0),
						AF55_64	  		  = ISNULL(T.AF55_64,0) + ISNULL(S.AF55_64,0),
						AF65_Plus		  = ISNULL(T.AF65_Plus,0) + ISNULL(S.AF65_Plus,0),
						TotalAudience	  = ISNULL(T.TotalAudience,0) + ISNULL(S.TotalAudience,0),
						PositiveSentiment = ISNULL(T.PositiveSentiment,0) + ISNULL(S.PositiveSentiment,0),
						NegativeSentiment = ISNULL(T.NegativeSentiment,0) + ISNULL(S.NegativeSentiment,0),
						IQAdShareValue    = ISNULL(T.IQAdShareValue,0) + ISNULL(S.IQAdShareValue,0),
						Seen_Earned		  = ISNULL(T.Seen_Earned,0) + ISNULL(S.Seen_Earned,0),
						Seen_Paid		  = ISNULL(T.Seen_Paid,0) + ISNULL(S.Seen_Paid,0),
						Heard_Earned	  = ISNULL(T.Heard_Earned,0) + ISNULL(S.Heard_Earned,0),
						Heard_Paid		  = ISNULL(T.Heard_Paid,0) + ISNULL(S.Heard_Paid,0)
			FROM IQAgent_EarnedPaidDaySummary  T WITH (NOLOCK), #IQAgent_EarnedPaidSummary  S
		    WHERE T._ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.DayDate = S.DayDate
				AND T.Market = S.Market
				AND T.CountryNumber = S.CountryNumber
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'

			UPDATE IQAgent_EarnedPaidDaySummary
					SET LtNumberOfDocs	  = ISNULL(T.LtNumberOfDocs,0) + ISNULL(S.NumberOfDocs,0),
						LtNumberOfHits	  = ISNULL(T.LtNumberOfHits,0) + ISNULL(S.NumberOfHits,0),
						LtAM18_20	  		  = ISNULL(T.LtAM18_20,0) + ISNULL(S.AM18_20,0),
						LtAM21_24	  		  = ISNULL(T.LtAM21_24,0) + ISNULL(S.AM21_24,0),
						LtAM25_34	  		  = ISNULL(T.LtAM25_34,0) + ISNULL(S.AM25_34,0),
						LtAM35_49	  		  = ISNULL(T.LtAM35_49,0) + ISNULL(S.AM35_49,0),
						LtAM50_54	  		  = ISNULL(T.LtAM50_54,0) + ISNULL(S.AM50_54,0),
						LtAM55_64	  		  = ISNULL(T.LtAM55_64,0) + ISNULL(S.AM55_64,0),
						LtAM65_Plus		  = ISNULL(T.LtAM65_Plus,0) + ISNULL(S.AM65_Plus,0),
						LtAF18_20	  		  = ISNULL(T.LtAF18_20,0) + ISNULL(S.AF18_20,0),
						LtAF21_24	  		  = ISNULL(T.LtAF21_24,0) + ISNULL(S.AF21_24,0),
						LtAF25_34	  		  = ISNULL(T.LtAF25_34,0) + ISNULL(S.AF25_34,0),
						LtAF35_49	  		  = ISNULL(T.LtAF35_49,0) + ISNULL(S.AF35_49,0),
						LtAF50_54	  		  = ISNULL(T.LtAF50_54,0) + ISNULL(S.AF50_54,0),
						LtAF55_64	  		  = ISNULL(T.LtAF55_64,0) + ISNULL(S.AF55_64,0),
						LtAF65_Plus		  = ISNULL(T.LtAF65_Plus,0) + ISNULL(S.AF65_Plus,0),
						LtTotalAudience	  = ISNULL(T.LtTotalAudience,0) + ISNULL(S.TotalAudience,0),
						LtPositiveSentiment = ISNULL(T.LtPositiveSentiment,0) + ISNULL(S.PositiveSentiment,0),
						NegativeSentiment = ISNULL(T.LtNegativeSentiment,0) + ISNULL(S.NegativeSentiment,0),
						LtIQAdShareValue    = ISNULL(T.LtIQAdShareValue,0) + ISNULL(S.IQAdShareValue,0),
						LtSeen_Earned		  = ISNULL(T.LtSeen_Earned,0) + ISNULL(S.Seen_Earned,0),
						LtSeen_Paid		  = ISNULL(T.LtSeen_Paid,0) + ISNULL(S.Seen_Paid,0),
						LtHeard_Earned	  = ISNULL(T.LtHeard_Earned,0) + ISNULL(S.Heard_Earned,0),
						LtHeard_Paid		  = ISNULL(T.LtHeard_Paid,0) + ISNULL(S.Heard_Paid,0)
			FROM IQAgent_EarnedPaidDaySummary  T WITH (NOLOCK), #IQAgent_EarnedPaidLocalTimeSummary  S
		    WHERE T._ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.DayDate = S.DayDate
				AND T.Market = S.Market
				AND T.CountryNumber = S.CountryNumber
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'	
						
					
			UPDATE IQAgent_EarnedPaidHourSummary
					SET	NumberOfDocs	  = ISNULL(T.NumberOfDocs,0) + ISNULL(S.NumberOfDocs,0),
						NumberOfHits	  = ISNULL(T.NumberOfHits,0) + ISNULL(S.NumberOfHits,0),
						AM18_20	  		  = ISNULL(T.AM18_20,0) + ISNULL(S.AM18_20,0),
						AM21_24	  		  = ISNULL(T.AM21_24,0) + ISNULL(S.AM21_24,0),
						AM25_34	  		  = ISNULL(T.AM25_34,0) + ISNULL(S.AM25_34,0),
						AM35_49	  		  = ISNULL(T.AM35_49,0) + ISNULL(S.AM35_49,0),
						AM50_54	  		  = ISNULL(T.AM50_54,0) + ISNULL(S.AM50_54,0),
						AM55_64	  		  = ISNULL(T.AM55_64,0) + ISNULL(S.AM55_64,0),
						AM65_Plus		  = ISNULL(T.AM65_Plus,0) + ISNULL(S.AM65_Plus,0),
						AF18_20	  		  = ISNULL(T.AF18_20,0) + ISNULL(S.AF18_20,0),
						AF21_24	  		  = ISNULL(T.AF21_24,0) + ISNULL(S.AF21_24,0),
						AF25_34	  		  = ISNULL(T.AF25_34,0) + ISNULL(S.AF25_34,0),
						AF35_49	  		  = ISNULL(T.AF35_49,0) + ISNULL(S.AF35_49,0),
						AF50_54	  		  = ISNULL(T.AF50_54,0) + ISNULL(S.AF50_54,0),
						AF55_64	  		  = ISNULL(T.AF55_64,0) + ISNULL(S.AF55_64,0),
						AF65_Plus		  = ISNULL(T.AF65_Plus,0) + ISNULL(S.AF65_Plus,0),
						TotalAudience	  = ISNULL(T.TotalAudience,0) + ISNULL(S.TotalAudience,0),
						PositiveSentiment = ISNULL(T.PositiveSentiment,0) + ISNULL(S.PositiveSentiment,0),
						NegativeSentiment = ISNULL(T.NegativeSentiment,0) + ISNULL(S.NegativeSentiment,0),
						IQAdShareValue    = ISNULL(T.IQAdShareValue,0) + ISNULL(S.IQAdShareValue,0),
						Seen_Earned		  = ISNULL(T.Seen_Earned,0) + ISNULL(S.Seen_Earned,0),
						Seen_Paid		  = ISNULL(T.Seen_Paid,0) + ISNULL(S.Seen_Paid,0),
						Heard_Earned	  = ISNULL(T.Heard_Earned,0) + ISNULL(S.Heard_Earned,0),
						Heard_Paid		  = ISNULL(T.Heard_Paid,0) + ISNULL(S.Heard_Paid,0)
		    FROM IQAgent_EarnedPaidHourSummary  T WITH (NOLOCK), #IQAgent_EarnedPaidHourSummary  S
		    WHERE T._ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.HourDateTime = S.HourDateTime
				AND T.Market = S.Market
				AND T.CountryNumber = S.CountryNumber
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'
/*
-- IQAnalytic_DaySummary

			UPDATE IQAnalytic_DaySummary
					SET NumberOfHits	  = ISNULL(T.NumberOfHits,0) + ISNULL(S.NumberOfHits,0),
						Seen_Earned		  = ISNULL(T.Seen_Earned,0) + ISNULL(S.Seen_Earned,0),
						Seen_Paid		  = ISNULL(T.Seen_Paid,0) + ISNULL(S.Seen_Paid,0),
						Heard_Earned	  = ISNULL(T.Heard_Earned,0) + ISNULL(S.Heard_Earned,0),
						Heard_Paid		  = ISNULL(T.Heard_Paid,0) + ISNULL(S.Heard_Paid,0)
			FROM IQAnalytic_DaySummary  T WITH (NOLOCK), #IQAgent_EarnedPaidSummary  S
		    WHERE T.ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.DayDate = S.DayDate
				AND T.Market = S.Market
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'

			UPDATE IQAnalytic_DaySummary
					SET LtNumberOfHits	  = ISNULL(T.LtNumberOfHits,0) + ISNULL(S.NumberOfHits,0),
						LtSeen_Earned		  = ISNULL(T.LtSeen_Earned,0) + ISNULL(S.Seen_Earned,0),
						LtSeen_Paid		  = ISNULL(T.LtSeen_Paid,0) + ISNULL(S.Seen_Paid,0),
						LtHeard_Earned	  = ISNULL(T.LtHeard_Earned,0) + ISNULL(S.Heard_Earned,0),
						LtHeard_Paid		  = ISNULL(T.LtHeard_Paid,0) + ISNULL(S.Heard_Paid,0)
			FROM IQAnalytic_DaySummary  T WITH (NOLOCK), #IQAgent_EarnedPaidLocalTimeSummary  S
		    WHERE T.ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.DayDate = S.DayDate
				AND T.Market = S.Market
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'	
						
					
			UPDATE IQAnalytic_HourSummary
					SET	NumberOfHits	  = ISNULL(T.NumberOfHits,0) + ISNULL(S.NumberOfHits,0),
						Seen_Earned		  = ISNULL(T.Seen_Earned,0) + ISNULL(S.Seen_Earned,0),
						Seen_Paid		  = ISNULL(T.Seen_Paid,0) + ISNULL(S.Seen_Paid,0),
						Heard_Earned	  = ISNULL(T.Heard_Earned,0) + ISNULL(S.Heard_Earned,0),
						Heard_Paid		  = ISNULL(T.Heard_Paid,0) + ISNULL(S.Heard_Paid,0)
		    FROM IQAnalytic_HourSummary  T WITH (NOLOCK), #IQAgent_EarnedPaidHourSummary  S
		    WHERE T.ClientGuid = S.ClientGuid
				AND T._SearchRequestID = S.SearchRequestID
				AND T.HourDateTime = S.HourDateTime
				AND T.Market = S.Market
				AND MediaType ='TV'
				AND SubMediaTYpe='TV'

--
*/ 
	   END

		
			DELETE IQAgent_TableResults_DirtyTable 
				   FROM IQAgent_TableResults_DirtyTable  d, #Tmp_DirtyTable tmp
						WHERE d.ID = tmp.ID
				     
		
		COMMIT TRANSACTION

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
				@CreatedBy='usp_DBJob_DeleteEarnedPaidSummary_ForTVLR',
				@ModifiedBy='usp_DBJob_DeleteEarnedPaidSummary_ForTVLR',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
END CATCH      
  

    
END

GO


