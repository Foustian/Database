CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_HourSummary_SelectTVSummary]
	@ClientGUID			uniqueidentifier,
	@FromDate			datetime,
	@ToDate				datetime,
	@SearchRequestID	bigint
AS
BEGIN
	SELECT
				HourDateTime AS 'GMTDatetime',
				IQAgent_SearchRequest.ID as 'SRID',
			    Sum(Cast(NoOfDocs as bigint)) as 'TotalRecordCount',
			    Sum(NoOfHits) as 'HitCount',
				Sum(Audience) as 'NielsenAudience',
				Sum(IQMediaValue) as 'IQMediaValue',
				Sum(Cast(PositiveSentiment as bigint)) as 'PositiveSentiment',
				Sum(Cast(NegativeSentiment as bigint)) as 'NegativeSentiment'
		FROM
				IQAgent_HourSummary
					INNER JOIN IQAgent_SearchRequest
						ON IQAgent_HourSummary._SearchRequestID = IQAgent_SearchRequest.ID
						AND IQAgent_SearchRequest.IsActive > 0

		Where
				IQAgent_HourSummary.ClientGuid=@ClientGUID
		AND		IQAgent_HourSummary.HourDateTime  BETWEEN @FromDate AND @ToDate
		AND		SubMediaType = 'TV'
		AND		(@SearchRequestID IS NULL OR _SearchRequestID = @SearchRequestID)
	
		Group By	
				HourDateTime,IQAgent_HourSummary.ClientGuid,IQAgent_SearchRequest.ID
END