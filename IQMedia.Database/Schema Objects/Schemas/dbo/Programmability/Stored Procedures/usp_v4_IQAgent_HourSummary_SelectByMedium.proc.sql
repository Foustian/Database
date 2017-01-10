-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQAgent_HourSummary_SelectByMedium]
	@ClientGUID		uniqueidentifier,
	@FromDate			datetime,
	@ToDate				datetime,
	@Medium		varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
				ClientGuid,
				HourDateTime,
				MediaType,
				SubMediaType,
			    NoOfDocs,
			    NoOfHits,
				Audience,
				IQMediaValue,
				PositiveSentiment,
				NegativeSentiment
		FROM
				IQAgent_HourSummary
		Where
				(IQAgent_HourSummary.ClientGuid=@ClientGUID)
		AND		((@FromDate is null or @ToDate is null) OR IQAgent_HourSummary.HourDateTime  BETWEEN @FromDate AND @ToDate) 
		AND		(@Medium is null or SubMediaType = @Medium)
END
