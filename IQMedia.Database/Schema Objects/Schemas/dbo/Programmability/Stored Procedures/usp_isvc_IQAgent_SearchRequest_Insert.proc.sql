CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_SearchRequest_Insert]
(
	@ClientGuid UNIQUEIDENTIFIER,
	@Query_Name VARCHAR(200),
	@SearchTerm XML
)
AS 
BEGIN

	DECLARE @v4SearchTerm XML=@SearchTerm

	DECLARE @IQAgentSearchRequestID AS BIGINT
	SET @IQAgentSearchRequestID = NULL
	
	DECLARE @AllowedIQAgent INT
	SELECT @AllowedIQAgent =  ISNULL((SELECT VALUE FROM IQClient_CustomSettings WHERE Field = 'TotalNoOfIQAgent' AND _clientGUID = @ClientGuid),(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field ='TotalNoOfIQAgent'))
	
	DECLARE @SearchRequestCount INT
	SELECT @SearchRequestCount = COUNT(*) FROM IQAgent_SearchRequest WHERE ClientGuid = @ClientGuid AND IsActive = 1
	
	PRINT '@SearchRequestCount:' + CAST(@SearchRequestCount	 AS VARCHAR(10))
	PRINT '@AllowedIQAgent' + CAST(@AllowedIQAgent	 AS VARCHAR(10))
			
	IF @SearchRequestCount < @AllowedIQAgent
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM IQAgent_SearchRequest WHERE Query_Name = @Query_Name AND IsActive = 1 AND ClientGUID = @ClientGuid)
				BEGIN
					
					INSERT INTO 
						IQAgent_SearchRequest(
							ClientGUID,
							Query_Name,
							Query_Version,
							SearchTerm,
							CreatedDate,
							ModifiedDate,
							IsActive,
							v4SearchTerm
						)
						VALUES(
							@ClientGuid,
							@Query_Name,
							1,
							@SearchTerm,
							GETDATE(),
							GETDATE(),
							1,
							@v4SearchTerm
						)
					
					SET @IQAgentSearchRequestID = SCOPE_IDENTITY()
					
					INSERT INTO IQAgent_SearchRequest_History
					(
						_SearchRequestID,
						[VERSION],
						SearchRequest,
						Name,
						DateCreated,
						v4SearchRequest
					)
					VALUES
					(
						@IQAgentSearchRequestID,
						1,
						@SearchTerm,
						@Query_Name,
						GETDATE(),
						@v4SearchTerm
					)		
					
			END
			
		END
		
		SELECT @IQAgentSearchRequestID as IQAgentSearchRequestID, @AllowedIQAgent as AllowedIQAgent, @SearchRequestCount as SearchRequestCount
END