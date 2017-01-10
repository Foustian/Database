USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_Refresh_IQAgent_DayHourSummary_Subprocess_2]    Script Date: 8/12/2015 10:57:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_Refresh_IQAgent_DayHourSummary_Subprocess_2]
AS
BEGIN
   
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

-- Created Date :	May 2015
-- Description   :  Called by the usp_Refresh_IQAgent_DayHourSummary, so it can use the #TmpDaySummaryLDResults_Final temp table index. 

BEGIN TRY  	
/*
UPDATE 
			LV_Temp.dbo.I_DaySummary99
		SET
			NoOfDocsLD = TmpDSLDR.NoOfDocs, 
			NoOfHitsLD = TmpDSLDR.NoOfHits,
			AudienceLD = TmpDSLDR.Audience,
			IQMediaValueLD = TmpDSLDR.MediaValue,
			PositiveSentimentLD = TmpDSLDR.PositiveSentiment,
			NegativeSentimentLD = TmpDSLDR.NegativeSentiment
		FROM	LV_Temp.dbo.I_DaySummary99 AS IQDay 
					INNER JOIN #TmpDaySummaryLDResults_Final AS TmpDSLDR
						  ON		IQDay.DayDate = TmpDSLDR.LocalMediaDate
							AND IQDay.SubMediaType = TmpDSLDR.SubMediaType
							AND IQDay._SearchRequestID = TmpDSLDR._SearchRequestID    
							AND IQDay.ClientGuid = TmpDSLDR.ClientGUID 
							AND IQDay.MediaType = TmpDSLDR.MediaType
					
INSERT INTO LV_Temp.dbo.I_DaySummary99(ClientGuid,DayDate,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,IQMediaValue,SubMediaType,PositiveSentiment,
NegativeSentiment,NoOfDocsLD,NoOfHitsLD,AudienceLD,IQMediaValueLD,PositiveSentimentLD,NegativeSentimentLD) 
SELECT TmpDSLDR.ClientGUID,TmpDSLDR.LocalMediaDate,TmpDSLDR.MediaType,TmpDSLDR._SearchRequestID,0,0,0,0,TmpDSLDR.SubMediaType,0,0,TmpDSLDR.NoOfDocs,TmpDSLDR.NoOfHits,
TmpDSLDR.Audience,TmpDSLDR.MediaValue,TmpDSLDR.PositiveSentiment,TmpDSLDR.NegativeSentiment
FROM #TmpDaySummaryLDResults_Final AS TmpDSLDR
						 JOIN LV_Temp.dbo.I_DaySummary99 AS IQDay 
						 ON		IQDay.DayDate = TmpDSLDR.LocalMediaDate
							AND IQDay.SubMediaType = TmpDSLDR.SubMediaType
							AND IQDay._SearchRequestID <> TmpDSLDR._SearchRequestID    
							AND IQDay.ClientGuid = TmpDSLDR.ClientGUID 
							AND IQDay.MediaType = TmpDSLDR.MediaType */
						
					
								Merge Into dbo.IQAgent_DaySummary_NEW As Target
							Using #TmpDaySummaryLDResults_Final AS Source
							 ON		Target.DayDate = Source.LocalMediaDate
							AND Target.SubMediaType = Source.SubMediaType
							AND Target._SearchRequestID = Source._SearchRequestID    
							AND Target.ClientGuid = Source.ClientGUID 
							AND Target.MediaType = Source.MediaType
							When Matched THEN
							UPDATE 
							SET	NoOfDocsLD = ISNULL(NoOfDocsLD,0) + Source.NoOfDocs, 
								NoOfHitsLD = ISNULL(NoOfHitsLD,0) + Source.NoOfHits,
								AudienceLD = ISNULL(AudienceLD,0) + Source.Audience,
								IQMediaValueLD = ISNULL(IQMediaValueLD ,0) + Source.MediaValue,
								PositiveSentimentLD = ISNULL(PositiveSentimentLD,0) + Source.PositiveSentiment,
								NegativeSentimentLD = ISNULL(NegativeSentimentLD,0) + Source.NegativeSentiment
							When Not Matched By Target Then
							INSERT(ClientGuid,DayDate,MediaType,_SearchRequestID,NoOfDocs,NoOfHits,Audience,IQMediaValue,SubMediaType,PositiveSentiment,NegativeSentiment,
							NoOfDocsLD,NoOfHitsLD,AudienceLD,IQMediaValueLD,PositiveSentimentLD,NegativeSentimentLD) Values(ClientGUID,LocalMediaDate,MediaType,_SearchRequestID,
							0,0,0,0,SubMediaType,0,0,NoOfDocs,NoOfHits,Audience,MediaValue,PositiveSentiment,NegativeSentiment);
					
						
		
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
				@CreatedBy='usp_Refresh_IQAgent_DayHourSummary_Subprocess_2]',
				@ModifiedBy='usp_Refresh_IQAgent_DayHourSummary_Subprocess_2]',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
				Return -1
		END CATCH        

END
















GO


