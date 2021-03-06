CREATE procedure [dbo].[usp_common_IQAgent_MediaResults_SelectQueuedIsRead]
	@ClientGUID UNIQUEIDENTIFIER
AS
BEGIN
	SELECT	_MediaResultID as ID,
			IsRead
	FROM	IQMediaGroup.dbo.IQAgent_MediaResults_UpdatedRecords_IsRead
	WHERE	ClientGUID = @ClientGUID
			AND SolrStatus != 1
			AND IsActive = 1
END