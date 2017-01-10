USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_CalculateEPForTV]    Script Date: 10/20/2016 2:58:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_CalculateEPForTV]  (      
@MinIQSeqIDOfADS BIGINT,@MaxIQSeqIDOfADS BIGINT,  @LastIQSeqIDOfTV BIGINT, @InsertTVStatus CHAR(30) OUTPUT)
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY        
   
   CREATE TABLE #IQ_ADS_Results 
	(
		[IQ_CC_KEY] VARCHAR(128),
		[StartOffset] INT,
		[EndOffset] INT
	)

	CREATE TABLE #IQAgent_TVResults 
	(
	    [IQAgent_TVResults_ID] BIGINT,
		[SearchRequestID] BIGINT,
		[IQ_CC_KEY] VARCHAR(128),
		[NumberOfHits] INT,
		[Paid] INT
	)

	DECLARE @Status SMALLINT
	 
	/*
	    DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff Float    ,@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
    SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_DBJob_EarnedPaidSummary' */
   
   IF @MaxIQSeqIDOfADS = 0
     BEGIN
	  SELECT @MaxIQSeqIDOfADS = MAX(ID) FROM IQ_ADS_Results WITH (NOLOCK)
	  -- SET @MaxIQSeqIDOfADS = @MaxIQSeqIDOfADS - 100
	 END

   -- IF  @LastIQSeqIDOfQHTV IS NULL
    --   SELECT @LastIQSeqIDOfQHTV =  LastIQSeqID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE  MediaType='TADS'

   IF @MinIQSeqIDOfADS = 0

		   INSERT INTO #IQ_ADS_Results(
				IQ_CC_KEY,
				StartOffset,
				EndOffset)
			SELECT DISTINCT ads.IQ_CC_KEY,
				   CONVERT(SMALLINT, CEILING(LEFT(Tbla.HitsList.value('./Begin[1]', 'varchar(10)'),LEN(Tbla.HitsList.value('./Begin[1]',	'varchar(10)'))-1)) ),
				   CONVERT(SMALLINT, CEILING(LEFT(Tbla.HitsList.value('./End[1]', 'varchar(10)'),LEN(Tbla.HitsList.value('./End[1]', 'varchar(10)'))-1)))
			FROM IQ_ADS_Results ads  
				   CROSS APPLY Hits.nodes('/ADSOffsets/Hits') AS Tbla(HitsList) 
			WHERE ads.ID > @MinIQSeqIDOfADS AND ads.ID < = @MaxIQSeqIDOfADS
				   AND ads.Hit_Count > 1
				  
	ELSE
	   BEGIN
		    SELECT @MinIQSeqIDOfADS = MIN(ID) FROM IQ_ADS_Results ads WHERE ads.FlagForTV IS NULL  AND ads.Hit_Count > 1
	       INSERT INTO #IQ_ADS_Results(
				IQ_CC_KEY,
				StartOffset,
				EndOffset)
			SELECT DISTINCT ads.IQ_CC_KEY,
				   CONVERT(SMALLINT, CEILING(LEFT(Tbla.HitsList.value('./Begin[1]', 'varchar(10)'),LEN(Tbla.HitsList.value('./Begin[1]',	'varchar(10)'))-1)) ),
				   CONVERT(SMALLINT, CEILING(LEFT(Tbla.HitsList.value('./End[1]', 'varchar(10)'),LEN(Tbla.HitsList.value('./End[1]', 'varchar(10)'))-1)))
			FROM IQ_ADS_Results ads  
				   CROSS APPLY Hits.nodes('/ADSOffsets/Hits') AS Tbla(HitsList) 
			WHERE ads.ID >= @MinIQSeqIDOfADS AND ads.ID < = @MaxIQSeqIDOfADS
				   AND ads.Hit_Count > 1
				   AND ads.FlagForTV IS NULL
	   END

    INSERT INTO #IQAgent_TVResults(
	    IQAgent_TVResults_ID,
		SearchRequestID,
		IQ_CC_KEY,
		NumberOfHits
		)
	SELECT tv.ID,
	       tv.SearchRequestID,
		   tv.IQ_CC_KEY,
		   Number_Hits
	FROM IQAgent_TVResults tv WITH (NOLOCK)
	     JOIN #IQ_ADS_Results ads ON ads.iq_cc_key = tv.iq_cc_key
	WHERE  
		   (tv.Paid IS  NULL or tv.Earned IS  NULL)
		   AND CC_Highlight IS NOT NULL AND Number_Hits > 0
		 --  AND tv.IsActive = 1

	IF (SELECT COUNT(1) FROM #IQAgent_TVResults) > 0
	   BEGIN
			CREATE INDEX idx1 on #IQ_ADS_Results(IQ_CC_KEY)
			CREATE INDEX idx1 on #IQAgent_TVResults(IQAgent_TVResults_ID)
			EXEC @Status = usp_DBJob_CalculateEPForTV_UpdateTVTable WITH RECOMPILE
			IF @Status = 0
			   SET @InsertTVStatus = 'Calcuate E/P For TV Succeeded'
			ELSE
				IF @Status = 2
				   SET @InsertTVStatus = 'Calcuate E/P For TV Idle'
				ELSE
				   SET @InsertTVStatus = 'Calcuate E/P For TV Failed'
	   END
	ELSE
	   SET @InsertTVStatus = 'Calcuate E/P For TV Idle'

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
				@CreatedBy='usp_DBJob_CalculateEPForTV',
				@ModifiedBy='usp_DBJob_CalculateEPForTV',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH      
  

    
END

























GO


