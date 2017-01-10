CREATE PROCEDURE [dbo].[usp_IQAgent_SearchRequest_SelectSearchTermBy_IQAgent_NMResultsID]
	@IQAgent_NMResultID bigint
AS
BEGIN
	Select
		IQAgent_SearchRequest.SearchTerm.value('(/SearchRequest//SearchTerm/node())[1]', 'VARCHAR(max)') as SearchTerm,
		IQAgent_NMResults.ArticleID
	From
		IQAgent_SearchRequest Inner Join 
			IQAgent_NMResults
				ON IQAgent_SearchRequest.ID = IQAgent_NMResults.IQAgentSearchRequestID	
	Where
		IQAgent_NMResults.ID = @IQAgent_NMResultID AND
		IQAgent_NMResults.IsActive = 1 
END