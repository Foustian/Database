CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_SearchRequest_SelectTVRequests]
	@ClientGuid uniqueidentifier,
	@SRIDList xml
AS
BEGIN	
	IF(@SRIDList IS NOT NULL)
	BEGIN
		
		SELECT 
			IQAgent_SearchRequest.ID AS SRID,
			Query_Name AS AgentName,
			SearchTerm,
			--SearchTerm.query('SearchRequest/SearchTerm').value('.','nvarchar(max)') as SearchTerm,
			IQAgent_SearchRequest.CreatedDate,
			IQAgent_SearchRequest.ModifiedDate 
		FROM 
			IQAgent_SearchRequest WITH(NOLOCK)
				INNER JOIN Client	
					ON IQAgent_SearchRequest.ClientGUID = Client.ClientGUID
				INNER JOIN @SRIDList.nodes('TVAgentsInput/SRIDList/SRID/ID') AS tblXml(c)
					ON IQAgent_SearchRequest.ID = tblXml.c.query('.').value('.','bigint')
		WHERE
			IQAgent_SearchRequest.ClientGUID = @ClientGuid
			AND IQAgent_SearchRequest.IsActive > 0
			AND Client.IsActive = 1
			AND  SearchTerm.exist('SearchRequest/TV')  =1		
		ORDER BY Query_Name
		
	END
	ELSE
	BEGIN
		
		SELECT 
			IQAgent_SearchRequest.ID AS SRID,
			Query_Name AS AgentName,
			SearchTerm,
			--SearchTerm.query('SearchRequest/SearchTerm').value('.','nvarchar(max)') as SearchTerm,
			IQAgent_SearchRequest.CreatedDate,
			IQAgent_SearchRequest.ModifiedDate 
		FROM 
			IQAgent_SearchRequest WITH(NOLOCK)
				INNER JOIN Client	
					ON IQAgent_SearchRequest.ClientGUID = Client.ClientGUID
		WHERE
			IQAgent_SearchRequest.ClientGUID = @ClientGuid
			AND IQAgent_SearchRequest.IsActive > 0
			AND Client.IsActive = 1
			AND  SearchTerm.exist('SearchRequest/TV')  =1
		ORDER BY Query_Name
		
	END
END