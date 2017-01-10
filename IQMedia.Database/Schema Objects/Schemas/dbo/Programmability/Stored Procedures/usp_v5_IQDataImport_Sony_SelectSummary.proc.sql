CREATE PROCEDURE [dbo].[usp_v5_IQDataImport_Sony_SelectSummary]
	@ClientGuid UNIQUEIDENTIFIER,
	@FromDate DATE,
	@ToDate DATE,
	@DateIntervalType TINYINT,
	@SearchRequestIDXml XML,
	@FilterXml XML,
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


	-- Chart Summary Data
	SELECT
			MAX(DayDate) as GMTDateTime,
			Sum(Cast(NoOfDocsLD as bigint)) as NoOfDocs,
			NULL as Artist,
			NULL as Album,
			NULL as Track,
			IQAgent_DaySummary.MediaType,
			IQAgent_DaySummary.SubMediaType,
			_SearchRequestID as SearchRequestID,	
			'SubMedia' as SeriesType
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
	Group By					
			_SearchRequestID, IQAgent_DaySummary.SubMediaType, IQAgent_DaySummary.MediaType,		
			DATEPART(YEAR, DayDate), DATEPART(MONTH, DayDate), CASE @DateIntervalType WHEN 1 THEN DATEPART(DAY, DayDate) END

	UNION ALL
				
	SELECT	MAX(Report_Date) AS GMTDateTime,
			SUM(DailyCount) AS NoOfDocs,
			Artist_Name as Artist,
			Album,
			Track,
			null as MediaType,
			CASE SourceType WHEN 'I' THEN 'iTunes' WHEN 'S' THEN 'Spotify' WHEN 'A' THEN 'Apple' END as SubMediaType,
			_SearchRequestID AS SearchRequestID,
			'Client' as SeriesType
	FROM	IQMediaGroup.dbo.IQDataImport_SonyDailySummary WITH (NOLOCK)
	INNER	JOIN IQMediaGroup.dbo.IQDataImport_SonyAgent WITH (NOLOCK)
			ON IQDataImport_SonyAgent._Artist_ID = IQDataImport_SonyDailySummary._Artist_ID
			AND IQDataImport_SonyAgent.IsActive = 1
	INNER	JOIN #tblSearchRequests tblSearchRequests
			ON tblSearchRequests.ID = IQDataImport_SonyAgent._SearchRequestID
	-- Remove once filter is switched from names to IDs
	INNER	JOIN IQMediaGroup.dbo.IQDataImport_SonyArtist
			ON IQDataImport_SonyArtist.ID = IQDataImport_SonyDailySummary._Artist_ID
	INNER	JOIN @FilterXml.nodes('list/item') as Filter(item)
			ON (Filter.item.value('@artist', 'varchar(300)') = '' OR Filter.item.value('@artist', 'varchar(300)') = IQDataImport_SonyArtist.Artist_Name)
			AND (Filter.item.value('@album', 'varchar(300)') = '' OR Filter.item.value('@album', 'varchar(300)') = IQDataImport_SonyDailySummary.Album)
			AND (Filter.item.value('@track', 'varchar(300)') = '' OR Filter.item.value('@track', 'varchar(300)') = IQDataImport_SonyDailySummary.Track)
	WHERE	(@FromDate IS NULL OR @ToDate IS NULL OR Report_Date BETWEEN @FromDate AND @ToDate)
			AND IQDataImport_SonyDailySummary.IsActive = 1
			AND 
			(
				   (SourceType = 'A' AND @TableType != 'Album')
				OR (SourceType = 'S' AND (@TableType != 'Album' OR IQDataImport_SonyDailySummary._Artist_ID = Album_ArtistID))
				OR (SourceType = 'I' AND (
					(@TableType != 'Track' AND AlbumTrackCd = 'A') OR (@TableType != 'Album' AND AlbumTrackCd = 'T'))
					)
			)
	GROUP	BY _SearchRequestID, Artist_Name, Album, Track,
			CASE SourceType WHEN 'I' THEN 'iTunes' WHEN 'S' THEN 'Spotify' WHEN 'A' THEN 'Apple' END,
			DATEPART(YEAR, Report_Date), DATEPART(MONTH, Report_Date), CASE @DateIntervalType WHEN 1 THEN DATEPART(DAY, Report_Date) END
END