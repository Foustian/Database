CREATE PROCEDURE [dbo].[usp_IQTrack_PlayLogNSummary_Select]
	@AssetGuid UNIQUEIDENTIFIER,
	@FromDate			DATE,
	@ToDate				DATE
AS
BEGIN

	DECLARE @TDate DATE = DATEADD(DAY, 1, @ToDate)
	
	SELECT ClipTitle
	FROM ArchiveClip
	WHERE ClipID = @AssetGuid
	
	SELECT COUNT(CONVERT(VARCHAR(10),PlayDate,110)) AS [COUNT], CONVERT(VARCHAR(10),PlayDate,110) AS PlayDate
	FROM IQTrack_PlayLog
	WHERE CONVERT(VARCHAR(10),PlayDate,110) BETWEEN @FromDate AND @TDate
	AND _AssetGuid = @AssetGuid
	GROUP BY CONVERT(VARCHAR(10),PlayDate,110)
	ORDER BY CONVERT(VARCHAR(10),PlayDate,110) DESC
	
	SELECT [COUNT]
	FROM IQTrack_PlaySummary
	WHERE _AssetGuid = @AssetGuid	
	
	SELECT	IQ_IPGeoLookup.Region,
			COUNT(IQTrack_PlayLog.ID) AS [COUNT]
	FROM	IQTrack_PlayLog WITH (NOLOCK)
	INNER	JOIN IQ_IPGeoLookup ON IQTrack_PlayLog.IPAddDecimal BETWEEN IQ_IPGeoLookup.IP_From AND IQ_IPGeoLookup.IP_To
	WHERE	IQ_IPGeoLookup.Country_Code = 'US'
			AND IQTrack_PlayLog._AssetGUID = @AssetGUID
			AND IQTrack_PlayLog.PlayDate BETWEEN @FromDate AND @TDate
	GROUP	BY IQ_IPGeoLookup.Region
	
	SELECT TOP 5
			dbo.fnParseUrl(Referrer) AS Url,
			COUNT(*) AS [COUNT]
	FROM	IQTrack_PlayLog WITH (NOLOCK)
	WHERE	_AssetGUID = @AssetGUID
			AND PlayDate BETWEEN @FromDate AND @TDate
			AND dbo.fnParseUrl(referrer) IS NOT NULL
	GROUP	BY dbo.fnParseUrl(referrer)
	ORDER	BY COUNT(*)	DESC
END
