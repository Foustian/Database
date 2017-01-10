CREATE PROCEDURE [dbo].[usp_v5_svc_Report_Feeds_Insert]
(
		@ReportID bigint,
		@XML XML
)		
AS
BEGIN
	
	DECLARE @StopWatch datetime, @SPStartTime datetime,@SPTrackingID uniqueidentifier, @TimeDiff decimal(18,2),@SPName varchar(100),@QueryDetail varchar(500)

	-- If there is an error, the time log shouldn't be rolled back. Store the messages in this table, then write them to @logTable after the transaction
	DECLARE @logTable table([Guid] uniqueidentifier, SPName varchar(100), QueryDetail varchar(500), TotalTime decimal(18,2))
 
	Set @SPStartTime=GetDate()
	Set @Stopwatch=GetDate()
	SET @SPTrackingID = NEWID()
	SET @SPName ='usp_v5_svc_Report_Feeds_Insert'     

    BEGIN TRANSACTION
	BEGIN TRY			
	
		DECLARE @CurrentDate datetime  = GetDate()
		DECLARE @Multiplier float
		DECLARE @AutoClipDuration int
		DECLARE @ClientGuid uniqueidentifier
		DECLARE @RootPathID bigint
		DECLARE @ReportRule xml		
		DECLARE @HasTVRecords int
		DECLARE @HasNMRecords int
		DECLARE @HasSMRecords int
		DECLARE @HasTWRecords int
		DECLARE @HasTMRecords int
		DECLARE @HasPQRecords int
		DECLARE @HasIQRRecords int		
								
		Declare @ReportTitle varchar(max)
		Declare @ReportKeywords varchar(max)
		Declare @ReportDesc varchar(max)
		Declare @ReportClientGuid uniqueidentifier
		Declare @ReportCustomerGuid uniqueidentifier
		Declare @ReportCategoryGuid uniqueidentifier
		Declare @ReportSubCategory1Guid uniqueidentifier
		Declare @ReportSubCategory2Guid uniqueidentifier
		Declare @ReportSubCategory3Guid uniqueidentifier								
								
		Select 								
			@ReportTitle = Title,
			@ReportKeywords = Keywords,
			@ReportDesc = [Description],
			@ReportClientGuid = ClientGuid,
			@ReportCustomerGuid = CustomerGuid,
			@ReportCategoryGuid = CategoryGuid,								
			@ReportSubCategory1Guid = SubCategory1Guid,
			@ReportSubCategory2Guid = SubCategory2Guid,
			@ReportSubCategory3Guid = SubCategory3Guid,
			@ClientGuid = ClientGuid
		From 
			IQReport_Feeds
		Where
			ID = @ReportID

		SELECT @RootPathID = ID FROM IQCore_RootPath WHERE _RootPathTypeID = (SELECT ID FROM IQCore_RootPathType Where Name ='TVEyes')
		
		Select @ReportRule = ReportRule From IQ_Report Where ReportGUID = (Select ReportGuid from IQReport_Feeds Where ID = @ReportID)
		
		-- To help avoid deadlock issues, only run each section if needed
		SELECT @HasTVRecords = @xml.exist('MediaResults/TV/MediaResult')
		SELECT @HasNMRecords = @xml.exist('MediaResults/NM/MediaResult')
		SELECT @HasSMRecords = @xml.exist('MediaResults/SM/MediaResult')
		SELECT @HasTWRecords = @xml.exist('MediaResults/TW/MediaResult')
		SELECT @HasTMRecords = @xml.exist('MediaResults/TM/MediaResult')
		SELECT @HasPQRecords = @xml.exist('MediaResults/PQ/MediaResult')
		SELECT @HasIQRRecords = @xml.exist('MediaResults/IQR/MediaResult')

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
					AND IQClient_CustomSettings.Field IN ('Multiplier','AutoClipDuration')
		)
 
		SELECT 
			@Multiplier = [Multiplier],
			@AutoClipDuration = [AutoClipDuration] 
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
				FOR Field IN ([Multiplier],[AutoClipDuration])
			) AS PivotTable	

	 SET @QueryDetail ='get all settings and report rule'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()		
	
	DECLARE @CppDayPart2Val float
	SELECT @CppDayPart2Val = cppvalue FROM IQ_SQAD Where daypartid = 2 and SQADMarketID = 997
						 
	DECLARE @tempTable table(id bigint,mediaType varchar(2),title nvarchar(max),mediaDate datetime,submediaType varchar(50),
								categoryGuid uniqueidentifier, subcategory1Guid uniqueidentifier, subcategory2Guid uniqueidentifier, subcategory3Guid uniqueidentifier, 
								clientGuid uniqueidentifier, customerGuid uniqueidentifier,ArticleID varchar(50),startOffset bigint,endoffset bigint,
								highlightingText nvarchar(max),positiveSentiment tinyint, negativeSentiment tinyint, Title120 VARCHAR(100), ClipDate DATE,IQ_CC_KEY varchar(50),
								_MediaID bigint,_SearchRequestID bigint,SearchTerm varchar(500),content nvarchar(max),v5MediaType varchar(2),v5SubMediaType varchar(50), rollupType varchar(50), dataModelType varchar(10))
	
	IF @HasNMRecords = 1
	BEGIN							
	Declare @NMRoothPathID bigint
	Select @NMRoothPathID =
							IQCore_RootPath.ID
					From
							IQCore_RootPath WITH (NOLOCK)
								inner join IQCore_RootPathType WITH (NOLOCK)
									on IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
					Where
							IQCore_RootPathType.Name='NM'
					Order by
							NEWID()
	
								--==============================================
								-- IQCore_NM
								--==============================================
								MERGE into IQCore_NM  as target
								 Using (
										 Select 
											ArticleID,
											MAX(Url) as Url,
											MAX(Harvest_Time) as Harvest_Time,
											'QUEUED' as [Status],
											@NMRoothPathID as RootPathID,
											@CurrentDate as LastModified									
										 From (Select
												ReportXML.NM.query('ArticleID').value('.','varchar(50)') as ArticleID,
												ReportXML.NM.query('Url').value('.','varchar(max)') as Url,
												ReportXML.NM.query('MediaDate').value('.','datetime') as Harvest_Time
											   From
												@xml.nodes('/MediaResults/NM/MediaResult') as ReportXML(NM)) sub
										group by
											ArticleID
									) as source ON source.ArticleID = target.ArticleID
								WHEN NOT MATCHED THEN
									Insert 
										(
											ArticleID,
											Url,
											harvest_time,
											[Status],
											_RootPathID,
											LastModified									
										)
										values
										(
											ArticleID,
											Url,
											Harvest_Time,
											[Status],
											RootPathID,
											LastModified
										);	

	 SET @QueryDetail ='insert into iqcore nm from xml using left join media result table'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()		

								--==============================================
								--ArchiveNM
								--==============================================
								 MERGE into ArchiveNM  as target
								 Using (

										 Select 
											ReportXML.NM.query('ID').value('.','bigint') as ID,
											ReportXML.NM.query('SearchRequestID').value('.','bigint') as _SearchRequestID,
											ReportXML.NM.query('HighlightingText').value('.','nvarchar(max)') as HighlightingText,
											ReportXML.NM.query('SearchTerm').value('.','varchar(500)') as SearchTerm,
											ReportXML.NM.query('NumberOfHits').value('.','tinyint') as Number_Hits,
											ReportXML.NM.query('Title').value('.','nvarchar(max)') as Title,
											IQReport_Feeds.Keywords,
											IQReport_Feeds.Description,
											ReportXML.NM.query('MediaDate').value('.','datetime') as harvest_time,
											Customer.FirstName,
											Customer.LastName,
											IQReport_Feeds.CustomerGuid,
											IQReport_Feeds.ClientGuid,
											IQReport_Feeds.CategoryGuid,
											IQReport_Feeds.SubCategory1Guid,
											IQReport_Feeds.SubCategory2Guid,
											IQReport_Feeds.SubCategory3Guid,
											ReportXML.NM.query('ArticleID').value('.','varchar(50)') as ArticleID,
											IQAgent_MissingArticles.Content,
											ReportXML.NM.query('Url').value('.','varchar(500)') as Url,
											ReportXML.NM.query('Publication').value('.','varchar(255)') as Publication,
											ReportXML.NM.query('CompeteUrl').value('.','varchar(255)') as CompeteUrl,
											1 as 'IsActive',
											ReportXML.NM.query('Audience').value('.','int') as Compete_Audience,
											ReportXML.NM.query('MediaValue').value('.','decimal(18,2)') as IQAdshareValue,
											ReportXML.NM.query('AudienceType').value('.','varchar(1)') as Compete_Result,
											ReportXML.NM.query('PositiveSentiment').value('.','tinyint') as PositiveSentiment,
											ReportXML.NM.query('NegativeSentiment').value('.','tinyint') as NegativeSentiment,
											ReportXML.NM.query('IQLicense').value('.','tinyint') as IQLicense,
											ReportXML.NM.query('MediaType').value('.','varchar(2)') as MediaType,
											ReportXML.NM.query('SubMediaType').value('.','varchar(50)') as SubMediaType,
											ReportXML.NM.query('v5MediaType').value('.','varchar(2)') as v5MediaType,
											ReportXML.NM.query('v5SubMediaType').value('.','varchar(50)') as v5SubMediaType,
											ReportXML.NM.query('DataModelType').value('.','varchar(10)') as DataModelType
									
									 From 
										@xml.nodes('/MediaResults/NM/MediaResult') as ReportXML(NM)
								
										Inner Join IQReport_Feeds WITH (NOLOCK)
										ON IQReport_Feeds.ID = @ReportID
								
										Inner Join Customer
										ON IQReport_Feeds.CustomerGuid = Customer.CustomerGuid

										left outer join IQAgent_MissingArticles WITH (NOLOCK)
											on ReportXML.NM.query('ArticleID').value('.','varchar(50)') = IQAgent_MissingArticles.ID
									) as source ON source.ArticleID = target.ArticleID and source.ClientGUID = target.ClientGUID
						WHEN NOT MATCHED THEN
							Insert 
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
									SubCategory1Guid,
									SubCategory2Guid,
									SubCategory3Guid,
									ArticleID,
									ArticleContent,
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
									HighlightingText,
									Number_Hits,
									v5SubMediaType					
								)
								values
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
									SubCategory1Guid,
									SubCategory2Guid,
									SubCategory3Guid,
									ArticleID,
									Content,									
									Url,
									Publication,
									CompeteUrl,
									IsActive,
									@CurrentDate,
									@CurrentDate,
									Compete_Audience,
									IQAdshareValue,
									Compete_Result,
									PositiveSentiment,
									NegativeSentiment,
									IQLicense,
									HighlightingText,
									Number_Hits,
									v5SubMediaType
								)

								OUTPUT INSERTED.ArchiveNMKey as 'id',source.MediaType as 'mediaType',INSERTED.Title as 'title',INSERTED.Harvest_Time as 'mediaDate',source.SubMediaType as 'submediaType',
										INSERTED.CategoryGuid 'categoryGuid',INSERTED.SubCategory1Guid 'subcategory1Guid',INSERTED.SubCategory2Guid 'subcategory2Guid',INSERTED.SubCategory3Guid 'subcategory3Guid',
										INSERTED.ClientGuid as 'clientGuid',INSERTED.CustomerGuid as 'customerGuid',
										INSERTED.ArticleID as 'ArticleID',NULL as 'startOffset',NULL as 'endoffset',inserted.HighlightingText as 'highlightingText',
										INSERTED.PositiveSentiment as 'positiveSentiment',INSERTED.NegativeSentiment as 'negativeSentiment', NULL AS Title120, NULL AS ClipDate, NULL as IQ_CC_KEY,
										source.ID,source._SearchRequestID,source.SearchTerm,INSERTED.ArticleContent as 'content',source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', 
										'NM' as 'rollupType', source.DataModelType as 'dataModelType'
										into @tempTable;

	 SET @QueryDetail ='insert into archive nm from xml using left join media result table'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()	
     END						
     	
	IF @HasSMRecords = 1
	BEGIN							
	Declare @SMRoothPathID bigint
	Select @SMRoothPathID =
							IQCore_RootPath.ID
					From
							IQCore_RootPath WITH (NOLOCK)
								inner join IQCore_RootPathType WITH (NOLOCK)
									on IQCore_RootPath._RootPathTypeID=IQCore_RootPathType.ID
					Where
							IQCore_RootPathType.Name='SM'
					Order by
							NEWID()
								--==============================================
								--IQCore SM
								--==============================================
								MERGE into IQCore_SM  as target
								 Using (
										 Select 
											ArticleID,
											MAX(Url) as Url,
											MAX(Harvest_Time) as Harvest_Time,
											'QUEUED' as [Status],
											@SMRoothPathID as RootPathID,
											@CurrentDate as LastModified									
										 From (Select
												ReportXML.SM.query('ArticleID').value('.','varchar(50)') as ArticleID,
												ReportXML.SM.query('Url').value('.','varchar(max)') as Url,
												ReportXML.SM.query('MediaDate').value('.','datetime') as Harvest_Time
											   From
												@xml.nodes('/MediaResults/SM/MediaResult') as ReportXML(SM)) sub
										group by
											ArticleID
									) as source ON source.ArticleID = target.ArticleID
								WHEN NOT MATCHED THEN
									Insert 
										(
											ArticleID,
											Url,
											harvest_time,
											[Status],
											_RootPathID,
											LastModified									
										)
										values
										(
											ArticleID,
											Url,
											Harvest_Time,
											[Status],
											RootPathID,
											LastModified
										);	
														
	
	 SET @QueryDetail ='insert into iq core sm from xml using left join media result table'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()	
								
								--==============================================
								--ArchiveSM
								--==============================================								
								MERGE into ArchiveSM  as target
								USING (
									Select 
											ReportXML.SM.query('ID').value('.','bigint') as ID,
											ReportXML.SM.query('SearchRequestID').value('.','bigint') as _SearchRequestID,
											ReportXML.SM.query('HighlightingText').value('.','nvarchar(max)') as HighlightingText,
											ReportXML.SM.query('SearchTerm').value('.','varchar(500)') as SearchTerm,
											ReportXML.SM.query('NumberOfHits').value('.','tinyint') as Number_Hits,
											ReportXML.SM.query('Title').value('.','nvarchar(max)') as Title,
											IQReport_Feeds.Keywords,
											IQReport_Feeds.Description,
											ReportXML.SM.query('MediaDate').value('.','datetime') as itemHarvestDate_DT,
											Customer.FirstName,
											Customer.LastName,
											IQReport_Feeds.CustomerGuid,
											IQReport_Feeds.ClientGuid,
											IQReport_Feeds.CategoryGuid,
											IQReport_Feeds.SubCategory1Guid,
											IQReport_Feeds.SubCategory2Guid,
											IQReport_Feeds.SubCategory3Guid,
											ReportXML.SM.query('ArticleID').value('.','varchar(50)') as SeqID,
											Case When ReportXML.SM.exist('Content') = 1
												Then
													ReportXML.SM.query('Content').value('.','nvarchar(max)')
												Else 
													IQAgent_MissingArticles.Content
											End as Content,							
											1 as 'IsActive',
											ReportXML.SM.query('Url').value('.','varchar(500)') as link,
											ReportXML.SM.query('Publication').value('.','varchar(255)') as homelink,
											ReportXML.SM.query('CompeteUrl').value('.','varchar(255)') as CompeteUrl,
											ReportXML.SM.query('Audience').value('.','int') as Compete_Audience,
											ReportXML.SM.query('MediaValue').value('.','decimal(18,2)') as IQAdshareValue,
											ReportXML.SM.query('AudienceType').value('.','varchar(1)') as Compete_Result,
											ReportXML.SM.query('PositiveSentiment').value('.','tinyint') as PositiveSentiment,
											ReportXML.SM.query('NegativeSentiment').value('.','tinyint') as NegativeSentiment,
											ReportXML.SM.query('ThumbUrl').value('.','varchar(max)') as ThumbUrl,
											ReportXML.SM.query('ArticleStatsModel') as ArticleStats,		
											ReportXML.SM.query('MediaType').value('.','varchar(2)') as MediaType,
											ReportXML.SM.query('SubMediaType').value('.','varchar(50)') as SubMediaType,
											ReportXML.SM.query('v5MediaType').value('.','varchar(2)') as v5MediaType,
											ReportXML.SM.query('v5SubMediaType').value('.','varchar(50)') as v5SubMediaType,
											ReportXML.SM.query('DataModelType').value('.','varchar(10)') as DataModelType					
									 From 
										@xml.nodes('/MediaResults/SM/MediaResult') as ReportXML(SM)
								
										Inner Join IQReport_Feeds WITH (NOLOCK)
										ON IQReport_Feeds.ID = @ReportID
								
										Inner Join Customer
										ON IQReport_Feeds.CustomerGuid = Customer.CustomerGuid
								
										left outer join IQAgent_MissingArticles WITH (NOLOCK) on
											ReportXML.SM.query('ArticleID').value('.','varchar(50)') = cast(IQAgent_MissingArticles.ID as varchar(50)) -- Not all article IDs are ints, so this breaks without the conversion
								) as source on source.SeqID = target.ArticleID and source.ClientGuid = target.ClientGuid
								WHEN NOT MATCHED THEN 
									Insert 
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
										SubCategory1Guid,
										SubCategory2Guid,
										SubCategory3Guid,
										ArticleID,
										ArticleContent,
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
										HighlightingText,
										Number_Hits,
										ThumbUrl,
										ArticleStats,
										v5SubMediaType
									)
									values
									(
											Title,
											Keywords,
											[Description],
											itemHarvestDate_DT,
											FirstName,
											LastName,
											CustomerGuid,
											ClientGuid,
											CategoryGuid,
											SubCategory1Guid,
											SubCategory2Guid,
											SubCategory3Guid,
											SeqID,
											Content,									
											link,									
											CompeteUrl,
											IsActive,
											SubMediaType,
											@CurrentDate,
											@CurrentDate,
											Compete_Audience,
											IQAdshareValue,
											Compete_Result,
											homelink,
											PositiveSentiment,
											NegativeSentiment,
											HighlightingText,
											Number_Hits,
											ThumbUrl,
											ArticleStats,
											v5SubMediaType
									)

								OUTPUT INSERTED.ArchiveSMKey as 'id',source.MediaType as 'mediaType',INSERTED.Title as 'title',INSERTED.Harvest_Time as 'mediaDate',
										INSERTED.Source_Category as 'submediaType',INSERTED.CategoryGuid as 'categoryGuid',INSERTED.SubCategory1Guid 'subcategory1Guid',INSERTED.SubCategory2Guid 'subcategory2Guid',
										INSERTED.SubCategory3Guid 'subcategory3Guid',INSERTED.ClientGuid as 'clientGuid',INSERTED.CustomerGuid as 'customerGuid',
										INSERTED.ArticleID as 'ArticleID',NULL as 'startOffset',NULL as 'endoffset',inserted.HighlightingText as 'highlightingText',
										INSERTED.PositiveSentiment as 'positiveSentiment',INSERTED.NegativeSentiment as 'negativeSentiment', NULL AS Title120, NULL AS ClipDate, NULL as IQ_CC_KEY,
										source.ID,source._SearchRequestID,source.SearchTerm,inserted.ArticleContent as 'content',
										source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', null as 'rollupType', source.DataModelType as 'dataModelType'
										
										into @tempTable;
						
	SET @QueryDetail ='insert into archive sm from xml using left join media result table'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()								
								--AND IQAgent_SMResults.SeqID Not IN (Select ArticleID From ArchiveSM Where IsActive = 1)								
	END							
	
	IF @HasTWRecords = 1
	BEGIN							
								--==============================================
								-- ArchiveTweets
								--==============================================								
								MERGE into ArchiveTweets  as target
								Using (
									Select 
											ReportXML.TW.query('ID').value('.','bigint') as ID,
											ReportXML.TW.query('SearchRequestID').value('.','bigint') as _SearchRequestID,
											ReportXML.TW.query('HighlightingText').value('.','nvarchar(max)') as HighlightingText,
											ReportXML.TW.query('SearchTerm').value('.','varchar(500)') as SearchTerm,
											ReportXML.TW.query('NumberOfHits').value('.','tinyint') as Number_Hits,
											NULL as Title,
											IQReport_Feeds.Keywords,
											IQReport_Feeds.Description,
											IQReport_Feeds.CustomerGuid,
											IQReport_Feeds.ClientGuid,
											IQReport_Feeds.CategoryGuid,
											IQReport_Feeds.SubCategory1Guid,
											IQReport_Feeds.SubCategory2Guid,
											IQReport_Feeds.SubCategory3Guid,
											ReportXML.TW.query('ArticleID').value('.','varchar(50)') as TweetID,
											ReportXML.TW.query('Title').value('.','nvarchar(50)') as actor_displayname,
											ReportXML.TW.query('ActorPreferredName').value('.','nvarchar(50)') as actor_preferredname,
											ReportXML.TW.query('Summary').value('.','nvarchar(max)') as summary,
											ReportXML.TW.query('Audience').value('.','bigint') as actor_followersCount,
											ReportXML.TW.query('ActorFriendsCount').value('.','bigint') as actor_friendsCount,
											ReportXML.TW.query('ActorImage').value('.','varchar(max)') as actor_image,
											ReportXML.TW.query('Url').value('.','varchar(max)') as actor_link,											
											ReportXML.TW.query('MediaValue').value('.','bigint') as gnip_klout_score,
											ReportXML.TW.query('MediaDate').value('.','datetime') as Tweet_postedDatetime,
											ReportXML.TW.query('PositiveSentiment').value('.','tinyint') as PositiveSentiment,
											ReportXML.TW.query('NegativeSentiment').value('.','tinyint') as NegativeSentiment,
											ReportXML.TW.query('MediaType').value('.','varchar(2)') as MediaType,
											ReportXML.TW.query('SubMediaType').value('.','varchar(50)') as SubMediaType,
											ReportXML.TW.query('v5MediaType').value('.','varchar(2)') as v5MediaType,
											ReportXML.TW.query('v5SubMediaType').value('.','varchar(50)') as v5SubMediaType,
											ReportXML.TW.query('DataModelType').value('.','varchar(10)') as DataModelType
									 From 
										@xml.nodes('/MediaResults/TW/MediaResult') as ReportXML(TW)
								
										Inner Join IQReport_Feeds WITH (NOLOCK)
										ON IQReport_Feeds.ID = @ReportID
								
										Inner Join Customer
										ON IQReport_Feeds.CustomerGuid = Customer.CustomerGuid				
								
								) as source on target.Tweet_ID = source.TweetID and target.ClientGUID = source.ClientGUID
								WHEN NOT MATCHED THEN
									INSERT 
									(
										Title,
										Keywords,
										Description,
										CustomerGUID,
										ClientGUID,
										CategoryGuid,												
										SubCategory1Guid,
										SubCategory2Guid,
										SubCategory3Guid,
										Tweet_ID,
										Actor_DisplayName,
										Actor_PreferredUserName,
										Tweet_Body,
										Actor_FollowersCount,
										Actor_FriendsCount,
										Actor_Image,
										Actor_link,
										gnip_Klout_Score,
										Tweet_PostedDateTime,	
										CreatedDate,											
										ModifiedDate,
										IsActive,
										PositiveSentiment,
										NegativeSentiment,
										HighlightingText,
										Number_Hits,
										v5SubMediaType
									)
									values
									(
											Title,
											Keywords,
											Description,
											CustomerGuid,
											ClientGuid,
											CategoryGuid,
											SubCategory1Guid,
											SubCategory2Guid,
											SubCategory3Guid,
											TweetID,
											actor_displayname,
											actor_preferredname,
											summary,
											actor_followersCount,
											actor_friendsCount,
											actor_image,
											actor_link,
											gnip_klout_score,
											Tweet_postedDatetime,
											@CurrentDate,
											@CurrentDate,
											1,
											PositiveSentiment,
											NegativeSentiment,
											HighlightingText,
											Number_Hits,
											v5SubMediaType
									)
											
									OUTPUT INSERTED.ArchiveTweets_Key as 'id',source.MediaType as 'mediaType',INSERTED.Title as 'title',INSERTED.Tweet_PostedDateTime as 'mediaDate',source.SubMediaType as 'submediaType',
									INSERTED.CategoryGuid as 'categoryGuid',INSERTED.SubCategory1Guid 'subcategory1Guid',INSERTED.SubCategory2Guid 'subcategory2Guid',INSERTED.SubCategory3Guid 'subcategory3Guid',
									INSERTED.ClientGuid as 'clientGuid',INSERTED.CustomerGuid as 'customerGuid',
									INSERTED.Tweet_ID as 'ArticleID',NULL as 'startOffset',NULL as 'endoffset', INSERTED.HighlightingText as 'highlightingText',
									INSERTED.PositiveSentiment as 'positiveSentiment',INSERTED.NegativeSentiment as 'negativeSentiment', NULL AS Title120, NULL AS ClipDate, NULL as IQ_CC_KEY, source.ID,source._SearchRequestID,
									source.SearchTerm,INSERTED.Tweet_Body as 'content',source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', null as 'rollupType', source.DataModelType as 'dataModelType'
									into @tempTable;
								
	
	 SET @QueryDetail ='insert into archive tweet from xml using left join media result table'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()								
	END
	
	IF @HasTVRecords = 1
	BEGIN							
								--==============================================
								-- IQCore_Clip
								--==============================================
								

								Declare @tempTVTable table (coreClipGuid uniqueidentifier,startOffset bigint,endOffset bigint,
															recordFileGuid uniqueidentifier,dateCreated datetime,averagesIQCCKEY varchar(max),squadIQCCKEY varchar(max),
															title varchar(max),IQStation varchar(20))

								DECLARE @TmpCoreClip TABLE (StartOffset INT, EndOffset INT, _RecordfileGuid UNIQUEIDENTIFIER, MediaResultID BIGINT)	
								
								INSERT INTO @TmpCoreClip
								(
									StartOffset,
									EndOffset,
									_RecordfileGuid,
									MediaResultID
								)
								SELECT										
										DISTINCT
										Case 
											When
												(cast(ReportXML.TV.value('xs:long(min(HighlightedCCOutput/CC/ClosedCaption/Offset))','bigint') AS INT) - 8) >= 0
											Then
												cast(ReportXML.TV.value('xs:long(min(HighlightedCCOutput/CC/ClosedCaption/Offset))','bigint') as int) - 8
											ELSE
												0
										END
											,
										Case 
											When
												(cast(ReportXML.TV.value('xs:long(min(HighlightedCCOutput/CC/ClosedCaption/Offset))','bigint') AS INT) - 8) >= 0
											Then
												(cast(ReportXML.TV.value('xs:long(min(HighlightedCCOutput/CC/ClosedCaption/Offset))','bigint') as int) - 8) + @AutoClipDuration - 1
											ELSE
												@AutoClipDuration - 1
										END,					
										ReportXML.TV.query('VideoGuid').value('.','uniqueidentifier'),
										ReportXML.TV.query('ID').value('.','bigint')
		
								From									
										@xml.nodes('/MediaResults/TV/MediaResult') as ReportXML(TV)
	
	 SET @QueryDetail ='populate @TmpCoreClip table from xml'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()		

								-- Keep track of which clips couldn't be created due to invalid raw media
								DECLARE @FailedClipXml XML

								SELECT @FailedClipXml =
									(SELECT	tmpCoreClip.MediaResultID as ID
									FROM	@TmpCoreClip tmpCoreClip
									INNER	JOIN IQCore_Recordfile WITH (NOLOCK) 
											ON IQCore_Recordfile.Guid = tmpCoreClip._RecordfileGuid
											AND IQCore_Recordfile.Status != 'READY'
									FOR XML PATH (''), root('FailedClips')
								)

								UPDATE IQReport_Feeds
								SET FailedClipXml = @FailedClipXml
								WHERE ID = @ReportID
	
	 SET @QueryDetail ='populate FailedClipXml column in IQReport_Feeds'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()		
														
								
								MERGE into IQCore_Clip  as target
								 Using (
										 Select 
											NEWID() as ClipGuid,
											tmpCoreClip.StartOffset,
											tmpCoreClip.EndOffset,
											@CurrentDate as DateCreated,
											_RecordfileGuid,
											'07175C0E-2B70-4325-BE6D-611910730968' as UserGuid
										 From 
											(Select Distinct
												StartOffset,
												EndOffset,
												_RecordfileGuid
											 From
												@TmpCoreClip) tmpCoreClip
										 Inner Join IQCore_Recordfile WITH (NOLOCK)
											On IQCore_Recordfile.Guid = tmpCoreClip._RecordfileGuid
											AND IQCore_Recordfile.Status = 'READY'
									) as source ON 
										source._RecordfileGUID = target._RecordfileGuid
										AND source.StartOffset = target.StartOffset
										AND source.EndOffset = target.EndOffset
										AND Exists (Select NULL
														From IQCore_ClipMeta WITH (NOLOCK)
														Where target.Guid = IQCore_ClipMeta._ClipGuid
														AND IQCore_ClipMeta.Field = 'IQClientID'
														AND IQCore_ClipMeta.Value = @ClientGuid)
								WHEN NOT MATCHED THEN
									Insert 
										(
											GUID,
											StartOffset,
											EndOffset,
											DateCreated,
											_RecordfileGuid,
											_UserGuid								
										)
										values
										(
											ClipGuid,
											StartOffset,
											EndOffset,
											DateCreated,
											_RecordfileGuid,
											UserGuid
										)

								OUTPUT INSERTED.GUID AS 'coreClipGuid',INSERTED.StartOffset AS 'startOffset',INSERTED.EndOffset AS 'endOffset',
										INSERTED._RecordfileGuid AS 'recordFileGuid',INSERTED.DateCreated AS 'dateCreated',NULL AS 'averagesIQCCKEY',
										NULL AS 'squadIQCCKEY',
										NULL AS 'title',
										NULL AS 'IQStation' INTO @tempTVTable;
											
	 SET @QueryDetail ='insert into iqcore_Clip table from @tmpCoreClip'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()								
									
								
								--==============================================
								-- Update @TempTVTable with Squad IQCCKEY,averages IQCCKEY , Title and IQ Station
								--==============================================
								update @tempTVTable
								Set title = ReportXML.TV.query('Title').value('.','varchar(max)'),
								averagesIQCCKEY = CASE 
											WHEN 
												IQ_Station.Dma_Num = '000' 
											THEN 
												IQ_Station_ID 
											ELSE 
												Station_Affil + '_' + TimeZone 
										END 
											+ '_' + SUBSTRING(ReportXML.TV.query('IQ_CC_Key').value('.','varchar(max)'),CHARINDEX('_',ReportXML.TV.query('IQ_CC_Key').value('.','varchar(max)')) +1,13),											
										squadIQCCKEY = ReportXML.TV.query('IQ_CC_Key').value('.','varchar(max)'),											
										IQStation = ReportXML.TV.query('StationID').value('.','varchar(150)')											
								From
									@xml.nodes('/MediaResults/TV/MediaResult') as ReportXML(TV)			
									
									INNER JOIN @TmpCoreClip tmpCoreClip
									ON tmpCoreClip.MediaResultID = ReportXML.TV.query('ID').value('.', 'bigint')
									
									INNER JOIN @tempTVTable t
									ON tmpCoreClip._RecordfileGuid = t.recordFileGuid
										AND tmpCoreClip.StartOffset = t.startOffset
									
									INNER Join IQCore_Clip WITH (NOLOCK)
									ON t.coreClipGuid = IQCore_Clip.Guid
										
									LEFT OUTER JOIN IQ_Station WITH (NOLOCK)
									ON ReportXML.TV.query('StationID').value('.','varchar(150)') = IQ_station.IQ_Station_ID
	
	SET @QueryDetail ='update @tempTVTable for title , station and iqcckey '
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()																	
								
								--==============================================
								-- IQCore_ClipInfo
								--==============================================
																
										
										Insert Into IQCore_ClipInfo
										(
											_ClipGuid,
											Title,
											[Description],
											Category,
											Keywords
										)
										Select 
											coreClipGuid,
											@ReportTitle,
											@ReportDesc,
											'PR',
											@ReportKeywords
										From
											@tempTVTable
										
										
										Insert Into IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											Value
										)
										Select
											coreClipGuid,
											'IQUser',
											@ReportCustomerGuid
										From
											@tempTVTable
											
										
										Insert Into IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											Value
										)	
										Select
											coreClipGuid,
											'IQclientID',
											@ReportClientGuid
										From
											@tempTVTable
											
										Insert Into IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											Value
										)	
										Select
											coreClipGuid,
											'IQCategory',
											@ReportCategoryGuid
										From
											@tempTVTable
										
										If @ReportSubCategory1Guid Is Not Null
										  Begin
											Insert Into IQCore_ClipMeta
											(
												_ClipGuid,
												Field,
												Value
											)	
											Select
												coreClipGuid,
												'SubCategory1GUID',
												@ReportSubCategory1Guid
											From
												@tempTVTable
										  End										
										
										If @ReportSubCategory2Guid Is Not Null
										  Begin	
											Insert Into IQCore_ClipMeta
											(
												_ClipGuid,
												Field,
												Value
											)	
											Select
												coreClipGuid,
												'SubCategory2GUID',
												@ReportSubCategory2Guid
											From
												@tempTVTable
										  End		
										
										If @ReportSubCategory3Guid Is Not Null
										  Begin											
											Insert Into IQCore_ClipMeta
											(
												_ClipGuid,
												Field,
												Value
											)	
											Select
												coreClipGuid,
												'SubCategory3GUID',
												@ReportSubCategory3Guid
											From
												@tempTVTable
										  End		
								

	 SET @QueryDetail ='insert into clip info and clip meta tables'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()									

										MERGE into ArchiveClip  as target
										Using (
													Select 
														distinct
														t.coreClipGuid,
														ReportXML.TV.query('ID').value('.','bigint') as ID,
														ReportXML.TV.query('SearchRequestID').value('.','bigint') as _SearchRequestID,
														ReportXML.TV.query('SearchTerm').value('.','varchar(500)') as SearchTerm,
														ReportXML.TV.query('NumberOfHits').value('.','tinyint') as Number_Hits,
														'http://media.iqmediacorp.com/logos/stations/small/' + cast([IQCore_Source].[Logo] as varchar(200)) as StationLogo,
														ReportXML.TV.query('Title').value('.','varchar(max)') as ClipTitle,
														[dbo].fnGetClipAdjustedDateTime([IQCore_Recording].[StartDate],IQ_Station.gmt_adj,IQ_Station.dst_adj,t.startOffset) AS ClipDate,
														IQCore_Recording.StartDate as GMTDateTime,
														Customer.FirstName,
														Customer.LastName,
														'PR' as Category,
														@ReportKeywords as Keywords,
														@ReportDesc as [Description],
														t.dateCreated,
														1 IsActive,
														REPLACE([IQCore_RootPath].[StreamSuffixPath] + [IQCore_AssetLocation].[Location],'\','/') as ThumbLocation,
														@ReportClientGuid as ClientGuid,
														@ReportCategoryGuid as CategoryGuid,
														@ReportSubCategory1Guid as SubCategory1Guid,
														@ReportSubCategory2Guid as SubCategory2Guid,
														@ReportSubCategory3Guid as SubCategory3Guid,
														@ReportCustomerGuid as CustomerGuid,
														LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) + 
														'_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00' as IQ_CC_Key,
														t.startOffset,
														CASE
															WHEN  AUDIENCE = 0 OR AUDIENCE IS NULL THEN
																CAST((Avg_Ratings_Pt) * (IQ_Station.UNIVERSE) AS int)
															ELSE 
																AUDIENCE
															END
														as AUDIENCE,

														CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
															CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* @MultiPlier * (CONVERT(decimal(18,2),(t.endOffset - t.startOffset + 1)) /30 ) * 
																CASE WHEN IQ_Station.SQADMARKETID = 997 AND IQ_Nielsen_Averages.DAYPARTID = 6 THEN
																	@CppDayPart2Val
																ELSE
																	(SELECT CPPVALUE FROM IQ_SQAD WHERE IQ_SQAD.SQADMARKETID = IQ_Station.SQADMARKETID AND IQ_SQAD.DAYPARTID = IQ_Nielsen_Averages.DAYPARTID)
																END
															)
														ELSE
															CONVERT(DECIMAL(18,2), SQAD_SHAREVALUE * @MultiPlier * (CONVERT(decimal(18,2),(t.endOffset - t.startOffset + 1)) /30 ))
														END
														as  SQAD_SHAREVALUE,
												
														CASE WHEN  SQAD_SHAREVALUE = 0 OR SQAD_SHAREVALUE IS NULL THEN
															CASE WHEN CONVERT(DECIMAL(18,2),Avg_Ratings_Pt * 100* @MultiPlier * (CONVERT(decimal(18,2),(t.endOffset - t.startOffset + 1)) /30 ) *
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
														END as Neilsen_Result,		
														ReportXML.TV.query('Title').value('.','varchar(max)') as Title120,		
														ReportXML.TV.query('HighlightingText').value('.','nvarchar(max)') as HighlightingText,
														ReportXML.TV.query('PositiveSentiment').value('.', 'tinyint') as PositiveSentiment,
														ReportXML.TV.query('NegativeSentiment').value('.', 'tinyint') as NegativeSentiment,
														ReportXML.TV.query('MediaType').value('.','varchar(2)') as MediaType,
														ReportXML.TV.query('SubMediaType').value('.','varchar(50)') as SubMediaType,
														ReportXML.TV.query('v5MediaType').value('.','varchar(2)') as v5MediaType,
														ReportXML.TV.query('v5SubMediaType').value('.','varchar(50)') as v5SubMediaType,
														ReportXML.TV.query('DataModelType').value('.','varchar(10)') as DataModelType
												
												 From 
											
													@tempTVTable t

													Inner Join @tmpCoreClip tmpCoreClip
													ON tmpCoreClip._RecordfileGuid = t.RecordfileGuid
														AND tmpCoreClip.StartOffset = t.StartOffset
																						
													Inner Join Customer WITH (NOLOCK)
													ON Customer.CustomerGuid = @ReportCustomerGuid
											
													Inner Join [IQCore_Recordfile] WITH (NOLOCK) 
													ON [IQCore_Recordfile].[Guid] = t.RecordfileGuid
											
													Inner Join [IQCore_Recording] WITH (NOLOCK) 
													ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
											
													Inner Join [IQCore_Source] WITH (NOLOCK) 
													ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
									
													left outer Join [IQCore_AssetLocation] WITH (NOLOCK)
													ON t.coreClipGuid = [IQCore_AssetLocation].[_AssetGuid]
											
													left outer Join [IQCore_RootPath] WITH (NOLOCK)
													ON [IQCore_AssetLocation].[_RootPathID] = [IQCore_RootPath].ID

													INNER JOIN IQ_Station WITH (NOLOCK)
													ON t.IQStation = IQ_station.IQ_Station_ID
											
													LEFT OUTER JOIN	[IQ_NIELSEN_SQAD] WITH (NOLOCK) 
													ON t.squadIQCCKEY = [IQ_NIELSEN_SQAD] .IQ_CC_Key
													AND [IQ_NIELSEN_SQAD].IQ_Start_Point= CASE WHEN t.startOffset = 0 THEN 1 ELSE CEILING(t.startOffset /900.0) END
											
													LEFT OUTER JOIN 
													IQ_Nielsen_Averages WITH (NOLOCK) 
													ON [IQ_NIELSEN_SQAD].iq_cc_key is null
													AND IQ_Nielsen_Averages.IQ_Start_Point = CASE WHEN t.startOffset = 0 THEN 1 ELSE CEILING(t.startOffset /900.0) END
													AND Affil_IQ_CC_Key = t.averagesIQCCKEY
											
													INNER JOIN @xml.nodes('/MediaResults/TV/MediaResult') as ReportXML(TV)
													ON ReportXML.TV.query('ID').value('.', 'bigint') = tmpCoreClip.MediaResultID
										) as source on (1=0)
										WHEN NOT MATCHED THEN
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
												SubCategory1Guid,
												SubCategory2Guid,
												SubCategory3Guid,
												CustomerGUID,												
												IQ_CC_Key,
												StartOffset,												
												Nielsen_Audience,
												IQAdShareValue,
												Nielsen_Result,
												CreatedDate,
												ModifiedDate,
												Title120,
												HighlightingText,
												Number_Hits,
												PositiveSentiment,
												NegativeSentiment,
												v5SubMediaType
											)	
											values
											(
												coreClipGuid,
												StationLogo,
												ClipTitle,
												ClipDate,
												GMTDateTime,
												FirstName,
												LastName,
												Category,
												Keywords,
												[Description],
												dateCreated,
												1,
												ThumbLocation,
												ClientGuid,
												CategoryGuid,
												SubCategory1Guid,
												SubCategory2Guid,
												SubCategory3Guid,
												CustomerGuid,
												IQ_CC_Key,
												startOffset,
												AUDIENCE,
												SQAD_SHAREVALUE,
												Neilsen_Result,				
												@CurrentDate,
												@CurrentDate,
												Title120,
												HighlightingText,
												Number_Hits,
												PositiveSentiment,
												NegativeSentiment,
												v5SubMediaType
											)										
											OUTPUT INSERTED.ArchiveClipKey as 'id',source.MediaType as 'mediaType',INSERTED.ClipTitle as 'title',
											INSERTED.GMTDateTime as 'mediaDate',source.SubMediaType as 'submediaType',INSERTED.CategoryGuid as 'categoryGuid',
									INSERTED.SubCategory1Guid 'subcategory1Guid',INSERTED.SubCategory2Guid 'subcategory2Guid',INSERTED.SubCategory3Guid 'subcategory3Guid',
									INSERTED.ClientGuid as 'clientGuid',INSERTED.CustomerGuid as 'customerGuid',
									INSERTED.ClipID as 'ArticleID',INSERTED.StartOffset as 'startOffset',
									(INSERTED.StartOffset + @AutoClipDuration - 1) as 'endoffset',INSERTED.HighlightingText as 'highlightingText',
									INSERTED.PositiveSentiment as 'positiveSentiment',INSERTED.NegativeSentiment as 'negativeSentiment',INSERTED.Title120, CONVERT(DATE,INSERTED.ClipDate) AS ClipDate,INSERTED.IQ_CC_Key as IQ_CC_KEY,
									source.ID,source._SearchRequestID,source.SearchTerm,CONVERT(nvarchar(max),inserted.ClosedCaption) as 'content',source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', 
									'TV' as 'rollupType', source.DataModelType as 'dataModelType'
									into @tempTable;
	
	SET @QueryDetail ='insert into archive clip table from @tempTVtable'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()																		
	END							
	
	IF @HasTMRecords = 1
	BEGIN							
								--==============================================
								-- ArchiveTVEyes
								--==============================================								


								MERGE into ArchiveTVEyes  as target
								USING (
									SELECT
											ReportXML.TM.query('ID').value('.','bigint') as ID,
											ReportXML.TM.query('SearchRequestID').value('.','bigint') as _SearchRequestID,
											ReportXML.TM.query('HighlightingText').value('.','nvarchar(max)') as HighlightingText,
											ReportXML.TM.query('SearchTerm').value('.','varchar(500)') as SearchTerm,
											ReportXML.TM.query('MediaID').value('.','bigint') as _MediaID,
											0 as Number_Hits,
											IQReport_Feeds.ClientGuid,
											IQReport_Feeds.CustomerGuid,
											IQReport_Feeds.CategoryGuid,
											IQReport_Feeds.SubCategory1Guid,
											IQReport_Feeds.SubCategory2Guid,
											IQReport_Feeds.SubCategory3Guid,
											ReportXML.TM.query('Title').value('.','varchar(255)') as StationName,
											IQReport_Feeds.Keywords,
											IQReport_Feeds.[Description],
											ReportXML.TM.query('StationID').value('.','varchar(50)') as StationID,
											ReportXML.TM.query('Market').value('.','varchar(150)') as Market,
											ReportXML.TM.query('DmaID').value('.','varchar(5)') as DMARank,
											ReportXML.TM.query('StationIDNum').value('.','varchar(50)') as StationIDNum,
											ReportXML.TM.query('Duration').value('.','int') as Duration,
											ReportXML.TM.query('HighlightingText').value('.','nvarchar(max)') as CC_Highlight,
											ReportXML.TM.query('MediaDate').value('.','datetime') as [UTCDateTime],
											NEWID() as TMGuid,
											@RootPathID as RootPathID,
											ReportXML.TM.query('LocalDate').value('.','datetime') as LocalDateTime,
											ReportXML.TM.query('TimeZone').value('.','varchar(10)') as TimeZone,
											ReportXML.TM.query('PositiveSentiment').value('.','tinyint') as PositiveSentiment,
											ReportXML.TM.query('NegativeSentiment').value('.','tinyint') as NegativeSentiment,
											ReportXML.TM.query('MediaType').value('.','varchar(2)') as MediaType,
											ReportXML.TM.query('SubMediaType').value('.','varchar(50)') as SubMediaType,
											ReportXML.TM.query('v5MediaType').value('.','varchar(2)') as v5MediaType,
											ReportXML.TM.query('v5SubMediaType').value('.','varchar(50)') as v5SubMediaType,
											ReportXML.TM.query('DataModelType').value('.','varchar(10)') as DataModelType
										FROM 
											@xml.nodes('/MediaResults/TM/MediaResult') as ReportXML(TM)
								
											Inner Join IQReport_Feeds WITH (NOLOCK)
											ON IQReport_Feeds.ID = @ReportID
									
								) as source on source._MediaID = target._IQAgentID and source.ClientGuid = target.ClientGuid
								WHEN NOT MATCHED THEN
								 insert
								 (
									_IQAgentID,
									ClientGUID,
									CustomerGUID,
									CategoryGuid,
									SubCategory1Guid,
									SubCategory2Guid,
									SubCategory3Guid,
									Title,
									Keywords,
									[Description],
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
									v5SubMediaType
								 )
								 values
								 (
									_MediaID,
									ClientGuid,
									CustomerGuid,
									CategoryGuid,
									SubCategory1Guid,
									SubCategory2Guid,
									SubCategory3Guid,
									StationName,
									Keywords,
									[Description],
									StationID,
									Market,
									DMARank,
									StationIDNum,
									Duration,
									CC_Highlight,
									[UTCDateTime],
									PositiveSentiment,
									NegativeSentiment,
									GETDATE(),
									'QUEUED',
									0,
									TMGuid,
									RootPathID,
									LocalDateTime,
									TimeZone,
									HighlightingText,
									Number_Hits,
									v5SubMediaType
								 )
								OUTPUT INSERTED.ArchiveTVEyesKey as 'id',source.MediaType as 'mediaType',INSERTED.Title as 'title',
											INSERTED.[UTCDateTime] as 'mediaDate',source.SubMediaType as 'submediaType',INSERTED.CategoryGuid as 'categoryGuid',
									INSERTED.SubCategory1Guid 'subcategory1Guid',INSERTED.SubCategory2Guid 'subcategory2Guid',INSERTED.SubCategory3Guid 'subcategory3Guid',
									INSERTED.ClientGuid as 'clientGuid',INSERTED.CustomerGuid as 'customerGuid',
									INSERTED._IQAgentID as 'ArticleID',null as 'startOffset',
									null as 'endoffset',INSERTED.HighlightingText as 'highlightingText',
									INSERTED.PositiveSentiment as 'positiveSentiment',INSERTED.NegativeSentiment as 'negativeSentiment', NULL AS Title120, NULL AS ClipDate, NULL as IQ_CC_KEY,
									source.ID,source._SearchRequestID,source.SearchTerm,INSERTED.Transcript as 'content',source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', 
									null as 'rollupType', source.DataModelType as 'dataModelType'
									into @tempTable;


	 SET @QueryDetail ='insert into ArchiveTVEyes table from xml'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()		
     END			
	 
	IF @HasPQRecords = 1
	BEGIN
								--==============================================
								-- ArchivePQ
								--==============================================

								MERGE INTO ArchivePQ  AS target
								USING (
									SELECT 
										ReportXML.PQ.query('ID').value('.','bigint') AS ID,
										ReportXML.PQ.query('SearchRequestID').value('.','bigint') AS _SearchRequestID,
										ReportXML.PQ.query('Title').value('.','varchar(255)') AS Title,
										IQReport_Feeds.Keywords,
										IQReport_Feeds.Description,
										IQReport_Feeds.CustomerGuid,
										IQReport_Feeds.ClientGuid,
										IQReport_Feeds.CategoryGuid,
										IQReport_Feeds.SubCategory1Guid,
										IQReport_Feeds.SubCategory2Guid,
										IQReport_Feeds.SubCategory3Guid,
										ReportXML.PQ.query('Publication').value('.','varchar(250)') AS Publication,
										ReportXML.PQ.query('ArticleID').value('.','varchar(25)') AS ProQuestID,
										ReportXML.PQ.query('MediaCategory').value('.','varchar(50)') AS MediaCategory,
										ReportXML.PQ.query('ContentHTML').value('.','varchar(max)') AS ContentHTML,
										ReportXML.PQ.query('LanguageNum').value('.','smallint') AS LanguageNum,
										ReportXML.PQ.query('Copyright').value('.','varchar(250)') AS Copyright,
										ReportXML.PQ.query('AvailableDate').value('.','datetime') AS AvailableDate,
										ReportXML.PQ.query('MediaDate').value('.','datetime') AS MediaDate,
										ReportXML.PQ.query('PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
										ReportXML.PQ.query('NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
										ReportXML.PQ.query('SearchTerm').value('.','varchar(500)') AS SearchTerm,
										ReportXML.PQ.query('NumberOfHits').value('.','tinyint') AS Number_Hits,
										ReportXML.PQ.query('HighlightingText').value('.','nvarchar(max)') AS HighlightingText,
										ReportXML.PQ.query('authors') AS Authors,
										ReportXML.PQ.query('MediaType').value('.','varchar(2)') as MediaType,
										ReportXML.PQ.query('SubMediaType').value('.','varchar(50)') as SubMediaType,
										ReportXML.PQ.query('v5MediaType').value('.','varchar(2)') as v5MediaType,
										ReportXML.PQ.query('v5SubMediaType').value('.','varchar(50)') as v5SubMediaType,
										ReportXML.PQ.query('DataModelType').value('.','varchar(10)') as DataModelType
																	
								 FROM 
									@xml.nodes('/MediaResults/PQ/MediaResult') AS ReportXML(PQ)
								
									INNER JOIN IQReport_Feeds WITH (NOLOCK)
									ON IQReport_Feeds.ID = @ReportID
										
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
									SubCategory1Guid,
									SubCategory2Guid,
									SubCategory3Guid,
									ProQuestID,
									Publication,
									Author,
									MediaCategory,
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
									SubCategory1Guid,
									SubCategory2Guid,
									SubCategory3Guid,
									ProQuestID,
									Publication,
									Authors,
									MediaCategory,
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
											
									OUTPUT INSERTED.ArchivePQKey AS 'id',source.MediaType AS 'mediaType',INSERTED.Title AS 'title',INSERTED.MediaDate AS 'mediaDate',source.SubMediaType AS 'submediaType',
									INSERTED.CategoryGuid AS 'categoryGuid',INSERTED.SubCategory1Guid 'subcategory1Guid',INSERTED.SubCategory2Guid 'subcategory2Guid',INSERTED.SubCategory3Guid 'subcategory3Guid',
									INSERTED.ClientGuid AS 'clientGuid',INSERTED.CustomerGuid AS 'customerGuid',
									INSERTED.ProQuestID AS 'ArticleID',NULL AS 'startOffset',NULL AS 'endoffset', INSERTED.HighlightingText AS 'highlightingText',
									INSERTED.PositiveSentiment AS 'positiveSentiment',INSERTED.NegativeSentiment AS 'negativeSentiment', NULL AS Title120, NULL AS ClipDate, NULL AS IQ_CC_Key,
									source.ID,source._SearchRequestID,source.SearchTerm,INSERTED.Content as 'content',source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', 
									null as 'rollupType', source.DataModelType as 'dataModelType'
										
									INTO @tempTable;
								
	SET @QueryDetail ='insert into ArchivePQ table from xml'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()			
	END		
	
	IF @HasIQRRecords = 1
	BEGIN							
								--==============================================
								-- IQCore_Clip
								--==============================================		
								
								Declare @tempRadioTable table (coreClipGuid uniqueidentifier, startOffset bigint, endOffset bigint, recordFileGuid uniqueidentifier)

								DECLARE @TmpRadioCoreClip TABLE (StartOffset INT, EndOffset INT, _RecordfileGuid UNIQUEIDENTIFIER, MediaResultID BIGINT)	
								
								INSERT INTO @TmpRadioCoreClip
								(
									StartOffset,
									EndOffset,
									_RecordfileGuid,
									MediaResultID
								)
								SELECT				
										Case 
											When
												(cast(ReportXML.IQR.value('xs:long(min(HighlightedCCOutput/CC/ClosedCaption/Offset))','bigint') AS INT) - 8) >= 0
											Then
												cast(ReportXML.IQR.value('xs:long(min(HighlightedCCOutput/CC/ClosedCaption/Offset))','bigint') as int) - 8
											ELSE
												0
										END
											,
										Case 
											When
												(cast(ReportXML.IQR.value('xs:long(min(HighlightedCCOutput/CC/ClosedCaption/Offset))','bigint') AS INT) - 8) >= 0
											Then
												(cast(ReportXML.IQR.value('xs:long(min(HighlightedCCOutput/CC/ClosedCaption/Offset))','bigint') as int) - 8) + @AutoClipDuration - 1
											ELSE
												@AutoClipDuration - 1
										END,					
										ReportXML.IQR.query('Guid').value('.','uniqueidentifier'),
										ReportXML.IQR.query('ID').value('.','bigint')
		
								From									
										@xml.nodes('/MediaResults/IQR/MediaResult') as ReportXML(IQR)
	
	 SET @QueryDetail ='populate @TmpRadioCoreClip table from xml'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()	

								-- Keep track of which clips couldn't be created due to invalid raw media
								DECLARE @FailedRadioClipXml XML

								SELECT @FailedRadioClipXml =
									(SELECT	tmpCoreClip.MediaResultID as ID
									FROM	@TmpRadioCoreClip tmpCoreClip
									INNER	JOIN IQCore_Recordfile WITH (NOLOCK) 
											ON IQCore_Recordfile.Guid = tmpCoreClip._RecordfileGuid
											AND IQCore_Recordfile.Status != 'READY'
									FOR XML PATH (''), root('FailedClips')
								)

								UPDATE IQReport_Feeds
								SET FailedClipXml = @FailedRadioClipXml
								WHERE ID = @ReportID
	
	 SET @QueryDetail ='populate FailedClipXml column in IQReport_Feeds'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()																
								
								MERGE into IQCore_Clip WITH (HOLDLOCK) as target
								 Using (
										 Select
											NEWID() as ClipGuid,
											tmpCoreClip.StartOffset,
											tmpCoreClip.EndOffset,
											@CurrentDate as DateCreated,
											_RecordfileGuid,
											'07175C0E-2B70-4325-BE6D-611910730968' as UserGuid
										 From 
											(Select Distinct
												StartOffset,
												EndOffset,
												_RecordfileGuid
											 From
												@TmpRadioCoreClip) tmpCoreClip
										 Inner Join IQCore_Recordfile WITH (NOLOCK)
											On IQCore_Recordfile.Guid = tmpCoreClip._RecordfileGuid
											AND IQCore_Recordfile.Status = 'READY'
									) as source ON 
										source._RecordfileGUID = target._RecordfileGuid
										AND source.StartOffset = target.StartOffset
										AND source.EndOffset = target.EndOffset
										AND Exists (Select NULL
														From IQCore_ClipMeta WITH (NOLOCK)
														Where target.Guid = IQCore_ClipMeta._ClipGuid
														AND IQCore_ClipMeta.Field = 'IQClientID'
														AND IQCore_ClipMeta.Value = @ClientGuid)
								WHEN NOT MATCHED THEN
									Insert 
										(
											GUID,
											StartOffset,
											EndOffset,
											DateCreated,
											_RecordfileGuid,
											_UserGuid								
										)
										values
										(
											ClipGuid,
											StartOffset,
											EndOffset,
											DateCreated,
											_RecordfileGuid,
											UserGuid
										)

								OUTPUT INSERTED.GUID AS 'coreClipGuid', INSERTED.StartOffset AS 'startOffset', INSERTED.EndOffset AS 'endOffset', INSERTED._RecordfileGuid AS 'recordFileGuid'
									INTO @tempRadioTable;
											
	 SET @QueryDetail ='insert into iqcore_Clip table from @tmpRadioCoreClip'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()																										
								
								--==============================================
								-- IQCore_ClipInfo
								--==============================================																
										
										Insert Into IQCore_ClipInfo
										(
											_ClipGuid,
											Title,
											[Description],
											Category,
											Keywords
										)
										Select 
											coreClipGuid,
											@ReportTitle,
											@ReportDesc,
											'PR',
											@ReportKeywords
										From
											@tempRadioTable
										
										
										Insert Into IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											Value
										)
										Select
											coreClipGuid,
											'IQUser',
											@ReportCustomerGuid
										From
											@tempRadioTable
											
										
										Insert Into IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											Value
										)	
										Select
											coreClipGuid,
											'IQclientID',
											@ReportClientGuid
										From
											@tempRadioTable
											
										Insert Into IQCore_ClipMeta
										(
											_ClipGuid,
											Field,
											Value
										)	
										Select
											coreClipGuid,
											'IQCategory',
											@ReportCategoryGuid
										From
											@tempRadioTable
										
										If @ReportSubCategory1Guid Is Not Null
										  Begin
											Insert Into IQCore_ClipMeta
											(
												_ClipGuid,
												Field,
												Value
											)	
											Select
												coreClipGuid,
												'SubCategory1GUID',
												@ReportSubCategory1Guid
											From
												@tempRadioTable
										  End										
										
										If @ReportSubCategory2Guid Is Not Null
										  Begin	
											Insert Into IQCore_ClipMeta
											(
												_ClipGuid,
												Field,
												Value
											)	
											Select
												coreClipGuid,
												'SubCategory2GUID',
												@ReportSubCategory2Guid
											From
												@tempRadioTable
										  End		
										
										If @ReportSubCategory3Guid Is Not Null
										  Begin											
											Insert Into IQCore_ClipMeta
											(
												_ClipGuid,
												Field,
												Value
											)	
											Select
												coreClipGuid,
												'SubCategory3GUID',
												@ReportSubCategory3Guid
											From
												@tempRadioTable
										  End		
								

	 SET @QueryDetail ='insert into clip info and clip meta tables'
     SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GetDate()							

										MERGE into ArchiveRadio WITH (HOLDLOCK) as target
										Using (
													Select 
														distinct
														ReportXML.IQR.query('ID').value('.','bigint') as ID,
														t.coreClipGuid,
														ReportXML.IQR.query('Title').value('.','varchar(max)') as Title,
														LTRIM(RTRIM(IQCore_Source.SourceID)) + '_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,112),1,13) + 
														'_' + SUBSTRING(CONVERT(VARCHAR(13),IQCore_Recording.Startdate,108),1,2) + '00' as IQ_CC_Key,
														IQCore_Recording.StartDate as GMTDatetime,
														[dbo].fnGetClipAdjustedDateTime([IQCore_Recording].[StartDate],IQ_Station.gmt_adj,IQ_Station.dst_adj,t.startOffset) AS LocalDatetime,
														ReportXML.IQR.query('NumberOfHits').value('.','tinyint') as Number_Hits,
														t.startOffset,
														ReportXML.IQR.query('HighlightingText').value('.','nvarchar(max)') as HighlightingText,
														ReportXML.IQR.query('MediaType').value('.','varchar(2)') as MediaType,
														ReportXML.IQR.query('SubMediaType').value('.','varchar(50)') as SubMediaType,
														ReportXML.IQR.query('v5MediaType').value('.','varchar(2)') as v5MediaType,
														ReportXML.IQR.query('v5SubMediaType').value('.','varchar(50)') as v5SubMediaType,
														ReportXML.IQR.query('PositiveSentiment').value('.','tinyint') as PositiveSentiment,
														ReportXML.IQR.query('NegativeSentiment').value('.','tinyint') as NegativeSentiment,
														@ReportKeywords as Keywords,
														@ReportDesc as [Description],
														Customer.FirstName,
														Customer.LastName,
														@ReportCustomerGuid as CustomerGuid,
														@ReportClientGuid as ClientGuid,
														@ReportCategoryGuid as CategoryGuid,
														@ReportSubCategory1Guid as SubCategory1Guid,
														@ReportSubCategory2Guid as SubCategory2Guid,
														@ReportSubCategory3Guid as SubCategory3Guid,
														ReportXML.IQR.query('DataModelType').value('.','varchar(10)') as DataModelType,
														ReportXML.IQR.query('SearchRequestID').value('.','bigint') as _SearchRequestID,
														ReportXML.IQR.query('SearchTerm').value('.','varchar(500)') as SearchTerm
												
												 From 
											
													@tempRadioTable t

													Inner Join @tmpRadioCoreClip tmpCoreClip
													ON tmpCoreClip._RecordfileGuid = t.RecordfileGuid
														AND tmpCoreClip.StartOffset = t.StartOffset
																						
													Inner Join Customer
													ON Customer.CustomerGuid = @ReportCustomerGuid
											
													Inner Join [IQCore_Recordfile] WITH (NOLOCK) 
													ON [IQCore_Recordfile].[Guid] = t.RecordfileGuid
											
													Inner Join [IQCore_Recording] WITH (NOLOCK) 
													ON [IQCore_Recordfile].[_RecordingID] = [IQCore_Recording].[ID]
											
													Inner Join [IQCore_Source] WITH (NOLOCK) 
													ON [IQCore_Recording].[_SourceGuid] = [IQCore_Source].[Guid]
											
													INNER JOIN @xml.nodes('/MediaResults/IQR/MediaResult') as ReportXML(IQR)
													ON ReportXML.IQR.query('ID').value('.', 'bigint') = tmpCoreClip.MediaResultID

													INNER JOIN IQ_Station
													ON ReportXML.IQR.query('StationID').value('.','varchar(150)') = IQ_station.IQ_Station_ID
										) as source on (1=0)
										WHEN NOT MATCHED THEN
											INSERT 
											(
												ClipGuid,
												Title,
												IQ_CC_Key,
												GMTDatetime,
												LocalDatetime,
												Number_Hits,
												StartOffset,
												HighlightingText,
												v5SubMediaType,
												PositiveSentiment,
												NegativeSentiment,
												Keywords,
												Description,
												FirstName,
												LastName,	
												CustomerGuid,
												ClientGuid,
												CategoryGuid,
												SubCategory1Guid,
												SubCategory2Guid,
												SubCategory3Guid,
												CreatedDate,
												ModifiedDate,
												IsActive
											)	
											values
											(
												coreClipGuid,
												Title,
												IQ_CC_Key,
												GMTDatetime,
												LocalDatetime,
												Number_Hits,
												StartOffset,
												HighlightingText,
												v5SubMediaType,
												PositiveSentiment,
												NegativeSentiment,
												Keywords,
												Description,
												FirstName,
												LastName,	
												CustomerGuid,
												ClientGuid,
												CategoryGuid,
												SubCategory1Guid,
												SubCategory2Guid,
												SubCategory3Guid,
												@CurrentDate,
												@CurrentDate,
												1
											)							
											OUTPUT INSERTED.ArchiveRadioKey as 'id',source.MediaType as 'mediaType',INSERTED.Title as 'title',
											INSERTED.GMTDatetime as 'mediaDate',source.SubMediaType as 'submediaType',INSERTED.CategoryGuid as 'categoryGuid',
											INSERTED.SubCategory1Guid 'subcategory1Guid',INSERTED.SubCategory2Guid 'subcategory2Guid',INSERTED.SubCategory3Guid 'subcategory3Guid',
											INSERTED.ClientGuid as 'clientGuid',INSERTED.CustomerGuid as 'customerGuid', INSERTED.ClipGuid as 'ArticleID',INSERTED.StartOffset as 'startOffset',
											(INSERTED.StartOffset + @AutoClipDuration - 1) as 'endoffset', INSERTED.HighlightingText as 'highlightingText', 
											INSERTED.PositiveSentiment as 'positiveSentiment', INSERTED.NegativeSentiment as 'negativeSentiment', null as 'Title120', 
											CONVERT(DATE, INSERTED.LocalDatetime) AS 'ClipDate', INSERTED.IQ_CC_Key, source.ID as _MediaID, source._SearchRequestID, source.SearchTerm, 
											null as 'content', source.v5MediaType as 'v5MediaType', INSERTED.v5SubMediaType as 'v5SubMediaType', 
											null as 'rollupType', source.DataModelType as 'dataModelType'
											into @tempTable;
										
	SET @QueryDetail ='insert into ArchiveRadio table from xml'
     SET @TimeDiff = DATEDIFF(ms, @Stopwatch, GETDATE())
     INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) VALUES(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
     SET @Stopwatch = GETDATE()			
	END																

								--==============================================
								-- IQArchive_Media
								--==============================================	

								IF OBJECT_ID('tempdb..#ArchiveMedia') IS NOT NULL
											DROP TABLE #ArchiveMedia
								
								CREATE TABLE #ArchiveMedia (ID BIGINT, CategoryGUID UNIQUEIDENTIFIER, SubCategory1GUID UNIQUEIDENTIFIER, SubCategory2GUID UNIQUEIDENTIFIER, SubCategory3GUID UNIQUEIDENTIFIER, 
															ClientGUID UNIQUEIDENTIFIER, Title120 VARCHAR(100), v5SubMediaType varchar(50), MediaID BIGINT, ClipDate DATE,ClipTitle nvarchar(max),
															MediaDate datetime,Station_Affil varchar(255), RollupType varchar(50))						
	
								
								Insert into IQArchive_Media(_ArchiveMediaID,MediaType,SubMediaType,Title,MediaDate,CategoryGuid,SubCategory1GUID,SubCategory2GUID,SubCategory3GUID,ClientGuid,CustomerGuid,
								IsActive,CreatedDate,highlightingText,PositiveSentiment,NegativeSentiment,_MediaID,_SearchRequestID,SearchTerm,Content,v5MediaType,v5SubMediaType)	
								OUTPUT INSERTED.ID, INSERTED.CategoryGUID, INSERTED.SubCategory1GUID, INSERTED.SubCategory2GUID, INSERTED.SubCategory3GUID, INSERTED.ClientGUID, NULL AS Title120, 
										INSERTED.v5SubMediaType, INSERTED._ArchiveMediaID AS MediaID, NULL AS ClipDate,inserted.Title as ClipTitle,inserted.MediaDate,NULL as Station_Affil, null as RollupType INTO #ArchiveMedia
								SELECT id,MediaType,subMediaType,title,mediaDate,categoryGuid,subcategory1Guid,subcategory2Guid,subcategory3Guid,clientGuid,CustomerGuid,1,@CurrentDate,highlightingText,
									positiveSentiment,negativeSentiment,_MediaID,_SearchRequestID,SearchTerm,Content,v5MediaType,v5SubMediaType
									 FROM @tempTable
								
								-- Can't set this field above because it isn't inserted into IQArchive_Media
								UPDATE #ArchiveMedia
								SET RollupType = tempTable.rollupType
								FROM #ArchiveMedia archiveMedia
								INNER JOIN @tempTable tempTable
									ON tempTable.id = archiveMedia.MediaID
									AND tempTable.v5SubMediaType = archiveMedia.v5SubMediaType

	SET @QueryDetail ='insert into iqarchive_media table from @temptable'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											

								-- used for NM Grouping , contains all possible parent/ child combinations
								DECLARE @MediaGroupTable TABLE (MediaID BIGINT, Title VARCHAR(max), MediaDate DATETime, CategoryGuid uniqueidentifier,ClientGuid uniqueidentifier,_ParentRecordID bigint,GroupRank int)  

								-- contains all parent media ids and details 
								DECLARE @MT TABLE (ArchiveMediaID BIGINT, TVID BIGINT, Title120 VARCHAR(100), ClipDate DATE, CategoryGUID UNIQUEIDENTIFIER, ClientGUID UNIQUEIDENTIFIER,ClipTitle nvarchar(max),GroupRank int,Station_Affil varchar(255))

								-- contains exact parent to child combination records
								DECLARE @Child TABLE(ArchiveMediaID BIGINT, ParentMediaID BIGINT)
								
								DECLARE @SecondsOnDay int= 86400
								DECLARE @2DaysTotalSeconds int= 172800

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
									#ArchiveMedia m1
										inner join
											IQArchive_Media m2 WITH (NOLOCK)
										on m1.ClipTitle=  m2.title
										and m1.v5SubMediaType = m2.v5SubMediaType
										and m1.CategoryGuid = m2.CategoryGuid
										and m1.ClientGuid = m2.ClientGuid
										and Cast((CAST(m1.mediadate AS float) - (CAST(m2.mediadate AS float))) * @SecondsOnDay as bigint) >= 0 and  Cast((CAST(m1.mediadate AS float) - (CAST(m2.mediadate AS float))) * @SecondsOnDay as bigint) <= @2DaysTotalSeconds
										and m1.ID != m2.ID
										and m2._ParentID is null
										and m2.IsActive= 1			
										and m1.RollupType = 'NM'
								order by m2.mediadate,m2.id

	SET @QueryDetail ='insert into @MediaGroupTable table from #ArchiveMedia table and archive_media table to find parent / child relations'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											

								/*start of set rank for each group fall in 48 hours */
								declare @RankID int,@RankUpdated bit

								SET @RankID  =1

								DECLARE @LastDate datetime

								UPDATE 
										@MediaGroupTable
								SET
										@RankID  = case when CAST((CAST(MediaDate AS float) - (CAST(@LastDate AS float))) * @SecondsOnDay as bigint) > @2DaysTotalSeconds then @RankID + 1  else @RankID end,
										@LastDate = case when CAST((CAST(MediaDate AS float) - (CAST(@LastDate AS float))) * @SecondsOnDay as bigint) > @2DaysTotalSeconds  or @LastDate is null then MediaDate else @LastDate end,
										GroupRank = @RankID

	SET @QueryDetail ='update grouprank for MediaGroupTable table'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											
								

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
										SELECT distinct
											row_number() over (partition by mtbl.CategoryGUID,mtbl.Title,mtbl.ClientGUID,mtbl.GroupRank order by mediadate asc,_ParentRecordID asc) as RowNumner,
											mtbl.Title,
											mtbl.CategoryGUID,
											mtbl.ClientGUID,
											_ParentRecordID AS MID,
											mtbl.GroupRank
										FROM   
											@MediaGroupTable mtbl 
									) as A
								Where RowNumner = 1


	SET @QueryDetail ='insert into @MT for all news parents'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											

								/* inseset child / parent record combinations into @Child table */
								Insert into @Child
								(
									ArchiveMediaID,
									ParentMediaID
								)
								Select
									distinct 
										MRTbl.MediaID,	
										MTbl.ArchiveMediaID AS ParentMediaID
								From
										@MediaGroupTable AS MRTbl
											INNER JOIN @MT AS MTbl
											 on MRTbl._ParentRecordID = MTbl.ArchiveMediaID
											 and MRTbl.MediaID != MTbl.ArchiveMediaID
											 and MRTbl.GroupRank = MTbl.GroupRank
	
	SET @QueryDetail ='populate @Child table for NM parent / child mapping'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											


								DELETE FROM 
									#ArchiveMedia
								WHERE
									ISNULL(RollupType, '') != 'TV'

	SET @QueryDetail ='delete from #ArchiveMedia where rolluptype != ''TV'''
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											
									 
								UPDATE #ArchiveMedia
									 SET Title120=TempMedia.Title120,
										 ClipDate=TempMedia.ClipDate,
										 Station_Affil = IQ_Station.Station_Affil
										 
								FROM
									#ArchiveMedia AS TempArchiveMedia
										INNER JOIN @tempTable AS TempMedia
											ON TempArchiveMedia.MediaID=TempMedia.ID
											AND TempArchiveMedia.v5SubMediaType=TempMedia.v5SubMediaType
										INNER JOIN IQ_Station 
											ON IQ_Station_ID =  SUBSTRING(TempMedia.IQ_CC_KEY,0 ,CHARINDEX('_',TempMedia.IQ_CC_KEY))

	SET @QueryDetail ='update archive media for title120 ,clipdate, station affil using join with @temptable'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											

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
										
								FROM #ArchiveMedia AS TempArchiveMedia		
										INNER JOIN ArchiveClip WITH (NOLOCK) 
											ON TempArchiveMedia.ClientGUID=ArchiveClip.ClientGUID
											AND	TempArchiveMedia.CategoryGUID=ArchiveClip.CategoryGUID
											AND TempArchiveMedia.ClipDate=CONVERT(Date,ArchiveClip.ClipDate)
											AND TempArchiveMedia.Title120=ArchiveClip.Title120
											and TempArchiveMedia.ClipTitle = ArchiveClip.ClipTitle
											AND TempArchiveMedia.MediaID!=ArchiveClip.ArchiveClipKey
										inner JOIN IQ_Station 
											on IQ_Station.IQ_Station_ID = SUBSTRING(ArchiveClip.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveClip.IQ_CC_Key))
											AND TempArchiveMedia.Station_Affil = IQ_Station.Station_Affil
										INNER JOIN IQArchive_Media WITH (NOLOCK)
											ON ArchiveClip.ArchiveClipKey=IQArchive_Media._ArchiveMediaID
											AND IQArchive_Media.v5SubMediaType=ArchiveClip.v5SubMediaType
											AND _ParentID IS NULL											
								WHERE 											
											IQArchive_Media.IsActive=1
									AND ArchiveClip.IsActive=1
								GROUP BY ArchiveClip.ClientGUID, ArchiveClip.CategoryGUID, CONVERT(Date,ArchiveClip.ClipDate),ArchiveClip.Title120,ArchiveClip.ClipTitle,TempArchiveMedia.Station_Affil

	SET @QueryDetail ='populate @MT table for all TV parent'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											

								INSERT INTO @Child
								(
									ArchiveMediaID,
									ParentMediaID
								)
								SELECT
										TempArchiveMedia.ID,
										MTbl.ArchiveMediaID AS ParentMediaID
								FROM
										#ArchiveMedia AS TempArchiveMedia
											INNER JOIN @MT AS MTbl
												ON		TempArchiveMedia.ClientGUID=MTbl.ClientGUID
													AND TempArchiveMedia.CategoryGUID=MTbl.CategoryGUID
													AND TempArchiveMedia.ClipDate=MTbl.ClipDate
													AND TempArchiveMedia.Title120=MTbl.Title120
													and TempArchiveMedia.ClipTitle = MTbl.ClipTitle
													AND TempArchiveMedia.Station_Affil = MTbl.Station_Affil

	SET @QueryDetail ='populate @Child table for TV parent / child mapping'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()											

														
								UPDATE 
										IQArchive_Media WITH (ROWLOCK)
								SET
										_ParentID= CASE WHEN ID=ParentMediaID THEN NULL ELSE ParentMediaID END
								FROM
										IQArchive_Media
											INNER JOIN	@Child AS Child
												ON		IQArchive_Media.ID=Child.ArchiveMediaID

	SET @QueryDetail ='uodate  IQArchive_Media for parentid using join with @Child table'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()			

							IF @HasNMRecords = 1
							BEGIN
								Insert Into @tempTable(id,ArticleID,dataModelType,v5SubMediaType)								
								Select 
									ArchiveNM.ArchiveNMKey,ReportXML.NM.query('ArticleID').value('.','varchar(50)'),ReportXML.NM.query('DataModelType').value('.','varchar(10)'),IQArchive_Media.v5SubMediaType
								From
																	
									@xml.nodes('/MediaResults/NM/MediaResult') as ReportXML(NM)
									
									Left Outer Join @tempTable t
									ON ReportXML.NM.query('ArticleID').value('.','varchar(50)') = t.ArticleID
									AND t.dataModelType = ReportXML.NM.query('DataModelType').value('.','varchar(10)')
									
									Inner Join ArchiveNM WITH (NOLOCK)
									ON ArchiveNM.ArticleID = ReportXML.NM.query('ArticleID').value('.','varchar(50)')
									AND ArchiveNM.ClientGuid = @ClientGuid
									Inner Join IQArchive_Media WITH (NOLOCK)
									ON IQArchive_Media._ArchiveMediaID = ArchiveNM.ArchiveNMKey
										and IQArchive_Media.v5SubMediaType = ArchiveNM.v5SubMediaType
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
										on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
									Where (t.ArticleID Is Null AND ReportXML2.ID.query('.').value('.','bigint') is Null)
							END	
							
							IF @HasSMRecords = 1
							BEGIN		
									-- Check If Data Not Inserted Into Archive Table than get ID and ArticleID for that -- SM
									Insert Into @tempTable(id,ArticleID,dataModelType,v5SubMediaType)								
								Select 
									ArchiveSM.ArchiveSMKey,ReportXML.SM.query('ArticleID').value('.','varchar(50)'),ReportXML.SM.query('DataModelType').value('.','varchar(10)'),IQArchive_Media.v5SubMediaType
								From
																	
									@xml.nodes('/MediaResults/SM/MediaResult') as ReportXML(SM)
									
									Left Outer Join @tempTable t
									ON ReportXML.SM.query('ArticleID').value('.','varchar(50)') = t.ArticleID
									AND t.dataModelType = ReportXML.SM.query('DataModelType').value('.','varchar(10)')
									
									Inner Join ArchiveSM WITH (NOLOCK)
									ON ArchiveSM.ArticleID = ReportXML.SM.query('ArticleID').value('.','varchar(50)')
									AND ArchiveSM.ClientGuid = @ClientGuid
									Inner Join IQArchive_Media WITH (NOLOCK)
									ON IQArchive_Media._ArchiveMediaID = ArchiveSM.ArchiveSMKey
										and IQArchive_Media.v5SubMediaType = ArchiveSM.v5SubMediaType
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
										on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
									Where (t.ArticleID Is Null AND ReportXML2.ID.query('.').value('.','bigint') is Null)
							END	
									
							IF @HasTWRecords = 1
							BEGIN		
									-- Check If Data Not Inserted Into Archive Table than get ID and ArticleID for that -- TW
									Insert Into @tempTable(id,ArticleID,dataModelType,v5SubMediaType)								
								Select 
									ArchiveTweets.ArchiveTweets_Key,ReportXML.TW.query('ArticleID').value('.','varchar(50)'),ReportXML.TW.query('DataModelType').value('.','varchar(10)'),IQArchive_Media.v5SubMediaType
								From
																	
									@xml.nodes('/MediaResults/TW/MediaResult') as ReportXML(TW)
									
									Left Outer Join @tempTable t
									ON ReportXML.TW.query('ArticleID').value('.','varchar(50)') = t.ArticleID
									AND t.dataModelType = ReportXML.TW.query('DataModelType').value('.','varchar(10)')
									
									Inner Join ArchiveTweets WITH (NOLOCK)
									ON ArchiveTweets.Tweet_ID = ReportXML.TW.query('ArticleID').value('.','varchar(50)')
									AND ArchiveTweets.ClientGuid = @ClientGuid
									Inner Join IQArchive_Media WITH (NOLOCK)
									ON IQArchive_Media._ArchiveMediaID = ArchiveTweets.ArchiveTweets_Key
										and IQArchive_Media.v5SubMediaType = ArchiveTweets.v5SubMediaType
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
										on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
									Where (t.ArticleID Is Null AND ReportXML2.ID.query('.').value('.','bigint') is Null)
							END		
							
							IF @HasTVRecords = 1
							BEGIN		
									Insert Into @tempTable(id,ArticleID,dataModelType,v5SubMediaType,startOffset,endOffset)								
								Select 
									MAX(ArchiveClip.ArchiveClipKey),
									MAX(CONVERT(varchar(40),IQCore_Clip.Guid)),
									IQ_MediaTypes.DataModelType,
									IQArchive_Media.v5SubMediaType,
									IQCore_Clip.StartOffset,
									IQCore_Clip.EndOffset
								From
																	
									@xml.nodes('/MediaResults/TV/MediaResult') as ReportXML(TV)
									
									Inner Join IQCore_Clip WITH (NOLOCK)
									ON IQCore_Clip._RecordFileGuid = ReportXML.TV.query('VideoGuid').value('.','uniqueidentifier')
										AND StartOffset = Case 
											When
												(cast(ReportXML.TV.query('min(HighlightedCCOutput/CC/ClosedCaption/Offset)').value('.','float') as int) - 8) >= 0
											Then
												cast(ReportXML.TV.query('min(HighlightedCCOutput/CC/ClosedCaption/Offset)').value('.','float') as int) - 8
											ELSE
												0
										END
										
										AND EndOffset = Case 
											When
												(cast(ReportXML.TV.query('min(HighlightedCCOutput/CC/ClosedCaption/Offset)').value('.','float') as int) - 8) >= 0
											Then
												(cast(ReportXML.TV.query('min(HighlightedCCOutput/CC/ClosedCaption/Offset)').value('.','float') as int) - 8) + @AutoClipDuration - 1
											ELSE
												@AutoClipDuration - 1
										END
									
									Inner Join ArchiveClip WITH (NOLOCK)
									ON ArchiveClip.ClipID = IQCore_Clip.Guid
									AND ArchiveClip.ClientGUID = @ReportClientGuid

									Inner Join IQ_MediaTypes WITH (NOLOCK)
									ON IQ_MediaTypes.SubMediaType = ArchiveClip.v5SubMediaType
									
									Left Outer Join @tempTable t
									ON t.ArticleID = cast(ArchiveClip.ClipID as varchar(max)) -- Since t.Article can hold non-GUID values, comparing to a uniqueidentifier can fail
									AND t.dataModelType = ReportXML.TV.query('DataModelType').value('.','varchar(10)')
									Inner Join IQArchive_Media WITH (NOLOCK)
									ON IQArchive_Media._ArchiveMediaID = ArchiveClip.ArchiveClipKey
										and IQArchive_Media.v5SubMediaType = ArchiveClip.v5SubMediaType
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
										on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
									Where (t.ArticleID Is Null AND ReportXML2.ID.query('.').value('.','bigint') is Null)
								group by IQCore_Clip._RecordFileGuid,IQCore_Clip.StartOffset,IQCore_Clip.EndOffset,IQ_MediaTypes.DataModelType,IQArchive_Media.v5SubMediaType
							END
							
							IF @HasTMRecords = 1
							BEGIN
									-- Check If Data Not Inserted Into Archive Table than get ID and _IQAgentID for that -- TM
								Insert Into @tempTable(id,ArticleID,dataModelType,v5SubMediaType)								
								Select 
									ArchiveTVEyes.ArchiveTVEyesKey,ReportXML.TM.query('MediaID').value('.','bigint'),ReportXML.TM.query('DataModelType').value('.','varchar(10)'),IQArchive_Media.v5SubMediaType
								From
																	
									@xml.nodes('/MediaResults/TM/MediaResult') as ReportXML(TM)
									
									Left Outer Join @tempTable t
									ON ReportXML.TM.query('MediaID').value('.','bigint') = t.ArticleID
									AND t.dataModelType = ReportXML.TM.query('DataModelType').value('.','varchar(10)')
									
									Inner Join ArchiveTVEyes WITH (NOLOCK)
									ON ArchiveTVEyes._IQAgentID = ReportXML.TM.query('MediaID').value('.','bigint')
									AND ArchiveTVEyes.ClientGUID = @ClientGuid
									Inner Join IQArchive_Media WITH (NOLOCK)
									ON IQArchive_Media._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
										and IQArchive_Media.v5SubMediaType = ArchiveTVEyes.v5SubMediaType
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
										on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
									Where (t.ArticleID Is Null AND ReportXML2.ID.query('.').value('.','bigint') is Null)
							END
							
							IF @HasPQRecords = 1
							BEGIN		
									-- Check If Data Not Inserted Into Archive Table than get ID and ArticleID for that -- PQ
									Insert Into @tempTable(id,ArticleID,dataModelType,v5SubMediaType)								
								Select 
									ArchivePQ.ArchivePQKey,ReportXML.PQ.query('ArticleID').value('.','varchar(50)'),ReportXML.PQ.query('DataModelType').value('.','varchar(10)'),IQArchive_Media.v5SubMediaType
								From
																	
									@xml.nodes('/MediaResults/PQ/MediaResult') as ReportXML(PQ)
									
									Left Outer Join @tempTable t
									ON ReportXML.PQ.query('ArticleID').value('.','varchar(50)') = t.ArticleID
									AND t.dataModelType = ReportXML.PQ.query('DataModelType').value('.','varchar(10)')
									
									Inner Join ArchivePQ WITH (NOLOCK)
									ON ArchivePQ.ProQuestID = ReportXML.PQ.query('ArticleID').value('.','varchar(50)')
									AND ArchivePQ.ClientGuid = @ClientGuid
									Inner Join IQArchive_Media WITH (NOLOCK)
									ON IQArchive_Media._ArchiveMediaID = ArchivePQ.ArchivePQKey
										and IQArchive_Media.v5SubMediaType = ArchivePQ.v5SubMediaType
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
										on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
									Where (t.ArticleID Is Null AND ReportXML2.ID.query('.').value('.','bigint') is Null)
							END	
							
							IF @HasIQRRecords = 1
							BEGIN		
									Insert Into @tempTable(id,ArticleID,dataModelType,v5SubMediaType,startOffset,endOffset)								
								Select 
									MAX(ArchiveRadio.ArchiveRadioKey),
									MAX(CONVERT(varchar(40),IQCore_Clip.Guid)),
									IQ_MediaTypes.DataModelType,
									IQArchive_Media.v5SubMediaType,
									IQCore_Clip.StartOffset,
									IQCore_Clip.EndOffset
								From
																	
									@xml.nodes('/MediaResults/IQR/MediaResult') as ReportXML(IQR)
									
									Inner Join IQCore_Clip WITH (NOLOCK)
									ON IQCore_Clip._RecordFileGuid = ReportXML.IQR.query('Guid').value('.','uniqueidentifier')
										AND StartOffset = Case 
											When
												(cast(ReportXML.IQR.query('min(HighlightedCCOutput/CC/ClosedCaption/Offset)').value('.','float') as int) - 8) >= 0
											Then
												cast(ReportXML.IQR.query('min(HighlightedCCOutput/CC/ClosedCaption/Offset)').value('.','float') as int) - 8
											ELSE
												0
										END
										
										AND EndOffset = Case 
											When
												(cast(ReportXML.IQR.query('min(HighlightedCCOutput/CC/ClosedCaption/Offset)').value('.','float') as int) - 8) >= 0
											Then
												(cast(ReportXML.IQR.query('min(HighlightedCCOutput/CC/ClosedCaption/Offset)').value('.','float') as int) - 8) + @AutoClipDuration - 1
											ELSE
												@AutoClipDuration - 1
										END
									
									Inner Join ArchiveRadio WITH (NOLOCK)
									ON ArchiveRadio.ClipGuid = IQCore_Clip.Guid
									AND ArchiveRadio.ClientGUID = @ReportClientGuid

									Inner Join IQ_MediaTypes WITH (NOLOCK)
									ON IQ_MediaTypes.SubMediaType = ArchiveRadio.v5SubMediaType
									
									Left Outer Join @tempTable t
									ON t.ArticleID = cast(ArchiveRadio.ClipGuid as varchar(max)) -- Since t.Article can hold non-GUID values, comparing to a uniqueidentifier can fail
									AND t.dataModelType = ReportXML.IQR.query('DataModelType').value('.','varchar(10)')
									Inner Join IQArchive_Media WITH (NOLOCK)
									ON IQArchive_Media._ArchiveMediaID = ArchiveRadio.ArchiveRadioKey
										and IQArchive_Media.v5SubMediaType = ArchiveRadio.v5SubMediaType
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
										on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
									Where (t.ArticleID Is Null AND ReportXML2.ID.query('.').value('.','bigint') is Null)
								group by IQCore_Clip._RecordFileGuid,IQCore_Clip.StartOffset,IQCore_Clip.EndOffset,IQ_MediaTypes.DataModelType,IQArchive_Media.v5SubMediaType
							END

							insert into @tempTable(id,dataModelType,v5SubMediaType)
							select 
								IQAgent_BLPMResults._ArchiveBLPMID,ReportXML.PM.query('DataModelType').value('.','varchar(10)'),IQArchive_Media.v5SubMediaType
								from 
									@xml.nodes('/MediaResults/PM/MediaResult') as ReportXML(PM)
										Inner Join IQAgent_BLPMResults WITH (NOLOCK)
											ON ReportXML.PM.query('MediaID').value('.','bigint') = IQAgent_BLPMResults.ID
										inner join IQArchive_Media WITH (NOLOCK) 
											ON IQArchive_Media.v5SubMediaType = ReportXML.PM.query('v5SubMediaType').value('.','varchar(50)')
											and IQArchive_Media._ArchiveMediaID = IQAgent_BLPMResults._ArchiveBLPMID
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
											on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
								where
										ReportXML2.ID.query('.').value('.','bigint') is Null

							insert into @tempTable(id,dataModelType,v5SubMediaType)
							select 
								IQAgent_BLPMResults_Archive._ArchiveBLPMID,ReportXML.PM.query('DataModelType').value('.','varchar(10)'),IQArchive_Media.v5SubMediaType
								from 
									@xml.nodes('/MediaResults/PM/MediaResult') as ReportXML(PM)
										Inner Join IQAgent_BLPMResults_Archive WITH (NOLOCK)
											ON ReportXML.PM.query('MediaID').value('.','bigint') = IQAgent_BLPMResults_Archive.ID
										inner join IQArchive_Media WITH (NOLOCK) 
											ON IQArchive_Media.v5SubMediaType = ReportXML.PM.query('v5SubMediaType').value('.','varchar(50)')
											and IQArchive_Media._ArchiveMediaID = IQAgent_BLPMResults_Archive._ArchiveBLPMID
										left outer join @ReportRule.nodes('/Report/Library/ArchiveMediaSet/ID') as ReportXML2(ID)
											on IQArchive_Media.ID =ReportXML2.ID.query('.').value('.','bigint')
								where
										ReportXML2.ID.query('.').value('.','bigint') is Null

	SET @QueryDetail ='insert into @temptable for all items which not inserted in current transaction (already exist in archive tables)'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()			

			IF @HasTVRecords = 1
			BEGIN
				UPDATE ArchiveClip WITH (ROWLOCK)
				SET 
					IsActive = 1 
				FROM 
					ArchiveClip 
						INNER JOIN @tempTable t
								on (ArchiveClip.ArchiveClipKey = t.id  or ArchiveClip.ArchiveClipKey = (SELECT m1._ArchiveMediaID From IQArchive_Media m1 WITH (NOLOCK) INNER JOIN IQArchive_Media m2 WITH (NOLOCK) on m1.ID = m2._ParentID and m2._ArchiveMediaID =t.id and m1.v5SubMediaType = m2.v5SubMediaType and m1.v5SubMediaType=t.v5SubMediaType and m1.ClientGUID = @ClientGuid))
								AND t.v5SubMediaType = ArchiveClip.v5SubMediaType
								AND ArchiveClip.ClientGUID = @ClientGuid
			END
			
			IF @HasNMRecords = 1
			BEGIN
				UPDATE ArchiveNM WITH (ROWLOCK)
				SET
					IsActive = 1
				FROM 
					ArchiveNM
						Inner Join @tempTable t
						ON (ArchiveNM.ArchiveNMKey = t.id or ArchiveNM.ArchiveNMKey = (SELECT m1._ArchiveMediaID From IQArchive_Media m1 WITH (NOLOCK) INNER JOIN IQArchive_Media m2 WITH (NOLOCK) on m1.ID = m2._ParentID and m2._ArchiveMediaID =t.id and m1.v5SubMediaType = m2.v5SubMediaType and m1.v5SubMediaType=t.v5SubMediaType and m1.ClientGUID = @ClientGuid))
						AND t.v5SubMediaType = ArchiveNM.v5SubMediaType
						AND ArchiveNM.ClientGuid=@ClientGuid
			END
			
			IF @HasSMRecords = 1
			BEGIN		
				UPDATE ArchiveSM WITH (ROWLOCK)
				SET
					IsActive = 1
				FROM 
					ArchiveSM
						Inner Join @tempTable t
						ON ArchiveSM.ArchiveSMKey = t.id
						AND t.v5SubMediaType = ArchiveSM.v5SubMediaType
						AND ArchiveSM.ClientGuid=@ClientGuid
			END
			
			IF @HasTWRecords = 1
			BEGIN
				UPDATE ArchiveTweets WITH (ROWLOCK)
				SET
					IsActive = 1
				FROM 
					ArchiveTweets
						Inner Join @tempTable t
						ON ArchiveTweets.ArchiveTweets_Key = t.id
						AND t.v5SubMediaType = ArchiveTweets.v5SubMediaType
						AND ArchiveTweets.ClientGuid=@ClientGuid
			END

			IF @HasTMRecords = 1
			BEGIN
				UPDATE ArchiveTVEyes WITH (ROWLOCK)
				SET
					IsActive = 1
				FROM 
					ArchiveTVEyes
						Inner Join @tempTable t
						ON ArchiveTVEyes.ArchiveTVEyesKey = t.id
						AND t.v5SubMediaType = ArchiveTVEyes.v5SubMediaType
						AND ArchiveTVEyes.ClientGuid=@ClientGuid
			END

			If @HasPQRecords = 1
			BEGIN
				UPDATE ArchivePQ WITH (ROWLOCK)
				SET
					IsActive = 1
				FROM
					ArchivePQ
						Inner Join @tempTable t
						ON ArchivePQ.ArchivePQKey = t.id
						AND t.v5SubMediaType = ArchivePQ.v5SubMediaType
						AND ArchivePQ.ClientGUID = @ClientGuid
			END

			IF @HasIQRRecords = 1
			BEGIN
				UPDATE ArchiveRadio WITH (ROWLOCK)
				SET
					IsActive = 1
				FROM
					ArchiveRadio
						Inner Join @tempTable t
						ON ArchiveRadio.ArchiveRadioKey = t.id
						AND t.v5SubMediaType = ArchiveRadio.v5SubMediaType
						AND ArchiveRadio.ClientGUID = @ClientGuid
			END

				UPDATE ArchiveBLPM WITH (ROWLOCK)
				SET
					IsActive = 1
				FROM
					ArchiveBLPM 
						inner join @tempTable t
						on ArchiveBLPM.ArchiveBLPMKey = t.id
						AND t.v5SubMediaType = ArchiveBLPM.v5SubMediaType
						and ArchiveBLPM.ClientGUID = @ClientGuid



				UPDATE IQArchive_Media
				SET
					IsActive = 1
				FROM 
					IQArchive_Media
						Inner Join @tempTable t
						ON (IQArchive_Media._ArchiveMediaID = t.id or IQArchive_Media._ArchiveMediaID = (SELECT m1._ArchiveMediaID From IQArchive_Media m1 WITH (NOLOCK) INNER JOIN IQArchive_Media m2 WITH (NOLOCK) on m1.ID = m2._ParentID and m2._ArchiveMediaID =t.id and m1.v5SubMediaType = m2.v5SubMediaType and m1.v5SubMediaType=t.v5SubMediaType and m1.ClientGUID = @ClientGuid))
						AND t.v5SubMediaType = IQArchive_Media.v5SubMediaType 
						AND IQArchive_Media.ClientGuid=@ClientGuid
	
	SET @QueryDetail ='update all archive table set isactive = 1 if they are in deleted state using join with @temptable'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()			
									
		--==============================================
		-- Create XML
		--==============================================						
DECLARE @RootElement XML = ''
declare @TVXML XML							
declare @NMXML XML
declare @SMXML XML
declare @TWXML XML
declare @TMXML XML
declare @PMXXML XML
declare @PQXML XML
declare @IQRXML XML



declare @TempArchiveMedia table (ID bigint)

insert into @TempArchiveMedia
Select
		IQArchive_Media.ID
From
		@tempTable as tmpTbl
			inner join IQArchive_Media WITH (NOLOCK)
				on	tmpTbl.ID=IQArchive_Media._ArchiveMediaID 
				AND	tmpTbl.v5SubMediaType=IQArchive_Media.v5SubMediaType		

SET @QueryDetail ='populate @TempArchiveMedia table from @tempTable to generate iq_Report report rule'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()			
		
							
select @NMXML = (Select t.ID,ArticleID,case when IQAgent_MissingArticles.ID IS NULL THEN 1 ELSE 0 END as Content 
								From 
									@tempTable t
										left outer join IQAgent_MissingArticles WITH (NOLOCK)
											on t.ArticleID = IQAgent_MissingArticles.ID 		
											and IQAgent_MissingArticles.Category ='NM'
								where 
									dataModelType = 'NM'
								FOR XML Path('SubMedia'))
								
select @TVXML = (Select ID,ArticleID,1 as CC,StartOffset,EndOffset,1 as Export,1 as ThumbGen,1 as IOSExport 
								From 
									@tempTable t
								where 
									dataModelType = 'TV' 
								FOR XML Path('SubMedia'))			
								
select @SMXML = (Select t.ID,ArticleID,case when IQAgent_MissingArticles.ID IS NULL THEN 1 ELSE 0 END as Content 
								From 
									@tempTable t
										left outer join IQAgent_MissingArticles WITH (NOLOCK)
											on t.ArticleID = cast(IQAgent_MissingArticles.ID as varchar(50)) -- Not all article IDs are ints, so this breaks without the conversion
											and IQAgent_MissingArticles.Category != 'NM'
										inner join IQ_MediaTypes
											on t.v5SubMediaType = IQ_MediaTypes.SubMediaType
								where 
									t.dataModelType = 'SM' 
									AND IQ_MediaTypes.UseHighlightingText = 1 -- If highlighting text isn't used, the content doesn't need to be retrieved via ArchiveMetaDataUpdate
								FOR XML Path('SubMedia'))			
								
select @TWXML = (Select ID,ArticleID,1 as Content 
								From 
									@tempTable t
								where 
									dataModelType = 'TW' 
								FOR XML Path('SubMedia'))

select @TMXML = (Select ID,ArticleID
								From 
									@tempTable t
								
								where 
									dataModelType = 'TM' 
								FOR XML Path('SubMedia'))


select @PMXXML = (Select ID
								From 
									@tempTable t
								
								where 
									dataModelType = 'PM' 
								FOR XML Path('SubMedia'))

select @PQXML = (Select ID, ArticleID, 1 as Content
								From
									@tempTable t
								where
									dataModelType = 'PQ'
								FOR XML PATH('SubMedia'))
								
select @IQRXML = (Select ID,ArticleID,1 as CC,StartOffset,EndOffset,1 as Export,1 as IOSExport 
								From 
									@tempTable t
								where 
									dataModelType = 'IQR' 
								FOR XML Path('SubMedia'))	


	
SET @QueryDetail ='create specific media xml using @tempTable'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()			
								

			-- if ArchiveTracking is Not null than it is "Add To Report"
			IF((Select ArchiveTracking From IQReport_Feeds where ID = @ReportID) IS NULL)
				BEGIN		
								
					SET @RootElement = '<Media></Media>'
					select @TVXML	= '<TV>'  + cast(@TVXML as varchar(max))+ '</TV>'
					select @NMXML	= '<NM>' + cast(@NMXML as varchar(max))+ '</NM>'
					select @SMXML	 = '<SM>' + cast(@SMXML as varchar(max))+ '</SM>'
					select @TWXML	 = '<TW>' + cast(@TWXML as varchar(max))+ '</TW>'
					select @TMXML	 = '<TM>' + cast(@TMXML as varchar(max))+ '</TM>'
					select @PMXXML  =	'<PM>' + cast(@PMXXML as varchar(max))+ '</PM>'			
					select @PQXML = '<PQ>' + cast(@PQXML as varchar(max)) + '</PQ>'		
					select @IQRXML = '<IQR>' + cast(@IQRXML as varchar(max)) + '</IQR>'		

					SET @RootElement.modify('insert sql:variable("@TVXML") as last into (/Media)[1]')
					SET @RootElement.modify('insert sql:variable("@NMXML") as last into (/Media)[1]')
					SET @RootElement.modify('insert sql:variable("@SMXML") as last into (/Media)[1]')
					SET @RootElement.modify('insert sql:variable("@TWXML") as last into (/Media)[1]')
					SET @RootElement.modify('insert sql:variable("@TMXML") as last into (/Media)[1]')
					SET @RootElement.modify('insert sql:variable("@PMXXML") as last into (/Media)[1]')
					set @RootElement.modify('insert sql:variable("@PQXML") as last into (/Media)[1]')
					set @RootElement.modify('insert sql:variable("@IQRXML") as last into (/Media)[1]')
				END										
			ELSE -- if ArchiveTracking is Not null than it is "Add To Report" && So We need to Append Submedia Element only
				BEGIN					
				
						Select @RootElement =  ArchiveTracking From IQReport_Feeds where ID = @ReportID
						Declare @ArchiveCurrentXML XML
						Select @ArchiveCurrentXML  = ArchiveTracking From IQReport_Feeds where ID = @ReportID
						
						--IF TV EXISTS THAN APPEND SUBMEDIA ONLY OTHERWISE APPEND WITH TV ELEMENT + SUBMEDIA
						IF(@ArchiveCurrentXML.exist('(//TV)') = 0)
							BEGIN
								SELECT @TVXML	= '<TV>'  + cast(@TVXML as varchar(max))+ '</TV>'
								SET @RootElement.modify('insert sql:variable("@TVXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN							
								SET @RootElement.modify('insert sql:variable("@TVXML") as last into (/Media/TV)[1]')								
							END	
						
						
						IF(@ArchiveCurrentXML.exist('(//NM)') = 0)
							BEGIN
								SELECT @NMXML	= '<NM>' + cast(@NMXML as varchar(max))+ '</NM>'
								SET @RootElement.modify('insert sql:variable("@NMXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@NMXML") as last into (/Media/NM)[1]')
							END
						
						IF(@ArchiveCurrentXML.exist('(//SM)') = 0)
							BEGIN
								SELECT @SMXML	= '<SM>' + cast(@SMXML as varchar(max))+ '</SM>'
								SET @RootElement.modify('insert sql:variable("@SMXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@SMXML") as last into (/Media/SM)[1]')
							END
							
						
						IF(@ArchiveCurrentXML.exist('(//TW)') = 0)
							BEGIN
								SELECT @TWXML	= '<TW>' + cast(@TWXML as varchar(max))+ '</TW>'
								SET @RootElement.modify('insert sql:variable("@TWXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@TWXML") as last into (/Media/TW)[1]')
							END


						IF(@ArchiveCurrentXML.exist('(//TM)') = 0)
							BEGIN
								SELECT @TMXML	= '<TM>' + cast(@TMXML as varchar(max))+ '</TM>'
								SET @RootElement.modify('insert sql:variable("@TMXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@TMXML") as last into (/Media/TM)[1]')
							END


						IF(@ArchiveCurrentXML.exist('(//PM)') = 0)
							BEGIN
								SELECT @TMXML	= '<PM>' + cast(@TMXML as varchar(max))+ '</PM>'
								SET @RootElement.modify('insert sql:variable("@PMXXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@PMXXML") as last into (/Media/PM)[1]')
							END


						IF(@ArchiveCurrentXML.exist('(//PQ)') = 0)
							BEGIN
								SELECT @PQXML	= '<PQ>' + cast(@PQXML as varchar(max))+ '</PQ>'
								SET @RootElement.modify('insert sql:variable("@PQXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@PQXML") as last into (/Media/PQ)[1]')
							END


						IF(@ArchiveCurrentXML.exist('(//IQR)') = 0)
							BEGIN
								SELECT @PQXML	= '<IQR>' + cast(@IQRXML as varchar(max))+ '</IQR>'
								SET @RootElement.modify('insert sql:variable("@IQRXML") as last into (/Media)[1]')
							END
						ELSE
							BEGIN
								SET @RootElement.modify('insert sql:variable("@IQRXML") as last into (/Media/IQR)[1]')
							END
				END					

SET @QueryDetail ='set @RootElement for achive tracking xml'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()								
		
		
		--Now Update IQReport_Feeds table's ArchiveTracking column with this XML
		
		Update IQReport_Feeds
		Set ArchiveTracking = @RootElement,
		LastModified = GETDATE()
		Where ID = @ReportID			
	

	SET @QueryDetail ='update IQReport_Feeds for ArchiveTracking with @RootElement'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()								

	
		-- Insert Record into IQ_Report
		
		declare @IQReportChild xml
		Select @IQReportChild = (Select cast('<ID>' + cast(ID as varchar(50)) +'</ID>' as xml)
								From 
									@TempArchiveMedia 
								
								FOR XML Path(''))
						
	SET @QueryDetail ='create xml for IQ_Report Report Rule using @TempArchiveMedia table'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()								
		
		
		Declare @FeedsReportGuid uniqueidentifier
		Set @FeedsReportGuid = NewID()
		
		IF((Select ReportRule From IQ_Report where ReportGUID = (Select ReportGuid from IQReport_Feeds Where ID = @ReportID)) IS NULL)
		BEGIN
			DECLARE @IQReportRootElement XML = '<Report><Library><ArchiveMediaSet></ArchiveMediaSet></Library></Report>'
			SET @IQReportRootElement.modify('insert sql:variable("@IQReportChild") as last into (/Report/Library/ArchiveMediaSet)[1]')
			Update IQ_Report
			Set ReportRule = @IQReportRootElement				
			Where ReportGuid = (Select ReportGuid from IQReport_Feeds Where ID = @ReportID)
		END
		ELSE
		BEGIN
			Update IQ_Report
			Set ReportRule.modify('insert sql:variable("@IQReportChild") as last into (/Report/Library/ArchiveMediaSet)[1]')
			Where ReportGuid = (Select ReportGuid from IQReport_Feeds Where ID = @ReportID)
		END
		
		SET @QueryDetail ='update report rule of IQ_REport table'
    SET @TimeDiff = DateDiff(ms, @Stopwatch, GetDate())
    INSERT INTO @logTable([Guid],SPName,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,@QueryDetail,@TimeDiff)
    SET @Stopwatch = GetDate()								
		Select 1
		
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
				@CreatedBy='usp_v5_svc_Report_Feeds_Insert',
				@ModifiedBy='usp_v5_svc_Report_Feeds_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
				
		Select -1
	END CATCH
		
		DECLARE @TypeID	BIGINT
		DECLARE @Status VARCHAR(20)
		
		SELECT	@TypeID = JobTypeID,
				@Status = Status
		FROM	IQReport_Feeds
		WHERE	ID = @ReportID
		
		exec usp_Service_JobMaster_UpdateStatus @ReportID, @Status, @ModifiedDate, @TypeID

		INSERT INTO IQ_SPTimeTracking([Guid], SPName, QueryDetail, TotalTime)
		SELECT [Guid], SPName, QueryDetail, TotalTime
		FROM @logTable

		SET @QueryDetail ='0'
		SET @TimeDiff = DateDiff(ms, @SPStartTime, GetDate())
		INSERT INTO IQ_SPTimeTracking([Guid],SPName,Input,QueryDetail,TotalTime) values(@SPTrackingID,@SPName,'<Input><ReportID>'+ convert(nvarchar(max),@ReportID) +'</ReportID><@XML>'+ convert(nvarchar(max),@XML) +'</@XML></Input>',@QueryDetail,@TimeDiff)
END

