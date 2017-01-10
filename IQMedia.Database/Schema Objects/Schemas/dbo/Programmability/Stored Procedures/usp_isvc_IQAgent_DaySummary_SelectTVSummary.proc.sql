CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_DaySummary_SelectTVSummary]
	@ClientGUID			uniqueidentifier,
	@FromDate			date,
	@ToDate				date,
	@SearchRequestID	bigint
AS
BEGIN
	SELECT
				DayDate as [GMTDate],
				IQAgent_SearchRequest.ID as SRID,
				Sum(Cast(NoOfDocs as bigint)) as 'GMTRecordCount',
			    Sum(NoOfHits) as 'GMTHitCount',
				Sum(Audience) as 'GMTNielsenAudience',
				Sum(IQMediaValue) as 'GMTIQMediaValue',
				Sum(Cast(PositiveSentiment as bigint)) as 'GMTPositiveSentiment',
				Sum(Cast(NegativeSentiment as bigint)) as 'GMTNegativeSentiment'
		FROM
				IQAgent_DaySummary
					INNER JOIN IQAgent_SearchRequest
						ON IQAgent_DaySummary._SearchRequestID = IQAgent_SearchRequest.ID
						AND IQAgent_SearchRequest.IsActive > 0
		Where
				IQAgent_DaySummary.ClientGuid=@ClientGUID
		AND		IQAgent_DaySummary.DayDate  BETWEEN @FromDate AND @ToDate
		AND		SubMediaType = 'TV'
		AND		(@SearchRequestID IS NULL OR _SearchRequestID = @SearchRequestID)
	
		Group By	
				DayDate,IQAgent_DaySummary.ClientGuid,IQAgent_SearchRequest.ID
END