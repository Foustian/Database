CREATE PROCEDURE [dbo].[usp_v4_IQSolrEngines_SelectAll]
	@Requestor varchar(50) = null
AS
BEGIN
	SELECT
			MediaType,
			FromDate,
			ToDate,
			BaseUrl
	FROM	
			IQSolrEngines
	WHERE
			IsActive = 1 
		AND ((@Requestor IS NULL AND Requestor = 'Web') OR (@Requestor = Requestor))
END