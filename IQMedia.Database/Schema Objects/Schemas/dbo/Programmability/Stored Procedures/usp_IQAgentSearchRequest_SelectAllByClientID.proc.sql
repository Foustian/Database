-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_SelectAllByClientID]
	-- Add the parameters for the stored procedure here
	@ClientGuid uniqueidentifier
	
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
			SearchTerm,
			IsActive
	FROM
		IQAgent_SearchRequest
	WHERE 
		ClientGUID = @ClientGuid
	
	ORDER BY Query_Name,Query_Version
	
END
