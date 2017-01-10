CREATE PROCEDURE [dbo].[usp_pshell_ArchiveBLPM_Insert] 
	@BLID VARCHAR (50),
	@Headline VARCHAR(255),
	@PubDate DATETIME ,
	@Author VARCHAR (50) ,
	@Pub_State VARCHAR (50),
	@Pub_Name VARCHAR (250),
	@Pub_freq VARCHAR (10),
	@Pub_ed_office VARCHAR (250),
	@DMA INT ,
	@Text VARCHAR(MAX),
	@Keywords VARCHAR(MAX),
	@BLPMxml XML ,
	@FileLocation VARCHAR(250),
	@RPID INT ,
	@CategoryGUID UNIQUEIDENTIFIER,
	@ClientGUID UNIQUEIDENTIFIER ,
	@CustomerGUID UNIQUEIDENTIFIER ,
	@Circulation INT,
	@SearchRequestID BIGINT,
	@ArchiveBLPMKey INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	 SET NOCOUNT OFF;        
	SET XACT_ABORT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY	

    -- Insert statements for procedure here
		DECLARE @ClipCount INT
		SELECT @ClipCount = COUNT(*) FROM ArchiveBLPM WHERE BLID=@BLID AND PubDate=@PubDate
		DECLARE @IQAgent_BLPMResultsKey BIGINT
		DECLARE @IQAgent_SummaryTrackingID BIGINT
		DECLARE @GMT INT, @DST INT, @LocalDayDate DATE
		SELECT  @GMT = gmt , @DST = dst FROM Client WHERE ClientGuid = @ClientGUID
		SET @LocalDayDate = CONVERT (DATE,CASE WHEN dbo.fnIsDayLightSaving(@PubDate) = 1 THEN  DATEADD(HOUR,(@GMT + @DST),@PubDate) ELSE DATEADD(HOUR,@GMT,@PubDate) END)
		
		DECLARE @StopWatch DATETIME,@SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
		SET @SPStartTime=GETDATE()
		SET @Stopwatch=GETDATE()
		SET @SPTrackingID = NEWID()
		SET @SPName ='usp_pshell_ArchiveBLPM_Insert'
		
		IF @ClipCount = 0 
		BEGIN 
   
			INSERT INTO	
				ArchiveBLPM
				(
				BLID ,
				Headline,
				PubDate ,
				Author ,
				Pub_State,
				Pub_Name,
				Pub_freq,
				Pub_ed_office,
				DMA,
				TEXT,
				Keywords,
				BLPMxml,
				FileLocation,
				RPID,
				Rating,
				CreatedDate,
				ModifiedDate,
				IsActive,
				CategoryGUID,
				ClientGUID,
				CustomerGUID,
				Circulation,
				v5SubMediaType
				)
				VALUES
				(
					@BLID,
					@Headline,
					@PubDate,
					@Author  ,
					@Pub_State,
					@Pub_Name ,
					@Pub_freq ,
					@Pub_ed_office  ,
					@DMA  ,
					@Text ,
					@Keywords ,
					@BLPMxml ,
					@FileLocation ,
					@RPID ,
					1,
					SYSDATETIME(),
					SYSDATETIME(),
					1,				
					@CategoryGUID,
					@ClientGUID,
					@CustomerGUID,
					@Circulation,
					'PM'
				)
				SELECT @ArchiveBLPMKey = SCOPE_IDENTITY()
				
				SET @QueryDetail ='Insert into ArchiveBLPM'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()
			
			
				INSERT INTO IQArchive_Media
				(
					_ArchiveMediaID,
					MediaType,
					Title,
					SubMediaType,
					HighlightingText,
					MediaDate,
					CategoryGUID,
					ClientGUID,
					CustomerGUID,
					IsActive,
					CreatedDate,
					Content,
					v5MediaType,
					v5SubMediaType
				)
				VALUES
				(
					@ArchiveBLPMKey,
					'PM',
					@Headline,
					'PM',
					CONVERT(NVARCHAR(MAX),@BLPMxml),
					@PubDate,
					@CategoryGUID,
					@ClientGUID,
					@CustomerGUID,
					1,
					GETDATE(),
					@Text,
					'PR',
					'PM'
				)
				
				SET @QueryDetail ='Insert into IQArchive_Media'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()

				INSERT INTO IQAgent_BLPMResults
				(
					_ArchiveBLPMID,
					SearchRequestID,
					BLID,
					Headline,
					PubDate,
					Author,
					Pub_State,
					Pub_Name,
					Pub_freq,
					Pub_ed_office,
					DMA,
					[TEXT],
					BLPMxml,
					FileLocation,
					Circulation,
					RPID,
					CreatedDate,
					ModifiedDate,
					IsActive,
					v5SubMediaType
				)

				VALUES
				(
					@ArchiveBLPMKey,
					@SearchRequestID,
					@BLID,
					@Headline,
					@PubDate,
					@Author,
					@Pub_State,
					@Pub_Name,
					@Pub_freq,
					@Pub_ed_office,
					@DMA,
					@Text,
					@BLPMxml,
					@FileLocation,
					@Circulation,
					@RPID,
					GETDATE(),
					GETDATE(),
					1,
					'PM'
				)
				
				SELECT @IQAgent_BLPMResultsKey = SCOPE_IDENTITY()
				
				SET @QueryDetail ='Insert into IQAgent_BLPMResults'
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
					@Headline,
					@IQAgent_BLPMResultsKey,
					@PubDate,
					@SearchRequestID,
					'PM',
					'PM',
					CONVERT(NVARCHAR(MAX),@BLPMxml),
					NULL,
					NULL,
					1,
					'PR',
					'PM'
				)
				
				SET @QueryDetail ='Insert into IQAgent_MediaResults'
				SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
				INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
				SET @Stopwatch = GETDATE()
				/*
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
					'INSERT PM',
					'IQAgent_HourSummary',
					(SELECT SUM(NoOfDocs) FROM IQAgent_HourSummary WHERE MediaType ='PM'),
					'usp_ArchiveBLPM_Insert',
					CONVERT(VARCHAR(10),@IQAgent_BLPMResultsKey)
				)
				
				SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY();
				*/


/*  July 2015  Note: Updating Day and Hour Summary tables are thru a dirty table process 

				IF EXISTS(SELECT NoOfDocs FROM IQAgent_HourSummary WHERE MediaType = 'PM' AND HourDateTime=DATEADD (HOUR,DATEPART(HOUR,@PubDate), CONVERT (VARCHAR(10),@PubDate,101)) AND ClientGuid = @ClientGUID AND _SearchRequestID = @SearchRequestID)
				BEGIN
					UPDATE 
						IQAgent_HourSummary   
					SET 
						NoOfDocs = NoOfDocs + 1,
						Audience = Audience + @Circulation
					FROM 
						IQAgent_HourSummary 
					WHERE
						MediaType = 'PM'
						AND HourDateTime = DATEADD (HOUR,DATEPART(HOUR,@PubDate), CONVERT (VARCHAR(10),@PubDate,101))
						AND ClientGuid  = @ClientGUID
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
						@ClientGUID,
						DATEADD (HOUR,DATEPART(HOUR,@PubDate), CONVERT (VARCHAR(10),@PubDate,101)),
						'PM',
						1,
						0,
						@Circulation,
						0,
						NULL,
						NULL,
						'PM',
						@SearchRequestID
				   ) 
				   
					SET @QueryDetail ='Insert IQAgent_HourSummary'
					SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
					INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
					SET @Stopwatch = GETDATE()
				     
				END
				/*			
				UPDATE 
						IQAgent_SummaryTracking
				SET
						RecordsAfterUpdation = (SELECT SUM(NoOfDocs) FROM IQAgent_DaySummary WHERE MediaType ='PM')
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
					'INSERT PM',
					'IQAgent_DaySummary',
					(SELECT SUM(NoOfDocs) FROM IQAgent_DaySummary WHERE MediaType ='PM'),
					'usp_ArchiveBLPM_Insert',
					CONVERT(VARCHAR(10),@IQAgent_BLPMResultsKey)
				)
			
				SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY();  
				*/
				
				IF EXISTS(SELECT NoOfDocs FROM IQAgent_DaySummary WHERE ClientGuid = @ClientGUID AND MediaType='PM' AND DayDate = CONVERT (DATE,@PubDate) AND _SearchRequestID = @SearchRequestID)
				BEGIN
					UPDATE
						IQAgent_DaySummary
					SET
						NoOfDocs = NoOfDocs + 1,
						Audience = Audience + @Circulation
					
					WHERE 
						ClientGuid = @ClientGUID
						AND MediaType = 'PM'
						AND DayDate = CONVERT (DATE,@PubDate)
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
						@ClientGUID,
						CONVERT (DATE,@PubDate),
						'PM',
						1,
						0,
						@Circulation,
						0,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						NULL,
						'PM',
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
					RecordsAfterUpdation = (SELECT SUM(NoOfDocs) FROM IQAgent_DaySummary WHERE MediaType ='PM')
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
					'INSERT PM LD',
					'IQAgent_DaySummary',
					(SELECT SUM(NoOfDocsLD) FROM IQAgent_DaySummary WHERE MediaType ='PM'),
					'usp_ArchiveBLPM_Insert',
					CONVERT(VARCHAR(10),@IQAgent_BLPMResultsKey)
				)
			
				SET @IQAgent_SummaryTrackingID = SCOPE_IDENTITY(); 
				*/
				
				IF EXISTS(SELECT IQAgent_DaySummary.ID FROM IQAgent_DaySummary WHERE ClientGuid = @ClientGuid AND MediaType='PM' AND DayDate = @LocalDayDate AND _SearchRequestID = @SearchRequestID)
				BEGIN
					UPDATE
						IQAgent_DaySummary
					SET
						NoOfDocsLD = ISNULL(NoOfDocsLD,0) + 1,
						AudienceLD = ISNULL(AudienceLD,0) + @Circulation
					WHERE 
						ClientGuid = @ClientGUID
						AND MediaType = 'PM'
						AND DayDate = @LocalDayDate
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
						@ClientGUID,
						@LocalDayDate,
						'PM',
						0,
						0,
						0,
						0,
						NULL,
						NULL,
						1,
						0,
						@Circulation,
						0,
						NULL,
						NULL,
						'PM',
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
					RecordsAfterUpdation = (SELECT SUM(NoOfDocsLD) FROM IQAgent_DaySummary WHERE MediaType ='PM')
				WHERE
					ID = @IQAgent_SummaryTrackingID   
				*/

-- End of Day and Hour Summary tables updates */
			END
		ELSE
			SET @ArchiveBLPMKey = 0

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	
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
				@CreatedBy='usp_ArchiveBLPM_Insert',
				@ModifiedBy='usp_ArchiveBLPM_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		
		SET @ArchiveBLPMKey = 0
	END CATCH
	
	 SET @QueryDetail ='0'
	  SET @TimeDiff = DATEDIFF(ms, @SPStartTime, GETDATE())
	  INSERT INTO IQ_SPTimeTracking([Guid],SPName,INPUT,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,'',@QueryDetail,@TimeDiff)
	
END
