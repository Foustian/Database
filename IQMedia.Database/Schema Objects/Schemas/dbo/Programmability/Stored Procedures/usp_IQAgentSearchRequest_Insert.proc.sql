-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- exec usp_IQAgentSearchRequest_Insert NULL,1,2,'Earthquake44',0,'Earthquake447',NULL

CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_Insert] 
	-- Add the parameters for the stored procedure here
	@SearchRequestKey	bigint output,
	@ClientID			bigint,
	@IQ_Agent_UserID	bigint,
	@Query_Name			varchar(100),
	@Query_Version		int,
	@SearchTerm			xml
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
		DECLARE @Version as int,@Search_Term as varchar(250)
		
		IF NOT EXISTS(SELECT 1 FROM IQAgentSearchRequest WHERE ClientID = @ClientID AND Query_Name = @Query_Name)
			BEGIN
				INSERT INTO	
					IQAgentSearchRequest
					(
						ClientID,
						IQ_Agent_UserID,
						Query_Name,
						Query_Version,
						SearchTerm
					)
					VALUES
					(
						@ClientID,
						@IQ_Agent_UserID,
						@Query_Name,
						@Query_Version,
						@SearchTerm
					)
				SELECT @SearchRequestKey = SCOPE_IDENTITY()
			END
		ELSE
			BEGIN
			
			
				DECLARE @Old_SearchRequestID as BIGINT
				
				SELECT 
						@Version = MAX(Query_Version) 
				FROM 
						IQAgentSearchRequest 
				WHERE 
						ClientID = @ClientID 
				AND Query_Name = @Query_Name
			
			
				SELECT 
						@Old_SearchRequestID = SearchRequestKey
				FROM 
						IQAgentSearchRequest 
				WHERE 
						ClientID = @ClientID 
				AND		Query_Name = @Query_Name
				AND		IsActive = 1
			
			
				-- First InActive all records with same query name and clientid
				UPDATE IQAgentSearchRequest SET IsActive = 0 WHERE ClientID = @ClientID AND Query_Name = @Query_Name
				
				SET @Query_Version = @Version + 1
				
				-- Insert new record with increamented version
				
				INSERT INTO	
					IQAgentSearchRequest
					(
						ClientID,
						IQ_Agent_UserID,
						Query_Name,
						Query_Version,
						SearchTerm
					)
					VALUES
					(
						@ClientID,
						@IQ_Agent_UserID,
						@Query_Name,
						@Query_Version,
						@SearchTerm
					)
				SELECT @SearchRequestKey = SCOPE_IDENTITY()
				
				-- Now Update IQNotificationSettings Table's SearchRequestID With Newer One
				
				Update IQNotificationSettings Set SearchRequestID = @SearchRequestKey
				Where SearchRequestID = @Old_SearchRequestID
				
			END
END


/****** Object:  StoredProcedure [dbo].[usp_SearchRequest_SelectAll]    Script Date: 04/01/2010 11:39:40 ******/
SET ANSI_NULLS ON
