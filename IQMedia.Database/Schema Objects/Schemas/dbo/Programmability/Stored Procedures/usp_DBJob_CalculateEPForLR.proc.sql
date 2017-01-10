USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_CalculateEPForLR]    Script Date: 3/16/2016 2:05:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_CalculateEPForLR]  (      
@MaxIQSeqIDOfADS INT, @InsertLRStatus CHAR(30) OUTPUT)
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY        
   
   CREATE TABLE #IQ_ADS_Results 
	(
		[IQ_CC_KEY] VARCHAR(128),
		[StartOffset] SMALLINT,
		[EndOffset] SMALLINT
	)
    DECLARE @LastIQSeqIDOfADS BIGINT = 0
	DECLARE @Status SMALLINT
	 
	/*
	    DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff Float    ,@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
    SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_DBJob_EarnedPaidSummary' */
   
   IF @MaxIQSeqIDOfADS = 0
	  SELECT @MaxIQSeqIDOfADS = MAX(ID) FROM IQ_ADS_Results WITH (NOLOCK)

   SELECT @LastIQSeqIDOfADS =  LastIQSeqID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE  MediaType='LADS'

   INSERT INTO #IQ_ADS_Results(
	    IQ_CC_KEY,
		StartOffset,
		EndOffset)
	SELECT DISTINCT ads.IQ_CC_KEY,
	       CONVERT(SMALLINT, CEILING(LEFT(Tbla.HitsList.value('./Begin[1]', 'varchar(10)'),LEN(Tbla.HitsList.value('./Begin[1]',	'varchar(10)'))-1)) ),
		   CONVERT(SMALLINT, CEILING(LEFT(Tbla.HitsList.value('./End[1]', 'varchar(10)'),LEN(Tbla.HitsList.value('./End[1]', 'varchar(10)'))-1)))
	FROM IQ_ADS_Results ads  
		   CROSS APPLY Hits.nodes('/ADSOffsets/Hits') AS Tbla(HitsList) 
	WHERE ads.ID > @LastIQSeqIDOfADS AND ads.ID < = @MaxIQSeqIDOfADS
	       AND ads.Hit_Count > 1

	IF (SELECT COUNT(1) FROM #IQ_ADS_Results) > 0
	   BEGIN
			CREATE INDEX idx1 on #IQ_ADS_Results(IQ_CC_KEY)
			EXEC @Status = usp_DBJob_CalculateEPForLR_UpdateLRTable @MaxIQSeqIDOfADS WITH RECOMPILE
			IF @Status = 0
			   SET @InsertLRStatus = 'Calcuate E/P For LR Succeeded'
			ELSE
			   IF @Status = 2
			      SET @InsertLRStatus = 'Calcuate E/P For LR Idle'
			   ELSE
			      SET @InsertLRStatus = 'Calcuate E/P For LR Fail'
	   END
	ELSE
	   SET @InsertLRStatus = 'Calcuate E/P For LR Idle'

 /* 
SET @QueryDetail ='Preparing MediaResults table'
SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
SET @Stopwatch = GETDATE()
*/
 
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
				@CreatedBy='usp_DBJob_CalculateEPForLR',
				@ModifiedBy='usp_DBJob_CalculateEPForLR',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END

























GO


