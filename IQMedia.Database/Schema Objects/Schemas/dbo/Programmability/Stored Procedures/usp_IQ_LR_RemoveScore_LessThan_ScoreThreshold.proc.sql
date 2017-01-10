USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_IQ_LR_RemoveScore_LessThan_ScoreThreshold]    Script Date: 3/16/2016 2:11:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_IQ_LR_RemoveScore_LessThan_ScoreThreshold] 
	@SearchImagesID BIGINT,
	@ResultsSeqID BIGINT,
	@NumberOfRecordProcessed INT,
	@NumberOfRecordAffected INT OUTPUT,
	@LastResultsSeqID INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

BEGIN TRY 
	
	DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)    
	
	SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_IQ_LR_RemoveScore_LessThan_ScoreThreshold'
	
	DECLARE @Hits XML
	DECLARE @ID BIGINT
	DECLARE @ScoreThreshold SMALLINT, @IsActive SMALLINT
	DECLARE @RowCount INT = 0
	DECLARE @NumberOfHits INT
	DECLARE @HitsCol TABLE (Offset INT, Score DECIMAL(10,2))
	
	SELECT @ScoreThreshold = score_threshold FROM IQ_LR_Search_Images WHERE ID = @SearchImagesID

	DECLARE t_cursor CURSOR FOR SELECT TOP (@NumberOfRecordProcessed) ID FROM IQ_LR_Results WITH (NOLOCK) WHERE _SearchLogoID = @SearchImagesID AND ID > @ResultsSeqID

	OPEN t_cursor
	FETCH NEXT FROM t_cursor INTO @ID
       WHILE @@FETCH_STATUS = 0
	     BEGIN
	      INSERT INTO @HitsCol (Offset, Score )
	      SELECT   Tbl.SearchRequestList.value('./Offset[1]', 'varchar(20)'), Tbl.SearchRequestList.value('./Score[1]', 'varchar(20)')
               FROM IQ_LR_Results WITH (NOLOCK)
               CROSS APPLY Hits.nodes('/LROffsets/Hits') AS Tbl(SearchRequestList) WHERE ID = @ID
		  DELETE @HitsCol WHERE Score < @ScoreThreshold
		  SELECT @NumberOfHits = COUNT(1) from @HitsCol

		  IF (@NumberOfHits = 0)
		     SELECT @Hits = CONVERT (XML,N'<LROffsets><Hits> </Hits> </LROffsets>'), @IsActive = 0
		  ELSE
		     BEGIN
		        SELECT @Hits = (SELECT FORMAT(Offset,'0000') as 'Offset',
						 Score as 'Score'
						 FROM @HitsCol FOR XML PATH('Hits'), ROOT('LROffsets'))
			    SET @IsActive = 1
			 END

		  UPDATE IQ_LR_RESULTS
		    SET Hits = @Hits, Hit_Count = @NumberOfHits, ModifiedDate = GETDATE(), IsActive = @IsActive
			WHERE ID = @ID
		  SET @ROWCOUNT = @ROWCOUNT + 1
	      FETCH NEXT FROM t_cursor INTO @ID
         END

  
    Close t_cursor
    Deallocate t_cursor

	SET @QueryDetail ='usp_IQ_LR_RemoveScore_LessThan_ScoreThreshold'
	SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
	INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
	-- SET @Stopwatch = GETDATE()
	SET @NumberOfRecordAffected = @ROWCOUNT
	SET @LastResultsSeqID = @ID
	RETURN 0
END TRY
BEGIN CATCH        
   
   -- ROLLBACK TRANSACTION;  
   
   DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME
			--	@IsActive	BIT
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_IQ_LR_RemoveScore_LessThan_ScoreThreshold',
				@ModifiedBy='usp_IQ_LR_RemoveScore_LessThan_ScoreThreshold',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE()
			--	@IsActive=1
				
        EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		Close t_cursor
        Deallocate t_cursor
        SET @NumberOfRecordAffected = 0
		SET @LastResultsSeqID = @ResultsSeqID
		RETURN -1
END CATCH     
      
END

GO


