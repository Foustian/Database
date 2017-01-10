CREATE PROCEDURE [dbo].[usp_ArchiveBLPM_Insert] 
	@BLID varchar (50),
	@Headline varchar(255),
	@PubDate datetime ,
	@Author varchar (50) ,
	@Pub_State varchar (50),
	@Pub_Name varchar (250),
	@Pub_freq varchar (10),
	@Pub_ed_office varchar (250),
	@DMA int ,
	@Text varchar(max),
	@Keywords varchar(max),
	@BLPMxml xml ,
	@FileLocation varchar(250),
	@RPID int ,
	@CategoryGUID uniqueidentifier,
	@ClientGUID uniqueidentifier ,
	@CustomerGUID uniqueidentifier ,
	@Circulation int,
	@SearchRequestID bigint,
	@ArchiveBLPMKey int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	BEGIN TRANSACTION
	BEGIN TRY	

    -- Insert statements for procedure here
		DECLARE @ClipCount int
		SELECT @ClipCount = COUNT(*) FROM ArchiveBLPM WHERE BLID=@BLID and PubDate=@PubDate
		DECLARE @IQAgent_BLPMResultsKey bigint
		DECLARE @IQAgent_SummaryTrackingID bigint
		DECLARE @GMT int, @DST int, @LocalDayDate date
		SELECT  @GMT = gmt , @DST = dst From Client where ClientGuid = @ClientGUID
		SET @LocalDayDate = convert (date,CASE WHEN dbo.fnIsDayLightSaving(@PubDate) = 1 THEN  DATEADD(HOUR,(@GMT + @DST),@PubDate) ELSE DATEADD(HOUR,@GMT,@PubDate) END)
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
				Text,
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
				Circulation
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
					@Circulation
				)
				SELECT @ArchiveBLPMKey = SCOPE_IDENTITY()
			
			
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
					CreatedDate
				)
				VALUES
				(
					@ArchiveBLPMKey,
					'PM',
					@Headline,
					'PM',
					Convert(nvarchar(max),@BLPMxml),
					@PubDate,
					@CategoryGUID,
					@ClientGUID,
					@CustomerGUID,
					1,
					GETDATE()
				)

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
					[Text],
					BLPMxml,
					FileLocation,
					Circulation,
					RPID,
					CreatedDate,
					ModifiedDate,
					IsActive
				)

				values
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
					1
				)

				SELECT @IQAgent_BLPMResultsKey = SCOPE_IDENTITY()


				INSERT INTO IQAgent_MediaResults
				(
					Title,
					_MediaID,
					MediaDate,
					_SearchRequestID,
					MediaType,
					Category,
					HighlightingText,
					PositiveSentiment,
					NegativeSentiment,
					IsActive
				)
				VALUES
				(
					@Headline,
					@IQAgent_BLPMResultsKey,
					@PubDate,
					@SearchRequestID,
					'PM',
					'PM',
					Convert(nvarchar(max),@BLPMxml),
					NULL,
					NULL,
					1
				)

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

				IF EXISTS(SELECT NoOfDocs FROM IQAgent_HourSummary WHERE MediaType = 'PM' AND HourDateTime=DateAdd (hour,DATEPART(hour,@PubDate), convert (varchar(10),@PubDate,101)) AND ClientGuid = @ClientGUID AND _SearchRequestID = @SearchRequestID)
				BEGIN
					Update 
						IQAgent_HourSummary   
					SET 
						NoOfDocs = NoOfDocs + 1,
						Audience = Audience + @Circulation
					FROM 
						IQAgent_HourSummary 
					WHERE
						MediaType = 'PM'
						AND HourDateTime = DateAdd (hour,DATEPART(hour,@PubDate), convert (varchar(10),@PubDate,101))
						AND ClientGuid  = @ClientGUID
						AND _SearchRequestID = @SearchRequestID
				END
				ELSE
				BEGIN
					Insert Into IQAgent_HourSummary      
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
						DateAdd (hour,DATEPART(hour,@PubDate), convert (varchar(10),@PubDate,101)),
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
				END
			
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

				if EXISTS(SELECT NoOfDocs FROM IQAgent_DaySummary WHERE ClientGuid = @ClientGUID AND MediaType='PM' AND DayDate = convert (date,@PubDate) AND _SearchRequestID = @SearchRequestID)
				BEGIN
					UPDATE
						IQAgent_DaySummary
					SET
						NoOfDocs = NoOfDocs + 1,
						Audience = Audience + @Circulation
					
					WHERE 
						ClientGuid = @ClientGUID
						AND MediaType = 'PM'
						AND DayDate = convert (date,@PubDate)
						AND _SearchRequestID = @SearchRequestID
				END
				ELSe
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
						convert (date,@PubDate),
						'PM',
						1,
						0,
						@Circulation,
						0,
						NUll,
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
				END

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
			
				if EXISTS(SELECT IQAgent_DaySummary.ID FROM IQAgent_DaySummary WHERE ClientGuid = @ClientGuid AND MediaType='PM' AND DayDate = @LocalDayDate AND _SearchRequestID = @SearchRequestID)
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
				END
				ELSe
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
				END

				UPDATE 
					IQAgent_SummaryTracking
				SET
					RecordsAfterUpdation = (SELECT SUM(NoOfDocsLD) FROM IQAgent_DaySummary WHERE MediaType ='PM')
				WHERE
					ID = @IQAgent_SummaryTrackingID   
			END
		ELSE
			SET @ArchiveBLPMKey = 0

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	
		ROLLBACK TRANSACTION
		
		declare @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
				
		
		Select 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_ArchiveBLPM_Insert',
				@ModifiedBy='usp_ArchiveBLPM_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		
		SET @ArchiveBLPMKey = 0
	END CATCH
END