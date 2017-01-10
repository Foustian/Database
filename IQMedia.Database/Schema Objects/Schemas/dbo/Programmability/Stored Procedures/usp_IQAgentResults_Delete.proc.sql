/*
	Created By 	: templage Generator ( An AmulTek product )
	Created On 	: 3/22/2010
	Purpose		: To Update data in RL_GUIDS
*/


-- EXEC [dbo].[usp_IQAgentResults_Delete] '14,15'

CREATE PROCEDURE [dbo].[usp_IQAgentResults_Delete]
(
	@IQAgentResultKeys varchar(500)
)
AS
BEGIN

	DECLARE @Query as nvarchar(1000)
	
	SET @Query = 'UPDATE IQAgent_TVResults SET IQAgent_TVResults.IsActive = 0 WHERE ID IN (' + @IQAgentResultKeys + ')'

	EXEC sp_executesql @Query
	
END