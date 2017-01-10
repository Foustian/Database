-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgent_SearchRequest_SelectSearchTermBy_IQAgent_TVResultsID]
	@IQAgentTVResultID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select
		IQAgent_SearchRequest.SearchTerm.value('(/SearchRequest//SearchTerm/node())[1]', 'VARCHAR(max)') as SearchTerm,
		IQAgent_TVResults.RL_VideoGUID
		From
		IQAgent_TVResults 
		Inner Join IQAgent_SearchRequest
		ON IQAgent_TVResults.SearchRequestID = IQAgent_SearchRequest.ID
		
		Where
		IQAgent_TVResults.ID = @IQAgentTVResultID AND
		IQAgent_TVResults.IsActive = 1 
    
END
