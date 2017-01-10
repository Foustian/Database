
CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_Select]
	
AS
BEGIN	
	SET NOCOUNT ON;

    Select
			IQAgentRequest.ID,
			IQAgentRequest.SearchTerm,
			--Customer.RedlassoUserName,
			--Customer.RedlassoPassword,
			Query_Name,
			Query_Version,
			IQAgentRequest.ClientGUID
	
	From
    
    (
			Select
						
						IQAgent_SearchRequest.ID,
						IQAgent_SearchRequest.SearchTerm,
						TempQueryVersion.Query_Name,
						TempQueryVersion.Query_Version,
						IQAgent_SearchRequest.ClientGUID
		    
			From
					
						IQAgent_SearchRequest,
						(   
		    
							Select
										IQAgent_SearchRequest.Query_Name,
										MAX(IQAgent_SearchRequest.Query_Version) as Query_Version
									
							From	
										IQAgent_SearchRequest
										
							Where
										IQAgent_SearchRequest.IsActive=1
									
							Group by
										IQAgent_SearchRequest.Query_Name
								
						) TempQueryVersion
			
			Where
						IQAgent_SearchRequest.Query_Name=TempQueryVersion.Query_Name and
						IQAgent_SearchRequest.Query_Version=TempQueryVersion.Query_Version and
						IQAgent_SearchRequest.IsActive=1
				
	) IQAgentRequest
	
END
