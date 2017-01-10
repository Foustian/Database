  
CREATE PROCEDURE [dbo].[usp_v4_IQSession_SelectAll]  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
   
 SELECT  
   SessionID,  
   LoginID,  
   SessionTimeOut,  
   LastAccessTime,  
   [Server]  
 FROM  
   IQSession  
    
  
END