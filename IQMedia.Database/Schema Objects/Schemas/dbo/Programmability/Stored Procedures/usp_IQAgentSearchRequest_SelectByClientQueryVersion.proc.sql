
CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_SelectByClientQueryVersion]
(
	@ClientGuid			uniqueidentifier,
	@Query_Name			varchar(100),
	@Query_Version		int
)

AS
BEGIN
	SET NOCOUNT ON;
	
	Select
			IQAgent_SearchRequest.ID,
			IQAgent_SearchRequest.SearchTerm,
			--Customer.RedlassoUserName,
			--Customer.RedlassoPassword,
			IQAgent_SearchRequest.ClientGUID,
			IQAgent_SearchRequest.Query_Name,
			IQAgent_SearchRequest.Query_Version
			
	From
			IQAgent_SearchRequest						
	Where
	
			IQAgent_SearchRequest.ClientGUID=@ClientGuid and
			IQAgent_SearchRequest.Query_Name=@Query_Name and
			IQAgent_SearchRequest.Query_Version=@Query_Version and
			IQAgent_SearchRequest.IsActive=1 


END


