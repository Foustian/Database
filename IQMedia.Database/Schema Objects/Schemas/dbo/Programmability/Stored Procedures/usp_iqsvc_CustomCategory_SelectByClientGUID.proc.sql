CREATE PROCEDURE [dbo].[usp_iqsvc_CustomCategory_SelectByClientGUID]
	
	@ClientGUID		uniqueidentifier
	
AS
BEGIN
	SET NOCOUNT ON;
	
	

	SELECT 
			
			CategoryName,
			CategoryGUID
			
	FROM
			CustomCategory
	WHERE
			ClientGUID = @ClientGUID AND	
			IsActive = 1
	Order By 
			CategoryName
	
END