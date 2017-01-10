CREATE PROCEDURE [dbo].[usp_IOSService_fliQ_CustomCategory_SelectByClientGuid]
	@ClientGuid uniqueidentifier 
AS
BEGIN
	SELECT 
			CategoryName,
			CategoryGUID
	FROM	
			CustomCategory
	WHERE
			ClientGUID = @ClientGuid
			AND IsActive = 1
	order by
			CategoryName
END