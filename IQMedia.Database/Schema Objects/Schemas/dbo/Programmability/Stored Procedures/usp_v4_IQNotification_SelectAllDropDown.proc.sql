CREATE PROCEDURE [dbo].[usp_v4_IQNotification_SelectAllDropDown]
	@ClientGuid uniqueidentifier
AS
BEGIN
	SELECT
			ID,
			Query_Name
			
	FROM	
			IQAgent_SearchRequest
	WHERE
			ClientGUID = @ClientGuid
			AND IsActive = 1
	
	SELECT
			ID,
			Location
	FROM	
			IQClient_CustomImage
	WHERE
			_ClientGUID = @ClientGuid
			AND IsActive = 1
END