CREATE PROCEDURE [dbo].[usp_IQAgent_SMResults_Delete]
	@IQAgent_SMResultsKey varchar(MAX)
AS
BEGIN
	DECLARE @Query as nvarchar(MAX)
	
	SET @Query = 'UPDATE IQAgent_SMResults SET IQAgent_SMResults.IsActive = 0 WHERE ID IN (' + @IQAgent_SMResultsKey + ')'

	EXEC sp_executesql @Query
END