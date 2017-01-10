CREATE PROCEDURE [dbo].[usp_isvc_IQSolrEngines_SelectAll]
(
	@Requestor VARCHAR(50) = null
)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
			MediaType,
			FromDate,
			ToDate,
			BaseUrl
	FROM	
			IQSolrEngines
	WHERE
			IsActive = 1 
		AND ((@Requestor IS NULL AND Requestor = 'apiservices') OR (@Requestor = Requestor))
END