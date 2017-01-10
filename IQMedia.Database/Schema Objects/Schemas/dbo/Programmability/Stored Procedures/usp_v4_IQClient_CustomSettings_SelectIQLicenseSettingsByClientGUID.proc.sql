CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectIQLicenseSettingsByClientGUID]
	@ClientGuid uniqueidentifier
AS
BEGIN

	SELECT	[Value] as 'IQLicense'
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'IQLicense'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid Desc
END