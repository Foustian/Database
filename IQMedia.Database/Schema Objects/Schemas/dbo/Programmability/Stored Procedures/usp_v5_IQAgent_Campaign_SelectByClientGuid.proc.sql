USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v5_IQAgent_Campaign_SelectByClientGuid]    Script Date: 5/25/2016 14:38:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_v5_IQAgent_Campaign_SelectByClientGuid]     
(
	@ClientGuid  UNIQUEIDENTIFIER
)
AS    
BEGIN    
 
 SET NOCOUNT ON;    
    
 SELECT IQAgent_Campaign.ID,    
		Name,
		_SearchRequestID as SearchRequestID,
		IQAgent_SearchRequest.Query_Name,   
		StartDatetime,
		EndDatetime,
		IQAgent_SearchRequest.Query_Version,
		IQAgent_Campaign.ModifiedDate,
		IQAgent_Campaign.IsActive
FROM	IQMediaGroup.dbo.IQAgent_Campaign WITH (NOLOCK)
INNER	JOIN IQMediaGroup.dbo.IQAgent_SearchRequest WITH (NOLOCK)
		ON IQAgent_SearchRequest.ID = IQAgent_Campaign._SearchRequestID
WHERE	ClientGuid = @ClientGuid    
		AND IQAgent_Campaign.IsActive > 0
		AND IQAgent_SearchRequest.IsActive > 0
ORDER	BY Name     
    
END 