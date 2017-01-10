CREATE PROCEDURE [dbo].[usp_v5_IQDataImport_Sony_SelectExportData]  
	@ClientGuid UNIQUEIDENTIFIER,
	@FromDate DATE,
	@ToDate DATE,
	@SearchRequestIDXml XML,
	@TableType VARCHAR(20),
	@MediaTypeAccessXml xml
AS  
BEGIN  	

	CREATE Table #tblSearchRequests (ID BIGINT)
	IF @SearchRequestIDXml IS NULL
	  BEGIN
		INSERT INTO #tblSearchRequests (ID)
		SELECT	ID
		FROM	IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
		WHERE	ClientGUID = @ClientGuid
				AND IsActive > 0
	  END
	ELSE
	  BEGIN
		INSERT INTO #tblSearchRequests (ID)
		SELECT	Search.req.value('@id','bigint')
		FROM	@SearchRequestIDXml.nodes('list/item') as Search(req) 
	  END

	DECLARE @MediaTypeAccessTbl TABLE(SubMediaType VARCHAR(50), HasAccess BIT)
	DECLARE	@HasMediaTypeAccess BIT = 0

	INSERT INTO @MediaTypeAccessTbl
	(
		SubMediaType,
		HasAccess
	)
	SELECT
		MT.A.value('@SubMediaType','VARCHAR(50)'),
		MT.A.value('@HasAccess','BIT')
	FROM
		@MediaTypeAccessXml.nodes('list/item') AS MT(A)
	WHERE
		MT.A.value('@TypeLevel','INT') = 2

	CREATE Table #tblResults (DayDate DATETIME, MediaType VARCHAR(50), AgentName VARCHAR(MAX), Artist VARCHAR(300), Album VARCHAR(300), Track VARCHAR(300), SpotifyCount BIGINT, ITunesAlbumCount BIGINT, ITunesTrackCount BIGINT, AppleMusicCount BIGINT, NoOfDocs BIGINT, NoOfHits BIGINT)

	INSERT INTO #tblResults (DayDate, MediaType, AgentName, NoOfDocs, NoOfHits)
	SELECT
		DayDate,
		DisplayName,
		Query_Name,
		NoOfDocsLD,
		NoOfHitsLD
	FROM 
		IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
			INNER JOIN #tblSearchRequests tblSearchRequests
				ON IQAgent_SearchRequest.ID = tblSearchRequests.ID
			INNER JOIN IQMediaGroup.dbo.IQAgent_DaySummary WITH (NOLOCK)
				ON IQAgent_DaySummary._SearchRequestID = IQAgent_SearchRequest.ID
				AND IQAgent_DaySummary.ClientGuid = @ClientGUID
				AND	((@FromDate is null or @ToDate is null) OR IQAgent_DaySummary.DayDate BETWEEN @FromDate AND @ToDate)
			INNER JOIN @MediaTypeAccessTbl AS MTA
				ON	IQAgent_DaySummary.SubMediaType = MTA.SubMediaType
				AND MTA.HasAccess = 1
			LEFT OUTER JOIN IQMediaGroup.dbo.IQ_MediaTypes 
				ON IQ_MediaTypes.SubMediaType = IQAgent_DaySummary.SubMediaType

	INSERT INTO #tblResults (DayDate, MediaType, AgentName, Artist, Album, Track, SpotifyCount, ITunesAlbumCount, ITunesTrackCount, AppleMusicCount, NoOfDocs, NoOfHits)
	SELECT	Report_Date,
			'Custom',
			Query_Name,
			Artist_Name,
			Album,
			Track,
			Spotify,
			ITunes_Album,
			ITunes_Track,
			Apple_Music,
			0,
			0
	FROM 
	(
		SELECT	Report_Date,
				DailyCount, 
				Query_Name,
				Artist_Name,
				CASE @TableType WHEN 'Artist' THEN '' ELSE Album END AS Album,
				CASE @TableType WHEN 'Track' THEN Track ELSE '' END AS Track,
				CASE SourceType 
					WHEN 'S' THEN 'Spotify'
					WHEN 'A' THEN 'Apple_Music'
					ELSE CASE AlbumTrackCd 
						WHEN 'T' THEN 'ITunes_Track' 
						ELSE 'ITunes_Album' 
					END
				END AS DataType
		FROM	IQMediaGroup.dbo.IQDataImport_SonyDailySummary WITH (NOLOCK)
		INNER	JOIN IQMediaGroup.dbo.IQDataImport_SonyAgent WITH (NOLOCK)
				ON IQDataImport_SonyAgent._Artist_ID = IQDataImport_SonyDailySummary._Artist_ID
				AND IQDataImport_SonyAgent.IsActive = 1
		INNER	JOIN #tblSearchRequests tblSearchRequests
				ON tblSearchRequests.ID = IQDataImport_SonyAgent._SearchRequestID
		INNER	JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
				ON IQAgent_SearchRequest.ID = tblSearchRequests.ID
		INNER	JOIN IQMediaGroup.dbo.IQDataImport_SonyArtist 
				ON IQDataImport_SonyArtist.ID = IQDataImport_SonyDailySummary._Artist_ID
				AND IQDataImport_SonyArtist.IsActive = 1
		WHERE	(@FromDate IS NULL OR @ToDate IS NULL OR Report_Date BETWEEN @FromDate AND @ToDate)
				AND IQDataImport_SonyDailySummary.IsActive = 1
				AND (
						 (SourceType = 'A' AND @TableType != 'Album')
					  OR (SourceType = 'S' AND (@TableType != 'Album' OR IQDataImport_SonyDailySummary._Artist_ID = Album_ArtistID))
					  OR (SourceType = 'I' AND (
							(@TableType != 'Track' AND AlbumTrackCd = 'A') OR (@TableType != 'Album' AND AlbumTrackCd = 'T'))
						 )
					)
	) AS SourceTbl
	PIVOT
	(
		SUM(DailyCount)
		FOR DataType IN ([Spotify],[ITunes_Track],[ITunes_Album],[Apple_Music])
	) AS PivotTbl

	SELECT	DayDate,
			MediaType,
			AgentName,
			ISNULL(Artist, '') as Artist,
			ISNULL(Album, '') as Album,
			ISNULL(Track, '') as Track,
			SpotifyCount,
			ITunesAlbumCount,
			ITunesTrackCount,
			AppleMusicCount,
			NoOfDocs,
			NoOfHits
	FROM	#tblResults
	ORDER	BY DayDate, AgentName, MediaType
END