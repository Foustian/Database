CREATE PROCEDURE [dbo].[usp_v5_svc_Report_Discovery_Insert]
(
		@ReportID BIGINT,
		@XML XML
)		
AS
BEGIN

	DECLARE @StopWatch DATETIME, @SPStartTime DATETIME,@SPTrackingID UNIQUEIDENTIFIER, @TimeDiff DECIMAL(18,2),@SPName VARCHAR(100),@QueryDetail VARCHAR(500)
 
	SET @SPStartTime=GETDATE()
	SET @Stopwatch=GETDATE()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v5_svc_Report_Discovery_Insert'     

    BEGIN TRANSACTION
	BEGIN TRY	
	
	DECLARE @OtherOnlineAdRate DECIMAL(18,2)
	DECLARE @CompeteMultiplier DECIMAL(18,2)
	DECLARE @OnlineNewsAdRate DECIMAL(18,2)
	DECLARE @URLPercentRead DECIMAL(18,2)
	DECLARE @AutoClipDuration INT
	DECLARE @CompeteAudienceMultiplier DECIMAL(18,2)
	DECLARE @HasTVRecords BIT
	DECLARE @HasNMRecords BIT
	DECLARE @HasSMRecords BIT
	DECLARE @HasPQRecords BIT

	SET @OtherOnlineAdRate = 1 
	SET @CompeteMultiplier = 1 
	SET @OnlineNewsAdRate= 1 
	SET @URLPercentRead = 1
	SET @CompeteAudienceMultiplier = 1
	
	SELECT @HasTVRecords = @xml.exist('MediaData/TV/SubMedia')
	SELECT @HasNMRecords = @xml.exist('MediaData/NM/SubMedia')
	SELECT @HasSMRecords = @xml.exist('MediaData/SM/SubMedia')
	SELECT @HasPQRecords = @xml.exist('MediaData/PQ/SubMedia')

	
	DECLARE @ClientGuid UNIQUEIDENTIFIER
	
	SELECT @ClientGuid =  ClientGuid FROM IQReport_Discovery WHERE ID = @ReportID

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
				AND IQClient_CustomSettings.Field IN ('OtherOnlineAdRate','CompeteMultiplier','OnlineNewsAdRate','URLPercentRead','AutoClipDuration','CompeteAudienceMultiplier')
	)
 
	SELECT 
		@OtherOnlineAdRate = [OtherOnlineAdRate],
		@CompeteMultiplier = [CompeteMultiplier],
		@OnlineNewsAdRate	=		[OnlineNewsAdRate],
		@URLPercentRead		 =	[URLPercentRead],
		@AutoClipDuration = [AutoClipDuration],
		@CompeteAudienceMultiplier = [CompeteAudienceMultiplier]
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
			FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead],[AutoClipDuration],[CompeteAudienceMultiplier])
		) AS PivotTable	
	
		DECLARE @CurrentDate DATETIME  = GETDATE()
		DECLARE @Multiplier FLOAT
		SELECT @Multiplier = CONVERT(FLOAT,ISNULL(
								(SELECT VALUE FROM 
									IQClient_CustomSettings 
								WHERE
								 Field = 'Multiplier' AND _ClientGuid = (SELECT ClientGuid FROM IQReport_Discovery WHERE ID = @ReportID)),
								 (SELECT VALUE FROM IQClient_CustomSettings WHERE Field = 'Multiplier' 
								 AND _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))

	DECLARE @CppDayPart2Val FLOAT
	SELECT @CppDayPart2Val = cppvalue FROM IQ_SQAD WHERE daypartid = 2 AND SQADMarketID = 997

	SET @QueryDetail ='get all settings of report for client'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()		
								 
	DECLARE @tempTable TABLE(id BIGINT,mediaType VARCHAR(2),title NVARCHAR(MAX),mediaDate DATETIME,submediaType VARCHAR(50),
								categoryGuid UNIQUEIDENTIFIER, clientGuid UNIQUEIDENTIFIER, customerGuid UNIQUEIDENTIFIER,ArticleID VARCHAR(50),startOffset BIGINT,
								endoffset BIGINT,highlightingText NVARCHAR(MAX),positiveSentiment TINYINT, negativeSentiment TINYINT, Title120 VARCHAR(100), 
								ClipDate DATE,IQ_CC_Key VARCHAR(50),SearchTerm VARCHAR(500),content NVARCHAR(MAX), v5MediaType VARCHAR(2), v5SubMediaType VARCHAR(50), rollupType varchar(50), dataModelType varchar(10))
	
	IF @HasNMRecords = 1
	BEGIN
	DECLARE @NMRoothPathID BIGINT
	SELECT @NMRoothPathID =
							IQCore_RootPath.ID
					FROM
							IQCore_RootPath
								INNER JOIN IQCore_RootPathType
									ON IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
					WHERE
							IQCore_RootPathType.Name='NM'
					ORDER BY
							NEWID()
	
								--==============================================
								-- IQCore_NM
								--==============================================
								MERGE INTO IQCore_NM  AS target
								 USING (
										 SELECT 
											DISTINCT
											ReportXML.NM.query('ArticleID').value('.','varchar(max)') AS ArticleID,
											ReportXML.NM.query('Url').value('.','varchar(max)') AS Url,
											ReportXML.NM.query('harvest_time').value('.','datetime') AS HarvestTime,
											'QUEUED' AS [Status],
											@NMRoothPathID AS RootPathID,
											@CurrentDate AS LastModified									
										 FROM 
											@xml.nodes('/MediaData/NM/SubMedia') AS ReportXML(NM)
									) AS source ON source.ArticleID = target.ArticleID
								WHEN NOT MATCHED THEN
									INSERT 
										(
											ArticleID,
											Url,
											harvest_time,
											[Status],
											_RootPathID,
											LastModified									
										)
										VALUES
										(
											ArticleID,
											Url,
											HarvestTime,
											[Status],
											RootPathID,
											LastModified
										);	
								
								
	 SET @QueryDetail ='insert into iqcore nm from xml using left join iqcore nm table'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()								
								
								
								--==============================================
								--ArchiveNM
								--==============================================
								MERGE INTO ArchiveNM  AS target
								USING (
									SELECT 
									
										ReportXML.NM.query('Title').value('.','nvarchar(max)') AS Title,
										IQReport_Discovery.Keywords,
										IQReport_Discovery.[Description],
										ReportXML.NM.query('harvest_time').value('.','datetime') AS Harvest_Time,
										Customer.FirstName,
										Customer.LastName,
										IQReport_Discovery.CustomerGuid,
										IQReport_Discovery.ClientGuid,
										IQReport_Discovery.CategoryGuid,
										ReportXML.NM.query('ArticleID').value('.','varchar(max)') AS ArticleID,
										ReportXML.NM.query('Url').value('.','varchar(max)') AS Url,
										ReportXML.NM.query('Publication').value('.','varchar(max)') AS Publication,
										ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') AS CompeteUrl,
										CASE 
											WHEN 
												(ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'facebook.com' OR ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'twitter.com' OR ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'friendfeed.com') 
													THEN -1
											ELSE
												ROUND((c_uniq_visitor * @CompeteAudienceMultiplier)/30,0)
											END AS c_uniq_visitor,
										CASE 
											WHEN 
												(ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'facebook.com' OR ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'twitter.com' OR ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'friendfeed.com') 
													THEN -1			 
										ELSE
											(((CONVERT(DECIMAL(18,2),c_uniq_visitor)/30)*@CompeteMultiplier * @CompeteAudienceMultiplier * (CONVERT(DECIMAL(18,2),@URLPercentRead)/100))/1000) * @OnlineNewsAdRate * ReportXML.NM.query('ProminenceMultiplier').value('.','decimal(18,6)')
										END AS IQ_AdShare_Value,
										CASE WHEN (ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'facebook.com' OR ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'twitter.com' OR ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = 'friendfeed.com') THEN
											NULL
										ELSE
											results
										END AS Compete_Result,
										ReportXML.NM.query('PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
										ReportXML.NM.query('NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
										ReportXML.NM.query('IQLicense').value('.','tinyint') AS IQLicense,
										ReportXML.NM.query('SearchTerm').value('.','varchar(500)') AS SearchTerm,
										ReportXML.NM.query('Number_Hits').value('.','tinyint') AS Number_Hits,
										ReportXML.NM.query('HighlightingText').value('.','nvarchar(max)') AS HighlightingText,
										ReportXML.NM.query('MediaType').value('.','varchar(2)') as MediaType,
										ReportXML.NM.query('SubMediaType').value('.','varchar(50)') as SubMediaType,
										ReportXML.NM.query('DataModelType').value('.','varchar(10)') as DataModelType
									
								 FROM 
									@xml.nodes('/MediaData/NM/SubMedia') AS ReportXML(NM)
								
									INNER JOIN IQReport_Discovery WITH (NOLOCK)
									ON IQReport_Discovery.ID = @ReportID
								
									INNER JOIN Customer
									ON IQReport_Discovery.CustomerGuid = Customer.CustomerGuid
								
									LEFT OUTER JOIN IQ_CompeteAll
									ON ReportXML.NM.query('CompeteUrl').value('.','varchar(max)') = IQ_CompeteAll.CompeteURL
								) AS source ON source.ArticleID = target.ArticleID AND source.ClientGuid = target.ClientGUID
							WHEN NOT MATCHED THEN
								
								INSERT 
								(
									Title,	
									Keywords,
									Description,								
									Harvest_Time,								
									FirstName,
									LastName,
									CustomerGuid,
									ClientGuid,
									CategoryGuid,									
									ArticleID,
									Url,
									Publication,
									CompeteUrl,
									IsActive,
									CreatedDate,
									ModifiedDate,
									Compete_Audience,
									IQAdshareValue,
									Compete_Result,
									PositiveSentiment,
									NegativeSentiment,
									IQLicense,
									Number_Hits,
									HighlightingText,
									v5SubMediaType
								)
								VALUES
								(
									Title,
									Keywords,
									Description,
									harvest_time,
									FirstName,
									LastName,
									CustomerGuid,
									ClientGuid,
									CategoryGuid,
									ArticleID,
									Url,
									Publication,
									CompeteUrl,
									1,
									@CurrentDate,
									@CurrentDate,
									c_uniq_visitor,
									IQ_AdShare_Value,
									Compete_Result,
									PositiveSentiment,
									NegativeSentiment,
									IQLicense,
									Number_Hits,
									HighlightingText,
									SubMediaType
								)
								
								OUTPUT INSERTED.ArchiveNMKey AS 'id','NM' AS 'mediaType',INSERTED.Title AS 'title',INSERTED.Harvest_Time AS 'mediaDate','NM' AS 'submediaType',
										INSERTED.CategoryGuid 'categoryGuid',
										INSERTED.ClientGuid AS 'clientGuid',INSERTED.CustomerGuid AS 'customerGuid',
										INSERTED.ArticleID AS 'ArticleID',NULL AS 'startOffset',NULL AS 'endoffset',INSERTED.HighlightingText AS 'highlightingText',
										INSERTED.PositiveSentiment AS 'positiveSentiment',INSERTED.NegativeSentiment AS 'negativeSentiment', NULL AS Title120, NULL AS ClipDate, NULL AS IQ_CC_Key,source.SearchTerm, NULL AS 'content',
										source.MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', 'NM' as 'rollupType', source.DataModelType as 'dataModelType'
										INTO @tempTable;
								
	SET @QueryDetail ='insert into archivenm from xml using left join archivenm table'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()															 
	END							
								
	IF @HasSMRecords = 1
	BEGIN
	DECLARE @SMRoothPathID BIGINT
	SELECT @SMRoothPathID =
							IQCore_RootPath.ID
					FROM
							IQCore_RootPath
								INNER JOIN IQCore_RootPathType
									ON IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
					WHERE
							IQCore_RootPathType.Name='SM'
					ORDER BY
							NEWID()
								--==============================================
								--IQCore SM
								--==============================================
								MERGE INTO IQCore_SM  AS target
								 USING (
										 SELECT 
											DISTINCT
											ReportXML.SM.query('ArticleID').value('.','varchar(max)') AS ArticleID,
											ReportXML.SM.query('Url').value('.','varchar(max)') AS Url,
											ReportXML.SM.query('harvest_time').value('.','datetime') AS HarvestTime,
											'QUEUED' AS [Status],
											@SMRoothPathID AS RootPathID,
											@CurrentDate AS LastModified									
										 FROM 
											@xml.nodes('/MediaData/SM/SubMedia') AS ReportXML(SM)
									) AS source ON source.ArticleID = target.ArticleID
								WHEN NOT MATCHED THEN
									INSERT 
										(
											ArticleID,
											Url,
											harvest_time,
											[Status],
											_RootPathID,
											LastModified									
										)
										VALUES
										(
											ArticleID,
											Url,
											HarvestTime,
											[Status],
											RootPathID,
											LastModified
										);

	SET @QueryDetail ='insert into iqcore sm from xml using left join iqcore sm table'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()															 
								
								--==============================================
								--ArchiveSM
								--==============================================								
								MERGE INTO ArchiveSM  AS target 
								USING (
									SELECT 
							
										ReportXML.SM.query('Title').value('.','nvarchar(max)') AS Title,
										IQReport_Discovery.Keywords,
										IQReport_Discovery.[Description],
										ReportXML.SM.query('harvest_time').value('.','datetime') AS harvest_time,
										Customer.FirstName,
										Customer.LastName,
										IQReport_Discovery.CustomerGuid,
										IQReport_Discovery.ClientGuid,
										IQReport_Discovery.CategoryGuid,
										ReportXML.SM.query('ArticleID').value('.','varchar(max)') AS ArticleID,
										ReportXML.SM.query('Url').value('.','varchar(max)') AS Url,
										ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') AS CompeteUrl,
										ReportXML.SM.query('SubMediaType').value('.','varchar(max)') AS SubMediaType,
										CASE 
											WHEN 
												(
												(ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'facebook.com' OR ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'twitter.com' OR ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'friendfeed.com') 
												OR
												IQ_MediaTypes.UseAudience = 0
												)
													THEN -1
											ELSE
												ROUND((c_uniq_visitor * @CompeteAudienceMultiplier/30),0)
											END AS c_uniq_visitor,

										CASE 
											WHEN 
												(
												(ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'facebook.com' OR ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'twitter.com' OR ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'friendfeed.com') 
												OR
												IQ_MediaTypes.UseMediaValue = 0
												)
													THEN -1			 
										ELSE
											(((CONVERT(DECIMAL(18,2),c_uniq_visitor)/30)* @CompeteMultiplier * @CompeteAudienceMultiplier * (CONVERT(DECIMAL(18,2),@URLPercentRead)/100))/1000) * @OtherOnlineAdRate * ReportXML.SM.query('ProminenceMultiplier').value('.','decimal(18,6)')
										END AS IQ_AdShare_Value,

										CASE WHEN ((ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'facebook.com' OR ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'twitter.com' OR ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = 'friendfeed.com')  OR (IQ_MediaTypes.UseAudience = 0 AND IQ_MediaTypes.UseMediaValue = 0)) THEN
											NULL
										ELSE
											results
										END AS Compete_Result,
										ReportXML.SM.query('homeLink').value('.','varchar(max)') AS homeLink,
										ReportXML.SM.query('PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
										ReportXML.SM.query('NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
										ReportXML.SM.query('SearchTerm').value('.','varchar(500)') AS SearchTerm,
										ReportXML.SM.query('Number_Hits').value('.','tinyint') AS Number_Hits,
										ReportXML.SM.query('HighlightingText').value('.','nvarchar(max)') AS HighlightingText,
										ReportXML.SM.query('MediaType').value('.','varchar(50)') as MediaType,
										ReportXML.SM.query('DataModelType').value('.','varchar(10)') as DataModelType
									
								 FROM 
									@xml.nodes('/MediaData/SM/SubMedia') AS ReportXML(SM)
								
									INNER JOIN IQReport_Discovery WITH (NOLOCK)
									ON IQReport_Discovery.ID = @ReportID
								
									INNER JOIN Customer
									ON IQReport_Discovery.CustomerGuid = Customer.CustomerGuid

									INNER JOIN IQ_MediaTypes
									ON IQ_MediaTypes.SubMediaType = ReportXML.SM.query('SubMediaType').value('.','varchar(50)')
								
									LEFT OUTER JOIN IQ_CompeteAll
									ON ReportXML.SM.query('CompeteUrl').value('.','varchar(max)') = IQ_CompeteAll.CompeteURL
									
								) AS source ON source.ArticleID = target.ArticleID AND source.ClientGUID = target.ClientGUID
								WHEN NOT MATCHED THEN
								INSERT
								(
									Title,	
									Keywords,
									Description,								
									Harvest_Time,								
									FirstName,
									LastName,
									CustomerGuid,
									ClientGuid,
									CategoryGuid,									
									ArticleID,									
									Url,
									CompeteUrl,
									IsActive,
									Source_Category,
									CreatedDate,
									ModifiedDate,
									Compete_Audience,
									IQAdshareValue,
									Compete_Result,
									homelink,
									PositiveSentiment,
									NegativeSentiment,
									Number_Hits,
									HighlightingText,
									v5SubMediaType
								)
								VALUES
								(
									Title,	
									Keywords,
									Description,								
									Harvest_Time,								
									FirstName,
									LastName,
									CustomerGuid,
									ClientGuid,
									CategoryGuid,									
									ArticleID,									
									Url,
									CompeteUrl,
									1,
									SubMediaType,
									@CurrentDate,
									@CurrentDate,
									c_uniq_visitor,
									IQ_AdShare_Value,
									Compete_Result,
									homelink,
									PositiveSentiment,
									NegativeSentiment,
									Number_Hits,
									HighlightingText,
									SubMediaType
								)
								
								OUTPUT INSERTED.ArchiveSMKey AS 'id','SM' AS 'mediaType',INSERTED.Title AS 'title',INSERTED.Harvest_Time AS 'mediaDate',
										INSERTED.Source_Category AS 'submediaType',INSERTED.CategoryGuid AS 'categoryGuid',
										INSERTED.ClientGuid AS 'clientGuid',INSERTED.CustomerGuid AS 'customerGuid',
										INSERTED.ArticleID AS 'ArticleID',NULL AS 'startOffset',NULL AS 'endoffset',INSERTED.HighlightingText AS 'highlightingText',
										INSERTED.PositiveSentiment AS 'positiveSentiment',INSERTED.NegativeSentiment AS 'negativeSentiment', NULL AS Title120, NULL AS ClipDate, NULL AS IQ_CC_Key,source.SearchTerm, NULL AS 'content',
										source.MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', null as 'rollupType', source.DataModelType as 'dataModelType'
										
										INTO @tempTable;
										
	SET @QueryDetail ='insert into arhive sm from xml using left join archive sm table'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()															 									
	END										 																				
				
	IF @HasTVRecords = 1	
	BEGIN			
								--==============================================
								-- IQCore_Clip
								--==============================================
								
								
								DECLARE @tempTVTable TABLE (coreClipGuid UNIQUEIDENTIFIER,startOffset BIGINT,endOffset BIGINT,
															recordFileGuid UNIQUEIDENTIFIER,dateCreated DATETIME,averagesIQCCKEY VARCHAR(MAX),squadIQCCKEY VARCHAR(MAX),
															title VARCHAR(MAX),IQStation VARCHAR(20),PositiveSentiment TINYINT,NegativeSentiment TINYINT,SearchTerm VARCHAR(500),Number_Hits TINYINT,HighlightingText NVARCHAR(MAX),
															v5MediaType VARCHAR(2), v5SubMediaType VARCHAR(50), DataModelType VARCHAR(10))
								
								DECLARE @ReportTitle VARCHAR(MAX)
								DECLARE @ReportKeywords VARCHAR(MAX)
								DECLARE @ReportDesc VARCHAR(MAX)
								DECLARE @ReportClientGuid UNIQUEIDENTIFIER
								DECLARE @ReportCustomerGuid UNIQUEIDENTIFIER
								DECLARE @ReportCategoryGuid UNIQUEIDENTIFIER
								
								
								SELECT 
								
									@ReportTitle = Title,
									@ReportKeywords = Keywords,
									@ReportDesc = [Description],
									@ReportClientGuid = ClientGuid,
									@ReportCustomerGuid = CustomerGuid,
									@ReportCategoryGuid = CategoryGuid								
									
								FROM 
									IQReport_Discovery
								WHERE
									ID = @ReportID


								DECLARE @TmpCoreClip TABLE (StartOffset INT, EndOffset INT, _RecordfileGuid UNIQUEIDENTIFIER)	
								
								INSERT INTO @TmpCoreClip
								(
									StartOffset,
									EndOffset,
									_RecordfileGuid
								)
								SELECT										
										DISTINCT
										CASE 
											WHEN
												(CAST(ReportXML.TV.query('StartOffset').value('.','bigint') AS INT) - 8) >= 0
											THEN
												CAST(ReportXML.TV.query('StartOffset').value('.','bigint') AS INT) - 8
											ELSE
												0
										END
											,
										CASE 
											WHEN
												(CAST(ReportXML.TV.query('StartOffset').value('.','bigint') AS INT) - 8) >= 0
											THEN
												(CAST(ReportXML.TV.query('StartOffset').value('.','bigint') AS INT) - 8) + @AutoClipDuration - 1
											ELSE
												@AutoClipDuration - 1
										END,									
										ReportXML.TV.query('VideoGUID').value('.','uniqueidentifier')										
		
								FROM									
										@xml.nodes('/MediaData/TV/SubMedia') AS ReportXML(TV)


	 SET @QueryDetail ='populate @TmpCoreClip table from xml'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()															 																				

								MERGE INTO IQCore_Clip  AS target
								 USING (
										 SELECT 
											NEWID() AS ClipGuid,
											StartOffset,
											EndOffset,
											@CurrentDate AS DateCreated,
											_RecordfileGuid,
											'07175C0E-2B70-4325-BE6D-611910730968' AS UserGuid
										 FROM 
											@TmpCoreClip
									) AS source ON 
										source._RecordfileGUID = target._RecordfileGuid
										AND source.StartOffset = target.StartOffset
										AND source.EndOffset = target.EndOffset
										AND EXISTS (SELECT NULL
														FROM IQCore_ClipMeta WITH (NOLOCK)
														WHERE target.Guid = IQCore_ClipMeta._ClipGuid
														AND IQCore_ClipMeta.Field = 'IQClientID'
														AND IQCore_ClipMeta.Value = @ClientGuid)
								WHEN NOT MATCHED THEN
									INSERT 
										(
											GUID,
											StartOffset,
											EndOffset,
											DateCreated,
											_RecordfileGuid,
											_UserGuid								
										)
										VALUES
										(
											ClipGuid,
											StartOffset,
											EndOffset,
											DateCreated,
											_RecordfileGuid,
											UserGuid
										)

								OUTPUT INSERTED.GUID AS 'coreClipGuid',INSERTED.StartOffset AS 'startOffset',INSERTED.EndOffset AS 'endOffset',
								INSERTED._RecordfileGuid AS 'recordFileGuid',INSERTED.dateCreated AS 'dateCreated',NULL AS 'averagesIQCCKEY',
								NULL AS 'squadIQCCKEY',
								NULL AS 'title',
								NULL AS 'IQStation',
								NULL AS 'PositiveSentiment',
								NULL AS 'NegativeSentiment',
								NULL AS 'SearchTerm',
								NULL AS 'Number_Hits',
								NULL AS 'HighlightingText',
								NULL AS 'v5MediaType',
								NULL AS 'v5SubMediaType',
								NULL AS 'DataModelType' INTO @tempTVTable;
									
	SET @QueryDetail ='insert records into iqcore_clip table using from @tempCoreClip'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()		
								
								--==============================================
								-- Update TempTVTable with Squad IQCCKEY,averages IQCCKEY , Title and IQ Station
								--==============================================
								UPDATE @tempTVTable
								SET title = ReportXML.TV.query('Title').value('.','varchar(max)'),
								averagesIQCCKEY = CASE 
											WHEN 
												ReportXML.TV.query('IQ_DMA').value('.','varchar(max)') = '000' 
											THEN 
												IQ_Station_ID 
											ELSE 
												Station_Affil + '_' + TimeZone 
										END 
											+ '_' + SUBSTRING(ReportXML.TV.query('IQ_CC_KEY').value('.','varchar(max)'),CHARINDEX('_',ReportXML.TV.query('IQ_CC_KEY').value('.','varchar(max)')) +1,13),
											
										squadIQCCKEY = ReportXML.TV.query('IQ_CC_KEY').value('.','varchar(max)'),											
											
										IQStation = SUBSTRING(ReportXML.TV.query('IQ_CC_KEY').value('.','varchar(max)'),1,CHARINDEX('_',ReportXML.TV.query('IQ_CC_KEY').value('.','varchar(max)'))-1),
										PositiveSentiment = ReportXML.TV.query('PositiveSentiment').value('.','tinyint'),
										NegativeSentiment = ReportXML.TV.query('NegativeSentiment').value('.','tinyint'),
										SearchTerm = ReportXML.TV.query('SearchTerm').value('.','varchar(500)'),
										Number_Hits =ReportXML.TV.query('Number_Hits').value('.','tinyint'),
										HighlightingText = ReportXML.TV.query('HighlightingText').value('.','nvarchar(max)'),
										v5MediaType = ReportXML.TV.query('MediaType').value('.','varchar(2)'),
										v5SubMediaType = ReportXML.TV.query('SubMediaType').value('.','varchar(50)'),
										DataModelType = ReportXML.TV.query('DataModelType').value('.','varchar(10)')

								FROM
									@xml.nodes('/MediaData/TV/SubMedia') AS ReportXML(TV)
									
									INNER JOIN @tempTVTable t
									ON ReportXML.TV.query('VideoGUID').value('.','uniqueidentifier') = t.recordFileGuid
									
									INNER JOIN IQCore_Clip WITH (NOLOCK)
										ON t.coreClipGuid = IQCore_Clip.Guid
										
										LEFT OUTER JOIN IQ_Station
										ON SUBSTRING(ReportXML.TV.query('IQ_CC_KEY').value('.','varchar(max)'),1,CHARINDEX('_',ReportXML.TV.query('IQ_CC_KEY').value('.','varchar(max)'))-1) = IQ_station.IQ_Station_ID
								
		SET @QueryDetail ='update @tempTVTable for title , station and iqcckey '
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()									


								--==============================================
								-- IQCore_ClipInfo
								--==============================================
																
										
										INSERT INTO IQCore_ClipInfo
										(
											_ClipGuid,
											Title,
											[Description],
											Category,
											Keywords
										)
										SELECT 
											coreClipGuid,
											@ReportTitle,
											@ReportDesc,
											'PR',
											@ReportKeywords
										FROM
											@tempTVTable
										
										
										INSERT INTO IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											VALUE
										)
										SELECT
											coreClipGuid,
											'IQUser',
											@ReportCustomerGuid
										FROM
											@tempTVTable
											
										
										INSERT INTO IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											VALUE
										)	
										SELECT
											coreClipGuid,
											'IQclientID',
											@ReportClientGuid
										FROM
											@tempTVTable
											
										INSERT INTO IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											VALUE
										)	
										SELECT
											coreClipGuid,
											'IQCategory',
											@ReportCategoryGuid
										FROM
											@tempTVTable
								
	 SET @QueryDetail ='insert into clip info and clip meta tables'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()									

										MERGE INTO ArchiveClip AS target
										USING (
											SELECT 
												DISTINCT
												t.coreClipGuid,
												'http://media.iqmediacorp.com/logos/stations/small/' + CAST([IQCore_Source].[Logo] AS VARCHAR(200)) AS ClipLogo,
												t.title,
												[dbo].fnGetClipAdjustedDateTime([IQCore_Recording].[StartDate],IQ_Station.gmt_adj,IQ_Station.dst_adj,t.startOffset) AS ClipDate,
												IQCore_Recording.StartDate AS GMTDateTime,
												Customer.FirstName,
												Customer.LastName,
												'PR' AS Category,
												@ReportKeywords AS Keywords,
												@ReportDesc AS [Description],
												t.dateCreated,
												REPLACE([IQCore_RootPath].[StreamSuffixPath] + [IQCore_AssetLocation].[Location],'\','/') AS ThumbnailImagePath,
												@ReportClientGuid AS ClientGuid,
												@ReportCategoryGuid AS CategoryGuid,
												@ReportCustomerGuid AS CustomerGuid,
												
												LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) + 
												'_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00' AS IQ_CC_Key,
												t.startOffset,
												CASE
													WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
														CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS INT)
													ELSE 
														AUDIENCE
													END
												AS AUDIENCE,

												CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
													CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* @MultiPlier * (CONVERT(DECIMAL(18,2),(t.endOffset - t.startOffset + 1)) /30 ) * 
														CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN
															@CppDayPart2Val
														ELSE
															(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)
														END
													)
												ELSE
													CONVERT(DECIMAL(18,2), SQAD_SHAREVALUE * @MultiPlier * (CONVERT(DECIMAL(18,2),(t.endOffset - t.startOffset + 1)) /30 ))
												END
												AS  SQAD_SHAREVALUE,
												
												CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
													CASE WHEN CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* @MultiPlier * (CONVERT(DECIMAL(18,2),(t.endOffset - t.startOffset + 1)) /30 ) *
																CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN
																	@CppDayPart2Val
																ELSE
																	(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)
																END
															) IS NULL THEN 
														NULL
													ELSE
														'E'
													END
												ELSE
													'A'
												END AS Nielsen_Result,												
												t.PositiveSentiment AS PositiveSentiment,
												t.NegativeSentiment AS NegativeSentiment,
												(SELECT  TOP 1  IQ_SSP.title120 FROM IQ_SSP WHERE 
													IQ_CC_Key =   t.squadIQCCKEY
													AND IQ_Start_Minute = (
															SELECT 
																CASE WHEN MAX(IQ_Start_Minute) IS NULL THEN 
																	(SELECT MIN(IQ_Start_Minute) FROM  IQ_SSP WHERE IQ_CC_Key = t.squadIQCCKEY)  
																ELSE 
																	MAX(IQ_Start_Minute) END AS IQ_Start_Minute 
															FROM 
																IQ_SSP 
															WHERE IQ_CC_Key = t.squadIQCCKEY
															AND (IQ_Start_Minute * 60) <=  t.startOffset
													)
												) AS Title120,
												t.SearchTerm,
												t.Number_Hits,
												t.HighlightingText,
												t.v5MediaType,
												t.v5SubMediaType,
												t.DataModelType
												
										 FROM 
											
											@tempTVTable t
																						
											INNER JOIN Customer
											ON Customer.CustomerGuid = @ReportCustomerGuid
											
											INNER JOIN [IQCore_Recordfile] WITH (NOLOCK)
											ON [IQCore_Recordfile].[Guid] = t.RecordfileGuid
											
											INNER JOIN [IQCore_Recording] WITH (NOLOCK)
											ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
											
											INNER JOIN [IQCore_Source] WITH (NOLOCK)
											ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
									
											LEFT OUTER JOIN [IQCore_AssetLocation] WITH (NOLOCK)
											ON t.coreClipGuid = [IQCore_AssetLocation].[_AssetGuid]
											
											LEFT OUTER JOIN [IQCore_RootPath]
											ON [IQCore_AssetLocation].[_RootPathID] = [IQCore_RootPath].ID						
												
											INNER JOIN IQ_Station
											ON t.IQStation = IQ_station.IQ_Station_ID
											
											LEFT OUTER JOIN	[IQ_NIELSEN_SQAD] WITH (NOLOCK)
											ON t.squadIQCCKEY = [IQ_NIELSEN_SQAD] .IQ_CC_Key
											AND [IQ_NIELSEN_SQAD].IQ_Start_Point= CASE WHEN t.startOffset = 0 THEN 1 ELSE CEILING(t.startOffset /900.0) END
											
											LEFT OUTER JOIN 
											IQ_Nielsen_Averages WITH (NOLOCK)
											ON [IQ_NIELSEN_SQAD].iq_cc_key IS NULL
											AND IQ_Nielsen_Averages.IQ_Start_Point = CASE WHEN t.startOffset = 0 THEN 1 ELSE CEILING(t.startOffset /900.0) END
											AND Affil_IQ_CC_Key = t.averagesIQCCKEY
											
										) AS source ON (1=0)
										WHEN NOT matched THEN
											INSERT 
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
												IsActive,
												ThumbnailImagePath,
												ClientGUID,
												CategoryGUID,												
												CustomerGUID,												
												IQ_CC_Key,
												StartOffset,												
												Nielsen_Audience,
												IQAdShareValue,
												Nielsen_Result,
												CreatedDate,
												ModifiedDate,
												PositiveSentiment,
												NegativeSentiment,
												Title120,
												Number_Hits,
												HighlightingText,
												v5SubMediaType
											)
											VALUES
											(
												coreClipGuid,
												ClipLogo,
												title,
												ClipDate,
												GMTDateTime,
												FirstName,
												LastName,
												Category,
												Keywords,
												[Description],
												dateCreated,
												1,
												ThumbnailImagePath,
												ClientGuid,
												CategoryGuid,
												CustomerGuid,
												IQ_CC_Key,
												startOffset,
												AUDIENCE,
												SQAD_SHAREVALUE,
												Nielsen_Result,	
												@CurrentDate,
												@CurrentDate,											
												PositiveSentiment,
												NegativeSentiment,
												Title120,
												Number_Hits,
												HighlightingText,
												v5SubMediaType
											)											
											OUTPUT INSERTED.ArchiveClipKey AS 'id','TV' AS 'mediaType',INSERTED.ClipTitle AS 'title',
											INSERTED.GMTDateTime AS 'mediaDate','TV' AS 'submediaType',INSERTED.CategoryGuid AS 'categoryGuid',
									INSERTED.ClientGuid AS 'clientGuid',INSERTED.CustomerGuid AS 'customerGuid',
									INSERTED.ClipID AS 'ArticleID',INSERTED.StartOffset AS 'startOffset',
									(INSERTED.StartOffset + @AutoClipDuration - 1 ) AS 'endoffset',INSERTED.HighlightingText AS 'highlightingText',
									INSERTED.PositiveSentiment AS 'positiveSentiment',INSERTED.NegativeSentiment AS 'negativeSentiment', INSERTED.Title120, 
									CONVERT(DATE,INSERTED.ClipDate) AS ClipDate, inserted.IQ_CC_Key AS IQ_CC_Key,source.SearchTerm, NULL AS 'content',
									source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', 'TV' as 'rollupType', source.DataModelType as 'dataModelType'
									INTO @tempTable;

	SET @QueryDetail ='insert into archive clip table from @tempTVtable'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()																		
	END										
									
	IF @HasPQRecords = 1
	BEGIN
								--==============================================
								-- ArchivePQ
								--==============================================

								MERGE INTO ArchivePQ  AS target
								USING (
									SELECT 
										ReportXML.PQ.query('Title').value('.','varchar(255)') AS Title,
										IQReport_Discovery.Keywords,
										IQReport_Discovery.Description,
										IQReport_Discovery.CustomerGuid,
										IQReport_Discovery.ClientGuid,
										IQReport_Discovery.CategoryGuid,
										ReportXML.PQ.query('Publication').value('.','varchar(250)') AS Publication,
										ReportXML.PQ.query('ArticleID').value('.','varchar(25)') AS ProQuestID,
										ReportXML.PQ.query('MediaCategory').value('.','varchar(50)') AS MediaCategory,
										ReportXML.PQ.query('Content').value('.','varchar(max)') AS Content,
										ReportXML.PQ.query('ContentHTML').value('.','varchar(max)') AS ContentHTML,
										ReportXML.PQ.query('LanguageNum').value('.','smallint') AS LanguageNum,
										ReportXML.PQ.query('Copyright').value('.','varchar(250)') AS Copyright,
										ReportXML.PQ.query('AvailableDate').value('.','datetime') AS AvailableDate,
										ReportXML.PQ.query('MediaDate').value('.','datetime') AS MediaDate,
										ReportXML.PQ.query('PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
										ReportXML.PQ.query('NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
										ReportXML.PQ.query('SearchTerm').value('.','varchar(500)') AS SearchTerm,
										ReportXML.PQ.query('Number_Hits').value('.','tinyint') AS Number_Hits,
										ReportXML.PQ.query('HighlightingText').value('.','nvarchar(max)') AS HighlightingText,
										ReportXML.PQ.query('authors') AS Authors,
										ReportXML.PQ.query('MediaType').value('.','varchar(2)') as v5MediaType,
										ReportXML.PQ.query('SubMediaType').value('.','varchar(50)') as v5SubMediaType,
										ReportXML.PQ.query('DataModelType').value('.','varchar(10)') as DataModelType
																	
								 FROM 
									@xml.nodes('/MediaData/PQ/SubMedia') AS ReportXML(PQ)
								
									INNER JOIN IQReport_Discovery WITH (NOLOCK)
									ON IQReport_Discovery.ID = @ReportID
								
									INNER JOIN Customer
									ON IQReport_Discovery.CustomerGuid = Customer.CustomerGuid		
								) AS source ON source.ProQuestID = target.ProQuestID AND source.ClientGUID = target.ClientGUID
								WHEN NOT matched THEN
								INSERT 
								(
									Title,
									Keywords,
									Description,
									CustomerGUID,
									ClientGUID,
									CategoryGuid,			
									ProQuestID,
									Publication,
									Author,
									MediaCategory,
									Content,
									ContentHTML,
									AvailableDate,
									MediaDate,
									LanguageNum,
									Copyright,		
									CreatedDate,											
									ModifiedDate,
									IsActive,
									PositiveSentiment,
									NegativeSentiment,
									Number_Hits,
									HighlightingText,
									v5SubMediaType
								)
								VALUES
								(
									Title,
									Keywords,
									Description,
									CustomerGUID,
									ClientGUID,
									CategoryGuid,		
									ProQuestID,
									Publication,
									Authors,
									MediaCategory,
									Content,
									ContentHTML,
									AvailableDate,
									MediaDate,
									LanguageNum,
									Copyright,	
									@CurrentDate,
									@CurrentDate,
									1,
									PositiveSentiment,
									NegativeSentiment,
									Number_Hits,
									HighlightingText,
									v5SubMediaType
								)
											
									OUTPUT INSERTED.ArchivePQKey AS 'id','PQ' AS 'mediaType',INSERTED.Title AS 'title',INSERTED.MediaDate AS 'mediaDate','PQ' AS 'submediaType',
									INSERTED.CategoryGuid AS 'categoryGuid',
									INSERTED.ClientGuid AS 'clientGuid',INSERTED.CustomerGuid AS 'customerGuid',
									INSERTED.ProQuestID AS 'ArticleID',NULL AS 'startOffset',NULL AS 'endoffset', INSERTED.HighlightingText AS 'highlightingText',
									INSERTED.PositiveSentiment AS 'positiveSentiment',INSERTED.NegativeSentiment AS 'negativeSentiment', NULL AS Title120, NULL AS ClipDate, NULL AS IQ_CC_Key,source.SearchTerm, INSERTED.Content AS 'content',
									source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', null as 'rollupType', source.DataModelType as 'dataModelType'
										
									INTO @tempTable;
								
	SET @QueryDetail ='insert into archive proquest table from xml using merge'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()			
	END												
										
								--==============================================
								-- IQArchive_Media
								--==============================================	
								
								DECLARE @ArchiveMedia TABLE (ID BIGINT, CategoryGUID UNIQUEIDENTIFIER, ClientGUID UNIQUEIDENTIFIER, Title120 VARCHAR(100), MediaID BIGINT, ClipDate DATE,ClipTitle NVARCHAR(MAX),MediaDate DATETIME,Station_Affil VARCHAR(255),
															 v5SubMediaType VARCHAR(50), RollupType VARCHAR(50))														
								
								INSERT INTO IQArchive_Media(_ArchiveMediaID,MediaType,SubMediaType,Title,MediaDate,CategoryGuid,ClientGuid,CustomerGuid,
								IsActive,CreatedDate,highlightingText,PositiveSentiment,NegativeSentiment,_SearchRequestID,SearchTerm,Content,v5MediaType,v5SubMediaType)								
								OUTPUT INSERTED.ID, INSERTED.CategoryGUID, INSERTED.ClientGUID, NULL AS Title120, INSERTED._ArchiveMediaID AS MediaID, NULL AS ClipDate,inserted.Title AS ClipTitle,inserted.MediaDate, NULL Station_Affil,
										INSERTED.v5SubMediaType, NULL AS RollupType INTO @ArchiveMedia
								SELECT id,MediaType,
									CASE 
											WHEN 
												MediaType = 'SM'
											THEN
												-- Social Media Comment Here
												CASE
													WHEN 
														(SubMediaType = 'Blog' OR SubMediaType =  'Comment')
													THEN
														'Blog'
													
													WHEN (SubMediaType = 'Forum' OR  SubMediaType = 'Review')
													THEN
														'Forum'
													
													ELSE
														'SocialMedia'
												END
											ELSE
									
									
										subMediaType	
									END
									
									subMediaType
									
									,title,mediaDate,categoryGuid,clientGuid,CustomerGuid,1,@CurrentDate,highlightingText,
									positiveSentiment,negativeSentiment,-1,SearchTerm,Content,v5MediaType,v5SubMediaType
									 FROM @tempTable
								
								-- Can't set this field above because it isn't inserted into IQArchive_Media
								UPDATE @ArchiveMedia
								SET RollupType = tempTable.rollupType
								FROM @ArchiveMedia archiveMedia
								INNER JOIN @tempTable tempTable
									ON tempTable.id = archiveMedia.MediaID
									AND tempTable.v5SubMediaType = archiveMedia.v5SubMediaType

	SET @QueryDetail ='insert into iqarchive_media table from @temptable'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()											

								-- used for NM Grouping , contains all possible parent/ child combinations
								DECLARE @MediaGroupTable TABLE (MediaID BIGINT, Title VARCHAR(MAX), MediaDate DATETIME, CategoryGuid UNIQUEIDENTIFIER,ClientGuid UNIQUEIDENTIFIER,_ParentRecordID BIGINT,GroupRank INT)  
								
								-- contains all parent media ids and details 
								DECLARE @MT TABLE (ArchiveMediaID BIGINT, TVID BIGINT, Title120 VARCHAR(100), ClipDate DATE, CategoryGUID UNIQUEIDENTIFIER, ClientGUID UNIQUEIDENTIFIER,ClipTitle NVARCHAR(MAX),GroupRank INT,Station_Affil VARCHAR(255))

								-- contains exact parent to child combination records
								DECLARE @Child TABLE(ArchiveMediaID BIGINT, ParentMediaID BIGINT)

								DECLARE @SecondsOnDay INT= 86400
								DECLARE @2DaysTotalSeconds INT= 172800

								
								-- insert all possible parent / child combinations to group table for NM
								INSERT INTO @MediaGroupTable
								(
									MediaID,
									Title,
									MediaDate,
									CategoryGuid,
									_ParentRecordID,
									ClientGuid
								)
								SELECT
									m1.ID,
									m1.ClipTitle,
									m2.MEdiaDate,
									m1.CategoryGuid,
									m2.id,
									m2.ClientGuid
								FROM
									@ArchiveMedia m1
										INNER JOIN
											IQArchive_Media m2 WITH (NOLOCK)
										ON m1.ClipTitle=  m2.title
										AND m1.v5SubMediaType = m2.v5SubMediaType
										AND m1.CategoryGuid = m2.CategoryGuid
										AND m1.ClientGuid = m2.ClientGuid
										AND CAST((CAST(m1.mediadate AS FLOAT) - (CAST(m2.mediadate AS FLOAT))) * @SecondsOnDay AS BIGINT) >= 0 AND  CAST((CAST(m1.mediadate AS FLOAT) - (CAST(m2.mediadate AS FLOAT))) * @SecondsOnDay AS BIGINT) <= @2DaysTotalSeconds
										AND m1.ID != m2.ID
										AND m2._ParentID IS NULL
										AND m2.IsActive= 1			
										AND m1.RollupType = 'NM'
								ORDER BY m2.mediadate,m2.id

	SET @QueryDetail ='insert into @MediaGroupTable table from #ArchiveMedia table and archive_media table to find parent / child relations'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()											

								/*start of set rank for each group fall in 48 hours */
								DECLARE @RankID INT,@RankUpdated BIT

								SET @RankID  =1


								DECLARE @LastDate DATETIME

								
								UPDATE 
										@MediaGroupTable
								SET
										@RankID  = CASE WHEN CAST((CAST(MediaDate AS FLOAT) - (CAST(@LastDate AS FLOAT))) * @SecondsOnDay AS BIGINT) > @2DaysTotalSeconds THEN @RankID + 1  ELSE @RankID END,
										@LastDate = CASE WHEN CAST((CAST(MediaDate AS FLOAT) - (CAST(@LastDate AS FLOAT))) * @SecondsOnDay AS BIGINT) > @2DaysTotalSeconds  OR @LastDate IS NULL THEN MediaDate ELSE @LastDate END,
										GroupRank = @RankID
								/*end of rank set */

	SET @QueryDetail ='update grouprank for MediaGroupTable table'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()											

								/* fetch and insert parents for NM to temporary table @MT */
								INSERT INTO @MT
								(
									ArchiveMediaID,
									CategoryGUID,
									ClientGUID,
									ClipTitle,
									GroupRank
								)
								SELECT 
									MID,
									CategoryGUID,
									ClientGUID,
									Title,	
									GroupRank
								FROM
									(
										SELECT DISTINCT
											ROW_NUMBER() OVER (PARTITION BY mtbl.CategoryGUID,mtbl.Title,mtbl.ClientGUID,mtbl.GroupRank ORDER BY mediadate ASC,_ParentRecordID ASC) AS RowNumner,
											mtbl.Title,
											mtbl.CategoryGUID,
											mtbl.ClientGUID,
											_ParentRecordID AS MID,
											mtbl.GroupRank
										FROM   
											@MediaGroupTable mtbl 
									) AS A
								WHERE RowNumner = 1

	SET @QueryDetail ='insert into @MT for all news parents'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()											

								/* inseset child / parent record combinations into @Child table */
								INSERT INTO @Child
								(
									ArchiveMediaID,
									ParentMediaID
								)
								SELECT
									DISTINCT 
										MRTbl.MediaID,	
										MTbl.ArchiveMediaID AS ParentMediaID
								FROM
										@MediaGroupTable AS MRTbl
											INNER JOIN @MT AS MTbl
											 ON MRTbl._ParentRecordID = MTbl.ArchiveMediaID
											 AND MRTbl.MediaID != MTbl.ArchiveMediaID
											 AND MRTbl.GroupRank = MTbl.GroupRank

	SET @QueryDetail ='populate @Child table for NM parent / child mapping'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()																			
								
								/* process for TV parent / childs  */

								DELETE FROM 
									@ArchiveMedia 
								WHERE
									ISNULL(RollupType, '') != 'TV'

	SET @QueryDetail ='delete from @ArchiveMedia where rolluptype != ''TV'''
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()											
									 
								UPDATE @ArchiveMedia
									 SET Title120=TempMedia.Title120,
										 ClipDate=TempMedia.ClipDate,
										 Station_Affil = IQ_Station.Station_Affil
								FROM
									@ArchiveMedia AS TempArchiveMedia
										INNER JOIN @tempTable AS TempMedia
											ON TempArchiveMedia.MediaID=TempMedia.ID
											AND TempArchiveMedia.v5SubMediaType=TempMedia.v5SubMediaType
										INNER JOIN IQ_Station 
											ON IQ_Station_ID =  SUBSTRING(TempMedia.IQ_CC_KEY,0 ,CHARINDEX('_',TempMedia.IQ_CC_KEY))

	SET @QueryDetail ='update archive media for title120 ,clipdate, station affil using join with @temptable'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()											

	DECLARE @MinDate DATETIME, @MaxDate DATETIME
	SELECT 
			@MinDate=CONVERT(DATE,MIN(MediaDate)),
            @MaxDate=CONVERT(DATE,MAX(MediaDate))
	FROM
            @ArchiveMedia
            
    SET @MaxDate=DATEADD(ss,86399,@MaxDate)
                                
	IF OBJECT_ID('tempdb..#TmpMT') IS NOT NULL
	BEGIN
			DROP TABLE #TmpMT
	END

	CREATE TABLE #TmpMT (ArchiveMediaID BIGINT, TVID BIGINT, ClipDate DATE,CategoryGUID UNIQUEIDENTIFIER,Title120 VARCHAR(100),StationID VARCHAR(50), ClipTitle VARCHAR(255))

	INSERT INTO #TmpMT
	(
		ArchiveMediaID,
		TVID,
		ClipDate,
		CategoryGUID,
		Title120,
		StationID,
		ClipTitle
	)
	SELECT
			IQArchive_Media.ID,
			ArchiveClip.ArchiveClipKey,
			CONVERT(DATE,ArchiveClip.ClipDate),
			IQArchive_Media.CategoryGUID,
			ArchiveClip.Title120,
			SUBSTRING(ArchiveClip.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveClip.IQ_CC_Key)),
			ArchiveClip.ClipTitle
	FROM
			IQArchive_Media WITH(NOLOCK)
				INNER JOIN ArchiveClip WITH(NOLOCK)
					ON		IQArchive_Media._ArchiveMediaID=ArchiveClip.ArchiveClipKey
						AND IQArchive_Media.v5SubMediaType = ArchiveClip.v5SubMediaType
						AND IQArchive_Media.ClientGUID=@ClientGUID
	WHERE
			IQArchive_Media.MediaDate >= @MinDate AND IQArchive_Media.MediaDate <= @MaxDate                  
		AND _ParentID IS NULL
		AND IQArchive_Media.IsActive=1
		AND ArchiveClip.IsActive=1
	      

	SET @QueryDetail ='populate #TmpMT table'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()								

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
			MIN(TmpMT.ArchiveMediaID) AS ArchiveMediaID,
			MIN(TmpMT.TVID) AS TVID,       
			TmpMT.Title120,
			TmpMT.ClipDate,
			TmpMT.CategoryGUID,
			@ClientGUID,
			TmpMT.ClipTitle,
			TempArchiveMedia.Station_Affil                                                                                                                                                             
	FROM @ArchiveMedia AS TempArchiveMedia                  
			INNER JOIN #TmpMT AS TmpMT    
				ON                                          
					TempArchiveMedia.CategoryGUID=TmpMT.CategoryGUID
				AND TempArchiveMedia.ClipDate=TmpMT.ClipDate
				AND TempArchiveMedia.Title120=TmpMT.Title120
				AND TempArchiveMedia.MediaID!=TmpMT.TVID
				AND TempArchiveMedia.ClipTitle = TmpMT.ClipTitle
			INNER JOIN IQ_Station 
				ON 
					IQ_Station.IQ_Station_ID = TmpMT.StationID
				AND TempArchiveMedia.Station_Affil = IQ_Station.Station_Affil                                                                                                                                                              
	                                                                                                                                
	                                                                                                                                                                                
	GROUP BY TmpMT.CategoryGUID, TmpMT.ClipDate,TmpMT.Title120,TmpMT.ClipTitle,TempArchiveMedia.Station_Affil

	SET @QueryDetail ='populate @MT table for all TV parent'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()											

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
													
		SET @QueryDetail ='populate @Child table for TV parent / child mapping'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()											
	
														
								UPDATE 
										IQArchive_Media WITH (ROWLOCK)
								SET
										_ParentID= CASE WHEN ID=ParentMediaID THEN NULL ELSE ParentMediaID END
								FROM
										IQArchive_Media
											INNER JOIN	@Child AS Child
												ON		IQArchive_Media.ID=Child.ArchiveMediaID

		SET @QueryDetail ='uodate  IQArchive_Media for parentid using join with @Child table'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()			
							
							IF @HasNMRecords = 1
							BEGIN		
								INSERT INTO @tempTable(id,ArticleID,dataModelType,v5SubMediaType)								
								SELECT 
									ArchiveNM.ArchiveNMKey,ReportXML.NM.query('ArticleID').value('.','varchar(max)'),ReportXML.NM.query('DataModelType').value('.','varchar(10)'),ArchiveNM.v5SubMediaType
								FROM
																	
									@xml.nodes('/MediaData/NM/SubMedia') AS ReportXML(NM)
									
									LEFT OUTER JOIN @tempTable t
									ON ReportXML.NM.query('ArticleID').value('.','varchar(max)') = t.ArticleID
									AND t.dataModelType = ReportXML.NM.query('DataModelType').value('.','varchar(10)')
									
									INNER JOIN ArchiveNM WITH (NOLOCK)
									ON ArchiveNM.ArticleID = ReportXML.NM.query('ArticleID').value('.','varchar(max)')
									AND ArchiveNM.ClientGuid=@ClientGuid
									
									WHERE t.ArticleID IS NULL
							END		
							
							IF @HasSMRecords = 1
							BEGIN		
									-- Check If Data Not Inserted Into Archive Table than get ID and ArticleID for that -- SM
									INSERT INTO @tempTable(id,ArticleID,dataModelType,v5SubMediaType)								
								SELECT 
									ArchiveSM.ArchiveSMKey,ReportXML.SM.query('ArticleID').value('.','varchar(max)'),ReportXML.SM.query('DataModelType').value('.','varchar(10)'),ArchiveSM.v5SubMediaType
								FROM
																	
									@xml.nodes('/MediaData/SM/SubMedia') AS ReportXML(SM)									
									
									LEFT OUTER JOIN @tempTable t
									ON ReportXML.SM.query('ArticleID').value('.','varchar(max)') = t.ArticleID
									AND t.dataModelType = ReportXML.SM.query('DataModelType').value('.','varchar(10)')
									
									INNER JOIN ArchiveSM WITH (NOLOCK)
									ON ArchiveSM.ArticleID = ReportXML.SM.query('ArticleID').value('.','varchar(max)')
									AND ArchiveSM.ClientGuid=@ClientGuid
									
									WHERE t.ArticleID IS NULL
							END

							IF @HasTVRecords = 1
							BEGIN
							INSERT INTO @tempTable(id,ArticleID,dataModelType,v5SubMediaType,startOffset,endOffset)								
								SELECT 
									MAX(ArchiveClip.ArchiveClipKey),MAX(CONVERT(VARCHAR(40),IQCore_Clip.Guid)),IQ_MediaTypes.DataModelType,ArchiveClip.v5SubMediaType,IQCore_Clip.StartOffset,IQCore_Clip.EndOffset
								FROM
																	
									@xml.nodes('/MediaData/TV/SubMedia') AS ReportXML(TV)
									
									INNER JOIN IQCore_Clip WITH (NOLOCK)
									ON IQCore_Clip._RecordFileGuid = ReportXML.TV.query('VideoGUID').value('.','uniqueidentifier')
										AND StartOffset = CASE 
											WHEN
												(CAST(ReportXML.TV.query('StartOffset').value('.','bigint') AS INT) - 8) >= 0
											THEN
												CAST(ReportXML.TV.query('StartOffset').value('.','bigint') AS INT) - 8
											ELSE
												0
										END
										
										AND EndOffset = CASE 
											WHEN
												(CAST(ReportXML.TV.query('StartOffset').value('.','bigint') AS INT) - 8) >= 0
											THEN
												(CAST(ReportXML.TV.query('StartOffset').value('.','bigint') AS INT) - 8) + @AutoClipDuration - 1
											ELSE
												@AutoClipDuration - 1 
										END
									
									INNER JOIN ArchiveClip WITH (NOLOCK)
									ON ArchiveClip.ClipID = IQCore_Clip.Guid
									AND ArchiveClip.ClientGUID = @ClientGuid

									Inner Join IQ_MediaTypes
									ON IQ_MediaTypes.SubMediaType = ArchiveClip.v5SubMediaType
									
									LEFT OUTER JOIN @tempTable t
									ON t.ArticleID = ArchiveClip.ClipID
									AND t.dataModelType = ReportXML.TV.query('DataModelType').value('.','varchar(10)')
									
									WHERE t.ArticleID IS NULL
								GROUP BY IQCore_Clip._RecordFileGuid,IQCore_Clip.StartOffset,IQCore_Clip.EndOffset,IQ_MediaTypes.DataModelType,ArchiveClip.v5SubMediaType
							END	
							
							IF @HasPQRecords = 1
							BEGIN		
									-- Check If Data Not Inserted Into Archive Table than get ID and ArticleID for that -- PQ
									INSERT INTO @tempTable(id,ArticleID,dataModelType,v5SubMediaType)								
								SELECT 
									ArchivePQ.ArchivePQKey,ReportXML.PQ.query('ArticleID').value('.','varchar(max)'),ReportXML.PQ.query('DataModelType').value('.','varchar(10)'),ArchivePQ.v5SubMediaType
								FROM
																	
									@xml.nodes('/MediaData/PQ/SubMedia') AS ReportXML(PQ)									
									
									LEFT OUTER JOIN @tempTable t
									ON ReportXML.PQ.query('ArticleID').value('.','varchar(max)') = t.ArticleID
									AND t.dataModelType = ReportXML.PQ.query('DataModelType').value('.','varchar(10)')
									
									INNER JOIN ArchivePQ WITH (NOLOCK)
									ON ArchivePQ.ProQuestID = ReportXML.PQ.query('ArticleID').value('.','varchar(max)')
									AND ArchivePQ.ClientGuid=@ClientGuid
									
									WHERE t.ArticleID IS NULL
							END

	SET @QueryDetail ='insert into @temptable for all items which not inserted in current transaction (already exist in archive tables)'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()			


				IF @HasTVRecords = 1
				BEGIN
					UPDATE ArchiveClip WITH (ROWLOCK)
					SET 
						IsActive = 1 
					FROM 
						ArchiveClip 
							INNER JOIN @tempTable t
									ON (ArchiveClip.ArchiveClipKey = t.id  OR ArchiveClip.ArchiveClipKey = (SELECT m1._ArchiveMediaID FROM IQArchive_Media m1 WITH (NOLOCK) INNER JOIN IQArchive_Media m2 WITH (NOLOCK) ON m1.ID = m2._ParentID AND m2._ArchiveMediaID =t.id AND m1.v5SubMediaType = m2.v5SubMediaType AND m1.v5SubMediaType=t.v5SubmediaType AND m1.ClientGUID = @ClientGuid))
									AND t.dataModelType = 'TV'
									AND ArchiveClip.ClientGUID = @ClientGuid

					WHERE ArchiveClip.IsActive = 0
				END
	
				IF @HasNMRecords = 1
				BEGIN
					UPDATE ArchiveNM WITH (ROWLOCK)
					SET
						IsActive = 1
					FROM 
						ArchiveNM
							INNER JOIN @tempTable t
							ON (ArchiveNM.ArchiveNMKey = t.id or ArchiveNM.ArchiveNMKey = (SELECT m1._ArchiveMediaID From IQArchive_Media m1 WITH (NOLOCK) INNER JOIN IQArchive_Media m2 WITH (NOLOCK) on m1.ID = m2._ParentID and m2._ArchiveMediaID =t.id and m1.v5SubMediaType = m2.v5SubMediaType and m1.v5SubMediaType=t.v5SubMediaType and m1.ClientGUID = @ClientGuid))
							AND t.dataModelType = 'NM'
							AND ArchiveNM.ClientGuid=@ClientGuid
				END	
				
				IF @HasSMRecords = 1
				BEGIN	
					UPDATE ArchiveSM WITH (ROWLOCK)
					SET
						IsActive = 1
					FROM 
						ArchiveSM
							INNER JOIN @tempTable t
							ON ArchiveSM.ArchiveSMKey = t.id
							AND t.dataModelType = 'SM'
							AND ArchiveSM.ClientGuid=@ClientGuid
				END
				
				IF @HasPQRecords = 1
				BEGIN	
					UPDATE ArchivePQ WITH (ROWLOCK)
					SET
						IsActive = 1
					FROM 
						ArchivePQ
							INNER JOIN @tempTable t
							ON ArchivePQ.ArchivePQKey = t.id
							AND t.dataModelType = 'PQ'
							AND ArchivePQ.ClientGuid=@ClientGuid
				END

					UPDATE IQArchive_Media WITH (ROWLOCK)
					SET
						IsActive = 1
					FROM 
						IQArchive_Media
							INNER JOIN @tempTable t
							ON 
								(IQArchive_Media._ArchiveMediaID = t.id OR IQArchive_Media._ArchiveMediaID = (SELECT m1._ArchiveMediaID FROM IQArchive_Media m1 WITH (NOLOCK) INNER JOIN IQArchive_Media m2 WITH (NOLOCK) ON m1.ID = m2._ParentID AND m2._ArchiveMediaID =t.id AND m1.v5SubMediaType = m2.v5SubMediaType AND m1.v5SubMediaType=t.v5SubMediaType AND m1.ClientGUID = @ClientGuid))
							AND t.v5SubMediaType = IQArchive_Media.v5SubMediaType 
							AND IQArchive_Media.ClientGuid=@ClientGuid
									
SET @QueryDetail ='update all archive table set isactive = 1 if they are in deleted state using join with @temptable'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()			

		--==============================================
		-- Create XML
		--==============================================						
DECLARE @RootElement XML = ''
DECLARE @TVXML XML							
DECLARE @NMXML XML
DECLARE @SMXML XML
DECLARE @PQXML XML

DECLARE @CurrentArchiveTrackingXML XML
SELECT @CurrentArchiveTrackingXML = ArchiveTracking FROM IQReport_Discovery WHERE ID = @ReportID

SELECT @NMXML = (SELECT CAST('<SubMedia><ID>' + CAST(ID AS VARCHAR(50)) +'</ID><Content>1</Content><ArticleID>' + CAST(ArticleID AS VARCHAR(200)) + '</ArticleID></SubMedia>' AS XML)
								FROM 
									@tempTable t
								LEFT OUTER JOIN @CurrentArchiveTrackingXML.nodes('/Media/NM/SubMedia') AS ReportXML(NM)
								ON ReportXML.NM.query('ArticleID').value('.','varchar(max)') = t.ArticleID
								
								WHERE 
									dataModelType = 'NM' AND ReportXML.NM.query('ArticleID').value('.','varchar(max)') IS NULL
								FOR XML PATH(''))
								
								
								
SELECT @TVXML = (SELECT CAST('<SubMedia><StartOffset>' + CAST(StartOffset AS VARCHAR(20))+ '</StartOffset><EndOffset>' + CAST(EndOffset AS VARCHAR(20))+ '</EndOffset><ID>' + CAST(ID AS VARCHAR(50)) + '</ID><CC>1</CC><Export>1</Export><ThumbGen>1</ThumbGen><IOSExport>1</IOSExport><ArticleID>' + CAST(ArticleID AS VARCHAR(200)) + '</ArticleID></SubMedia>' AS XML)
								FROM 
									@tempTable t
								LEFT OUTER JOIN @CurrentArchiveTrackingXML.nodes('/Media/TV/SubMedia') AS ReportXML(TV)
								ON ReportXML.TV.query('ArticleID').value('.','varchar(max)') = t.ArticleID
								 
								WHERE 
									dataModelType = 'TV' AND ReportXML.TV.query('ArticleID').value('.','varchar(max)') IS NULL
								FOR XML PATH(''))			
								
SELECT @SMXML = (SELECT CAST('<SubMedia><ID>' + CAST(ID AS VARCHAR(50)) +'</ID><Content>1</Content><ArticleID>' + CAST(ArticleID AS VARCHAR(200)) + '</ArticleID></SubMedia>' AS XML)
								FROM 
									@tempTable t
								LEFT OUTER JOIN @CurrentArchiveTrackingXML.nodes('/Media/SM/SubMedia') AS ReportXML(SM)
								ON ReportXML.SM.query('ArticleID').value('.','varchar(max)') = t.ArticleID
								
								WHERE 
									dataModelType = 'SM' AND ReportXML.SM.query('ArticleID').value('.','varchar(max)') IS NULL
								FOR XML PATH(''))		
								
SELECT @PQXML = (SELECT CAST('<SubMedia><ID>' + CAST(ID AS VARCHAR(50)) +'</ID><Content>1</Content><ArticleID>' + CAST(ArticleID AS VARCHAR(200)) + '</ArticleID></SubMedia>' AS XML)
								FROM 
									@tempTable t
								LEFT OUTER JOIN @CurrentArchiveTrackingXML.nodes('/Media/PQ/SubMedia') AS ReportXML(PQ)
								ON ReportXML.PQ.query('ArticleID').value('.','varchar(max)') = t.ArticleID
								WHERE 
									dataModelType = 'PQ' AND ReportXML.PQ.query('ArticleID').value('.','varchar(max)') IS NULL
								FOR XML PATH(''))	
								
SET @QueryDetail ='create specific media xml using @tempTable'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()			


			-- if ArchiveTracking is Not null than it is "Add To Report"
			IF((SELECT ArchiveTracking FROM IQReport_Discovery WHERE ID = @ReportID) IS NULL)
				BEGIN
				
					SET @RootElement = '<Media></Media>'
					SELECT @TVXML	= '<TV>'  + CAST(@TVXML AS VARCHAR(MAX))+ '</TV>'
					SELECT @NMXML	= '<NM>' + CAST(@NMXML AS VARCHAR(MAX))+ '</NM>'
					SELECT @SMXML	 = '<SM>' + CAST(@SMXML AS VARCHAR(MAX))+ '</SM>'
					SELECT @PQXML   = '<PQ>' + CAST(@PQXML AS VARCHAR(MAX))+ '</PQ>'
													

					SET @RootElement.modify('insert sql:variable("@TVXML") as last into (/Media)[1]')
					SET @RootElement.modify('insert sql:variable("@NMXML") as last into (/Media)[1]')
					SET @RootElement.modify('insert sql:variable("@SMXML") as last into (/Media)[1]')
					SET @RootElement.modify('insert sql:variable("@PQXML") as last into (/Media)[1]')
				END										
			ELSE -- if ArchiveTracking is Not null than it is "Add To Report" && So We need to Append Submedia Element only
				BEGIN
				
						SELECT @RootElement =  ArchiveTracking FROM IQReport_Discovery WHERE ID = @ReportID
						DECLARE @ArchiveCurrentXML XML
						SELECT @ArchiveCurrentXML  = ArchiveTracking FROM IQReport_Discovery WHERE ID = @ReportID
						
						--IF TV EXISTS THAN APPEND SUBMEDIA ONLY OTHERWISE APPEND WITH TV ELEMENT + SUBMEDIA
						IF(@ArchiveCurrentXML.exist('(//TV)') = 0)
							BEGIN
								SELECT @TVXML	= '<TV>'  + CAST(@TVXML AS VARCHAR(MAX))+ '</TV>'
								SET @RootElement.modify('insert sql:variable("@TVXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN							
								SET @RootElement.modify('insert sql:variable("@TVXML") as last into (/Media/TV)[1]')								
							END	
						
						
						IF(@ArchiveCurrentXML.exist('(//NM)') = 0)
							BEGIN
								SELECT @NMXML	= '<NM>' + CAST(@NMXML AS VARCHAR(MAX))+ '</NM>'
								SET @RootElement.modify('insert sql:variable("@NMXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@NMXML") as last into (/Media/NM)[1]')
							END
						
						IF(@ArchiveCurrentXML.exist('(//SM)') = 0)
							BEGIN
								SELECT @SMXML	= '<SM>' + CAST(@SMXML AS VARCHAR(MAX))+ '</SM>'
								SET @RootElement.modify('insert sql:variable("@SMXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@SMXML") as last into (/Media/SM)[1]')
							END						
						
						IF(@ArchiveCurrentXML.exist('(//PQ)') = 0)
							BEGIN
								SELECT @PQXML	= '<PQ>' + CAST(@PQXML AS VARCHAR(MAX))+ '</PQ>'
								SET @RootElement.modify('insert sql:variable("@PQXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@PQXML") as last into (/Media/PQ)[1]')
							END
				END					

					
SET @QueryDetail ='set @RootElement for achive tracking xml'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()				
		
		--Now Update IQReport_Discovery table's ArchiveTracking column with this XML
		
		UPDATE IQReport_Discovery
		SET ArchiveTracking = @RootElement,
		LastModified = GETDATE()
		WHERE ID = @ReportID			

	SET @QueryDetail ='update IQReport_Feeds for ArchiveTracking with @RootElement'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()		
	
		
		DECLARE @ReportGuid UNIQUEIDENTIFIER
		SELECT @ReportGuid = ReportGuid FROM IQReport_Discovery WHERE ID = @ReportID

		DECLARE @IQReportRootElement XML
		SELECT @IQReportRootElement =  ReportRule FROM IQ_Report WHERE ReportGUID = @ReportGuid

		IF(@IQReportRootElement IS NULL)
		BEGIN
			SET @IQReportRootElement  = '<Report><Library><ArchiveMediaSet></ArchiveMediaSet></Library></Report>'
		END

		DECLARE @TempArchiveMedia TABLE (ID BIGINT)

		INSERT INTO @TempArchiveMedia
		SELECT
			IQArchive_Media.ID
		FROM
			@tempTable AS tmpTbl
				INNER JOIN IQArchive_Media WITH (NOLOCK)
					ON	tmpTbl.ID=IQArchive_Media._ArchiveMediaID 
					AND	tmpTbl.v5SubMediaType=IQArchive_Media.v5SubMediaType
				LEFT OUTER JOIN @IQReportRootElement.nodes('/Report/Library/ArchiveMediaSet/ID') AS IQ_ReportXML(R)
					ON IQArchive_Media.ID = IQ_ReportXML.R.value('.','bigint')
		WHERE IQ_ReportXML.R.value('.','bigint') IS NULL


		SET @QueryDetail ='populate @TempArchiveMedia table from @tempTable to generate iq_Report report rule'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()			

					

		DECLARE @IQReportChild XML
		SELECT @IQReportChild = (SELECT CAST('<ID>' + CAST(ID AS VARCHAR(50)) +'</ID>' AS XML)
								FROM 
									@TempArchiveMedia 
								
								FOR XML PATH(''))
								
		SET @IQReportRootElement.modify('insert sql:variable("@IQReportChild") as last into (/Report/Library/ArchiveMediaSet)[1]')

		UPDATE IQ_Report
		SET ReportRule = @IQReportRootElement				
		WHERE ReportGuid = (SELECT ReportGuid FROM IQReport_Discovery WHERE ID = @ReportID)	
			

		SET @QueryDetail ='update report rule of IQ_REport table'
    SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
    INSERT INTO IQ_SPTimeTracking([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GETDATE()	
			
		SELECT 1
		
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
				@CreatedBy='usp_v5_svc_Report_Discovery_Insert',
				@ModifiedBy='usp_v5_svc_Report_Discovery_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
				
		SELECT -1
	END CATCH
		
		DECLARE @TypeID	BIGINT
		DECLARE @Status VARCHAR(20)
		
		SELECT	@TypeID = JobTypeID,
				@Status = Status
		FROM	IQReport_Discovery
		WHERE	ID = @ReportID
		
		EXEC usp_Service_JobMaster_UpdateStatus @ReportID, @Status, @ModifiedDate, @TypeID	

		SET @QueryDetail ='0'
		SET @TimeDiff = DATEDIFF(ms, @SPStartTime, GETDATE())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,INPUT,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,'<Input><ReportID>'+ CONVERT(NVARCHAR(MAX),@ReportID) +'</ReportID><@XML>'+ CONVERT(NVARCHAR(MAX),@XML) +'</@XML></Input>',@QueryDetail,@TimeDiff)
END

GO


