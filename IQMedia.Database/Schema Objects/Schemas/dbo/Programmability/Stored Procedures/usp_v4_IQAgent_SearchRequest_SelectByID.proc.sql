-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: 06 August 2013  
-- Description: Select single IQAgentSearchRequest by ID  
-- =============================================  
CREATE PROCEDURE [dbo].[usp_v4_IQAgent_SearchRequest_SelectByID]  
 @ID    BIGINT,  
 @ClientGuid  UNIQUEIDENTIFIER  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 SELECT  
   ID,  
   Query_Name,  
   Query_Version,  
   ModifiedDate,  
   SearchTerm  
 FROM IQAgent_SearchRequest  
 WHERE ID = @ID  
 AND  ClientGUID = @ClientGuid  
 AND  IsActive > 0
     
  
END  