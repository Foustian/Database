-- =============================================    
-- Author:  <Author,,Name>    
-- Create date: 06 August 2013    
-- Description: Display all the results by ClientGuid    
-- =============================================    
CREATE PROCEDURE [dbo].[usp_v4_IQAgent_SearchRequest_SelectByClientGuid]   
(
	@ClientGuid  UNIQUEIDENTIFIER,  
	@IncludeDeleted BIT
)
AS    
BEGIN    
 
 SET NOCOUNT ON;    
    
 SELECT    
		ID,    
		Query_Name,   
		[SearchTerm].value('(/SearchRequest//SearchTerm/node())[1]','nvarchar(max)') as SearchTerm,   
		Query_Version,    
		ModifiedDate,  
		CONVERT(BIT, SearchTerm.exist('SearchRequest/PM')) AS IsRestrictedMedia,
		IsActive
FROM 
		IQAgent_SearchRequest    
WHERE 
		ClientGUID = @ClientGuid    
	AND  (IsActive > 0 OR @IncludeDeleted = 1)

ORDER BY Query_Name     
    
END 

