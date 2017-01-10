-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[usp_v5_IQAgent_SearchRequest_SelectSearchTermBy_IQAgent_TVResultsID]  
 @IQAgentTVResultID BIGINT,  
 @ClientGuid UNIQUEIDENTIFIER  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  

	IF EXISTS (SELECT NULL FROM IQAgent_MediaResults WHERE ID = @IQAgentTVResultID)
	  BEGIN
		SELECT  
		   CASE  
			WHEN IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/TV/SearchTerm/@IsUserMaster)[1]', 'VARCHAR(max)') = 'false'  
			THEN IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/TV/SearchTerm)[1]', 'VARCHAR(max)')  
			ELSE IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest//SearchTerm/node())[1]', 'VARCHAR(max)')  
		   END AS SearchTerm,  
		   IQAgent_TVResults.RL_VideoGUID AS 'RL_VideoGUID',
		   IQAgent_TVResults.iq_cc_key  
		FROM  
		   IQAgent_TVResults WITH(NOLOCK)  
			INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)  
			 ON IQAgent_TVResults.SearchRequestID = IQAgent_SearchRequest.ID  
			 AND IQAgent_SearchRequest.ClientGUID = @ClientGuid  
			INNER JOIN IQAgent_SearchRequest_History WITH(NOLOCK)  
			 ON IQAgent_SearchRequest.ID=IQAgent_SearchRequest_History._SearchRequestID  
			 AND IQAgent_TVResults._QueryVersion=IQAgent_SearchRequest_History.[Version]  
			INNER JOIN IQAgent_MediaResults WITH(NOLOCK)  
			 ON IQAgent_MediaResults._MediaID=IQAgent_TVResults.ID       
			 AND IQAgent_MediaResults.ID = @IQAgentTVResultID   
			 AND IQAgent_MediaResults.v5Category = IQAgent_TVResults.v5SubMediaType    
		WHERE  
			IQAgent_TVResults.IsActive = 1 AND IQAgent_SearchRequest.IsActive > 0  
	  END
	ELSE
	  BEGIN
		SELECT  
		   CASE  
			WHEN IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/TV/SearchTerm/@IsUserMaster)[1]', 'VARCHAR(max)') = 'false'  
			THEN IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/TV/SearchTerm)[1]', 'VARCHAR(max)')  
			ELSE IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest//SearchTerm/node())[1]', 'VARCHAR(max)')  
		   END AS SearchTerm,  
		   IQAgent_TVResults_Archive.RL_VideoGUID AS 'RL_VideoGUID',
		   IQAgent_TVResults_Archive.iq_cc_key  
		FROM  
		   IQAgent_TVResults_Archive WITH(NOLOCK)  
			INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)  
			 ON IQAgent_TVResults_Archive.SearchRequestID = IQAgent_SearchRequest.ID  
			 AND IQAgent_SearchRequest.ClientGUID = @ClientGuid  
			INNER JOIN IQAgent_SearchRequest_History WITH(NOLOCK)  
			 ON IQAgent_SearchRequest.ID=IQAgent_SearchRequest_History._SearchRequestID  
			 AND IQAgent_TVResults_Archive._QueryVersion=IQAgent_SearchRequest_History.[Version]  
			INNER JOIN IQAgent_MediaResults_Archive WITH(NOLOCK)  
			 ON IQAgent_MediaResults_Archive._MediaID=IQAgent_TVResults_Archive.ID       
			 AND IQAgent_MediaResults_Archive.ID = @IQAgentTVResultID   
			 AND IQAgent_MediaResults_Archive.v5Category = IQAgent_TVResults_Archive.v5SubMediaType    
		WHERE  
			IQAgent_TVResults_Archive.IsActive = 1 AND IQAgent_SearchRequest.IsActive > 0  
	  END

END  