-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_UpdateIsActive] 
	-- Add the parameters for the stored procedure here
	@SearchRequestKey	bigint,
	@IsActive			bit,
	@ClientGuid			uniqueidentifier,
	@Query_Name			varchar(100)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @Old_SearchRequestID AS BIGINT
	
	SELECT @Old_SearchRequestID = ID FROM IQAgent_SearchRequest
	WHERE  ClientGUID = @ClientGuid AND Query_Name = @Query_Name AND IsActive = 1
	
	
	-- First Set All Records InActive 
	
	UPDATE IQAgent_SearchRequest SET IsActive = 0 WHERE ClientGUID = @ClientGuid AND Query_Name = @Query_Name
	
	
	UPDATE 
			IQAgent_SearchRequest 
	SET 
			IsActive = @IsActive 
	WHERE 
			ID = @SearchRequestKey
			
	IF @IsActive = 1 
		BEGIN
		
			UPDATE IQNotificationSettings SET SearchRequestID = @SearchRequestKey
			WHERE SearchRequestID = @Old_SearchRequestID
			
		END
	
END


/****** Object:  StoredProcedure [dbo].[usp_SearchRequest_SelectAll]    Script Date: 04/01/2010 11:39:40 ******/
SET ANSI_NULLS ON
