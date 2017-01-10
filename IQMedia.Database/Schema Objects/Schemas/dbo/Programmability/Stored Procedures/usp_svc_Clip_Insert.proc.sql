CREATE PROCEDURE [dbo].[usp_svc_Clip_Insert]
(
	@RecordfileGUID		UNIQUEIDENTIFIER,
	@StartOffset		INT,
	@EndOffset			INT,
	@Title				VARCHAR(255),
	@Description		VARCHAR(MAX),
	@Category			UNIQUEIDENTIFIER,
	@Keywords			VARCHAR(MAX),
	@ClientGUID			UNIQUEIDENTIFIER,
	@CustomerGUID		UNIQUEIDENTIFIER,
	@ClipMeta			XML
)
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	DECLARE @OtherOnlineAdRate	DECIMAL(18,2)
	DECLARE @CompeteMultiplier	DECIMAL(18,2)
	DECLARE @OnlineNewsAdRate	DECIMAL(18,2)
	DECLARE @URLPercentRead		DECIMAL(18,2)

	SET @OtherOnlineAdRate = 1 
	SET @CompeteMultiplier = 1 
	SET @OnlineNewsAdRate= 1 
	SET @URLPercentRead = 1
	
	DECLARE @Multiplier FLOAT
	SELECT @Multiplier = CONVERT(FLOAT,ISNULL((SELECT VALUE FROM IQClient_CustomSettings WHERE Field = 'Multiplier' AND _ClientGuid = @ClientGuid),(SELECT VALUE FROM IQClient_CustomSettings WHERE Field = 'Multiplier' AND _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))

	DECLARE @CppDayPart2Val FLOAT
	SELECT @CppDayPart2Val = cppvalue FROM IQ_SQAD WHERE daypartid = 2 AND SQADMarketID = 997

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
				AND IQClient_CustomSettings.Field IN ('OtherOnlineAdRate','CompeteMultiplier','OnlineNewsAdRate','URLPercentRead')
	)
 
	SELECT 
		@OtherOnlineAdRate = [OtherOnlineAdRate],
		@CompeteMultiplier = [CompeteMultiplier],
		@OnlineNewsAdRate  = [OnlineNewsAdRate],
		@URLPercentRead	   = [URLPercentRead] 
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
			FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead])
		) AS PivotTable
	
	BEGIN TRY
	
		BEGIN TRANSACTION
		
		DECLARE @ClipGUID UNIQUEIDENTIFIER = NEWID()
		DECLARE @ClipDate DATETIME=SYSDATETIME()
		
		INSERT INTO IQCore_Clip
		(
			[Guid],
			StartOffset,
			EndOffset,
			_RecordfileGuid,
			DateCreated,
			_UserGuid
		)
		VALUES
		(
			@ClipGUID,
			@StartOffset,
			@EndOffset,
			@RecordfileGUID,
			@ClipDate,
			'07175c0e-2b70-4325-be6d-611910730968'
		)
		
		INSERT INTO IQCore_ClipInfo
		(
			_ClipGuid,
			Title,
			Category,
			[Description],
			Keywords
		)
		VALUES
		(
			@ClipGUID,
			@Title,
			'PR',
			@Description,
			@Keywords
		)
		
		INSERT INTO IQCore_ClipMeta
		(
			_ClipGuid,
			Field,
			VALUE
		)
		SELECT
			@ClipGUID,
			tbl.c.value('@Field','varchar(128)'),
			tbl.c.value('@Value','varchar(2048)')
		FROM
			@ClipMeta.nodes('List/Meta') AS tbl(c)
			
		DECLARE @tmpArchiveClip TABLE(ID BIGINT,Title120 VARCHAR(100),ClipDate DATE,IQ_CC_KEY VARCHAR(255))
		DECLARE @StartDate	DATETIME,
				@IQCCKey	VARCHAR(50),
				@SourceID	VARCHAR(255),
				@SourceLogo	VARCHAR(150)
				
		SELECT
				@StartDate=IQCore_Recording.StartDate,
				@IQCCKey=LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00',
				@SourceID=IQCore_Source.SourceID,
				@SourceLogo='http://media.iqmediacorp.com/logos/stations/small/' + IQCore_Source.Logo				
		FROM
				[IQCore_Recordfile] WITH(NOLOCK)             
        
				INNER JOIN [IQCore_Recording] WITH(NOLOCK) 
					ON	[IQCore_Recordfile].[Guid]=@RecordfileGUID
					AND	[IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID] 
					
        
				INNER JOIN [IQCore_Source] WITH(NOLOCK) 
					ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid] 
					
		DECLARE @ClipMediaDate DATETIME,
				@FirstName VARCHAR(50),
				@LastName	VARCHAR(50),
				@NielsenAudience INT,
				@MediaValue	DECIMAL(18,2),
				@NielsenResult VARCHAR(1),
				@Title120 VARCHAR(100)
				
		SELECT
			@ClipMediaDate=[dbo].fnGetClipAdjustedDateTime(@StartDate,[IQ_Station].gmt_adj,[IQ_Station].dst_adj,@StartOffset),
			@NielsenAudience= CASE
						WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
							CONVERT(VARCHAR,CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS INT))
					ELSE 
							AUDIENCE
					END,
					
			@MediaValue= 	CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
					CONVERT(VARCHAR,CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* @Multiplier * 
								(
									CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN 
										@CppDayPart2Val 
									ELSE 
										(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID) 
									END
								)
									* (CAST((@EndOffset - @StartOffset + 1) AS DECIMAL(18,2)) /30 )))
			ELSE
					CONVERT(VARCHAR,CONVERT(DECIMAL(18,2), SQAD_SHAREVALUE * @MultiPlier * (CAST((@EndOffset - @StartOffset + 1) AS DECIMAL(18,2)) /30 ))) 
			END	,
			
			@NielsenResult=CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
						CASE WHEN CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* @MultiPlier * (
								CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN 
									@CppDayPart2Val 
								ELSE 
									(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID) 
								END
							)) IS NULL THEN
							NULL
						ELSE
							'E'
						END
					ELSE
						'A'
					END,
					
			@Title120=(SELECT TOP 1 IQ_SSP.title120 FROM IQ_SSP WITH (NOLOCK) WHERE 
				IQ_CC_Key =   @IQCCKey
				AND IQ_Start_Minute = (
						SELECT 
							CASE WHEN MAX(IQ_Start_Minute) IS NULL THEN 
								(SELECT MIN(IQ_Start_Minute) FROM  IQ_SSP WITH (NOLOCK) WHERE IQ_CC_Key = @IQCCKey)  
							ELSE 
								MAX(IQ_Start_Minute) END AS IQ_Start_Minute 
						FROM 
							IQ_SSP WITH (NOLOCK)
						WHERE IQ_CC_Key = @IQCCKey
						AND (IQ_Start_Minute * 60) <=  @StartOffset
				)
			)
		FROM
			[IQ_Station] WITH(NOLOCK) 			
				LEFT OUTER JOIN  [IQ_NIELSEN_SQAD] WITH(NOLOCK) 
					ON IQ_Station.IQ_Station_ID=@SourceID
					AND [IQ_NIELSEN_SQAD].IQ_CC_Key = @IQCCKey
					AND [IQ_NIELSEN_SQAD].IQ_Start_Point = CASE WHEN @StartOffset = 0 THEN 1 ELSE CEILING(@StartOffset /900.0) END
					
				LEFT OUTER JOIN IQ_Nielsen_Averages WITH(NOLOCK) 
					ON IQ_Station.IQ_Station_ID=@SourceID
					AND IQ_Nielsen_Averages.IQ_Start_Point = CASE WHEN @StartOffset = 0 THEN 1 ELSE CEILING(@StartOffset /900.0) END
					AND Affil_IQ_CC_Key =  CASE WHEN IQ_Station.Dma_Num = '000' THEN IQ_Station.IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(@IQCCKey,CHARINDEX('_',@IQCCKey) +1,13)
		WHERE	
				IQ_Station.IQ_Station_ID=@SourceID		
			
		INSERT INTO ArchiveClip
		(
				ClipID,
				ClipLogo,
				ClipTitle,
				ClipDate,
				GMTDateTime,
				FirstName,
				LastName,
				Category,
				Keywords,
				[Description],
				ClipCreationDate,
				CreatedBy,
				ModifiedBy,
				CreatedDate,
				ModifiedDate,
				IsActive,
				ClientGUID,
				CategoryGUID,
				SubCategory1GUID,
				SubCategory2GUID,
				SubCategory3GUID,
				CustomerGUID,
				IQ_CC_Key,
				StartOffset,
				Nielsen_Audience,
				IQAdShareValue,
				Nielsen_Result,
				Title120,
				v5SubMediaType
		)
		OUTPUT INSERTED.ArchiveClipKey,inserted.Title120,CONVERT(DATE,inserted.ClipDate),inserted.IQ_CC_Key INTO @tmpArchiveClip
		SELECT	
		
			@ClipGUID,
			@SourceLogo,
			@Title,			
			@ClipMediaDate,
			@StartDate,
			FirstName,
			LastName,
			'PR',
			@Keywords,
			@Description,
			@ClipDate,
			'System',
			'System',
			GETDATE(),
			GETDATE(),
			1,
			@ClientGUID,
			@Category,
			NULL,
			NULL,
			NULL,
			@CustomerGUID,
			@IQCCKey,
			@StartOffset,
			@NielsenAudience,
			@MediaValue,
			@NielsenResult,
			@Title120,
			'TV'
					
	FROM
			
                
				[Customer]
	WHERE 
			Customer.CustomerGUID=@CustomerGUID	
		
	
	DECLARE @ArchiveMedia TABLE (ID BIGINT, CategoryGUID UNIQUEIDENTIFIER, ClientGUID UNIQUEIDENTIFIER, Title120 VARCHAR(100), MediaType CHAR(2), MediaID BIGINT, ClipDate DATE,ClipTitle NVARCHAR(MAX),Station_Affil VARCHAR(255))														
			
			INSERT INTO IQArchive_Media
			(
				_ArchiveMediaID,
				MediaType,
				SubMediaType,
				Title,
				MediaDate,
				CategoryGUID,
				ClientGUID,
				CustomerGUID,
				IsActive,
				CreatedDate,
				v5MediaType,
				v5SubMediaType
			)
			OUTPUT INSERTED.ID, INSERTED.CategoryGUID, INSERTED.ClientGUID, NULL AS Title120, INSERTED.MediaType, INSERTED._ArchiveMediaID AS MediaID, NULL AS ClipDate,inserted.Title AS ClipTitle, NULL AS Station_Affil INTO @ArchiveMedia
			SELECT 
					TmpArchiveClip.ID,
					'TV',
					'TV',
					@Title,
					@StartDate,
					@Category,
					@ClientGUID,
					@CustomerGUID,
					1,
					@ClipDate,
					'TV',
					'TV'
					
			FROM @tmpArchiveClip AS TmpArchiveClip

									 
		UPDATE @ArchiveMedia
				SET Title120=TempMedia.Title120,
					ClipDate=TempMedia.ClipDate,
					Station_Affil = IQ_Station.Station_Affil
		FROM
			@ArchiveMedia AS TempArchiveMedia
				INNER JOIN @tmpArchiveClip AS TempMedia
					ON TempArchiveMedia.MediaID=TempMedia.ID
				INNER JOIN IQ_Station	
					ON IQ_Station_ID = SUBSTRING(TempMedia.IQ_CC_KEY,0 ,CHARINDEX('_',TempMedia.IQ_CC_KEY))
					


		DECLARE @MT TABLE (ArchiveMediaID BIGINT, TVID BIGINT, Title120 VARCHAR(100), ClipDate DATE, CategoryGUID UNIQUEIDENTIFIER, ClientGUID UNIQUEIDENTIFIER,ClipTitle NVARCHAR(MAX),Station_Affil VARCHAR(255))

		INSERT INTO @MT
		(
			ArchiveMediaID,
			TVID,
			Title120,
			ClipDate,
			CategoryGUID,
			ClientGUID,
			ClipTitle,
			Station_Affil
		)
		SELECT
				MIN(IQArchive_Media.ID) AS ArchiveMediaID,
				MIN(ArchiveClip.ArchiveClipKey) AS TVID,	 
				ArchiveClip.Title120,
				CONVERT(DATE,ArchiveClip.ClipDate),
				ArchiveClip.CategoryGUID,
				ArchiveClip.ClientGUID,
				ArchiveClip.ClipTitle,
				TempArchiveMedia.Station_Affil
										
		FROM @ArchiveMedia AS TempArchiveMedia		
				INNER JOIN ArchiveClip WITH (NOLOCK)
					ON TempArchiveMedia.ClientGUID=ArchiveClip.ClientGUID
					AND	TempArchiveMedia.CategoryGUID=ArchiveClip.CategoryGUID
					AND TempArchiveMedia.ClipDate=CONVERT(DATE,ArchiveClip.ClipDate)
					AND TempArchiveMedia.Title120=ArchiveClip.Title120
					AND TempArchiveMedia.MediaID!=ArchiveClip.ArchiveClipKey
					AND TempArchiveMedia.ClipTitle = ArchiveClip.ClipTitle
				INNER JOIN IQ_Station 
					ON IQ_Station.IQ_Station_ID = SUBSTRING(ArchiveClip.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveClip.IQ_CC_Key))
					AND TempArchiveMedia.Station_Affil = IQ_Station.Station_Affil
				INNER JOIN IQArchive_Media WITH(NOLOCK) 
					ON ArchiveClip.ArchiveClipKey=IQArchive_Media._ArchiveMediaID
					AND IQArchive_Media.MediaType='TV'
					AND _ParentID IS NULL											
		WHERE 											
					IQArchive_Media.IsActive=1
			AND ArchiveClip.IsActive=1
		GROUP BY ArchiveClip.ClientGUID, ArchiveClip.CategoryGUID, CONVERT(DATE,ArchiveClip.ClipDate),ArchiveClip.Title120,ArchiveClip.ClipTitle,TempArchiveMedia.Station_Affil
									
		DECLARE @Child TABLE(ArchiveMediaID BIGINT, ParentMediaID BIGINT)

		INSERT INTO @Child
		(
			ArchiveMediaID,
			ParentMediaID
		)
		SELECT
				TempArchiveMedia.ID,
				MTbl.ArchiveMediaID AS ParentMediaID
		FROM
				@ArchiveMedia AS TempArchiveMedia
					INNER JOIN @MT AS MTbl
						ON		TempArchiveMedia.ClientGUID=MTbl.ClientGUID
							AND TempArchiveMedia.CategoryGUID=MTbl.CategoryGUID
							AND TempArchiveMedia.ClipDate=MTbl.ClipDate
							AND TempArchiveMedia.Title120=MTbl.Title120
							AND TempArchiveMedia.ClipTitle = MTbl.ClipTitle
							AND TempArchiveMedia.Station_Affil = MTbl.Station_Affil
														
		UPDATE 
				IQArchive_Media
		SET
				_ParentID= CASE WHEN ID=ParentMediaID THEN NULL ELSE ParentMediaID END
		FROM
				IQArchive_Media
					INNER JOIN	@Child AS Child
						ON		IQArchive_Media.ID=Child.ArchiveMediaID
		
		IF EXISTS(SELECT IQUGCArchiveKey FROM IQUGCArchive WHERE UGCGUID=@RecordfileGUID AND _FileTypeID>=9)
		BEGIN
			DECLARE @CurrentDateTime DATETIME=GETDATE()
			
			INSERT INTO IQService_UGCRawClipExport
			(
				ClipGUID,
				[Status],
				DateQueued,
				LastModified
			)
			VALUES
			(
				@ClipGUID,
				'QUEUED',
				@CurrentDateTime,
				@CurrentDateTime
			)  
		END

		/* Clip CC Export */

		EXEC usp_Services_ClipCCExport_Insert @ClipGUID, @ClientGUID
						
		SELECT
				@ClipGUID
		
	
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF(@@TRANCOUNT>0)
		BEGIN
			ROLLBACK TRANSACTION
		END
		
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
				@ExceptionMessage=CONVERT(VARCHAR(500),ERROR_NUMBER())+'_'+ERROR_MESSAGE() + '_RecordfileGuid: ' + cast(@RecordfileGUID as varchar(100)),
				@CreatedBy='usp_svc_Clip_Insert',
				@ModifiedBy='usp_svc_Clip_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		
		RAISERROR(@ExceptionMessage,11,1)
	
	END CATCH

END

