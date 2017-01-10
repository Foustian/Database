CREATE PROCEDURE [dbo].[usp_v4_fliQ_ClientApplication_SelectAllDropDown]
AS
BEGIN
	SELECT
			ClientKey,
			ClientName
	FROM
			Client
	WHERE
			Client.IsActive = 1
			and Client.IsFliq  = 1

	SELECT
			ID,
			[Application]
	FROM	
			fliQ_Application
	WHERe
			IsActive = 1

		
END