﻿CREATE PROCEDURE [dbo].[usp_v4_IQAgent_SearchRequest_Insert]
	@ClientGuid uniqueidentifier,
	@Query_Name varchar(200),
	@SearchTerm xml,
	@v5SearchTerm xml = null,
	@Output int output
AS 
BEGIN
	
	Declare @AllowedIQAgent int
	Select @AllowedIQAgent =  isnull((Select Value from IQClient_CustomSettings where Field = 'TotalNoOfIQAgent' and _clientGUID = @ClientGuid),(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field ='TotalNoOfIQAgent'))
	
	Declare @SearchRequestCount int
	Select @SearchRequestCount = COUNT(*) from IQAgent_SearchRequest where ClientGuid = @ClientGuid and IsActive > 0
	
	print '@SearchRequestCount:' + CAST(@SearchRequestCount	 AS VARCHAR(10))
	PRINT '@AllowedIQAgent' + CAST(@AllowedIQAgent	 AS VARCHAR(10))
			
	if @SearchRequestCount < @AllowedIQAgent
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM IQAgent_SearchRequest Where Query_Name = @Query_Name AND IsActive > 0 and ClientGUID = @ClientGuid)
				BEGIN
					
					DECLARE @IQAgentSearchRequestID AS BIGINT
					
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
							@v5SearchTerm,
							GETDATE(),
							GETDATE(),
							1,
							@SearchTerm
						)
					
					SET @IQAgentSearchRequestID = SCOPE_IDENTITY()
					
					INSERT INTO IQAgent_SearchRequest_History
					(
						_SearchRequestID,
						[Version],
						SearchRequest,
						Name,
						DateCreated,
						v4SearchRequest
					)
					VALUES
					(
						@IQAgentSearchRequestID,
						1,
						@v5SearchTerm,
						@Query_Name,
						GETDATE(),
						@SearchTerm
					)
					
					SET @Output = @IQAgentSearchRequestID
				END
			ELSE
				BEGIN
					SET @Output = -1 
				END
		END
	ELSE
		BEGIN
				SET @Output = -2
		END
END