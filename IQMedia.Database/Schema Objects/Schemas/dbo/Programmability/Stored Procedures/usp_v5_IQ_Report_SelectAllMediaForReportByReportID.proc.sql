-- =============================================
-- Author:		<Author,,Name>
-- Create date: 27 June 2013
-- Description:	Displays report results 
-- =============================================

CREATE PROCEDURE [dbo].[usp_v5_IQ_Report_SelectAllMediaForReportByReportID]
	@ReportID		BIGINT,
	@ClientGuid     uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ReportRule AS XML
	DECLARE @ReportGUID uniqueidentifier
	DECLARE @ReportType varchar(100)
	DECLARE @SortColumn varchar(10)
	DECLARE @ShowNationalValues bit
	DECLARE @ReportStatus varchar(50) = null

	SELECT	@ReportRule = ReportRule, 
			@ReportGUID = ReportGUID,
			@ReportType = IQ_ReportType.[Identity]
	FROM	IQ_Report 
	INNER	JOIN IQ_ReportType ON IQ_ReportType.ID = IQ_Report._ReportTypeID
	WHERE	IQ_Report.ID = @ReportID 
			AND IQ_Report.IsActive = 1

	IF @ReportType = 'v4Library'
	  BEGIN
		SELECT @ReportStatus = Status FROM IQReport_Feeds WHERE ReportGUID = @ReportGUID

		-- If the report wasn't created from Feeds, check Discovery
		IF @ReportStatus IS NULL
		  BEGIN
			SELECT @ReportStatus = Status FROM IQReport_Discovery WHERE ReportGUID = @ReportGUID
		  END
	  END
	
	-- Only display the report if it is fully done processing
	IF @ReportRule IS NOT NULL AND (@ReportStatus IS NULL OR @ReportStatus = 'COMPLETED')
		BEGIN

			DECLARE @MultiPlier float
			select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGuid),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))

			SET @SortColumn = @ReportRule.query('Report/Library/Settings/Sort').value('.','varchar(max)')	
			SET @ShowNationalValues = CASE WHEN @ReportRule.query('Report/Library/Settings/ShowNationalValues').value('.','varchar(max)') = '' THEN 1 ELSE @ReportRule.query('Report/Library/Settings/ShowNationalValues').value('.','bit') END	
			
			DECLARE @tblIQMedia_Archive AS TABLE
			(
				ID					BIGINT,
				_ArchiveMediaID		BIGINT,
				MediaType			VARCHAR(10),
				MediaDate			DATETIME,		
				ClientGUID			UNIQUEIDENTIFIER,		
				CustomerGUID		UNIQUEIDENTIFIER,	
				Title				NVARCHAR(500),			
				SubMediaType		VARCHAR(50),
				SubMediaTypeDesc	VARCHAR(200),
				HighlightingText	NVARCHAR(MAX),
				Content				NVARCHAR(MAX),
				CategoryGUID		UNIQUEIDENTIFIER,
				CategoryName		VARCHAR(150),
				SubCategory1GUID	UNIQUEIDENTIFIER,
				SubCategory1Name	VARCHAR(150),
				SubCategory2GUID	UNIQUEIDENTIFIER,
				SubCategory2Name	VARCHAR(150),
				SubCategory3GUID	UNIQUEIDENTIFIER,
				SubCategory3Name	VARCHAR(150),
				PositiveSentiment	tinyint,
				NegativeSentiment	tinyint,
				IsValidForNationalValues			bit,
				DisplayDescription  bit,
				AgentID				bigint,
				AgentName			varchar(max),
				Position			int,
				GroupTier1Value		varchar(max),
				GroupTier2Value		varchar(max)
			)

			INSERT INTO @tblIQMedia_Archive
			(
				ID
			)
			SELECT
			tbl.c.query('.').value('.','bigint') from
			@ReportRule.nodes('Report/Library/ArchiveMediaSet/ID') as tbl(c)
			
		
			UPDATE @tblIQMedia_Archive
	
			SET		_ArchiveMediaID = IQArchive_Media._ArchiveMediaID,
					MediaType = IQArchive_Media.v5MediaType,		
					HighlightingText = IQArchive_Media.HighlightingText,
					Content = IQArchive_Media.Content,
					MediaDate = IQArchive_Media.MediaDate,		
					ClientGUID = IQArchive_Media.ClientGUID,		
					CustomerGUID = IQArchive_Media.CustomerGUID,	
					Title = IQArchive_Media.Title,			
					SubMediaType = IQArchive_Media.v5SubMediaType,
					SubMediaTypeDesc = IQ_MediaTypes.DisplayName,
					CategoryGUID = IQArchive_Media.CategoryGUID,
					CategoryName = cat.CategoryName,
					SubCategory1GUID = IQArchive_Media.SubCategory1GUID,
					SubCategory1Name = subcat1.CategoryName,
					SubCategory2GUID = IQArchive_Media.SubCategory2GUID,
					SubCategory2Name = subcat2.CategoryName,
					SubCategory3GUID = IQArchive_Media.SubCategory3GUID,
					SubCategory3Name = subcat3.CategoryName,
					PositiveSentiment = IQArchive_Media.PositiveSentiment,
					NegativeSentiment = IQArchive_Media.NegativeSentiment,
					IsValidForNationalValues = CASE WHEN EXISTS(SELECT 1 ID FROM IQArchive_Media WHERE _ParentID = tblIQMedia_Archive.ID) THEN 1 ELSE 0 END,
					DisplayDescription = IQArchive_Media.DisplayDescription,
					AgentID = IQAgent_SearchRequest.ID,
					AgentName = IQAgent_SearchRequest.Query_Name,
					Position = IQ_Report_ItemPositions.Position,
					GroupTier1Value = IQ_Report_ItemPositions.GroupTier1Value,
					GroupTier2Value = IQ_Report_ItemPositions.GroupTier2Value
						
			FROM	@tblIQMedia_Archive AS tblIQMedia_Archive
				INNER JOIN IQArchive_Media WITH (NOLOCK)
					ON IQArchive_Media.ID = tblIQMedia_Archive.ID
					AND IQArchive_Media.ClientGUID = @ClientGuid
				INNER JOIN IQ_MediaTypes
					ON IQ_MediaTypes.SubMediaType = IQArchive_Media.v5SubMediaType
					AND IQ_MediaTypes.TypeLevel = 2
				LEFT JOIN IQAgent_SearchRequest WITH (NOLOCK)
					ON IQAgent_SearchRequest.ID = IQArchive_Media._SearchRequestID
				LEFT JOIN IQ_Report_ItemPositions WITH (NOLOCK)
					ON IQ_Report_ItemPositions._ReportGUID = @ReportGUID
					AND IQ_Report_ItemPositions._ArchiveMediaID = tblIQMedia_Archive.ID
					AND IQ_Report_ItemPositions.IsActive = 1
				LEFT JOIN CustomCategory cat WITH (NOLOCK)
					ON cat.CategoryGUID = IQArchive_Media.CategoryGUID
				LEFT JOIN CustomCategory subcat1 WITH (NOLOCK)
					ON subcat1.CategoryGUID = IQArchive_Media.SubCategory1GUID
				LEFT JOIN CustomCategory subcat2 WITH (NOLOCK)
					ON subcat2.CategoryGUID = IQArchive_Media.SubCategory2GUID
				LEFT JOIN CustomCategory subcat3 WITH (NOLOCK)
					ON subcat3.CategoryGUID = IQArchive_Media.SubCategory3GUID
			
			
			
			
			-- Fill ArchiveBLPM table
    
			SELECT 
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					tblIQMedia_Archive.MediaDate,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					ArchiveBLPM.Circulation,
					ArchiveBLPM.FileLocation,
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					ArchiveBLPM.Pub_Name,
					Description,
					tblIQMedia_Archive.DisplayDescription,
					tblIQMedia_Archive.AgentID,
					tblIQMedia_Archive.AgentName,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value
					
			FROM @tblIQMedia_Archive AS tblIQMedia_Archive
			
			INNER JOIN ArchiveBLPM
			ON tblIQMedia_Archive._ArchiveMediaID = ArchiveBLPM.ArchiveBLPMKey
			AND	tblIQMedia_Archive.SubMediaType=ArchiveBLPM.v5SubMediaType
			AND ArchiveBLPM.ClientGUID = @ClientGuid
			ORder by RowNo
			-- Fill ArchiveClip table
		    
			SELECT 
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									WHEN @SortColumn = 'Audience+' THEN ROW_NUMBER() OVER(ORDER By Nielsen_Audience ASC, IQ_Station.Station_Call_Sign ASC, MediaDate DESC)
									WHEN @SortColumn = 'Audience-' THEN ROW_NUMBER() OVER(ORDER By Nielsen_Audience DESC, IQ_Station.Station_Call_Sign ASC, MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					tblIQMedia_Archive.MediaDate,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					ArchiveClip.ClipID,
					ArchiveClip.ClipDate,
					CASE WHEN Nielsen_Audience < 0 THEN 0 ELSE Nielsen_Audience END AS Nielsen_Audience,
					CASE WHEN IQAdShareValue < 0 THEN 0 ELSE IQAdShareValue END AS IQAdShareValue,
					Nielsen_Result,
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					IQ_Station.Dma_Name as 'Market',
					IQ_Station.Station_Call_Sign,
					IQ_Station.IQ_Station_ID as 'StationLogo',
					IQ_Station.TimeZone,
					tblIQMedia_Archive.PositiveSentiment,
					tblIQMedia_Archive.NegativeSentiment,
					Description,
					tblIQMedia_Archive.DisplayDescription,
					tblIQMedia_Archive.AgentID,
					tblIQMedia_Archive.AgentName,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value,
					CASE WHEN (@ShowNationalValues = 1 AND IsValidForNationalValues = 1) THEN (SELECT SUM(IQSSP_NationalNielsen.Audience) FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = IQ_Station.Station_Affil) ELSE NULL END as National_Nielsen_Audience,
					CASE WHEN (@ShowNationalValues = 1 AND IsValidForNationalValues = 1)THEN (SELECT (SUM(IQSSP_NationalNielsen.MediaValue) * @MultiPlier *  (CONVERT(decimal(18,2),(IQCore_Clip.endOffset - IQCore_Clip.startOffset + 1)) /30 )) FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = IQ_Station.Station_Affil) ELSE NULL END as National_IQAdShareValue,
					CASE WHEN (@ShowNationalValues = 1 AND  IsValidForNationalValues = 1) THEN (SELECT CASE WHEN min(CONVERT(int,IQSSP_NationalNielsen.IsActual)) = 1 THEN 'A' ELSE 'E' END FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = IQ_Station.Station_Affil) ELSE NULL END as National_Nielsen_Result
					
			FROM	@tblIQMedia_Archive AS tblIQMedia_Archive
		    
			INNER JOIN ArchiveClip
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveClip.ArchiveClipKey
				AND	tblIQMedia_Archive.SubMediaType=ArchiveClip.v5SubMediaType
				AND ArchiveClip.ClientGUID = @ClientGuid
			INNER JOIN IQCore_Clip 
				ON ArchiveClip.ClipID = IQCore_Clip.[Guid]
			LEFT JOIN IQ_Station
				ON IQ_Station.IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))
		    ORder by RowNo
		    
			-- Fill ArchiveNM table
		    
			SELECT 
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									WHEN @SortColumn = 'Audience+' THEN ROW_NUMBER() OVER(ORDER By Compete_Audience ASC, ArchiveNM.CompeteUrl ASC, MediaDate DESC)
									WHEN @SortColumn = 'Audience-' THEN ROW_NUMBER() OVER(ORDER By Compete_Audience DESC, ArchiveNM.CompeteUrl ASC, MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					tblIQMedia_Archive.MediaDate,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					ArchiveNM.Url,
					CASE WHEN Compete_Audience < 0 THEN 0 ELSE Compete_Audience END AS Compete_Audience,
					CASE WHEN IQAdShareValue < 0 THEN 0 ELSE IQAdShareValue END AS IQAdShareValue,
					Compete_Result,
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					ArchiveNM.Publication,
					tblIQMedia_Archive.PositiveSentiment,
					tblIQMedia_Archive.NegativeSentiment,
					IQLicense,
					Description,
					tblIQMedia_Archive.DisplayDescription,
					ArchiveNM.CompeteURL,
					tblIQMedia_Archive.AgentID,
					tblIQMedia_Archive.AgentName,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value
					
					
												
			FROM @tblIQMedia_Archive AS tblIQMedia_Archive
			INNER JOIN ArchiveNM
			ON tblIQMedia_Archive._ArchiveMediaID = ArchiveNM.ArchiveNMKey
			AND	tblIQMedia_Archive.SubMediaType=ArchiveNM.v5SubMediaType
			AND ArchiveNM.ClientGuid = @ClientGuid
		    ORder by RowNo
			-- Fill ArchiveSM table
		    
			SELECT 
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									WHEN @SortColumn = 'Audience+' THEN ROW_NUMBER() OVER(ORDER By Compete_Audience ASC, ArchiveSM.CompeteURL ASC, MediaDate DESC)
									WHEN @SortColumn = 'Audience-' THEN ROW_NUMBER() OVER(ORDER By Compete_Audience DESC, ArchiveSM.CompeteURL ASC, MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					ArchiveSM.Url,
					tblIQMedia_Archive.MediaDate,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					CASE WHEN Compete_Audience < 0 THEN 0 ELSE Compete_Audience END AS Compete_Audience,
					CASE WHEN IQAdShareValue < 0 THEN 0 ELSE IQAdShareValue END AS IQAdShareValue,
					Compete_Result,
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					ArchiveSM.homelink,
					tblIQMedia_Archive.PositiveSentiment,
					tblIQMedia_Archive.NegativeSentiment,
					Description,
					tblIQMedia_Archive.DisplayDescription,
					ArchiveSM.ThumbUrl,
					ArchiveSM.ArticleStats,
					ArchiveSM.CompeteURL,
					tblIQMedia_Archive.AgentID,
					tblIQMedia_Archive.AgentName,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value
					
			FROM @tblIQMedia_Archive AS tblIQMedia_Archive
			INNER JOIN ArchiveSM
			ON tblIQMedia_Archive._ArchiveMediaID = ArchiveSM.ArchiveSMKey
			AND	tblIQMedia_Archive.SubMediaType=ArchiveSM.v5SubMediaType
		   AND ArchiveSM.ClientGuid = @ClientGuid
		    ORder by RowNo
			-- Fill ArchiveTweets table
		    
			SELECT 
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									WHEN @SortColumn = 'Audience+' THEN ROW_NUMBER() OVER(ORDER By Actor_FollowersCount ASC, Actor_DisplayName ASC, MediaDate DESC)
									WHEN @SortColumn = 'Audience-' THEN ROW_NUMBER() OVER(ORDER By Actor_FollowersCount DESC, Actor_DisplayName ASC, MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					tblIQMedia_Archive.MediaDate,
					Actor_DisplayName, 
					Actor_PreferredUserName, 
					Actor_FollowersCount, 
					Actor_FriendsCount, 
					Actor_Image,
					Actor_link,
					Tweet_ID,
					gnip_Klout_Score,
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					tblIQMedia_Archive.PositiveSentiment,
					tblIQMedia_Archive.NegativeSentiment,
					Description,
					tblIQMedia_Archive.DisplayDescription,
					tblIQMedia_Archive.AgentID,
					tblIQMedia_Archive.AgentName,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value

			FROM @tblIQMedia_Archive AS tblIQMedia_Archive
			INNER JOIN ArchiveTweets
			ON tblIQMedia_Archive._ArchiveMediaID = ArchiveTweets.ArchiveTweets_Key
			AND	tblIQMedia_Archive.SubMediaType=ArchiveTweets.v5SubMediaType
			AND ArchiveTweets.ClientGUID = @ClientGuid
			ORder by RowNo


			-- Fill ArchiveTVEyes table
		    
			SELECT 
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					tblIQMedia_Archive.MediaDate,
					DMARank, 
					StationID, 
					Market, 
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					tblIQMedia_Archive.PositiveSentiment,
					tblIQMedia_Archive.NegativeSentiment,
					ArchiveTVEyes.LocalDateTime,
					ArchiveTVEyes.TimeZone,
					Description,
					tblIQMedia_Archive.DisplayDescription,
					tblIQMedia_Archive.AgentID,
					tblIQMedia_Archive.AgentName,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value

			FROM @tblIQMedia_Archive AS tblIQMedia_Archive
			INNER JOIN ArchiveTVEyes
			ON tblIQMedia_Archive._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
			AND	tblIQMedia_Archive.SubMediaType=ArchiveTVEyes.v5SubMediaType
			AND ArchiveTVEyes.ClientGUID = @ClientGuid
			order by RowNo
			
			
			-- Fill ArchiveMisc table
		    
			SELECT 
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					tblIQMedia_Archive.MediaDate,
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					ArchiveMisc.CreateDT,
					ArchiveMisc.CreateDTTimeZone,
					IQUGC_FileTypes.FileType,
					IQUGC_FileTypes.FileTypeExt,
					(SELECT ISNULL(StreamSuffixPath + REPLACE(ArchiveMisc.Location,'\','/'),'') FROM IQCore_RootPath Where ID = ArchiveMisc._RootPathID) as MediaUrl,
					Description,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value

			FROM @tblIQMedia_Archive AS tblIQMedia_Archive
			INNER JOIN ArchiveMisc
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveMisc.ArchiveMiscKey
				AND	tblIQMedia_Archive.SubMediaType=ArchiveMisc.v5SubMediaType
				AND ArchiveMisc.ClientGUID = @ClientGuid
			INNER JOIN IQUGC_FileTypes
				ON IQUGC_FileTypes.ID = ArchiveMisc._FileTypeID
			order by RowNo			
			
			-- Fill ArchivePQ table
		    
			SELECT 
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By tblIQMedia_Archive.MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By tblIQMedia_Archive.MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By tblIQMedia_Archive.MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					tblIQMedia_Archive.MediaDate,
					Publication,
					Author,
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					tblIQMedia_Archive.PositiveSentiment,
					tblIQMedia_Archive.NegativeSentiment,
					Description,
					tblIQMedia_Archive.DisplayDescription,
					tblIQMedia_Archive.AgentID,
					tblIQMedia_Archive.AgentName,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value

			FROM @tblIQMedia_Archive AS tblIQMedia_Archive
			INNER JOIN ArchivePQ
			ON tblIQMedia_Archive._ArchiveMediaID = ArchivePQ.ArchivePQKey
			AND	tblIQMedia_Archive.SubMediaType=ArchivePQ.v5SubMediaType
			AND ArchivePQ.ClientGUID = @ClientGuid
			ORder by RowNo

			-- Fill ArchiveRadio table

			SELECT	
					CASE
									WHEN @SortColumn = 'Date+' THEN ROW_NUMBER() OVER(ORDER By tblIQMedia_Archive.MediaDate ASC)
									WHEN @SortColumn = 'Date-' THEN ROW_NUMBER() OVER(ORDER By tblIQMedia_Archive.MediaDate DESC)
									ELSE ROW_NUMBER() OVER(ORDER By tblIQMedia_Archive.MediaDate DESC)
								END AS RowNo,
					tblIQMedia_Archive.ID,
					_ArchiveMediaID,
					tblIQMedia_Archive.Title,
					tblIQMedia_Archive.HighlightingText,
					tblIQMedia_Archive.Content,
					tblIQMedia_Archive.MediaType,
					tblIQMedia_Archive.SubMediaType,
					tblIQMedia_Archive.SubMediaTypeDesc,
					tblIQMedia_Archive.MediaDate,
					tblIQMedia_Archive.CategoryGUID,
					tblIQMedia_Archive.CategoryName,
					tblIQMedia_Archive.SubCategory1GUID,
					tblIQMedia_Archive.SubCategory1Name,
					tblIQMedia_Archive.SubCategory2GUID,
					tblIQMedia_Archive.SubCategory2Name,
					tblIQMedia_Archive.SubCategory3GUID,
					tblIQMedia_Archive.SubCategory3Name,
					tblIQMedia_Archive.PositiveSentiment,
					tblIQMedia_Archive.NegativeSentiment,
					ArchiveRadio.ClipGuid,
					ArchiveRadio.LocalDatetime,
					IQ_Station.Dma_Name,
					IQ_Station.IQ_Station_ID,
					IQ_Station.TimeZone,
					IQ_Station.Dma_Num,
					Description,
					tblIQMedia_Archive.DisplayDescription,
					tblIQMedia_Archive.AgentID,
					tblIQMedia_Archive.AgentName,
					tblIQMedia_Archive.Position,
					tblIQMedia_Archive.GroupTier1Value,
					tblIQMedia_Archive.GroupTier2Value

			FROM @tblIQMedia_Archive AS tblIQMedia_Archive
			INNER JOIN ArchiveRadio WITH (NOLOCK)
				ON tblIQMedia_Archive._ArchiveMediaID = ArchiveRadio.ArchiveRadioKey
				AND	tblIQMedia_Archive.SubMediaType = ArchiveRadio.v5SubMediaType
				AND ArchiveRadio.ClientGUID = @ClientGuid
			INNER JOIN IQ_Station
				ON IQ_Station.IQ_Station_ID = SUBSTRING(ArchiveRadio.IQ_CC_Key,0 ,CHARINDEX('_',ArchiveRadio.IQ_CC_Key))
			ORder by RowNo


			-- Select Report Details
			
			SELECT 
					IQ_Report.ID,
					ReportGUID,
					Title,
					ReportRule,
					ReportRule.query('Report/Library/Settings') as ReportSettings,
					ReportDate,
					_ReportImageID,
					CASE WHEN IQClient_CustomImage.[Location] IS NULL THEN (SELECT IQClient_CustomImage.Location FROM IQClient_CustomImage Where _ClientGUID = @ClientGuid AND IsActive = 1 AND IsDefault = 1) ELSE IQClient_CustomImage.[Location] END as _ReportImage,
					(SELECT COUNT(1) FROM IQ_Report_ItemPositions WHERE IQ_Report_ItemPositions._ReportGUID = IQ_Report.ReportGUID AND IQ_Report_ItemPositions.IsActive = 1) AS NumSorted
			FROM	IQ_Report
				LEFT OUTER JOIN IQClient_CustomImage
					ON IQ_Report._ReportImageID = IQClient_CustomImage.ID
					AND IQ_Report.ClientGuid = IQClient_CustomImage._ClientGUID
					AND IQClient_CustomImage.IsActive = 1
			WHERE	IQ_Report.ID = @ReportID
			AND		IQ_Report.IsActive = 1
			AND IQ_Report.ClientGuid = @ClientGuid
		
		END
    
END
