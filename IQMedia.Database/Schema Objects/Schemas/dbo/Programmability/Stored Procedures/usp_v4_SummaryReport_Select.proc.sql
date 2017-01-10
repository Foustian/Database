-- =============================================
-- Author:		iQ media
-- Create date: 6/27/2013 
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_SummaryReport_Select]
(
	@ClientGUID		uniqueidentifier,
	@FromDate			date,
	@ToDate				date
)	
AS
BEGIN	
	SET NOCOUNT ON;
	
	
		SELECT
				ClientGuid,
				DayDate,
				MediaType,
				SubMediaType,
			    NoOfDocs,
			    NoOfHits,
				Audience,
				IQMediaValue
		FROM
				IQAgent_DaySummary
		Where
				(IQAgent_DaySummary.ClientGuid=@ClientGUID)
		AND		((@FromDate is null or @ToDate is null) OR IQAgent_DaySummary.DayDate  BETWEEN @FromDate AND @ToDate) 
	
END


