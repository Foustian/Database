CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectIQTVRegionByClientGUID]
	@ClientGuid uniqueidentifier
AS
BEGIN

	SELECT	[Value] as 'IQTVRegion'
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'IQTVRegion'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid Desc
END