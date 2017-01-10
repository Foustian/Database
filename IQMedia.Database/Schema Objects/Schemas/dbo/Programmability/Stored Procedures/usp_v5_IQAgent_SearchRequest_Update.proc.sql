CREATE PROCEDURE [dbo].[usp_v5_IQAgent_SearchRequest_Update]       
 @IQAgent_SearchRequestID BIGINT,    
 @ClientGuid UNIQUEIDENTIFIER,    
 @Query_Name VARCHAR(200),    
 @SearchTerm XML,    
 @Output INT OUTPUT    
AS     
BEGIN    
     
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
 IF NOT EXISTS(SELECT 1 FROM IQAgent_SearchRequest WHERE ID <> @IQAgent_SearchRequestID AND Query_Name = @Query_Name AND IsActive =  1 AND ClientGUID = @ClientGuid)    
  BEGIN    
     
     DECLARE @Version BIGINT,  
   @OldSearchTerm XML,  
   @PMXml XML     
        
     SELECT @Version = Query_Version,  
   @OldSearchTerm=SearchTerm  
     FROM IQAgent_SearchRequest     
     WHERE ClientGUID = @ClientGUID     
     AND  ID = @IQAgent_SearchRequestID    
       
     SELECT   
   @PMXml=CASE WHEN tbl.c.exist('PM')=1 THEN tbl.c.query('PM') ELSE NULL END  
     FROM  
   @OldSearchTerm.nodes('SearchRequest') AS tbl(c)   
    
 IF (@PMXml IS NOT NULL)  
  BEGIN  
   SET @SearchTerm.modify('insert sql:variable("@PMXml") into (/SearchRequest)[1]')
  END  
         
 BEGIN TRANSACTION;   
           
 UPDATE   
   IQAgent_SearchRequest       
 SET    
  Query_Name = @Query_Name,      
       SearchTerm = @SearchTerm,    
       Query_Version = @Version + 1,    
       ModifiedDate=GETDATE() 
 WHERE   
   ClientGUID = @ClientGuid       
     AND  ID = @IQAgent_SearchRequestID    
  AND IsActive=1  
         
 IF(@@ROWCOUNT>0)  
 BEGIN  
     INSERT INTO IQAgent_SearchRequest_History    
     (    
      _SearchRequestID,    
      [VERSION],    
      SearchRequest,    
      Name,    
      DateCreated
     )    
     VALUES    
     (    
      @IQAgent_SearchRequestID,    
      @Version + 1,    
      @SearchTerm,    
      @Query_Name,    
      GETDATE()
     )    

	-- If the agent doesn't have a Twitter section, deactivate any active records in IQ_Twitter_Settings belonging to it
	DECLARE @HasTwitter BIT = @SearchTerm.exist('SearchRequest/Twitter')

	IF (@HasTwitter = 0)
	  BEGIN
		UPDATE IQ_Twitter_Settings
		SET IsActive = 0,
			ModifiedDate = GETDATE()
		WHERE SRID = @IQAgent_SearchRequestID
			AND IsActive = 1
	
		IF (@@ROWCOUNT > 0)
		  BEGIN
			exec usp_v5_IQService_TwitterSettings_Insert @ClientGuid, null, @IQAgent_SearchRequestID, 0
		  END
	  END
	  
	-- If the agent doesn't have a TM section, deactivate any active records in IQ_TVEyes_Settings belonging to it
	DECLARE @HasTVEyes BIT = @SearchTerm.exist('SearchRequest/TM')

	IF (@HasTVEyes = 0)
	  BEGIN
		UPDATE IQ_TVEyes_Settings
		SET IsActive = 0,
			ModifiedDate = GETDATE()
		WHERE SRID = @IQAgent_SearchRequestID
			AND IsActive = 1
	
		IF (@@ROWCOUNT > 0)
		  BEGIN
			exec usp_v5_IQService_TVEyesSettings_Insert @ClientGuid, null, @IQAgent_SearchRequestID, 0
		  END
	  END

   SET @Output = @IQAgent_SearchRequestID    
  END      
  
  COMMIT TRANSACTION
 END
 ELSE    
  BEGIN    
   SET @Output = -1    
  END    
   
END