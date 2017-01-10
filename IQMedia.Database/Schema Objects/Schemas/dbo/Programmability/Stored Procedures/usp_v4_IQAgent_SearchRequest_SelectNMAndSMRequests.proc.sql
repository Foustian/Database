CREATE PROCEDURE [dbo].[usp_v4_IQAgent_SearchRequest_SelectNMAndSMRequests]
	@ClientGuid		UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
			ID,
			Query_Name
	FROM	IQAgent_SearchRequest
	WHERE	ClientGUID = @ClientGuid
	AND		IsActive = 1
	And		(
				IQAgent_SearchRequest.SearchTerm.exist('SearchRequest/SocialMedia') = 1 or 
				IQAgent_SearchRequest.SearchTerm.exist('SearchRequest/News') = 1
			)
	ORDER BY Query_Name	

END