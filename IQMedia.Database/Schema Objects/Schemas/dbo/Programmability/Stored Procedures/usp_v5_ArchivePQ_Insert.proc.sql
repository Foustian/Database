CREATE PROCEDURE [dbo].[usp_v5_ArchivePQ_Insert]
	@ProQuestID VARCHAR(MAX),
	@Title VARCHAR(255),		
	@Publication VARCHAR(250),
	@Author XML,
	@Content VARCHAR(MAX),
	@ContentHTML VARCHAR(MAX),
	@HighlightingText VARCHAR(MAX),
	@AvailableDate DATE,
	@MediaDate DATE,
	@LanguageNum SMALLINT,
	@MediaCategory VARCHAR(50),
	@Copyright VARCHAR(250),
	@CustomerGuid UNIQUEIDENTIFIER,
	@ClientGuid UNIQUEIDENTIFIER,
	@CategoryGuid UNIQUEIDENTIFIER,	
	@PositiveSentiment TINYINT,
	@NegativeSentiment TINYINT,
	@MediaID BIGINT,
	@SearchTerm VARCHAR(500),
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
	
	DECLARE @rpID INT
	DECLARE @ArchiveKeyBkp BIGINT
	
	BEGIN TRANSACTION
	BEGIN TRY

	DECLARE @FirstName VARCHAR(150), @LastName  VARCHAR(150)

	SELECT 
		@FirstName = FirstName,  
		@LastName = LastName
	FROM  
		Customer 
	WHERE CustomerGuid = @CustomerGuid		

		IF NOT EXISTS(SELECT ProQuestID FROM ArchivePQ WHERE ProQuestID = @ProQuestID AND CustomerGuid = @CustomerGuid AND IsActive = 1)
		  BEGIN
			
			DECLARE @SearchRequestID bigint

			IF(@MediaID IS NOT NULL)
				SELECT
					@SearchRequestID = IQAgent_MediaResults._SearchRequestID,
					@SearchTerm = SearchTerm.query('SearchRequest/SearchTerm').value('.','varchar(500)'),
					@HighlightingText = IQAgent_MediaResults.HighlightingText
				FROM	
					IQAgent_MediaResults WITH(NOLOCK) 
						Inner join IQAgent_SearchRequest WITH(NOLOCK) 
							ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest .ID
						inner join IQAgent_PQResults WITH(NOLOCK) 
							on IQAgent_MediaResults.v5Category = @SubMediaType
							and IQAgent_MediaResults._MediaID = IQAgent_PQResults.ID
				WHERE
					IQAgent_MediaResults.ID = @MediaID
			ELSE
			  BEGIN
				SET @SearchRequestID = -1
			  END

			INSERT INTO ArchivePQ
			(
				ProQuestID,
				Title,
				Publication,
				Author,
				MediaCategory,
				Content,
				ContentHTML,
				HighlightingText,
				AvailableDate,
				MediaDate,
				LanguageNum,
				Copyright,
				CategoryGUID,
				ClientGUID,
				CustomerGUID,
				PositiveSentiment,
				NegativeSentiment,
				CreatedDate,
				ModifiedDate,
				IsActive,
				Keywords,
				Description,
				v5SubMediaType
			)
			VALUES
			(  
				@ProQuestID,
				@Title,
				@Publication,
				@Author,
				@MediaCategory,
				@Content,
				@ContentHTML,
				@HighlightingText,
				@AvailableDate,
				@MediaDate,
				@LanguageNum,
				@Copyright,
				@CategoryGUID,
				@ClientGUID,
				@CustomerGUID,
				@PositiveSentiment,
				@NegativeSentiment,
				GETDATE(),
				GETDATE(),
				1,
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
				HighlightingText,
				MediaDate,
				CategoryGUID,
				ClientGUID,
				CustomerGUID,
				IsActive,
				CreatedDate,
				PositiveSentiment,
				NegativeSentiment,
				_ParentID,
				_SearchRequestID,
				_MediaID,
				SearchTerm,
				Content,
				v5MediaType,
				v5SubMediaType
			)
			VALUES
			(
				@ArchiveKeyBkp,
				'PQ',
				@Title,
				'PQ',
				@HighlightingText,
				@MediaDate,
				@CategoryGuid,
				@ClientGuid,
				@CustomerGuid,
				1,
				GETDATE(),
				@PositiveSentiment,
				@NegativeSentiment,
				NULL,
				@SearchRequestID,
				@MediaID,
				@SearchTerm,
				@Content,
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
				@CreatedBy='usp_v5_ArchivePQ_Insert',
				@ModifiedBy='usp_v5_ArchivePQ_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @ArchiveKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		
	END CATCH
END
