-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQAgent_DaySummary_SelectByMedium]
	@ClientGUID		uniqueidentifier,
	@FromDate			date,
	@ToDate				date,
	@Medium		varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
				ClientGuid,
				DayDate,
				MediaType,
				SubMediaType,
			    NoOfDocs,
			    NoOfHits,
				Audience,
				IQMediaValue,
				PositiveSentiment,
				NegativeSentiment
		FROM
				IQAgent_DaySummary
		Where
				(IQAgent_DaySummary.ClientGuid=@ClientGUID)
		AND		((@FromDate is null or @ToDate is null) OR IQAgent_DaySummary.DayDate  BETWEEN @FromDate AND @ToDate) 
		AND		(@Medium Is Null or SubMediaType = @Medium)
END
