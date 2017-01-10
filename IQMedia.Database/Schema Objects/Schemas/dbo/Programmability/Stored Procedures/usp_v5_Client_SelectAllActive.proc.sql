CREATE PROCEDURE [dbo].[usp_v5_Client_SelectAllActive]

AS
BEGIN

	SET NOCOUNT ON;

	SELECT
			ClientKey,
			ClientName,
			MCID
	FROM
			Client
	WHERE
			Client.IsActive = 1

END