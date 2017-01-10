CREATE PROCEDURE [dbo].[usp_v4_IQClient_CustomSettings_SelectRawMediaPauseSecsByClientGUID]
	@ClientGuid uniqueidentifier
AS
BEGIN

	SELECT	TOP 1 [Value] as 'RawMediaPauseSecs'
	FROM	IQClient_CustomSettings 
	WHERE	Field = 'RawMediaPauseSecs'
	AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER BY _ClientGuid Desc
END