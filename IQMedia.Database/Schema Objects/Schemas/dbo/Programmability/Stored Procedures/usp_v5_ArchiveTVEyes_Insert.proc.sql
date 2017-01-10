CREATE PROCEDURE [dbo].[usp_v5_ArchiveTVEyes_Insert]	
	@MediaID BIGINT,
	@CustomerGuid UNIQUEIDENTIFIER,
	@ClientGuid UNIQUEIDENTIFIER,
	@CategoryGuid UNIQUEIDENTIFIER,
	@Title VARCHAR(255),
	@StationID VARCHAR(50),
	@Market VARCHAR(150),
	@DMARank VARCHAR(5),
	@StationIDNum VARCHAR(50),
	@Duration INT,
	@Transcript NVARCHAR(MAX),
	@UTCDateTime DATETIME,
	@LocalDateTime DATETIME,
	@PositiveSentiment TINYINT,
	@NegativeSentiment TINYINT,
	@TimeZone VARCHAR(10),
	@Keywords varchar(2048),
	@Description varchar(2048),
	@MediaType varchar(2),
	@SubMediaType varchar(50),
	@ArchiveKey	BIGINT OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @RootPathID INT
	DECLARE @ArchiveKeyBkp BIGINT
	DECLARE @TVEyesID BIGINT
	
	BEGIN TRANSACTION
	BEGIN TRY	
	
		SELECT @RootPathID = ID FROM IQCore_RootPath WHERE _RootPathTypeID = (SELECT ID FROM IQCore_RootPathType Where Name ='TVEyes')
		SELECT	
			@TVEyesID = IQAgent_TVEyesResults.ID 
		FROM	
			IQAgent_TVEyesResults WITH (NOLOCK)
				INNER JOIN IQAgent_MediaResults WITH (NOLOCK)
					ON IQAgent_MediaResults._MediaID = IQAgent_TVEyesResults.ID
					AND IQAgent_MediaResults.v5Category = @SubMediaType
		WHERE	
			IQAgent_MediaResults.ID = @MediaID
			

		IF NOT EXISTS(SELECT _IQAgentID FROM ArchiveTVEyes WHERE _IQAgentID = @TVEyesID AND CustomerGuid = @CustomerGuid AND IsActive = 1)
		  BEGIN
			
			DECLARE @SearchRequestID bigint
			DECLARE @SearchTerm varchar(500)

			SELECT
				@SearchRequestID = IQAgent_MediaResults._SearchRequestID,
				@SearchTerm = SearchTerm.query('SearchRequest/SearchTerm').value('.','varchar(500)')
			FROM	
				IQAgent_MediaResults WITH(NOLOCK) 
					Inner join IQAgent_SearchRequest WITH(NOLOCK) 
						ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID
			WHERE
				IQAgent_MediaResults.ID = @MediaID

			INSERT INTO ArchiveTVEyes
			(
				_IQAgentID,
				ClientGUID,
				CustomerGUID,
				CategoryGuid,
				Title,
				StationID,
				Market,
				DMARank,
				StationIDNum,
				Duration,
				Transcript,
				[UTCDateTime],
				PositiveSentiment,
				NegativeSentiment,
				ModifiedDate,
				[Status],
				IsDownLoaded,
				TMGuid,
				_RootPathID,
				LocalDateTime,
				TimeZone,
				HighlightingText,
				Number_Hits,
				Keywords,
				Description,
				v5SubMediaType
			)
			VALUES
			(
				@TVEyesID,
				@ClientGuid,
				@CustomerGuid,
				@CategoryGuid,
				@Title,
				@StationID,
				@Market,
				@DMARank,
				@StationIDNum,
				@Duration,
				@Transcript,
				@UTCDateTime,
				@PositiveSentiment,
				@NegativeSentiment,
				GETDATE(),
				'QUEUED',
				0,
				NEWID(),
				@RootPathID,
				@LocalDateTime,
				@TimeZone,
				@Transcript,
				0,
				@Keywords,
				@Description,
				@SubMediaType
			)

			SELECT @ArchiveKeyBkp = SCOPE_IDENTITY()
			
			INSERT INTO IQArchive_Media
			(
				_ArchiveMediaID,
				MediaType,
				Title,
				SubMediaType,
				MediaDate,
				CategoryGUID,
				ClientGUID,
				CustomerGUID,
				IsActive,
				CreatedDate,
				_SearchRequestID,
				_MediaID,
				SearchTerm,
				HighlightingText,
				Content,
				v5MediaType,
				v5SubMediaType
			)
			VALUES
			(
				@ArchiveKeyBkp,
				'TM',
				@Title,
				'Radio',
				@UTCDateTime,
				@CategoryGuid,
				@ClientGuid,
				@CustomerGuid,
				1,
				GETDATE(),
				@SearchRequestID,
				@MediaID,
				@SearchTerm,
				@Transcript,
				@Transcript,
				@MediaType,
				@SubMediaType
			)								
		  END
		ELSE
		  BEGIN									
			SELECT  @ArchiveKeyBkp = -1
		  END							
							
		SET @ArchiveKey = @ArchiveKeyBkp		
	
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
				@CreatedBy='usp_v5_ArchiveTVEyes_Insert',
				@ModifiedBy='usp_v5_ArchiveTVEyes_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @ArchiveKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		
	END CATCH
END
