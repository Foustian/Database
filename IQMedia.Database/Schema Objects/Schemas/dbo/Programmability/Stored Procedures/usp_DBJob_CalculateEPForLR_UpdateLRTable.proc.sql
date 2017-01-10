USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_CalculateEPForLR_UpdateLRTable]    Script Date: 3/16/2016 2:06:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_CalculateEPForLR_UpdateLRTable]  (      
 @MaxIQSeqIDOfADS BIGINT)
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
BEGIN TRY        
	BEGIN TRANSACTION

	/*
		INSERT INTO IQ_DBJob_ADSAudit (IQ_CC_KEY, MediaType)
		   SELECT ads.IQ_CC_KEY, 'TV' FROM #IQ_ADS_Results ads 
		   WHERE NOT EXISTS( SELECT IQ_CC_KEY FROM IQAgent_QHTVResults itv WITH (NOLOCK)
		                                    WHERE IQ_CC_KEY = ads.IQ_CC_Key)
	*/

		DELETE #IQ_ADS_Results
		FROM #IQ_ADS_Results ads  WHERE NOT EXISTS( SELECT IQ_CC_KEY FROM IQAgent_LRResults  WITH (NOLOCK)
		                                    WHERE IQ_CC_KEY = ads.IQ_CC_Key)

		IF (SELECT COUNT(1) FROM #IQ_ADS_Results) = 0
		    BEGIN
				IF EXISTS (SELECT ID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE MediaType='LADS')
					UPDATE IQ_DBJobLastIQSeqID SET LastIQSeqID = @MaxIQSeqIDOfADS, ModifiedDate = GETDATE() WHERE MediaType='LADS'
				ELSE
					INSERT INTO IQ_DBJobLastIQSeqID (MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive) 
					VALUES('LADS',@MaxIQSeqIDOfADS,GETDATE(),GETDATE(),1)
				COMMIT TRANSACTION
				RETURN 2
			END

		UPDATE IQAgent_LRResults
			SET	  Paid =  TotCount,
				  Earned = NumOfHits - TotCount,
			      ModifiedDate = GETDATE()
			FROM IQAgent_LRResults lr 
				JOIN (SELECT ilr.iq_cc_key AS IQ_CC_key,  ilr.StartingPoint AS StartingPoint, ilr._SearchLogoID AS _SearchLogoID,  
				ISNULL(COUNT(DISTINCT(Tblc.HitList.value('.', 'SMALLINT') )),0) AS TotCount FROM IQAgent_LRResults ilr
			            CROSS APPLY Hits.nodes('/LROffsets/Hits/Offset') AS Tblc(HitList)
			             JOIN  #IQ_ADS_Results ads  
						 ON ads.IQ_CC_KEY = ilr.IQ_CC_KEY  
						 AND Tblc.HitList.value('.', 'SMALLINT') BETWEEN StartOffset AND EndOffset
						 AND Tblc.HitList.value('.', 'SMALLINT') > 0 AND Tblc.HitList.value('.', 'SMALLINT') < 900 
						 AND ilr.StartingPoint=1 
						 GROUP BY  ilr.iq_cc_key, ilr.StartingPoint, ilr._SearchLogoID) AS temp
				ON  temp.IQ_CC_Key = lr.IQ_CC_key
				AND temp.StartingPoint = lr.StartingPoint
				AND temp._SearchLogoID = lr._SearchLogoID
					
		UPDATE IQAgent_LRResults
			SET	  Paid =  TotCount,
			      Earned = NumOfHits - TotCount,
			      ModifiedDate = GETDATE()
			FROM IQAgent_LRResults lr 
				JOIN (SELECT ilr.iq_cc_key AS IQ_CC_key,  ilr.StartingPoint AS StartingPoint, ilr._SearchLogoID AS _SearchLogoID,   
				ISNULL(COUNT(DISTINCT(Tblc.HitList.value('.', 'SMALLINT') )),0) AS TotCount FROM IQAgent_LRResults ilr
			            CROSS APPLY Hits.nodes('/LROffsets/Hits/Offset') AS Tblc(HitList)
			             JOIN  #IQ_ADS_Results ads  
						 ON ads.IQ_CC_KEY = ilr.IQ_CC_KEY  
						 AND Tblc.HitList.value('.', 'SMALLINT') BETWEEN StartOffset AND EndOffset
						 AND Tblc.HitList.value('.', 'SMALLINT') > 900 AND Tblc.HitList.value('.', 'SMALLINT') < 1800 
						 AND ilr.StartingPoint=2 
						 GROUP BY  ilr.iq_cc_key, ilr.StartingPoint, ilr._SearchLogoID) temp
				ON  temp.IQ_CC_Key = lr.IQ_CC_key
				AND temp.StartingPoint = lr.StartingPoint
				AND temp._SearchLogoID = lr._SearchLogoID

		UPDATE IQAgent_LRResults
			SET	  Paid =  TotCount,
			      Earned = NumOfHits - TotCount,
			      ModifiedDate = GETDATE()
			FROM IQAgent_LRResults lr 
				JOIN (SELECT ilr.iq_cc_key AS IQ_CC_key,  ilr.StartingPoint AS StartingPoint, ilr._SearchLogoID AS _SearchLogoID, 
				ISNULL(COUNT(DISTINCT(Tblc.HitList.value('.', 'SMALLINT') )),0) AS TotCount FROM IQAgent_LRResults ilr
			            CROSS APPLY Hits.nodes('/LROffsets/Hits/Offset') AS Tblc(HitList)
			             JOIN  #IQ_ADS_Results ads  
						 ON ads.IQ_CC_KEY = ilr.IQ_CC_KEY  
						 AND Tblc.HitList.value('.', 'SMALLINT') BETWEEN StartOffset AND EndOffset
						 AND Tblc.HitList.value('.', 'SMALLINT') > 1800 AND Tblc.HitList.value('.', 'SMALLINT') < 2700 
						 AND ilr.StartingPoint=3 
						 GROUP BY  ilr.iq_cc_key, ilr.StartingPoint, ilr._SearchLogoID) temp
				ON  temp.IQ_CC_Key = lr.IQ_CC_key
				AND temp.StartingPoint = lr.StartingPoint
				AND temp._SearchLogoID = lr._SearchLogoID

		UPDATE IQAgent_LRResults
			SET	  Paid =  TotCount,
			      Earned = NumOfHits - TotCount,
			      ModifiedDate = GETDATE()
			FROM IQAgent_LRResults lr 
				JOIN (SELECT ilr.iq_cc_key AS IQ_CC_key,  ilr.StartingPoint AS StartingPoint, ilr._SearchLogoID AS _SearchLogoID,  
				ISNULL(COUNT(DISTINCT(Tblc.HitList.value('.', 'SMALLINT') )),0) AS TotCount FROM IQAgent_LRResults ilr
			            CROSS APPLY Hits.nodes('/LROffsets/Hits/Offset') AS Tblc(HitList)
			             JOIN  #IQ_ADS_Results ads  
						 ON ads.IQ_CC_KEY = ilr.IQ_CC_KEY  
						 AND Tblc.HitList.value('.', 'SMALLINT') BETWEEN StartOffset AND EndOffset
						 AND Tblc.HitList.value('.', 'SMALLINT') > 2700 AND Tblc.HitList.value('.', 'SMALLINT') < 3600 
						 AND ilr.StartingPoint=4
						 GROUP BY  ilr.iq_cc_key, ilr.StartingPoint, ilr._SearchLogoID) temp
				ON  temp.IQ_CC_Key = lr.IQ_CC_key
				AND temp.StartingPoint = lr.StartingPoint
				AND temp._SearchLogoID = lr._SearchLogoID
	
		IF EXISTS (SELECT ID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE MediaType='LADS')
				UPDATE IQ_DBJobLastIQSeqID SET LastIQSeqID = @MaxIQSeqIDOfADS, ModifiedDate = GETDATE() WHERE MediaType='LADS'
			ELSE
				INSERT INTO IQ_DBJobLastIQSeqID (MediaType,LastIQSeqID,CreatedDate,ModifiedDate,IsActive) 
				VALUES('LADS',@MaxIQSeqIDOfADS,GETDATE(),GETDATE(),1)

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
				@CreatedBy='usp_DBJob_CalculateEPForLR_UpdateLRTable',
				@ModifiedBy='usp_DBJob_CalculateEPForLR_UpdateLRTable',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END
GO


