CREATE PROCEDURE [dbo].[usp_v5_IQDataImport_Sony_SelectTableData]  
	@ClientGuid UNIQUEIDENTIFIER,
	@FromDate DATE,
	@ToDate DATE,
	@SearchRequestIDXml XML,
	@PageSize INT,
	@StartIndex INT,
	@TableType VARCHAR(20),
	@NumTotalRecords INT OUTPUT
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

	CREATE Table #tblResults (ArtistID BIGINT, Artist VARCHAR(300), Album VARCHAR(300), Track VARCHAR(300), SpotifyCount BIGINT, ITunesAlbumCount BIGINT, ITunesTrackCount BIGINT, AppleMusicCount BIGINT, TotalCount BIGINT)

	INSERT INTO #tblResults (ArtistID, Artist, Album, Track, SpotifyCount, ITunesAlbumCount, ITunesTrackCount, AppleMusicCount, TotalCount)
	SELECT	_Artist_ID,
			Artist_Name,
			Album,
			Track,
			Spotify,
			ITunes_Album,
			ITunes_Track,
			Apple_Music,
			ISNULL(Spotify, 0) + ISNULL(ITunes_Album, 0) + ISNULL(ITunes_Track, 0) + ISNULL(Apple_Music, 0)
	FROM 
	(
		SELECT	DailyCount, 
				IQDataImport_SonyDailySummary._Artist_ID,
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

	SELECT * FROM
		(
			SELECT	ROW_NUMBER() OVER(ORDER BY TotalCount DESC) AS RowNum,
					Artist,
					Album,
					Track,
					SpotifyCount,
					ITunesAlbumCount,
					ITunesTrackCount,
					AppleMusicCount,
					TotalCount
			FROM	#tblResults tblResults
		) AS T
	WHERE RowNum > @StartIndex AND RowNum <= (@StartIndex + @PageSize)
	Order By RowNum

	SELECT @NumTotalRecords = COUNT(*)
	FROM #tblResults
END