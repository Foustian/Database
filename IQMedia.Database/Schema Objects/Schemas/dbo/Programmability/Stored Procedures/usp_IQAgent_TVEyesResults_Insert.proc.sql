CREATE PROCEDURE [dbo].[usp_IQAgent_TVEyesResults_Insert] 
	@SearchRequestID BIGINT,
	@QueryVersion   INT,
	@StationID VARCHAR(50),
	@StationName VARCHAR(150),
	@Market VARCHAR(150),
	@DMARank VARCHAR(5),
	@LocalDate DATETIME ,
	@UTCDate DATETIME ,
	@TimeZone VARCHAR(3),
	@PlayerUrl VARCHAR (255),
	@TranscriptUrl VARCHAR (255),	
	@CC_Highlight XML ,
	@FileLocation VARCHAR(255),
	@StationIDNum	VARCHAR(50),
	@Duration		INT,
	@IQAgentTVEyesResultsKey INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)    
	
	SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_IQAgent_TVEyesResults_Insert'
	
	BEGIN TRANSACTION;        
	BEGIN TRY 
    -- Insert statements for procedure here
  DECLARE @ClipCount INT,
		  @AgentSearchRequestIsActive TINYINT  
		SELECT @ClipCount = COUNT(*) FROM IQAgent_TVEyesResults WHERE FileLocation=@FileLocation
  SELECT @AgentSearchRequestIsActive=IsActive FROM IQAgent_SearchRequest WHERE ID=@SearchRequestID
  
  IF (@ClipCount = 0 AND @AgentSearchRequestIsActive=1)
		BEGIN 
				DECLARE @ClientGuid UNIQUEIDENTIFIER
				DECLARE @IQAgent_SummaryTrackingID BIGINT
				SELECT @ClientGuid  = ClientGuid FROM IQAgent_SearchRequest WHERE ID = @SearchRequestID
		
	
		INSERT INTO	
			IQAgent_TVEyesResults
			(
			[SearchRequestID],
			[_QueryVersion]
			,[StationID]
			  ,[StationName]
			  ,[Market]
			  ,[DMARank]
			  ,[LocalDateTime]
			  ,[UTCDateTime]
			  ,[TimeZone]
			  ,[PlayerUrl]
			  ,[TranscriptUrl]
			  ,[CC_Highlight]
			  ,[FileLocation]
			  ,[StationIDNum]
			  ,[Duration]
			  ,v5SubMediaType
					)
			VALUES
			(
				@SearchRequestID,
				@QueryVersion,
				@StationID ,
				@StationName ,
				@Market ,
				@DMARank ,
				@LocalDate ,
				@UTCDate ,
				@TimeZone,
				@PlayerUrl ,
				@TranscriptUrl ,	
				@CC_Highlight  ,
				@FileLocation,
				@StationIDNum,
				@Duration,
				'Radio'
			)
			SELECT @IQAgentTVEyesResultsKey = SCOPE_IDENTITY()

			 SET @QueryDetail ='Insert into IQAgent_TVEyesResults.'
			SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GETDATE()

			INSERT INTO IQAgent_MediaResults
			(
				Title,
				_MediaID,
				MediaDate,
				_SearchRequestID,
				MediaType,  -- Once media type reorganization is done, MediaType and Category should be removed
				Category,
				HighlightingText,
				PositiveSentiment,
				NegativeSentiment,
				IsActive,
				v5MediaType,
				v5Category
			)
			VALUES
			(
				@StationName,
				@IQAgentTVEyesResultsKey,
				@UTCDate,
				@SearchRequestID,
				'TM',
				'Radio',
				CONVERT(NVARCHAR(MAX),@CC_Highlight),
				0,
				0,
				1,
				'TM',
				'Radio'
			)
			
			SET @QueryDetail ='Insert into IQAgent_MediaResults.'
			SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
			INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
			SET @Stopwatch = GETDATE()
			
			/*INSERT INTO IQAgent_SummaryTracking
			(
				Operation,
				OperationTable,
				RecordsBeforeUpdation,
				SP,
				Detail
			)
			VALUES
			(
				'INSERT TM',
				'IQAgent_HourSummary',
				(SELECT SUM(NoOfDocs) FROM IQAgent_HourSummary WHERE MediaType ='TM'),
				'usp_IQAgent_TVEyesResults_Insert',
				CONVERT(VARCHAR(10),@IQAgentTVEyesResultsKey)
			)
			
			SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY();
			*/


/*  July 2015  Note: Updating Day and Hour Summary tables are thru a dirty table process 

			IF EXISTS(SELECT NoOfDocs FROM IQAgent_HourSummary WITH(NOLOCK) WHERE MediaType = 'TM' AND HourDateTime=DATEADD (HOUR,DATEPART(HOUR,@UTCDate), CONVERT (VARCHAR(10),@UTCDate,101)) AND ClientGuid = @ClientGuid AND _SearchRequestID = @SearchRequestID)
			BEGIN
				UPDATE 
					IQAgent_HourSummary   
				SET 
					NoOfDocs = NoOfDocs + 1    
				FROM 
					IQAgent_HourSummary 
				WHERE
					MediaType = 'TM'
					AND HourDateTime = DATEADD (HOUR,DATEPART(HOUR,@UTCDate), CONVERT (VARCHAR(10),@UTCDate,101))
					AND ClientGuid  = @ClientGuid
					AND _SearchRequestID = @SearchRequestID
					
				SET @QueryDetail ='Update IQAgent_HourSummary'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()
			END
			ELSE
			BEGIN
				INSERT INTO IQAgent_HourSummary      
			   (      
					ClientGuid,      
					HourDateTime,      
					MediaType,      
					NoOfDocs,      
					NoOfHits,      
					Audience,      
					IQMediaValue,  
					PositiveSentiment,  
					NegativeSentiment,
					SubMediaType,
					_SearchRequestID  
			   )   
			   VALUES
			   (
					@ClientGuid,
					DATEADD (HOUR,DATEPART(HOUR,@UTCDate), CONVERT (VARCHAR(10),@UTCDate,101)),
					'TM',
					1,
					0,
					0,
					0,
					0,
					0,
					'Radio',
					@SearchRequestID
			   )   
			   
			   SET @QueryDetail ='Insert IQAgent_HourSummary'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()
			END
			
			/*UPDATE 
					IQAgent_SummaryTracking
			SET
					RecordsAfterUpdation = (SELECT SUM(NoOfDocs) FROM IQAgent_DaySummary WHERE MediaType ='TM')
			WHERE
					ID = @IQAgent_SummaryTrackingID
					
					
			INSERT INTO IQAgent_SummaryTracking
			(
				Operation,
				OperationTable,
				RecordsBeforeUpdation,
				SP,
				Detail
			)
			VALUES
			(
				'INSERT TM',
				'IQAgent_DaySummary',
				(SELECT SUM(NoOfDocs) FROM IQAgent_DaySummary WHERE MediaType ='TM'),
				'usp_IQAgent_TVEyesResults_Insert',
				CONVERT(VARCHAR(10),@IQAgentTVEyesResultsKey)
			)
			
			SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY();  
			*/

			IF EXISTS(SELECT NoOfDocs FROM IQAgent_DaySummary WITH(NOLOCK) WHERE ClientGuid = @ClientGuid AND MediaType='TM' AND DayDate = CONVERT (DATE,@UTCDate) AND _SearchRequestID = @SearchRequestID)
			BEGIN
				UPDATE
					IQAgent_DaySummary
				SET
					NoOfDocs = NoOfDocs + 1
				WHERE 
					ClientGuid = @ClientGuid
					AND MediaType = 'TM'
					AND DayDate = CONVERT (DATE,@UTCDate)
					AND _SearchRequestID = @SearchRequestID
					
				SET @QueryDetail ='Update IQAgent_DaySummary'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()	
			END
			ELSE
			BEGIN
				INSERT INTO IQAgent_DaySummary
				(
					ClientGuid,      
					DayDate,      
					MediaType,      
					NoOfDocs,      
					NoOfHits,      
					Audience,      
					IQMediaValue,  
					PositiveSentiment,  
					NegativeSentiment,
					NoOfDocsLD,      
					NoOfHitsLD,      
					AudienceLD,      
					IQMediaValueLD,  
					PositiveSentimentLD,  
					NegativeSentimentLD,
					SubMediaType,
					_SearchRequestID
				)
				VALUES
				(
					@ClientGuid,
					CONVERT (DATE,@UTCDate),
					'TM',
					1,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					'Radio',
					@SearchRequestID
				)
				
				SET @QueryDetail ='Insert IQAgent_DaySummary'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()	
			END

			/*
			UPDATE 
				IQAgent_SummaryTracking
			SET
				RecordsAfterUpdation = (SELECT SUM(NoOfDocs) FROM IQAgent_DaySummary WHERE MediaType ='TM')
			WHERE
				ID = @IQAgent_SummaryTrackingID  


			INSERT INTO IQAgent_SummaryTracking
			(
				Operation,
				OperationTable,
				RecordsBeforeUpdation,
				SP,
				Detail
			)
			VALUES
			(
				'INSERT TM LD',
				'IQAgent_DaySummary',
				(SELECT SUM(NoOfDocsLD) FROM IQAgent_DaySummary WHERE MediaType ='TM'),
				'usp_IQAgent_TVEyesResults_Insert',
				CONVERT(VARCHAR(10),@IQAgentTVEyesResultsKey)
			)
			
			SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY();  
			*/

			IF EXISTS(SELECT NoOfDocsLD FROM IQAgent_DaySummary WITH(NOLOCK) WHERE ClientGuid = @ClientGuid AND MediaType='TM' AND DayDate = CONVERT (DATE,CASE WHEN dbo.fnIsDayLightSaving(@UTCDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst FROM Client WHERE ClientGuid = @ClientGuid),@UTCDate) ELSE DATEADD(HOUR,(SELECT gmt FROM Client WHERE ClientGuid = @ClientGuid),@UTCDate) END) AND _SearchRequestID = @SearchRequestID)
			BEGIN
				UPDATE
					IQAgent_DaySummary
				SET
					NoOfDocsLD = NoOfDocsLD + 1
				WHERE 
					ClientGuid = @ClientGuid
					AND MediaType = 'TM'
					AND DayDate = CONVERT (DATE,CASE WHEN dbo.fnIsDayLightSaving(@UTCDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst FROM Client WHERE ClientGuid = @ClientGuid),@UTCDate) ELSE DATEADD(HOUR,(SELECT gmt FROM Client WHERE ClientGuid = @ClientGuid),@UTCDate) END)
					AND _SearchRequestID = @SearchRequestID
					
					SET @QueryDetail ='Update Local IQAgent_DaySummary'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()	
			END
			ELSE
			BEGIN
				INSERT INTO IQAgent_DaySummary
				(
					ClientGuid,      
					DayDate,      
					MediaType,      
					NoOfDocs,      
					NoOfHits,      
					Audience,      
					IQMediaValue,  
					PositiveSentiment,  
					NegativeSentiment,
					NoOfDocsLD,      
					NoOfHitsLD,      
					AudienceLD,      
					IQMediaValueLD,  
					PositiveSentimentLD,  
					NegativeSentimentLD,
					SubMediaType,
					_SearchRequestID
				)
				VALUES
				(
					@ClientGuid,
					CONVERT (DATE,CASE WHEN dbo.fnIsDayLightSaving(@UTCDate) = 1 THEN  DATEADD(HOUR,(SELECT gmt + dst FROM Client WHERE ClientGuid = @ClientGuid),@UTCDate) ELSE DATEADD(HOUR,(SELECT gmt FROM Client WHERE ClientGuid = @ClientGuid),@UTCDate) END),
					'TM',
					0,
					0,
					0,
					0,
					0,
					0,
					1,
					0,
					0,
					0,
					0,
					0,
					'Radio',
					@SearchRequestID
				)
				
				SET @QueryDetail ='Insert Local IQAgent_DaySummary'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()
			END

			/*
			UPDATE 
				IQAgent_SummaryTracking
			SET
				RecordsAfterUpdation = (SELECT SUM(NoOfDocsLD) FROM IQAgent_DaySummary WHERE MediaType ='TM')
			WHERE
				ID = @IQAgent_SummaryTrackingID  
			*/

			-- End of Day and Hour Summary tables updates */
		END

	ELSE
		SET @IQAgentTVEyesResultsKey = 0
	COMMIT TRANSACTION;        
  END TRY        
  BEGIN CATCH        
   ROLLBACK TRANSACTION;  
   
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
				@CreatedBy='usp_IQAgent_TVEyesResults_Insert',
				@ModifiedBy='usp_IQAgent_TVEyesResults_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @IQAgentTVEyesResultsKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey OUTPUT
         
  END CATCH     
  
   SET @QueryDetail ='0'
	  SET @TimeDiff = DATEDIFF(ms, @SPStartTime, GETDATE())
	  INSERT INTO IQ_SPTimeTracking([Guid],SPName,INPUT,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,'',@QueryDetail,@TimeDiff)
     
END
