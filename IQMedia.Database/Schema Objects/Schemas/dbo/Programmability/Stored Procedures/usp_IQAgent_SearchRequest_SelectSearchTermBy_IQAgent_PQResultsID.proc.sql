CREATE PROCEDURE [dbo].[usp_IQAgent_SearchRequest_SelectSearchTermBy_IQAgent_PQResultsID]
	@IQAgent_PQResultID bigint
AS
BEGIN
	Select
		IQAgent_SearchRequest.SearchTerm.value('(/SearchRequest//SearchTerm/node())[1]', 'VARCHAR(max)') as SearchTerm,
		IQAgent_PQResults.ProQuestID
	From
		IQAgent_SearchRequest Inner Join 
			IQAgent_PQResults
				ON IQAgent_SearchRequest.ID = IQAgent_PQResults.IQAgentSearchRequestID	
	Where
		IQAgent_PQResults.ID = @IQAgent_PQResultID 
END