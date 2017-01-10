CREATE PROCEDURE [dbo].[usp_v5_IQArchive_Media_EmailTemplate2_Select]
	@ArchiveIDXml XML,
	@MasterClientID INT,
	@ClientGuid UNIQUEIDENTIFIER -- Unused. Needed for template signature
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ReportGUID UNIQUEIDENTIFIER
	DECLARE @HeaderImage VARCHAR(255)
	DECLARE @MasterClientGUID UNIQUEIDENTIFIER
	DECLARE @MasterClientName VARCHAR(100)

	SELECT	@MasterClientGUID = ClientGUID,
			@MasterClientName = ClientName
	FROM	Client 
	WHERE	ClientKey = @MasterClientID
	
	SELECT	@ReportGUID = ReportGUID
	FROM	IQ_Report 
	INNER	JOIN IQ_ReportType
		ON IQ_Report._ReportTypeID = IQ_ReportType.ID
	WHERE	IQ_ReportType.MasterReportType = 'MCMediaTemplate'
			AND IQ_Report.ClientGuid = @MasterClientGUID
			AND IQ_Report.IsActive = 1
			AND	IQ_ReportType.IsActive = 1
	
	SELECT	@HeaderImage = Location
	FROM	IQClient_CustomImage 
	WHERE	IQClient_CustomImage._ClientGUID = @MasterClientGUID
			AND IQClient_CustomImage.IsDefault = 1 
			AND IQClient_CustomImage.IsActive = 1
	
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
		CategoryName		VARCHAR(150),
		CategoryRanking		INT,
		PositiveSentiment	tinyint,
		NegativeSentiment	tinyint,
		DisplayDescription	BIT
	)

	INSERT INTO @tblIQMedia_Archive
	(
		ID
	)
	SELECT	
		tbl.c.query('.').value('.','bigint') 
	FROM	
		@ArchiveIDXml.nodes('list/id') as tbl(c)
	INNER JOIN IQArchive_Media WITH (NOLOCK)	
		ON IQArchive_Media.ID = tbl.c.query('.').value('.','bigint') 
		AND IQArchive_Media.IsActive = 1
	INNER JOIN IQArchive_MCMedia WITH (NOLOCK)
		ON IQArchive_MCMedia.ArchiveID = IQArchive_Media.ID
		AND IQArchive_MCMedia.MasterClientGUID = @MasterClientGUID
		AND IQArchive_MCMedia.IsActive = 1
		
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
			CategoryName = CustomCategory.CategoryName,
			CategoryRanking = CustomCategory.CategoryRanking,
			PositiveSentiment = IQArchive_Media.PositiveSentiment,
			NegativeSentiment = IQArchive_Media.NegativeSentiment,
			DisplayDescription = IQArchive_Media.DisplayDescription					
	FROM	@tblIQMedia_Archive AS tblIQMedia_Archive
	INNER	JOIN IQArchive_Media WITH (NOLOCK)
		ON IQArchive_Media.ID = tblIQMedia_Archive.ID
		AND IQArchive_Media.ClientGUID IS NOT NULL -- Included for indexing
	INNER	JOIN Client
		ON Client.ClientGUID = IQArchive_Media.ClientGUID
	LEFT	JOIN CustomCategory WITH (NOLOCK) 
		ON IQArchive_Media.CategoryGUID = CustomCategory.CategoryGUID

	
	SELECT 'HeaderInfo' AS TableType,
		   @ReportGUID AS ReportGuid,
		   @HeaderImage AS HeaderImage,
		   @MasterClientGUID AS MasterClientGuid,
		   @MasterClientName AS MasterClientName
	
	-- Fill ArchiveBLPM table    
	SELECT 
		'PM' AS TableType,
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
		tblIQMedia_Archive.CategoryGUID,
		tblIQMedia_Archive.CategoryName,
		tblIQMedia_Archive.CategoryRanking,
		Description,
		tblIQMedia_Archive.DisplayDescription
	FROM @tblIQMedia_Archive as tblIQMedia_Archive
	INNER JOIN ArchiveBLPM WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveBLPM.ArchiveBLPMKey
		AND	tblIQMedia_Archive.SubMediaType = ArchiveBLPM.v5SubMediaType	
    
	-- Fill ArchiveClip table    
	SELECT 
		'TV' AS TableType,
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
		Nielsen_Audience,
		IQAdShareValue,
		Nielsen_Result,
		Dma_Name as 'Market',
		IQ_Station_ID as 'StationLogo',
		IQ_Station.TimeZone,
		Dma_Num,
		tblIQMedia_Archive.PositiveSentiment,
		tblIQMedia_Archive.NegativeSentiment,
		tblIQMedia_Archive.ClientGUID,
		tblIQMedia_Archive.ClientName,
		tblIQMedia_Archive.CategoryGUID,
		tblIQMedia_Archive.CategoryName,
		tblIQMedia_Archive.CategoryRanking,
		Description,
		tblIQMedia_Archive.DisplayDescription
	FROM @tblIQMedia_Archive as tblIQMedia_Archive
	INNER JOIN ArchiveClip WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveClip.ArchiveClipKey
		AND	tblIQMedia_Archive.SubMediaType = ArchiveClip.v5SubMediaType
	INNER JOIN IQCore_Clip 
		ON ArchiveClip.ClipID = IQCore_Clip.[Guid]
	LEFT JOIN IQ_Station
		ON IQ_Station.IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))
		
	-- Fill ArchiveNM table    
	SELECT 
		'NM' AS TableType,
		tblIQMedia_Archive.ID,
		_ArchiveMediaID,
		tblIQMedia_Archive.Title,
		tblIQMedia_Archive.HighlightingText,
		tblIQMedia_Archive.Content,
		tblIQMedia_Archive.MediaDate,
		tblIQMedia_Archive.MediaType,
		tblIQMedia_Archive.SubMediaType,
		ArchiveNM.Url,
		Compete_Audience,
		Compete_Result,
		IQAdShareValue,
		ArchiveNM.Publication,
		tblIQMedia_Archive.PositiveSentiment,
		tblIQMedia_Archive.NegativeSentiment,
		tblIQMedia_Archive.ClientGUID,
		tblIQMedia_Archive.ClientName,
		tblIQMedia_Archive.CategoryGUID,
		tblIQMedia_Archive.CategoryName,
		tblIQMedia_Archive.CategoryRanking,
		Description,
		tblIQMedia_Archive.DisplayDescription,
		IQLicense
	FROM @tblIQMedia_Archive as tblIQMedia_Archive
	INNER JOIN ArchiveNM WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveNM.ArchiveNMKey
		AND	tblIQMedia_Archive.SubMediaType = ArchiveNM.v5SubMediaType
    
	-- Fill ArchiveSM table    
	SELECT 
		'SM' AS TableType,
		tblIQMedia_Archive.ID,
		_ArchiveMediaID,
		tblIQMedia_Archive.Title,
		tblIQMedia_Archive.HighlightingText,
		tblIQMedia_Archive.Content,
		ArchiveSM.Url,
		tblIQMedia_Archive.MediaDate,
		tblIQMedia_Archive.MediaType,
		tblIQMedia_Archive.SubMediaType,
		Compete_Audience,
		Compete_Result,
		IQAdShareValue,
		ArchiveSM.homelink,
		tblIQMedia_Archive.PositiveSentiment,
		tblIQMedia_Archive.NegativeSentiment,
		tblIQMedia_Archive.ClientGUID,
		tblIQMedia_Archive.ClientName,
		tblIQMedia_Archive.CategoryGUID,
		tblIQMedia_Archive.CategoryName,
		tblIQMedia_Archive.CategoryRanking,
		Description,
		tblIQMedia_Archive.DisplayDescription,
		ArchiveSM.ThumbUrl,
		ArchiveSM.ArticleStats
	FROM @tblIQMedia_Archive as tblIQMedia_Archive
	INNER JOIN ArchiveSM WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveSM.ArchiveSMKey
		AND	tblIQMedia_Archive.SubMediaType = ArchiveSM.v5SubMediaType
   
	-- Fill ArchiveTweets table    
	SELECT 
		'TW' AS TableType,
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
		tblIQMedia_Archive.CategoryGUID,
		tblIQMedia_Archive.CategoryName,
		tblIQMedia_Archive.CategoryRanking,
		Description,
		tblIQMedia_Archive.DisplayDescription
	FROM @tblIQMedia_Archive as tblIQMedia_Archive
	INNER JOIN ArchiveTweets WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveTweets.ArchiveTweets_Key
		AND	tblIQMedia_Archive.SubMediaType = ArchiveTweets.v5SubMediaType

	-- Fill ArchiveTVEyes table    
	SELECT 
		'TM' AS TableType,
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
		tblIQMedia_Archive.CategoryGUID,
		tblIQMedia_Archive.CategoryName,
		tblIQMedia_Archive.CategoryRanking,
		Description,
		tblIQMedia_Archive.DisplayDescription
	FROM @tblIQMedia_Archive as tblIQMedia_Archive
	INNER JOIN ArchiveTVEyes WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
		AND	tblIQMedia_Archive.SubMediaType = ArchiveTVEyes.v5SubMediaType
		AND ArchiveTVEyes.IsDownLoaded = 1
		
	-- Fill ArchiveMS table    
	SELECT 
		'MS' AS TableType,
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
		tblIQMedia_Archive.CategoryGUID,
		tblIQMedia_Archive.CategoryName,
		tblIQMedia_Archive.CategoryRanking,
		Description
	FROM @tblIQMedia_Archive as tblIQMedia_Archive
	INNER JOIN ArchiveMisc WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveMisc.ArchiveMiscKey
		AND	tblIQMedia_Archive.SubMediaType = ArchiveMisc.v5SubMediaType
	INNER JOIN IQUGC_FileTypes
		ON IQUGC_FileTypes.ID = ArchiveMisc._FileTypeID
    
	-- Fill ArchivePQ table    
	SELECT 
		'PQ' AS TableType,
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
		tblIQMedia_Archive.CategoryGUID,
		tblIQMedia_Archive.CategoryName,
		tblIQMedia_Archive.CategoryRanking,
		Description,
		tblIQMedia_Archive.DisplayDescription
	FROM @tblIQMedia_Archive as tblIQMedia_Archive
	INNER JOIN ArchivePQ WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchivePQ.ArchivePQKey
		AND	tblIQMedia_Archive.SubMediaType = ArchivePQ.v5SubMediaType

	-- Fill ArchiveRadio table    
    SELECT 
			'IQR' AS TableType,
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
			tblIQMedia_Archive.CategoryGUID,
			tblIQMedia_Archive.CategoryName,
			tblIQMedia_Archive.CategoryRanking,
			Description,
			tblIQMedia_Archive.DisplayDescription			
    FROM @tblIQMedia_Archive AS tblIQMedia_Archive
    INNER JOIN ArchiveRadio WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveRadio.ArchiveRadioKey
		AND	tblIQMedia_Archive.SubMediaType = ArchiveRadio.v5SubMediaType
	INNER	JOIN IQ_Station
		ON IQ_Station_ID = SUBSTRING(ArchiveRadio.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveRadio.IQ_CC_Key))
END
