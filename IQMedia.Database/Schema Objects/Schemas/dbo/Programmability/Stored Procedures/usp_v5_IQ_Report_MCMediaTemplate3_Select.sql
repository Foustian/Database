CREATE PROCEDURE [dbo].[usp_v5_IQ_Report_MCMediaTemplate3_Select]
	@ReportGUID	UNIQUEIDENTIFIER,
	@SearchSettings XML
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ReportXML AS XML,
			@ReportImage varchar(255),
			@MasterClientGuid UNIQUEIDENTIFIER,
			@MasterClientID BIGINT
	DECLARE @NielsenAccess bit, @CompeteAccess bit

	DECLARE @SearchTerm VARCHAR(MAX)
	DECLARE @SubMediaType VARCHAR(50)
	DECLARE @SelectionType VARCHAR(3)

	SELECT	@SearchTerm = CASE ISNULL(tbl.s.value('SearchTerm[1]', 'varchar(max)'), '') WHEN '' THEN NULL ELSE tbl.s.value('SearchTerm[1]', 'varchar(max)') END,
			@SubMediaType = CASE ISNULL(tbl.s.value('SubMediaType[1]', 'varchar(50)'), '') WHEN '' THEN NULL ELSE tbl.s.value('SubMediaType[1]', 'varchar(50)') END,
			@SelectionType = CASE ISNULL(tbl.s.value('SelectionType[1]', 'varchar(3)'), '') WHEN '' THEN NULL ELSE tbl.s.value('SelectionType[1]', 'varchar(3)') END
	FROM	@SearchSettings.nodes('SearchSettings') as tbl(s)

	SELECT	@ReportXML = ReportRULE,
			@ReportImage = Location,
			@MasterClientGuid = IQ_Report.ClientGuid
	FROM	IQ_Report 
	INNER JOIN IQ_ReportType
		ON IQ_Report._ReportTypeID = IQ_ReportType.ID
	LEFT OUTER JOIN IQClient_CustomImage 
		ON IQClient_CustomImage._ClientGUID = IQ_Report.ClientGuid
		AND IQClient_CustomImage.IsDefault = 1 AND IQClient_CustomImage.IsActive = 1
	WHERE	ReportGUID = @ReportGUID
	AND		IQ_Report.IsActive = 1
	AND		IQ_ReportType.IsActive = 1

	SELECT	@MasterClientID = ClientKey
	FROM	Client
	WHERE	ClientGUID = @MasterClientGuid


	SET @NielsenAccess = 0
	SET @CompeteAccess = 0

	Select 
		@NielsenAccess = NielSenData,
		@CompeteAccess  = CompeteData
	FROM
	(
		SELECT
			Rolename,   
			CAST(ClientRole.IsAccess AS INT) AS IsAccess		
		FROM         
			dbo.Role INNER JOIN
			dbo.ClientRole ON dbo.Role.RoleKey = dbo.ClientRole.RoleID INNER JOIN
			dbo.Client on ClientRole.ClientID = Client.ClientKey
			and Client.IsActive = 1 and ClientRole.IsAccess = 1 and role.IsActive = 1		
		WHERE
			Client.ClientGuid = @MasterClientGuid
	) as a pivot
	(
		max([IsAccess])
		FOR [RoleName] IN ([NielSenData],[CompeteData])
	)AS B

	DECLARE @tblIQMedia_Archive AS TABLE
	(
		ID					BIGINT,
		_ArchiveMediaID		BIGINT,
		MediaType			VARCHAR(10),
		MediaDate			DATETIME,		
		ClientGUID			UNIQUEIDENTIFIER,	
		ClientName			VARCHAR(100),
		Title				NVARCHAR(500),			
		SubMediaType		VARCHAR(50),
		HighlightingText	NVARCHAR(MAX),
		Content				NVARCHAR(MAX),
		CategoryGUID		UNIQUEIDENTIFIER,
		PositiveSentiment	tinyint,
		NegativeSentiment	tinyint,
		DisplayDescription	BIT
	)

	IF (@SearchSettings.exist('SearchSettings/CategorySet[@IsAllowAll="true"]') = 1)
	  BEGIN
		INSERT INTO @tblIQMedia_Archive
		(
			ID
		)
		SELECT	
			tbl.c.query('.').value('.','bigint') 
		FROM	
			@ReportXML.nodes('MediaResults/ID') as tbl(c)
		INNER JOIN IQArchive_Media WITH (NOLOCK)	
			ON IQArchive_Media.ID = tbl.c.query('.').value('.','bigint') 
		INNER JOIN IQArchive_MCMedia WITH (NOLOCK)
			ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
			AND IQArchive_MCMedia.MasterClientGUID = @MasterClientGuid
		WHERE 
			IQArchive_Media.IsActive = 1
			AND IQArchive_MCMedia.IsActive = 1
			AND	(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
			AND	(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
	  END
	ELSE
	  BEGIN
		DECLARE @TotalCats INT
		DECLARE @TempTable table(CategoryGuid uniqueidentifier, CategoryName varchar(150))

		-- If multiple clients within a master client have categories with the same name, they're grouped together by name for filtering purposes.
		-- Split them out into their individual GUIDs, making sure to filter out categories with the same name on other clients.
		INSERT INTO @TempTable
		SELECT	CategoryGUID,
				CategoryName
		FROM	CustomCategory
		INNER	JOIN @SearchSettings.nodes('SearchSettings/CategorySet/Category') as cat(item)
				ON CustomCategory.CategoryName = cat.item.value('.','varchar(150)')
		INNER	JOIN Client
				ON CustomCategory.ClientGUID = Client.ClientGUID
				AND Client.MCID = @MasterClientID

		SELECT @TotalCats = count(distinct CategoryName) FROM @TempTable as t

		IF(UPPER(@SelectionType) = 'AND')
		  BEGIN
			INSERT INTO @tblIQMedia_Archive
			(
				ID
			)
			SELECT	
				tbl.c.query('.').value('.','bigint') 
			FROM	
				@ReportXML.nodes('MediaResults/ID') as tbl(c)
			INNER JOIN IQArchive_Media WITH (NOLOCK)	
				ON IQArchive_Media.ID = tbl.c.query('.').value('.','bigint') 
			INNER JOIN IQArchive_MCMedia WITH (NOLOCK)
				ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
				AND IQArchive_MCMedia.MasterClientGUID = @MasterClientGuid
			WHERE 
				(
					IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
				)		
				AND IQArchive_Media.IsActive = 1
				AND IQArchive_MCMedia.IsActive = 1
				AND	(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND	(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
				AND (CASE WHEN  IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
								1
						ELSE
								0
						END + 
						CASE WHEN  IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
								1
						ELSE
								0
						END +
						CASE WHEN  IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
								1
						ELSE
								0
						END +
						CASE WHEN  IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1) THEN
								1
						ELSE
								0 END
					) >= CASE WHEN @TotalCats < 4 THEN @TotalCats ELSE 4 END
		  END
		ELSE
		  BEGIN
			INSERT INTO @tblIQMedia_Archive
			(
				ID
			)
			SELECT	
				tbl.c.query('.').value('.','bigint') 
			FROM	
				@ReportXML.nodes('MediaResults/ID') as tbl(c)
			INNER JOIN IQArchive_Media WITH (NOLOCK)	
				ON IQArchive_Media.ID = tbl.c.query('.').value('.','bigint') 
			INNER JOIN IQArchive_MCMedia WITH (NOLOCK)
				ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
				AND IQArchive_MCMedia.MasterClientGUID = @MasterClientGuid
			WHERE 
				(
					IQArchive_Media.CategoryGUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory1GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory2GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
						OR IQArchive_Media.SubCategory3GUID in (SELECT t1.CategoryGUID FROM @TempTable t1)
				)	
				AND IQArchive_Media.IsActive = 1
				AND IQArchive_MCMedia.IsActive = 1
				AND	(@SearchTerm IS NULL OR (Content LIKE '%' + @SearchTerm + '%' OR Title LIKE '%' + @SearchTerm + '%'))
				AND	(@SubMediaType IS NULL OR v5SubMediaType = @SubMediaType)
		  END
	  END
		
	UPDATE @tblIQMedia_Archive	
	SET		_ArchiveMediaID = IQArchive_Media._ArchiveMediaID,
			MediaType = IQArchive_Media.v5MediaType,		
			HighlightingText = IQArchive_Media.HighlightingText,
			Content = IQArchive_Media.Content,
			MediaDate = IQArchive_Media.MediaDate,		
			ClientGUID = IQArchive_Media.ClientGUID,	
			ClientName = Client.ClientName,
			Title = IQArchive_Media.Title,			
			SubMediaType = IQArchive_Media.v5SubMediaType,
			CategoryGUID = IQArchive_Media.CategoryGUID,
			PositiveSentiment = IQArchive_Media.PositiveSentiment,
			NegativeSentiment = IQArchive_Media.NegativeSentiment,
			DisplayDescription = IQArchive_Media.DisplayDescription						
	FROM	@tblIQMedia_Archive AS tblIQMedia_Archive
	INNER	JOIN IQArchive_Media WITH (NOLOCK)
		ON IQArchive_Media.ID = tblIQMedia_Archive.ID
		AND IQArchive_Media.ClientGUID IS NOT NULL -- Included for indexing
	INNER	JOIN Client
		ON Client.ClientGUID = IQArchive_Media.ClientGUID

	
	SELECT	'HeaderInfo' AS TableType,
			@ReportImage AS ReportImage, 
			@MasterClientGuid AS MasterClientGuid
	
	IF @ReportXML IS NOT NULL
		BEGIN		

			-- Fill ArchiveBLPM table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				tblIQMedia_Archive.MediaDate,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				ArchiveBLPM.Circulation,
				ArchiveBLPM.FileLocation,
				ArchiveBLPM.Pub_Name,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description,
				tblIQMedia_Archive.DisplayDescription
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchiveBLPM WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveBLPM.ArchiveBLPMKey
				AND	tblIQMedia_Archive.SubMediaType = ArchiveBLPM.v5SubMediaType
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2
    
			-- Fill ArchiveClip table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				tblIQMedia_Archive.MediaDate,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				ArchiveClip.ClipID,
				ArchiveClip.ClipDate,
				case when @NielsenAccess = 1  then Nielsen_Audience else null end as Nielsen_Audience,
				case when @NielsenAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
				Nielsen_Result,
				Dma_Name as 'Market',
				IQ_Station_ID as 'StationLogo',
				IQ_Station.TimeZone,
				Dma_Num,
				tblIQMedia_Archive.PositiveSentiment,
				tblIQMedia_Archive.NegativeSentiment,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description,
				tblIQMedia_Archive.DisplayDescription
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchiveClip WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveClip.ArchiveClipKey
				AND	tblIQMedia_Archive.SubMediaType = ArchiveClip.v5SubMediaType
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2
			INNER JOIN IQCore_Clip 
				ON ArchiveClip.ClipID = IQCore_Clip.[Guid]
			LEFT JOIN IQ_Station
				ON IQ_Station.IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))
		
			-- Fill ArchiveNM table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				tblIQMedia_Archive.MediaDate,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				ArchiveNM.Url,
				case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
				case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
				case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
				ArchiveNM.Publication,
				tblIQMedia_Archive.PositiveSentiment,
				tblIQMedia_Archive.NegativeSentiment,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description,
				tblIQMedia_Archive.DisplayDescription,
				IQLicense
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchiveNM WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveNM.ArchiveNMKey
				AND	tblIQMedia_Archive.SubMediaType = ArchiveNM.v5SubMediaType
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2
    
			-- Fill ArchiveSM table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				ArchiveSM.Url,
				tblIQMedia_Archive.MediaDate,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
				case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
				case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
				ArchiveSM.homelink,
				tblIQMedia_Archive.PositiveSentiment,
				tblIQMedia_Archive.NegativeSentiment,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description,
				tblIQMedia_Archive.DisplayDescription,
				ArchiveSM.ThumbUrl,
				ArchiveSM.ArticleStats
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchiveSM WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveSM.ArchiveSMKey
				AND	tblIQMedia_Archive.SubMediaType = ArchiveSM.v5SubMediaType
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2
   
			-- Fill ArchiveTweets table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				tblIQMedia_Archive.MediaDate,
				Actor_DisplayName, 
				Actor_PreferredUserName, 
				Actor_FollowersCount, 
				Actor_FriendsCount, 
				Actor_Image,
				Actor_link,
				Tweet_ID,
				gnip_Klout_Score,
				tblIQMedia_Archive.PositiveSentiment,
				tblIQMedia_Archive.NegativeSentiment,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description,
				tblIQMedia_Archive.DisplayDescription
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchiveTweets WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveTweets.ArchiveTweets_Key
				AND	tblIQMedia_Archive.SubMediaType = ArchiveTweets.v5SubMediaType
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2

			-- Fill ArchiveTVEyes table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				ArchiveTVEyes.StationID,
				ArchiveTVEyes.Market,
				ArchiveTVEyes.DMARank,
				tblIQMedia_Archive.MediaDate,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				tblIQMedia_Archive.PositiveSentiment,
				tblIQMedia_Archive.NegativeSentiment,
				ArchiveTVEyes.LocalDateTime,
				ArchiveTVEyes.TimeZone,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description,
				tblIQMedia_Archive.DisplayDescription
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchiveTVEyes WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
				AND	tblIQMedia_Archive.SubMediaType = ArchiveTVEyes.v5SubMediaType
				AND ArchiveTVEyes.IsDownLoaded = 1
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2
		
			-- Fill ArchiveMS table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				tblIQMedia_Archive.MediaDate,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				ArchiveMisc.CreateDT,
				ArchiveMisc.CreateDTTimeZone,
				IQUGC_FileTypes.FileType,
				(SELECT ISNULL(StreamSuffixPath + REPLACE(ArchiveMisc.Location,'\','/'),'') FROM IQCore_RootPath Where ID = ArchiveMisc._RootPathID) as MediaUrl,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchiveMisc WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveMisc.ArchiveMiscKey
				AND	tblIQMedia_Archive.SubMediaType = ArchiveMisc.v5SubMediaType
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2
			INNER JOIN IQUGC_FileTypes
				ON IQUGC_FileTypes.ID = ArchiveMisc._FileTypeID
    
			-- Fill ArchivePQ table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				tblIQMedia_Archive.MediaDate,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				ArchivePQ.Publication,
				ArchivePQ.Author,
				tblIQMedia_Archive.PositiveSentiment,
				tblIQMedia_Archive.NegativeSentiment,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description,
				tblIQMedia_Archive.DisplayDescription
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchivePQ WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchivePQ.ArchivePQKey
				AND	tblIQMedia_Archive.SubMediaType = ArchivePQ.v5SubMediaType
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2
    
			-- Fill ArchiveRadio table    
			SELECT 
				IQ_MediaTypes.DataModelType AS TableType,
				tblIQMedia_Archive.ID,
				_ArchiveMediaID,
				tblIQMedia_Archive.Title,
				tblIQMedia_Archive.HighlightingText,
				tblIQMedia_Archive.Content,
				tblIQMedia_Archive.MediaDate,
				tblIQMedia_Archive.MediaType,
				tblIQMedia_Archive.SubMediaType,
				ArchiveRadio.ClipGuid,
				ArchiveRadio.LocalDatetime,
				IQ_Station.Dma_Name,
				IQ_Station.IQ_Station_ID,
				IQ_Station.TimeZone,
				IQ_Station.Dma_Num,
				tblIQMedia_Archive.PositiveSentiment,
				tblIQMedia_Archive.NegativeSentiment,
				tblIQMedia_Archive.ClientGUID,
				tblIQMedia_Archive.ClientName,
				Description,
				tblIQMedia_Archive.DisplayDescription
			FROM @tblIQMedia_Archive as tblIQMedia_Archive
			INNER JOIN ArchiveRadio WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveRadio.ArchiveRadioKey
				AND	tblIQMedia_Archive.SubMediaType = ArchiveRadio.v5SubMediaType
			INNER	JOIN IQ_Station
				ON IQ_Station_ID = SUBSTRING(ArchiveRadio.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveRadio.IQ_CC_Key))
			INNER JOIN IQ_MediaTypes
				ON IQ_MediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
				AND IQ_MediaTypes.TypeLevel = 2

			-- Get Filter Data
			SELECT	'SubMediaTypeFilter' AS TableType,
					TblMediaTypes.MediaType,
					TblMediaTypes.DisplayName as MediaTypeDesc,
					TblMediaTypes.HasSubMediaTypes,
					TblSubMediaTypes.SubMediaType,
					TblSubMediaTypes.DisplayName as SubMediaTypeDesc,
					COUNT(1) AS SubMediaTypeCount
			FROM	@tblIQMedia_Archive as tblIQMedia_Archive
			INNER	JOIN IQ_MediaTypes as TblSubMediaTypes
					ON TblSubMediaTypes.SubMediaType = tblIQMedia_Archive.SubMediaType
			INNER	JOIN IQ_MediaTypes as TblMediaTypes
					ON TblSubMediaTypes.MediaType = TblMediaTypes.MediaType
					AND TblMediaTypes.TypeLevel = 1	
			GROUP BY TblMediaTypes.MediaType, TblMediaTypes.DisplayName, TblMediaTypes.SortOrder, TblMediaTypes.HasSubMediaTypes, 
						TblSubMediaTypes.SubMediaType, TblSubMediaTypes.DisplayName, TblSubMediaTypes.SortOrder
			ORDER BY TblMediaTypes.SortOrder, TblSubMediaTypes.SortOrder

			SELECT	'ClientFilter' AS TableType,
					ClientName,
					ClientGUID,
					COUNT(1) AS NumResults
			FROM	@tblIQMedia_Archive
			GROUP	BY ClientName,
					ClientGUID
			ORDER	BY ClientName

			SELECT	'CategoryFilter' AS TableType,
					CategoryName,
					COUNT(1) AS NumResults
			FROM	@tblIQMedia_Archive tblIQMedia_Archive
			INNER	JOIN IQArchive_Media WITH (NOLOCK)
				ON IQArchive_Media.ID = tblIQMedia_Archive.ID
			INNER	JOIN CustomCategory
				ON	(
						CustomCategory.CategoryGUID = IQArchive_Media.CategoryGUID
						OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory1GUID
						OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory2GUID
						OR CustomCategory.CategoryGUID = IQArchive_Media.SubCategory3GUID
					)
			GROUP	BY CategoryName
			ORDER	BY CategoryName

			SELECT	DISTINCT 'DateFilter' AS TableType,
					CAST(MediaDate AS DATE) AS MediaDate
			FROM	@tblIQMedia_Archive
		END
END
