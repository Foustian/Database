CREATE PROCEDURE [dbo].[usp_v4_fliq_Customer_SelectAllDropDown]
AS
BEGIN
	SELECT
		Client.ClientKey,
		Client.ClientName
	FROM
		[Client]
	WHERE
		[Client].IsActive=1 
		AND Client.IsFliq = 1
END