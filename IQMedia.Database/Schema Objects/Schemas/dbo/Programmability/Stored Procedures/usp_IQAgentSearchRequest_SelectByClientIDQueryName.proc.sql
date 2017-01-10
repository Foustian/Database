-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_SelectByClientIDQueryName]
	-- Add the parameters for the stored procedure here
	@ClientGuid	uniqueidentifier,
	@Query_Name varchar(100)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
			ID,
			ClientGUID,
			Query_Name,
			Query_Version,
			SearchTerm
	FROM
			IQAgent_SearchRequest
	
	WHERE	ClientGUID = @ClientGuid 
	AND		Query_Name = @Query_Name 
	AND		IsActive=1
    
END
