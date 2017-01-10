USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_CalculateEPForTV_UpdateTVTable]    Script Date: 10/20/2016 2:58:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_CalculateEPForTV_UpdateTVTable]   

AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
BEGIN TRY        
	
	DECLARE @ADSCreateddate datetime

	UPDATE #IQAgent_TVResults
		SET	  Paid = (SELECT ISNULL(COUNT(DISTINCT(Tblc.HitList.value('.', 'INT') )),0) FROM IQAgent_TVResults itv WITH (NOLOCK) 
			            CROSS APPLY CC_Highlight.nodes('/HighlightedCCOutput/CC/ClosedCaption/Offset') AS Tblc(HitList)
			             JOIN  #IQ_ADS_Results ads  
						 ON ads.IQ_CC_KEY = itv.iq_cc_key 
						-- AND itv.iq_cc_key = tv.IQ_CC_KEY
						-- AND itv.SearchRequestID = tv.SearchRequestID
						 AND Tblc.HitList.value('.', 'INT') BETWEEN StartOffset AND EndOffset WHERE itv.ID = tv.IQAgent_TVResults_ID)
		FROM #IQAgent_TVResults tv	WITH (NOLOCK)
		--   JOIN #IQ_ADS_Results outer_ads 
		 --     ON outer_ads.IQ_CC_key = tv.IQ_CC_key

    SELECT @ADSCreateddate = DATEADD(Day, -15, GETDATE())

	BEGIN TRANSACTION

	    UPDATE IQAgent_TVResults
		SET Paid = tmp.Paid,
		    Earned = Number_Hits - tmp.Paid
		  --  ModifiedDate = GETDATE()
		FROM IQAgent_TVResults tv
		   JOIN #IQAgent_TVResults tmp ON tmp.IQAgent_TVResults_ID = tv.ID
		         AND tv.Number_Hits = tmp.NumberOfHits

		UPDATE IQ_ADS_Results
		    SET FlagForTV = 'Y'
		FROM IQ_ADS_Results ads
		    JOIN #IQ_ADS_Results tmp ON tmp.iq_cc_key = ads.iq_cc_key
		WHERE Createddate <= @ADSCreateddate
        
/*
		IF EXISTS (SELECT ID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE MediaType='TADS')
				UPDATE IQ_DBJobLastIQSeqID SET LastIQSeqID = @LastIQSeqIDOfQHTV, ModifiedDate = GETDATE() WHERE MediaType='TADS'
			ELSE
				INSERT INTO IQ_DBJobLastIQSeqID (MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive) 
				VALUES('TADS',@LastIQSeqIDOfQHTV,GETDATE(),GETDATE(),1)
*/
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
				@CreatedBy='usp_DBJob_CalculateEPForTV_UpdateTVTable',
				@ModifiedBy='usp_DBJob_CalculateEPForTV_UpdateTVTable',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END
GO


