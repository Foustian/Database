USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_RecalculateEarnedPaidSummary_ForTV]    Script Date: 10/20/2016 3:10:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_RecalculateEarnedPaidSummary_ForTV]        

AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY        
 	
	DECLARE @IQ_ADS_Station_Control TABLE (StationID VARCHAR(100))
	INSERT INTO @IQ_ADS_Station_Control(StationID) SELECT StationID FROM IQ_ADS_Station_Control

	BEGIN TRANSACTION		
			
			
					UPDATE IQAgent_EarnedPaidDaySummary 
					SET NumberOFDocs	= ISNULL(t.NumberOFDocs,0) - ISNULL(s.NumberOFDocs,0),
						NumberOfHits	= ISNULL(t.NumberOfHits,0) - ISNULL(s.NumberOfHits,0),
						AM18_20			= ISNULL(t.AM18_20,0) - ISNULL(s.AM18_20,0),
						AM21_24			= ISNULL(t.AM21_24,0) - ISNULL(s.AM21_24,0),
						AM25_34			= ISNULL(t.AM25_34,0) - ISNULL(s.AM25_34,0),
						AM35_49			= ISNULL(t.AM35_49,0) - ISNULL(s.AM35_49,0),
						AM50_54			= ISNULL(t.AM50_54,0) - ISNULL(s.AM50_54,0),
						AM55_64			= ISNULL(t.AM55_64,0) - ISNULL(s.AM55_64,0),
						AM65_Plus		= ISNULL(t.AM65_Plus,0) - ISNULL(s.AM65_Plus,0),
						AF18_20			= ISNULL(t.AF18_20,0) - ISNULL(s.AF18_20,0),
						AF21_24			= ISNULL(t.AF21_24,0) - ISNULL(s.AF21_24,0),
						AF25_34			= ISNULL(t.AF25_34,0) - ISNULL(s.AF25_34,0),
						AF35_49			= ISNULL(t.AF35_49,0) - ISNULL(s.AF35_49,0),
						AF50_54			= ISNULL(t.AF50_54,0) - ISNULL(s.AF50_54,0),
						AF55_64			= ISNULL(t.AF55_64,0) - ISNULL(s.AF55_64,0),
						AF65_Plus		= ISNULL(t.AF65_Plus,0) - ISNULL(s.AF65_Plus,0),
						TotalAudience	= ISNULL(t.TotalAudience,0) - ISNULL(s.TotalAudience,0),
						PositiveSentiment	= ISNULL(t.PositiveSentiment,0) - ISNULL(s.PositiveSentiment,0),
						NegativeSentiment	= ISNULL(t.NegativeSentiment,0) - ISNULL(s.NegativeSentiment,0),
						IQAdShareValue		= ISNULL(t.IQAdShareValue,0) - ISNULL(s.IQAdShareValue,0),
						Heard_Earned	  = ISNULL(t.Heard_Earned,0) - ISNULL(s.Heard_Earned,0),
						Heard_Paid		  = ISNULL(t.Heard_Paid,0) - ISNULL(s.Heard_Paid,0)
					FROM IQAgent_EarnedPaidDaySummary t WITH (NOLOCK), #IQAgent_EarnedPaidDaySummary_Delete_ADS s
					WHERE
					    T.DayDate = S.DayDate
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.Market = S.Market
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.CountryNumber = S.CountryNumber
				
					
					UPDATE IQAgent_EarnedPaidDaySummary 
					SET LtNumberOFDocs	= ISNULL(t.LtNumberOFDocs,0) - ISNULL(s.NumberOFDocs,0),
						LtNumberOfHits	= ISNULL(t.LtNumberOfHits,0) - ISNULL(s.NumberOfHits,0),
						LtAM18_20			= ISNULL(t.LtAM18_20,0) - ISNULL(s.AM18_20,0),
						LtAM21_24			= ISNULL(t.LtAM21_24,0) - ISNULL(s.AM21_24,0),
						LtAM25_34			= ISNULL(t.LtAM25_34,0) - ISNULL(s.AM25_34,0),
						LtAM35_49			= ISNULL(t.LtAM35_49,0) - ISNULL(s.AM35_49,0),
						LtAM50_54			= ISNULL(t.LtAM50_54,0) - ISNULL(s.AM50_54,0),
						LtAM55_64			= ISNULL(t.LtAM55_64,0) - ISNULL(s.AM55_64,0),
						LtAM65_Plus		= ISNULL(t.LtAM65_Plus,0) - ISNULL(s.AM65_Plus,0),
						LtAF18_20			= ISNULL(t.LtAF18_20,0) - ISNULL(s.AF18_20,0),
						LtAF21_24			= ISNULL(t.LtAF21_24,0) - ISNULL(s.AF21_24,0),
						LtAF25_34			= ISNULL(t.LtAF25_34,0) - ISNULL(s.AF25_34,0),
						LtAF35_49			= ISNULL(t.LtAF35_49,0) - ISNULL(s.AF35_49,0),
						LtAF50_54			= ISNULL(t.LtAF50_54,0) - ISNULL(s.AF50_54,0),
						LtAF55_64			= ISNULL(t.LtAF55_64,0) - ISNULL(s.AF55_64,0),
						LtAF65_Plus		= ISNULL(t.LtAF65_Plus,0) - ISNULL(s.AF65_Plus,0),
						LtTotalAudience	= ISNULL(t.LtTotalAudience,0) - ISNULL(s.TotalAudience,0),
						LtPositiveSentiment	= ISNULL(t.LtPositiveSentiment,0) - ISNULL(s.PositiveSentiment,0),
						LtNegativeSentiment	= ISNULL(t.LtNegativeSentiment,0) - ISNULL(s.NegativeSentiment,0),
						LtIQAdShareValue		= ISNULL(t.LtIQAdShareValue,0) - ISNULL(s.IQAdShareValue,0),
						LtHeard_Earned	  = ISNULL(t.LtHeard_Earned,0) - ISNULL(s.Heard_Earned,0),
						LtHeard_Paid		  = ISNULL(t.LtHeard_Paid,0) - ISNULL(s.Heard_Paid,0)
					FROM IQAgent_EarnedPaidDaySummary t WITH (NOLOCK), #IQAgent_EarnedPaidLocalTimeDaySummary_Delete_ADS s
					WHERE
						T.DayDate = S.DayDate
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.Market = S.Market
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.CountryNumber = S.CountryNumber

					UPDATE IQAgent_EarnedPaidHourSummary 
					SET NumberOFDocs	= ISNULL(t.NumberOFDocs,0) - ISNULL(s.NumberOFDocs,0),
						NumberOfHits	= ISNULL(t.NumberOfHits,0) - ISNULL(s.NumberOfHits,0),
						AM18_20			= ISNULL(t.AM18_20,0) - ISNULL(s.AM18_20,0),
						AM21_24			= ISNULL(t.AM21_24,0) - ISNULL(s.AM21_24,0),
						AM25_34			= ISNULL(t.AM25_34,0) - ISNULL(s.AM25_34,0),
						AM35_49			= ISNULL(t.AM35_49,0) - ISNULL(s.AM35_49,0),
						AM50_54			= ISNULL(t.AM50_54,0) - ISNULL(s.AM50_54,0),
						AM55_64			= ISNULL(t.AM55_64,0) - ISNULL(s.AM55_64,0),
						AM65_Plus		= ISNULL(t.AM65_Plus,0) - ISNULL(s.AM65_Plus,0),
						AF18_20			= ISNULL(t.AF18_20,0) - ISNULL(s.AF18_20,0),
						AF21_24			= ISNULL(t.AF21_24,0) - ISNULL(s.AF21_24,0),
						AF25_34			= ISNULL(t.AF25_34,0) - ISNULL(s.AF25_34,0),
						AF35_49			= ISNULL(t.AF35_49,0) - ISNULL(s.AF35_49,0),
						AF50_54			= ISNULL(t.AF50_54,0) - ISNULL(s.AF50_54,0),
						AF55_64			= ISNULL(t.AF55_64,0) - ISNULL(s.AF55_64,0),
						AF65_Plus		= ISNULL(t.AF65_Plus,0) - ISNULL(s.AF65_Plus,0),
						TotalAudience	= ISNULL(t.TotalAudience,0) - ISNULL(s.TotalAudience,0),
						PositiveSentiment	= ISNULL(t.PositiveSentiment,0) - ISNULL(s.PositiveSentiment,0),
						NegativeSentiment	= ISNULL(t.NegativeSentiment,0) - ISNULL(s.NegativeSentiment,0),
						IQAdShareValue		= ISNULL(t.IQAdShareValue,0) - ISNULL(s.IQAdShareValue,0),
						Heard_Earned	  = ISNULL(t.Heard_Earned,0) - ISNULL(s.Heard_Earned,0),
						Heard_Paid		  = ISNULL(t.Heard_Paid,0) - ISNULL(s.Heard_Paid,0)
					FROM IQAgent_EarnedPaidHourSummary t WITH (NOLOCK), #IQAgent_EarnedPaidHourSummary_Delete_ADS s
					WHERE
						T.HourDateTime = S.HourDateTime
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.Market = S.Market
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.CountryNumber = S.CountryNumber
		/*		
				select * into LV_Temp.dbo.IQAgent_EarnedPaidDaySummary_OldHits FROM #IQAgent_EarnedPaidDaySummary_OldHits
				select * into IQAgent_EarnedPaidLocalTimeDaySummary_OldHits FROM #IQAgent_EarnedPaidLocalTimeDaySummary_OldHits
				select * into IQAgent_EarnedPaidHourSummary_OldHits FROM #IQAgent_EarnedPaidHourSummary_OldHits
				select * into LV_Temp.dbo.IQAgent_EarnedPaidDaySummary_NewHits FROM #IQAgent_EarnedPaidDaySummary_NewHits
				select * into IQAgent_EarnedPaidLocalTimeDaySummary_NewHits FROM #IQAgent_EarnedPaidLocalTimeDaySummary_NewHits
				select * into IQAgent_EarnedPaidHourSummary_NewHits FROM #IQAgent_EarnedPaidHourSummary_NewHits
*/
	-- Update IQAnalytic

					UPDATE IQAgent_AnalyticsDaySummary  
					SET NumberOfHits	= ISNULL(t.NumberOfHits,0) - ISNULL(s.NumberOfHits,0),
						Heard_Earned	  = ISNULL(t.Heard_Earned,0) - ISNULL(s.Earned,0),
						Heard_Paid		  = ISNULL(t.Heard_Paid,0) - ISNULL(s.Paid,0)
					FROM IQAgent_AnalyticsDaySummary   t WITH (NOLOCK), #IQAgent_EarnedPaidDaySummary_OldHits s
					WHERE
					    T.DayDate = S.DayDate
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
					
							
					UPDATE IQAgent_AnalyticsDaySummary 
					SET LtNumberOfHits	= ISNULL(t.LtNumberOfHits,0) - ISNULL(s.NumberOfHits,0),
						LtHeard_Earned	  = ISNULL(t.LtHeard_Earned,0) - ISNULL(s.Earned,0),
						LtHeard_Paid		  = ISNULL(t.LtHeard_Paid,0) - ISNULL(s.Paid,0)
					FROM IQAgent_AnalyticsDaySummary  t WITH (NOLOCK), #IQAgent_EarnedPaidLocalTimeDaySummary_OldHits s
					WHERE
						T.DayDate = S.DayDate
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
					

					UPDATE IQAgent_AnalyticsHourSummary  
					SET NumberOfHits	= ISNULL(t.NumberOfHits,0) - ISNULL(s.NumberOfHits,0),
						Heard_Earned	  = ISNULL(t.Heard_Earned,0) - ISNULL(s.Earned,0),
						Heard_Paid		  = ISNULL(t.Heard_Paid,0) - ISNULL(s.Paid,0)
					FROM IQAgent_AnalyticsHourSummary   t WITH (NOLOCK), #IQAgent_EarnedPaidHourSummary_OldHits s
					WHERE
					    T.GMTHourDateTime = S.HourDateTime
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
		/*	
					-- Subtract Old Hits Value
					UPDATE IQAgent_AnalyticsDaySummary 
					SET NumberOfHits	= ISNULL(t.NumberOfHits,0) - ISNULL(s.NumberOfHits,0)
					FROM IQAgent_AnalyticsDaySummary t WITH (NOLOCK), #IQAgent_EarnedPaidDaySummary_OldHits s
					WHERE
					    T.DayDate = S.DayDate
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
				
				
					
					UPDATE IQAgent_AnalyticsDaySummary
					SET LtNumberOfHits	= ISNULL(t.LtNumberOfHits,0) - ISNULL(s.NumberOfHits,0)
					FROM IQAgent_AnalyticsDaySummary t WITH (NOLOCK), #IQAgent_EarnedPaidLocalTimeDaySummary_OldHits s
					WHERE
					    T.DayDate = S.DayDate
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
				

					UPDATE IQAgent_AnalyticsHourSummary
					SET 	NumberOfHits	= ISNULL(t.NumberOfHits,0) - ISNULL(s.NumberOfHits,0)
					FROM  IQAgent_AnalyticsHourSummary t WITH (NOLOCK), #IQAgent_EarnedPaidHourSummary_OldHits s
					WHERE
					    T.GMTHourDateTime = S.HourDateTime
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
		*/			
					--  Add New Hits Value
					UPDATE IQAgent_AnalyticsDaySummary 
					SET NumberOfHits	= ISNULL(t.NumberOfHits,0) + ISNULL(s.NumberOfHits,0)
					FROM  IQAgent_AnalyticsDaySummary t WITH (NOLOCK), #IQAgent_EarnedPaidDaySummary_NewHits s
					WHERE
					    T.DayDate = S.DayDate
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
					
				
					
					UPDATE IQAgent_AnalyticsDaySummary
					SET LtNumberOfHits	= ISNULL(t.LtNumberOfHits,0) + ISNULL(s.NumberOfHits,0)
					FROM  IQAgent_AnalyticsDaySummary  t WITH (NOLOCK), #IQAgent_EarnedPaidLocalTimeDaySummary_NewHits s
					WHERE
					    T.DayDate = S.DayDate
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
				

					UPDATE IQAgent_AnalyticsHourSummary 
					SET 	NumberOfHits	= ISNULL(t.NumberOfHits,0) + ISNULL(s.NumberOfHits,0)
					FROM IQAgent_AnalyticsHourSummary  t WITH (NOLOCK), #IQAgent_EarnedPaidHourSummary_NewHits s
					WHERE
					    T.GMTHourDateTime = S.HourDateTime
					AND T._ClientGuid = S.ClientGuid
					AND T._SearchRequestID = S.SearchRequestID
					AND T.MediaType='TV'
					AND T.SubMediaType='TV'
					AND T.Market = S.Market
					

					-- Reset the Process Flag, so it will be reprocessed by the E/P Job
					UPDATE IQAgent_TVResults
					SET Earned  = NULL,
					    Paid    = NULL,
					    Process = NULL
					FROM IQAgent_TVResults tv WITH (NOLOCK), #IQAgent_TableResults_DirtyTable s
					   WHERE tv.ID = s._IQAgent_MediaID AND tv.RL_Station IN (SELECT StationID FROM @IQ_ADS_Station_Control)

					UPDATE IQAgent_TVResults
					SET Earned  = NULL,
					    Paid    = NULL
					FROM IQAgent_TVResults tv WITH (NOLOCK), #IQAgent_TableResults_DirtyTable0 s
					   WHERE tv.ID = s._IQAgent_MediaID

					UPDATE IQAgent_TVResults
					SET Earned  = NULL,
					    Paid    = NULL
					FROM IQAgent_TVResults tv WITH (NOLOCK), #IQAgent_TableResults_DirtyTable1 s
					   WHERE tv.ID = s._IQAgent_MediaID

					DELETE IQAgent_TableResults_DirtyTable 
				   	FROM IQAgent_TableResults_DirtyTable d, #IQAgent_TableResults_DirtyTable tmp
						WHERE d.ID = tmp.Dirtytbl_ID

					DELETE IQAgent_TableResults_DirtyTable 
				   	FROM IQAgent_TableResults_DirtyTable d, #IQAgent_TableResults_DirtyTable0 tmp
						WHERE d.ID = tmp.Dirtytbl_ID
				     
					DELETE IQAgent_TableResults_DirtyTable 
				   	FROM IQAgent_TableResults_DirtyTable d, #IQAgent_TableResults_DirtyTable1 tmp
						WHERE d.ID = tmp.Dirtytbl_ID

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
				@CreatedBy='usp_DBJob_RecalculateEarnedPaidSummary_ForTVLR',
				@ModifiedBy='usp_DBJob_RecalculateEarnedPaidSummary_ForTVLR',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
END CATCH      
  

    
END

GO


