CREATE PROCEDURE [dbo].[usp_isvc_CustomCategory_SelectByClientGuid]
	@ClientGuid uniqueidentifier
AS
BEGIN
	SELECT
			CategoryName,
			CategoryGUID
	FROM	
			CustomCategory
	Where
			ClientGUID = @ClientGuid
END