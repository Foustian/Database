USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_Wrapper_EarnedPaidSummary]    Script Date: 10/20/2016 3:20:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DBJob_Wrapper_EarnedPaidSummary]  (      
@NumberOfRecord INT, @LastIQSeqIDOfADS BIGINT, @MaxIQSeqIDOfADS BIGINT,  @InsertLRStatus CHAR(30) OUTPUT,  @InsertTVStatus CHAR(30) OUTPUT, @DeleteStatus CHAR(35) OUTPUT)
AS        
BEGIN         
 SET NOCOUNT ON;        
 SET XACT_ABORT ON;
  
 BEGIN TRY   
  
     CREATE TABLE #IQ_ADS_Results 
	(
		[IQ_CC_KEY] VARCHAR(128)
	
	)

	CREATE TABLE #Tmp_DirtyTable(
	[ID] [bigint]  NOT NULL,
	[_IQAgent_MediaID] [bigint] NOT NULL,
	[MediaType] [varchar](2) NULL,
	[Flag] [char](1) NULL,
	[GMTDatetime] [datetime] NULL,
	[SearchRequestID] [bigint] NULL,
	[RL_Market] [varchar](150) NULL,
	[Rl_Station] [varchar](150) NULL,
	[Number_Hits] [int] NULL,
	[Earned] [int] NULL,
	[Paid] [int] NULL,
	[IsActive] [bit] NULL
	)
	 
	 DECLARE @Status SMALLINT

	 IF @MaxIQSeqIDOfADS = 0
		SELECT @MaxIQSeqIDOfADS = MAX(ID) FROM IQ_ADS_Results WITH (NOLOCK)

	-- IF @LastIQSeqIDOfADS IS NULL
	   -- SELECT @LastIQSeqIDOfADS =  LastIQSeqID FROM IQ_DBJobLastIQSeqID WITH (NOLOCK) WHERE  MediaType='SADS'

    IF @LastIQSeqIDOfADS = 0
			INSERT INTO #IQ_ADS_Results
			(
				IQ_CC_KEY
			)
			SELECT ads.IQ_CC_KEY
	       			FROM IQ_ADS_Results ads  
			WHERE ads.ID > @LastIQSeqIDOfADS AND ads.ID < = @MaxIQSeqIDOfADS
				   AND ads.Hit_Count > 1
				   
	ELSE
			INSERT INTO #IQ_ADS_Results
			(
				IQ_CC_KEY
			)
			SELECT ads.IQ_CC_KEY
	       			FROM IQ_ADS_Results ads  
			WHERE ads.ID > @LastIQSeqIDOfADS AND ads.ID < = @MaxIQSeqIDOfADS
				   AND ads.Hit_Count > 1
				   AND ads.FlagForEP IS NULL

-- Add Earned/Paid to Summary Table
	IF (SELECT COUNT(1) FROM #IQ_ADS_Results) > 0
	   BEGIN
			CREATE INDEX idx1 on #IQ_ADS_Results(IQ_CC_KEY)
			EXEC @Status = usp_DBJob_AddEarnedPaidSummary @NumberOfRecord, @MaxIQSeqIDOfADS,
			               @InsertLRStatus = @InsertLRStatus OUTPUT,  
						   @InsertTVStatus = @InsertTVStatus OUTPUT WITH RECOMPILE
	   END
	 ELSE
	   BEGIN
		SET @InsertLRStatus ='INSERT TV/LR IDLE'
		SET @InsertTVStatus ='INSERT TV/LR IDLE'
	   END


	
-- Subtract Earned/Paid From Summary  Table
-- There is an update trigger on the IQAgent_QHTVResults and IQAgent_LRResults to write to the IQAgent_QHTVLRResults_DirtyTable table if the IsActive flag is changed    from 1 to 0 (delete).

   INSERT INTO #Tmp_DirtyTable (
		[ID],
		[_IQAgent_MediaID],
		[MediaType],
		[Flag],
		[GMTDatetime],
		[SearchRequestID],
		[RL_Market],
		[Rl_Station],
		[Number_Hits],
		[Earned],
		[Paid],
		[IsActive]
	  )
   SELECT 
        [ID],
		[_IQAgent_MediaID],
		[MediaType],
		[Flag],
		[GMTDatetime],
		[SearchRequestID],
		[RL_Market],
		[Rl_Station],
		[Number_Hits],
		[Earned],
		[Paid],
		[IsActive]
   FROM IQAgent_TableResults_DirtyTable WITH (NOLOCK)
        WHERE Flag='D'

   IF (SELECT COUNT(1) FROM #Tmp_DirtyTable) > 0
      BEGIN
		CREATE INDEX idx1 ON #Tmp_DirtyTable(MediaType,_IQAgent_MediaID)
		CREATE INDEX idx2 ON #Tmp_DirtyTable(ID)
		EXEC @Status = usp_DBJob_DeleteEarnedPaidSummary @NumberOfRecord, @MaxIQSeqIDOfADS,
			               @DeleteStatus = @DeleteStatus OUTPUT  WITH RECOMPILE
	  END	
   ELSE
     SET @DeleteStatus='DELETE TV/LR IDLE'

     

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
				@CreatedBy='usp_DBJob_Wrapper_EarnedPaidSummary',
				@ModifiedBy='usp_DBJob_Wrapper_EarnedPaidSummary',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Return 1
  END CATCH     
  END     
GO


