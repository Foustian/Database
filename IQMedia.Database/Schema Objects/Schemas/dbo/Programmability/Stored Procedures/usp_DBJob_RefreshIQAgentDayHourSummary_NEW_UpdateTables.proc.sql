USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_RefreshIQAgentDayHourSummary_NEW_UpdateTables]    Script Date: 10/20/2016 3:18:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_DBJob_RefreshIQAgentDayHourSummary_NEW_UpdateTables]
(@Process CHAR(1))
AS
BEGIN
   
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

-- Created Date :	May 2015
-- Description   :  Called by the usp_Refresh_IQAgent_DayHourSummary, so it can use the #TmpDaySummaryLDResults_Final temp table index. 

BEGIN TRY  	

Begin Transaction			
				Merge Into dbo.IQAgent_DaySummary_NEW As Target
				Using #TmpDaySummaryLDResults AS Source
					    ON	Target.DayDate = Source.LocalMediaDate
						AND Target.SubMediaType = Source.SubMediaType
						AND Target._SearchRequestID = Source._SearchRequestID    
						AND Target.ClientGuid = Source.ClientGUID 
						AND Target.MediaType = Source.MediaType
				When Matched THEN
				UPDATE 
					SET	NoOfDocsLD = ISNULL(Target.NoOfDocsLD,0) + Source.NoOfDocs, 
						NoOfHitsLD = ISNULL(Target.NoOfHitsLD,0) + Source.NoOfHits,
						AudienceLD = ISNULL(Target.AudienceLD,0) + Source.Audience,
						IQMediaValueLD = ISNULL(Target.IQMediaValueLD,0) + Source.MediaValue,
						PositiveSentimentLD = ISNULL(Target.PositiveSentimentLD,0) + Source.PositiveSentiment,
						NegativeSentimentLD = ISNULL(Target.NegativeSentimentLD,0) + Source.NegativeSentiment,
						LastUpdated = GETDATE(),
						Process=@Process
				When Not Matched By Target Then
					INSERT(ClientGuid,DayDate,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,IQMediaValue,SubMediaType,
					PositiveSentiment,NegativeSentiment,NoOfDocsLD,NoOfHitsLD,AudienceLD,IQMediaValueLD,PositiveSentimentLD,NegativeSentimentLD,LastUpdated,Process) 
					Values(ClientGUID,LocalMediaDate,MediaType,_SearchRequestID,
							0,0,0,0,SubMediaType,0,0,NoOfDocs,NoOfHits,Audience,MediaValue,PositiveSentiment,NegativeSentiment,GETDATE(),@Process);
					
				Merge Into dbo.IQAgent_DaySummary_NEW As Target
				Using #TmpDaySummaryResults AS Source
						    ON	Target.DayDate = Source.MediaDate
							AND Target.SubMediaType = Source.SubMediaType
							AND Target._SearchRequestID = Source._SearchRequestID    
							AND Target.ClientGuid = Source.ClientGUID 
							AND Target.MediaType = Source.MediaType
				When Matched THEN
				UPDATE 
							SET	NoOfDocs = ISNULL(Target.NoOfDocs,0) + Source.NoOfDocs, 
								NoOfHits = ISNULL(Target.NoOfHits,0)+ Source.NoOfHits,
								Audience = ISNULL(Target.Audience,0) + Source.Audience,
								IQMediaValue = ISNULL(Target.IQMediaValue,0) + Source.MediaValue,
								PositiveSentiment = ISNULL(Target.PositiveSentiment,0) + Source.PositiveSentiment,
								NegativeSentiment = ISNULL(Target.NegativeSentiment,0) + Source.NegativeSentiment,
								LastUpdated = GETDATE(),
								Process=@Process
				When Not Matched By Target Then
					INSERT(ClientGuid,DayDate,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,IQMediaValue,SubMediaType,
					PositiveSentiment,NegativeSentiment,NoOfDocsLD,NoOfHitsLD,AudienceLD,IQMediaValueLD,PositiveSentimentLD,NegativeSentimentLD,LastUpdated,Process) 
					Values
					(ClientGUID,MediaDate,MediaType,_SearchRequestID,Source.NoOfDocs,Source.NoOfHits,Source.Audience,Source.MediaValue,SubMediaType,
					Source.PositiveSentiment,Source.NegativeSentiment,0,0,0,0,0,0,GETDATE(),@Process);
							
				Merge Into dbo.IQAgent_HourSummary_NEW As Target
				Using #TmpHourSummaryResults AS Source
						    ON	Target.HourDateTime = Source.MediaDateTime
							AND Target.SubMediaType = Source.SubMediaType
							AND Target._SearchRequestID = Source._SearchRequestID    
							AND Target.ClientGuid = Source.ClientGUID 
							AND Target.MediaType = Source.MediaType
							When Matched THEN
				UPDATE 
						SET	NoOfDocs = ISNULL(Target.NoOfDocs,0) + Source.NoOfDocs, 
							NoOfHits = ISNULL(Target.NoOfHits,0) + Source.NoOfHits,
							Audience = ISNULL(Target.Audience,0) + Source.Audience,
							IQMediaValue = ISNULL(Target.IQMediaValue,0) + Source.MediaValue,
							PositiveSentiment = ISNULL(Target.PositiveSentiment,0) + Source.PositiveSentiment,
							NegativeSentiment = ISNULL(Target.NegativeSentiment,0) + Source.NegativeSentiment,
							LastUpdated = GETDATE(),
							Process=@Process
				When Not Matched By Target Then
				INSERT(ClientGuid,HourDateTime,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,IQMediaValue,PositiveSentiment,NegativeSentiment,SubMediaType,LastUpdated,Process)
				Values(ClientGUID,MediaDateTime,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,MediaValue,PositiveSentiment,NegativeSentiment,SubMediaType,GETDATE(),@Process);
							
			
							
							
Commit Transaction
Return 0
END TRY
		BEGIN CATCH
		    Rollback Transaction
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
				@CreatedBy='usp_DBJob_RefreshIQAgentDayHourSummary_NEW_UpdateTables',
				@ModifiedBy='usp_DBJob_RefreshIQAgentDayHourSummary_NEW_UpdateTables',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
				Return -1
		END CATCH        

END


























GO


