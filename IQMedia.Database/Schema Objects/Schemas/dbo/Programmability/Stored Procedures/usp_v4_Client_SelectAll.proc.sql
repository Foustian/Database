CREATE PROCEDURE [dbo].[usp_v4_Client_SelectAll]
AS
BEGIN
	SELECT	
		Client.ClientKey,
		Client.ClientName 
	FROM 
		Client 
	ORDER BY ClientName
END