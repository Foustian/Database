CREATE PROCEDURE [dbo].[usp_IQAgent_SearchRequest_SelectSearchTermBy_IQAgent_SMResultsID]
	@IQAgent_SMResultID bigint
AS
BEGIN
	Select
		IQAgent_SearchRequest.SearchTerm.value('(/SearchRequest//SearchTerm/node())[1]', 'VARCHAR(max)') as SearchTerm,
		IQAgent_SMResults.SeqID as ArticleID
	From
		IQAgent_SearchRequest Inner Join 
			IQAgent_SMResults
				ON IQAgent_SearchRequest.ID = IQAgent_SMResults.IQAgentSearchRequestID	
	Where
		IQAgent_SMResults.ID = @IQAgent_SMResultID AND
		IQAgent_SMResults.IsActive = 1 
END