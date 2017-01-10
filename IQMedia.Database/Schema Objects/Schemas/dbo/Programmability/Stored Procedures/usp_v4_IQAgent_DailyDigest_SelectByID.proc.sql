CREATE PROCEDURE [dbo].[usp_v4_IQAgent_DailyDigest_SelectByID]
	@ID bigint
AS
BEGIN
	SELECT
			ID,
			EmailAddress,
			AgentXml,
			_ReportImageID,
			dateadd(hour,Client.gmt, IQAgent_DailyDigest.TimeOfDay) as TimeOfDay
	FROM
			IQAgent_DailyDigest
				inner join Client
					on IQAgent_DailyDigest._ClientGuid = Client.ClientGUID
					and Client.IsActive = 1
	WHERE
			ID = @ID
END