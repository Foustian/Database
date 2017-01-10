CREATE PROCEDURE [dbo].[usp_IQAgent_SearchRequest_SelectAllowedMediaTypesByID]
	@ID bigint,
	@IsAllowTV bit output,
	@IsAllowNM bit output,
	@IsAllowSM bit output
AS
BEGIN
	SELECT 
			@IsAllowTV = SearchTerm.exist('/SearchRequest/TV'),
			@IsAllowNM = SearchTerm.exist('/SearchRequest/News'),
			@IsAllowSM = SearchTerm.exist('/SearchRequest/SocialMedia')
	FROM 
			IQAgent_SearchRequest 
	WHERE
			ID = @ID
END