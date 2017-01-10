CREATE PROCEDURE [dbo].[usp_v4_IQSession_Insert]  
(  
 @SessionID VARCHAR(255),  
 @LoginID VARCHAR(255),  
 @SessionTimeout DATETIME,  
 @LastAccessTime DATETIME,  
 @Server varchar(16)   
)  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
    
 If not exists (Select SessionID from IQSession where SessionID=@SessionID)  
 Begin  
   
  INSERT INTO IQSession  
  (  
   SessionID,  
   LoginID,  
   SessionTimeOut,  
   LastAccessTime,  
   [Server]  
  )  
  VALUES  
  (  
   @SessionID,  
   @LoginID,  
   @SessionTimeout,  
   @LastAccessTime,  
   @Server  
  )  
    
 End  
 Else  
 Begin  
   
  Update IQSession  
  Set   
   SessionTimeOut = @SessionTimeout,  
   LastAccessTime = @LastAccessTime,  
   [Server] = @Server,
   [LoginID] = @LoginID
  Where  
   SessionID = @SessionID  
   
 End  
  
END