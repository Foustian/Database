CREATE PROCEDURE [dbo].[usp_v4_Client_SelectAllFliqClientList]
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
	order by ClientName
END