-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgentResults_SelectByQueryName]
	-- Add the parameters for the stored procedure here
	@SearchRequestID bigint
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		IQAgent_TVResults.ID,
		RL_VideoGUID,
		Number_Hits,
		RL_Date,
		RL_Time,
		Rl_Market,
		Rl_Station
	FROM
		IQAgent_TVResults
	
	INNER JOIN IQAgent_SearchRequest on dbo.IQAgent_TVResults.SearchRequestID = dbo.IQAgent_SearchRequest.ID
	
	WHERE SearchRequestID = @SearchRequestID AND dbo.IQAgent_TVResults.IsActive=1
    
END
