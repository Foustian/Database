CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_SearchRequest_Update]     
(
	@IQAgent_SearchRequestID BIGINT,    
	@ClientGuid UNIQUEIDENTIFIER,    
	@Query_Name VARCHAR(200),    
	@SearchTerm XML  
)
AS     
BEGIN    

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF NOT EXISTS(SELECT 1 FROM IQAgent_SearchRequest WHERE ID <> @IQAgent_SearchRequestID AND Query_Name = @Query_Name AND IsActive =  1 AND ClientGUID = @ClientGuid)    
BEGIN    
     
	DECLARE @Version BIGINT,  
			@OldSearchTerm XML,  
			@PMXml XML     
        
    SELECT 
			@Version = Query_Version,  
			@OldSearchTerm=SearchTerm  
    FROM 
			IQAgent_SearchRequest     
    WHERE 
			ClientGUID = @ClientGUID     
		AND	ID = @IQAgent_SearchRequestID    
       
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
		AND	ID = @IQAgent_SearchRequestID    
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

		-- If the agent previously had a Twitter rule set but no longer does, deactivate the corresponding record in IQ_Twitter_Settings
		DECLARE @OldGnipTag VARCHAR(50) = ISNULL(@OldSearchTerm.query('SearchRequest/Twitter/GnipTagList/GnipTag').value('.','varchar(50)'), '')
		DECLARE @NewGnipTag VARCHAR(50) = ISNULL(@SearchTerm.query('SearchRequest/Twitter/GnipTagList/GnipTag').value('.','varchar(50)'), '')

		IF (@OldGnipTag != '' AND @NewGnipTag = '')
		  BEGIN
			UPDATE IQ_Twitter_Settings
			SET IsActive = 0,
				ModifiedDate = GETDATE()
			WHERE UserTrackGUID = @OldGnipTag

			exec usp_v5_IQService_TwitterSettings_Insert @ClientGuid, null, @IQAgent_SearchRequestID, 0
		  END

		-- If the agent previously had a TVEyes rule set but no longer does, deactivate the corresponding record in IQ_TVEyes_Settings
		DECLARE @OldTVESettingsKey VARCHAR(50) = @OldSearchTerm.query('SearchRequest/TM/TVEyesSettingsKey').value('.','bigint')
		DECLARE @NewTVESettingsKey VARCHAR(50) = @SearchTerm.query('SearchRequest/TM/TVEyesSettingsKey').value('.','bigint')

		IF (@OldTVESettingsKey != 0 AND @NewTVESettingsKey = 0)
		  BEGIN
			UPDATE IQ_TVEyes_Settings
			SET IsActive = 0,
				ModifiedDate = GETDATE()
			WHERE TVESettingsKey = @OldTVESettingsKey

			exec usp_v5_IQService_TVEyesSettings_Insert @ClientGuid, null, @IQAgent_SearchRequestID, 0
		  END
	END 
	
	COMMIT TRANSACTION
		
	SELECT @@ROWCOUNT  
	
  END    
  ELSE  
  BEGIN  
	SELECT -2  
  END  
END
