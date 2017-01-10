CREATE PROCEDURE [dbo].[usp_v5_ArchiveNM_Insert]
	@ArticleID VARCHAR(MAX),
	@ArticleUri VARCHAR(MAX),
	@Harvest_Time DATETIME,
	@Title VARCHAR(250),		
	@CustomerGuid UNIQUEIDENTIFIER,
	@ClientGuid UNIQUEIDENTIFIER,
	@CategoryGuid UNIQUEIDENTIFIER,	
	@Content NVARCHAR(MAX),	
	@Publication VARCHAR(MAX),
	@CompeteUrl VARCHAR(MAX),
	@PositiveSentiment TINYINT,
	@NegativeSentiment TINYINT,
	@IQLicense	TINYINT,
	@Event		VARCHAR(50),
	@MediaID bigint,
	@HighLightText nvarchar(max),
	@SearchTerm varchar(500),
	@Number_Hits tinyint,
	@Keywords varchar(2048),
	@Description varchar(2048),
	@ProminenceMultiplier decimal(18,2),
	@MediaType varchar(2),
	@SubMediaType varchar(50),
	@ArchiveKey			BIGINT OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @rpID INT
	DECLARE @ArchiveKeyBkp BIGINT
	
	BEGIN TRANSACTION
	BEGIN TRY	
	
	DECLARE @OtherOnlineAdRate DECIMAL(18,2)
	DECLARE @CompeteMultiplier DECIMAL(18,2)
	DECLARE @OnlineNewsAdRate DECIMAL(18,2)
	DECLARE @URLPercentRead DECIMAL(18,2)
	DECLARE @CompeteAudienceMultiplier DECIMAL(18,2)

	SET @OtherOnlineAdRate = 1 
	SET @CompeteMultiplier = 1 
	SET @OnlineNewsAdRate= 1 
	SET @URLPercentRead = 1
	SET @CompeteAudienceMultiplier = 1 
			
	;WITH TEMP_ClientSettings AS
	(
		SELECT
				ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid DESC) AS RowNum,
				Field,
				VALUE
		FROM
				IQClient_CustomSettings
		WHERE
				(IQClient_CustomSettings._ClientGuid=@ClientGuid OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
				AND IQClient_CustomSettings.Field IN ('OtherOnlineAdRate','CompeteMultiplier','OnlineNewsAdRate','URLPercentRead','CompeteAudienceMultiplier')
	)
 
	SELECT 
		@OtherOnlineAdRate = [OtherOnlineAdRate],
		@CompeteMultiplier = [CompeteMultiplier],
		@OnlineNewsAdRate	=		[OnlineNewsAdRate],
		@URLPercentRead		 =	[URLPercentRead],
		@CompeteAudienceMultiplier =  [CompeteAudienceMultiplier]
	FROM
		(
		  SELECT
				
					[Field],
					[VALUE]
		  FROM
					TEMP_ClientSettings
		  WHERE	
					RowNum =1
		) AS SourceTable
		PIVOT
		(
			MAX(VALUE)
			FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead],[CompeteAudienceMultiplier])
		) AS PivotTable	

	DECLARE @FirstName VARCHAR(150), @LastName  VARCHAR(150)

	SELECT 
		@FirstName = FirstName,  
		@LastName = LastName
	FROM  
		Customer 
	WHERE CustomerGuid = @CustomerGuid


	DECLARE @Compete_Audience INT, @Compete_Result VARCHAR(5) , @AdShareValue DECIMAL(18,2)

	IF(@CompeteUrl = 'facebook.com' OR @CompeteUrl = 'twitter.com' OR @CompeteUrl = 'friendfeed.com')
	BEGIN
		SET @Compete_Audience = -1;
		SET @AdShareValue = -1;
		SET @Compete_Result = NULL;
	END 
	ELSE
	BEGIN
		SELECT 
			@Compete_Audience = ROUND((CONVERT(DECIMAL(18,2),c_uniq_visitor) * @CompeteAudienceMultiplier)/30,0),
			@AdShareValue =((((CONVERT(DECIMAL(18,2),c_uniq_visitor)/30)* @CompeteMultiplier * @CompeteAudienceMultiplier * (CONVERT(DECIMAL(18,2),@URLPercentRead)/100))/1000)* @OnlineNewsAdRate) * @ProminenceMultiplier,
			@Compete_Result = results
		FROM
				IQ_CompeteAll 
		WHERE
				CompeteURL = @CompeteUrl

		/*IF(@Compete_Audience IS NULL OR @AdShareValue IS NULL)
		BEGIN
			SELECT 
				@Compete_Audience = ROUND((CONVERT(DECIMAL(18,2),c_uniq_visitor) * @CompeteAudienceMultiplier)/30,0),
				@AdShareValue =(((CONVERT(DECIMAL(18,2),c_uniq_visitor)/30) * @CompeteMultiplier * @CompeteAudienceMultiplier * (CONVERT(DECIMAL(18,2),@URLPercentRead)/100))/1000) * @OnlineNewsAdRate,
				@Compete_Result = 'E'
			FROM
				IQ_Compete_Averages
			WHERE
				CompeteURL = @CompeteUrl
		END*/
	END 
		

   SELECT
							@rpID=IQCore_RootPath.ID
					FROM
							IQCore_RootPath
								INNER JOIN IQCore_RootPathType
									ON IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
					WHERE
							IQCore_RootPathType.Name='NM'
					ORDER BY
							NEWID()
	
					IF NOT EXISTS(SELECT ArticleID FROM IQCore_Nm WHERE ArticleID = @ArticleID)
						BEGIN
							INSERT INTO 
								IQCore_Nm
								(
									ArticleID,
									Url,
									harvest_time,
									[Status],
									_RootPathID
								)
							VALUES
								(
									@ArticleID,
									@ArticleUri,
									@Harvest_Time,
									'QUEUED',
									@rpID
								)	
						END
		
		
						IF NOT EXISTS(SELECT ArticleID FROM ArchiveNM WHERE ArticleID = @ArticleID AND CustomerGuid = @CustomerGuid AND IsActive=1)
						BEGIN
							
							DECLARE @SearchRequestID bigint

							IF(@MediaID IS NOT NULL)
								SELECT
									@SearchRequestID = IQAgent_MediaResults._SearchRequestID,
									@SearchTerm = SearchTerm.query('SearchRequest/SearchTerm').value('.','varchar(500)'),
									@HighLightText = convert(nvarchar(max), IQAgent_NMResults.HighlightingText),
									@Number_Hits = IQAgent_NMResults.Number_Hits
								FROM	
									IQAgent_MediaResults WITH(NOLOCK) 
										Inner join IQAgent_SearchRequest WITH(NOLOCK) 
											ON IQAgent_MediaResults._SearchRequestID =IQAgent_SearchRequest .ID
										inner join IQAgent_NMResults WITH(NOLOCK) 
											on IQAgent_MediaResults.v5Category = @SubMediaType
											and IQAgent_MediaResults._MediaID = IQAgent_NMResults.ID
								WHERE
									IQAgent_MediaResults.ID = @MediaID
							ELSE
							BEGIN
								SET @SearchRequestID = -1
							END

							INSERT INTO 
								ArchiveNM
								(
									Title,	
									Harvest_Time,								
									FirstName,
									LastName,
									CustomerGuid,
									ClientGuid,
									CategoryGuid,									
									ArticleID,
									ArticleContent,
									Url,
									Publication,
									CompeteUrl,
									IsActive,
									CreatedDate,
									ModifiedDate,
									PositiveSentiment,
									NegativeSentiment,
									Compete_Audience,
									IQAdShareValue,
									Compete_Result,
									IQLicense,
									Number_Hits,
									HighlightingText,
									Keywords,
									Description,
									v5SubMediaType
								)
							SELECT  
									@Title,
									@Harvest_Time,
									@FirstName,
									@LastName,
									@CustomerGuid,
									@ClientGuid,
									@CategoryGuid,									
									@ArticleID,
									@Content,
									@ArticleUri,
									@Publication,
									@CompeteUrl,
									1,
									GETDATE(),
									GETDATE(),
									@PositiveSentiment,
									@NegativeSentiment,
									@Compete_Audience,
									@AdShareValue,
									@Compete_Result,
									@IQLicense,
									@Number_Hits,
									@HighLightText,
									@Keywords,
									@Description,
									@SubMediaType

							SELECT @ArchiveKeyBkp = SCOPE_IDENTITY()

							DECLARE @SecondsOnDay int= 86400
							DECLARE @2DaysTotalSeconds int= 172800
							DECLARE @ParentID bigint

							SELECT @ParentID = ID
							FROM 
								IQArchive_Media
							WHERE
								Title = @Title
								and v5SubMediaType = @SubMediaType
								and CategoryGuid = @CategoryGuid
								and ClientGuid = @ClientGuid
								and _ParentID is null
								and IsActive = 1
								and Cast((CAST(@Harvest_Time AS float) - (CAST(mediadate AS float))) * @SecondsOnDay as bigint) >= 0 and  Cast((CAST(@Harvest_Time AS float) - (CAST(mediadate AS float))) * @SecondsOnDay as bigint) <= @2DaysTotalSeconds
							
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
								'NM',
								@Title,
								'NM',
								@HighLightText,
								@Harvest_Time,
								@CategoryGuid,
								@ClientGuid,
								@CustomerGuid,
								1,
								GETDATE(),
								@PositiveSentiment,
								@NegativeSentiment,
								@ParentID,
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
				@CreatedBy='usp_v5_ArchiveNM_Insert',
				@ModifiedBy='usp_v5_ArchiveNM_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @ArchiveKey = 0
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		
	END CATCH
END
