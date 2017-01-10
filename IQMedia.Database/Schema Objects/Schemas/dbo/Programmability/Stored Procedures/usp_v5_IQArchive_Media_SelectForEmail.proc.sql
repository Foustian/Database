-- =============================================
-- Author:		<Author,,Name>
-- Create date: 17 June 2013
-- Description:	Select records for Email functionality
-- =============================================
CREATE PROCEDURE [dbo].[usp_v5_IQArchive_Media_SelectForEmail]
	@ArchiveXML		XML,
	@ClientGuid		uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tblIQMedia_Arvhive AS TABLE
	(
		ID					BIGINT,
		_ArchiveMediaID		BIGINT,
		MediaType			VARCHAR(10),
		MediaDate			DATETIME,		
		ClientGUID			UNIQUEIDENTIFIER,		
		CustomerGUID		UNIQUEIDENTIFIER,	
		Title				NVARCHAR(MAX),			
		SubMediaType		VARCHAR(50),
		HighlightingText	NVARCHAR(MAX),
		Content				NVARCHAR(MAX),
		DisplayDescription	BIT
	)
			
	INSERT INTO @tblIQMedia_Arvhive (ID )
	SELECT	tbl.c.query('.').value('.','BIGINT')
	FROM	@ArchiveXML.nodes('list/id') as tbl(c)
	
	
	UPDATE @tblIQMedia_Arvhive
	
	SET _ArchiveMediaID = IQArchive_Media._ArchiveMediaID,
			MediaType = IQArchive_Media.v5MediaType,		
			HighlightingText = IQArchive_Media.HighlightingText,
			Content = IQArchive_Media.Content,
			MediaDate = IQArchive_Media.MediaDate,		
			ClientGUID = IQArchive_Media.ClientGUID,		
			CustomerGUID = IQArchive_Media.CustomerGUID,	
			Title = IQArchive_Media.Title,			
			SubMediaType = IQArchive_Media.v5SubMediaType,
			DisplayDescription	= IQArchive_Media.DisplayDescription
				
	FROM	@tblIQMedia_Arvhive AS tblIQMedia_Arvhive
	INNER JOIN IQArchive_Media
	ON IQArchive_Media.ID = tblIQMedia_Arvhive.ID
	AND IQArchive_Media.ClientGUID = @ClientGuid
	
	
	
	-- Fill ArchiveBLPM table
    
    SELECT 
			tblIQMedia_Arvhive.ID,
			_ArchiveMediaID,
			tblIQMedia_Arvhive.Title,
			tblIQMedia_Arvhive.HighlightingText,
			tblIQMedia_Arvhive.Content,
			tblIQMedia_Arvhive.MediaDate,
			tblIQMedia_Arvhive.MediaType,
			tblIQMedia_Arvhive.SubMediaType,
			ArchiveBLPM.Circulation,
			ArchiveBLPM.FileLocation,
			ArchiveBLPM.Pub_Name,
			Description,
			tblIQMedia_Arvhive.DisplayDescription
    FROM @tblIQMedia_Arvhive AS tblIQMedia_Arvhive
    INNER JOIN ArchiveBLPM WITH (NOLOCK)
    ON tblIQMedia_Arvhive._ArchiveMediaID = ArchiveBLPM.ArchiveBLPMKey
    AND	tblIQMedia_Arvhive.SubMediaType=ArchiveBLPM.v5SubMediaType
    AND ArchiveBLPM.ClientGUID = @ClientGuid
    -- Fill ArchiveClip table
    
    SELECT 
			tblIQMedia_Arvhive.ID,
			_ArchiveMediaID,
			tblIQMedia_Arvhive.Title,
			tblIQMedia_Arvhive.HighlightingText,
			tblIQMedia_Arvhive.Content,
			tblIQMedia_Arvhive.MediaDate,
			tblIQMedia_Arvhive.MediaType,
			tblIQMedia_Arvhive.SubMediaType,
			ArchiveClip.ClipID,
			ArchiveClip.ClipDate,
			Nielsen_Audience,
			IQAdShareValue,
			Nielsen_Result,
			(Select Dma_Name From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Market',
			(Select IQ_Station_ID From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'StationLogo',
			(Select TimeZone From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'TimeZone',
			PositiveSentiment,
			NegativeSentiment,
			Description,
			tblIQMedia_Arvhive.DisplayDescription
			
    FROM	@tblIQMedia_Arvhive AS tblIQMedia_Arvhive
    
    INNER JOIN ArchiveClip WITH (NOLOCK)
    ON tblIQMedia_Arvhive._ArchiveMediaID = ArchiveClip.ArchiveClipKey
    AND	tblIQMedia_Arvhive.SubMediaType=ArchiveClip.v5SubMediaType
	AND ArchiveClip.ClientGUID = @ClientGuid
    
    
    -- Fill ArchiveNM table
    
    SELECT 
			tblIQMedia_Arvhive.ID,
			_ArchiveMediaID,
			tblIQMedia_Arvhive.Title,
			tblIQMedia_Arvhive.HighlightingText,
			tblIQMedia_Arvhive.Content,
			tblIQMedia_Arvhive.MediaDate,
			tblIQMedia_Arvhive.MediaType,
			tblIQMedia_Arvhive.SubMediaType,
			ArchiveNM.Url,
			Compete_Audience,
			IQAdShareValue,
			Compete_Result,
			ArchiveNM.Publication,
			PositiveSentiment,
			NegativeSentiment,
			IQLicense,
			Description,
			tblIQMedia_Arvhive.DisplayDescription
			
										
    FROM @tblIQMedia_Arvhive AS tblIQMedia_Arvhive
    INNER JOIN ArchiveNM WITH (NOLOCK)
    ON tblIQMedia_Arvhive._ArchiveMediaID = ArchiveNM.ArchiveNMKey
    AND	tblIQMedia_Arvhive.SubMediaType=ArchiveNM.v5SubMediaType
	AND ArchiveNM.ClientGuid = @ClientGuid
   
    
    -- Fill ArchiveSM table
    
    SELECT 
			tblIQMedia_Arvhive.ID,
			_ArchiveMediaID,
			tblIQMedia_Arvhive.Title,
			tblIQMedia_Arvhive.HighlightingText,
			tblIQMedia_Arvhive.Content,
			ArchiveSM.Url,
			tblIQMedia_Arvhive.MediaDate,
			tblIQMedia_Arvhive.MediaType,
			tblIQMedia_Arvhive.SubMediaType,
			Compete_Audience,
			IQAdShareValue,
			Compete_Result,
			ArchiveSM.homelink,
			PositiveSentiment,
			NegativeSentiment,
			Description,
			tblIQMedia_Arvhive.DisplayDescription,
			ArchiveSM.ThumbUrl,
			ArchiveSM.ArticleStats
			
    FROM @tblIQMedia_Arvhive AS tblIQMedia_Arvhive
    INNER JOIN ArchiveSM WITH (NOLOCK)
    ON tblIQMedia_Arvhive._ArchiveMediaID = ArchiveSM.ArchiveSMKey
    AND	tblIQMedia_Arvhive.SubMediaType=ArchiveSM.v5SubMediaType
   AND ArchiveSM.ClientGuid = @ClientGuid
    
    -- Fill ArchiveTweets table
    
    SELECT 
			tblIQMedia_Arvhive.ID,
			_ArchiveMediaID,
			tblIQMedia_Arvhive.Title,
			tblIQMedia_Arvhive.HighlightingText,
			tblIQMedia_Arvhive.Content,
			tblIQMedia_Arvhive.MediaType,
			tblIQMedia_Arvhive.SubMediaType,
			tblIQMedia_Arvhive.MediaDate,
			Actor_DisplayName, 
			Actor_PreferredUserName, 
			Actor_FollowersCount, 
			Actor_FriendsCount, 
			Actor_Image,
			Actor_link,
			Tweet_ID,
			gnip_Klout_Score,
			PositiveSentiment,
			NegativeSentiment,
			Description,
			tblIQMedia_Arvhive.DisplayDescription

    FROM @tblIQMedia_Arvhive AS tblIQMedia_Arvhive
    INNER JOIN ArchiveTweets WITH (NOLOCK)
    ON tblIQMedia_Arvhive._ArchiveMediaID = ArchiveTweets.ArchiveTweets_Key
    AND	tblIQMedia_Arvhive.SubMediaType=ArchiveTweets.v5SubMediaType
	AND ArchiveTweets.ClientGUID = @ClientGuid

	-- Fill ArchiveTVEyes table
    
    SELECT 
			tblIQMedia_Arvhive.ID,
			_ArchiveMediaID,
			tblIQMedia_Arvhive.Title,
			tblIQMedia_Arvhive.HighlightingText,
			tblIQMedia_Arvhive.Content,
			tblIQMedia_Arvhive.MediaDate,
			tblIQMedia_Arvhive.MediaType,
			tblIQMedia_Arvhive.SubMediaType,
			ArchiveTVEyes.DMARank,
			ArchiveTVEyes.Market,
			ArchiveTVEyes.StationID,
			PositiveSentiment,
			NegativeSentiment,
			ArchiveTVEyes.LocalDateTime,
			ArchiveTVEyes.TimeZone,
			Description,
			tblIQMedia_Arvhive.DisplayDescription
			
    FROM @tblIQMedia_Arvhive AS tblIQMedia_Arvhive
    INNER JOIN ArchiveTVEyes WITH (NOLOCK)
    ON tblIQMedia_Arvhive._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
    AND	tblIQMedia_Arvhive.SubMediaType=ArchiveTVEyes.v5SubMediaType
   AND ArchiveTVEyes.ClientGuid = @ClientGuid

	-- Fill ArchiveMS table  

    SELECT 
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
			Description

    FROM @tblIQMedia_Arvhive AS tblIQMedia_Archive
    INNER JOIN ArchiveMisc WITH (NOLOCK)
		ON tblIQMedia_Archive._ArchiveMediaID = ArchiveMisc.ArchiveMiscKey
		AND	tblIQMedia_Archive.SubMediaType=ArchiveMisc.v5SubMediaType
		AND tblIQMedia_Archive.ClientGUID = @ClientGuid
    INNER JOIN IQUGC_FileTypes
		ON IQUGC_FileTypes.ID = ArchiveMisc._FileTypeID

	-- Fill ArchivePQ table
    
    SELECT 
			tblIQMedia_Arvhive.ID,
			_ArchiveMediaID,
			tblIQMedia_Arvhive.Title,
			tblIQMedia_Arvhive.HighlightingText,
			tblIQMedia_Arvhive.Content,
			tblIQMedia_Arvhive.MediaDate,
			tblIQMedia_Arvhive.MediaType,
			tblIQMedia_Arvhive.SubMediaType,
			ArchivePQ.Publication,
			ArchivePQ.Author,
			PositiveSentiment,
			NegativeSentiment,
			Description,
			tblIQMedia_Arvhive.DisplayDescription
			
    FROM @tblIQMedia_Arvhive AS tblIQMedia_Arvhive
    INNER JOIN ArchivePQ WITH (NOLOCK)
    ON tblIQMedia_Arvhive._ArchiveMediaID = ArchivePQ.ArchivePQKey
    AND	tblIQMedia_Arvhive.SubMediaType=ArchivePQ.v5SubMediaType
   AND ArchivePQ.ClientGuid = @ClientGuid

	-- Fill ArchiveRadio table
    
    SELECT 
			tblIQMedia_Arvhive.ID,
			_ArchiveMediaID,
			tblIQMedia_Arvhive.Title,
			tblIQMedia_Arvhive.HighlightingText,
			tblIQMedia_Arvhive.Content,
			tblIQMedia_Arvhive.MediaDate,
			tblIQMedia_Arvhive.MediaType,
			tblIQMedia_Arvhive.SubMediaType,
			ArchiveRadio.ClipGuid,
			ArchiveRadio.LocalDatetime,
			IQ_Station.Dma_Name,
			IQ_Station.IQ_Station_ID,
			IQ_Station.TimeZone,
			IQ_Station.Dma_Num,
			PositiveSentiment,
			NegativeSentiment,
			Description,
			tblIQMedia_Arvhive.DisplayDescription
			
    FROM @tblIQMedia_Arvhive AS tblIQMedia_Arvhive
    INNER JOIN ArchiveRadio WITH (NOLOCK)
		ON tblIQMedia_Arvhive._ArchiveMediaID = ArchiveRadio.ArchiveRadioKey
		AND	tblIQMedia_Arvhive.SubMediaType=ArchiveRadio.v5SubMediaType
		AND ArchiveRadio.ClientGuid = @ClientGuid
	INNER JOIN IQ_Station
		ON IQ_Station.IQ_Station_ID = SUBSTRING(ArchiveRadio.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveRadio.IQ_CC_Key))
   
    
END
