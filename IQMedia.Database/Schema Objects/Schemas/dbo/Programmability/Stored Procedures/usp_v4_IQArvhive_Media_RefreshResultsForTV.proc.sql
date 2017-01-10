-- =============================================
-- Author:		<Author,,Name>
-- Create date: 24 June 2013
-- Description:	Refresh results for "ArvhiveClip" and insert into "ArchiveClip" and "IQArchive_Media"
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQArvhive_Media_RefreshResultsForTV]
	@ClientGuid		UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

	
	------------------------- To find out Nielsen values for ArchiveClip table ------------------------
	
	DECLARE @OtherOnlineAdRate	decimal(18,2)
	DECLARE @CompeteMultiplier	decimal(18,2)
	DECLARE @OnlineNewsAdRate	decimal(18,2)
	DECLARE @URLPercentRead		decimal(18,2)

	SET @OtherOnlineAdRate = 1 
	SET @CompeteMultiplier = 1 
	SET @OnlineNewsAdRate= 1 
	Set @URLPercentRead = 1
	
	DECLARE @Multiplier float
	select @Multiplier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGuid),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))

	DECLARE @CppDayPart2Val float
	SELECT @CppDayPart2Val = cppvalue FROM IQ_SQAD Where daypartid = 2 and SQADMarketID = 997

	;WITH TEMP_ClientSettings AS
	(
		SELECT
				ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid desc) as RowNum,
				Field,
				Value
		FROM
				IQClient_CustomSettings
		Where
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
					[Value]
		  FROM
					TEMP_ClientSettings
		  WHERE	
					RowNum =1
		) AS SourceTable
		PIVOT
		(
			Max(Value)
			FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead])
		) AS PivotTable
	
	
	---------------------------------------------------------------------------------------------------
	
	


	----- Insert results into Temp table. Use Temp table to fill [dbo].[ArchiveCilp] and [dbo].[IQArchive_Media] table

	DECLARE @TempResults AS TABLE
	(
		FirstName				VARCHAR(150),
		LastName				VARCHAR(150),
		ClipID					UNIQUEIDENTIFIER,
		ClipLogo				VARCHAR(150),
		ClipTitle				VARCHAR(255),
		ClipDate				DATETIME,
		GMTDateTime				DATETIME,
		Category				VARCHAR(50),
		Keywords				VARCHAR(MAX),
		Description				VARCHAR(MAX),
		ClipCreationDate		DATETIME,
		ThumbnailImagePath		VARCHAR(500),
		ClientGUID				UNIQUEIDENTIFIER,
		CategoryGUID			UNIQUEIDENTIFIER,
		SubCategory1GUID		UNIQUEIDENTIFIER,
		SubCategory2GUID		UNIQUEIDENTIFIER,
		SubCategory3GUID		UNIQUEIDENTIFIER,
		CustomerGUID			UNIQUEIDENTIFIER,
		IQ_CC_Key				VARCHAR(28),
		StartOffset				INT,
		EndOffSet				INT,
		Nielsen_Audience		INT,
		IQAdShareValue			DECIMAL(18,2),
		Nielsen_Result			VARCHAR(1),
		Title120				VARCHAR(100)
	)	
	
	
	INSERT INTO @TempResults
	(
		FirstName,
		LastName,
		ClipID,
		ClipLogo,
		ClipTitle,
		ClipDate,
		GMTDateTime,
		Category,
		Keywords,		
		Description,
		ClipCreationDate,
		ThumbnailImagePath,
		ClientGUID,	
		CategoryGUID,		
		SubCategory1GUID,
		SubCategory2GUID,	
		SubCategory3GUID,	
		CustomerGUID,	
		IQ_CC_Key,
		StartOffset,
		EndOffSet,
		Title120
	)
	
	
		
	SELECT 
			 (Select FirstName From Customer Where CustomerGUID = CONVERT(uniqueidentifier,ClipMetaData.iQUser)),
			 (Select LastName From Customer Where CustomerGUID = CONVERT(uniqueidentifier,ClipMetaData.iQUser)),
             [IQCore_Clip].[Guid] AS ClipID, 
             'http://media.iqmediacorp.com/logos/stations/small/' + [IQCore_Source].[Logo] AS ClipLogo, 
             [IQCore_ClipInfo].[Title] AS ClipTitle, 
             [dbo].fnGetClipAdjustedDateTime([IQCore_Recording].[StartDate],[IQ_Station].gmt_adj,[IQ_Station].dst_adj,IQCore_Clip.StartOffset) AS ClipDate,
			 IQCore_Recording.StartDate as GMTDateTime,
             [IQCore_ClipInfo].[Category], 
             [IQCore_ClipInfo].[Keywords], 
             [IQCore_ClipInfo].[Description],  
             [IQCore_Clip].[DateCreated] AS ClipCreationDate, 
             REPLACE([IQCore_RootPath].[StreamSuffixPath] + [IQCore_AssetLocation].[Location],'\','/') AS ClipThumbnailImagePath, 
             CASE WHEN LEN(iqClientid) > 0 THEN [iqClientid] ELSE NULL  END AS ClientGUID, 
             CASE WHEN LEN(iQCategory) > 0 THEN [iQCategory] ELSE NULL END AS CategoryGUID, 
             CASE WHEN LEN(ClipMetaData.SubCategory1GUID) > 0 THEN ClipMetaData.SubCategory1GUID ELSE NULL END AS SubCategory1GUID, 
             CASE WHEN LEN(ClipMetaData.SubCategory2GUID) > 0 THEN ClipMetaData.SubCategory2GUID ELSE NULL END AS SubCategory2GUID, 
             CASE WHEN LEN(ClipMetaData.SubCategory3GUID) > 0 THEN ClipMetaData.SubCategory3GUID ELSE NULL END AS SubCategory3GUID, 
             [iQUser] as CustomerGUID, 
             LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' + 
				SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) + 
				'_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00' AS IQ_CC_KEY,
			IQCore_Clip.StartOffset,
			IQCore_Clip.EndOffset,
			(SELECT  IQ_SSP.title120 FROM IQ_SSP WHERE 
				IQ_CC_Key =   LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00' 
				AND IQ_Start_Minute = (
						SELECT 
							CASE WHEN MAX(IQ_Start_Minute) IS NULL THEN 
								(SELECT MIN(IQ_Start_Minute) FROM  IQ_SSP WHERE IQ_CC_Key = LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00')  
							ELSE 
								MAX(IQ_Start_Minute) END as IQ_Start_Minute 
						FRoM 
							IQ_SSP 
						WHERE IQ_CC_Key = LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00' 
						AND (IQ_Start_Minute * 60) <=  IQCore_Clip.StartOffset
				)
			)         
        FROM 
        [IQCore_Clip] with(nolock) 
        
        INNER JOIN [IQCore_ClipInfo] with(nolock) 
                ON [IQCore_Clip].[Guid] = [IQCore_ClipInfo].[_ClipGuid]                         

        INNER JOIN [IQCore_Recordfile] with(nolock) 
                ON [IQCore_Recordfile].[Guid] = [IQCore_Clip].[_RecordfileGuid] 
        
        INNER JOIN [IQCore_Recording] with(nolock) 
                ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID] 
        
        INNER JOIN [IQCore_Source] with(nolock) 
                ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid] 
                
        LEFT OUTER JOIN [IQCore_AssetLocation] with(nolock) 
                ON [IQCore_Clip].[Guid] = [IQCore_AssetLocation].[_AssetGuid] 
                
        LEFT OUTER JOIN [IQCore_RootPath] with(nolock) 
                ON [IQCore_AssetLocation].[_RootPathID] = [IQCore_RootPath].ID 
        
        INNER JOIN 
        ( 
                SELECT 
                       _ClipGuid, [iQCategory],[iqClientid], [iQUser],[SubCategory1GUID],[SubCategory2GUID],[SubCategory3GUID]
                FROM 
                ( 
                    SELECT 
                         IQCore_ClipMeta._ClipGuid, IQCore_ClipMeta.Field,IQCore_ClipMeta.Value
                    FROM 
                    IQCore_ClipMeta  with(nolock)
                                                                      
                 ) AS SourceTable    
                PIVOT 
                ( 
                    MAX(Value) 
                    FOR Field IN ([iQCategory],[iqClientid], [iQUser],[SubCategory1GUID],[SubCategory2GUID],[SubCategory3GUID])

                ) AS PivotTable) as ClipMetaData 
                ON [IQCore_Clip].[Guid]=ClipMetaData._ClipGuid
        INNER JOIN [IQ_Station]
        ON [IQCore_Source].[SourceID]=IQ_Station.IQ_Station_ID  
                        
        LEFT OUTER JOIN [ArchiveClip]
        ON [IQCore_Clip].[Guid] = ArchiveClip.ClipID
		
                                                        
        WHERE [IQCore_Clip].[_UserGuid] = '07175c0e-2b70-4325-be6d-611910730968'
        AND	[ArchiveClip].ClipID IS NULL
        AND	ClipMetaData.[iqClientid] = convert(varchar(40),@ClientGuid)


		BEGIN TRANSACTION
		
		BEGIN TRY
		-- Insert records into [dbo].[ArchiveClip] table

			DECLARE @tmpArchiveClip TABLE(ID bigint,Title120 varchar(100),ClipDate date,IQ_CC_KEY varchar(255))
		
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
				Description,
				ClipCreationDate,
				CreatedBy,
				ModifiedBy,
				CreatedDate,
				ModifiedDate,
				IsActive,
				ThumbnailImagePath,
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
				Title120
			)
			OUTPUT INSERTED.ArchiveClipKey,inserted.Title120,CONVERT(Date,inserted.ClipDate),inserted.IQ_CC_Key into @tmpArchiveClip
			SELECT 
					ClipID,
					ClipLogo,
					ClipTitle,
					ClipDate,
					GMTDateTime,
					FirstName,
					LastName,
					Category,
					Keywords,		
					Description,
					ClipCreationDate,
					'System',
					'System',
					GETDATE(),
					GETDATE(),
					1,
					ThumbnailImagePath,
					ClientGUID,	
					CategoryGUID,		
					SubCategory1GUID,
					SubCategory2GUID,	
					SubCategory3GUID,	
					CustomerGUID,	
					TempResults.IQ_CC_Key,
					StartOffset,
					CASE
						WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
							Convert(varchar,CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS INT))
					ELSE 
							AUDIENCE
					END,
					
					CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
							Convert(varchar,CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* @Multiplier * 
										(
											CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN 
												@CppDayPart2Val 
											ELSE 
												(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID) 
											END
										)
											* (Cast((EndOffset - StartOffset + 1) as Decimal(18,2)) /30 )))
					ELSE
							Convert(varchar,CONVERT(DECIMAL(18,2), SQAD_SHAREVALUE * @MultiPlier * (Cast((EndOffset - StartOffset + 1) as Decimal(18,2)) /30 ))) 
					END		AS  SQAD_SHAREVALUE,
						
						
					CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
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
					TempResults.Title120
					
					
			FROM	
				@TempResults AS TempResults
					--left outer join ArchiveClip	
					--	ON TempResults.ClipID = ArchiveClip.ClipID

			
				LEFT OUTER JOIN IQ_Station
					ON LTRIM(RTRIM(Substring(TempResults.IQ_CC_KEY,1,Charindex('_', TempResults.IQ_CC_KEY)-1))) = IQ_Station.IQ_Station_ID
			
				LEFT OUTER JOIN  [IQ_NIELSEN_SQAD] as s1
					ON TempResults.IQ_CC_KEY = s1.IQ_CC_Key
					AND s1.IQ_Start_Point = CASE WHEN StartOffset = 0 THEN 1 ELSE CEILING(StartOffset /900.0) END
			
				LEFT OUTER JOIN IQ_Nielsen_Averages 
					ON IQ_Nielsen_Averages.IQ_Start_Point = CASE WHEN StartOffset = 0 THEN 1 ELSE CEILING(StartOffset /900.0) END
					AND Affil_IQ_CC_Key =  CASE WHEN IQ_Station.Dma_Num = '000' THEN IQ_Station.IQ_Station_ID ELSE Station_Affil + '_' + TimeZone END + '_' + SUBSTRING(TempResults.IQ_CC_KEY,CHARINDEX('_',TempResults.IQ_CC_KEY) +1,13)
			--where
			--	ArchiveClip.ClipID is null
			
			-- Insert records into [dbo].[IQArchive_Media] table

			DECLARE @ArchiveMedia TABLE (ID BIGINT, CategoryGUID UNIQUEIDENTIFIER, ClientGUID UNIQUEIDENTIFIER, Title120 VARCHAR(100), MediaType CHAR(2), MediaID BIGINT, ClipDate DATE,ClipTitle nvarchar(max),Station_Affil varchar(255))														
			
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
				CreatedDate
			)
			OUTPUT INSERTED.ID, INSERTED.CategoryGUID, INSERTED.ClientGUID, NULL AS Title120, INSERTED.MediaType, INSERTED._ArchiveMediaID AS MediaID, NULL AS ClipDate,inserted.Title as ClipTitle, NULL as Station_Affil INTO @ArchiveMedia
			SELECT 
					ArchiveClip.ArchiveClipKey,
					'TV',
					'TV',
					ArchiveClip.ClipTitle,
					ArchiveClip.GMTDateTime,
					ArchiveClip.CategoryGUID,
					ArchiveClip.ClientGUID,
					TempResults.CustomerGUID,
					1,
					ArchiveClip.ClipCreationDate
					
			FROM @TempResults AS TempResults
			INNER JOIN ArchiveClip
			ON ArchiveClip.ClipID = TempResults.ClipID

									 
		UPDATE @ArchiveMedia
				SET Title120=TempMedia.Title120,
					ClipDate=TempMedia.ClipDate,
					Station_Affil = IQ_Station.Station_Affil
		FROM
			@ArchiveMedia AS TempArchiveMedia
				INNER JOIN @tmpArchiveClip AS TempMedia
					ON TempArchiveMedia.MediaID=TempMedia.ID
				inner join IQ_Station	
					on IQ_Station_ID = SUBSTRING(TempMedia.IQ_CC_KEY,0 ,CHARINDEX('_',TempMedia.IQ_CC_KEY))
					


		DECLARE @MT TABLE (ArchiveMediaID BIGINT, TVID BIGINT, Title120 VARCHAR(100), ClipDate DATE, CategoryGUID UNIQUEIDENTIFIER, ClientGUID UNIQUEIDENTIFIER,ClipTitle nvarchar(max),Station_Affil Varchar(255))

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
				CONVERT(Date,ArchiveClip.ClipDate),
				ArchiveClip.CategoryGUID,
				ArchiveClip.ClientGUID,
				ArchiveClip.ClipTitle,
				TempArchiveMedia.Station_Affil
										
		FROM @ArchiveMedia AS TempArchiveMedia		
				INNER JOIN ArchiveClip 
					ON TempArchiveMedia.ClientGUID=ArchiveClip.ClientGUID
					AND	TempArchiveMedia.CategoryGUID=ArchiveClip.CategoryGUID
					AND TempArchiveMedia.ClipDate=CONVERT(Date,ArchiveClip.ClipDate)
					AND TempArchiveMedia.Title120=ArchiveClip.Title120
					AND TempArchiveMedia.MediaID!=ArchiveClip.ArchiveClipKey
					and TempArchiveMedia.ClipTitle = ArchiveClip.ClipTitle
				inner JOIN IQ_Station 
					on IQ_Station.IQ_Station_ID = SUBSTRING(ArchiveClip.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveClip.IQ_CC_Key))
					AND TempArchiveMedia.Station_Affil = IQ_Station.Station_Affil
				INNER JOIN IQArchive_Media
					ON ArchiveClip.ArchiveClipKey=IQArchive_Media._ArchiveMediaID
					AND IQArchive_Media.MediaType='TV'
					AND _ParentID IS NULL											
		WHERE 											
					IQArchive_Media.IsActive=1
			AND ArchiveClip.IsActive=1
		GROUP BY ArchiveClip.ClientGUID, ArchiveClip.CategoryGUID, CONVERT(Date,ArchiveClip.ClipDate),ArchiveClip.Title120,ArchiveClip.ClipTitle,TempArchiveMedia.Station_Affil
									
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
							and TempArchiveMedia.ClipTitle = MTbl.ClipTitle
							and TempArchiveMedia.Station_Affil = MTbl.Station_Affil
														
		UPDATE 
				IQArchive_Media
		SET
				_ParentID= CASE WHEN ID=ParentMediaID THEN NULL ELSE ParentMediaID END
		FROM
				IQArchive_Media
					INNER JOIN	@Child AS Child
						ON		IQArchive_Media.ID=Child.ArchiveMediaID
				
			
		COMMIT TRANSACTION
		
		END TRY
		
		BEGIN CATCH
			ROLLBACK TRANSACTION	
			PRINT	'ErrorNumber=' + CAST(ERROR_NUMBER() AS VARCHAR(500))
			PRINT	'ErrorSeverity=' + CAST(ERROR_SEVERITY() AS VARCHAR(500))
			PRINT	'ErrorProcedure=' + CAST(ERROR_PROCEDURE() AS VARCHAR(500))
			PRINT	'ErrorMessage=' + CAST(ERROR_MESSAGE() AS VARCHAR(500))
			
			 
			
			declare @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
			
			
			DECLARE @ClipIDs varchar(max)

			SET @ClipIDs = (SELECT CONVERT(varchar(40),t.ClipID) + ',' From  @TempResults t for xml path(''))
		
			Select 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(max),ERROR_NUMBER())+'_'+ERROR_MESSAGE() + 'ClipID XML :'+@ClipIDs,
				@CreatedBy='usp_v4_IQArvhive_Media_RefreshResultsForTV',
				@ModifiedBy='usp_v4_IQArvhive_Media_RefreshResultsForTV',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
			exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		END CATCH
		
		-- Finally send newly inserted records to calling application
		
		SELECT 
					ArchiveClip.ArchiveClipKey,
					ArchiveClip.ClipID
					
			FROM @TempResults AS TempResults
			INNER JOIN ArchiveClip
			ON ArchiveClip.ClipID = TempResults.ClipID
			
END
