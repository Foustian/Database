CREATE PROCEDURE [dbo].[usp_v4_IQAgent_SearchRequest_Update]   
 @IQAgent_SearchRequestID BIGINT,    
 @ClientGuid UNIQUEIDENTIFIER,    
 @Query_Name VARCHAR(200),    
 @SearchTerm XML,    
 @v5SearchTerm xml = null,
 @Output INT OUTPUT    
AS     
BEGIN    
     
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
 IF NOT EXISTS(SELECT 1 FROM IQAgent_SearchRequest WHERE ID <> @IQAgent_SearchRequestID AND Query_Name = @Query_Name AND IsActive =  1 AND ClientGUID = @ClientGuid)    
  BEGIN    
     
     DECLARE @Version BIGINT,  
   @OldSearchTerm XML,  
   @TMXml XML,  
   @PMXml XML     
        
     SELECT @Version = Query_Version,  
   @OldSearchTerm=SearchTerm  
     FROM IQAgent_SearchRequest     
     WHERE ClientGUID = @ClientGUID     
     AND  ID = @IQAgent_SearchRequestID    
       
     SELECT  
   @TMXml=CASE WHEN tbl.c.exist('TM')=1 THEN tbl.c.query('TM') ELSE NULL END,  
   @PMXml=CASE WHEN tbl.c.exist('PM')=1 THEN tbl.c.query('PM') ELSE NULL END  
     FROM  
   @OldSearchTerm.nodes('SearchRequest') AS tbl(c)  
     
 IF (@TMXml IS NOT NULL)  
  BEGIN  
   SET @SearchTerm.modify('insert sql:variable("@TMXml") into (/SearchRequest)[1]')    
   IF @v5SearchTerm IS NOT NULL
     BEGIN
		SET @v5SearchTerm.modify('insert sql:variable("@TMXml") into (/SearchRequest)[1]')   
	 END
  END  
    
 IF (@PMXml IS NOT NULL)  
  BEGIN  
   SET @SearchTerm.modify('insert sql:variable("@PMXml") into (/SearchRequest)[1]')  
   IF @v5SearchTerm IS NOT NULL
     BEGIN
		SET @v5SearchTerm.modify('insert sql:variable("@PMXml") into (/SearchRequest)[1]')   
	 END
  END  
         
 BEGIN TRANSACTION;   
           
 UPDATE   
   IQAgent_SearchRequest       
 SET    
  Query_Name = @Query_Name,      
       v4SearchTerm = @SearchTerm,    
       Query_Version = @Version + 1,    
       ModifiedDate=GETDATE(),
	   SearchTerm = @v5SearchTerm     
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
      v4SearchRequest,    
      Name,    
      DateCreated,
	  SearchRequest
     )    
     VALUES    
     (    
      @IQAgent_SearchRequestID,    
      @Version + 1,    
      @SearchTerm,    
      @Query_Name,    
      GETDATE(),
	  @v5SearchTerm
     )    
   SET @Output = @IQAgent_SearchRequestID    
  END      
  
  COMMIT TRANSACTION
 END
 ELSE    
  BEGIN    
   SET @Output = -1    
  END    
   
END