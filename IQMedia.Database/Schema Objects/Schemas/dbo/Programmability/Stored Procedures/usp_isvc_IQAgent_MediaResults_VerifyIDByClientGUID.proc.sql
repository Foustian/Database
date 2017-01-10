CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_MediaResults_VerifyIDByClientGUID]
	@IQAgentID BIGINT,
	@ClientGuid	UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
		IQAgent_MediaResults.ID
	FROM
		IQAgent_MediaResults
				INNER JOIN IQAgent_SearchRequest
					ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID
					AND IQAgent_SearchRequest.ClientGUID = @ClientGuid
					AND IQAgent_MediaResults.ID = @IQAgentID 
					AND IQAgent_MediaResults.MediaType='TV'
	WHERE
		IQAgent_MediaResults.IsActive = 1 AND IQAgent_SearchRequest.IsActive > 0
END