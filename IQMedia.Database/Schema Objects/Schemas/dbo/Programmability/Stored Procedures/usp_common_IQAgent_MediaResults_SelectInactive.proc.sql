CREATE PROCEDURE [dbo].[usp_common_IQAgent_MediaResults_SelectInactive]
	@ClientGUID uniqueidentifier
AS
BEGIN
	SELECT  Deletes.ID.value('.', 'bigint') as ID
	FROM	IQMediaGroup.dbo.IQAgent_DeleteControl
	CROSS	APPLY statusUpdateData.nodes('add/doc/field[@name="iqseqid"]') as Deletes(ID)
	WHERE	clientGUID = @ClientGUID
	AND		isSolrUpdated != 'COMPLETED'
	AND		searchRequestID IS NULL
	
	SELECT	distinct searchRequestID
	FROM	IQMediaGroup.dbo.IQAgent_DeleteControl
	WHERE	clientGUID = @ClientGUID
	AND		isSolrUpdated != 'COMPLETED'
	AND		searchRequestID IS NOT NULL
END