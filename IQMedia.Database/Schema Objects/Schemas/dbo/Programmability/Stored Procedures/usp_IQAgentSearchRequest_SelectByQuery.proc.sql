-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_SelectByQuery]
	-- Add the parameters for the stored procedure here
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
	
	WHERE Query_Name = @Query_Name and IsActive=1
    
END
