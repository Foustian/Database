CREATE PROCEDURE [dbo].[usp_IQAgent_NMResults_Delete]
	@IQAgent_NMResultsKey varchar(MAX)
AS
BEGIN
	DECLARE @Query as nvarchar(MAX)
	
	SET @Query = 'UPDATE IQAgent_NMResults SET IQAgent_NMResults.IsActive = 0 WHERE ID IN (' + @IQAgent_NMResultsKey + ')'

	EXEC sp_executesql @Query
END