
CREATE PROCEDURE [dbo].[usp_pshell_UGCAutoClip_Insert]
	
	@ClipGUID			uniqueidentifier output,
	@StartOffset		int,
	@EndOffset			int,	
	@LastModified		datetime,
	@RecordFileGuid		uniqueidentifier,
	@ClipData			XML,
	@FileLocation		varchar(2048),
	@FileName			varchar(2048),
	@IOSLocation		varchar(2048),
	@IOSRootPathID		int,	
	@Message			VARCHAR(500)  output
	
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
    Begin Transaction    
 
 BEGIN try  
		Declare @UserGuid uniqueidentifier
		
			Select @UserGuid =	
						xmldata.b.query('User').value('.', 'varchar(max)')		
							FROM
						@ClipData.nodes('/IngestionData/ClipInfo') AS xmldata(b)
		
						Declare @ClipCreationDate DateTime=GETDATE()

						SET @ClipGUID = NEWID()
						INSERT INTO IQCore_Clip(
										Guid,
										StartOffset,
										EndOffset,
										DateCreated,
										_RecordfileGuid,
										_UserGuid   
										)
								VALUES (
										@ClipGUID,
										@StartOffset,
										@EndOffset,
										@ClipCreationDate,
										@RecordFileGuid,
										@UserGuid					
									   )
						  
								Declare @Title varchar(max),
										@Keywords varchar(Max),
										@Description varchar(Max),
										@TmpCategory varchar(255)

								SELECT	
										@Title=xmldata.b.query('Title').value('.','varchar(max)'),
										@Description=xmldata.b.query('Description').value('.', 'Varchar(max)'),
										@TmpCategory=xmldata.b.query('Category').value('.','Varchar(255)'),
										@Keywords=xmldata.b.query('Keywords').value('.','Varchar(max)')
									FROM
										@ClipData.nodes('/IngestionData/ClipInfo') AS xmldata(b)

		
								INSERT INTO IQCore_ClipInfo
								(
									_ClipGuid,
									Title,
									[Description],
									Category,
									Keywords	
								)												
								Values
								(							
									@ClipGUID,
									@Title,
									@Description,
									@TmpCategory,
									@Keywords
								)
				
					DECLARE @Location xml;
					SET @Location = N'<Meta Key="FileLocation" Value="'+@FileLocation+'" />
									  <Meta Key="FileName" Value="'+@FileName+'" />
									  <Meta Key="IOSLocation" Value="'+@IOSLocation+'" />
									  <Meta Key="IOSRootPathID" Value="'+CONVERT(varchar,@IOSRootPathID)+'" />
									  <Meta Key="NoOfTimesDownloaded" Value="0" />';
									  
					SET @ClipData.modify('insert sql:variable("@Location") into (/IngestionData/ClipInfo/MetaData)[1]') 
				
				
					INSERT INTO IQCore_ClipMeta
					(
						_ClipGuid,
						Field,
						Value
					)
					SELECT 
							@ClipGUID, 
							xmldata.b.value('@Key', 'varchar(max)'),
							xmldata.b.value('@Value', 'varchar(max)')
					FROM 
							@ClipData.nodes('/IngestionData/ClipInfo/MetaData/Meta') AS xmldata(b)
						
						
					Declare @ClientGUID		uniqueidentifier,
							@CategoryGUID	uniqueidentifier,
							@CustomerGUID	uniqueidentifier,
							@SubCategory1GUID	uniqueidentifier,
							@SubCategory2GUID	uniqueidentifier,
							@SubCategory3GUID	uniqueidentifier

					SELECT 
							@CategoryGUID = [iQCategory],
							@ClientGUID = [iQClientid],
							@CustomerGUID = [iQUser],
							@SubCategory1GUID = CASE WHEN LTRIM(RTRIM([SubCategory1GUID]))='' THEN NULL ELSE [SubCategory1GUID] END,
							@SubCategory2GUID = CASE WHEN LTRIM(RTRIM([SubCategory2GUID]))='' THEN NULL ELSE [SubCategory2GUID] END,
							@SubCategory3GUID = CASE WHEN LTRIM(RTRIM([SubCategory3GUID]))='' THEN NULL ELSE [SubCategory3GUID] END
					FROM
						(
						  SELECT
				
									[Field],
									[VALUE]
						  FROM
									[IQCore_Clipmeta] with(nolock)
						  WHERE	
									[_Clipguid]=@ClipGUID
						) AS SourceTable
						PIVOT
						(
							MAX(VALUE)
							FOR Field IN ([iQCategory],[iQClientid],[iQUser],[SubCategory1GUID],[SubCategory2GUID],[SubCategory3GUID])
						) AS PivotTable

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
								ON	[IQCore_Recordfile].[Guid]=@RecordFileGuid
								AND	[IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID] 
					
        
							INNER JOIN [IQCore_Source] WITH(NOLOCK) 
								ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid] 
					
					DECLARE @ClipMediaDate DATETIME,
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
					
						@Title120=(SELECT  IQ_SSP.title120 FROM IQ_SSP WHERE 
							IQ_CC_Key =   @IQCCKey
							AND IQ_Start_Minute = (
									SELECT 
										CASE WHEN MAX(IQ_Start_Minute) IS NULL THEN 
											(SELECT MIN(IQ_Start_Minute) FROM  IQ_SSP WHERE IQ_CC_Key = @IQCCKey)  
										ELSE 
											MAX(IQ_Start_Minute) END AS IQ_Start_Minute 
									FROM 
										IQ_SSP 
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
						@ClipCreationDate,
						'System',
						'System',
						@ClipCreationDate,
						@ClipCreationDate,
						1,
						@ClientGUID,
						@CategoryGUID,
						@SubCategory1GUID,
						@SubCategory2GUID,
						@SubCategory3GUID,
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
				SELECT 
						TmpArchiveClip.ID,
						'TV',
						'TV',
						@Title,
						@StartDate,
						@CategoryGUID,
						@ClientGUID,
						@CustomerGUID,
						1,
						@ClipCreationDate,
						'TV',
						'TV'
					
				FROM @tmpArchiveClip AS TmpArchiveClip
   
				SET @Message='Record inserted successfully.' 
	COMMIT Transaction  
	
 END TRY  
   
 
 BEGIN CATCH
 SET @ClipGUID=Null  
  Set @Message='Error: '+ERROR_MESSAGE()+' Procedure:'+ERROR_PROCEDURE()+' Line:'+ CONVERT(varchar,ERROR_LINE())  
   IF @@TRANCOUNT > 0  
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
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_pshell_UGCAutoClip_Insert',
				@ModifiedBy='usp_pshell_UGCAutoClip_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
  
 END CATCH		
 
    
END